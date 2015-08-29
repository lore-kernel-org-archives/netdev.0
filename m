From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 3/3] net: Change VRF driver to use the new L3 RX handler
Date: Fri, 28 Aug 2015 17:34:23 -0700
Message-ID: <1440808463-14526-4-git-send-email-dsa@cumulusnetworks.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35196 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbbH2Aee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 20:34:34 -0400
Received: by pacdd16 with SMTP id dd16so77805485pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 17:34:33 -0700 (PDT)
In-Reply-To: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By registering an L3 handler the VRF driver's rx handler does not need
the L3 check. Once the skb->dev is switched to the VRF device the packet
is reinjected to the stack and starts anew. This is required for the
packet to get picked up at the packet socket level with the new
device and continue up the stack hitting netfilter hooks as well.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 32 ++++++++++----------------------
 1 file changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index e7094fbd7568..3aa1a7db830c 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -88,16 +88,6 @@ static struct dst_ops vrf_dst_ops = {
 	.default_advmss	= vrf_default_advmss,
 };
 
-static bool is_ip_rx_frame(struct sk_buff *skb)
-{
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-	case htons(ETH_P_IPV6):
-		return true;
-	}
-	return false;
-}
-
 static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
 {
 	vrf_dev->stats.tx_errors++;
@@ -108,21 +98,19 @@ static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
 static rx_handler_result_t vrf_handle_frame(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
+	struct net_device *dev = vrf_master_get_rcu(skb->dev);
+	struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
 
-	if (is_ip_rx_frame(skb)) {
-		struct net_device *dev = vrf_master_get_rcu(skb->dev);
-		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
+	u64_stats_update_begin(&dstats->syncp);
+	dstats->rx_pkts++;
+	dstats->rx_bytes += skb->len;
+	u64_stats_update_end(&dstats->syncp);
 
-		u64_stats_update_begin(&dstats->syncp);
-		dstats->rx_pkts++;
-		dstats->rx_bytes += skb->len;
-		u64_stats_update_end(&dstats->syncp);
+	skb->dev = dev;
 
-		skb->dev = dev;
+	netif_receive_skb(skb);
 
-		return RX_HANDLER_ANOTHER;
-	}
-	return RX_HANDLER_PASS;
+	return RX_HANDLER_CONSUMED;
 }
 
 static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
@@ -405,7 +393,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 	vrf_ptr->tb_id = vrf->tb_id;
 
 	/* register the packet handler for slave ports */
-	ret = netdev_rx_handler_register(port_dev, vrf_handle_frame, dev);
+	ret = netdev_l3_rx_handler_register(port_dev, vrf_handle_frame, dev);
 	if (ret) {
 		netdev_err(port_dev,
 			   "Device %s failed to register rx_handler\n",
-- 
1.9.1
