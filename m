From: frank.blaschka@de.ibm.com
Subject: [patch 1/4] [PATCH] qeth: support ipv6 query arp cache for HiperSockets
Date: Wed, 08 Dec 2010 13:57:58 +0100
Message-ID: <20101208125844.331379112@de.ibm.com>
References: <20101208125757.726629855@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Einar Lueck <elelueck@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:41127 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab0LHM6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 07:58:49 -0500
Content-Disposition: inline; filename=601-qeth-ipv6-query-arp.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@de.ibm.com>

Function qeth_l3_arp_query now queries for IPv6 addresses, too, if
QETH_QARP_WITH_IPV6 is passed as parameter to the ioctl. HiperSockets
and GuestLAN in HiperSockets mode provide corresponding entries.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 arch/s390/include/asm/qeth.h     |   51 +++++++--
 drivers/s390/net/qeth_core_mpc.h |    2 
 drivers/s390/net/qeth_l3_main.c  |  219 +++++++++++++++++++++++++--------------
 3 files changed, 187 insertions(+), 85 deletions(-)

--- a/arch/s390/include/asm/qeth.h
+++ b/arch/s390/include/asm/qeth.h
@@ -28,39 +28,70 @@ struct qeth_arp_cache_entry {
 	__u8  reserved2[32];
 } __attribute__ ((packed));
 
+enum qeth_arp_ipaddrtype {
+	QETHARP_IP_ADDR_V4 = 1,
+	QETHARP_IP_ADDR_V6 = 2,
+};
+struct qeth_arp_entrytype {
+	__u8 mac;
+	__u8 ip;
+} __attribute__((packed));
+
+#define QETH_QARP_MEDIASPECIFIC_BYTES 32
+#define QETH_QARP_MACADDRTYPE_BYTES 1
 struct qeth_arp_qi_entry7 {
-	__u8 media_specific[32];
-	__u8 macaddr_type;
-	__u8 ipaddr_type;
+	__u8 media_specific[QETH_QARP_MEDIASPECIFIC_BYTES];
+	struct qeth_arp_entrytype type;
 	__u8 macaddr[6];
 	__u8 ipaddr[4];
 } __attribute__((packed));
 
+struct qeth_arp_qi_entry7_ipv6 {
+	__u8 media_specific[QETH_QARP_MEDIASPECIFIC_BYTES];
+	struct qeth_arp_entrytype type;
+	__u8 macaddr[6];
+	__u8 ipaddr[16];
+} __attribute__((packed));
+
 struct qeth_arp_qi_entry7_short {
-	__u8 macaddr_type;
-	__u8 ipaddr_type;
+	struct qeth_arp_entrytype type;
 	__u8 macaddr[6];
 	__u8 ipaddr[4];
 } __attribute__((packed));
 
+struct qeth_arp_qi_entry7_short_ipv6 {
+	struct qeth_arp_entrytype type;
+	__u8 macaddr[6];
+	__u8 ipaddr[16];
+} __attribute__((packed));
+
 struct qeth_arp_qi_entry5 {
-	__u8 media_specific[32];
-	__u8 macaddr_type;
-	__u8 ipaddr_type;
+	__u8 media_specific[QETH_QARP_MEDIASPECIFIC_BYTES];
+	struct qeth_arp_entrytype type;
 	__u8 ipaddr[4];
 } __attribute__((packed));
 
+struct qeth_arp_qi_entry5_ipv6 {
+	__u8 media_specific[QETH_QARP_MEDIASPECIFIC_BYTES];
+	struct qeth_arp_entrytype type;
+	__u8 ipaddr[16];
+} __attribute__((packed));
+
 struct qeth_arp_qi_entry5_short {
-	__u8 macaddr_type;
-	__u8 ipaddr_type;
+	struct qeth_arp_entrytype type;
 	__u8 ipaddr[4];
 } __attribute__((packed));
 
+struct qeth_arp_qi_entry5_short_ipv6 {
+	struct qeth_arp_entrytype type;
+	__u8 ipaddr[16];
+} __attribute__((packed));
 /*
  * can be set by user if no "media specific information" is wanted
  * -> saves a lot of space in user space buffer
  */
 #define QETH_QARP_STRIP_ENTRIES  0x8000
