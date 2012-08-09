From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 11/14] vlan: clean up vlan_dev_hard_start_xmit()
Date: Thu,  9 Aug 2012 23:00:23 +0800
Message-ID: <1344524426-11588-12-git-send-email-amwang@redhat.com>
References: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, Benjamin LaHaise <bcrl@kvack.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030911Ab2HIPBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 11:01:10 -0400
In-Reply-To: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up vlan_dev_hard_start_xmit() function.

Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/8021q/vlan_dev.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b65623f..dedc56c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -137,9 +137,21 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return rc;
 }
 
+static inline netdev_tx_t vlan_netpoll_send_skb(struct vlan_dev_priv *info, struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (info->netpoll)
+		netpoll_send_skb(info->netpoll, skb);
+#else
+	BUG();
+#endif
+	return NETDEV_TX_OK;
+}
+
 static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
+	struct vlan_dev_priv *info = vlan_dev_priv(dev);
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
 	unsigned int len;
 	int ret;
@@ -150,29 +162,30 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
 	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
-	    vlan_dev_priv(dev)->flags & VLAN_FLAG_REORDER_HDR) {
+	    info->flags & VLAN_FLAG_REORDER_HDR) {
 		u16 vlan_tci;
-		vlan_tci = vlan_dev_priv(dev)->vlan_id;
+		vlan_tci = info->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 	}
 
-	skb->dev = vlan_dev_priv(dev)->real_dev;
+	skb->dev = info->real_dev;
 	len = skb->len;
-	if (netpoll_tx_running(dev))
-		return skb->dev->netdev_ops->ndo_start_xmit(skb, skb->dev);
+	if (unlikely(netpoll_tx_running(dev)))
+		return vlan_netpoll_send_skb(info, skb);
+
 	ret = dev_queue_xmit(skb);
 
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		struct vlan_pcpu_stats *stats;
 
-		stats = this_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats);
+		stats = this_cpu_ptr(info->vlan_pcpu_stats);
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
 		stats->tx_bytes += len;
 		u64_stats_update_end(&stats->syncp);
 	} else {
-		this_cpu_inc(vlan_dev_priv(dev)->vlan_pcpu_stats->tx_dropped);
+		this_cpu_inc(info->vlan_pcpu_stats->tx_dropped);
 	}
 
 	return ret;
-- 
1.7.7.6
