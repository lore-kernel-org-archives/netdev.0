From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 71/77] ipw2x00: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:38 -0700
Message-ID: <20090321053717.989009860@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, jkosina@suse.cz,
	dstreba@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36740 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761169AbZCUFsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:30 -0400
Content-Disposition: inline; filename=ipw-ieee-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace struct in ieee with current net_device_stats, so no longer
need get_stats hook

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/wireless/ipw2x00/ieee80211.h     |    1 
 drivers/net/wireless/ipw2x00/ipw2100.c       |   36 +++++++++---------
 drivers/net/wireless/ipw2x00/ipw2200.c       |   52 +++++++++------------------
 drivers/net/wireless/ipw2x00/libipw_module.c |   11 -----
 drivers/net/wireless/ipw2x00/libipw_rx.c     |   17 +++-----
 drivers/net/wireless/ipw2x00/libipw_tx.c     |    9 ++--
 6 files changed, 49 insertions(+), 77 deletions(-)

--- a/drivers/net/wireless/ipw2x00/ieee80211.h	2009-03-20 21:18:15.663026786 -0700
+++ b/drivers/net/wireless/ipw2x00/ieee80211.h	2009-03-20 21:24:54.874966147 -0700
@@ -786,7 +786,6 @@ struct ieee80211_device {
 	struct ieee80211_security sec;
 
 	/* Bookkeeping structures */
-	struct net_device_stats stats;
 	struct ieee80211_stats ieee_stats;
 
 	struct ieee80211_geo geo;
--- a/drivers/net/wireless/ipw2x00/libipw_module.c	2009-03-20 21:18:15.668026646 -0700
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c	2009-03-20 21:24:54.887966521 -0700
@@ -139,13 +139,6 @@ static int ieee80211_change_mtu(struct n
 	return 0;
 }
 
-static struct net_device_stats *ieee80211_generic_get_stats(
-	struct net_device *dev)
-{
-	struct ieee80211_device *ieee = netdev_priv(dev);
-	return &ieee->stats;
-}
-
 struct net_device *alloc_ieee80211(int sizeof_priv)
 {
 	struct ieee80211_device *ieee;
@@ -163,10 +156,6 @@ struct net_device *alloc_ieee80211(int s
 	dev->hard_start_xmit = ieee80211_xmit;
 	dev->change_mtu = ieee80211_change_mtu;
 
-	/* Drivers are free to override this if the generic implementation
-	 * does not meet their needs. */
-	dev->get_stats = ieee80211_generic_get_stats;
-
 	ieee->dev = dev;
 
 	err = ieee80211_networks_allocate(ieee);
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c	2009-03-20 21:18:15.677026752 -0700
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c	2009-03-20 21:25:06.478026388 -0700
@@ -335,7 +335,6 @@ int ieee80211_rx(struct ieee80211_device
 	struct ieee80211_hdr_4addr *hdr;
 	size_t hdrlen;
 	u16 fc, type, stype, sc;
-	struct net_device_stats *stats;
 	unsigned int frag;
 	u8 *payload;
 	u16 ethertype;
@@ -354,8 +353,6 @@ int ieee80211_rx(struct ieee80211_device
 	int can_be_decrypted = 0;
 
 	hdr = (struct ieee80211_hdr_4addr *)skb->data;
-	stats = &ieee->stats;
-
 	if (skb->len < 10) {
 		printk(KERN_INFO "%s: SKB length < 10\n", dev->name);
 		goto rx_dropped;
@@ -412,8 +409,8 @@ int ieee80211_rx(struct ieee80211_device
 #endif
 
 	if (ieee->iw_mode == IW_MODE_MONITOR) {
-		stats->rx_packets++;
-		stats->rx_bytes += skb->len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
 		ieee80211_monitor_rx(ieee, skb, rx_stats);
 		return 1;
 	}
@@ -769,8 +766,8 @@ int ieee80211_rx(struct ieee80211_device
 	}
 #endif
 
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 #ifdef NOT_YET
 	if (ieee->iw_mode == IW_MODE_MASTER && !wds && ieee->ap->bridge_packets) {
@@ -812,7 +809,7 @@ int ieee80211_rx(struct ieee80211_device
 			 * in our stats. */
 			IEEE80211_DEBUG_DROP
 			    ("RX: netif_rx dropped the packet\n");
-			stats->rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 	}
 
@@ -824,7 +821,7 @@ int ieee80211_rx(struct ieee80211_device
 	return 1;
 
       rx_dropped:
-	stats->rx_dropped++;
+	dev->stats.rx_dropped++;
 
 	/* Returning 0 indicates to caller that we have not handled the SKB--
 	 * so it is still allocated and can be used again by underlying
@@ -919,7 +916,7 @@ void ieee80211_rx_any(struct ieee80211_d
 
 drop_free:
 	dev_kfree_skb_irq(skb);
-	ieee->stats.rx_dropped++;
+	ieee->dev->stats.rx_dropped++;
 	return;
 }
 
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c	2009-03-20 21:18:15.673026767 -0700
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c	2009-03-20 21:18:36.958902525 -0700
@@ -260,7 +260,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	int i, bytes_per_frag, nr_frags, bytes_last_frag, frag_size,
 	    rts_required;
 	unsigned long flags;
-	struct net_device_stats *stats = &ieee->stats;
 	int encrypt, host_encrypt, host_encrypt_msdu, host_build_iv;
 	__be16 ether_type;
 	int bytes, fc, hdr_len;
@@ -306,7 +305,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 
 	if (!encrypt && ieee->ieee802_1x &&
 	    ieee->drop_unencrypted && ether_type != htons(ETH_P_PAE)) {
-		stats->tx_dropped++;
+		dev->stats.tx_dropped++;
 		goto success;
 	}
 
@@ -526,8 +525,8 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	if (txb) {
 		int ret = (*ieee->hard_start_xmit) (txb, dev, priority);
 		if (ret == 0) {
-			stats->tx_packets++;
-			stats->tx_bytes += txb->payload_size;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += txb->payload_size;
 			return 0;
 		}
 
@@ -539,7 +538,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
       failed:
 	spin_unlock_irqrestore(&ieee->lock, flags);
 	netif_stop_queue(dev);
-	stats->tx_errors++;
+	dev->stats.tx_errors++;
 	return 1;
 }
 
--- a/drivers/net/wireless/ipw2x00/ipw2100.c	2009-03-20 21:18:15.685026716 -0700
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c	2009-03-20 21:24:53.398965406 -0700
@@ -2391,13 +2391,14 @@ static void ipw2100_corruption_detected(
 #endif
 
 	priv->fatal_error = IPW2100_ERR_C3_CORRUPTION;
-	priv->ieee->stats.rx_errors++;
+	priv->net_dev->stats.rx_errors++;
 	schedule_reset(priv);
 }
 
 static void isr_rx(struct ipw2100_priv *priv, int i,
 			  struct ieee80211_rx_stats *stats)
 {
+	struct net_device *dev = priv->net_dev;
 	struct ipw2100_status *status = &priv->status_queue.drv[i];
 	struct ipw2100_rx_packet *packet = &priv->rx_buffers[i];
 
@@ -2406,14 +2407,14 @@ static void isr_rx(struct ipw2100_priv *
 	if (unlikely(status->frame_size > skb_tailroom(packet->skb))) {
 		IPW_DEBUG_INFO("%s: frame_size (%u) > skb_tailroom (%u)!"
 			       "  Dropping.\n",
-			       priv->net_dev->name,
+			       dev->name,
 			       status->frame_size, skb_tailroom(packet->skb));
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		return;
 	}
 
-	if (unlikely(!netif_running(priv->net_dev))) {
-		priv->ieee->stats.rx_errors++;
+	if (unlikely(!netif_running(dev))) {
+		dev->stats.rx_errors++;
 		priv->wstats.discard.misc++;
 		IPW_DEBUG_DROP("Dropping packet while interface is not up.\n");
 		return;
@@ -2443,10 +2444,10 @@ static void isr_rx(struct ipw2100_priv *
 	if (!ieee80211_rx(priv->ieee, packet->skb, stats)) {
 #ifdef IPW2100_RX_DEBUG
 		IPW_DEBUG_DROP("%s: Non consumed packet:\n",
-			       priv->net_dev->name);
+			       dev->name);
 		printk_buf(IPW_DL_DROP, packet_data, status->frame_size);
 #endif
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 		/* ieee80211_rx failed, so it didn't free the SKB */
 		dev_kfree_skb_any(packet->skb);
@@ -2457,7 +2458,7 @@ static void isr_rx(struct ipw2100_priv *
 	if (unlikely(ipw2100_alloc_skb(priv, packet))) {
 		printk(KERN_WARNING DRV_NAME ": "
 		       "%s: Unable to allocate SKB onto RBD ring - disabling "
-		       "adapter.\n", priv->net_dev->name);
+		       "adapter.\n", dev->name);
 		/* TODO: schedule adapter shutdown */
 		IPW_DEBUG_INFO("TODO: Shutdown adapter...\n");
 	}
@@ -2471,6 +2472,7 @@ static void isr_rx(struct ipw2100_priv *
 static void isr_rx_monitor(struct ipw2100_priv *priv, int i,
 		   struct ieee80211_rx_stats *stats)
 {
+	struct net_device *dev = priv->net_dev;
 	struct ipw2100_status *status = &priv->status_queue.drv[i];
 	struct ipw2100_rx_packet *packet = &priv->rx_buffers[i];
 
@@ -2488,15 +2490,15 @@ static void isr_rx_monitor(struct ipw210
 				sizeof(struct ipw_rt_hdr))) {
 		IPW_DEBUG_INFO("%s: frame_size (%u) > skb_tailroom (%u)!"
 			       "  Dropping.\n",
-			       priv->net_dev->name,
+			       dev->name,
 			       status->frame_size,
 			       skb_tailroom(packet->skb));
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		return;
 	}
 
-	if (unlikely(!netif_running(priv->net_dev))) {
-		priv->ieee->stats.rx_errors++;
+	if (unlikely(!netif_running(dev))) {
+		dev->stats.rx_errors++;
 		priv->wstats.discard.misc++;
 		IPW_DEBUG_DROP("Dropping packet while interface is not up.\n");
 		return;
@@ -2505,7 +2507,7 @@ static void isr_rx_monitor(struct ipw210
 	if (unlikely(priv->config & CFG_CRC_CHECK &&
 		     status->flags & IPW_STATUS_FLAG_CRC_ERROR)) {
 		IPW_DEBUG_RX("CRC error in packet.  Dropping.\n");
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		return;
 	}
 
@@ -2527,7 +2529,7 @@ static void isr_rx_monitor(struct ipw210
 	skb_put(packet->skb, status->frame_size + sizeof(struct ipw_rt_hdr));
 
 	if (!ieee80211_rx(priv->ieee, packet->skb, stats)) {
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 		/* ieee80211_rx failed, so it didn't free the SKB */
 		dev_kfree_skb_any(packet->skb);
@@ -2538,7 +2540,7 @@ static void isr_rx_monitor(struct ipw210
 	if (unlikely(ipw2100_alloc_skb(priv, packet))) {
 		IPW_DEBUG_WARNING(
 			"%s: Unable to allocate SKB onto RBD ring - disabling "
-			"adapter.\n", priv->net_dev->name);
+			"adapter.\n", dev->name);
 		/* TODO: schedule adapter shutdown */
 		IPW_DEBUG_INFO("TODO: Shutdown adapter...\n");
 	}
@@ -3340,7 +3342,7 @@ static int ipw2100_tx(struct ieee80211_t
 
 	if (!(priv->status & STATUS_ASSOCIATED)) {
 		IPW_DEBUG_INFO("Can not transmit when not connected.\n");
-		priv->ieee->stats.tx_carrier_errors++;
+		priv->net_dev->stats.tx_carrier_errors++;
 		netif_stop_queue(dev);
 		goto fail_unlock;
 	}
@@ -5836,7 +5838,7 @@ static void ipw2100_tx_timeout(struct ne
 {
 	struct ipw2100_priv *priv = ieee80211_priv(dev);
 
-	priv->ieee->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 #ifdef CONFIG_IPW2100_MONITOR
 	if (priv->ieee->iw_mode == IW_MODE_MONITOR)
--- a/drivers/net/wireless/ipw2x00/ipw2200.c	2009-03-20 21:18:15.659026583 -0700
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c	2009-03-20 21:24:29.757901661 -0700
@@ -7731,22 +7731,23 @@ static void ipw_handle_data_packet(struc
 				   struct ipw_rx_mem_buffer *rxb,
 				   struct ieee80211_rx_stats *stats)
 {
+	struct net_device *dev = priv->net_dev;
 	struct ieee80211_hdr_4addr *hdr;
 	struct ipw_rx_packet *pkt = (struct ipw_rx_packet *)rxb->skb->data;
 
 	/* We received data from the HW, so stop the watchdog */
-	priv->net_dev->trans_start = jiffies;
+	dev->trans_start = jiffies;
 
 	/* We only process data packets if the
 	 * interface is open */
 	if (unlikely((le16_to_cpu(pkt->u.frame.length) + IPW_RX_FRAME_SIZE) >
 		     skb_tailroom(rxb->skb))) {
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		priv->wstats.discard.misc++;
 		IPW_DEBUG_DROP("Corruption detected! Oh no!\n");
 		return;
 	} else if (unlikely(!netif_running(priv->net_dev))) {
-		priv->ieee->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		priv->wstats.discard.misc++;
 		IPW_DEBUG_DROP("Dropping packet while interface is not up.\n");
 		return;
@@ -7768,7 +7769,7 @@ static void ipw_handle_data_packet(struc
 		ipw_rebuild_decrypted_skb(priv, rxb->skb);
 
 	if (!ieee80211_rx(priv->ieee, rxb->skb, stats))
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 	else {			/* ieee80211_rx succeeded, so it now owns the SKB */
 		rxb->skb = NULL;
 		__ipw_led_activity_on(priv);
@@ -7780,6 +7781,7 @@ static void ipw_handle_data_packet_monit
 					   struct ipw_rx_mem_buffer *rxb,
 					   struct ieee80211_rx_stats *stats)
 {
+	struct net_device *dev = priv->net_dev;
 	struct ipw_rx_packet *pkt = (struct ipw_rx_packet *)rxb->skb->data;
 	struct ipw_rx_frame *frame = &pkt->u.frame;
 
@@ -7797,18 +7799,18 @@ static void ipw_handle_data_packet_monit
 	short len = le16_to_cpu(pkt->u.frame.length);
 
 	/* We received data from the HW, so stop the watchdog */
-	priv->net_dev->trans_start = jiffies;
+	dev->trans_start = jiffies;
 
 	/* We only process data packets if the
 	 * interface is open */
 	if (unlikely((le16_to_cpu(pkt->u.frame.length) + IPW_RX_FRAME_SIZE) >
 		     skb_tailroom(rxb->skb))) {
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		priv->wstats.discard.misc++;
 		IPW_DEBUG_DROP("Corruption detected! Oh no!\n");
 		return;
 	} else if (unlikely(!netif_running(priv->net_dev))) {
-		priv->ieee->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		priv->wstats.discard.misc++;
 		IPW_DEBUG_DROP("Dropping packet while interface is not up.\n");
 		return;
@@ -7818,7 +7820,7 @@ static void ipw_handle_data_packet_monit
 	 * that now */
 	if (len > IPW_RX_BUF_SIZE - sizeof(struct ipw_rt_hdr)) {
 		/* FIXME: Should alloc bigger skb instead */
-		priv->ieee->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		priv->wstats.discard.misc++;
 		IPW_DEBUG_DROP("Dropping too large packet in monitor\n");
 		return;
@@ -7924,7 +7926,7 @@ static void ipw_handle_data_packet_monit
 	IPW_DEBUG_RX("Rx packet of %d bytes.\n", rxb->skb->len);
 
 	if (!ieee80211_rx(priv->ieee, rxb->skb, stats))
-		priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 	else {			/* ieee80211_rx succeeded, so it now owns the SKB */
 		rxb->skb = NULL;
 		/* no LED during capture */
@@ -7956,6 +7958,7 @@ static void ipw_handle_promiscuous_rx(st
 				      struct ipw_rx_mem_buffer *rxb,
 				      struct ieee80211_rx_stats *stats)
 {
+	struct net_device *dev = priv->prom_net_dev;
 	struct ipw_rx_packet *pkt = (struct ipw_rx_packet *)rxb->skb->data;
 	struct ipw_rx_frame *frame = &pkt->u.frame;
 	struct ipw_rt_hdr *ipw_rt;
@@ -7978,17 +7981,17 @@ static void ipw_handle_promiscuous_rx(st
 		return;
 
 	/* We received data from the HW, so stop the watchdog */
-	priv->prom_net_dev->trans_start = jiffies;
+	dev->trans_start = jiffies;
 
 	if (unlikely((len + IPW_RX_FRAME_SIZE) > skb_tailroom(rxb->skb))) {
-		priv->prom_priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		IPW_DEBUG_DROP("Corruption detected! Oh no!\n");
 		return;
 	}
 
 	/* We only process data packets if the interface is open */
-	if (unlikely(!netif_running(priv->prom_net_dev))) {
-		priv->prom_priv->ieee->stats.rx_dropped++;
+	if (unlikely(!netif_running(dev))) {
+		dev->stats.rx_dropped++;
 		IPW_DEBUG_DROP("Dropping packet while interface is not up.\n");
 		return;
 	}
@@ -7997,7 +8000,7 @@ static void ipw_handle_promiscuous_rx(st
 	 * that now */
 	if (len > IPW_RX_BUF_SIZE - sizeof(struct ipw_rt_hdr)) {
 		/* FIXME: Should alloc bigger skb instead */
-		priv->prom_priv->ieee->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		IPW_DEBUG_DROP("Dropping too large packet in monitor\n");
 		return;
 	}
@@ -8129,7 +8132,7 @@ static void ipw_handle_promiscuous_rx(st
 	IPW_DEBUG_RX("Rx packet of %d bytes.\n", skb->len);
 
 	if (!ieee80211_rx(priv->prom_priv->ieee, skb, stats)) {
-		priv->prom_priv->ieee->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		dev_kfree_skb_any(skb);
 	}
 }
@@ -8413,7 +8416,7 @@ static void ipw_rx(struct ipw_priv *priv
 					IPW_DEBUG_DROP
 					    ("Received packet is too small. "
 					     "Dropping.\n");
-					priv->ieee->stats.rx_errors++;
+					priv->net_dev->stats.rx_errors++;
 					priv->wstats.discard.misc++;
 					break;
 				}
@@ -10484,15 +10487,6 @@ static int ipw_net_hard_start_xmit(struc
 	return ret;
 }
 
-static struct net_device_stats *ipw_net_get_stats(struct net_device *dev)
-{
-	struct ipw_priv *priv = ieee80211_priv(dev);
-
-	priv->ieee->stats.tx_packets = priv->tx_packets;
-	priv->ieee->stats.rx_packets = priv->rx_packets;
-	return &priv->ieee->stats;
-}
-
 static void ipw_net_set_multicast_list(struct net_device *dev)
 {
 
@@ -11535,12 +11529,6 @@ static int ipw_prom_hard_start_xmit(stru
 	return -EOPNOTSUPP;
 }
 
-static struct net_device_stats *ipw_prom_get_stats(struct net_device *dev)
-{
-	struct ipw_prom_priv *prom_priv = ieee80211_priv(dev);
-	return &prom_priv->ieee->stats;
-}
-
 static int ipw_prom_alloc(struct ipw_priv *priv)
 {
 	int rc = 0;
@@ -11562,7 +11550,6 @@ static int ipw_prom_alloc(struct ipw_pri
 	priv->prom_net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
 	priv->prom_net_dev->open = ipw_prom_open;
 	priv->prom_net_dev->stop = ipw_prom_stop;
-	priv->prom_net_dev->get_stats = ipw_prom_get_stats;
 	priv->prom_net_dev->hard_start_xmit = ipw_prom_hard_start_xmit;
 
 	priv->prom_priv->ieee->iw_mode = IW_MODE_MONITOR;
@@ -11695,7 +11682,6 @@ static int __devinit ipw_pci_probe(struc
 	net_dev->open = ipw_net_open;
 	net_dev->stop = ipw_net_stop;
 	net_dev->init = ipw_net_init;
-	net_dev->get_stats = ipw_net_get_stats;
 	net_dev->set_multicast_list = ipw_net_set_multicast_list;
 	net_dev->set_mac_address = ipw_net_set_mac_address;
 	priv->wireless_data.spy_data = &priv->ieee->spy_data;

-- 