+#define QETH_QARP_WITH_IPV6	 0x4000
 #define QETH_QARP_REQUEST_MASK   0x00ff
 
 /* data sent to user space as result of query arp ioctl */
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -333,7 +333,7 @@ struct qeth_arp_query_data {
 	__u16 request_bits;
 	__u16 reply_bits;
 	__u32 no_entries;
-	char data;
+	char data; /* only for replies */
 } __attribute__((packed));
 
 /* used as parameter for arp_query reply */
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -30,6 +30,7 @@
 
 #include "qeth_l3.h"
 
+
 static int qeth_l3_set_offline(struct ccwgroup_device *);
 static int qeth_l3_recover(void *);
 static int qeth_l3_stop(struct net_device *);
@@ -2455,22 +2456,46 @@ static int qeth_l3_arp_set_no_entries(st
 	return rc;
 }
 
-static void qeth_l3_copy_arp_entries_stripped(struct qeth_arp_query_info *qinfo,
-		struct qeth_arp_query_data *qdata, int entry_size,
-		int uentry_size)
-{
-	char *entry_ptr;
-	char *uentry_ptr;
-	int i;
-
-	entry_ptr = (char *)&qdata->data;
-	uentry_ptr = (char *)(qinfo->udata + qinfo->udata_offset);
-	for (i = 0; i < qdata->no_entries; ++i) {
-		/* strip off 32 bytes "media specific information" */
-		memcpy(uentry_ptr, (entry_ptr + 32), entry_size - 32);
-		entry_ptr += entry_size;
-		uentry_ptr += uentry_size;
+static __u32 get_arp_entry_size(struct qeth_card *card,
+			struct qeth_arp_query_data *qdata,
+			struct qeth_arp_entrytype *type, __u8 strip_entries)
+{
+	__u32 rc;
+	__u8 is_hsi;
+
+	is_hsi = qdata->reply_bits == 5;
+	if (type->ip == QETHARP_IP_ADDR_V4) {
+		QETH_CARD_TEXT(card, 4, "arpev4");
+		if (strip_entries) {
+			rc = is_hsi ? sizeof(struct qeth_arp_qi_entry5_short) :
+				sizeof(struct qeth_arp_qi_entry7_short);
+		} else {
+			rc = is_hsi ? sizeof(struct qeth_arp_qi_entry5) :
+				sizeof(struct qeth_arp_qi_entry7);
+		}
+	} else if (type->ip == QETHARP_IP_ADDR_V6) {
+		QETH_CARD_TEXT(card, 4, "arpev6");
+		if (strip_entries) {
+			rc = is_hsi ?
+				sizeof(struct qeth_arp_qi_entry5_short_ipv6) :
+				sizeof(struct qeth_arp_qi_entry7_short_ipv6);
+		} else {
+			rc = is_hsi ?
+				sizeof(struct qeth_arp_qi_entry5_ipv6) :
+				sizeof(struct qeth_arp_qi_entry7_ipv6);
+		}
+	} else {
+		QETH_CARD_TEXT(card, 4, "arpinv");
+		rc = 0;
 	}
+
+	return rc;
+}
+
+static int arpentry_matches_prot(struct qeth_arp_entrytype *type, __u16 prot)
+{
+	return (type->ip == QETHARP_IP_ADDR_V4 && prot == QETH_PROT_IPV4) ||
+		(type->ip == QETHARP_IP_ADDR_V6 && prot == QETH_PROT_IPV6);
 }
 
 static int qeth_l3_arp_query_cb(struct qeth_card *card,
@@ -2479,72 +2504,77 @@ static int qeth_l3_arp_query_cb(struct q
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_arp_query_data *qdata;
 	struct qeth_arp_query_info *qinfo;
-	int entry_size;
-	int uentry_size;
 	int i;
+	int e;
+	int entrybytes_done;
+	int stripped_bytes;
+	__u8 do_strip_entries;
 
-	QETH_CARD_TEXT(card, 4, "arpquecb");
+	QETH_CARD_TEXT(card, 3, "arpquecb");
 
 	qinfo = (struct qeth_arp_query_info *) reply->param;
 	cmd = (struct qeth_ipa_cmd *) data;
+	QETH_CARD_TEXT_(card, 4, "%i", cmd->hdr.prot_version);
 	if (cmd->hdr.return_code) {
-		QETH_CARD_TEXT_(card, 4, "qaer1%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT(card, 4, "arpcberr");
+		QETH_CARD_TEXT_(card, 4, "%i", cmd->hdr.return_code);
 		return 0;
 	}
 	if (cmd->data.setassparms.hdr.return_code) {
 		cmd->hdr.return_code = cmd->data.setassparms.hdr.return_code;
-		QETH_CARD_TEXT_(card, 4, "qaer2%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT(card, 4, "setaperr");
+		QETH_CARD_TEXT_(card, 4, "%i", cmd->hdr.return_code);
 		return 0;
 	}
 	qdata = &cmd->data.setassparms.data.query_arp;
-	switch (qdata->reply_bits) {
-	case 5:
-		uentry_size = entry_size = sizeof(struct qeth_arp_qi_entry5);
-		if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES)
-			uentry_size = sizeof(struct qeth_arp_qi_entry5_short);
-		break;
-	case 7:
-		/* fall through to default */
-	default:
-		/* tr is the same as eth -> entry7 */
-		uentry_size = entry_size = sizeof(struct qeth_arp_qi_entry7);
-		if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES)
-			uentry_size = sizeof(struct qeth_arp_qi_entry7_short);
-		break;
-	}
-	/* check if there is enough room in userspace */
-	if ((qinfo->udata_len - qinfo->udata_offset) <
-			qdata->no_entries * uentry_size){
-		QETH_CARD_TEXT_(card, 4, "qaer3%i", -ENOMEM);
-		cmd->hdr.return_code = -ENOMEM;
-		goto out_error;
-	}
-	QETH_CARD_TEXT_(card, 4, "anore%i",
-		       cmd->data.setassparms.hdr.number_of_replies);
-	QETH_CARD_TEXT_(card, 4, "aseqn%i", cmd->data.setassparms.hdr.seq_no);
 	QETH_CARD_TEXT_(card, 4, "anoen%i", qdata->no_entries);
 
-	if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES) {
-		/* strip off "media specific information" */
-		qeth_l3_copy_arp_entries_stripped(qinfo, qdata, entry_size,
-					       uentry_size);
-	} else
-		/*copy entries to user buffer*/
-		memcpy(qinfo->udata + qinfo->udata_offset,
-		       (char *)&qdata->data, qdata->no_entries*uentry_size);
+	do_strip_entries = (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES) > 0;
+	stripped_bytes = do_strip_entries ? QETH_QARP_MEDIASPECIFIC_BYTES : 0;
+	entrybytes_done = 0;
+	for (e = 0; e < qdata->no_entries; ++e) {
+		char *cur_entry;
+		__u32 esize;
+		struct qeth_arp_entrytype *etype;
+
+		cur_entry = &qdata->data + entrybytes_done;
+		etype = &((struct qeth_arp_qi_entry5 *) cur_entry)->type;
+		if (!arpentry_matches_prot(etype, cmd->hdr.prot_version)) {
+			QETH_CARD_TEXT(card, 4, "pmis");
+			QETH_CARD_TEXT_(card, 4, "%i", etype->ip);
+			break;
+		}
+		esize = get_arp_entry_size(card, qdata, etype,
+			do_strip_entries);
+		QETH_CARD_TEXT_(card, 5, "esz%i", esize);
+		if (!esize)
+			break;
+
+		if ((qinfo->udata_len - qinfo->udata_offset) < esize) {
+			QETH_CARD_TEXT_(card, 4, "qaer3%i", -ENOMEM);
+			cmd->hdr.return_code = -ENOMEM;
+			goto out_error;
+		}
 
-	qinfo->no_entries += qdata->no_entries;
-	qinfo->udata_offset += (qdata->no_entries*uentry_size);
+		memcpy(qinfo->udata + qinfo->udata_offset,
+			&qdata->data + entrybytes_done + stripped_bytes,
+			esize);
+		entrybytes_done += esize + stripped_bytes;
+		qinfo->udata_offset += esize;
+		++qinfo->no_entries;
+	}
 	/* check if all replies received ... */
 	if (cmd->data.setassparms.hdr.seq_no <
 	    cmd->data.setassparms.hdr.number_of_replies)
 		return 1;
+	QETH_CARD_TEXT_(card, 4, "nove%i", qinfo->no_entries);
 	memcpy(qinfo->udata, &qinfo->no_entries, 4);
 	/* keep STRIP_ENTRIES flag so the user program can distinguish
 	 * stripped entries from normal ones */
 	if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES)
 		qdata->reply_bits |= QETH_QARP_STRIP_ENTRIES;
 	memcpy(qinfo->udata + QETH_QARP_MASK_OFFSET, &qdata->reply_bits, 2);
+	QETH_CARD_TEXT_(card, 4, "rc%i", 0);
 	return 0;
 out_error:
 	i = 0;
@@ -2567,45 +2597,86 @@ static int qeth_l3_send_ipa_arp_cmd(stru
 				      reply_cb, reply_param);
 }
 
-static int qeth_l3_arp_query(struct qeth_card *card, char __user *udata)
+static int qeth_l3_query_arp_cache_info(struct qeth_card *card,
+	enum qeth_prot_versions prot,
+	struct qeth_arp_query_info *qinfo)
 {
 	struct qeth_cmd_buffer *iob;
-	struct qeth_arp_query_info qinfo = {0, };
+	struct qeth_ipa_cmd *cmd;
 	int tmp;
 	int rc;
 
+	QETH_CARD_TEXT_(card, 3, "qarpipv%i", prot);
+
+	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
+			IPA_CMD_ASS_ARP_QUERY_INFO,
+			sizeof(struct qeth_arp_query_data) - sizeof(char),
+			prot);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setassparms.data.query_arp.request_bits = 0x000F;
+	cmd->data.setassparms.data.query_arp.reply_bits = 0;
+	cmd->data.setassparms.data.query_arp.no_entries = 0;
+	rc = qeth_l3_send_ipa_arp_cmd(card, iob,
+			   QETH_SETASS_BASE_LEN+QETH_ARP_CMD_LEN,
+			   qeth_l3_arp_query_cb, (void *)qinfo);
+	if (rc) {
+		tmp = rc;
+		QETH_DBF_MESSAGE(2,
+			"Error while querying ARP cache on %s: %s "
+			"(0x%x/%d)\n", QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+	}
+
+	return rc;
+}
+
+static int qeth_l3_arp_query(struct qeth_card *card, char __user *udata)
+{
+	struct qeth_arp_query_info qinfo = {0, };
+	int rc;
+
 	QETH_CARD_TEXT(card, 3, "arpquery");
 
 	if (!qeth_is_supported(card,/*IPA_QUERY_ARP_ADDR_INFO*/
 			       IPA_ARP_PROCESSING)) {
-		return -EOPNOTSUPP;
+		QETH_CARD_TEXT(card, 3, "arpqnsup");
+		rc = -EOPNOTSUPP;
+		goto out;
 	}
 	/* get size of userspace buffer and mask_bits -> 6 bytes */
-	if (copy_from_user(&qinfo, udata, 6))
-		return -EFAULT;
+	if (copy_from_user(&qinfo, udata, 6)) {
+		rc = -EFAULT;
+		goto out;
+	}
 	qinfo.udata = kzalloc(qinfo.udata_len, GFP_KERNEL);
-	if (!qinfo.udata)
-		return -ENOMEM;
+	if (!qinfo.udata) {
+		rc = -ENOMEM;
+		goto out;
+	}
 	qinfo.udata_offset = QETH_QARP_ENTRIES_OFFSET;
-	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
-				       IPA_CMD_ASS_ARP_QUERY_INFO,
-				       sizeof(int), QETH_PROT_IPV4);
-
-	rc = qeth_l3_send_ipa_arp_cmd(card, iob,
-				   QETH_SETASS_BASE_LEN+QETH_ARP_CMD_LEN,
-				   qeth_l3_arp_query_cb, (void *)&qinfo);
+	rc = qeth_l3_query_arp_cache_info(card, QETH_PROT_IPV4, &qinfo);
 	if (rc) {
-		tmp = rc;
-		QETH_DBF_MESSAGE(2, "Error while querying ARP cache on %s: %s "
-			"(0x%x/%d)\n", QETH_CARD_IFNAME(card),
-			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 		if (copy_to_user(udata, qinfo.udata, 4))
 			rc = -EFAULT;
+			goto free_and_out;
 	} else {
-		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
+#ifdef CONFIG_QETH_IPV6
+		if (qinfo.mask_bits & QETH_QARP_WITH_IPV6) {
+			/* fails in case of GuestLAN QDIO mode */
+			qeth_l3_query_arp_cache_info(card, QETH_PROT_IPV6,
+				&qinfo);
+		}
+#endif
+		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len)) {
+			QETH_CARD_TEXT(card, 4, "qactf");
 			rc = -EFAULT;
+			goto free_and_out;
+		}
+		QETH_CARD_TEXT_(card, 4, "qacts");
 	}
+free_and_out:
 	kfree(qinfo.udata);
+out:
 	return rc;
 }
 

