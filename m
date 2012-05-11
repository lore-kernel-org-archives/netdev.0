From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_set_dev do not unconditionally drop ref to dst
Date: Thu, 10 May 2012 23:06:11 -0400 (EDT)
Message-ID: <20120510.230611.551784978338373902.davem@davemloft.net>
References: <1335941961.22133.48.camel@edumazet-glaptop>
	<20120503.022837.2021054007853235758.davem@davemloft.net>
	<20120509104803.GA52076@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, linux-s390@vger.kernel.org,
	eric.dumazet@gmail.com
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932315Ab2EKDGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:06:18 -0400
In-Reply-To: <20120509104803.GA52076@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Wed, 9 May 2012 12:48:03 +0200

> On Thu, May 03, 2012 at 02:28:37AM -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 02 May 2012 08:59:21 +0200
>> 
>> > If Arnd doesnt care to even reply, we can just revert his buggy
>> > patch, instead of trying to understand and fix all issues.
>> 
>> Agreed, it's the best sounding solution by far.
> Hi Dave,
> 
> looks like discussion is done and everybody is ok with reverting
> Arnds patch. Can you revert commit 8a83a00b0735190384a348156837918271034144 ?

Done, and I'll queue this up for -stable too.

[PATCH] Revert "net: maintain namespace isolation between vlan and real device"

This reverts commit 8a83a00b0735190384a348156837918271034144.

It causes regressions for S390 devices, because it does an
unconditional DST drop on SKBs for vlans and the QETH device
needs the neighbour entry hung off the DST for certain things
on transmit.

Arnd can't remember exactly why he even needed this change.

Conflicts:

	drivers/net/macvlan.c
	net/8021q/vlan_dev.c
	net/core/dev.c

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/macvlan.c     |    2 +-
 include/linux/netdevice.h |    9 ---------
 net/8021q/vlan_dev.c      |    2 +-
 net/core/dev.c            |   36 +++++-------------------------------
 4 files changed, 7 insertions(+), 42 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f975afd..025367a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -259,7 +259,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 xmit_world:
 	skb->ip_summed = ip_summed;
-	skb_set_dev(skb, vlan->lowerdev);
+	skb->dev = vlan->lowerdev;
 	return dev_queue_xmit(skb);
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5cbaa20..33900a5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1403,15 +1403,6 @@ static inline bool netdev_uses_dsa_tags(struct net_device *dev)
 	return 0;
 }
 
-#ifndef CONFIG_NET_NS
-static inline void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
-{
-	skb->dev = dev;
-}
-#else /* CONFIG_NET_NS */
-void skb_set_dev(struct sk_buff *skb, struct net_device *dev);
-#endif
-
 static inline bool netdev_uses_trailer_tags(struct net_device *dev)
 {
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9988d4a..9757c19 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -157,7 +157,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 	}
 
-	skb_set_dev(skb, vlan_dev_priv(dev)->real_dev);
+	skb->dev = vlan_dev_priv(dev)->real_dev;
 	len = skb->len;
 	if (netpoll_tx_running(dev))
 		return skb->dev->netdev_ops->ndo_start_xmit(skb, skb->dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9bb8f87..99e1d75 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1617,10 +1617,14 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		return NET_RX_DROP;
 	}
 	skb->skb_iif = 0;
-	skb_set_dev(skb, dev);
+	skb->dev = dev;
+	skb_dst_drop(skb);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, dev);
+	skb->mark = 0;
+	secpath_reset(skb);
+	nf_reset(skb);
 	return netif_rx(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
@@ -1869,36 +1873,6 @@ void netif_device_attach(struct net_device *dev)
 }
 EXPORT_SYMBOL(netif_device_attach);
 
-/**
- * skb_dev_set -- assign a new device to a buffer
- * @skb: buffer for the new device
- * @dev: network device
- *
- * If an skb is owned by a device already, we have to reset
- * all data private to the namespace a device belongs to
- * before assigning it a new device.
- */
-#ifdef CONFIG_NET_NS
-void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
-{
-	skb_dst_drop(skb);
-	if (skb->dev && !net_eq(dev_net(skb->dev), dev_net(dev))) {
-		secpath_reset(skb);
-		nf_reset(skb);
-		skb_init_secmark(skb);
-		skb->mark = 0;
-		skb->priority = 0;
-		skb->nf_trace = 0;
-		skb->ipvs_property = 0;
-#ifdef CONFIG_NET_SCHED
-		skb->tc_index = 0;
-#endif
-	}
-	skb->dev = dev;
-}
-EXPORT_SYMBOL(skb_set_dev);
-#endif /* CONFIG_NET_NS */
-
 static void skb_warn_bad_offload(const struct sk_buff *skb)
 {
 	static const netdev_features_t null_features = 0;
-- 
1.7.10.1
