From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 02/18] ipw2200: Fix TX QoS enabled frames problem
Date: Thu, 13 Apr 2006 17:19:11 +0800
Message-ID: <20060413091911.GA28706@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:21139 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S964842AbWDMJ0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:26:22 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch works with the ieee80211 stack to set the correct QoS bit to the
ipw2200 card. It fixed the TX failure problem for using WPA with QoS.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   71 +++++++++++++++++++---------------------
 1 files changed, 33 insertions(+), 38 deletions(-)

3c5ca65d97d901329cf04807d51cf854f6385755
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 77caeac..a4d8d49 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -6862,61 +6862,55 @@ static int ipw_get_tx_queue_number(struc
 	return from_priority_to_tx_queue[priority] - 1;
 }
 
-/*
-* add QoS parameter to the TX command
-*/
-static int ipw_qos_set_tx_queue_command(struct ipw_priv *priv,
-					u16 priority,
-					struct tfd_data *tfd, u8 unicast)
+static int ipw_is_qos_active(struct net_device *dev,
+			     struct sk_buff *skb)
 {
-	int ret = 0;
-	int tx_queue_id = 0;
+	struct ipw_priv *priv = ieee80211_priv(dev);
 	struct ieee80211_qos_data *qos_data = NULL;
 	int active, supported;
-	unsigned long flags;
+	u8 *daddr = skb->data + ETH_ALEN;
+	int unicast = !is_multicast_ether_addr(daddr);
 
 	if (!(priv->status & STATUS_ASSOCIATED))
 		return 0;
 
 	qos_data = &priv->assoc_network->qos_data;
 
-	spin_lock_irqsave(&priv->ieee->lock, flags);
-
 	if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
 		if (unicast == 0)
 			qos_data->active = 0;
 		else
 			qos_data->active = qos_data->supported;
 	}
-
 	active = qos_data->active;
 	supported = qos_data->supported;
-
-	spin_unlock_irqrestore(&priv->ieee->lock, flags);
-
 	IPW_DEBUG_QOS("QoS  %d network is QoS active %d  supported %d  "
 		      "unicast %d\n",
 		      priv->qos_data.qos_enable, active, supported, unicast);
-	if (active && priv->qos_data.qos_enable) {
-		ret = from_priority_to_tx_queue[priority];
-		tx_queue_id = ret - 1;
-		IPW_DEBUG_QOS("QoS packet priority is %d \n", priority);
-		if (priority <= 7) {
-			tfd->tx_flags_ext |= DCT_FLAG_EXT_QOS_ENABLED;
-			tfd->tfd.tfd_26.mchdr.qos_ctrl = priority;
-			tfd->tfd.tfd_26.mchdr.frame_ctl |=
-			    IEEE80211_STYPE_QOS_DATA;
-
-			if (priv->qos_data.qos_no_ack_mask &
-			    (1UL << tx_queue_id)) {
-				tfd->tx_flags &= ~DCT_FLAG_ACK_REQD;
-				tfd->tfd.tfd_26.mchdr.qos_ctrl |=
-				    CTRL_QOS_NO_ACK;
-			}
-		}
-	}
+	if (active && priv->qos_data.qos_enable)
+		return 1;
 
-	return ret;
+	return 0;
+
+}
+/*
+* add QoS parameter to the TX command
+*/
+static int ipw_qos_set_tx_queue_command(struct ipw_priv *priv,
+					u16 priority,
+					struct tfd_data *tfd)
+{
+	int tx_queue_id = 0;
+
+
+	tx_queue_id = from_priority_to_tx_queue[priority] - 1;
+	tfd->tx_flags_ext |= DCT_FLAG_EXT_QOS_ENABLED;
+
+	if (priv->qos_data.qos_no_ack_mask & (1UL << tx_queue_id)) {
+		tfd->tx_flags &= ~DCT_FLAG_ACK_REQD;
+		tfd->tfd.tfd_26.mchdr.qos_ctrl |= CTRL_QOS_NO_ACK;
+	}
+	return 0;
 }
 
 /*
@@ -9656,7 +9650,7 @@ we need to heavily modify the ieee80211_
 static int ipw_tx_skb(struct ipw_priv *priv, struct ieee80211_txb *txb,
 			     int pri)
 {
-	struct ieee80211_hdr_3addr *hdr = (struct ieee80211_hdr_3addr *)
+	struct ieee80211_hdr_3addrqos *hdr = (struct ieee80211_hdr_3addrqos *)
 	    txb->fragments[0]->data;
 	int i = 0;
 	struct tfd_frame *tfd;
@@ -9671,9 +9665,9 @@ static int ipw_tx_skb(struct ipw_priv *p
 	u16 remaining_bytes;
 	int fc;
 
+	hdr_len = ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_ctl));
 	switch (priv->ieee->iw_mode) {
 	case IW_MODE_ADHOC:
-		hdr_len = IEEE80211_3ADDR_LEN;
 		unicast = !is_multicast_ether_addr(hdr->addr1);
 		id = ipw_find_station(priv, hdr->addr1);
 		if (id == IPW_INVALID_STATION) {
@@ -9690,7 +9684,6 @@ static int ipw_tx_skb(struct ipw_priv *p
 	case IW_MODE_INFRA:
 	default:
 		unicast = !is_multicast_ether_addr(hdr->addr3);
-		hdr_len = IEEE80211_3ADDR_LEN;
 		id = 0;
 		break;
 	}
@@ -9769,7 +9762,8 @@ static int ipw_tx_skb(struct ipw_priv *p
 		tfd->u.data.tx_flags |= DCT_FLAG_NO_WEP;
 
 #ifdef CONFIG_IPW_QOS
-	ipw_qos_set_tx_queue_command(priv, pri, &(tfd->u.data), unicast);
+	if (fc & IEEE80211_STYPE_QOS_DATA)
+		ipw_qos_set_tx_queue_command(priv, pri, &(tfd->u.data));
 #endif				/* CONFIG_IPW_QOS */
 
 	/* payload */
@@ -10969,6 +10963,7 @@ static int ipw_pci_probe(struct pci_dev 
 	priv->ieee->is_queue_full = ipw_net_is_queue_full;
 
 #ifdef CONFIG_IPW_QOS
+	priv->ieee->is_qos_active = ipw_is_qos_active;
 	priv->ieee->handle_probe_response = ipw_handle_beacon;
 	priv->ieee->handle_beacon = ipw_handle_probe_response;
 	priv->ieee->handle_assoc_response = ipw_handle_assoc_response;
-- 
1.2.6

