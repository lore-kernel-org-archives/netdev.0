From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] r8152: drop the tx packet with invalid length
Date: Fri, 19 Dec 2014 10:13:57 -0800
Message-ID: <1419012837.9773.85.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417020748.29427.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.120658.498602780456343676.davem@davemloft.net>
	 <1417027459.29427.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.153356.461494573591656082.davem@davemloft.net>
	 <0835B3720019904CB8F7AA43166CEEB2ED585A@RTITMBSV03.realtek.com.tw>
	 <1419010603.9773.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419010603.9773.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-12-19 at 09:36 -0800, Eric Dumazet wrote:
> On Fri, 2014-12-19 at 06:42 +0000, Hayes Wang wrote:
> 
> > Excuse me. I try to implement ndo_gso_check() with kernel 3.18.
> > However, I still get packets with gso and their skb lengths are more
> > than the acceptable one. Do I miss something?
> > 
> > +static bool rtl8152_gso_check(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	if ((skb->len + sizeof(struct tx_desc)) > agg_buf_sz)
> > +		return false;
> > +
> > +	return true;
> > +}
> >  
> > @@ -5861,6 +5876,9 @@ static const struct net_device_ops rtl8152_netdev_ops = {
> >  	.ndo_set_mac_address	= rtl8152_set_mac_address,
> >  	.ndo_change_mtu		= rtl8152_change_mtu,
> >  	.ndo_validate_addr	= eth_validate_addr,
> > +	.ndo_gso_check		= rtl8152_gso_check,
> >  };
> 
> You are right, it seems ndo_gso_check() is buggy at this moment.
> 
> Presumably this method should alter %features so that we really segment
> the packets in software.
> 
> features &= ~NETIF_F_GSO_MASK;

Could you try following patch ?

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7df221788cd4..0346bcfe72a5 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -314,7 +314,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 	 */
 	if (q->flags & IFF_VNET_HDR)
 		features |= vlan->tap_features;
-	if (netif_needs_gso(dev, skb, features)) {
+	if (netif_needs_gso(dev, skb, &features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
 		if (IS_ERR(segs))
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 22bcb4e12e2a..9cacabaea175 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -578,6 +578,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	struct netfront_queue *queue = NULL;
 	unsigned int num_queues = dev->real_num_tx_queues;
+	netdev_features_t features;
 	u16 queue_index;
 
 	/* Drop the packet if no queues are set up */
@@ -611,9 +612,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&queue->tx_lock, flags);
 
+	features = netif_skb_features(skb);
 	if (unlikely(!netif_carrier_ok(dev) ||
 		     (slots > 1 && !xennet_can_sg(dev)) ||
-		     netif_needs_gso(dev, skb, netif_skb_features(skb)))) {
+		     netif_needs_gso(dev, skb, &features))) {
 		spin_unlock_irqrestore(&queue->tx_lock, flags);
 		goto drop;
 	}
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c31f74d76ebd..fb1f8c900df9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3608,13 +3608,19 @@ static inline bool skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
 }
 
 static inline bool netif_needs_gso(struct net_device *dev, struct sk_buff *skb,
-				   netdev_features_t features)
+				   netdev_features_t *features)
 {
-	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
-		(dev->netdev_ops->ndo_gso_check &&
-		 !dev->netdev_ops->ndo_gso_check(skb, dev)) ||
-		unlikely((skb->ip_summed != CHECKSUM_PARTIAL) &&
-			 (skb->ip_summed != CHECKSUM_UNNECESSARY)));
+	if (!skb_is_gso(skb))
+		return false;
+	if (!skb_gso_ok(skb, *features))
+		return true;
+	if (dev->netdev_ops->ndo_gso_check &&
+	    !dev->netdev_ops->ndo_gso_check(skb, dev)) {
+		*features &= ~NETIF_F_GSO_MASK;
+		return true;
+	}
+	return skb->ip_summed != CHECKSUM_PARTIAL &&
+	       skb->ip_summed != CHECKSUM_UNNECESSARY;
 }
 
 static inline void netif_set_gso_max_size(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index f411c28d0a66..b61c26b45bb7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2668,7 +2668,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 	if (skb->encapsulation)
 		features &= dev->hw_enc_features;
 
-	if (netif_needs_gso(dev, skb, features)) {
+	if (netif_needs_gso(dev, skb, &features)) {
 		struct sk_buff *segs;
 
 		segs = skb_gso_segment(skb, features);
