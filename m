From: frank.blaschka@de.ibm.com
Subject: [patch 3/3] qeth: bridgeport support - address notifications
Date: Tue, 14 Jan 2014 15:54:13 +0100
Message-ID: <20140114145509.534470776@de.ibm.com>
References: <20140114145410.453840919@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Eugene Crosser <eugene.crosser@ru.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:57147 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaANOzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 09:55:17 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 14 Jan 2014 14:55:15 -0000
Content-Disposition: inline; filename=604-qeth-bridgeport-notification.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Introduce functions to enable and disable bridgeport address
notification feature, sysfs attributes for access to these
functions from userspace, and udev events emitted when a host
joins or exits a bridgeport-enabled HiperSocket channel.

Signed-off-by: Eugene Crosser <eugene.crosser@ru.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 Documentation/s390/qeth.txt       |   29 ++++
 drivers/s390/net/qeth_core.h      |    5 
 drivers/s390/net/qeth_core_main.c |    3 
 drivers/s390/net/qeth_core_mpc.c  |    1 
 drivers/s390/net/qeth_core_mpc.h  |   38 ++++++
 drivers/s390/net/qeth_l2_main.c   |  230 ++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_l2_sys.c    |   62 ++++++++++
 7 files changed, 368 insertions(+)

--- a/Documentation/s390/qeth.txt
+++ b/Documentation/s390/qeth.txt
@@ -19,3 +19,32 @@ BRIDGEPORT=statechange -  indicates that
 ROLE={primary|secondary|none} - the role assigned to the port.
 
 STATE={active|standby|inactive} - the newly assumed state of the port.
+
+When run on HiperSockets Bridge Capable Port hardware with host address
+notifications enabled, a udev event with ACTION=CHANGE is emitted.
+It is emitted on behalf of the corresponding ccwgroup device when a host
+or a VLAN is registered or unregistered on the network served by the device.
+The event has the following attributes:
+
+BRIDGEDHOST={reset|register|deregister|abort} - host address
+  notifications are started afresh, a new host or VLAN is registered or
+  deregistered on the Bridge Port HiperSockets channel, or address
+  notifications are aborted.
+
+VLAN=numeric-vlan-id - VLAN ID on which the event occurred. Not included
+  if no VLAN is involved in the event.
+
+MAC=xx:xx:xx:xx:xx:xx - MAC address of the host that is being registered
+  or deregistered from the HiperSockets channel. Not reported if the
+  event reports the creation or destruction of a VLAN.
+
+NTOK_BUSID=x.y.zzzz - device bus ID (CSSID, SSID and device number).
+
+NTOK_IID=xx - device IID.
+
+NTOK_CHPID=xx - device CHPID.
+
+NTOK_CHID=xxxx - device channel ID.
+
+Note that the NTOK_* attributes refer to devices other than  the one
+connected to the system on which the OS is running.
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -169,9 +169,12 @@ enum qeth_sbp_states {
 	QETH_SBP_STATE_ACTIVE	= 2,
 };
 
+#define QETH_SBP_HOST_NOTIFICATION 1
+
 struct qeth_sbp_info {
 	__u32 supported_funcs;
 	enum qeth_sbp_roles role;
+	__u32 hostnotification:1;
 };
 
 static inline int qeth_is_ipa_supported(struct qeth_ipa_info *ipa,
@@ -950,6 +953,8 @@ void qeth_bridgeport_query_support(struc
 int qeth_bridgeport_query_ports(struct qeth_card *card,
 	enum qeth_sbp_roles *role, enum qeth_sbp_states *state);
 int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role);
+int qeth_bridgeport_an_set(struct qeth_card *card, int enable);
+void qeth_bridge_host_event(struct qeth_card *card, struct qeth_ipa_cmd *cmd);
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
 int qeth_get_elements_no(struct qeth_card *, struct sk_buff *, int);
 int qeth_get_elements_for_frags(struct sk_buff *);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -622,6 +622,9 @@ static struct qeth_ipa_cmd *qeth_check_i
 					return NULL;
 				} else
 					return cmd;
