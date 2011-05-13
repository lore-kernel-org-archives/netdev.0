From: Roland Dreier <roland@kernel.org>
Subject: [RFC 1/3] RDMA: Add netlink infrastructure
Date: Fri, 13 May 2011 09:18:43 -0700
Message-ID: <1305303525-11113-2-git-send-email-roland@kernel.org>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog101.obsmtp.com ([74.125.245.70]:36337 "HELO
	na3sys010aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759483Ab1EMQSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 12:18:53 -0400
In-Reply-To: <1305303525-11113-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>

[Dave please do not apply even if this ends up in netdev patchwork!]

Add basic RDMA netlink infrastructure that allows for registration of
RDMA clients for which data is to be exported and supplies message
construction callbacks.

NOT-Signed-off-by: Nir Muchtar <nirm@voltaire.com>

[ Rename and reorganize a few things.  - Roland ]

NOT-Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/infiniband/core/Makefile  |    2 +-
 drivers/infiniband/core/device.c  |   11 ++
 drivers/infiniband/core/netlink.c |  190 +++++++++++++++++++++++++++++++++++++
 include/linux/netlink.h           |    1 +
 include/rdma/rdma_netlink.h       |   64 +++++++++++++
 5 files changed, 267 insertions(+), 1 deletions(-)
 create mode 100644 drivers/infiniband/core/netlink.c
 create mode 100644 include/rdma/rdma_netlink.h

diff --git a/drivers/infiniband/core/Makefile b/drivers/infiniband/core/Makefile
index cb1ab3e..c8bbaef 100644
--- a/drivers/infiniband/core/Makefile
+++ b/drivers/infiniband/core/Makefile
@@ -8,7 +8,7 @@ obj-$(CONFIG_INFINIBAND_USER_ACCESS) +=	ib_uverbs.o ib_ucm.o \
 					$(user_access-y)
 
 ib_core-y :=			packer.o ud_header.o verbs.o sysfs.o \
-				device.o fmr_pool.o cache.o
+				device.o fmr_pool.o cache.o netlink.o
 ib_core-$(CONFIG_INFINIBAND_USER_MEM) += umem.o
 
 ib_mad-y :=			mad.o smi.o agent.o mad_rmpp.o
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 46a7a3f..635c338 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -38,6 +38,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/mutex.h>
+#include <rdma/rdma_netlink.h>
 
 #include "core_priv.h"
 
@@ -736,8 +737,17 @@ static int __init ib_core_init(void)
 		goto err_sysfs;
 	}
 
+	ret = ibnl_init();
+	if (ret) {
+		printk(KERN_WARNING "Couldn't init IB netlink interface\n");
+		goto err_cache;
+	}
+
 	return 0;
 
+err_cache:
+	ib_cache_cleanup();
+
 err_sysfs:
 	ib_sysfs_cleanup();
 
