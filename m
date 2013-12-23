From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] vxlan: distribute vxlan tunneled traffic across multiple TXQs
Date: Mon, 23 Dec 2013 18:26:53 +0530
Message-ID: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <edumazet@google.com>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:24967 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab3LWMwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 07:52:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vxlan driver sets itself as the socket owner for all the TX flows
it encapsulates (using vxlan_set_owner()) and assigns it's own skb
destructor. This causes all tunneled traffic to land up on only one TXQ
as all encapsulated skbs refer to the vxlan socket and not the original
socket.  Also, the vxlan skb destructor breaks some functionality for
tunneled traffic like wmem accounting and as Eric D. mentioned, TCP
small queues and FQ/pacing packet scheduler too.

This patch removes vxlan ownership on tunneled skbs. This causes
tunneled traffic to be hashed into multiple TXQs based on the original
socket hash.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/vxlan.c |   22 +++-------------------
 1 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index aef44aa..eb55c08 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1381,20 +1381,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-static void vxlan_sock_put(struct sk_buff *skb)
-{
-	sock_put(skb->sk);
-}
-
-/* On transmit, associate with the tunnel socket */
-static void vxlan_set_owner(struct sock *sk, struct sk_buff *skb)
-{
-	skb_orphan(skb);
-	sock_hold(sk);
-	skb->sk = sk;
-	skb->destructor = vxlan_sock_put;
-}
-
 /* Compute source port for outgoing packet
  *   first choice to use L4 flow hash since it will spread
  *     better and maybe available from hardware
@@ -1514,8 +1500,6 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	ip6h->daddr	  = *daddr;
 	ip6h->saddr	  = *saddr;
 
-	vxlan_set_owner(vs->sock->sk, skb);
-
 	err = handle_offloads(skb);
 	if (err)
 		return err;
@@ -1572,8 +1556,6 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	uh->len = htons(skb->len);
 	uh->check = 0;
 
-	vxlan_set_owner(vs->sock->sk, skb);
-
 	err = handle_offloads(skb);
 	if (err)
 		return err;
@@ -1836,8 +1818,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct sk_buff *skb1;
 
 		skb1 = skb_clone(skb, GFP_ATOMIC);
-		if (skb1)
+		if (skb1) {
+			skb1->sk = skb->sk;
 			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
+		}
 	}
 
 	dev_kfree_skb(skb);
-- 
1.7.1
