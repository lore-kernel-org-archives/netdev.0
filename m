From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/13] qeth layer 2 and layer 3 common feature handling
Date: Thu, 16 Jun 2016 16:18:59 +0200
Message-ID: <1466086743-55484-10-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:25171 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754545AbcFPOTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:41 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEJ0Lw092874
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:35 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23ktc9ruvr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:35 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:33 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

This patch introduces a common set of fix_features and set_features
functions for layer 2 and layer 3. The RX, TX and TSO offload
functionality on the OSA card is enabled using ethtool at user's
request and not at device initialization as done before.

For layer 3 the RX checksum offloading is disabled at device
initialization time.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |   5 +-
 drivers/s390/net/qeth_core_main.c | 127 ++++++++++++++++++++++++++------------
 drivers/s390/net/qeth_l2_main.c   |  54 ++++------------
 drivers/s390/net/qeth_l3_main.c   | 123 +++---------------------------------
 4 files changed, 111 insertions(+), 198 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index ab0a171..bf40063 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -993,12 +993,13 @@ int qeth_send_setassparms(struct qeth_card *, struct qeth_cmd_buffer *, __u16,
 			  int (*reply_cb)(struct qeth_card *,
 					  struct qeth_reply *, unsigned long),
 			  void *);
+int qeth_setassparms_cb(struct qeth_card *, struct qeth_reply *, unsigned long);
 struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *,
 						 enum qeth_ipa_funcs,
 						 __u16, __u16,
 						 enum qeth_prot_versions);
-int qeth_start_ipa_tx_checksum(struct qeth_card *);
-int qeth_set_rx_csum(struct qeth_card *, int);
+int qeth_set_features(struct net_device *, netdev_features_t);
+netdev_features_t qeth_fix_features(struct net_device *, netdev_features_t);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index ede9ed8..19a6ee0 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5268,8 +5268,8 @@ no_mem:
 }
 EXPORT_SYMBOL_GPL(qeth_core_get_next_skb);
 
-static int qeth_setassparms_cb(struct qeth_card *card,
-			       struct qeth_reply *reply, unsigned long data)
+int qeth_setassparms_cb(struct qeth_card *card,
+			struct qeth_reply *reply, unsigned long data)
 {
 	struct qeth_ipa_cmd *cmd;
 
@@ -5297,6 +5297,7 @@ static int qeth_setassparms_cb(struct qeth_card *card,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(qeth_setassparms_cb);
 
 struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *card,
 						 enum qeth_ipa_funcs ipa_func,
@@ -6053,74 +6054,120 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 }
 EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_settings);
 
-static int qeth_send_checksum_command(struct qeth_card *card)
+static int qeth_send_checksum_on(struct qeth_card *card, int cstype)
 {
+	long rxtx_arg;
 	int rc;
 
-	rc = qeth_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
-					  IPA_CMD_ASS_START, 0);
+	rc = qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_START, 0);
 	if (rc) {
-		dev_warn(&card->gdev->dev, "Starting HW checksumming for %s "
-			"failed, using SW checksumming\n",
-			QETH_CARD_IFNAME(card));
+		dev_warn(&card->gdev->dev,
+			 "Starting HW checksumming for %s failed, using SW checksumming\n",
+			 QETH_CARD_IFNAME(card));
 		return rc;
 	}
-	rc = qeth_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
-					  IPA_CMD_ASS_ENABLE,
-					  card->info.csum_mask);
+	rxtx_arg = (cstype == IPA_OUTBOUND_CHECKSUM) ? card->info.tx_csum_mask
+						     : card->info.csum_mask;
+	rc = qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_ENABLE,
+					  rxtx_arg);
 	if (rc) {
-		dev_warn(&card->gdev->dev, "Enabling HW checksumming for %s "
-			"failed, using SW checksumming\n",
-			QETH_CARD_IFNAME(card));
+		dev_warn(&card->gdev->dev,
+			 "Enabling HW checksumming for %s failed, using SW checksumming\n",
+			 QETH_CARD_IFNAME(card));
 		return rc;
 	}
