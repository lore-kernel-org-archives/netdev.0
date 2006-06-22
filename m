From: paul.moore@hp.com
Subject: [RFC 6/8] NetLabel: CIPSOv4 integration
Date: Thu, 22 Jun 2006 18:49:17 -0400
Message-ID: <20060622225410.521216000@flek.zko.hp.com>
References: <20060622224910.885573000@flek.zko.hp.com>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:6575 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161363AbWFVWya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 18:54:30 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-cipsov4
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add CIPSO/IPv4 support and management to the NetLabel subsystem.  These changes
integrate the CIPSO/IPv4 configuration into the existing NetLabel code and
enable the use of CIPSO/IPv4 within the overall NetLabel framework.
---
 net/netlabel/netlabel_cipso_v4.c |  583 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 583 insertions(+)

Index: linux-2.6.17.i686-quilt/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- /dev/null
+++ linux-2.6.17.i686-quilt/net/netlabel/netlabel_cipso_v4.c
@@ -0,0 +1,583 @@
+/*
+ * NetLabel CIPSO/IPv4 Support
+ *
+ * This file defines the CIPSO/IPv4 functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and RIPSO.
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
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+
+#include "netlabel_user.h"
+#include "netlabel_cipso_v4.h"
+
+/*
+ * Local Prototypes
+ */
+
+static void netlbl_cipsov4_send_ack(const struct sk_buff *req_skb,
+				    const u32 ret_code);
+
+/*
+ * Helper Functions
+ */
+
+/**
+ * netlbl_cipsov4_put_hdr - Write a CIPSO NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel CIPSOv4 opcode
+ * @doi: the CIPSO DOI value
+ *
+ * Description:
+ * Use the given values to write a NetLabel CIPSOv4 header into the given
+ * buffer.
+ *
+ */
+static void netlbl_cipsov4_put_hdr(unsigned char *buffer,
+				   const u32 opcode,
+				   const u32 doi)
+{
+	struct netlbl_cipsov4_msghdr *hdr =
+		(struct netlbl_cipsov4_msghdr *)buffer;
+	hdr->opcode = opcode;
+	hdr->doi = doi;
+}
+
+/**
+ * netlbl_cipsov4_putinc_hdr - Write a CIPSO NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel CIPSOv4 opcode
+ * @doi: the CIPSO DOI value
+ *
+ * Description:
+ * Use the given values to write a NetLabel CIPSOv4 header into the given
+ * buffer and increment the buffer pointer past the header.
+ *
+ */
+static void netlbl_cipsov4_putinc_hdr(unsigned char **buffer,
+				      const u32 opcode,
+				      const u32 doi)
+{
+	netlbl_cipsov4_put_hdr(*buffer, opcode, doi);
+	*buffer += sizeof(struct netlbl_cipsov4_msghdr);
+}
+
+/**
+ * netlbl_cipsov4_payload_len - Return the length of the payload
+ * @skb: the NETLINK buffer
+ *
+ * Description:
+ * This function returns the length of the CIPSO V4 NetLabel payload.
+ *
+ */
+static u32 netlbl_cipsov4_payload_len(const struct sk_buff *skb)
+{
+	const struct nlmsghdr *nl_hdr = (struct nlmsghdr *)skb->data;
+
+	if (nlmsg_len(nl_hdr) <= sizeof(struct netlbl_cipsov4_msghdr))
+		return 0;
+	return nlmsg_len(nl_hdr) - sizeof(struct netlbl_cipsov4_msghdr);
+}
+
+/**
+ * netlbl_cipsov4_payload_data - Returns a pointer to the start of the data
+ * @skb: the NETLINK buffer
+ *
+ * Description:
+ * This function returns a pointer to the start of the CIPSO V4 NetLabel
+ * payload.
+ *
+ */
+static unsigned char *netlbl_cipsov4_payload_data(const struct sk_buff *skb)
+{
+	return nlmsg_data((struct nlmsghdr *)skb->data) +
+		sizeof(struct netlbl_cipsov4_msghdr);
+}
+
+/**
+ * netlbl_cipsov4_doi_free - Frees a CIPSO V4 DOI definition
+ * @entry: the entry's RCU field
+ *
+ * Description:
+ * This function is designed to be used as a callback to the call_rcu()
+ * function so that the memory allocated to the DOI definition can be released
+ * safely.
+ *
+ */
+static void netlbl_cipsov4_doi_free(struct rcu_head *entry)
+{
+	struct cipso_v4_doi *ptr;
+
+	ptr = container_of(entry, struct cipso_v4_doi, rcu);
+	switch (ptr->type) {
+	case CIPSO_V4_MAP_STD:
+		if (ptr->map.std->lvl.cipso_size > 0)
+			kfree(ptr->map.std->lvl.cipso);
+		if (ptr->map.std->lvl.local_size > 0)
+			kfree(ptr->map.std->lvl.local);
+		if (ptr->map.std->cat.cipso_size > 0)
+			kfree(ptr->map.std->cat.cipso);
+		if (ptr->map.std->cat.local_size > 0)
+			kfree(ptr->map.std->cat.local);
+		break;
+	}
+	kfree(ptr);
+}
+
+/*
+ * Label Mapping Functions
+ */
+
+/**
+ * netlbl_cipsov4_add_std - Adds a CIPSO V4 DOI definition
+ * @doi: the DOI value
+ * @msg: the ADD message data
+ * @msg_size: the size of the ADD message buffer
+ *
+ * Description:
+ * Create a new CIPSO_V4_MAP_STD DOI definition based on the given ADD message
+ * and add it to the CIPSO V4 engine.  Return zero on success and non-zero on
+ * error.
+ *
+ */
+static int netlbl_cipsov4_add_std(const u32 doi,
+				  const unsigned char *msg,
+				  const u32 msg_size)
+{
+	int ret_val = -EPERM;
+	unsigned char *msg_ptr = (unsigned char *)msg;
+	u32 msg_len = msg_size;
+	u32 num_tags;
+	u32 num_lvls;
+	u32 num_cats;
+	struct cipso_v4_doi *doi_def = NULL;
+	u32 iter;
+	u32 tmp_val_a;
+	u32 tmp_val_b;
+
+	if (msg_len < 4)
+		goto add_std_failure;
+	num_tags = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (num_tags == 0 || num_tags > CIPSO_V4_TAG_MAXCNT)
+		goto add_std_failure;
+
+	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
+	if (doi_def == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->map.std = kzalloc(sizeof(*doi_def->map.std),
+				   GFP_KERNEL);
+	if (doi_def->map.std == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->type = CIPSO_V4_MAP_STD;
+
+	if (msg_len < num_tags)
+		goto add_std_failure;
+	msg_len -= num_tags;
+	for (iter = 0; iter < num_tags; iter++) {
+		doi_def->tags[iter] = netlbl_getinc_u8(&msg_ptr);
+		switch (doi_def->tags[iter]) {
+		case CIPSO_V4_TAG_RBITMAP:
+			break;
+		default:
+			goto add_std_failure;
+		}
+	}
+	if (iter < CIPSO_V4_TAG_MAXCNT)
+		doi_def->tags[iter] = CIPSO_V4_TAG_INVALID;
+
+	if (msg_len < 24)
+		goto add_std_failure;
+
+	num_lvls = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (num_lvls == 0)
+		goto add_std_failure;
+	doi_def->map.std->lvl.local_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->lvl.local_size > CIPSO_V4_MAX_LOC_LVLS)
+		goto add_std_failure;
+	doi_def->map.std->lvl.local = kcalloc(doi_def->map.std->lvl.local_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->lvl.local == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->map.std->lvl.cipso_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->lvl.cipso_size > CIPSO_V4_MAX_REM_LVLS)
+		goto add_std_failure;
+	doi_def->map.std->lvl.cipso = kcalloc(doi_def->map.std->lvl.cipso_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->lvl.cipso == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+
+	num_cats = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	doi_def->map.std->cat.local_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->cat.local_size > CIPSO_V4_MAX_LOC_CATS)
+		goto add_std_failure;
+	doi_def->map.std->cat.local = kcalloc(doi_def->map.std->cat.local_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->cat.local == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+	doi_def->map.std->cat.cipso_size = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (doi_def->map.std->cat.cipso_size > CIPSO_V4_MAX_REM_CATS)
+		goto add_std_failure;
+	doi_def->map.std->cat.cipso = kcalloc(doi_def->map.std->cat.cipso_size,
+					      sizeof(u32), GFP_KERNEL);
+	if (doi_def->map.std->cat.cipso == NULL) {
+		ret_val = -ENOMEM;
+		goto add_std_failure;
+	}
+
+	if (msg_len < num_lvls * 8 + num_cats * 8)
+		goto add_std_failure;
+	msg_len -= num_lvls * 8 + num_cats * 8;
+
+	for (iter = 0; iter < doi_def->map.std->lvl.cipso_size; iter++)
+		doi_def->map.std->lvl.cipso[iter] = CIPSO_V4_INV_LVL;
+	for (iter = 0; iter < doi_def->map.std->lvl.local_size; iter++)
+		doi_def->map.std->lvl.local[iter] = CIPSO_V4_INV_LVL;
+	for (iter = 0; iter < doi_def->map.std->cat.cipso_size; iter++)
+		doi_def->map.std->cat.cipso[iter] = CIPSO_V4_INV_CAT;
+	for (iter = 0; iter < doi_def->map.std->cat.local_size; iter++)
+		doi_def->map.std->cat.local[iter] = CIPSO_V4_INV_CAT;
+
+	for (iter = 0; iter < num_lvls; iter++) {
+		tmp_val_a = netlbl_getinc_u32(&msg_ptr);
+		tmp_val_b = netlbl_getinc_u32(&msg_ptr);
+
+		if (tmp_val_a >= doi_def->map.std->lvl.local_size ||
+		    tmp_val_b >= doi_def->map.std->lvl.cipso_size)
+			goto add_std_failure;
+
+		doi_def->map.std->lvl.cipso[tmp_val_b] = tmp_val_a;
+		doi_def->map.std->lvl.local[tmp_val_a] = tmp_val_b;
+	}
+
+	for (iter = 0; iter < num_cats; iter++) {
+		tmp_val_a = netlbl_getinc_u32(&msg_ptr);
+		tmp_val_b = netlbl_getinc_u32(&msg_ptr);
+
+		if (tmp_val_a >= doi_def->map.std->cat.local_size ||
+		    tmp_val_b >= doi_def->map.std->cat.cipso_size)
+			goto add_std_failure;
+
+		doi_def->map.std->cat.cipso[tmp_val_b] = tmp_val_a;
+		doi_def->map.std->cat.local[tmp_val_a] = tmp_val_b;
+	}
+
+	doi_def->doi = doi;
+	ret_val = cipso_v4_doi_add(doi_def);
+	if (ret_val != 0)
+		goto add_std_failure;
+	return 0;
+
+add_std_failure:
+	if (doi_def)
+		netlbl_cipsov4_doi_free(&doi_def->rcu);
+	return ret_val;
+}
+
+/**
+ * netlbl_cipsov4_add_pass - Adds a CIPSO V4 DOI definition
+ * @doi: the DOI value
+ * @msg: the ADD message data
+ * @msg_size: the size of the ADD message buffer
+ *
+ * Description:
+ * Create a new CIPSO_V4_MAP_PASS DOI definition based on the given ADD message
+ * and add it to the CIPSO V4 engine.  Return zero on success and non-zero on
+ * error.
+ *
+ */
+static int netlbl_cipsov4_add_pass(const u32 doi,
+				   const unsigned char *msg,
+				   const u32 msg_size)
+{
+	int ret_val = -EPERM;
+	unsigned char *msg_ptr = (unsigned char *)msg;
+	u32 msg_len = msg_size;
+	u32 num_tags;
+	struct cipso_v4_doi *doi_def = NULL;
+	u32 iter;
+
+	if (msg_len < 4)
+		goto add_pass_failure;
+	num_tags = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+	if (num_tags == 0 || num_tags > CIPSO_V4_TAG_MAXCNT)
+		goto add_pass_failure;
+
+	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
+	if (doi_def == NULL) {
+		ret_val = -ENOMEM;
+		goto add_pass_failure;
+	}
+	doi_def->type = CIPSO_V4_MAP_PASS;
+
+	if (msg_len < num_tags)
+		goto add_pass_failure;
+	msg_len -= num_tags;
+	for (iter = 0; iter < num_tags; iter++) {
+		doi_def->tags[iter] = netlbl_getinc_u8(&msg_ptr);
+		switch (doi_def->tags[iter]) {
+		case CIPSO_V4_TAG_RBITMAP:
+			break;
+		default:
+			goto add_pass_failure;
+		}
+	}
+	if (iter < CIPSO_V4_TAG_MAXCNT)
+		doi_def->tags[iter] = CIPSO_V4_TAG_INVALID;
+
+	doi_def->doi = doi;
+	ret_val = cipso_v4_doi_add(doi_def);
+	if (ret_val != 0)
+		goto add_pass_failure;
+	return 0;
+
+add_pass_failure:
+	if (doi_def)
+		netlbl_cipsov4_doi_free(&doi_def->rcu);
+	return ret_val;
+}
+
+/**
+ * netlbl_cipsov4_add - Handle an ADD message
+ * @req_skb: the NETLINK buffer
+ * @doi: the DOI
+ * @msg: the NetLabel CIPSO V4 message
+ *
+ * Description:
+ * Create a new DOI definition based on the given ADD message and add it to the
+ * CIPSO V4 engine.
+ *
+ */
+static void netlbl_cipsov4_add(const struct sk_buff *req_skb,
+			       const u32 doi,
+			       const unsigned char *msg)
+{
+	int ret_val = -EINVAL;
+	u32 map_type;
+	u32 msg_len = netlbl_cipsov4_payload_len(req_skb);
+
+	if (msg_len < 4) {
+		netlbl_cipsov4_send_ack(req_skb, EINVAL);
+		return;
+	}
+
+	map_type = netlbl_get_u32(msg);
+	switch (map_type) {
+	case CIPSO_V4_MAP_STD:
+		ret_val = netlbl_cipsov4_add_std(doi, msg + 4, msg_len - 4);
+		break;
+	case CIPSO_V4_MAP_PASS:
+		ret_val = netlbl_cipsov4_add_pass(doi, msg + 4, msg_len - 4);
+		break;
+	}
+	netlbl_cipsov4_send_ack(req_skb, -ret_val);
+}
+
+/**
+ * netlbl_cipsov4_list - Handle a LIST message
+ * @req_skb: the NETLINK buffer
+ * @doi: the DOI
+ * @msg: the NetLabel CIPSO V4 message
+ *
+ * Description:
+ * Process a user generated LIST message and respond accordingly.
+ *
+ */
+static void netlbl_cipsov4_list(const struct sk_buff *req_skb,
+				const u32 doi,
+				const unsigned char *msg)
+{
+	int ret_val = -ENOMEM;
+	struct sk_buff *skb;
+	unsigned char *buf_ptr;
+
+	skb = cipso_v4_doi_dump(doi, sizeof(struct netlbl_cipsov4_msghdr));
+	if (skb == NULL)
+		goto list_return;
+	buf_ptr = skb_push(skb,
+			   NLMSG_SPACE(sizeof(struct netlbl_cipsov4_msghdr)));
+	if (buf_ptr == NULL) {
+		kfree(skb);
+		ret_val = -EAGAIN;
+		goto list_return;
+	}
+	netlbl_putinc_hdr(&buf_ptr,
+			  NETLBL_NLTYPE_CIPSOV4,
+			  skb->len,
+			  0,
+			  NETLINK_CB(req_skb).pid,
+			  0);
+	netlbl_cipsov4_putinc_hdr(&buf_ptr, NL_CV4_LIST, 0);
+
+	ret_val = netlbl_netlink_snd(skb, NETLINK_CB(req_skb).pid);
+
+list_return:
+	if (ret_val != 0)
+		netlbl_cipsov4_send_ack(skb, -ret_val);
+}
+
+/**
+ * netlbl_cipsov4_remove - Handle a REMOVE message
+ * @req_skb: the NETLINK buffer
+ * @doi: the DOI
+ * @msg: the NetLabel CIPSO V4 message
+ *
+ * Description:
+ * Process a user generated REMOVE message and respond accordingly.
+ *
+ */
+static void netlbl_cipsov4_remove(const struct sk_buff *req_skb,
+				 const u32 doi,
+				 const unsigned char *msg)
+{
+	int ret_val;
+
+	ret_val = cipso_v4_doi_remove(doi, netlbl_cipsov4_doi_free);
+	netlbl_cipsov4_send_ack(req_skb, -ret_val);
+}
+
+/*
+ * NetLabel Protocol Handlers
+ */
+
+/**
+ * netlbl_cipsov4_send_ack - Send an ACK message
+ * @req_skb: the NETLINK buffer
+ * @ret_code: return code to use
+ *
+ * Description:
+ * This function sends an ACK message to the sender of the NETLINK message
+ * specified by @req_skb.
+ *
+ */
+static void netlbl_cipsov4_send_ack(const struct sk_buff *req_skb,
+				    const u32 ret_code)
+{
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb;
+	struct nlmsghdr *nl_ack_hdr;
+	unsigned char *data;
+
+	data_size = sizeof(struct netlbl_cipsov4_msghdr) + 8;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL)
+		return;
+
+	nl_ack_hdr = NLMSG_PUT(skb,
+			       NETLINK_CB(req_skb).pid,
+			       0,
+			       NETLBL_NLTYPE_CIPSOV4,
+			       data_size);
+	nl_ack_hdr->nlmsg_len = msg_size;
+
+	data = NLMSG_DATA(nl_ack_hdr);
+	netlbl_cipsov4_putinc_hdr(&data, NL_CV4_ACK, 0);
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
+ * netlbl_cipsov4_rcv - Process incoming NetLabel packets
+ * @skb: the NETLINK buffer
+ * @msg: pointer to the start of the NetLabel data
+ *
+ * Description:
+ * This function is reponsibile for reading all of the incoming CIPSO V4
+ * NetLabel traffic and dispatching it to the correct CIPSO V4 functions.
+ *
+ */
+void netlbl_cipsov4_rcv(const struct sk_buff *skb, const unsigned char *msg)
+{
+	int ret_val;
+	struct netlbl_cipsov4_msghdr *nl_cv4_hdr;
+
+	if (nlmsg_len((struct nlmsghdr *)skb->data) <
+	    sizeof(struct netlbl_cipsov4_msghdr)) {
+		netlbl_cipsov4_send_ack(skb, EINVAL);
+		return;
+	}
+
+	nl_cv4_hdr = (struct netlbl_cipsov4_msghdr *)msg;
+	switch (nl_cv4_hdr->opcode) {
+	case NL_CV4_ADD:
+		ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+		if (ret_val != 0)
+			netlbl_cipsov4_send_ack(skb, ret_val);
+		netlbl_cipsov4_add(skb,
+				   nl_cv4_hdr->doi,
+				   netlbl_cipsov4_payload_data(skb));
+		break;
+	case NL_CV4_REMOVE:
+		ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+		if (ret_val != 0)
+			netlbl_cipsov4_send_ack(skb, ret_val);
+		netlbl_cipsov4_remove(skb,
+				      nl_cv4_hdr->doi,
+				      netlbl_cipsov4_payload_data(skb));
+		break;
+	case NL_CV4_LIST:
+		netlbl_cipsov4_list(skb,
+				    nl_cv4_hdr->doi,
+				    netlbl_cipsov4_payload_data(skb));
+		break;
+	default:
+		netlbl_cipsov4_send_ack(skb, EINVAL);
+		return;
+	}
+}

--
paul moore
linux security @ hp