+			case IPA_CMD_ADDRESS_CHANGE_NOTIF:
+				qeth_bridge_host_event(card, cmd);
+				return NULL;
 			case IPA_CMD_MODCCID:
 				return cmd;
 			case IPA_CMD_REGISTER_LOCAL_ADDR:
--- a/drivers/s390/net/qeth_core_mpc.c
+++ b/drivers/s390/net/qeth_core_mpc.c
@@ -254,6 +254,7 @@ static struct ipa_cmd_names qeth_ipa_cmd
 	{IPA_CMD_DESTROY_ADDR,	"destroy_addr"},
 	{IPA_CMD_REGISTER_LOCAL_ADDR,	"register_local_addr"},
 	{IPA_CMD_UNREGISTER_LOCAL_ADDR,	"unregister_local_addr"},
+	{IPA_CMD_ADDRESS_CHANGE_NOTIF, "address_change_notification"},
 	{IPA_CMD_UNKNOWN,	"unknown"},
 };
 
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -109,6 +109,7 @@ enum qeth_ipa_cmds {
 	IPA_CMD_DESTROY_ADDR		= 0xc4,
 	IPA_CMD_REGISTER_LOCAL_ADDR	= 0xd1,
 	IPA_CMD_UNREGISTER_LOCAL_ADDR	= 0xd2,
+	IPA_CMD_ADDRESS_CHANGE_NOTIF	= 0xd3,
 	IPA_CMD_UNKNOWN			= 0x00
 };
 
@@ -520,6 +521,11 @@ struct net_if_token {
 	__u16 chid;
 } __packed;
 
+struct mac_addr_lnid {
+	__u8 mac[6];
+	__u16 lnid;
+} __packed;
+
 struct qeth_ipacmd_sbp_hdr {
 	__u32 supported_sbp_cmds;
 	__u32 enabled_sbp_cmds;
@@ -583,6 +589,37 @@ struct qeth_ipacmd_setbridgeport {
 	} data;
 } __packed;
 
+/* ADDRESS_CHANGE_NOTIFICATION adapter-initiated "command" *******************/
+/* Bitmask for entry->change_code. Both bits may be raised.		     */
+enum qeth_ipa_addr_change_code {
+	IPA_ADDR_CHANGE_CODE_VLANID		= 0x01,
+	IPA_ADDR_CHANGE_CODE_MACADDR		= 0x02,
+	IPA_ADDR_CHANGE_CODE_REMOVAL		= 0x80,	/* else addition */
+};
+enum qeth_ipa_addr_change_retcode {
+	IPA_ADDR_CHANGE_RETCODE_OK		= 0x0000,
+	IPA_ADDR_CHANGE_RETCODE_LOSTEVENTS	= 0x0010,
+};
+enum qeth_ipa_addr_change_lostmask {
+	IPA_ADDR_CHANGE_MASK_OVERFLOW		= 0x01,
+	IPA_ADDR_CHANGE_MASK_STATECHANGE	= 0x02,
+};
+
+struct qeth_ipacmd_addr_change_entry {
+	struct net_if_token token;
+	struct mac_addr_lnid addr_lnid;
+	__u8 change_code;
+	__u8 reserved1;
+	__u16 reserved2;
+} __packed;
+
+struct qeth_ipacmd_addr_change {
+	__u8 lost_event_mask;
+	__u8 reserved;
+	__u16 num_entries;
+	struct qeth_ipacmd_addr_change_entry entry[];
+} __packed;
+
 /* Header for each IPA command */
 struct qeth_ipacmd_hdr {
 	__u8   command;
@@ -613,6 +650,7 @@ struct qeth_ipa_cmd {
 		struct qeth_set_routing			setrtg;
 		struct qeth_ipacmd_diagass		diagass;
 		struct qeth_ipacmd_setbridgeport	sbp;
+		struct qeth_ipacmd_addr_change		addrchange;
 	} data;
 } __attribute__ ((packed));
 
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1354,6 +1354,71 @@ EXPORT_SYMBOL(qeth_osn_deregister);
 
 /* SETBRIDGEPORT support, async notifications */
 