+
+	dev_info(&card->gdev->dev, "HW Checksumming (%sbound) enabled\n",
+		 cstype == IPA_INBOUND_CHECKSUM ? "in" : "out");
 	return 0;
 }
 
-int qeth_set_rx_csum(struct qeth_card *card, int on)
+static int qeth_set_ipa_csum(struct qeth_card *card, int on, int cstype)
 {
 	int rc;
 
 	if (on) {
-		rc = qeth_send_checksum_command(card);
+		rc = qeth_send_checksum_on(card, cstype);
 		if (rc)
 			return -EIO;
-		dev_info(&card->gdev->dev,
-			"HW Checksumming (inbound) enabled\n");
 	} else {
-		rc = qeth_send_simple_setassparms(card,
-			IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
+		rc = qeth_send_simple_setassparms(card, cstype,
+						  IPA_CMD_ASS_STOP, 0);
 		if (rc)
 			return -EIO;
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(qeth_set_rx_csum);
 
-int qeth_start_ipa_tx_checksum(struct qeth_card *card)
+static int qeth_set_ipa_tso(struct qeth_card *card, int on)
 {
-	int rc = 0;
+	int rc;
 
-	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
-		return rc;
-	rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
-					  IPA_CMD_ASS_START, 0);
-	if (rc)
-		goto err_out;
-	rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
-					  IPA_CMD_ASS_ENABLE,
-					  card->info.tx_csum_mask);
-	if (rc)
-		goto err_out;
+	QETH_CARD_TEXT(card, 3, "sttso");
 
-	dev_info(&card->gdev->dev, "HW TX Checksumming enabled\n");
-	return rc;
-err_out:
-	dev_warn(&card->gdev->dev, "Enabling HW TX checksumming for %s "
-		"failed, using SW TX checksumming\n", QETH_CARD_IFNAME(card));
+	if (on) {
+		rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_TSO,
+						  IPA_CMD_ASS_START, 0);
+		if (rc) {
+			dev_warn(&card->gdev->dev,
+				 "Starting outbound TCP segmentation offload for %s failed\n",
+				 QETH_CARD_IFNAME(card));
+			return -EIO;
+		}
+		dev_info(&card->gdev->dev, "Outbound TSO enabled\n");
+	} else {
+		rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_TSO,
+						  IPA_CMD_ASS_STOP, 0);
+	}
 	return rc;
 }
-EXPORT_SYMBOL_GPL(qeth_start_ipa_tx_checksum);
+
+int qeth_set_features(struct net_device *dev, netdev_features_t features)
+{
+	struct qeth_card *card = dev->ml_priv;
+	netdev_features_t changed = card->dev->features ^ features;
+	int rc = 0;
+
+	QETH_DBF_TEXT(SETUP, 2, "setfeat");
+	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
+
+	if (card->state == CARD_STATE_DOWN ||
+	    card->state == CARD_STATE_RECOVER)
+		return 0;
+
+	if ((changed & NETIF_F_IP_CSUM))
+		rc = qeth_set_ipa_csum(card,
+				       features & NETIF_F_IP_CSUM ? 1 : 0,
+				       IPA_OUTBOUND_CHECKSUM);
+	if ((changed & NETIF_F_RXCSUM))
+		rc |= qeth_set_ipa_csum(card,
+					features & NETIF_F_RXCSUM ? 1 : 0,
+					IPA_INBOUND_CHECKSUM);
+	if ((changed & NETIF_F_TSO))
+		rc |= qeth_set_ipa_tso(card, features & NETIF_F_TSO ? 1 : 0);
+	return rc ? -EIO : 0;
+}
+EXPORT_SYMBOL_GPL(qeth_set_features);
+
+netdev_features_t qeth_fix_features(struct net_device *dev,
+				    netdev_features_t features)
+{
+	struct qeth_card *card = dev->ml_priv;
+
+	QETH_DBF_TEXT(SETUP, 2, "fixfeat");
+	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+		features &= ~NETIF_F_IP_CSUM;
+	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
+		features &= ~NETIF_F_RXCSUM;
+	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
+		features &= ~NETIF_F_TSO;
+		dev_info(&card->gdev->dev, "Outbound TSO not supported on %s\n",
+			 QETH_CARD_IFNAME(card));
+	}
+	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
+	return features;
+}
+EXPORT_SYMBOL_GPL(qeth_fix_features);
 
 static int __init qeth_core_init(void)
 {
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 2a331d1..928a4ad 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -404,38 +404,6 @@ static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev,
 	return rc;
 }
 
