From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH vxlan v2 6/8] vxlan: Improve vxlan headroom calculation.
Date: Wed, 26 Jun 2013 13:13:56 -0700
Message-ID: <1372277636-17662-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:51702 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752452Ab3FZUOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:14:03 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so14657592pbc.32
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 13:14:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than having static headroom calculation, adjust headroom
according to target device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d642d4d..0125c57 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1069,6 +1069,7 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
 {
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
+	int min_headroom;
 	int err;
 
 	if (!skb->encapsulation) {
@@ -1076,6 +1077,14 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
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
@@ -1159,10 +1168,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
