From: Jesse Gross <jesse@kernel.org>
Subject: [PATCH net v2 1/3] ipip: Properly mark ipip GRO packets as encapsulated.
Date: Sat, 19 Mar 2016 09:32:00 -0700
Message-ID: <1458405122-12565-2-git-send-email-jesse@kernel.org>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
Cc: netdev@vger.kernel.org, Patrick Boutilier <boutilpj@ednet.ns.ca>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55636 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbcCSQco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 12:32:44 -0400
In-Reply-To: <1458405122-12565-1-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipip encapsulated packets can be merged together by GRO but the result
does not have the proper GSO type set or even marked as being
encapsulated at all. Later retransmission of these packets will likely
fail if the device does not support ipip offloads. This is similar to
the issue resolved in IPv6 sit in feec0cb3
("ipv6: gro: support sit protocol").

Reported-by: Patrick Boutilier <boutilpj@ednet.ns.ca>
Fixes: 9667e9bb ("ipip: Add gro callbacks to ipip offload")
Tested-by: Patrick Boutilier <boutilpj@ednet.ns.ca>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jesse Gross <jesse@kernel.org>
---
v2: No change.
---
 net/ipv4/af_inet.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0cc923f..9659233 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1448,6 +1448,13 @@ out_unlock:
 	return err;
 }
 
+static int ipip_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_IPIP;
+	return inet_gro_complete(skb, nhoff);
+}
+
 int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 unsigned short type, unsigned char protocol,
 			 struct net *net)
@@ -1676,7 +1683,7 @@ static const struct net_offload ipip_offload = {
 	.callbacks = {
 		.gso_segment	= inet_gso_segment,
 		.gro_receive	= inet_gro_receive,
-		.gro_complete	= inet_gro_complete,
+		.gro_complete	= ipip_gro_complete,
 	},
 };
 
-- 
2.5.0
