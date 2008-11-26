From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 10/39] wimax: Generic messaging interface between user space and driver/device
Date: Wed, 26 Nov 2008 14:40:29 -0800
Message-ID: <802197ab7fc27af2e6e36ab83039cad6569997e1.1227691434.git.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:44410 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752121AbYKZWlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 17:41:14 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements a direct communication channel between user space and
the driver/device, by which free form messages can be sent back and
forth.

This is intended for device-specific features, vendor quirks, etc.

Currently is the only communication mechanism used because there is no
standard kernel API defined for WiMAX operation. Not enough devices
are in the market to decide what is a good user-kernel API/abstraction
layer.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-msg.c |  495 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 495 insertions(+), 0 deletions(-)
 create mode 100644 net/wimax/op-msg.c

diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
new file mode 100644
index 0000000..cfa7929
--- /dev/null
+++ b/net/wimax/op-msg.c
@@ -0,0 +1,495 @@
+/*
+ * Linux WiMAX
+ * Generic messaging interface between userspace and driver/device
+ *
+ *
+ * Copyright (C) 2007-2008 Intel Corporation <linux-wimax@intel.com>
+ * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ *
+ *
+ * This implements a direct communication channel between user space and
+ * the driver/device, by which free form messages can be sent back and
+ * forth.
+ *
+ * This is intended for device-specific features, vendor quirks, etc.
+ *
+ * By default, all devices get one default pipe ("the messaging
+ * pipe").
+ *
+ * Due to limitations in the way generic netlink is implemented (no
+ * multicast from user space clients to the kernel), the messaging
+ * pipe is the only way to send messages from user space to the
+ * driver.
+ *
+ * However, devices can create as many kernel-to-user pipes as
+ * needed.
+ *
+ * The functions wimax.h:wimax_msg_*() operate identical to
+ * wimax_pipe_msg*(), but over the default pipe.
+ *
+ * See include/net/wimax.h
+ *
+ * GENERIC NETLINK ENCODING AND CAPACITY
+ *
+ * Messages are encoded as a binary netlink attribute using nla_put()
+ * using type NLA_UNSPEC (as some versions of libnl still in
+ * deployment don't yet understand NLA_BINARY).
+ *
+ * The maximum capacity of this transport is undetermined. Sending of
+ * messages up to 4k has been tested with success. Bigger buffers
+ * beware.
+ *
+ * RECEPTION OF MESSAGES
+ *
+ * When a message is received from user space, it is passed verbatim
+ * to the driver calling wimax_dev->op_msg_from_user(). The return
+ * value from this function is passed back to user space as an ack
+ * over the generic netlink protocol.
+ *
+ * Remember these messages from user space to the kernel always
+ * operate over the default pipe.
+ *
+ * The stack doesn't do any processing or interpretation of these
+ * messages.
+ *
+ * SENDING MESSAGES
+ *
+ * Messages can be sent with wimax_[pipe_]msg().
+ *
+ * If the message delivery needs to happen on a different context to
+ * that of its creation, wimax_[pipe_]msg_alloc() can be used to get a
+ * pointer to the message that can be delivered later on with
+ * wimax_[pipe_]msg_send().
+ *
+ * ROADMAP
+ *
+ * wimax_gnl_doit_msg_from_user()    Process a message from user space
+ *   wimax_dev_get_by_genl_info()
+ *   wimax_dev->op_msg_from_user()   Delivery of message to the driver
+ *
+ * wimax_pipe_msg()                  Send a message to user space
+ *   wimax_pipe_msg_alloc()
+ *   wimax_pipe_msg_send()
+ *
+ * wimax_pipe_add()		     Create a new pipe
+ * wimax_pipe_rm()                   Remove a pipe
+ */
+#include <linux/device.h>
+#include <net/genetlink.h>
+#include <linux/netdevice.h>
+#include <linux/wimax.h>
+#include <linux/security.h>
+#include "wimax-internal.h"
+
+
+#define D_SUBMODULE op_msg
+#include "debug-levels.h"
+
+
+/**
+ * wimax_pipe_add - Create a new messaging pipe
+ *
+ * @wimax_dev: WiMAX device descriptor (properly referenced)
+ *
+ * @name: Name of the new pipe
+ *
+ * Returns: Positive pipe ID descriptor [for to wimax_pipe_msg*()].
+ *     Negative errno code on error.
+ *
+ * Description:
+ *
+ * Creates a new pipe for sending messages or notifications to user
+ * space. User space can read them by receiving from the @name generic
+ * netlink multicast group associated to @wimax_dev.
+ *
+ * We allow running this when the device is still uninitialized. Not
+ * so when the device is being torn down.
+ */
+struct wimax_pipe *wimax_pipe_add(struct wimax_dev *wimax_dev,
+				  const char *name)
+{
+	int result;
+	struct device *dev = wimax_dev_to_dev(wimax_dev);
+	struct wimax_pipe *pipe;
+
+	d_fnstart(3, dev, "(wimax_dev %p name %s)\n", wimax_dev, name);
+	result = -ENOMEM;
+	pipe = kzalloc(sizeof(*pipe), GFP_KERNEL);
+	if (pipe == NULL) {
+		dev_err(dev, "cannot allocate pipe '%s': %d\n",
+			name, result);
+		goto error_kzalloc;
+	}
+
+	snprintf(pipe->mcg.name, sizeof(pipe->mcg.name), name);
+	result = genl_register_mc_group(&wimax_dev->gnl_family, &pipe->mcg);
+	if (unlikely(result < 0)) {
+		dev_err(dev, "cannot register pipe '%s': %d\n",
+			name, result);
+		goto error_register_mc_group;
+	}
+	mutex_lock(&wimax_dev->mutex);
+	list_add_tail(&pipe->list_node, &wimax_dev->pipe_list);
+	mutex_unlock(&wimax_dev->mutex);
+	d_fnstart(3, dev, "(wimax_dev %p name %s) = %p\n",
+		  wimax_dev, name, pipe);
+	return pipe;
+
+error_register_mc_group:
+	kfree(pipe);
+error_kzalloc:
+	d_fnstart(3, dev, "(wimax_dev %p name %s) = %d\n",
+		  wimax_dev, name, result);
+	return ERR_PTR(result);
+}
+EXPORT_SYMBOL_GPL(wimax_pipe_add);
+
+
+/*
+ * Remove a pipe with locking (lock assumed taken)
+ *
+ * We do it like this to avoid calling the generic netlink code with
+ * the lock held -- the lockdep validator will complain in some false
+ * positive cases.
+ */
+void __wimax_pipe_rm(struct wimax_dev *wimax_dev, struct wimax_pipe *pipe)
+{
+	struct device *dev = wimax_dev_to_dev(wimax_dev);
+
+	d_fnstart(3, dev, "(wimax_dev %p pipe %p)\n", wimax_dev, pipe);
+	list_del(&pipe->list_node);
+	genl_unregister_mc_group(&wimax_dev->gnl_family, &pipe->mcg);
+	kfree(pipe);
+	d_fnend(3, dev, "(wimax_dev %p pipe %p) = void\n", wimax_dev, pipe);
+}
+
+
+/**
+ * wimax_pipe_rm - Remove a messaging pipe
+ *
+ * @wimax_dev: WiMAX device descriptor (properly referenced)
+ *
+ * @name: name of the pipe to remove
+ *
+ * Removes a messaging pipe previously created with wimax_pipe_add().
+ */
+void wimax_pipe_rm(struct wimax_dev *wimax_dev, struct wimax_pipe *pipe)
+{
+	struct device *dev = wimax_dev_to_dev(wimax_dev);
+
+	d_fnstart(3, dev, "(wimax_dev %p pipe %p)\n", wimax_dev, pipe);
+	mutex_lock(&wimax_dev->mutex);
+	list_del(&pipe->list_node);
+	mutex_unlock(&wimax_dev->mutex);
+	genl_unregister_mc_group(&wimax_dev->gnl_family, &pipe->mcg);
+	kfree(pipe);
+	d_fnend(3, dev, "(wimax_dev %p pipe %p) = void\n", wimax_dev, pipe);
+}
+EXPORT_SYMBOL_GPL(wimax_pipe_rm);
+
+
+/**
+ * wimax_pipe_msg_alloc - Create a new skb for sending a message to userspace
+ *
+ * @wimax_dev: WiMAX device descriptor
+ * @msg: pointer to the message data to send
+ * @size: size of the message to send (in bytes), including the header.
+ * @gfp_flags: flags for memory allocation.
+ *
+ * Returns: %0 if ok, negative errno code on error
+ *
+ * Description:
+ *
+ * Allocates an skb that will contain the message to send to user
+ * space over the messaging pipe and initializes it, copying the
+ * payload.
+ *
+ * Once this call is done, you can deliver it with
+ * wimax_pipe_msg_send().
+ *
+ * IMPORTANT:
+ *
+ * Don't use skb_push()/skb_pull()/skb_reserve() on the skb, as
+ * wimax_pipe_msg_send() depends on skb->data being placed at the
+ * beginning of the user message.
+ */
+struct sk_buff *wimax_pipe_msg_alloc(struct wimax_dev *wimax_dev,
+				     const void *msg, size_t size,
+				     gfp_t gfp_flags)
+{
+	int result;
+	struct device *dev = wimax_dev->net_dev->dev.parent;
+	void *genl_msg;
+	struct sk_buff *skb;
+
+	skb = genlmsg_new(nla_total_size(size), gfp_flags);
+	if (skb == NULL)
+		return NULL;
+	genl_msg = genlmsg_put(skb, 0, 0, &wimax_dev->gnl_family,
+			       0, WIMAX_GNL_OP_MSG_TO_USER);
+	if (genl_msg == NULL) {
+		dev_err(dev, "no memory to create generic netlink message\n");
+		goto error_genlmsg_put;
+	}
+	result = nla_put(skb, WIMAX_GNL_MSG_DATA, size, msg);
+	if (result == -1) {
+		dev_err(dev, "no memory to add payload in attribute\n");
+		goto error_nla_put;
+	}
+	genlmsg_end(skb, genl_msg);
+	return skb;
+
+error_nla_put:
+error_genlmsg_put:
+	nlmsg_free(skb);
+	return ERR_PTR(-ENOMEM);
+
+}
+EXPORT_SYMBOL_GPL(wimax_pipe_msg_alloc);
+
+
+/**
+ * wimax_msg_data - Return a pointer to a message's payload
+ *
+ * @msg: Pointer to a message created with wimax_pipe_msg_alloc()
+ */
+const void *wimax_msg_data(struct sk_buff *msg)
+{
+	struct nlmsghdr *nlh = (void *) msg->head;
+	struct nlattr *nla;
+
+	nla = nlmsg_find_attr(nlh, sizeof(struct genlmsghdr),
+			      WIMAX_GNL_MSG_DATA);
+	if (nla == NULL) {
+		printk(KERN_ERR "Cannot find attribute WIMAX_GNL_MSG_DATA\n");
+		return NULL;
+	}
+	return nla_data(nla);
+}
+EXPORT_SYMBOL_GPL(wimax_msg_data);
+
+
+/**
+ * wimax_msg_len - Return a message's payload length
+ *
+ * @msg: Pointer to a message created with wimax_pipe_msg_alloc()
+ */
+ssize_t wimax_msg_len(struct sk_buff *msg)
+{
+	struct nlmsghdr *nlh = (void *) msg->head;
+	struct nlattr *nla;
+
+	nla = nlmsg_find_attr(nlh, sizeof(struct genlmsghdr),
+			      WIMAX_GNL_MSG_DATA);
+	if (nla == NULL) {
+		printk(KERN_ERR "Cannot find attribute WIMAX_GNL_MSG_DATA\n");
+		return -EINVAL;
+	}
+	return nla_len(nla);
+}
+EXPORT_SYMBOL_GPL(wimax_msg_len);
+
+
+/**
+ * wimax_pipe_msg_send - Send a pre-allocated message to user space
+ *
+ * @wimax_dev: WiMAX device descriptor
+ *
+ * @pipe: Pipe handle, as returned by wimax_pipe_add(). For sending
+ *     over the default pipe, use a pipe id of @wimax_dev->pipe_msg.
+ *
+ * @skb: &struct sk_buff returned by wimax_pipe_msg_alloc(). Note the
+ *     ownership of @skb is transferred to this function.
+ *
+ * Returns: 0 if ok, < 0 errno code on error
+ *
+ * Description:
+ *
+ * Sends a free-form message that was preallocated with
+ * wimax_pipe_msg_alloc() and filled up.
+ *
+ * Assumes that once you pass an skb to this function for sending, it
+ * owns it and will release it when done (on success).
+ *
+ * IMPORTANT:
+ *
+ * Don't use skb_push()/skb_pull()/skb_reserve() on the skb, as
+ * wimax_pipe_msg_send() depends on skb->data being placed at the
+ * beginning of the user message.
+ */
+int wimax_pipe_msg_send(struct wimax_dev *wimax_dev, struct wimax_pipe *pipe,
+			struct sk_buff *skb)
+{
+	int result;
+	struct device *dev = wimax_dev->net_dev->dev.parent;
+	void *msg = skb->data;
+	size_t size = skb->len;
+	might_sleep();
+
+	d_printf(1, dev, "CTX: wimax msg, %zu bytes\n", size);
+	d_dump(2, dev, msg, size);
+	result = genlmsg_multicast(skb, 0, pipe->mcg.id, GFP_KERNEL);
+	d_printf(1, dev, "CTX: genl multicast result %d\n", result);
+	if (result == -ESRCH)	/* Nobody connected, ignore it */
+		result = 0;	/* btw, the skb is freed already */
+	return result;
+}
+EXPORT_SYMBOL_GPL(wimax_pipe_msg_send);
+
+
+/**
+ * wimax_pipe_msg - Send a message to user space
+ *
+ * @wimax_dev: WiMAX device descriptor (properly referenced)
+ *
+ * @pipe: Pipe handle, as returned by wimax_pipe_add(). For sending
+ *     over the default pipe, use a pipe id of @wimax_dev->pipe_msg.
+ *
+ *
+ * @buf: pointer to the message to send.
+ *
+ * @size: size of the buffer pointed to by @buf (in bytes).
+ *
+ * @gfp_flags: flags for memory allocation.
+ *
+ * Returns: %0 if ok, negative errno code on error.
+ *
+ * Description:
+ *
+ * Sends a free-form message to user space on the the @pipeid pipe of
+ * device @wimax_dev.
+ *
+ * NOTES:
+ *
+ * Once the @skb is given to this function, who will own it and will
+ * release it when done (unless it returns error).
+ */
+int wimax_pipe_msg(struct wimax_dev *wimax_dev, struct wimax_pipe *pipe,
+		   const void *buf, size_t size, gfp_t gfp_flags)
+{
+	int result = -ENOMEM;
+	struct sk_buff *skb;
+
+	skb = wimax_pipe_msg_alloc(wimax_dev, buf, size, gfp_flags);
+	if (skb == NULL)
+		goto error_msg_new;
+	result = wimax_pipe_msg_send(wimax_dev, pipe, skb);
+error_msg_new:
+	return result;
+}
+EXPORT_SYMBOL_GPL(wimax_pipe_msg);
+
+
+static
+struct nla_policy wimax_gnl_msg_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+	[WIMAX_GNL_MSG_DATA] = {
+		.type = NLA_UNSPEC,	/* libnl doesn't grok BINARY yet */
+	},
+};
+
+
+/*
+ * Relays a message from user space to the driver
+ *
+ * The skb is passed to the driver-specific function with the netlink
+ * and generic netlink headers already stripped.
+ *
+ * This call will block while handling/relaying the message.
+ */
+static
+int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *info)
+{
+	int result;
+	struct wimax_dev *wimax_dev;
+	struct device *dev;
+	struct nlmsghdr *nlh;
+	struct nlattr *tb[WIMAX_GNL_ATTR_MAX+1];
+	void *msg_buf;
+	size_t msg_len;
+
+	might_sleep();
+	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
+	result = -EPERM;
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+		goto error_perm;
+	result = -ENODEV;
+	wimax_dev = wimax_dev_get_by_genl_info(info);
+	if (wimax_dev == NULL)
+		goto error_no_wimax_dev;
+	dev = wimax_dev_to_dev(wimax_dev);
+
+	nlh = (void *) skb->data;
+
+	/* Parse the message to extract arguments */
+	result = nlmsg_parse(nlh, sizeof(struct genlmsghdr),
+			     tb, ARRAY_SIZE(tb),
+			     wimax_gnl_msg_policy);
+	if (result < 0) {
+		dev_err(dev, "WIMAX_GNL_MSG_FROM_USER: "
+			"can't parse message: %d\n", result);
+		goto error_parse;
+	}
+	result = -EINVAL;
+	if (tb[WIMAX_GNL_MSG_DATA] == NULL) {
+		dev_err(dev, "WIMAX_GNL_MSG_FROM_USER: can't find MSG_DATA "
+			"attribute\n");
+		goto error_no_pid;
+	}
+	msg_buf = nla_data(tb[WIMAX_GNL_MSG_DATA]);
+	msg_len = nla_len(tb[WIMAX_GNL_MSG_DATA]);
+
+	mutex_lock(&wimax_dev->mutex);
+	result = wimax_dev_is_ready(wimax_dev);
+	if (result < 0)
+		goto error_not_ready;
+	result = -ENOSYS;
+	if (wimax_dev->op_msg_from_user == NULL)
+		goto error_noop;
+
+	d_printf(1, dev,
+		 "CRX: nlmsghdr len %u type %u flags 0x%04x seq 0x%x pid %u\n",
+		 nlh->nlmsg_len, nlh->nlmsg_type, nlh->nlmsg_flags,
+		 nlh->nlmsg_seq, nlh->nlmsg_pid);
+	d_printf(1, dev, "CRX: wimax message %zu bytes\n", msg_len);
+	d_dump(2, dev, msg_buf, msg_len);
+
+	result = wimax_dev->op_msg_from_user(wimax_dev, msg_buf, msg_len, info);
+error_noop:
+error_not_ready:
+	mutex_unlock(&wimax_dev->mutex);
+error_no_pid:
+error_parse:
+	dev_put(wimax_dev->net_dev);
+error_no_wimax_dev:
+error_perm:
+	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
+	return result;
+}
+
+
+/*
+ * Generic Netlink glue
+ */
+
+struct genl_ops wimax_gnl_msg_from_user = {
+	.cmd = WIMAX_GNL_OP_MSG_FROM_USER,
+	.flags = 0,
+	.policy = wimax_gnl_msg_policy,
+	.doit = wimax_gnl_doit_msg_from_user,
+	.dumpit = NULL,
+};
+
-- 
1.5.6.5

