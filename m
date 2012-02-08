From: frank.blaschka@de.ibm.com
Subject: [patch 5/6] [PATCH] qeth: add query OSA address table support
Date: Wed, 08 Feb 2012 11:19:49 +0100
Message-ID: <20120208102029.571724964@de.ibm.com>
References: <20120208101944.272235343@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:57816 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126Ab2BHKVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 05:21:14 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 8 Feb 2012 10:21:08 -0000
Content-Disposition: inline; filename=606-qeth-query-osa-table.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Add qeth device private ioctl to query the OSA address table.
This helps debugging hw related problems.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 arch/s390/include/asm/qeth.h      |    7 ++
 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |   99 ++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_core_mpc.h  |   13 ++++
 drivers/s390/net/qeth_l2_main.c   |    3 +
 drivers/s390/net/qeth_l3_main.c   |    3 +
 6 files changed, 126 insertions(+)

--- a/arch/s390/include/asm/qeth.h
+++ b/arch/s390/include/asm/qeth.h
@@ -20,6 +20,7 @@
 #define SIOC_QETH_ARP_FLUSH_CACHE       (SIOCDEVPRIVATE + 4)
 #define SIOC_QETH_ADP_SET_SNMP_CONTROL  (SIOCDEVPRIVATE + 5)
 #define SIOC_QETH_GET_CARD_TYPE         (SIOCDEVPRIVATE + 6)
