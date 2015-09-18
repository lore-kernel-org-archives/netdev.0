From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 4/5] qeth: add layer 2 RX/TX checksum offloading
Date: Fri, 18 Sep 2015 16:06:51 +0200
Message-ID: <1442585212-58347-5-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Thomas Richter <tmricht@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp05.uk.ibm.com ([195.75.94.101]:50580 "EHLO
	e06smtp05.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbbIROHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 10:07:06 -0400
Received: from /spool/local
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 18 Sep 2015 15:07:04 +0100
In-Reply-To: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

Checksum offloading for send and receive is already
supported for layer 3 (IP layer). This patch
adds support for RX and TX hardware checksum offloading
for layer 2 (MAC layer). The hardware calculates the checksum
for IP UDP and TCP packets.

This patch moves the hardware checksum offloading setup
to the set of common functions in qeth_core_main.c.
Layer 2 and layer 3 now simply call the same common functions.

Also note that TX checksum offloading is always enabled.
The device driver relies on the TCP/IP stack to make use of
this feature.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reviewed-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
---
 drivers/s390/net/qeth_core.h      |   9 ++
 drivers/s390/net/qeth_core_main.c | 178 ++++++++++++++++++++++++++++++++++++--
 drivers/s390/net/qeth_l2_main.c   |  87 +++++++++++++++++--
 drivers/s390/net/qeth_l3_main.c   | 158 ++++++---------------------------
 4 files changed, 285 insertions(+), 147 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 283d6e6..6719447d 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -967,6 +967,15 @@ int qeth_hw_trap(struct qeth_card *, enum qeth_diags_trap_action);
 int qeth_query_ipassists(struct qeth_card *, enum qeth_prot_versions prot);
 void qeth_trace_features(struct qeth_card *);
 void qeth_close_dev(struct qeth_card *);
+int qeth_send_simple_setassparms(struct qeth_card *, enum qeth_ipa_funcs,
+				 __u16, long);
+int qeth_send_setassparms(struct qeth_card *, struct qeth_cmd_buffer *, __u16,
+			  long,
+			  int (*reply_cb)(struct qeth_card *,
+					  struct qeth_reply *, unsigned long),
+			  void *);
+int qeth_start_ipa_tx_checksum(struct qeth_card *);
+int qeth_set_rx_csum(struct qeth_card *, int);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index cd39a02..31ac53f 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4978,13 +4978,11 @@ static void qeth_core_free_card(struct qeth_card *card)
 void qeth_trace_features(struct qeth_card *card)
 {
 	QETH_CARD_TEXT(card, 2, "features");
-	QETH_CARD_TEXT_(card, 2, "%x", card->options.ipa4.supported_funcs);
-	QETH_CARD_TEXT_(card, 2, "%x", card->options.ipa4.enabled_funcs);
-	QETH_CARD_TEXT_(card, 2, "%x", card->options.ipa6.supported_funcs);
-	QETH_CARD_TEXT_(card, 2, "%x", card->options.ipa6.enabled_funcs);
-	QETH_CARD_TEXT_(card, 2, "%x", card->options.adp.supported_funcs);
-	QETH_CARD_TEXT_(card, 2, "%x", card->options.adp.enabled_funcs);
-	QETH_CARD_TEXT_(card, 2, "%x", card->info.diagass_support);
+	QETH_CARD_HEX(card, 2, &card->options.ipa4, sizeof(card->options.ipa4));
+	QETH_CARD_HEX(card, 2, &card->options.ipa6, sizeof(card->options.ipa6));
+	QETH_CARD_HEX(card, 2, &card->options.adp, sizeof(card->options.adp));
+	QETH_CARD_HEX(card, 2, &card->info.diagass_support,
+		      sizeof(card->info.diagass_support));
 }
 EXPORT_SYMBOL_GPL(qeth_trace_features);
 
@@ -5083,6 +5081,7 @@ retriable:
 	}
 
 	card->options.ipa4.supported_funcs = 0;
+	card->options.ipa6.supported_funcs = 0;
 	card->options.adp.supported_funcs = 0;
 	card->options.sbp.supported_funcs = 0;
 	card->info.diagass_support = 0;
