From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH vxlan v2 7/8] vxlan: Add tx-vlan offload support.
Date: Wed, 26 Jun 2013 13:14:03 -0700
Message-ID: <1372277643-17701-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:37561 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752452Ab3FZUOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:14:06 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so31450pab.13
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 13:14:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch allows transmit side vlan offload for vxlan
devices.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0125c57..d573458 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -27,6 +27,7 @@
 #include <linux/igmp.h>
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
+#include <linux/if_vlan.h>
 #include <linux/hash.h>
 #include <linux/ethtool.h>
 #include <net/arp.h>
@@ -1078,13 +1079,23 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
 	}
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ VXLAN_HLEN + sizeof(struct iphdr);
+			+ VXLAN_HLEN + sizeof(struct iphdr)
+			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
 
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err))
 		return err;
 
+	if (vlan_tx_tag_present(skb)) {
+		if (unlikely(!__vlan_put_tag(skb,
+					     skb->vlan_proto,
+					     vlan_tx_tag_get(skb))))
+			return -ENOMEM;
+
+		skb->vlan_tci = 0;
+	}
+
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
@@ -1476,6 +1487,8 @@ static void vxlan_setup(struct net_device *dev)
 	dev->features   |= NETIF_F_RXCSUM;
 	dev->features   |= NETIF_F_GSO_SOFTWARE;
 
+	dev->vlan_features = dev->features;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX;
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
-- 
1.7.1
