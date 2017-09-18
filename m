From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/9] s390/qeth: add basic VNICC support
Date: Mon, 18 Sep 2017 21:18:14 +0200
Message-ID: <20170918191822.65142-2-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45890 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751463AbdIRTUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:20:15 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJK78m037149
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:15 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2hwt8mcu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:13 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:22 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

VNIC Characteristics (VNICC) are features of HiperSockets that define
how packets are handled by the underlying network hardware. For example,
if the VNICC flooding is configured on a qeth device, ethernet frames to
unknown destination MAC addresses are received.

Currently, there is support for seven VNICCs: flooding, multicast
flooding, receive broadcast, learning, takeover learning, takeover
setvmac, bridge invisible. Also, six IPA commands exist for configuring
VNICCs on a qeth device: query characteristics, query commands, enable
characteristic, disable characteristic, set timeout, get timeout.

This patch adds the basic code infrastructure for VNICC support to qeth.
It allows querying VNICC support from the underlying hardware. To this
end, it adds:

* basic message formats for IPA commands
* basic data structures
* basic error handling
* query characteristics IPA command support

The query characteristics IPA command allows requesting the currently
supported and currently enabled VNIC characteristics from the underlying
hardware.

Support for the other IPA commands and for the configuration of VNICCs
is added in follow-up patches together with the respective user
interface functions.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h     |   7 ++
 drivers/s390/net/qeth_core_mpc.c |   4 +-
 drivers/s390/net/qeth_core_mpc.h |  29 +++++++++
 drivers/s390/net/qeth_l2_main.c  | 136 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 172 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 59e09854c4f7..b96438df8fd4 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -182,6 +182,12 @@ struct qeth_sbp_info {
 	__u32 reflect_promisc_primary:1;
 };
 
