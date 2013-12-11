From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: [PATCH 2/2] qeth: Display adjacent switch port attributes in ethtool
Date: Wed, 11 Dec 2013 14:29:00 +0100
Message-ID: <1386768540-48188-3-git-send-email-raspl@linux.vnet.ibm.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com>
Cc: bhutchings@solarflare.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:57729 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839Ab3LKN3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:29:44 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 13:29:43 -0000
In-Reply-To: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for get_switch_port_attrs() callback in ethtool to display
adjacent switch port's attributes.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Acked-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  7 ++++
 drivers/s390/net/qeth_core_main.c | 79 +++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_core_mpc.h  | 17 +++++++++
 drivers/s390/net/qeth_l2_main.c   |  1 +
 drivers/s390/net/qeth_l3_main.c   |  1 +
 5 files changed, 105 insertions(+)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 41ef943..bc30a2a 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -738,6 +738,11 @@ struct qeth_rx {
 	int qdio_err;
 };
 
+struct qeth_switch_info {
+        __u32 capabilities;
+        __u32 settings;
+};
+
 #define QETH_NAPI_WEIGHT NAPI_POLL_WEIGHT
 
 struct qeth_card {
@@ -914,6 +919,8 @@ struct qeth_cmd_buffer *qeth_wait_for_buffer(struct qeth_channel *);
 int qeth_mdio_read(struct net_device *, int, int);
 int qeth_snmp_command(struct qeth_card *, char __user *);
 int qeth_query_oat_command(struct qeth_card *, char __user *);
+int qeth_core_ethtool_get_switch_port_attrs(struct net_device *,
+						struct ethtool_swport_attrs *);
 int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
 	int (*reply_cb)(struct qeth_card *, struct qeth_reply*, unsigned long),
 	void *reply_param);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index eb4e1f8..b8827bd 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3036,6 +3036,42 @@ int qeth_query_ipassists(struct qeth_card *card, enum qeth_prot_versions prot)
 }
 EXPORT_SYMBOL_GPL(qeth_query_ipassists);
 
+static int qeth_query_switch_port_attributes_cb(struct qeth_card *card,
+				struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_switch_info *sw_info;
+	struct qeth_query_switch_attributes *attrs;
+
+	QETH_CARD_TEXT(card, 2, "qsqiatcb");
+	cmd = (struct qeth_ipa_cmd *) data;
+	sw_info = (struct qeth_switch_info *)reply->param;
+	if (cmd->data.setadapterparms.hdr.return_code == 0) {
+		attrs = &cmd->data.setadapterparms.data.query_switch_attributes;
+		sw_info->capabilities = attrs->capabilities;
+		sw_info->settings = attrs->settings;
+	}
+	qeth_default_setadapterparms_cb(card, reply, (unsigned long) cmd);
+
+	return 0;
+}
+
+static int qeth_query_switch_port_attributes(struct qeth_card *card,
+					struct qeth_switch_info *sw_info)
+{
+	struct qeth_cmd_buffer *iob;
+
+	QETH_CARD_TEXT(card, 2, "qswiattr");
+	if (!qeth_adp_supported(card, IPA_SETADP_QUERY_SWITCH_ATTRIBUTES))
+		return -EOPNOTSUPP;
+	if (!netif_carrier_ok(card->dev))
+		return -ENOMEDIUM;
+	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_SWITCH_ATTRIBUTES,
+				sizeof(struct qeth_ipacmd_setadpparms_hdr));
+	return qeth_send_ipa_cmd(card, iob,
+				qeth_query_switch_port_attributes_cb, sw_info);
+}
+
 static int qeth_query_setdiagass_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
 {
@@ -5696,6 +5732,49 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 }
 EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_settings);
 
