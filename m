From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 34/42] fusion: convert devices to new API
Date: Tue, 06 Jan 2009 16:33:50 -0800
Message-ID: <20090107003349.186562432@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Eric.Moore@lsi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60706 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbZAGAyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:06 -0500
Content-Disposition: inline; filename=fusion.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops and internal net_device_stats

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/message/fusion/mptlan.c	2009-01-03 22:26:32.399766978 -0800
+++ b/drivers/message/fusion/mptlan.c	2009-01-03 22:30:48.831765189 -0800
@@ -106,7 +106,6 @@ struct mpt_lan_priv {
 
 	u32 total_posted;
 	u32 total_received;
-	struct net_device_stats stats;	/* Per device statistics */
 
 	struct delayed_work post_buckets_task;
 	struct net_device *dev;
@@ -548,15 +547,6 @@ mpt_lan_close(struct net_device *dev)
 }
 
 /*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
-static struct net_device_stats *
-mpt_lan_get_stats(struct net_device *dev)
-{
-	struct mpt_lan_priv *priv = netdev_priv(dev);
-
-	return (struct net_device_stats *) &priv->stats;
-}
-
-/*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
 static int
 mpt_lan_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -594,8 +584,8 @@ mpt_lan_send_turbo(struct net_device *de
 	ctx = GET_LAN_BUFFER_CONTEXT(tmsg);
 	sent = priv->SendCtl[ctx].skb;
 
-	priv->stats.tx_packets++;
-	priv->stats.tx_bytes += sent->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += sent->len;
 
 	dioprintk((KERN_INFO MYNAM ": %s/%s: @%s, skb %p sent.\n",
 			IOC_AND_NETDEV_NAMES_s_s(dev),
@@ -636,7 +626,7 @@ mpt_lan_send_reply(struct net_device *de
 
 	switch (le16_to_cpu(pSendRep->IOCStatus) & MPI_IOCSTATUS_MASK) {
 	case MPI_IOCSTATUS_SUCCESS:
-		priv->stats.tx_packets += count;
+		dev->stats.tx_packets += count;
 		break;
 
 	case MPI_IOCSTATUS_LAN_CANCELED:
@@ -644,13 +634,13 @@ mpt_lan_send_reply(struct net_device *de
 		break;
 
 	case MPI_IOCSTATUS_INVALID_SGL:
-		priv->stats.tx_errors += count;
+		dev->stats.tx_errors += count;
 		printk (KERN_ERR MYNAM ": %s/%s: ERROR - Invalid SGL sent to IOC!\n",
 				IOC_AND_NETDEV_NAMES_s_s(dev));
 		goto out;
 
 	default:
-		priv->stats.tx_errors += count;
+		dev->stats.tx_errors += count;
 		break;
 	}
 
@@ -661,7 +651,7 @@ mpt_lan_send_reply(struct net_device *de
 		ctx = GET_LAN_BUFFER_CONTEXT(le32_to_cpu(*pContext));
 
 		sent = priv->SendCtl[ctx].skb;
-		priv->stats.tx_bytes += sent->len;
+		dev->stats.tx_bytes += sent->len;
 
 		dioprintk((KERN_INFO MYNAM ": %s/%s: @%s, skb %p sent.\n",
 				IOC_AND_NETDEV_NAMES_s_s(dev),
@@ -842,8 +832,8 @@ mpt_lan_receive_skb(struct net_device *d
 		 "delivered to upper level.\n",
 			IOC_AND_NETDEV_NAMES_s_s(dev), skb->len));
 
-	priv->stats.rx_bytes += skb->len;
-	priv->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
 
 	skb->dev = dev;
 	netif_rx(skb);
@@ -1308,6 +1298,14 @@ mpt_lan_post_receive_buckets_work(struct
 						  post_buckets_task.work));
 }
 
+static const struct net_device_ops mpt_netdev_ops = {
+	.ndo_open       = mpt_lan_open,
+	.ndo_stop       = mpt_lan_close,
+	.ndo_start_xmit = mpt_lan_sdu_send,
+	.ndo_change_mtu = mpt_lan_change_mtu,
+	.ndo_tx_timeout = mpt_lan_tx_timeout,
+};
+
 /*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
 static struct net_device *
 mpt_register_lan_device (MPT_ADAPTER *mpt_dev, int pnum)
@@ -1372,15 +1370,7 @@ mpt_register_lan_device (MPT_ADAPTER *mp
 	priv->tx_max_out = (tx_max_out_p <= MPT_TX_MAX_OUT_LIM) ?
 			    tx_max_out_p : MPT_TX_MAX_OUT_LIM;
 
-	dev->open = mpt_lan_open;
-	dev->stop = mpt_lan_close;
-	dev->get_stats = mpt_lan_get_stats;
-	dev->set_multicast_list = NULL;
-	dev->change_mtu = mpt_lan_change_mtu;
-	dev->hard_start_xmit = mpt_lan_sdu_send;
-
-/* Not in 2.3.42. Need 2.3.45+ */
-	dev->tx_timeout = mpt_lan_tx_timeout;
+	dev->netdev_ops = &mpt_netdev_ops;
 	dev->watchdog_timeo = MPT_LAN_TX_TIMEOUT;
 
 	dlprintk((KERN_INFO MYNAM ": Finished registering dev "

-- 

