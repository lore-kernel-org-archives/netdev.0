From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 1/7] vxlan: avoid vlan processing in vxlan device.
Date: Sun, 13 Nov 2016 20:43:52 -0800
Message-ID: <1479098638-4921-2-git-send-email-pshelar@ovn.org>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:46892 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752144AbcKNEoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 23:44:05 -0500
In-Reply-To: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VxLan device does not have special handling for vlan taging on egress.
Therefore it does not make sense to expose vlan offloading feature.
This patch does not change vxlan functinality.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
Acked-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c     |  9 +--------
 include/linux/if_vlan.h | 16 ----------------
 2 files changed, 1 insertion(+), 24 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index cb5cc7c..756d826 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1748,18 +1748,13 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	}
 
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
-			+ VXLAN_HLEN + iphdr_len
-			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
+			+ VXLAN_HLEN + iphdr_len;
 
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err))
 		goto out_free;
 
-	skb = vlan_hwaccel_push_inside(skb);
-	if (WARN_ON(!skb))
-		return -ENOMEM;
-
 	err = iptunnel_handle_offloads(skb, type);
 	if (err)
 		goto out_free;
@@ -2527,10 +2522,8 @@ static void vxlan_setup(struct net_device *dev)
 	dev->features   |= NETIF_F_GSO_SOFTWARE;
 
 	dev->vlan_features = dev->features;
-	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
-	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 	netif_keep_dst(dev);
 	dev->priv_flags |= IFF_NO_QUEUE;
 
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 3319d97..8d5fcd6 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -399,22 +399,6 @@ static inline struct sk_buff *__vlan_hwaccel_push_inside(struct sk_buff *skb)
 		skb->vlan_tci = 0;
 	return skb;
 }
-/*
- * vlan_hwaccel_push_inside - pushes vlan tag to the payload
- * @skb: skbuff to tag
- *
- * Checks is tag is present in @skb->vlan_tci and if it is, it pushes the
- * VLAN tag from @skb->vlan_tci inside to the payload.
- *
- * Following the skb_unshare() example, in case of error, the calling function
- * doesn't have to worry about freeing the original skb.
- */
-static inline struct sk_buff *vlan_hwaccel_push_inside(struct sk_buff *skb)
-{
-	if (skb_vlan_tag_present(skb))
-		skb = __vlan_hwaccel_push_inside(skb);
-	return skb;
-}
 
 /**
  * __vlan_hwaccel_put_tag - hardware accelerated VLAN inserting
-- 
1.9.1