-static netdev_features_t qeth_l2_fix_features(struct net_device *dev,
-					      netdev_features_t features)
-{
-	struct qeth_card *card = dev->ml_priv;
-
-	QETH_DBF_TEXT(SETUP, 2, "fixfeat");
-	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
-		features &= ~NETIF_F_IP_CSUM;
-	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
-		features &= ~NETIF_F_RXCSUM;
-	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
-	return features;
-}
-
-static int qeth_l2_set_features(struct net_device *dev,
-				netdev_features_t features)
-{
-	struct qeth_card *card = dev->ml_priv;
-	netdev_features_t changed = dev->features ^ features;
-
-	QETH_DBF_TEXT(SETUP, 2, "setfeat");
-	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
-
-	if (card->state == CARD_STATE_DOWN ||
-	    card->state == CARD_STATE_RECOVER)
-		return 0;
-
-	if (!(changed & NETIF_F_RXCSUM))
-		return 0;
-	return qeth_set_rx_csum(card, features & NETIF_F_RXCSUM ? 1 : 0);
-}
-
 static void qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 {
 	QETH_DBF_TEXT(SETUP , 2, "stopcard");
@@ -1112,8 +1080,8 @@ static const struct net_device_ops qeth_l2_netdev_ops = {
 	.ndo_vlan_rx_add_vid	= qeth_l2_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = qeth_l2_vlan_rx_kill_vid,
 	.ndo_tx_timeout	   	= qeth_tx_timeout,
-	.ndo_fix_features	= qeth_l2_fix_features,
-	.ndo_set_features	= qeth_l2_set_features
+	.ndo_fix_features	= qeth_fix_features,
+	.ndo_set_features	= qeth_set_features
 };
 
 static int qeth_l2_setup_netdev(struct qeth_card *card)
@@ -1144,10 +1112,14 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 		&qeth_l2_ethtool_ops : &qeth_l2_osn_ops;
 	card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	if (card->info.type == QETH_CARD_TYPE_OSD && !card->info.guestlan) {
-		card->dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-					 NETIF_F_SG;
-		/* Turn on RX offloading and SG per default */
-		card->dev->features |= NETIF_F_RXCSUM | NETIF_F_SG;
+		card->dev->hw_features = NETIF_F_SG;
+		/* OSA 3S and earlier has no RX/TX support */
+		if (qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+			card->dev->hw_features |= NETIF_F_IP_CSUM;
+		if (qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
+			card->dev->hw_features |= NETIF_F_RXCSUM;
+		/* Turn on SG per default */
+		card->dev->features |= NETIF_F_SG;
 	}
 	card->info.broadcast_capable = 1;
 	qeth_l2_request_initial_mac(card);
@@ -1165,9 +1137,6 @@ static int qeth_l2_start_ipassists(struct qeth_card *card)
 	/* configure isolation level */
 	if (qeth_set_access_ctrl_online(card, 0))
 		return -ENODEV;
-	if (qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
-		qeth_set_rx_csum(card, 1);
-	qeth_start_ipa_tx_checksum(card);
 	return 0;
 }
 
@@ -1236,7 +1205,8 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 contin:
 	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
 	    (card->info.type == QETH_CARD_TYPE_OSX)) {
-		if (qeth_l2_start_ipassists(card))
+		rc = qeth_l2_start_ipassists(card);
+		if (rc)
 			goto out_remove;
 	}
 
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 6e7d06c..fc81776 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -909,36 +909,6 @@ static int qeth_l3_setadapter_parms(struct qeth_card *card)
 	return rc;
 }
 
-static int qeth_l3_default_setassparms_cb(struct qeth_card *card,
-			struct qeth_reply *reply, unsigned long data)
-{
-	struct qeth_ipa_cmd *cmd;
-
-	QETH_CARD_TEXT(card, 4, "defadpcb");
-
-	cmd = (struct qeth_ipa_cmd *) data;
-	if (cmd->hdr.return_code == 0) {
-		cmd->hdr.return_code = cmd->data.setassparms.hdr.return_code;
-		if (cmd->hdr.prot_version == QETH_PROT_IPV4)
-			card->options.ipa4.enabled_funcs = cmd->hdr.ipa_enabled;
-		if (cmd->hdr.prot_version == QETH_PROT_IPV6)
-			card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
-	}
-	if (cmd->data.setassparms.hdr.assist_no == IPA_INBOUND_CHECKSUM &&
-	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
-		card->info.csum_mask = cmd->data.setassparms.data.flags_32bit;
-		QETH_CARD_TEXT_(card, 3, "csum:%d", card->info.csum_mask);
-	}
-	if (cmd->data.setassparms.hdr.assist_no == IPA_OUTBOUND_CHECKSUM &&
-	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
-		card->info.tx_csum_mask =
-			cmd->data.setassparms.data.flags_32bit;
-		QETH_CARD_TEXT_(card, 3, "tcsu:%d", card->info.tx_csum_mask);
-	}
-
-	return 0;
-}
-
 #ifdef CONFIG_QETH_IPV6
 static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
 		enum qeth_ipa_funcs ipa_func, __u16 cmd_code)
