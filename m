From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 4/6] vxlan: Improve vxlan headroom calculation.
Date: Tue, 23 Jul 2013 11:22:45 -0700
Message-ID: <1374603765-15529-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:58555 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933618Ab3GWSWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 14:22:48 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so2636073pab.34
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 11:22:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than having static headroom calculation, adjust headroom
according to target device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 816ce9e..1ca7ca3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1067,6 +1067,7 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
 {
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
+	int min_headroom;
 	int err;
 
 	if (!skb->encapsulation) {
@@ -1074,6 +1075,14 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
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
@@ -1157,10 +1166,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
