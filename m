From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 6/8] vxlan: Improve vxlan headroom calculation.
Date: Thu, 20 Jun 2013 00:26:52 -0700
Message-ID: <1371713212-8271-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:58868 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S935028Ab3FTH0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 03:26:55 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so5925169pbc.35
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 00:26:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than having static headroom calculation, adjust headroom
according to target device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6ca2632..e53c947 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1040,6 +1040,7 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
 {
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
+	int min_headroom;
 	int err;
 
 	if (!skb->encapsulation) {
@@ -1047,6 +1048,14 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
 		skb->encapsulation = 1;
 	}
 
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+			+ VXLAN_HLEN + sizeof(struct iphdr);
+
+	/* Need space for new headers (invalidates iph ptr) */
+	err = skb_cow_head(skb, min_headroom);
+	if (unlikely(err))
+		return err;
+
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
@@ -1099,10 +1108,6 @@ static netdev_tx_t __vxlan_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 	}
 
-	/* Need space for new headers (invalidates iph ptr) */
-	if (skb_cow_head(skb, VXLAN_HEADROOM))
-		goto drop;
-
 	old_iph = ip_hdr(skb);
 
 	ttl = vxlan->ttl;
-- 
1.7.1
