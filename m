From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v5 5/7] vxlan: Improve vxlan headroom calculation.
Date: Wed, 31 Jul 2013 16:14:42 -0700
Message-ID: <1375312482-18748-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:39301 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751194Ab3GaXOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:14:45 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so1313763pde.37
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 16:14:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than having static headroom calculation, adjust headroom
according to target device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2329210..f9c7c75 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1114,6 +1114,7 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
 {
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
+	int min_headroom;
 	int err;
 
 	if (!skb->encapsulation) {
@@ -1121,6 +1122,14 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
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
@@ -1204,10 +1213,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