@@ -952,7 +922,7 @@ static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
 	if (!iob)
 		return -ENOMEM;
 	rc = qeth_send_setassparms(card, iob, 0, 0,
-				   qeth_l3_default_setassparms_cb, NULL);
+				   qeth_setassparms_cb, NULL);
 	return rc;
 }
 #endif
@@ -1187,47 +1157,6 @@ out:
 	return rc;
 }
 
-static void qeth_l3_start_ipa_checksum(struct qeth_card *card)
-{
-	QETH_CARD_TEXT(card, 3, "strtcsum");
-	if (qeth_is_supported(card, IPA_INBOUND_CHECKSUM)
-	    && (card->dev->features & NETIF_F_RXCSUM))
-		qeth_set_rx_csum(card, 1);
-}
-
-static void qeth_l3_start_ipa_tx_checksum(struct qeth_card *card)
-{
-	QETH_CARD_TEXT(card, 3, "strttxcs");
-	qeth_start_ipa_tx_checksum(card);
-}
-
-static int qeth_l3_start_ipa_tso(struct qeth_card *card)
-{
-	int rc;
-
-	QETH_CARD_TEXT(card, 3, "sttso");
-
-	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
-		dev_info(&card->gdev->dev,
-			"Outbound TSO not supported on %s\n",
-			QETH_CARD_IFNAME(card));
-		rc = -EOPNOTSUPP;
-	} else {
-		rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_TSO,
-						  IPA_CMD_ASS_START, 0);
-		if (rc)
-			dev_warn(&card->gdev->dev, "Starting outbound TCP "
-				"segmentation offload for %s failed\n",
-				QETH_CARD_IFNAME(card));
-		else
-			dev_info(&card->gdev->dev,
-				"Outbound TSO enabled\n");
-	}
-	if (rc)
-		card->dev->features &= ~NETIF_F_TSO;
-	return rc;
-}
-
 static int qeth_l3_start_ipassists(struct qeth_card *card)
 {
 	QETH_CARD_TEXT(card, 3, "strtipas");
@@ -1241,9 +1170,6 @@ static int qeth_l3_start_ipassists(struct qeth_card *card)
 	qeth_l3_start_ipa_multicast(card);		/* go on*/
 	qeth_l3_start_ipa_ipv6(card);		/* go on*/
 	qeth_l3_start_ipa_broadcast(card);		/* go on*/
-	qeth_l3_start_ipa_checksum(card);		/* go on*/
-	qeth_l3_start_ipa_tx_checksum(card);
-	qeth_l3_start_ipa_tso(card);		/* go on*/
 	return 0;
 }
 
