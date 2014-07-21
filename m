From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] qeth: Display adjacent switch attributes
Date: Mon, 21 Jul 2014 12:54:43 +0200
Message-ID: <20140721105502.483376376@de.ibm.com>
References: <20140721105442.533889716@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:43552 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbaGUKzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 06:55:09 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jul 2014 11:55:07 +0100
Content-Disposition: inline; filename=600-qeth-switch-attrs.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Add support to display the adjacent switch port's forwarding
attributes. Currently supports info on forwarding modes '802.1'
and 'rr' (reflective relay).

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    7 ++++++
 drivers/s390/net/qeth_core_main.c |   39 ++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_core_mpc.h  |   17 ++++++++++++++++
 drivers/s390/net/qeth_core_sys.c  |   38 ++++++++++++++++++++++++++++++++++++-
 4 files changed, 100 insertions(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -766,6 +766,11 @@ struct carrier_info {
 	__u32 port_speed;
 };
 
+struct qeth_switch_info {
+	__u32 capabilities;
+	__u32 settings;
+};
+
 #define QETH_NAPI_WEIGHT NAPI_POLL_WEIGHT
 
 struct qeth_card {
@@ -946,6 +951,8 @@ struct qeth_cmd_buffer *qeth_wait_for_bu
 int qeth_mdio_read(struct net_device *, int, int);
 int qeth_snmp_command(struct qeth_card *, char __user *);
 int qeth_query_oat_command(struct qeth_card *, char __user *);
+int qeth_query_switch_attributes(struct qeth_card *card,
+				  struct qeth_switch_info *sw_info);
 int qeth_query_card_info(struct qeth_card *card,
 	struct carrier_info *carrier_info);
 int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3037,6 +3037,45 @@ int qeth_query_ipassists(struct qeth_car
 }
 EXPORT_SYMBOL_GPL(qeth_query_ipassists);
 
+static int qeth_query_switch_attributes_cb(struct qeth_card *card,
+				struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_switch_info *sw_info;
+	struct qeth_query_switch_attributes *attrs;
+
+	QETH_CARD_TEXT(card, 2, "qswiatcb");
+	cmd = (struct qeth_ipa_cmd *) data;
+	sw_info = (struct qeth_switch_info *)reply->param;
+	if (cmd->data.setadapterparms.hdr.return_code == 0) {
+		attrs = &cmd->data.setadapterparms.data.query_switch_attributes;
+		sw_info->capabilities = attrs->capabilities;
+		sw_info->settings = attrs->settings;
+		QETH_CARD_TEXT_(card, 2, "%04x%04x", sw_info->capabilities,
+							sw_info->settings);
+	}
+	qeth_default_setadapterparms_cb(card, reply, (unsigned long) cmd);
+
+	return 0;
+}
+
+int qeth_query_switch_attributes(struct qeth_card *card,
+				 struct qeth_switch_info *sw_info)
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
+				qeth_query_switch_attributes_cb, sw_info);
+}
+EXPORT_SYMBOL_GPL(qeth_query_switch_attributes);
+
 static int qeth_query_setdiagass_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
 {
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -242,6 +242,7 @@ enum qeth_ipa_setadp_cmd {
 	IPA_SETADP_SET_DIAG_ASSIST		= 0x00002000L,
 	IPA_SETADP_SET_ACCESS_CONTROL		= 0x00010000L,
 	IPA_SETADP_QUERY_OAT			= 0x00080000L,
+	IPA_SETADP_QUERY_SWITCH_ATTRIBUTES	= 0x00100000L,
 };
 enum qeth_ipa_mac_ops {
 	CHANGE_ADDR_READ_MAC		= 0,
@@ -431,6 +432,21 @@ struct qeth_query_card_info {
 	__u32	reserved2;
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
@@ -452,6 +468,7 @@ struct qeth_ipacmd_setadpparms {
 		struct qeth_set_access_ctrl set_access_ctrl;
 		struct qeth_query_oat query_oat;
 		struct qeth_query_card_info card_info;
+		struct qeth_query_switch_attributes query_switch_attributes;
 		__u32 mode;
 	} data;
 } __attribute__ ((packed));
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -543,7 +543,42 @@ out:
 }
 
 static DEVICE_ATTR(isolation, 0644, qeth_dev_isolation_show,
-		   qeth_dev_isolation_store);
+			qeth_dev_isolation_store);
+
+static ssize_t qeth_dev_switch_attrs_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	struct qeth_switch_info sw_info;
+	int	rc = 0;
+
+	if (!card)
+		return -EINVAL;
+
+	if (card->state != CARD_STATE_SOFTSETUP && card->state != CARD_STATE_UP)
+		return sprintf(buf, "n/a\n");
+
+	rc = qeth_query_switch_attributes(card, &sw_info);
+	if (rc)
+		return rc;
+
+	if (!sw_info.capabilities)
+		rc = sprintf(buf, "unknown");
+
+	if (sw_info.capabilities & QETH_SWITCH_FORW_802_1)
+		rc = sprintf(buf, (sw_info.settings & QETH_SWITCH_FORW_802_1 ?
+							"[802.1]" : "802.1"));
+	if (sw_info.capabilities & QETH_SWITCH_FORW_REFL_RELAY)
+		rc += sprintf(buf + rc,
+			(sw_info.settings & QETH_SWITCH_FORW_REFL_RELAY ?
+							" [rr]" : " rr"));
+	rc += sprintf(buf + rc, "\n");
+
+	return rc;
+}
+
+static DEVICE_ATTR(switch_attrs, 0444,
+		   qeth_dev_switch_attrs_show, NULL);
 
 static ssize_t qeth_hw_trap_show(struct device *dev,
 				struct device_attribute *attr, char *buf)
@@ -728,6 +763,7 @@ static struct attribute *qeth_device_att
 	&dev_attr_layer2.attr,
 	&dev_attr_isolation.attr,
 	&dev_attr_hw_trap.attr,
+	&dev_attr_switch_attrs.attr,
 	NULL,
 };
 static struct attribute_group qeth_device_attr_group = {
