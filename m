From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] udp: prevent skbs lingering in tunnel socket queues
Date: Thu, 19 May 2016 15:58:33 +0200
Message-ID: <1463666313-12743-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33984 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754283AbcESOGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 10:06:25 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 671A220C82
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 09:58:39 -0400 (EDT)
Received: from z.localhost.localdomain (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id B2083C00014
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 09:58:38 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we find a socket with encapsulation enabled we should call
the encap_recv function even if just a udp header without payload is
available. The callbacks are responsible for correctly verifying and
dropping the packets.

Also, in case the header validation fails for geneve and vxlan we
shouldn't put the skb back into the socket queue, no one will pick
them up there.  Instead we can simply discard them in the respective
encap_recv functions.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/geneve.c | 10 +++-------
 drivers/net/vxlan.c  |  4 ++--
 net/ipv4/udp.c       |  2 +-
 net/ipv6/udp.c       |  2 +-
 4 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index a6dc11ce497f5c..cadefe4fdaa2aa 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -335,15 +335,15 @@ static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* Need Geneve and inner Ethernet header to be present */
 	if (unlikely(!pskb_may_pull(skb, GENEVE_BASE_HLEN)))
-		goto error;
+		goto drop;
 
 	/* Return packets with reserved bits set */
 	geneveh = geneve_hdr(skb);
 	if (unlikely(geneveh->ver != GENEVE_VER))
-		goto error;
+		goto drop;
 
 	if (unlikely(geneveh->proto_type != htons(ETH_P_TEB)))
-		goto error;
+		goto drop;
 
 	gs = rcu_dereference_sk_user_data(sk);
 	if (!gs)
@@ -366,10 +366,6 @@ drop:
 	/* Consume bad packet */
 	kfree_skb(skb);
 	return 0;
-
-error:
-	/* Let the UDP layer deal with the skb */
-	return 1;
 }
 
 static struct socket *geneve_create_sock(struct net *net, bool ipv6,
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 25ab6bf013c4d2..8ff30c3bdfceab 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1304,7 +1304,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 
 	/* Need UDP and VXLAN header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
-		return 1;
+		goto drop;
 
 	unparsed = *vxlan_hdr(skb);
 	/* VNI flag always required to be set */
@@ -1313,7 +1313,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 			   ntohl(vxlan_hdr(skb)->vx_flags),
 			   ntohl(vxlan_hdr(skb)->vx_vni));
 		/* Return non vxlan pkt */
-		return 1;
+		goto drop;
 	}
 	unparsed.vx_flags &= ~VXLAN_HF_VNI;
 	unparsed.vx_vni &= ~VXLAN_VNI_MASK;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2e3ebfe5549ef5..d56c0559b477cb 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1565,7 +1565,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* if we're overly short, let UDP handle it */
 		encap_rcv = ACCESS_ONCE(up->encap_rcv);
-		if (skb->len > sizeof(struct udphdr) && encap_rcv) {
+		if (encap_rcv) {
 			int ret;
 
 			/* Verify checksum before giving to encap */
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2ba6a77a881532..2da1896af93496 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -617,7 +617,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* if we're overly short, let UDP handle it */
 		encap_rcv = ACCESS_ONCE(up->encap_rcv);
-		if (skb->len > sizeof(struct udphdr) && encap_rcv) {
+		if (encap_rcv) {
 			int ret;
 
 			/* Verify checksum before giving to encap */
-- 
2.5.5
