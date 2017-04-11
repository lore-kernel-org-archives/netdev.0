From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 01/10] s390/qeth: move common ioctl handling to core
Date: Tue, 11 Apr 2017 16:11:10 +0200
Message-ID: <20170411141119.82526-2-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48820 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753139AbdDKOLh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:37 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8nWk048371
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:36 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rkcv256y-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:36 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:34 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a number of layer-independent ioctls that we can handle
in core, and reduce code duplication. For layer-specific ioctls,
add a do_ioctl() discipline hook.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  5 ++--
 drivers/s390/net/qeth_core_main.c | 63 +++++++++++++++++++++++++++++++++++----
 drivers/s390/net/qeth_l2_main.c   | 54 ++-------------------------------
 drivers/s390/net/qeth_l3_main.c   | 41 ++-----------------------
 4 files changed, 64 insertions(+), 99 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index ed5b3582adba..ee4d43f0c149 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -716,6 +716,7 @@ struct qeth_discipline {
 	int (*freeze)(struct ccwgroup_device *);
 	int (*thaw) (struct ccwgroup_device *);
 	int (*restore)(struct ccwgroup_device *);
+	int (*do_ioctl)(struct net_device *dev, struct ifreq *rq, int cmd);
 	int (*control_event_handler)(struct qeth_card *card,
 					struct qeth_ipa_cmd *cmd);
 };
@@ -936,9 +937,6 @@ void qeth_prepare_control_data(struct qeth_card *, int,
 void qeth_release_buffer(struct qeth_channel *, struct qeth_cmd_buffer *);
 void qeth_prepare_ipa_cmd(struct qeth_card *, struct qeth_cmd_buffer *, char);
 struct qeth_cmd_buffer *qeth_wait_for_buffer(struct qeth_channel *);
-int qeth_mdio_read(struct net_device *, int, int);
-int qeth_snmp_command(struct qeth_card *, char __user *);
-int qeth_query_oat_command(struct qeth_card *, char __user *);
 int qeth_query_switch_attributes(struct qeth_card *card,
 				  struct qeth_switch_info *sw_info);
 int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
@@ -956,6 +954,7 @@ int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
 			struct sk_buff *, struct qeth_hdr *, int, int, int);
 int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
 		    struct sk_buff *, struct qeth_hdr *, int);
+int qeth_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 int qeth_core_get_sset_count(struct net_device *, int);
 void qeth_core_get_ethtool_stats(struct net_device *,
 				struct ethtool_stats *, u64 *);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 6b22b05a6953..c9fdf98e5e15 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4417,7 +4417,7 @@ void qeth_tx_timeout(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(qeth_tx_timeout);
 
-int qeth_mdio_read(struct net_device *dev, int phy_id, int regnum)
+static int qeth_mdio_read(struct net_device *dev, int phy_id, int regnum)
 {
 	struct qeth_card *card = dev->ml_priv;
 	int rc = 0;
@@ -4480,7 +4480,6 @@ int qeth_mdio_read(struct net_device *dev, int phy_id, int regnum)
 	}
 	return rc;
 }
