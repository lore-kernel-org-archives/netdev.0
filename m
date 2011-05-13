From: frank.blaschka@de.ibm.com
Subject: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Fri, 13 May 2011 06:45:01 +0200
Message-ID: <20110513044547.424857838@de.ibm.com>
References: <20110513044500.190198403@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:53548 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab1EMEpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 00:45:51 -0400
Content-Disposition: inline; filename=qeth_hw_feat2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Set rx csum default to hw checksumming again.
Remove sysfs interface for rx csum (checksumming) and TSO (large_send).
With the new hw_features it does not work to keep the old sysfs
interface in parallel. Convert options.checksum_type to new hw_features.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |    1 
 drivers/s390/net/qeth_core_mpc.h  |    8 --
 drivers/s390/net/qeth_l2_main.c   |    5 -
 drivers/s390/net/qeth_l3.h        |    2 
 drivers/s390/net/qeth_l3_main.c   |  104 +++++++++++++++++--------------------
 drivers/s390/net/qeth_l3_sys.c    |  106 --------------------------------------
 7 files changed, 49 insertions(+), 178 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -639,7 +639,6 @@ struct qeth_card_options {
 	struct qeth_ipa_info adp; /*Adapter parameters*/
 	struct qeth_routing_info route6;
 	struct qeth_ipa_info ipa6;
-	enum qeth_checksum_types checksum_type;
 	int broadcast_mode;
 	int macaddr_mode;
 	int fake_broadcast;
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1039,7 +1039,6 @@ static void qeth_set_intial_options(stru
 {
 	card->options.route4.type = NO_ROUTER;
 	card->options.route6.type = NO_ROUTER;
-	card->options.checksum_type = QETH_CHECKSUM_DEFAULT;
 	card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
 	card->options.macaddr_mode = QETH_TR_MACADDR_NONCANONICAL;
 	card->options.fake_broadcast = 0;
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -80,14 +80,6 @@ enum qeth_tr_broadcast_modes {
 	QETH_TR_BROADCAST_LOCAL    = 1,
 };
 
-/* these values match CHECKSUM_* in include/linux/skbuff.h */
-enum qeth_checksum_types {
-	SW_CHECKSUMMING = 0, /* TODO: set to bit flag used in IPA Command */
-	HW_CHECKSUMMING = 1,
-	NO_CHECKSUMMING = 2,
-};
-#define QETH_CHECKSUM_DEFAULT SW_CHECKSUMMING
-
 /*
  * Routing stuff
  */
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -420,10 +420,7 @@ static int qeth_l2_process_inbound_buffe
 		case QETH_HEADER_TYPE_LAYER2:
 			skb->pkt_type = PACKET_HOST;
 			skb->protocol = eth_type_trans(skb, skb->dev);
-			if (card->options.checksum_type == NO_CHECKSUMMING)
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			else
-				skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = CHECKSUM_NONE;
 			if (skb->protocol == htons(ETH_P_802_2))
 				*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
 			len = skb->len;
--- a/drivers/s390/net/qeth_l3.h
+++ b/drivers/s390/net/qeth_l3.h
@@ -62,8 +62,6 @@ void qeth_l3_del_vipa(struct qeth_card *
 int qeth_l3_add_rxip(struct qeth_card *, enum qeth_prot_versions, const u8 *);
 void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions,
 			const u8 *);
-int qeth_l3_set_large_send(struct qeth_card *, enum qeth_large_send_types);
-int qeth_l3_set_rx_csum(struct qeth_card *, enum qeth_checksum_types);
 int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *, struct qeth_ipaddr *);
 
 #endif /* __QETH_L3_H__ */
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1445,34 +1445,30 @@ static int qeth_l3_send_checksum_command
 	return 0;
 }
 
-int qeth_l3_set_rx_csum(struct qeth_card *card,
-	enum qeth_checksum_types csum_type)
+int qeth_l3_set_rx_csum(struct qeth_card *card, int on)
 {
 	int rc = 0;
 
-	if (card->options.checksum_type == HW_CHECKSUMMING) {
-		if ((csum_type != HW_CHECKSUMMING) &&
-			(card->state != CARD_STATE_DOWN)) {
-			rc = qeth_l3_send_simple_setassparms(card,
-				IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
+	if (on) {
+		if (card->state != CARD_STATE_DOWN) {
+			if (!qeth_is_supported(card,
+				    IPA_INBOUND_CHECKSUM))
+					return -EPERM;
+			rc = qeth_l3_send_checksum_command(card);
 			if (rc)
 				return -EIO;
 		}
 		card->dev->features |= NETIF_F_RXCSUM;
 	} else {
-		if (csum_type == HW_CHECKSUMMING) {
-			if (card->state != CARD_STATE_DOWN) {
-				if (!qeth_is_supported(card,
-				    IPA_INBOUND_CHECKSUM))
-					return -EPERM;
-				rc = qeth_l3_send_checksum_command(card);
-				if (rc)
-					return -EIO;
-			}
+		if (card->state != CARD_STATE_DOWN) {
+			rc = qeth_l3_send_simple_setassparms(card,
+				IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
+			if (rc)
+				return -EIO;
 		}
 		card->dev->features &= ~NETIF_F_RXCSUM;
 	}
-	card->options.checksum_type = csum_type;
+
 	return rc;
 }
 
@@ -1482,32 +1478,34 @@ static int qeth_l3_start_ipa_checksum(st
 
 	QETH_CARD_TEXT(card, 3, "strtcsum");
 
-	if (card->options.checksum_type == NO_CHECKSUMMING) {
-		dev_info(&card->gdev->dev,
-			"Using no checksumming on %s.\n",
-			QETH_CARD_IFNAME(card));
-		return 0;
-	}
-	if (card->options.checksum_type == SW_CHECKSUMMING) {
-		dev_info(&card->gdev->dev,
-			"Using SW checksumming on %s.\n",
-			QETH_CARD_IFNAME(card));
-		return 0;
-	}
-	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM)) {
-		dev_info(&card->gdev->dev,
+	if (card->dev->features & NETIF_F_RXCSUM) {
+		/* hw may have changed during offline or recovery */
+		if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM)) {
+			dev_info(&card->gdev->dev,
 			"Inbound HW Checksumming not "
 			"supported on %s,\ncontinuing "
 			"using Inbound SW Checksumming\n",
 			QETH_CARD_IFNAME(card));
-		card->options.checksum_type = SW_CHECKSUMMING;
-		return 0;
-	}
-	rc = qeth_l3_send_checksum_command(card);
-	if (!rc)
-		dev_info(&card->gdev->dev,
+			goto update_feature;
+		}
+
+		rc = qeth_l3_send_checksum_command(card);
+		if (!rc)
+			dev_info(&card->gdev->dev,
 			"HW Checksumming (inbound) enabled\n");
+		else
+			goto update_feature;
+	} else
+		dev_info(&card->gdev->dev,
+			"Using SW checksumming on %s.\n",
+			QETH_CARD_IFNAME(card));
+	return 0;
 
+update_feature:
+	rtnl_lock();
+	card->dev->features &= ~NETIF_F_RXCSUM;
+	netdev_update_features(card->dev);
+	rtnl_unlock();
 	return rc;
 }
 
@@ -2037,14 +2035,7 @@ static inline int qeth_l3_rebuild_skb(st
 		is_vlan = 1;
 	}
 
-	switch (card->options.checksum_type) {
-	case SW_CHECKSUMMING:
-		skb->ip_summed = CHECKSUM_NONE;
-		break;
-	case NO_CHECKSUMMING:
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		break;
-	case HW_CHECKSUMMING:
+	if (card->dev->features & NETIF_F_RXCSUM) {
 		if ((hdr->hdr.l3.ext_flags &
 		    (QETH_HDR_EXT_CSUM_HDR_REQ |
 		     QETH_HDR_EXT_CSUM_TRANSP_REQ)) ==
@@ -2053,7 +2044,8 @@ static inline int qeth_l3_rebuild_skb(st
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
 			skb->ip_summed = CHECKSUM_NONE;
-	}
+	} else
+		skb->ip_summed = CHECKSUM_NONE;
 
 	return is_vlan;
 }
@@ -3235,20 +3227,19 @@ static u32 qeth_l3_fix_features(struct n
 
 static int qeth_l3_set_features(struct net_device *dev, u32 features)
 {
-	enum qeth_checksum_types csum_type;
 	struct qeth_card *card = dev->ml_priv;
 	u32 changed = dev->features ^ features;
+	int on;
 
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
 
 	if (features & NETIF_F_RXCSUM)
-		csum_type = HW_CHECKSUMMING;
+		on = 1;
 	else
-		csum_type = SW_CHECKSUMMING;
+		on = 0;
 
-	dev->features = features ^ NETIF_F_RXCSUM;
-	return qeth_l3_set_rx_csum(card, csum_type);
+	return qeth_l3_set_rx_csum(card, on);
 }
 
 static const struct ethtool_ops qeth_l3_ethtool_ops = {
@@ -3342,6 +3333,12 @@ static int qeth_l3_setup_netdev(struct q
 			if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
 				card->dev->dev_id = card->info.unique_id &
 							 0xffff;
+			if (!card->info.guestlan) {
+				card->dev->hw_features = NETIF_F_SG |
+					NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+					NETIF_F_TSO;
+				card->dev->features = NETIF_F_RXCSUM;
+			}
 		}
 	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
 		card->dev = alloc_netdev(0, "hsi%d", ether_setup);
@@ -3357,8 +3354,6 @@ static int qeth_l3_setup_netdev(struct q
 	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
 	card->dev->mtu = card->info.initial_mtu;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
-	card->dev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
-		NETIF_F_IP_CSUM | NETIF_F_TSO;
 	card->dev->features |=	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |
 				NETIF_F_HW_VLAN_FILTER;
@@ -3382,9 +3377,6 @@ static int qeth_l3_probe_device(struct c
 	card->discipline.output_handler = (qdio_handler_t *)
 		qeth_qdio_output_handler;
 	card->discipline.recover = qeth_l3_recover;
-	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
-	    (card->info.type == QETH_CARD_TYPE_OSX))
-		card->options.checksum_type = HW_CHECKSUMMING;
 	return 0;
 }
 
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -15,16 +15,6 @@
 #define QETH_DEVICE_ATTR(_id, _name, _mode, _show, _store) \
 struct device_attribute dev_attr_##_id = __ATTR(_name, _mode, _show, _store)
 
-static const char *qeth_l3_get_checksum_str(struct qeth_card *card)
-{
-	if (card->options.checksum_type == SW_CHECKSUMMING)
-		return "sw";
-	else if (card->options.checksum_type == HW_CHECKSUMMING)
-		return "hw";
-	else
-		return "no";
-}
-
 static ssize_t qeth_l3_dev_route_show(struct qeth_card *card,
 			struct qeth_routing_info *route, char *buf)
 {
@@ -295,51 +285,6 @@ out:
 static DEVICE_ATTR(canonical_macaddr, 0644, qeth_l3_dev_canonical_macaddr_show,
 		   qeth_l3_dev_canonical_macaddr_store);
 
-static ssize_t qeth_l3_dev_checksum_show(struct device *dev,
-			struct device_attribute *attr, char *buf)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-
-	if (!card)
-		return -EINVAL;
-
-	return sprintf(buf, "%s checksumming\n",
-			qeth_l3_get_checksum_str(card));
-}
-
-static ssize_t qeth_l3_dev_checksum_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t count)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-	enum qeth_checksum_types csum_type;
-	char *tmp;
-	int rc = 0;
-
-	if (!card)
-		return -EINVAL;
-
-	mutex_lock(&card->conf_mutex);
-	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "sw_checksumming"))
-		csum_type = SW_CHECKSUMMING;
-	else if (!strcmp(tmp, "hw_checksumming"))
-		csum_type = HW_CHECKSUMMING;
-	else if (!strcmp(tmp, "no_checksumming"))
-		csum_type = NO_CHECKSUMMING;
-	else {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	rc = qeth_l3_set_rx_csum(card, csum_type);
-out:
-	mutex_unlock(&card->conf_mutex);
-	return rc ? rc : count;
-}
-
-static DEVICE_ATTR(checksumming, 0644, qeth_l3_dev_checksum_show,
-		qeth_l3_dev_checksum_store);
-
 static ssize_t qeth_l3_dev_sniffer_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -402,64 +347,13 @@ out:
 static DEVICE_ATTR(sniffer, 0644, qeth_l3_dev_sniffer_show,
 		qeth_l3_dev_sniffer_store);
 
-static ssize_t qeth_l3_dev_large_send_show(struct device *dev,
-				struct device_attribute *attr, char *buf)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-
-	if (!card)
-		return -EINVAL;
-
-	if (!(card->dev->features & NETIF_F_TSO))
-		return sprintf(buf, "%s\n", "no");
-	else
-		return sprintf(buf, "%s\n", "TSO");
-}
-
-static ssize_t qeth_l3_dev_large_send_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t count)
-{
-	struct qeth_card *card;
-	char *tmp;
-	int enable;
-
-	if (!card)
-		return -EINVAL;
-	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "no"))
-		enable = 0;
-	else if (!strcmp(tmp, "TSO"))
-		enable = 1;
-	else
-		return -EINVAL;
-
-	rtnl_lock();
-
-	card = dev_get_drvdata(dev);
-
-	if (enable)
-		card->dev->wanted_features |= NETIF_F_TSO;
-	else
-		card->dev->wanted_features &= ~NETIF_F_TSO;
-	netdev_update_features(card->dev);
-
-	rtnl_unlock();
-
-	return count;
-}
-
-static DEVICE_ATTR(large_send, 0644, qeth_l3_dev_large_send_show,
-		   qeth_l3_dev_large_send_store);
-
 static struct attribute *qeth_l3_device_attrs[] = {
 	&dev_attr_route4.attr,
 	&dev_attr_route6.attr,
 	&dev_attr_fake_broadcast.attr,
 	&dev_attr_broadcast_mode.attr,
 	&dev_attr_canonical_macaddr.attr,
-	&dev_attr_checksumming.attr,
 	&dev_attr_sniffer.attr,
-	&dev_attr_large_send.attr,
 	NULL,
 };
 