@@ -5268,6 +5267,102 @@ no_mem:
 }
 EXPORT_SYMBOL_GPL(qeth_core_get_next_skb);
 
+static int qeth_setassparms_cb(struct qeth_card *card,
+			       struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_CARD_TEXT(card, 4, "defadpcb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code == 0) {
+		cmd->hdr.return_code = cmd->data.setassparms.hdr.return_code;
+		if (cmd->hdr.prot_version == QETH_PROT_IPV4)
+			card->options.ipa4.enabled_funcs = cmd->hdr.ipa_enabled;
+		if (cmd->hdr.prot_version == QETH_PROT_IPV6)
+			card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
+	}
+	if (cmd->data.setassparms.hdr.assist_no == IPA_INBOUND_CHECKSUM &&
+	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
+		card->info.csum_mask = cmd->data.setassparms.data.flags_32bit;
+		QETH_CARD_TEXT_(card, 3, "csum:%d", card->info.csum_mask);
+	}
+	if (cmd->data.setassparms.hdr.assist_no == IPA_OUTBOUND_CHECKSUM &&
+	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
+		card->info.tx_csum_mask =
+			cmd->data.setassparms.data.flags_32bit;
+		QETH_CARD_TEXT_(card, 3, "tcsu:%d", card->info.tx_csum_mask);
+	}
+
+	return 0;
+}
+
+static struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *card,
+						  enum qeth_ipa_funcs ipa_func,
+						  __u16 cmd_code, __u16 len,
+						  enum qeth_prot_versions prot)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_CARD_TEXT(card, 4, "getasscm");
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETASSPARMS, prot);
+
+	if (iob) {
+		cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+		cmd->data.setassparms.hdr.assist_no = ipa_func;
+		cmd->data.setassparms.hdr.length = 8 + len;
+		cmd->data.setassparms.hdr.command_code = cmd_code;
+		cmd->data.setassparms.hdr.return_code = 0;
+		cmd->data.setassparms.hdr.seq_no = 0;
+	}
+
+	return iob;
+}
+
+int qeth_send_setassparms(struct qeth_card *card,
+			  struct qeth_cmd_buffer *iob, __u16 len, long data,
+			  int (*reply_cb)(struct qeth_card *,
+					  struct qeth_reply *, unsigned long),
+			  void *reply_param)
+{
+	int rc;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_CARD_TEXT(card, 4, "sendassp");
+
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	if (len <= sizeof(__u32))
+		cmd->data.setassparms.data.flags_32bit = (__u32) data;
+	else   /* (len > sizeof(__u32)) */
+		memcpy(&cmd->data.setassparms.data, (void *) data, len);
+
+	rc = qeth_send_ipa_cmd(card, iob, reply_cb, reply_param);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_send_setassparms);
+
+int qeth_send_simple_setassparms(struct qeth_card *card,
+				 enum qeth_ipa_funcs ipa_func,
+				 __u16 cmd_code, long data)
+{
+	int rc;
+	int length = 0;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_CARD_TEXT(card, 4, "simassp4");
+	if (data)
+		length = sizeof(__u32);
+	iob = qeth_get_setassparms_cmd(card, ipa_func, cmd_code,
+				       length, QETH_PROT_IPV4);
+	if (!iob)
+		return -ENOMEM;
+	rc = qeth_send_setassparms(card, iob, length, data,
+				   qeth_setassparms_cb, NULL);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_send_simple_setassparms);
+
 static void qeth_unregister_dbf_views(void)
 {
 	int x;
@@ -5954,6 +6049,75 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 }
 EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_settings);
 
