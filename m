From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4] ipv4: Pass explicit destination address to
 rt_get_peer().
Date: Wed, 18 May 2011 18:56:38 -0400 (EDT)
Message-ID: <20110518.185638.2259430129185983305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755621Ab1ERW4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:56:40 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4IMucaq017416
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 15:56:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will next trickle down to rt_bind_peer().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    2 +-
 net/ipv4/tcp_ipv4.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index ba0e084..600d0f2 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -292,7 +292,7 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 
 extern void rt_bind_peer(struct rtable *rt, int create);
 
-static inline struct inet_peer *rt_get_peer(struct rtable *rt)
+static inline struct inet_peer *rt_get_peer(struct rtable *rt, __be32 daddr)
 {
 	if (rt->peer)
 		return rt->peer;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7e0bc60..1d290ac 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -206,7 +206,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	if (tcp_death_row.sysctl_tw_recycle &&
 	    !tp->rx_opt.ts_recent_stamp && fl4->daddr == daddr) {
-		struct inet_peer *peer = rt_get_peer(rt);
+		struct inet_peer *peer = rt_get_peer(rt, fl4->daddr);
 		/*
 		 * VJ's idea. We save last timestamp seen from
 		 * the destination in peer table, when entering state
@@ -1353,8 +1353,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (dst = inet_csk_route_req(sk, &fl4, req)) != NULL &&
-		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
-		    peer->daddr.addr.a4 == saddr) {
+		    fl4.daddr == saddr &&
+		    (peer = rt_get_peer((struct rtable *)dst, fl4.daddr)) != NULL) {
 			inet_peer_refcheck(peer);
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
-- 
1.7.4.4

