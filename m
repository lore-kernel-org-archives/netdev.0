From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: conditionally expand buffer headroom over udp tunnel
Date: Mon, 19 Oct 2015 11:43:11 -0400
Message-ID: <1445269391-30333-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.biz.mail.bf1.yahoo.com ([98.139.244.55]:21066 "EHLO
	smtp107.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752150AbbJSPnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 11:43:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit d999297c3dbbe ("tipc: reduce locking scope during packet reception")
we altered the packet retransmission function. Since then, when
restransmitting packets, we create a clone of the original buffer
using __pskb_copy(skb, MIN_H_SIZE), where MIN_H_SIZE is the size of
the area we want to have copied, but also the smallest possible TIPC
packet size. The value of MIN_H_SIZE is 24.

Unfortunately, __pskb_copy() also has the effect that the headroom
of the cloned buffer takes the size MIN_H_SIZE. This is too small
for carrying the packet over the UDP tunnel bearer, which requires
a minimum headroom of 28 bytes. A change to just use pskb_copy()
lets the clone inherit the original headroom of 80 bytes, but also
assumes that the copied data area is of at least that size, something
that is not always the case. So that is not a viable solution.

We now fix this by adding a check for sufficient headroom in the
transmit function of udp_media.c, and expanding it when necessary.

Fixes: commit d999297c3dbbe ("tipc: reduce locking scope during packet reception")
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/udp_media.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index c170d31..6e648d9 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -52,6 +52,8 @@
 /* IANA assigned UDP port */
 #define UDP_PORT_DEFAULT	6118
 
+#define UDP_MIN_HEADROOM        28
+
 static const struct nla_policy tipc_nl_udp_policy[TIPC_NLA_UDP_MAX + 1] = {
 	[TIPC_NLA_UDP_UNSPEC]	= {.type = NLA_UNSPEC},
 	[TIPC_NLA_UDP_LOCAL]	= {.type = NLA_BINARY,
@@ -156,6 +158,9 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 	struct sk_buff *clone;
 	struct rtable *rt;
 
+	if (skb_headroom(skb) < UDP_MIN_HEADROOM)
+		pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
+
 	clone = skb_clone(skb, GFP_ATOMIC);
 	skb_set_inner_protocol(clone, htons(ETH_P_TIPC));
 	ub = rcu_dereference_rtnl(b->media_ptr);
-- 
1.9.1
