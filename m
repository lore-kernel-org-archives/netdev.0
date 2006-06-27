From: paul.moore@hp.com
Subject: [RFC 7/8] NetLabel: unlabeled packet handling
Date: Tue, 27 Jun 2006 18:56:38 -0400
Message-ID: <20060627230053.088793000@flek.zko.hp.com>
References: <20060627225631.538814000@flek.zko.hp.com>
Cc: sgrubb@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:50086 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S932585AbWF0XAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 19:00:55 -0400
To: redhat-lspp@redhat.com, netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-unlabeled
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add unlabeled packet support to the NetLabel subsystem.  NetLabel does not do
any processing on unlabled packets, but it must support passing unlabled
packets on both the inbound and outbound sides.
---
 net/netlabel/netlabel_unlabeled.c |  258 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 258 insertions(+)

Index: linux-2.6.17.i686-quilt/net/netlabel/netlabel_unlabeled.c
===================================================================
--- /dev/null
+++ linux-2.6.17.i686-quilt/net/netlabel/netlabel_unlabeled.c
@@ -0,0 +1,258 @@
+/*
+ * NetLabel Unlabeled Support
+ *
+ * This file defines functions for dealing with unlabeled packets for the
+ * NetLabel system.  The NetLabel system manages static and dynamic label
+ * mappings for network protocols such as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+
+#include <net/netlabel.h>
+#include <asm/bug.h>
+
+#include "netlabel_user.h"
+#include "netlabel_domainhash.h"
+#include "netlabel_unlabeled.h"
+
+/* Accept unlabeled packets flag */
+static atomic_t netlabel_unlabel_accept_flg = ATOMIC_INIT(0);
+
+/* NetLabel Generic NETLINK CIPSOv4 family */
+static struct genl_family netlbl_unlabel_gnl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = 0,
+	.name = NETLBL_NLTYPE_UNLABELED_NAME,
+	.version = NETLBL_PROTO_VERSION,
+	.maxattr = 0,
+};
+
+
+/*
+ * Local Prototypes
+ */
+
+static void netlbl_unlabel_send_ack(const struct genl_info *info,
+				    const u32 ret_code);
+
+
+/*
+ * NetLabel Command Handlers
+ */
+
+/**
+ * netlbl_unlabel_accept - Handle an ACCEPT message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated ACCEPT message and set the accept flag accordingly.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_unlabel_accept(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val;
+	unsigned char *msg = netlbl_netlink_payload_data(skb);
+	u32 value;
+
+	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+	if (ret_val != 0)
+		return ret_val;
+
+	if (netlbl_netlink_payload_len(skb) == 4) {
+		value = netlbl_get_u32(msg);
+		if (value == 1 || value == 0) {
+			atomic_set(&netlabel_unlabel_accept_flg, value);
+			netlbl_unlabel_send_ack(info, NETLBL_E_OK);
+			return 0;
+		}
+	}
+
+	netlbl_unlabel_send_ack(info, EINVAL);
+	return -EINVAL;
+}
+
+
+/*
+ * NetLabel Generic NETLINK Command Definitions
+ */
+
+static struct genl_ops netlbl_unlabel_genl_c_accept = {
+	.cmd = NLBL_UNLABEL_C_ACCEPT,
+	.flags = 0,
+	.doit = netlbl_unlabel_accept,
+	.dumpit = NULL,
+};
+
+/*
+ * NetLabel Generic NETLINK Protocol Functions
+ */
+
+/**
+ * netlbl_unlabel_send_ack - Send an ACK message
+ * @info: the generic NETLINK information
+ * @ret_code: return code to use
+ *
+ * Description:
+ * This function sends an ACK message to the sender of the NETLINK message
+ * specified by @info.
+ *
+ */
+static void netlbl_unlabel_send_ack(const struct genl_info *info,
+				    const u32 ret_code)
+{
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb;
+	unsigned char *data;
+
+	data_size = GENL_HDRLEN + 8;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL)
+		return;
+
+	data = netlbl_netlink_hdr_put(skb,
+				      info->snd_pid,
+				      0,
+				      0,
+				      netlbl_unlabel_gnl_family.id,
+				      NLBL_UNLABEL_C_ACK,
+				      data_size);
+	if (data == NULL)
+		goto send_ack_failure;
+
+	netlbl_putinc_u32(&data, info->snd_seq);
+	netlbl_putinc_u32(&data, ret_code);
+
+	netlbl_netlink_snd(skb, info->snd_pid);
+	return;
+
+send_ack_failure:
+	kfree_skb(skb);
+}
+
+/**
+ * netlbl_unlabel_genl_init - Register the Unlabeled NetLabel component
+ *
+ * Description:
+ * Register the unlabeled packet NetLabel component with the Generic NETLINK
+ * mechanism.  Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_unlabel_genl_init(void)
+{
+	int ret_val;
+
+	ret_val = genl_register_family(&netlbl_unlabel_gnl_family);
+	if (ret_val != 0)
+		return ret_val;
+
+	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
+				    &netlbl_unlabel_genl_c_accept);
+	if (ret_val != 0)
+		return ret_val;
+
+	return 0;
+}
+
+/**
+ * netlbl_unlabel_genl_exit - Unregister the Unlabeled NetLabel component
+ *
+ * Description:
+ * Unregister the unlabeled packet NetLabel component with the Generic NETLINK
+ * mechanism.  Returns zero on success, negative values on failure.
+ *
+ */
+void netlbl_unlabel_genl_exit(void)
+{
+	genl_unregister_ops(&netlbl_unlabel_gnl_family,
+			    &netlbl_unlabel_genl_c_accept);
+
+	genl_unregister_family(&netlbl_unlabel_gnl_family);
+	netlbl_unlabel_gnl_family.id = GENL_ID_GENERATE;
+}
+
+/*
+ * NetLabel KAPI Hooks
+ */
+
+/**
+ * netlbl_unlabel_getattr - Get the security attributes for an unlabled packet
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Determine the security attributes, if any, for an unlabled packet and return
+ * them in @secattr.  Returns zero on success and negative values on failure.
+ *
+ */
+int netlbl_unlabel_getattr(struct netlbl_lsm_secattr *secattr)
+{
+	BUG_ON(secattr == NULL);
+
+	if (atomic_read(&netlabel_unlabel_accept_flg) == 1) {
+		memset(secattr, 0, sizeof(*secattr));
+		return 0;
+	}
+
+	return -ENOMSG;
+}
+
+/**
+ * netlbl_unlabel_defconf - Set the default config to allow unlabeled packets
+ *
+ * Description:
+ * Set the default NetLabel configuration to allow incoming unlabeled packets
+ * and to send unlabeled network traffic by default.
+ *
+ */
+int netlbl_unlabel_defconf(void)
+{
+	int ret_val;
+	struct netlbl_dom_map *entry;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (entry == NULL)
+		return -ENOMEM;
+	entry->type = NETLBL_NLTYPE_UNLABELED;
+	ret_val = netlbl_domhsh_add_default(entry);
+	if (ret_val != 0)
+		return ret_val;
+
+	atomic_set(&netlabel_unlabel_accept_flg, 1);
+
+	return 0;
+}

--
paul moore
linux security @ hp
