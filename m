From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: [PATCH][LRO] Fix lro_mgr->features checks
Date: Mon, 07 Jan 2008 14:33:32 +0100
Message-ID: <47822A2C.4020303@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew J. Gallatin" <gallatin@myri.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Linus Torvalds <torvalds@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:50087 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbYAGOAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 09:00:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The LRO_F_* checks in inet_lro.c are buggy, the following patch
is needed to check lro_mgr->features correctly.

I decided to follow the NETIF_F_* convention and thus removed
test_bit. Some people might like it better if we keep using
test_bit and just set lro_mgr->features to 1<<LRO_F_NAPI instead
of just LRO_F_NAPI. I don't know what's the best.

Without this patch, we noticed several problems with myri10ge,
at least when using non-IP packets. I guess the ehea driver did
not expose any big problem because test_bit(NAPI) returns true
thanks to lro_mgr->features containing LRO_F_EXTRACT_VLAN_ID.

Please apply for 2.6.24.

Brice



[PATCH][LRO] Fix lro_mgr->features checks

lro_mgr->features contains a bitmask of LRO_F_* values which are
defined as power of two, not as bit indexes.
They must be checked with x&LRO_F_FOO, not with test_bit(LRO_F_FOO,&x).

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Acked-by: Andrew Gallatin <gallatin@myri.com>
---
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 9a96c27..4a4d49f 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -310,7 +310,7 @@ static void lro_flush(struct net_lro_mgr *lro_mgr,
 	skb_shinfo(lro_desc->parent)->gso_size = lro_desc->mss;
 
 	if (lro_desc->vgrp) {
-		if (test_bit(LRO_F_NAPI, &lro_mgr->features))
+		if (lro_mgr->features & LRO_F_NAPI)
 			vlan_hwaccel_receive_skb(lro_desc->parent,
 						 lro_desc->vgrp,
 						 lro_desc->vlan_tag);
@@ -320,7 +320,7 @@ static void lro_flush(struct net_lro_mgr *lro_mgr,
 					lro_desc->vlan_tag);
 
 	} else {
-		if (test_bit(LRO_F_NAPI, &lro_mgr->features))
+		if (lro_mgr->features & LRO_F_NAPI)
 			netif_receive_skb(lro_desc->parent);
 		else
 			netif_rx(lro_desc->parent);
@@ -352,7 +352,7 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
 		goto out;
 
 	if ((skb->protocol == htons(ETH_P_8021Q))
-	    && !test_bit(LRO_F_EXTRACT_VLAN_ID, &lro_mgr->features))
+	    && !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
 		vlan_hdr_len = VLAN_HLEN;
 
 	if (!lro_desc->active) { /* start new lro session */
@@ -474,7 +474,7 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
 			goto out;
 
 		if ((skb->protocol == htons(ETH_P_8021Q))
-		    && !test_bit(LRO_F_EXTRACT_VLAN_ID, &lro_mgr->features))
+		    && !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
 			vlan_hdr_len = VLAN_HLEN;
 
 		iph = (void *)(skb->data + vlan_hdr_len);
@@ -516,7 +516,7 @@ void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     void *priv)
 {
 	if (__lro_proc_skb(lro_mgr, skb, NULL, 0, priv)) {
-		if (test_bit(LRO_F_NAPI, &lro_mgr->features))
+		if (lro_mgr->features & LRO_F_NAPI)
 			netif_receive_skb(skb);
 		else
 			netif_rx(skb);
@@ -531,7 +531,7 @@ void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
 				  void *priv)
 {
 	if (__lro_proc_skb(lro_mgr, skb, vgrp, vlan_tag, priv)) {
-		if (test_bit(LRO_F_NAPI, &lro_mgr->features))
+		if (lro_mgr->features & LRO_F_NAPI)
 			vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
 		else
 			vlan_hwaccel_rx(skb, vgrp, vlan_tag);
@@ -550,7 +550,7 @@ void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 	if (!skb)
 		return;
 
-	if (test_bit(LRO_F_NAPI, &lro_mgr->features))
+	if (lro_mgr->features & LRO_F_NAPI)
 		netif_receive_skb(skb);
 	else
 		netif_rx(skb);
@@ -570,7 +570,7 @@ void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
 	if (!skb)
 		return;
 
-	if (test_bit(LRO_F_NAPI, &lro_mgr->features))
+	if (lro_mgr->features & LRO_F_NAPI)
 		vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
 	else
 		vlan_hwaccel_rx(skb, vgrp, vlan_tag);