+struct qeth_vnicc_info {
+	/* supported/currently configured VNICCs; updated in IPA exchanges */
+	u32 sup_chars;
+	u32 cur_chars;
+};
+
 static inline int qeth_is_ipa_supported(struct qeth_ipa_info *ipa,
 		enum qeth_ipa_funcs func)
 {
@@ -673,6 +679,7 @@ struct qeth_card_options {
 	struct qeth_routing_info route6;
 	struct qeth_ipa_info ipa6;
 	struct qeth_sbp_info sbp; /* SETBRIDGEPORT options */
+	struct qeth_vnicc_info vnicc; /* VNICC options */
 	int fake_broadcast;
 	int layer2;
 	int performance_stats;
diff --git a/drivers/s390/net/qeth_core_mpc.c b/drivers/s390/net/qeth_core_mpc.c
index 6dd7d05e5693..5f8a2b834d39 100644
--- a/drivers/s390/net/qeth_core_mpc.c
+++ b/drivers/s390/net/qeth_core_mpc.c
@@ -167,7 +167,7 @@ static struct ipa_rc_msg qeth_ipa_rc_msg[] = {
 	{IPA_RC_IP_TABLE_FULL,		"Add Addr IP Table Full - ipv6"},
 	{IPA_RC_UNKNOWN_ERROR,		"IPA command failed - reason unknown"},
 	{IPA_RC_UNSUPPORTED_COMMAND,	"Command not supported"},
-	{IPA_RC_TRACE_ALREADY_ACTIVE,	"trace already active"},
+	{IPA_RC_VNICC_OOSEQ,		"Command issued out of sequence"},
 	{IPA_RC_INVALID_FORMAT,		"invalid format or length"},
 	{IPA_RC_DUP_IPV6_REMOTE, "ipv6 address already registered remote"},
 	{IPA_RC_SBP_IQD_NOT_CONFIGURED,	"Not configured for bridgeport"},
@@ -193,6 +193,7 @@ static struct ipa_rc_msg qeth_ipa_rc_msg[] = {
 	{IPA_RC_L2_INVALID_VLAN_ID,	"L2 invalid vlan id"},
 	{IPA_RC_L2_DUP_VLAN_ID,		"L2 duplicate vlan id"},
 	{IPA_RC_L2_VLAN_ID_NOT_FOUND,	"L2 vlan id not found"},
+	{IPA_RC_VNICC_VNICBP,		"VNIC is BridgePort"},
 	{IPA_RC_SBP_OSA_NOT_CONFIGURED,	"Not configured for bridgeport"},
 	{IPA_RC_SBP_OSA_OS_MISMATCH,	"OS mismatch"},
 	{IPA_RC_SBP_OSA_ANO_DEV_PRIMARY, "Primary bridgeport exists already"},
@@ -253,6 +254,7 @@ static struct ipa_cmd_names qeth_ipa_cmd_names[] = {
 	{IPA_CMD_DELGMAC,	"delgmac"},
 	{IPA_CMD_SETVLAN,	"setvlan"},
 	{IPA_CMD_DELVLAN,	"delvlan"},
+	{IPA_CMD_VNICC,		"vnic_characteristics"},
 	{IPA_CMD_SETBRIDGEPORT_OSA,	"set_bridge_port(osa)"},
 	{IPA_CMD_SETCCID,	"setccid"},
 	{IPA_CMD_DELCCID,	"delccid"},
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 912e0107de8f..c13816b8c92f 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -90,6 +90,7 @@ enum qeth_ipa_cmds {
 	IPA_CMD_DELGMAC			= 0x24,
 	IPA_CMD_SETVLAN			= 0x25,
 	IPA_CMD_DELVLAN			= 0x26,
+	IPA_CMD_VNICC			= 0x2a,
 	IPA_CMD_SETBRIDGEPORT_OSA	= 0x2b,
 	IPA_CMD_SETCCID			= 0x41,
 	IPA_CMD_DELCCID			= 0x42,
@@ -165,6 +166,7 @@ enum qeth_ipa_return_codes {
 	IPA_RC_L2_INVALID_VLAN_ID	= 0x2015,
 	IPA_RC_L2_DUP_VLAN_ID		= 0x2016,
 	IPA_RC_L2_VLAN_ID_NOT_FOUND	= 0x2017,
+	IPA_RC_VNICC_VNICBP		= 0x20B0,
 	IPA_RC_SBP_OSA_NOT_CONFIGURED	= 0x2B0C,
 	IPA_RC_SBP_OSA_OS_MISMATCH	= 0x2B10,
 	IPA_RC_SBP_OSA_ANO_DEV_PRIMARY	= 0x2B14,
@@ -197,6 +199,9 @@ enum qeth_ipa_return_codes {
 	IPA_RC_ENOMEM			= 0xfffe,
 	IPA_RC_FFFF			= 0xffff
 };
+/* for VNIC Characteristics */
+#define IPA_RC_VNICC_OOSEQ 0x0005
+
 /* for SET_DIAGNOSTIC_ASSIST */
 #define IPA_RC_INVALID_SUBCMD		IPA_RC_IP_TABLE_FULL
 #define IPA_RC_HARDWARE_AUTH_ERROR	IPA_RC_UNKNOWN_ERROR
@@ -551,6 +556,29 @@ struct qeth_ipacmd_diagass {
 	__u8   cdata[64];
 } __attribute__ ((packed));
 
+/* VNIC Characteristics IPA Command: *****************************************/
+/* IPA commands/sub commands for VNICC */
+#define IPA_VNICC_QUERY_CHARS		0x00000000L
+
+/* VNICC header */
+struct qeth_ipacmd_vnicc_hdr {
+	u32 sup;
+	u32 cur;
+};
+
+/* VNICC sub command header */
+struct qeth_vnicc_sub_hdr {
+	u16 data_length;
+	u16 reserved;
+	u32 sub_command;
+};
+
+/* complete VNICC IPA command message */
+struct qeth_ipacmd_vnicc {
+	struct qeth_ipacmd_vnicc_hdr hdr;
+	struct qeth_vnicc_sub_hdr sub_hdr;
+};
+
 /* SETBRIDGEPORT IPA Command:	 *********************************************/
 enum qeth_ipa_sbp_cmd {
 	IPA_SBP_QUERY_COMMANDS_SUPPORTED	= 0x00000000L,
@@ -692,6 +720,7 @@ struct qeth_ipa_cmd {
 		struct qeth_ipacmd_diagass		diagass;
 		struct qeth_ipacmd_setbridgeport	sbp;
 		struct qeth_ipacmd_addr_change		addrchange;
+		struct qeth_ipacmd_vnicc		vnicc;
 	} data;
 } __attribute__ ((packed));
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 760b023eae95..2fa273b40dd1 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -33,6 +33,7 @@ static void qeth_bridge_state_change(struct qeth_card *card,
 					struct qeth_ipa_cmd *cmd);
 static void qeth_bridge_host_event(struct qeth_card *card,
 					struct qeth_ipa_cmd *cmd);
+static void qeth_l2_vnicc_init(struct qeth_card *card);
 
 static int qeth_l2_verify_dev(struct net_device *dev)
 {
@@ -1045,9 +1046,14 @@ static int qeth_l2_start_ipassists(struct qeth_card *card)
 
 static void qeth_l2_trace_features(struct qeth_card *card)
 {
-	QETH_CARD_TEXT(card, 2, "l2featur");
+	/* Set BridgePort features */
+	QETH_CARD_TEXT(card, 2, "featuSBP");
 	QETH_CARD_HEX(card, 2, &card->options.sbp.supported_funcs,
 		      sizeof(card->options.sbp.supported_funcs));
+	/* VNIC Characteristics features */
+	QETH_CARD_TEXT(card, 2, "feaVNICC");
+	QETH_CARD_HEX(card, 2, &card->options.vnicc.sup_chars,
+		      sizeof(card->options.vnicc.sup_chars));
 }
 
 static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
@@ -1072,8 +1078,6 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	if (card->options.sbp.supported_funcs)
 		dev_info(&card->gdev->dev,
 		"The device represents a Bridge Capable Port\n");
-	qeth_trace_features(card);
-	qeth_l2_trace_features(card);
 
 	if (!card->dev && qeth_l2_setup_netdev(card)) {
 		rc = -ENODEV;
@@ -1090,6 +1094,12 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	} else
 		card->info.hwtrap = 0;
 
+	/* for the rx_bcast characteristic, init VNICC after setmac */
+	qeth_l2_vnicc_init(card);
+
+	qeth_trace_features(card);
+	qeth_l2_trace_features(card);
+
 	qeth_l2_setup_bridgeport_attrs(card);
 
 	card->state = CARD_STATE_HARDSETUP;
@@ -2039,6 +2049,126 @@ int qeth_bridgeport_an_set(struct qeth_card *card, int enable)
 }
 EXPORT_SYMBOL_GPL(qeth_bridgeport_an_set);
 
+/* VNIC Characteristics support */
+
+/* handle VNICC IPA command return codes; convert to error codes */
+static int qeth_l2_vnicc_makerc(struct qeth_card *card, int ipa_rc)
+{
+	int rc;
+
+	switch (ipa_rc) {
+	case IPA_RC_SUCCESS:
+		return ipa_rc;
+	case IPA_RC_L2_UNSUPPORTED_CMD:
+	case IPA_RC_NOTSUPP:
+		rc = -EOPNOTSUPP;
+		break;
+	case IPA_RC_VNICC_OOSEQ:
+		rc = -EALREADY;
+		break;
+	case IPA_RC_VNICC_VNICBP:
+		rc = -EBUSY;
+		break;
+	case IPA_RC_L2_ADDR_TABLE_FULL:
+		rc = -ENOSPC;
+		break;
+	case IPA_RC_L2_MAC_NOT_AUTH_BY_ADP:
+		rc = -EACCES;
+		break;
+	default:
+		rc = -EIO;
+	}
+
+	QETH_CARD_TEXT_(card, 2, "err%04x", ipa_rc);
+	return rc;
+}
+
+/* generic VNICC request call back control */
+struct _qeth_l2_vnicc_request_cbctl {
+	u32 sub_cmd;
+};
+
+/* generic VNICC request call back */
+static int qeth_l2_vnicc_request_cb(struct qeth_card *card,
+				    struct qeth_reply *reply,
+				    unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd = (struct qeth_ipa_cmd *) data;
+	struct qeth_ipacmd_vnicc *rep = &cmd->data.vnicc;
+
+	QETH_CARD_TEXT(card, 2, "vniccrcb");
+	if (cmd->hdr.return_code)
+		return 0;
+	/* return results to caller */
+	card->options.vnicc.sup_chars = rep->hdr.sup;
+	card->options.vnicc.cur_chars = rep->hdr.cur;
+
+	return 0;
+}
+
+/* generic VNICC request */
+static int qeth_l2_vnicc_request(struct qeth_card *card,
+				 struct _qeth_l2_vnicc_request_cbctl *cbctl)
+{
+	struct qeth_ipacmd_vnicc *req;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+	int rc;
+
+	QETH_CARD_TEXT(card, 2, "vniccreq");
+
+	/* get new buffer for request */
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_VNICC, 0);
+	if (!iob)
+		return -ENOMEM;
+
+	/* create header for request */
+	cmd = (struct qeth_ipa_cmd *)(iob->data + IPA_PDU_HEADER_SIZE);
+	req = &cmd->data.vnicc;
+
+	/* create sub command header for request */
+	req->sub_hdr.data_length = sizeof(req->sub_hdr);
+	req->sub_hdr.sub_command = cbctl->sub_cmd;
+
+	/* create sub command specific request fields */
+	switch (cbctl->sub_cmd) {
+	case IPA_VNICC_QUERY_CHARS:
+		break;
+	default:
+		qeth_release_buffer(iob->channel, iob);
+		return -EOPNOTSUPP;
+	}
+
+	/* send request */
+	rc = qeth_send_ipa_cmd(card, iob, qeth_l2_vnicc_request_cb,
+			       (void *) cbctl);
+
+	return qeth_l2_vnicc_makerc(card, rc);
+}
+
+/* VNICC query VNIC characteristics request */
+static int qeth_l2_vnicc_query_chars(struct qeth_card *card)
+{
+	struct _qeth_l2_vnicc_request_cbctl cbctl;
+
+	/* prepare callback control */
+	cbctl.sub_cmd = IPA_VNICC_QUERY_CHARS;
+
+	QETH_CARD_TEXT(card, 2, "vniccqch");
+	return qeth_l2_vnicc_request(card, &cbctl);
+}
+
+/* (re-)initialize VNICC */
+static void qeth_l2_vnicc_init(struct qeth_card *card)
+{
+	QETH_CARD_TEXT(card, 2, "vniccini");
+	/* initial query and storage of VNIC characteristics */
+	if (qeth_l2_vnicc_query_chars(card)) {
+		card->options.vnicc.sup_chars = 0;
+		card->options.vnicc.cur_chars = 0;
+	}
+}
+
 module_init(qeth_l2_init);
 module_exit(qeth_l2_exit);
 MODULE_AUTHOR("Frank Blaschka <frank.blaschka@de.ibm.com>");
-- 
2.13.5