+static int qeth_send_checksum_command(struct qeth_card *card)
+{
+	int rc;
+
+	rc = qeth_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
+					  IPA_CMD_ASS_START, 0);
+	if (rc) {
+		dev_warn(&card->gdev->dev, "Starting HW checksumming for %s "
+			"failed, using SW checksumming\n",
+			QETH_CARD_IFNAME(card));
+		return rc;
+	}
+	rc = qeth_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
+					  IPA_CMD_ASS_ENABLE,
+					  card->info.csum_mask);
+	if (rc) {
+		dev_warn(&card->gdev->dev, "Enabling HW checksumming for %s "
+			"failed, using SW checksumming\n",
+			QETH_CARD_IFNAME(card));
+		return rc;
+	}
+	return 0;
+}
+
+int qeth_set_rx_csum(struct qeth_card *card, int on)
+{
+	int rc;
+
+	if (on) {
+		rc = qeth_send_checksum_command(card);
+		if (rc)
+			return -EIO;
+		dev_info(&card->gdev->dev,
+			"HW Checksumming (inbound) enabled\n");
+	} else {
+		rc = qeth_send_simple_setassparms(card,
+			IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
+		if (rc)
+			return -EIO;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_set_rx_csum);
+
+int qeth_start_ipa_tx_checksum(struct qeth_card *card)
+{
+	int rc = 0;
+
+	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+		return rc;
+	rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
+					  IPA_CMD_ASS_START, 0);
+	if (rc)
+		goto err_out;
+	rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
+					  IPA_CMD_ASS_ENABLE,
+					  card->info.tx_csum_mask);
+	if (rc)
+		goto err_out;
+
+	dev_info(&card->gdev->dev, "HW TX Checksumming enabled\n");
+	return rc;
+err_out:
+	dev_warn(&card->gdev->dev, "Enabling HW TX checksumming for %s "
+		"failed, using SW TX checksumming\n", QETH_CARD_IFNAME(card));
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_start_ipa_tx_checksum);
+
 static int __init qeth_core_init(void)
 {
 	int rc;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index a4e3652..dc905b3 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -252,6 +252,23 @@ static inline int qeth_l2_get_cast_type(struct qeth_card *card,
 	return RTN_UNSPEC;
 }
 
+static inline void qeth_l2_hdr_csum(struct qeth_card *card,
+				    struct qeth_hdr *hdr, struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	/* tcph->check contains already the pseudo hdr checksum
+	 * so just set the header flags
+	 */
+	if (iph->protocol == IPPROTO_UDP)
+		hdr->hdr.l2.flags[1] |= QETH_HDR_EXT_UDP;
+	hdr->hdr.l2.flags[1] |= QETH_HDR_EXT_CSUM_TRANSP_REQ |
+		QETH_HDR_EXT_CSUM_HDR_REQ;
+	iph->check = 0;
+	if (card->options.performance_stats)
+		card->perf_stats.tx_csum++;
+}
+
 static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 			struct sk_buff *skb, int cast_type)
 {
@@ -390,6 +407,38 @@ static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev,
 	return rc;
 }
 
+static netdev_features_t qeth_l2_fix_features(struct net_device *dev,
+					      netdev_features_t features)
+{
+	struct qeth_card *card = dev->ml_priv;
+
+	QETH_DBF_TEXT(SETUP, 2, "fixfeat");
+	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+		features &= ~NETIF_F_IP_CSUM;
+	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
+		features &= ~NETIF_F_RXCSUM;
+	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
+	return features;
+}
+
+static int qeth_l2_set_features(struct net_device *dev,
+				netdev_features_t features)
+{
+	struct qeth_card *card = dev->ml_priv;
+	netdev_features_t changed = dev->features ^ features;
+
+	QETH_DBF_TEXT(SETUP, 2, "setfeat");
+	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
+
+	if (card->state == CARD_STATE_DOWN ||
+	    card->state == CARD_STATE_RECOVER)
+		return 0;
+
+	if (!(changed & NETIF_F_RXCSUM))
+		return 0;
+	return qeth_set_rx_csum(card, features & NETIF_F_RXCSUM ? 1 : 0);
+}
+
 static void qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 {
 	QETH_DBF_TEXT(SETUP , 2, "stopcard");
@@ -450,7 +499,15 @@ static int qeth_l2_process_inbound_buffer(struct qeth_card *card,
 		case QETH_HEADER_TYPE_LAYER2:
 			skb->pkt_type = PACKET_HOST;
 			skb->protocol = eth_type_trans(skb, skb->dev);
-			skb->ip_summed = CHECKSUM_NONE;
+			if ((card->dev->features & NETIF_F_RXCSUM)
+			   && ((hdr->hdr.l2.flags[1] &
+				(QETH_HDR_EXT_CSUM_HDR_REQ |
+				   QETH_HDR_EXT_CSUM_TRANSP_REQ)) ==
+				(QETH_HDR_EXT_CSUM_HDR_REQ |
+				   QETH_HDR_EXT_CSUM_TRANSP_REQ)))
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				skb->ip_summed = CHECKSUM_NONE;
 			if (skb->protocol == htons(ETH_P_802_2))
 				*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
 			len = skb->len;
@@ -803,6 +860,8 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						sizeof(struct qeth_hdr));
 			skb_set_mac_header(new_skb, sizeof(struct qeth_hdr));
 			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
+			if (new_skb->ip_summed == CHECKSUM_PARTIAL)
+				qeth_l2_hdr_csum(card, hdr, new_skb);
 		}
 	}
 
