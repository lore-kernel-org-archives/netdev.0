From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/8] qeth: IFF_PROMISC flag to BRIDGE PORT mode
Date: Mon, 18 May 2015 14:27:55 +0200
Message-ID: <1431952079-6847-5-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:47864 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168AbbERM2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:28:30 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:28:28 +0100
In-Reply-To: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

OSA and HiperSocket devices do not support promiscuous mode proper,
but they support "BRIDGE PORT" mode that is functionally similar.
This update introduces sysfs attribute that, when set, makes the driver
try to "reflect" setting and resetting of the IFF_PROMISC flag on the
interface into setting and resetting PRIMARY or SECONDARY bridge port
role on the underlying OSA or HiperSocket device.

Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h    |  2 ++
 drivers/s390/net/qeth_l2_main.c | 40 ++++++++++++++++++++++++++---
 drivers/s390/net/qeth_l2_sys.c  | 56 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 95 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 3abac02..ba974a2 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -175,6 +175,8 @@ struct qeth_sbp_info {
 	__u32 supported_funcs;
 	enum qeth_sbp_roles role;
 	__u32 hostnotification:1;
+	__u32 reflect_promisc:1;
+	__u32 reflect_promisc_primary:1;
 };
 
 static inline int qeth_is_ipa_supported(struct qeth_ipa_info *ipa,
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 1cdefae..0ff926d 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -683,6 +683,39 @@ static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
 	return rc ? -EINVAL : 0;
 }
 
+static void qeth_promisc_to_bridge(struct qeth_card *card)
+{
+	struct net_device *dev = card->dev;
+	enum qeth_ipa_promisc_modes promisc_mode;
+	int role;
+	int rc;
+
+	QETH_CARD_TEXT(card, 3, "pmisc2br");
+
+	if (!card->options.sbp.reflect_promisc)
+		return;
+	promisc_mode = (dev->flags & IFF_PROMISC) ? SET_PROMISC_MODE_ON
+						: SET_PROMISC_MODE_OFF;
+	if (promisc_mode == card->info.promisc_mode)
+		return;
+
+	if (promisc_mode == SET_PROMISC_MODE_ON) {
+		if (card->options.sbp.reflect_promisc_primary)
+			role = QETH_SBP_ROLE_PRIMARY;
+		else
+			role = QETH_SBP_ROLE_SECONDARY;
+	} else
+		role = QETH_SBP_ROLE_NONE;
+
+	rc = qeth_bridgeport_setrole(card, role);
+	QETH_DBF_TEXT_(SETUP, 2, "bpm%c%04x",
+			(promisc_mode == SET_PROMISC_MODE_ON) ? '+' : '-', rc);
+	if (!rc) {
+		card->options.sbp.role = role;
+		card->info.promisc_mode = promisc_mode;
+	}
+}
+
 static void qeth_l2_set_multicast_list(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
@@ -704,9 +737,10 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 		qeth_l2_add_mc(card, ha->addr, 1);
 
 	spin_unlock_bh(&card->mclock);
-	if (!qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
-		return;
-	qeth_setadp_promisc_mode(card);
+	if (qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
+		qeth_setadp_promisc_mode(card);
+	else
+		qeth_promisc_to_bridge(card);
 }
 
 static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/drivers/s390/net/qeth_l2_sys.c b/drivers/s390/net/qeth_l2_sys.c
index 6504d48..a553fba 100644
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -159,10 +159,66 @@ static DEVICE_ATTR(bridge_hostnotify, 0644,
 			qeth_bridgeport_hostnotification_show,
 			qeth_bridgeport_hostnotification_store);
 
+static ssize_t qeth_bridgeport_reflect_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *state;
+
+	if (!card)
+		return -EINVAL;
+
+	if (card->options.sbp.reflect_promisc) {
+		if (card->options.sbp.reflect_promisc_primary)
+			state = "primary";
+		else
+			state = "secondary";
+	} else
+		state = "none";
+
+	return sprintf(buf, "%s\n", state);
+}
+
+static ssize_t qeth_bridgeport_reflect_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	int enable, primary;
+
+	if (!card)
+		return -EINVAL;
+
+	if (sysfs_streq(buf, "none")) {
+		enable = 0;
+		primary = 0;
+	} else if (sysfs_streq(buf, "primary")) {
+		enable = 1;
+		primary = 1;
+	} else if (sysfs_streq(buf, "secondary")) {
+		enable = 1;
+		primary = 0;
+	} else
+		return -EINVAL;
+
+	mutex_lock(&card->conf_mutex);
+
+	card->options.sbp.reflect_promisc = enable;
+	card->options.sbp.reflect_promisc_primary = primary;
+
+	mutex_unlock(&card->conf_mutex);
+
+	return count;
+}
+
+static DEVICE_ATTR(bridge_reflect_promisc, 0644,
+			qeth_bridgeport_reflect_show,
+			qeth_bridgeport_reflect_store);
+
 static struct attribute *qeth_l2_bridgeport_attrs[] = {
 	&dev_attr_bridge_role.attr,
 	&dev_attr_bridge_state.attr,
 	&dev_attr_bridge_hostnotify.attr,
+	&dev_attr_bridge_reflect_promisc.attr,
 	NULL,
 };
 
-- 
2.3.7