@@ -2440,7 +2366,7 @@ static int qeth_l3_arp_add_entry(struct qeth_card *card,
 	rc = qeth_send_setassparms(card, iob,
 				   sizeof(struct qeth_arp_cache_entry),
 				   (unsigned long) entry,
-				   qeth_l3_default_setassparms_cb, NULL);
+				   qeth_setassparms_cb, NULL);
 	if (rc) {
 		tmp = rc;
 		qeth_l3_ipaddr4_to_string((u8 *)entry->ipaddr, buf);
@@ -2480,7 +2406,7 @@ static int qeth_l3_arp_remove_entry(struct qeth_card *card,
 		return -ENOMEM;
 	rc = qeth_send_setassparms(card, iob,
 				   12, (unsigned long)buf,
-				   qeth_l3_default_setassparms_cb, NULL);
+				   qeth_setassparms_cb, NULL);
 	if (rc) {
 		tmp = rc;
 		memset(buf, 0, 16);
@@ -2826,7 +2752,7 @@ static int qeth_l3_get_elements_no_tso(struct qeth_card *card,
 	int elements = qeth_get_elements_for_range(
 				tcpdptr,
 				(addr_t)skb->data + skb_headlen(skb)) +
-		qeth_get_elements_for_frags(skb);
+				qeth_get_elements_for_frags(skb);
 
 	if ((elements + extra_elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
 		QETH_DBF_MESSAGE(2,
@@ -3089,36 +3015,6 @@ static int qeth_l3_stop(struct net_device *dev)
 	return 0;
 }
 
-static netdev_features_t qeth_l3_fix_features(struct net_device *dev,
-	netdev_features_t features)
-{
-	struct qeth_card *card = dev->ml_priv;
-
-	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
-		features &= ~NETIF_F_IP_CSUM;
-	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO))
-		features &= ~NETIF_F_TSO;
-	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
-		features &= ~NETIF_F_RXCSUM;
-	return features;
-}
-
-static int qeth_l3_set_features(struct net_device *dev,
-	netdev_features_t features)
-{
-	struct qeth_card *card = dev->ml_priv;
-	netdev_features_t changed = dev->features ^ features;
-
-	if (!(changed & NETIF_F_RXCSUM))
-		return 0;
-
-	if (card->state == CARD_STATE_DOWN ||
-	    card->state == CARD_STATE_RECOVER)
-		return 0;
-
-	return qeth_set_rx_csum(card, features & NETIF_F_RXCSUM ? 1 : 0);
-}
-
 static const struct ethtool_ops qeth_l3_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_strings = qeth_core_get_strings,
@@ -3161,8 +3057,8 @@ static const struct net_device_ops qeth_l3_netdev_ops = {
 	.ndo_set_rx_mode	= qeth_l3_set_multicast_list,
 	.ndo_do_ioctl		= qeth_l3_do_ioctl,
 	.ndo_change_mtu		= qeth_change_mtu,
-	.ndo_fix_features	= qeth_l3_fix_features,
-	.ndo_set_features	= qeth_l3_set_features,
+	.ndo_fix_features	= qeth_fix_features,
+	.ndo_set_features	= qeth_set_features,
 	.ndo_vlan_rx_add_vid	= qeth_l3_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = qeth_l3_vlan_rx_kill_vid,
 	.ndo_tx_timeout		= qeth_tx_timeout,
@@ -3177,8 +3073,8 @@ static const struct net_device_ops qeth_l3_osa_netdev_ops = {
 	.ndo_set_rx_mode	= qeth_l3_set_multicast_list,
 	.ndo_do_ioctl		= qeth_l3_do_ioctl,
 	.ndo_change_mtu		= qeth_change_mtu,
-	.ndo_fix_features	= qeth_l3_fix_features,
-	.ndo_set_features	= qeth_l3_set_features,
+	.ndo_fix_features	= qeth_fix_features,
+	.ndo_set_features	= qeth_set_features,
 	.ndo_vlan_rx_add_vid	= qeth_l3_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = qeth_l3_vlan_rx_kill_vid,
 	.ndo_tx_timeout		= qeth_tx_timeout,
@@ -3210,8 +3106,7 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 				card->dev->hw_features = NETIF_F_SG |
 					NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
 					NETIF_F_TSO;
-				card->dev->features = NETIF_F_RXCSUM |
-						      NETIF_F_SG;
+				card->dev->features = NETIF_F_SG;
 			}
 		}
 	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
-- 
2.6.6