+#define SIOC_QETH_QUERY_OAT		(SIOCDEVPRIVATE + 7)
 
 struct qeth_arp_cache_entry {
 	__u8  macaddr[6];
@@ -107,4 +108,10 @@ struct qeth_arp_query_user_data {
 	char *entries;
 } __attribute__((packed));
 
+struct qeth_query_oat_data {
+	__u32 command;
+	__u32 buffer_len;
+	__u32 response_len;
+	__u64 ptr;
+};
 #endif /* __ASM_S390_QETH_IOCTL_H__ */
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -906,6 +906,7 @@ void qeth_prepare_ipa_cmd(struct qeth_ca
 struct qeth_cmd_buffer *qeth_wait_for_buffer(struct qeth_channel *);
 int qeth_mdio_read(struct net_device *, int, int);
 int qeth_snmp_command(struct qeth_card *, char __user *);
+int qeth_query_oat_command(struct qeth_card *, char __user *);
 struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *, __u32, __u32);
 int qeth_default_setadapterparms_cb(struct qeth_card *, struct qeth_reply *,
 					unsigned long);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -26,6 +26,7 @@
 #include <asm/ebcdic.h>
 #include <asm/io.h>
 #include <asm/sysinfo.h>
+#include <asm/compat.h>
 
 #include "qeth_core.h"
 
@@ -4402,6 +4403,104 @@ int qeth_snmp_command(struct qeth_card *
 }
 EXPORT_SYMBOL_GPL(qeth_snmp_command);
 
+static int qeth_setadpparms_query_oat_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_qoat_priv *priv;
+	char *resdata;
+	int resdatalen;
+
+	QETH_CARD_TEXT(card, 3, "qoatcb");
+
+	cmd = (struct qeth_ipa_cmd *)data;
+	priv = (struct qeth_qoat_priv *)reply->param;
+	resdatalen = cmd->data.setadapterparms.hdr.cmdlength;
+	resdata = (char *)data + 28;
+
+	if (resdatalen > (priv->buffer_len - priv->response_len)) {
+		cmd->hdr.return_code = IPA_RC_FFFF;
+		return 0;
+	}
+
+	memcpy((priv->buffer + priv->response_len), resdata,
+		resdatalen);
+	priv->response_len += resdatalen;
+
+	if (cmd->data.setadapterparms.hdr.seq_no <
+	    cmd->data.setadapterparms.hdr.used_total)
+		return 1;
+	return 0;
+}
+
+int qeth_query_oat_command(struct qeth_card *card, char __user *udata)
+{
+	int rc = 0;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_query_oat *oat_req;
+	struct qeth_query_oat_data oat_data;
+	struct qeth_qoat_priv priv;
+	void __user *tmp;
+
+	QETH_CARD_TEXT(card, 3, "qoatcmd");
+
+	if (!qeth_adp_supported(card, IPA_SETADP_QUERY_OAT)) {
+		rc = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (copy_from_user(&oat_data, udata,
+	    sizeof(struct qeth_query_oat_data))) {
+			rc = -EFAULT;
+			goto out;
+	}
+
+	priv.buffer_len = oat_data.buffer_len;
+	priv.response_len = 0;
+	priv.buffer =  kzalloc(oat_data.buffer_len, GFP_KERNEL);
+	if (!priv.buffer) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_OAT,
+				   sizeof(struct qeth_ipacmd_setadpparms_hdr) +
+				   sizeof(struct qeth_query_oat));
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	oat_req = &cmd->data.setadapterparms.data.query_oat;
+	oat_req->subcmd_code = oat_data.command;
+
+	rc = qeth_send_ipa_cmd(card, iob, qeth_setadpparms_query_oat_cb,
+			       &priv);
+	if (!rc) {
+		if (is_compat_task())
+			tmp = compat_ptr(oat_data.ptr);
+		else
+			tmp = (void __user *)(unsigned long)oat_data.ptr;
+
+		if (copy_to_user(tmp, priv.buffer,
+		    priv.response_len)) {
+			rc = -EFAULT;
+			goto out_free;
+		}
+
+		oat_data.response_len = priv.response_len;
+
+		if (copy_to_user(udata, &oat_data,
+		    sizeof(struct qeth_query_oat_data)))
+			rc = -EFAULT;
+	} else
+		if (rc == IPA_RC_FFFF)
+			rc = -EFAULT;
+
+out_free:
+	kfree(priv.buffer);
+out:
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_query_oat_command);
+
 static inline int qeth_get_qdio_q_format(struct qeth_card *card)
 {
 	switch (card->info.type) {
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -249,6 +249,7 @@ enum qeth_ipa_setadp_cmd {
 	IPA_SETADP_SET_PROMISC_MODE		= 0x00000800L,
 	IPA_SETADP_SET_DIAG_ASSIST		= 0x00002000L,
 	IPA_SETADP_SET_ACCESS_CONTROL		= 0x00010000L,
+	IPA_SETADP_QUERY_OAT			= 0x00080000L,
 };
 enum qeth_ipa_mac_ops {
 	CHANGE_ADDR_READ_MAC		= 0,
@@ -398,6 +399,17 @@ struct qeth_set_access_ctrl {
 	__u32 subcmd_code;
 } __attribute__((packed));
 
+struct qeth_query_oat {
+	__u32 subcmd_code;
+	__u8 reserved[12];
+} __packed;
+
+struct qeth_qoat_priv {
+	__u32 buffer_len;
+	__u32 response_len;
+	char *buffer;
+};
+
 struct qeth_ipacmd_setadpparms_hdr {
 	__u32 supp_hw_cmds;
 	__u32 reserved1;
@@ -417,6 +429,7 @@ struct qeth_ipacmd_setadpparms {
 		struct qeth_change_addr change_addr;
 		struct qeth_snmp_cmd snmp;
 		struct qeth_set_access_ctrl set_access_ctrl;
+		struct qeth_query_oat query_oat;
 		__u32 mode;
 	} data;
 } __attribute__ ((packed));
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -75,6 +75,9 @@ static int qeth_l2_do_ioctl(struct net_d
 			mii_data->val_out = qeth_mdio_read(dev,
 				mii_data->phy_id, mii_data->reg_num);
 		break;
+	case SIOC_QETH_QUERY_OAT:
+		rc = qeth_query_oat_command(card, rq->ifr_ifru.ifru_data);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2745,6 +2745,9 @@ static int qeth_l3_do_ioctl(struct net_d
 							mii_data->phy_id,
 							mii_data->reg_num);
 		break;
+	case SIOC_QETH_QUERY_OAT:
+		rc = qeth_query_oat_command(card, rq->ifr_ifru.ifru_data);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