@@ -968,6 +1027,8 @@ static const struct net_device_ops qeth_l2_netdev_ops = {
 	.ndo_vlan_rx_add_vid	= qeth_l2_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = qeth_l2_vlan_rx_kill_vid,
 	.ndo_tx_timeout	   	= qeth_tx_timeout,
+	.ndo_fix_features	= qeth_l2_fix_features,
+	.ndo_set_features	= qeth_l2_set_features
 };
 
 static int qeth_l2_setup_netdev(struct qeth_card *card)
@@ -997,6 +1058,11 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 		(card->info.type != QETH_CARD_TYPE_OSN) ?
 		&qeth_l2_ethtool_ops : &qeth_l2_osn_ops;
 	card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+	if (card->info.type == QETH_CARD_TYPE_OSD && !card->info.guestlan) {
+		card->dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
+		/* Turn on RX offloading per default */
+		card->dev->features |= NETIF_F_RXCSUM;
+	}
 	card->info.broadcast_capable = 1;
 	qeth_l2_request_initial_mac(card);
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
@@ -1004,6 +1070,17 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	return register_netdev(card->dev);
 }
 
+static int qeth_l2_start_ipassists(struct qeth_card *card)
+{
+	/* configure isolation level */
+	if (qeth_set_access_ctrl_online(card, 0))
+		return -ENODEV;
+	if (qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
+		qeth_set_rx_csum(card, 1);
+	qeth_start_ipa_tx_checksum(card);
+	return 0;
+}
+
 static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
@@ -1069,12 +1146,8 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 contin:
 	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
 	    (card->info.type == QETH_CARD_TYPE_OSX)) {
-		/* configure isolation level */
-		rc = qeth_set_access_ctrl_online(card, 0);
-		if (rc) {
-			rc = -ENODEV;
+		if (qeth_l2_start_ipassists(card))
 			goto out_remove;
-		}
 	}
 
 	if (card->info.type != QETH_CARD_TYPE_OSN &&
@@ -1453,7 +1526,7 @@ static void qeth_bridge_emit_host_event(struct qeth_card *card,
 		}
 		if (code & IPA_ADDR_CHANGE_CODE_MACADDR) {
 			snprintf(str[i], sizeof(str[i]), "MAC=%pM",
-				 addr_lnid->mac);
+				addr_lnid->mac);
 			env[i] = str[i]; i++;
 		}
 		snprintf(str[i], sizeof(str[i]), "NTOK_BUSID=%x.%x.%04x",
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index a1aaa36..543960e 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1065,27 +1065,6 @@ static struct qeth_cmd_buffer *qeth_l3_get_setassparms_cmd(
 	return iob;
 }
 
-static int qeth_l3_send_setassparms(struct qeth_card *card,
-	struct qeth_cmd_buffer *iob, __u16 len, long data,
-	int (*reply_cb)(struct qeth_card *, struct qeth_reply *,
-		unsigned long),
-	void *reply_param)
-{
-	int rc;
-	struct qeth_ipa_cmd *cmd;
-
-	QETH_CARD_TEXT(card, 4, "sendassp");
-
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	if (len <= sizeof(__u32))
-		cmd->data.setassparms.data.flags_32bit = (__u32) data;
-	else   /* (len > sizeof(__u32)) */
-		memcpy(&cmd->data.setassparms.data, (void *) data, len);
-
-	rc = qeth_send_ipa_cmd(card, iob, reply_cb, reply_param);
-	return rc;
-}
-
 #ifdef CONFIG_QETH_IPV6
 static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
 		enum qeth_ipa_funcs ipa_func, __u16 cmd_code)