-EXPORT_SYMBOL_GPL(qeth_mdio_read);
 
 static int qeth_send_ipa_snmp_cmd(struct qeth_card *card,
 		struct qeth_cmd_buffer *iob, int len,
@@ -4570,7 +4569,7 @@ static int qeth_snmp_command_cb(struct qeth_card *card,
 	return 0;
 }
 
-int qeth_snmp_command(struct qeth_card *card, char __user *udata)
+static int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 {
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
@@ -4630,7 +4629,6 @@ int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 	kfree(qinfo.udata);
 	return rc;
 }
-EXPORT_SYMBOL_GPL(qeth_snmp_command);
 
 static int qeth_setadpparms_query_oat_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
@@ -4662,7 +4660,7 @@ static int qeth_setadpparms_query_oat_cb(struct qeth_card *card,
 	return 0;
 }
 
-int qeth_query_oat_command(struct qeth_card *card, char __user *udata)
+static int qeth_query_oat_command(struct qeth_card *card, char __user *udata)
 {
 	int rc = 0;
 	struct qeth_cmd_buffer *iob;
@@ -4732,7 +4730,6 @@ int qeth_query_oat_command(struct qeth_card *card, char __user *udata)
 out:
 	return rc;
 }
-EXPORT_SYMBOL_GPL(qeth_query_oat_command);
 
 static int qeth_query_card_info_cb(struct qeth_card *card,
 				   struct qeth_reply *reply, unsigned long data)
@@ -5759,6 +5756,60 @@ static const struct attribute_group *qeth_drv_attr_groups[] = {
 	NULL,
 };
 
+int qeth_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct qeth_card *card = dev->ml_priv;
+	struct mii_ioctl_data *mii_data;
+	int rc = 0;
+
+	if (!card)
+		return -ENODEV;
+
+	if (!qeth_card_hw_is_reachable(card))
+		return -ENODEV;
+
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		return -EPERM;
+
+	switch (cmd) {
+	case SIOC_QETH_ADP_SET_SNMP_CONTROL:
+		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
+		break;
+	case SIOC_QETH_GET_CARD_TYPE:
+		if ((card->info.type == QETH_CARD_TYPE_OSD ||
+		     card->info.type == QETH_CARD_TYPE_OSM ||
+		     card->info.type == QETH_CARD_TYPE_OSX) &&
+		    !card->info.guestlan)
+			return 1;
+		else
+			return 0;
+	case SIOCGMIIPHY:
+		mii_data = if_mii(rq);
+		mii_data->phy_id = 0;
+		break;
+	case SIOCGMIIREG:
+		mii_data = if_mii(rq);
+		if (mii_data->phy_id != 0)
+			rc = -EINVAL;
+		else
+			mii_data->val_out = qeth_mdio_read(dev,
+				mii_data->phy_id, mii_data->reg_num);
+		break;
+	case SIOC_QETH_QUERY_OAT:
+		rc = qeth_query_oat_command(card, rq->ifr_ifru.ifru_data);
+		break;
+	default:
+		if (card->discipline->do_ioctl)
+			rc = card->discipline->do_ioctl(dev, rq, cmd);
+		else
+			rc = -EOPNOTSUPP;
+	}
+	if (rc)
+		QETH_CARD_TEXT_(card, 2, "ioce%x", rc);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_do_ioctl);
+
 static struct {
 	const char str[ETH_GSTRING_LEN];
 } qeth_ethtool_stats_keys[] = {
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index cd0ba9e0d3e5..30232076d867 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -16,7 +16,6 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/etherdevice.h>
-#include <linux/mii.h>
 #include <linux/ip.h>
 #include <linux/list.h>
 #include <linux/hash.h>
@@ -34,56 +33,6 @@ static void qeth_bridge_state_change(struct qeth_card *card,
 static void qeth_bridge_host_event(struct qeth_card *card,
 					struct qeth_ipa_cmd *cmd);
 
-static int qeth_l2_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-{
-	struct qeth_card *card = dev->ml_priv;
-	struct mii_ioctl_data *mii_data;
-	int rc = 0;
-
-	if (!card)
-		return -ENODEV;
-
-	if (!qeth_card_hw_is_reachable(card))
-		return -ENODEV;
-
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return -EPERM;
-
-	switch (cmd) {
-	case SIOC_QETH_ADP_SET_SNMP_CONTROL:
-		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
-		break;
-	case SIOC_QETH_GET_CARD_TYPE:
-		if ((card->info.type == QETH_CARD_TYPE_OSD ||
-		     card->info.type == QETH_CARD_TYPE_OSM ||
-		     card->info.type == QETH_CARD_TYPE_OSX) &&
-		    !card->info.guestlan)
-			return 1;
-		return 0;
-		break;
-	case SIOCGMIIPHY:
-		mii_data = if_mii(rq);
-		mii_data->phy_id = 0;
-		break;
-	case SIOCGMIIREG:
-		mii_data = if_mii(rq);
-		if (mii_data->phy_id != 0)
-			rc = -EINVAL;
-		else
-			mii_data->val_out = qeth_mdio_read(dev,
-				mii_data->phy_id, mii_data->reg_num);
-		break;
-	case SIOC_QETH_QUERY_OAT:
-		rc = qeth_query_oat_command(card, rq->ifr_ifru.ifru_data);
-		break;
-	default:
-		rc = -EOPNOTSUPP;
-	}
-	if (rc)
-		QETH_CARD_TEXT_(card, 2, "ioce%d", rc);
-	return rc;
-}
-
 static int qeth_l2_verify_dev(struct net_device *dev)
 {
 	struct qeth_card *card;
@@ -1059,7 +1008,7 @@ static const struct net_device_ops qeth_l2_netdev_ops = {
 	.ndo_start_xmit		= qeth_l2_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= qeth_l2_set_rx_mode,
-	.ndo_do_ioctl	   	= qeth_l2_do_ioctl,
+	.ndo_do_ioctl		= qeth_do_ioctl,
 	.ndo_set_mac_address    = qeth_l2_set_mac_address,
 	.ndo_change_mtu	   	= qeth_change_mtu,
 	.ndo_vlan_rx_add_vid	= qeth_l2_vlan_rx_add_vid,
@@ -1417,6 +1366,7 @@ struct qeth_discipline qeth_l2_discipline = {
 	.freeze = qeth_l2_pm_suspend,
 	.thaw = qeth_l2_pm_resume,
 	.restore = qeth_l2_pm_resume,
+	.do_ioctl = NULL,
 	.control_event_handler = qeth_l2_control_event,
 };
 EXPORT_SYMBOL_GPL(qeth_l2_discipline);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index c29525838b7c..25b6823af1b2 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -16,7 +16,6 @@
 #include <linux/errno.h>
 #include <linux/kernel.h>
 #include <linux/etherdevice.h>
-#include <linux/mii.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
@@ -2457,15 +2456,8 @@ static int qeth_l3_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct qeth_card *card = dev->ml_priv;
 	struct qeth_arp_cache_entry arp_entry;
-	struct mii_ioctl_data *mii_data;
 	int rc = 0;
 
-	if (!card)
-		return -ENODEV;
-
-	if (!qeth_card_hw_is_reachable(card))
-		return -ENODEV;
-
 	switch (cmd) {
 	case SIOC_QETH_ARP_SET_NO_ENTRIES:
 		if (!capable(CAP_NET_ADMIN)) {
@@ -2510,37 +2502,9 @@ static int qeth_l3_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		}
 		rc = qeth_l3_arp_flush_cache(card);
 		break;
-	case SIOC_QETH_ADP_SET_SNMP_CONTROL:
-		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
-		break;
-	case SIOC_QETH_GET_CARD_TYPE:
-		if ((card->info.type == QETH_CARD_TYPE_OSD ||
-		     card->info.type == QETH_CARD_TYPE_OSX) &&
-		    !card->info.guestlan)
-			return 1;
-		return 0;
-		break;
-	case SIOCGMIIPHY:
-		mii_data = if_mii(rq);
-		mii_data->phy_id = 0;
-		break;
-	case SIOCGMIIREG:
-		mii_data = if_mii(rq);
-		if (mii_data->phy_id != 0)
-			rc = -EINVAL;
-		else
-			mii_data->val_out = qeth_mdio_read(dev,
-							mii_data->phy_id,
-							mii_data->reg_num);
-		break;
-	case SIOC_QETH_QUERY_OAT:
-		rc = qeth_query_oat_command(card, rq->ifr_ifru.ifru_data);
-		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-	if (rc)
-		QETH_CARD_TEXT_(card, 2, "ioce%d", rc);
 	return rc;
 }
 
@@ -3056,7 +3020,7 @@ static const struct net_device_ops qeth_l3_netdev_ops = {
 	.ndo_start_xmit		= qeth_l3_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= qeth_l3_set_multicast_list,
-	.ndo_do_ioctl		= qeth_l3_do_ioctl,
+	.ndo_do_ioctl		= qeth_do_ioctl,
 	.ndo_change_mtu		= qeth_change_mtu,
 	.ndo_fix_features	= qeth_fix_features,
 	.ndo_set_features	= qeth_set_features,
@@ -3072,7 +3036,7 @@ static const struct net_device_ops qeth_l3_osa_netdev_ops = {
 	.ndo_start_xmit		= qeth_l3_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= qeth_l3_set_multicast_list,
-	.ndo_do_ioctl		= qeth_l3_do_ioctl,
+	.ndo_do_ioctl		= qeth_do_ioctl,
 	.ndo_change_mtu		= qeth_change_mtu,
 	.ndo_fix_features	= qeth_fix_features,
 	.ndo_set_features	= qeth_set_features,
@@ -3439,6 +3403,7 @@ struct qeth_discipline qeth_l3_discipline = {
 	.freeze = qeth_l3_pm_suspend,
 	.thaw = qeth_l3_pm_resume,
 	.restore = qeth_l3_pm_resume,
+	.do_ioctl = qeth_l3_do_ioctl,
 	.control_event_handler = qeth_l3_control_event,
 };
 EXPORT_SYMBOL_GPL(qeth_l3_discipline);
-- 
2.10.2
