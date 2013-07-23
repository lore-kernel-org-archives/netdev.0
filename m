From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 5/6] vxlan: Add tx-vlan offload support.
Date: Tue, 23 Jul 2013 11:22:50 -0700
Message-ID: <1374603770-15567-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:52350 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933618Ab3GWSWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 14:22:53 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so3149356pab.11
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 11:22:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch allows transmit side vlan offload for vxlan
devices.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1ca7ca3..f76c09c 100644
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
@@ -1076,13 +1077,23 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
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
@@ -1486,6 +1497,8 @@ static void vxlan_setup(struct net_device *dev)
 	dev->features   |= NETIF_F_RXCSUM;
 	dev->features   |= NETIF_F_GSO_SOFTWARE;
 
+	dev->vlan_features = dev->features;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX;
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
-- 
1.7.1