@@ -1098,31 +1077,12 @@ static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
 				       0, QETH_PROT_IPV6);
 	if (!iob)
 		return -ENOMEM;
-	rc = qeth_l3_send_setassparms(card, iob, 0, 0,
+	rc = qeth_send_setassparms(card, iob, 0, 0,
 				   qeth_l3_default_setassparms_cb, NULL);
 	return rc;
 }
 #endif
 
-static int qeth_l3_send_simple_setassparms(struct qeth_card *card,
-		enum qeth_ipa_funcs ipa_func, __u16 cmd_code, long data)
-{
-	int rc;
-	int length = 0;
-	struct qeth_cmd_buffer *iob;
-
-	QETH_CARD_TEXT(card, 4, "simassp4");
-	if (data)
-		length = sizeof(__u32);
-	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
-				       length, QETH_PROT_IPV4);
-	if (!iob)
-		return -ENOMEM;
-	rc = qeth_l3_send_setassparms(card, iob, length, data,
-				   qeth_l3_default_setassparms_cb, NULL);
-	return rc;
-}
-
 static int qeth_l3_start_ipa_arp_processing(struct qeth_card *card)
 {
 	int rc;
@@ -1135,8 +1095,8 @@ static int qeth_l3_start_ipa_arp_processing(struct qeth_card *card)
 			QETH_CARD_IFNAME(card));
 		return 0;
 	}