@@ -748,6 +758,7 @@ err:
 
 static void __exit ib_core_cleanup(void)
 {
+	ibnl_cleanup();
 	ib_cache_cleanup();
 	ib_sysfs_cleanup();
 	/* Make sure that any pending umem accounting work is done. */
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
new file mode 100644
index 0000000..361e29f
--- /dev/null
+++ b/drivers/infiniband/core/netlink.c
@@ -0,0 +1,190 @@
+/*
+ * Copyright (c) 2010 Voltaire Inc.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
+#include <net/netlink.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+#include <rdma/rdma_netlink.h>
+
+struct ibnl_client {
+	struct list_head		list;
+	int				index;
+	int				nops;
+	const struct ibnl_client_cbs   *cb_table;
+};
+
+static DEFINE_MUTEX(ibnl_mutex);
+static struct sock *nls;
+static LIST_HEAD(client_list);
+
+int ibnl_add_client(int index, int nops,
+		    const struct ibnl_client_cbs cb_table[])
+{
+	struct ibnl_client *cur;
+	struct ibnl_client *nl_client;
+
+	nl_client = kmalloc(sizeof *nl_client, GFP_KERNEL);
+	if (!nl_client)
+		return -ENOMEM;
+
+	nl_client->index	= index;
+	nl_client->nops		= nops;
+	nl_client->cb_table	= cb_table;
+
+	mutex_lock(&ibnl_mutex);
+
+	list_for_each_entry(cur, &client_list, list) {
+		if (cur->index == index) {
+			pr_warn("Client for %d already exists\n", index);
+			mutex_unlock(&ibnl_mutex);
+			kfree(nl_client);
+			return -EINVAL;
+		}
+	}
+
+	list_add_tail(&nl_client->list, &client_list);
+
+	mutex_unlock(&ibnl_mutex);
+
+	return 0;
+}
+EXPORT_SYMBOL(ibnl_add_client);
+
+int ibnl_remove_client(int index)
+{
+	struct ibnl_client *cur, *next;
+
+	mutex_lock(&ibnl_mutex);
+	list_for_each_entry_safe(cur, next, &client_list, list) {
+		if (cur->index == index) {
+			list_del(&(cur->list));
+			mutex_unlock(&ibnl_mutex);
+			kfree(cur);
+			return 0;
+		}
+	}
+	pr_warn("Can't remove callback for client idx %d. Not found\n", index);
+	mutex_unlock(&ibnl_mutex);
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(ibnl_remove_client);
+
+void *ibnl_put_msg(struct sk_buff *skb, struct nlmsghdr **nlh, int seq,
+		   int len, int client, int op)
+{
+	unsigned char *prev_tail;
+
+	prev_tail = skb_tail_pointer(skb);
+	*nlh = NLMSG_NEW(skb, 0, seq, RDMA_NL_GET_TYPE(client, op),
+			len, NLM_F_MULTI);
+	(*nlh)->nlmsg_len = skb_tail_pointer(skb) - prev_tail;
+	return NLMSG_DATA(*nlh);
+
+nlmsg_failure:
+	nlmsg_trim(skb, prev_tail);
+	return NULL;
+}
+EXPORT_SYMBOL(ibnl_put_msg);
+
+int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
+		  int len, void *data, int type)
+{
+	unsigned char *prev_tail;
+
+	prev_tail = skb_tail_pointer(skb);
+	NLA_PUT(skb, type, len, data);
+	nlh->nlmsg_len += skb_tail_pointer(skb) - prev_tail;
+	return 0;
+
+nla_put_failure:
+	nlmsg_trim(skb, prev_tail - nlh->nlmsg_len);
+	return -EMSGSIZE;
+}
+EXPORT_SYMBOL(ibnl_put_attr);
+
+static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct ibnl_client *client;
+	int type = nlh->nlmsg_type;
+	int index = RDMA_NL_GET_CLIENT(type);
+	int op = RDMA_NL_GET_OP(type);
+
+	list_for_each_entry(client, &client_list, list) {
+		if (client->index == index) {
+			if (op < 0 || op >= client->nops ||
+			    !client->cb_table[RDMA_NL_GET_OP(op)].dump)
+				return -EINVAL;
+			return netlink_dump_start(nls, skb, nlh,
+						  client->cb_table[op].dump,
+						  NULL);
+		}
+	}
+
+	pr_info("Index %d wasn't found in client list\n", index);
+	return -EINVAL;
+}
+
+static void ibnl_rcv(struct sk_buff *skb)
+{
+	mutex_lock(&ibnl_mutex);
+	netlink_rcv_skb(skb, &ibnl_rcv_msg);
+	mutex_unlock(&ibnl_mutex);
+}
+
+int ibnl_init(void)
+{
+	nls = netlink_kernel_create(&init_net, NETLINK_INFINIBAND, 0, ibnl_rcv,
+				    NULL, THIS_MODULE);
+	if (!nls) {
+		pr_warn("Failed to create netlink socket\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void ibnl_cleanup(void)
+{
+	struct ibnl_client *cur, *next;
+
+	mutex_lock(&ibnl_mutex);
+	list_for_each_entry_safe(cur, next, &client_list, list) {
+		list_del(&(cur->list));
+		kfree(cur);
+	}
+	mutex_unlock(&ibnl_mutex);
+
+	netlink_kernel_release(nls);
+}
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 4c4ac3f..b1e3e59 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -24,6 +24,7 @@
 /* leave room for NETLINK_DM (DM Events) */
 #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
 #define NETLINK_ECRYPTFS	19
+#define NETLINK_INFINIBAND	20
 
 #define MAX_LINKS 32		
 
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
new file mode 100644
index 0000000..c983a19
--- /dev/null
+++ b/include/rdma/rdma_netlink.h
@@ -0,0 +1,64 @@
+#ifndef _RDMA_NETLINK_H
+#define _RDMA_NETLINK_H
+
+#define RDMA_NL_GET_CLIENT(type) ((type & (((1 << 6) - 1) << 10)) >> 10)
+#define RDMA_NL_GET_OP(type) (type & ((1 << 10) - 1))
+#define RDMA_NL_GET_TYPE(client, op) ((client << 10) + op)
+
+#ifdef __KERNEL__
+
+#include <linux/netlink.h>
+
+struct ibnl_client_cbs {
+	int (*dump)(struct sk_buff *skb, struct netlink_callback *nlcb);
+};
+
+int ibnl_init(void);
+void ibnl_cleanup(void);
+
+/**
+ * Add a a client to the list of IB netlink exporters.
+ * @index: Index of the added client
+ * @nops: Number of supported ops by the added client.
+ * @cb_table: A table for op->callback
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int ibnl_add_client(int index, int nops,
+		    const struct ibnl_client_cbs cb_table[]);
+
+/**
+ * Remove a client from IB netlink.
+ * @index: Index of the removed IB client.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int ibnl_remove_client(int index);
+
+/**
+ * Put a new message in a supplied skb.
+ * @skb: The netlink skb.
+ * @nlh: Pointer to put the header of the new netlink message.
+ * @seq: The message sequence number.
+ * @len: The requested message length to allocate.
+ * @client: Calling IB netlink client.
+ * @op: message content op.
+ * Returns the allocated buffer on success and NULL on failure.
+ */
+void *ibnl_put_msg(struct sk_buff *skb, struct nlmsghdr **nlh, int seq,
+		   int len, int client, int op);
+/**
+ * Put a new attribute in a supplied skb.
+ * @skb: The netlink skb.
+ * @nlh: Header of the netlink message to append the attribute to.
+ * @len: The length of the attribute data.
+ * @data: The attribute data to put.
+ * @type: The attribute type.
+ * Returns the 0 and a negative error code on failure.
+ */
+int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
+		  int len, void *data, int type);
+
+#endif /* __KERNEL__ */
+
+#endif /* _RDMA_NETLINK_H */
-- 
1.7.4.1