+int qeth_core_ethtool_get_switch_port_attrs(struct net_device *netdev,
+					struct ethtool_swport_attrs *attrs)
+{
+	int rc, i;
+	struct qeth_card *card = netdev->ml_priv;
+	struct qeth_switch_info sw_info;
+	static const struct {
+		int qeth_cap;
+		int etht_cap_sup;
+		int etht_cap_enbl;
+	} qattrs[] = {
+		{ QETH_SWITCH_FORW_802_1, SUPPORTED_SP_FWD_802_1,
+		  ENABLED_SP_FWD_802_1 },
+		{ QETH_SWITCH_FORW_REFL_RELAY, SUPPORTED_SP_FWD_RR,
+		  ENABLED_SP_FWD_RR },
+		{ QETH_SWITCH_CAP_RTE, SUPPORTED_SP_CAP_RTE,
+		  ENABLED_SP_CAP_RTE },
+		{ QETH_SWITCH_CAP_ECP, SUPPORTED_SP_CAP_ECP,
+		  ENABLED_SP_CAP_ECP },
+		{ QETH_SWITCH_CAP_VDP, SUPPORTED_SP_CAP_VDP,
+		  ENABLED_SP_CAP_VDP }
+	};
+
+	rc = qeth_query_switch_port_attributes(card, &sw_info);
+	if (rc)
+		return rc;
+
+	if (!sw_info.capabilities) {
+		attrs->port_rc = GPORT_RC_LLDP_UNSUP;
+		return 0;
+	}
+	for (i = 0; i < ARRAY_SIZE(qattrs); i++) {
+		if (sw_info.capabilities & qattrs[i].qeth_cap) {
+			attrs->supported |= qattrs[i].etht_cap_sup;
+			if (sw_info.settings & qattrs[i].qeth_cap)
+				attrs->enabled |= qattrs[i].etht_cap_enbl;
+		}
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_switch_port_attrs);
+
 static int __init qeth_core_init(void)
 {
 	int rc;
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 07085d5..9f9b034 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -240,6 +240,7 @@ enum qeth_ipa_setadp_cmd {
 	IPA_SETADP_SET_DIAG_ASSIST		= 0x00002000L,
 	IPA_SETADP_SET_ACCESS_CONTROL		= 0x00010000L,
 	IPA_SETADP_QUERY_OAT			= 0x00080000L,
+	IPA_SETADP_QUERY_SWITCH_ATTRIBUTES	= 0x00100000L,
 };
 enum qeth_ipa_mac_ops {
 	CHANGE_ADDR_READ_MAC		= 0,
@@ -404,6 +405,21 @@ struct qeth_qoat_priv {
 	char *buffer;
 };
 
+#define QETH_SWITCH_FORW_802_1		0x00000001
+#define QETH_SWITCH_FORW_REFL_RELAY	0x00000002
+#define QETH_SWITCH_CAP_RTE		0x00000004
+#define QETH_SWITCH_CAP_ECP		0x00000008
+#define QETH_SWITCH_CAP_VDP		0x00000010
+
+struct qeth_query_switch_attributes {
+	__u8  version;
+	__u8  reserved1;
+	__u16 reserved2;
+	__u32 capabilities;
+	__u32 settings;
+	__u8  reserved3[8];
+};
+
 struct qeth_ipacmd_setadpparms_hdr {
 	__u32 supp_hw_cmds;
 	__u32 reserved1;
@@ -424,6 +440,7 @@ struct qeth_ipacmd_setadpparms {
 		struct qeth_snmp_cmd snmp;
 		struct qeth_set_access_ctrl set_access_ctrl;
 		struct qeth_query_oat query_oat;
+		struct qeth_query_switch_attributes query_switch_attributes;
 		__u32 mode;
 	} data;
 } __attribute__ ((packed));
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index ec8ccda..ae4de33 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -911,6 +911,7 @@ static const struct ethtool_ops qeth_l2_ethtool_ops = {
 	.get_sset_count = qeth_core_get_sset_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
 	.get_settings = qeth_core_ethtool_get_settings,
+	.get_switch_port_attrs = qeth_core_ethtool_get_switch_port_attrs,
 };
 
 static const struct ethtool_ops qeth_l2_osn_ops = {
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index c1b0b27..356076a 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3198,6 +3198,7 @@ static const struct ethtool_ops qeth_l3_ethtool_ops = {
 	.get_sset_count = qeth_core_get_sset_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
 	.get_settings = qeth_core_ethtool_get_settings,
+	.get_switch_port_attrs = qeth_core_ethtool_get_switch_port_attrs,
 };
 
 /*
-- 
1.8.3.4