-	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
-					IPA_CMD_ASS_START, 0);
+	rc = qeth_send_simple_setassparms(card, IPA_ARP_PROCESSING,
+					  IPA_CMD_ASS_START, 0);
 	if (rc) {
 		dev_warn(&card->gdev->dev,
 			"Starting ARP processing support for %s failed\n",
@@ -1158,7 +1118,7 @@ static int qeth_l3_start_ipa_ip_fragmentation(struct qeth_card *card)
 		return  -EOPNOTSUPP;
 	}
 
-	rc = qeth_l3_send_simple_setassparms(card, IPA_IP_FRAGMENTATION,
+	rc = qeth_send_simple_setassparms(card, IPA_IP_FRAGMENTATION,
 					  IPA_CMD_ASS_START, 0);
 	if (rc) {
 		dev_warn(&card->gdev->dev,
@@ -1183,7 +1143,7 @@ static int qeth_l3_start_ipa_source_mac(struct qeth_card *card)
 		return -EOPNOTSUPP;
 	}
 
-	rc = qeth_l3_send_simple_setassparms(card, IPA_SOURCE_MAC,
+	rc = qeth_send_simple_setassparms(card, IPA_SOURCE_MAC,
 					  IPA_CMD_ASS_START, 0);
 	if (rc)
 		dev_warn(&card->gdev->dev,
@@ -1204,7 +1164,7 @@ static int qeth_l3_start_ipa_vlan(struct qeth_card *card)
 		return -EOPNOTSUPP;
 	}
 
-	rc = qeth_l3_send_simple_setassparms(card, IPA_VLAN_PRIO,
+	rc = qeth_send_simple_setassparms(card, IPA_VLAN_PRIO,
 					  IPA_CMD_ASS_START, 0);
 	if (rc) {
 		dev_warn(&card->gdev->dev,
@@ -1229,7 +1189,7 @@ static int qeth_l3_start_ipa_multicast(struct qeth_card *card)
 		return -EOPNOTSUPP;
 	}
 
-	rc = qeth_l3_send_simple_setassparms(card, IPA_MULTICASTING,
+	rc = qeth_send_simple_setassparms(card, IPA_MULTICASTING,
 					  IPA_CMD_ASS_START, 0);
 	if (rc) {
 		dev_warn(&card->gdev->dev,
@@ -1259,7 +1219,7 @@ static int qeth_l3_softsetup_ipv6(struct qeth_card *card)
 			QETH_CARD_IFNAME(card));
 		return rc;
 	}
-	rc = qeth_l3_send_simple_setassparms(card, IPA_IPV6,
+	rc = qeth_send_simple_setassparms(card, IPA_IPV6,
 					  IPA_CMD_ASS_START, 3);
 	if (rc) {
 		dev_err(&card->gdev->dev,
@@ -1319,7 +1279,7 @@ static int qeth_l3_start_ipa_broadcast(struct qeth_card *card)
 		rc = -EOPNOTSUPP;
 		goto out;
 	}
-	rc = qeth_l3_send_simple_setassparms(card, IPA_FILTERING,
+	rc = qeth_send_simple_setassparms(card, IPA_FILTERING,
 					  IPA_CMD_ASS_START, 0);
 	if (rc) {
 		dev_warn(&card->gdev->dev, "Enabling broadcast filtering for "
@@ -1327,7 +1287,7 @@ static int qeth_l3_start_ipa_broadcast(struct qeth_card *card)
 		goto out;
 	}
 
-	rc = qeth_l3_send_simple_setassparms(card, IPA_FILTERING,
+	rc = qeth_send_simple_setassparms(card, IPA_FILTERING,
 					  IPA_CMD_ASS_CONFIGURE, 1);
 	if (rc) {
 		dev_warn(&card->gdev->dev,
@@ -1337,7 +1297,7 @@ static int qeth_l3_start_ipa_broadcast(struct qeth_card *card)
 	}
 	card->info.broadcast_capable = QETH_BROADCAST_WITH_ECHO;
 	dev_info(&card->gdev->dev, "Broadcast enabled\n");
-	rc = qeth_l3_send_simple_setassparms(card, IPA_FILTERING,
+	rc = qeth_send_simple_setassparms(card, IPA_FILTERING,
 					  IPA_CMD_ASS_ENABLE, 1);
 	if (rc) {
 		dev_warn(&card->gdev->dev, "Setting up broadcast echo "
@@ -1353,84 +1313,18 @@ out:
 	return rc;
 }
 
-static int qeth_l3_send_checksum_command(struct qeth_card *card)
-{
-	int rc;
-
-	rc = qeth_l3_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
-					  IPA_CMD_ASS_START, 0);
-	if (rc) {
-		dev_warn(&card->gdev->dev, "Starting HW checksumming for %s "
-			"failed, using SW checksumming\n",
-			QETH_CARD_IFNAME(card));
-		return rc;
-	}
-	rc = qeth_l3_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
-					  IPA_CMD_ASS_ENABLE,
-					  card->info.csum_mask);
-	if (rc) {
-		dev_warn(&card->gdev->dev, "Enabling HW checksumming for %s "
-			"failed, using SW checksumming\n",
-			QETH_CARD_IFNAME(card));
-		return rc;
-	}
-	return 0;
-}
-
-static int qeth_l3_set_rx_csum(struct qeth_card *card, int on)
-{
-	int rc = 0;
-
-	if (on) {
-		rc = qeth_l3_send_checksum_command(card);
-		if (rc)
-			return -EIO;
-		dev_info(&card->gdev->dev,
-			"HW Checksumming (inbound) enabled\n");
-	} else {
-		rc = qeth_l3_send_simple_setassparms(card,
-			IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
-		if (rc)
-			return -EIO;
-	}
-
-	return 0;
-}
-
-static int qeth_l3_start_ipa_checksum(struct qeth_card *card)
+static void qeth_l3_start_ipa_checksum(struct qeth_card *card)
 {
 	QETH_CARD_TEXT(card, 3, "strtcsum");
-
-	if (card->dev->features & NETIF_F_RXCSUM) {
-		rtnl_lock();
-		/* force set_features call */
-		card->dev->features &= ~NETIF_F_RXCSUM;
-		netdev_update_features(card->dev);
-		rtnl_unlock();
-	}
-	return 0;
+	if (qeth_is_supported(card, IPA_INBOUND_CHECKSUM)
+	    && (card->dev->features & NETIF_F_RXCSUM))
+		qeth_set_rx_csum(card, 1);
 }
 
-static int qeth_l3_start_ipa_tx_checksum(struct qeth_card *card)
+static void qeth_l3_start_ipa_tx_checksum(struct qeth_card *card)
 {
-	int rc = 0;
-
-	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
-		return rc;
-	rc = qeth_l3_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
-			  IPA_CMD_ASS_START, 0);
-	if (rc)
-		goto err_out;
-	rc = qeth_l3_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
-			  IPA_CMD_ASS_ENABLE, card->info.tx_csum_mask);
-	if (rc)
-		goto err_out;
-	dev_info(&card->gdev->dev, "HW TX Checksumming enabled\n");
-	return rc;
-err_out:
-	dev_warn(&card->gdev->dev, "Enabling HW TX checksumming for %s "
-		"failed, using SW TX checksumming\n", QETH_CARD_IFNAME(card));
-	return rc;
+	QETH_CARD_TEXT(card, 3, "strttxcs");
+	qeth_start_ipa_tx_checksum(card);
 }
 
 static int qeth_l3_start_ipa_tso(struct qeth_card *card)
@@ -1445,8 +1339,8 @@ static int qeth_l3_start_ipa_tso(struct qeth_card *card)
 			QETH_CARD_IFNAME(card));
 		rc = -EOPNOTSUPP;
 	} else {
-		rc = qeth_l3_send_simple_setassparms(card, IPA_OUTBOUND_TSO,
-						IPA_CMD_ASS_START, 0);
+		rc = qeth_send_simple_setassparms(card, IPA_OUTBOUND_TSO,
+						  IPA_CMD_ASS_START, 0);
 		if (rc)
 			dev_warn(&card->gdev->dev, "Starting outbound TCP "
 				"segmentation offload for %s failed\n",
@@ -1950,7 +1844,6 @@ static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
 			skb->ip_summed = CHECKSUM_NONE;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
-
 	return is_vlan;
 }
 
@@ -2287,7 +2180,7 @@ static int qeth_l3_arp_set_no_entries(struct qeth_card *card, int no_entries)
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
 		return -EOPNOTSUPP;
 	}
-	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
+	rc = qeth_send_simple_setassparms(card, IPA_ARP_PROCESSING,
 					  IPA_CMD_ASS_ARP_SET_NO_ENTRIES,
 					  no_entries);
 	if (rc) {
@@ -2552,7 +2445,7 @@ static int qeth_l3_arp_add_entry(struct qeth_card *card,
 				       QETH_PROT_IPV4);
 	if (!iob)
 		return -ENOMEM;
-	rc = qeth_l3_send_setassparms(card, iob,
+	rc = qeth_send_setassparms(card, iob,
 				   sizeof(struct qeth_arp_cache_entry),
 				   (unsigned long) entry,
 				   qeth_l3_default_setassparms_cb, NULL);
@@ -2593,7 +2486,7 @@ static int qeth_l3_arp_remove_entry(struct qeth_card *card,
 				       QETH_PROT_IPV4);
 	if (!iob)
 		return -ENOMEM;
-	rc = qeth_l3_send_setassparms(card, iob,
+	rc = qeth_send_setassparms(card, iob,
 				   12, (unsigned long)buf,
 				   qeth_l3_default_setassparms_cb, NULL);
 	if (rc) {
@@ -2624,7 +2517,7 @@ static int qeth_l3_arp_flush_cache(struct qeth_card *card)
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
 		return -EOPNOTSUPP;
 	}
-	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
+	rc = qeth_send_simple_setassparms(card, IPA_ARP_PROCESSING,
 					  IPA_CMD_ASS_ARP_FLUSH_CACHE, 0);
 	if (rc) {
 		tmp = rc;
@@ -3187,7 +3080,6 @@ static netdev_features_t qeth_l3_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_TSO;
 	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
 		features &= ~NETIF_F_RXCSUM;
-
 	return features;
 }
 
@@ -3204,7 +3096,7 @@ static int qeth_l3_set_features(struct net_device *dev,
 	    card->state == CARD_STATE_RECOVER)
 		return 0;
 
-	return qeth_l3_set_rx_csum(card, features & NETIF_F_RXCSUM ? 1 : 0);
+	return qeth_set_rx_csum(card, features & NETIF_F_RXCSUM ? 1 : 0);
 }
 
 static const struct ethtool_ops qeth_l3_ethtool_ops = {
-- 
2.3.8
