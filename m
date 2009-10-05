From: Atis Elsts <atis@mikrotik.com>
Subject: [PATCH] Add sk_mark route lookup support for IPv4 listening sockets, and for IPv4 multicast forwarding
Date: Mon, 5 Oct 2009 16:46:34 +0300
Message-ID: <200910051646.34770.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, panther@balabit.hu,
	eric.dumazet@gmail.com, brian.haley@hp.com, zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:43452 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810AbZJENrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 09:47:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is followup to my previous route lookup patch, it adds sk_mark based routing lookup support in even more places. Now it is possible to have e.g. TCP server listening to connection requests in a specific routing table specified by SO_MARK socket option.

Also, correct me if I'm wrong, but syncookie route lookup still seems to be broken in more than one way. The sk_bound_dev_if interface from socket is not used; and route lookup is done in init_net, instead of using sock_net(sk).
cookie_v6_check() in net/ipv6/syncookies.c probably needs a patch as well.


Add support for route lookup using sk_mark on IPv4 listening sockets, and for IPv4 multicast forwarding
Signed-off-by: Atis Elsts <atis@mikrotik.com>
---
 net/ipv4/inet_connection_sock.c |    1 +
 net/ipv4/ipmr.c                 |    2 ++
 net/ipv4/syncookies.c           |    3 ++-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 4351ca2..9139e8f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -358,6 +358,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options *opt = inet_rsk(req)->opt;
 	struct flowi fl = { .oif = sk->sk_bound_dev_if,
+			    .mark = sk->sk_mark,
 			    .nl_u = { .ip4_u =
 				      { .daddr = ((opt && opt->srr) ?
 						  opt->faddr :
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 630a56d..66c58e4 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1238,6 +1238,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 
 	if (vif->flags&VIFF_TUNNEL) {
 		struct flowi fl = { .oif = vif->link,
+				    .mark = skb->mark,
 				    .nl_u = { .ip4_u =
 					      { .daddr = vif->remote,
 						.saddr = vif->local,
@@ -1248,6 +1249,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 		encap = sizeof(struct iphdr);
 	} else {
 		struct flowi fl = { .oif = vif->link,
+				    .mark = skb->mark,
 				    .nl_u = { .ip4_u =
 					      { .daddr = iph->daddr,
 						.tos = RT_TOS(iph->tos) } },
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index a6e0e07..5ec678a 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -333,7 +333,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 * no easy way to do this.
 	 */
 	{
-		struct flowi fl = { .nl_u = { .ip4_u =
+		struct flowi fl = { .mark = sk->sk_mark,
+				    .nl_u = { .ip4_u =
 					      { .daddr = ((opt && opt->srr) ?
 							  opt->faddr :
 							  ireq->rmt_addr),
