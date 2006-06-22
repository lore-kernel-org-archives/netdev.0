From: paul.moore@hp.com
Subject: [RFC 7/8] NetLabel: unlabeled packet handling
Date: Thu, 22 Jun 2006 18:49:18 -0400
Message-ID: <20060622225410.977128000@flek.zko.hp.com>
References: <20060622224910.885573000@flek.zko.hp.com>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:13743 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1030440AbWFVWyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 18:54:32 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-unlabeled
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add unlabeled packet support to the NetLabel subsystem.  NetLabel does not do
any processing on unlabled packets, but it must support passing unlabled
packets on both the inbound and outbound sides.
---
 net/netlabel/netlabel_unlabeled.c |  287 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 287 insertions(+)

Index: linux-2.6.17.i686-quilt/net/netlabel/netlabel_unlabeled.c
===================================================================
--- /dev/null
+++ linux-2.6.17.i686-quilt/net/netlabel/netlabel_unlabeled.c
@@ -0,0 +1,287 @@
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
+/*
+ * Local Prototypes
+ */
+
+static void netlbl_unlabel_send_ack(const struct sk_buff *req_skb,
+				    const u32 ret_code);
+
+/*
+ * Helper Functions
+ */
+
+/**
+ * netlbl_unlabel_put_hdr - Write a Unlabeled NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel Unlabeled opcode
+ *
+ * Description:
+ * Use the given values to write a NetLabel Unlabeled header into the given
+ * buffer.
+ *
+ */
+static void netlbl_unlabel_put_hdr(unsigned char *buffer, const u32 opcode)
+{
+	((struct netlbl_unlabel_msghdr *)buffer)->opcode = opcode;
+}
+
+/**
+ * netlbl_unlabel_putinc_hdr - Write a Unlabeled NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel Unlabeled opcode
+ *
+ * Description:
+ * Use the given values to write a NetLabel Unlabeled header into the given
+ * buffer and increment the buffer pointer past the header.
+ *
+ */
+static void netlbl_unlabel_putinc_hdr(unsigned char **buffer, const u32 opcode)
+{
+	netlbl_unlabel_put_hdr(*buffer, opcode);
+	*buffer += sizeof(struct netlbl_unlabel_msghdr);
+}
+
+/**
+ * netlbl_unlabel_payload_len - Return the length of the payload
+ * @skb: the NETLINK buffer
+ *
+ * Description:
+ * This function returns the length of the NetLabel unlabeled payload.
+ *
+ */
+static u32 netlbl_unlabel_payload_len(const struct sk_buff *skb)
+{
+	const struct nlmsghdr *nl_hdr = (struct nlmsghdr *)skb->data;
+
+	if (nlmsg_len(nl_hdr) <= sizeof(struct netlbl_unlabel_msghdr))
+		return 0;
+	return nlmsg_len(nl_hdr) - sizeof(struct netlbl_unlabel_msghdr);
+}
+
+/**
+ * netlbl_unlabel_payload_data - Returns a pointer to the start of the data
+ * @skb: the NETLINK buffer
+ *
+ * Description:
+ * This function returns a pointer to the start of the NetLabel unlabeled
+ * payload.
+ *
+ */
+static unsigned char *netlbl_unlabel_payload_data(const struct sk_buff *skb)
+{
+	return nlmsg_data((struct nlmsghdr *)skb->data)
+		+ sizeof(struct netlbl_unlabel_msghdr);
+}
+
+/*
+ * Label Mapping Functions
+ */
+
+/**
+ * netlbl_unlabel_accept - Handle an ACCEPT message
+ * @req_skb: the NETLINK buffer
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated ACCEPT message and set the accept flag accordingly.
+ *
+ */
+static void netlbl_unlabel_accept(const struct sk_buff *req_skb,
+				 const unsigned char *msg)
+{
+	u32 value;
+
+	if (netlbl_unlabel_payload_len(req_skb) == 4) {
+		value = netlbl_get_u32(msg);
+		if (value == 1 || value == 0) {
+			atomic_set(&netlabel_unlabel_accept_flg, value);
+			netlbl_unlabel_send_ack(req_skb, NETLBL_E_OK);
+			return;
+		}
+	}
+
+	netlbl_unlabel_send_ack(req_skb, EINVAL);
+	return;
+}
+
+/*
+ * NetLabel Protocol Handlers
+ */
+
+/**
+ * netlbl_unlabel_send_ack - Send an ACK message
+ * @req_skb: the NETLINK buffer
+ * @ret_code: return code to use
+ *
+ * Description:
+ * This function sends an ACK message to the sender of the NETLINK message
+ * specified by @req_skb.
+ *
+ */
+static void netlbl_unlabel_send_ack(const struct sk_buff *req_skb,
+				    const u32 ret_code)
+{
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb;
+	struct nlmsghdr *nl_ack_hdr;
+	unsigned char *data;
+
+	data_size = sizeof(struct netlbl_unlabel_msghdr) + 8;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL)
+		return;
+
+	nl_ack_hdr = NLMSG_PUT(skb,
+			       NETLINK_CB(req_skb).pid,
+			       0,
+			       NETLBL_NLTYPE_UNLABELED,
+			       data_size);
+	nl_ack_hdr->nlmsg_len = msg_size;
+
+	data = NLMSG_DATA(nl_ack_hdr);
+	netlbl_unlabel_putinc_hdr(&data, NL_UNL_ACK);
+	netlbl_putinc_u32(&data,
+			  ((struct nlmsghdr *)req_skb->data)->nlmsg_seq);
+	netlbl_putinc_u32(&data, ret_code);
+
+	netlbl_netlink_snd(skb, NETLINK_CB(req_skb).pid);
+	return;
+
+nlmsg_failure:
+	kfree_skb(skb);
+}
+
+/**
+ * netlbl_unlabel_rcv - Process incoming NetLabel packets
+ * @skb: the NETLINK buffer
+ * @msg: pointer to the start of the NetLabel data
+ *
+ * Description:
+ * This function is reponsibile for reading all of the incoming Unlabeled
+ * NetLabel traffic and dispatching it to the correct Unlabeled functions.
+ *
+ */
+void netlbl_unlabel_rcv(const struct sk_buff *skb, const unsigned char *msg)
+{
+	int ret_val;
+
+	if (nlmsg_len((struct nlmsghdr *)skb->data) <
+	    sizeof(struct netlbl_unlabel_msghdr)) {
+		netlbl_unlabel_send_ack(skb, EINVAL);
+		return;
+	}
+
+	switch (((struct netlbl_unlabel_msghdr *)msg)->opcode) {
+	case NL_UNL_ACCEPT:
+		ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+		if (ret_val != 0)
+			netlbl_unlabel_send_ack(skb, ret_val);
+		netlbl_unlabel_accept(skb, netlbl_unlabel_payload_data(skb));
+		break;
+	default:
+		netlbl_unlabel_send_ack(skb, EINVAL);
+		return;
+	}
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
