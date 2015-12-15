From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 1/2] fou: clean up socket with kfree_rcu
Date: Tue, 15 Dec 2015 21:01:53 +0100
Message-ID: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55082 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932190AbbLOUCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 15:02:06 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 9CDD721F64
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 15:02:05 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fou->udp_offloads is managed by RCU. As it is actually included inside
the fou sockets, we cannot let the memory go out of scope before a grace
period. We either can synchronize_rcu or switch over to kfree_rcu to
manage the sockets. kfree_rcu seems appropriate as it is used by vxlan
and geneve.

Fixes: 23461551c00628c ("fou: Support for foo-over-udp RX path")
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/fou.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index e0fcbbbcfe54d0..bd903fe0f7508d 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -24,6 +24,7 @@ struct fou {
 	u16 type;
 	struct udp_offload udp_offloads;
 	struct list_head list;
+	struct rcu_head rcu;
 };
 
 #define FOU_F_REMCSUM_NOPARTIAL BIT(0)
@@ -417,7 +418,7 @@ static void fou_release(struct fou *fou)
 	list_del(&fou->list);
 	udp_tunnel_sock_release(sock);
 
-	kfree(fou);
+	kfree_rcu(fou, rcu);
 }
 
 static int fou_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
-- 
2.5.0
