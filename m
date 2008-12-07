From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH net-next-2.6] [TPROXY] fixes a possible read from an
 unmapped location in the socket match
Date: Sun, 7 Dec 2008 11:16:53 +0100
Message-ID: <1228674863.15263.82.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:51143 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755664AbYLGSnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2008 13:43:40 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id B878C39C599
	for <netdev@vger.kernel.org>; Sun,  7 Dec 2008 19:43:36 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	TIME_WAIT sockets need to be handled specially, and the socket match
	casted inet_timewait_sock instances to inet_sock, which are not
	compatible. Handle this special case by checking sk->sk_state.
---
 net/netfilter/xt_socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 0e03922..1d521a5 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -144,7 +144,7 @@ socket_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
 				   saddr, daddr, sport, dport, par->in, false);
 	if (sk != NULL) {
-		bool wildcard = (inet_sk(sk)->rcv_saddr == 0);
+		bool wildcard = (sk->sk_state != TCP_TIME_WAIT && inet_sk(sk)->rcv_saddr == 0);
 
 		nf_tproxy_put_sock(sk);
 		if (wildcard)
-- 
1.5.6.3