+enum qeth_an_event_type {anev_reg_unreg, anev_abort, anev_reset};
+
+/**
+ * qeth_bridge_emit_host_event() - bridgeport address change notification
+ * @card:  qeth_card structure pointer, for udev events.
+ * @evtype:  "normal" register/unregister, or abort, or reset. For abort
+ *	      and reset token and addr_lnid are unused and may be NULL.
+ * @code:  event bitmask: high order bit 0x80 value 1 means removal of an
+ *			  object, 0 - addition of an object.
+ *			  0x01 - VLAN, 0x02 - MAC, 0x03 - VLAN and MAC.
+ * @token: "network token" structure identifying physical address of the port.
+ * @addr_lnid: pointer to structure with MAC address and VLAN ID.
+ *
+ * This function is called when registrations and deregistrations are
+ * reported by the hardware, and also when notifications are enabled -
+ * for all currently registered addresses.
+ */
+static void qeth_bridge_emit_host_event(struct qeth_card *card,
+	enum qeth_an_event_type evtype,
+	u8 code, struct net_if_token *token, struct mac_addr_lnid *addr_lnid)
+{
+	char str[7][32];
+	char *env[8];
+	int i = 0;
+
+	switch (evtype) {
+	case anev_reg_unreg:
+		snprintf(str[i], sizeof(str[i]), "BRIDGEDHOST=%s",
+				(code & IPA_ADDR_CHANGE_CODE_REMOVAL)
+				? "deregister" : "register");
+		env[i] = str[i]; i++;
+		if (code & IPA_ADDR_CHANGE_CODE_VLANID) {
+			snprintf(str[i], sizeof(str[i]), "VLAN=%d",
+				addr_lnid->lnid);
+			env[i] = str[i]; i++;
+		}
+		if (code & IPA_ADDR_CHANGE_CODE_MACADDR) {
+			snprintf(str[i], sizeof(str[i]), "MAC=%pM6",
+				&addr_lnid->mac);
+			env[i] = str[i]; i++;
+		}
+		snprintf(str[i], sizeof(str[i]), "NTOK_BUSID=%x.%x.%04x",
+			token->cssid, token->ssid, token->devnum);
+		env[i] = str[i]; i++;
+		snprintf(str[i], sizeof(str[i]), "NTOK_IID=%02x", token->iid);
+		env[i] = str[i]; i++;
+		snprintf(str[i], sizeof(str[i]), "NTOK_CHPID=%02x",
+				token->chpid);
+		env[i] = str[i]; i++;
+		snprintf(str[i], sizeof(str[i]), "NTOK_CHID=%04x", token->chid);
+		env[i] = str[i]; i++;
+		break;
+	case anev_abort:
+		snprintf(str[i], sizeof(str[i]), "BRIDGEDHOST=abort");
+		env[i] = str[i]; i++;
+		break;
+	case anev_reset:
+		snprintf(str[i], sizeof(str[i]), "BRIDGEDHOST=reset");
+		env[i] = str[i]; i++;
+		break;
+	}
+	env[i] = NULL;
+	kobject_uevent_env(&card->gdev->dev.kobj, KOBJ_CHANGE, env);
+}
+
 struct qeth_bridge_state_data {
 	struct work_struct worker;
 	struct qeth_card *card;
@@ -1425,6 +1490,78 @@ void qeth_bridge_state_change(struct qet
 }
 EXPORT_SYMBOL(qeth_bridge_state_change);
 
+struct qeth_bridge_host_data {
+	struct work_struct worker;
+	struct qeth_card *card;
+	struct qeth_ipacmd_addr_change hostevs;
+};
+
+static void qeth_bridge_host_event_worker(struct work_struct *work)
+{
+	struct qeth_bridge_host_data *data =
+		container_of(work, struct qeth_bridge_host_data, worker);
+	int i;
+
+	if (data->hostevs.lost_event_mask) {
+		dev_info(&data->card->gdev->dev,
+"Address notification from the HiperSockets Bridge Port stopped %s (%s)\n",
+			data->card->dev->name,
+			(data->hostevs.lost_event_mask == 0x01)
+			? "Overflow"
+			: (data->hostevs.lost_event_mask == 0x02)
+			? "Bridge port state change"
+			: "Unknown reason");
+		mutex_lock(&data->card->conf_mutex);
+		data->card->options.sbp.hostnotification = 0;
+		mutex_unlock(&data->card->conf_mutex);
+		qeth_bridge_emit_host_event(data->card, anev_abort,
+			0, NULL, NULL);
+	} else
+		for (i = 0; i < data->hostevs.num_entries; i++) {
+			struct qeth_ipacmd_addr_change_entry *entry =
+					&data->hostevs.entry[i];
+			qeth_bridge_emit_host_event(data->card,
+					anev_reg_unreg,
+					entry->change_code,
+					&entry->token, &entry->addr_lnid);
+		}
+	kfree(data);
+}
+
+void qeth_bridge_host_event(struct qeth_card *card, struct qeth_ipa_cmd *cmd)
+{
+	struct qeth_ipacmd_addr_change *hostevs =
+		 &cmd->data.addrchange;
+	struct qeth_bridge_host_data *data;
+	int extrasize;
+
+	QETH_CARD_TEXT(card, 2, "brhostev");
+	if (cmd->hdr.return_code != 0x0000) {
+		if (cmd->hdr.return_code == 0x0010) {
+			if (hostevs->lost_event_mask == 0x00)
+				hostevs->lost_event_mask = 0xff;
+		} else {
+			QETH_CARD_TEXT_(card, 2, "BPHe%04x",
+				cmd->hdr.return_code);
+			return;
+		}
+	}
+	extrasize = sizeof(struct qeth_ipacmd_addr_change_entry) *
+						hostevs->num_entries;
+	data = kzalloc(sizeof(struct qeth_bridge_host_data) + extrasize,
+		GFP_ATOMIC);
+	if (!data) {
+		QETH_CARD_TEXT(card, 2, "BPHalloc");
+		return;
+	}
+	INIT_WORK(&data->worker, qeth_bridge_host_event_worker);
+	data->card = card;
+	memcpy(&data->hostevs, hostevs,
+			sizeof(struct qeth_ipacmd_addr_change) + extrasize);
+	queue_work(qeth_wq, &data->worker);
+}
+EXPORT_SYMBOL(qeth_bridge_host_event);
+
 /* SETBRIDGEPORT support; sending commands */
 
 struct _qeth_sbp_cbctl {
@@ -1711,6 +1848,99 @@ int qeth_bridgeport_setrole(struct qeth_
 	return rc;
 }
 
+/**
+ * qeth_anset_makerc() - derive "traditional" error from hardware codes.
+ * @card:		      qeth_card structure pointer, for debug messages.
+ *
+ * Returns negative errno-compatible error indication or 0 on success.
+ */
+static int qeth_anset_makerc(struct qeth_card *card, int pnso_rc, u16 response)
+{
+	int rc;
+
+	if (pnso_rc == 0)
+		switch (response) {
+		case 0x0001:
+			rc = 0;
+			break;
+		case 0x0004:
+		case 0x0100:
+		case 0x0106:
+			rc = -ENOSYS;
+			dev_err(&card->gdev->dev,
+				"Setting address notification failed\n");
+			break;
+		case 0x0107:
+			rc = -EAGAIN;
+			break;
+		default:
+			rc = -EIO;
+		}
+	else
+		rc = -EIO;
+
+	if (rc) {
+		QETH_CARD_TEXT_(card, 2, "SBPp%04x", pnso_rc);
+		QETH_CARD_TEXT_(card, 2, "SBPr%04x", response);
+	}
+	return rc;
+}
+
+static void qeth_bridgeport_an_set_cb(void *priv,
+		enum qdio_brinfo_entry_type type, void *entry)
+{
+	struct qeth_card *card = (struct qeth_card *)priv;
+	struct qdio_brinfo_entry_l2 *l2entry;
+	u8 code;
+
+	if (type != l2_addr_lnid) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	l2entry = (struct qdio_brinfo_entry_l2 *)entry;
+	code = IPA_ADDR_CHANGE_CODE_MACADDR;
+	if (l2entry->addr_lnid.lnid)
+		code |= IPA_ADDR_CHANGE_CODE_VLANID;
+	qeth_bridge_emit_host_event(card, anev_reg_unreg, code,
+		(struct net_if_token *)&l2entry->nit,
+		(struct mac_addr_lnid *)&l2entry->addr_lnid);
+}
+
+/**
+ * qeth_bridgeport_an_set() - Enable or disable bridgeport address notification
+ * @card:		      qeth_card structure pointer.
+ * @enable:		      0 - disable, non-zero - enable notifications
+ *
+ * Returns negative errno-compatible error indication or 0 on success.
+ *
+ * On enable, emits a series of address notifications udev events for all
+ * currently registered hosts.
+ */
+int qeth_bridgeport_an_set(struct qeth_card *card, int enable)
+{
+	int rc;
+	u16 response;
+	struct ccw_device *ddev;
+	struct subchannel_id schid;
+
+	if (!card)
+		return -EINVAL;
+	if (!card->options.sbp.supported_funcs)
+		return -EOPNOTSUPP;
+	ddev = CARD_DDEV(card);
+	ccw_device_get_schid(ddev, &schid);
+
+	if (enable) {
+		qeth_bridge_emit_host_event(card, anev_reset, 0, NULL, NULL);
+		rc = qdio_pnso_brinfo(schid, 1, &response,
+			qeth_bridgeport_an_set_cb, card);
+	} else
+		rc = qdio_pnso_brinfo(schid, 0, &response, NULL, NULL);
+	return qeth_anset_makerc(card, rc, response);
+}
+EXPORT_SYMBOL_GPL(qeth_bridgeport_an_set);
+
 module_init(qeth_l2_init);
 module_exit(qeth_l2_exit);
 MODULE_AUTHOR("Frank Blaschka <frank.blaschka@de.ibm.com>");
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -119,9 +119,63 @@ static ssize_t qeth_bridge_port_state_sh
 static DEVICE_ATTR(bridge_state, 0644, qeth_bridge_port_state_show,
 		   NULL);
 
+static ssize_t qeth_bridgeport_hostnotification_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	int enabled;
+
+	if (!card)
+		return -EINVAL;
+
+	mutex_lock(&card->conf_mutex);
+
+	enabled = card->options.sbp.hostnotification;
+
+	mutex_unlock(&card->conf_mutex);
+
+	return sprintf(buf, "%d\n", enabled);
+}
+
+static ssize_t qeth_bridgeport_hostnotification_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	int rc = 0;
+	int enable;
+
+	if (!card)
+		return -EINVAL;
+
+	if (sysfs_streq(buf, "0"))
+		enable = 0;
+	else if (sysfs_streq(buf, "1"))
+		enable = 1;
+	else
+		return -EINVAL;
+
+	mutex_lock(&card->conf_mutex);
+
+	if (qeth_card_hw_is_reachable(card)) {
+		rc = qeth_bridgeport_an_set(card, enable);
+		if (!rc)
+			card->options.sbp.hostnotification = enable;
+	} else
+		card->options.sbp.hostnotification = enable;
+
+	mutex_unlock(&card->conf_mutex);
+
+	return rc ? rc : count;
+}
+
+static DEVICE_ATTR(bridge_hostnotify, 0644,
+			qeth_bridgeport_hostnotification_show,
+			qeth_bridgeport_hostnotification_store);
+
 static struct attribute *qeth_l2_bridgeport_attrs[] = {
 	&dev_attr_bridge_role.attr,
 	&dev_attr_bridge_state.attr,
+	&dev_attr_bridge_hostnotify.attr,
 	NULL,
 };
 
@@ -147,6 +201,8 @@ void qeth_l2_remove_device_attributes(st
  */
 void qeth_l2_setup_bridgeport_attrs(struct qeth_card *card)
 {
+	int rc;
+
 	if (!card)
 		return;
 	if (!card->options.sbp.supported_funcs)
@@ -158,4 +214,10 @@ void qeth_l2_setup_bridgeport_attrs(stru
 		qeth_bridgeport_query_ports(card,
 			&card->options.sbp.role, NULL);
 	}
+	if (card->options.sbp.hostnotification) {
+		rc = qeth_bridgeport_an_set(card, 1);
+		if (rc)
+			card->options.sbp.hostnotification = 0;
+	} else
+		qeth_bridgeport_an_set(card, 0);
 }
