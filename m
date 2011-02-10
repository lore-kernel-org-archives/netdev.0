From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 1/5] inetpeer: Abstract address representation further.
Date: Wed, 09 Feb 2011 22:13:02 -0800 (PST)
Message-ID: <20110209.221302.183051251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751750Ab1BJGM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 01:12:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EA5FE24C088
	for <netdev@vger.kernel.org>; Wed,  9 Feb 2011 22:13:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Future changes will add caching information, and some of
these new elements will be addresses.

Since the family is implicit via the ->daddr.family member,
replicating the family in ever address we store is entirely
redundant.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |   16 ++++++++++------
 net/ipv4/inetpeer.c    |    6 +++---
 net/ipv4/tcp_ipv4.c    |    2 +-
 net/ipv6/tcp_ipv6.c    |    2 +-
 4 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index ead2cb2..60e2cd8 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -15,12 +15,16 @@
 #include <net/ipv6.h>
 #include <asm/atomic.h>
 
-struct inetpeer_addr {
+struct inetpeer_addr_base {
 	union {
-		__be32		a4;
-		__be32		a6[4];
+		__be32			a4;
+		__be32			a6[4];
 	};
-	__u16	family;
+};
+
+struct inetpeer_addr {
+	struct inetpeer_addr_base	addr;
+	__u16				family;
 };
 
 struct inet_peer {
@@ -67,7 +71,7 @@ static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 {
 	struct inetpeer_addr daddr;
 
-	daddr.a4 = v4daddr;
+	daddr.addr.a4 = v4daddr;
 	daddr.family = AF_INET;
 	return inet_getpeer(&daddr, create);
 }
@@ -76,7 +80,7 @@ static inline struct inet_peer *inet_getpeer_v6(struct in6_addr *v6daddr, int cr
 {
 	struct inetpeer_addr daddr;
 
-	ipv6_addr_copy((struct in6_addr *)daddr.a6, v6daddr);
+	ipv6_addr_copy((struct in6_addr *)daddr.addr.a6, v6daddr);
 	daddr.family = AF_INET6;
 	return inet_getpeer(&daddr, create);
 }
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 709fbb4..4346c38 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -167,9 +167,9 @@ static int addr_compare(const struct inetpeer_addr *a,
 	int i, n = (a->family == AF_INET ? 1 : 4);
 
 	for (i = 0; i < n; i++) {
-		if (a->a6[i] == b->a6[i])
+		if (a->addr.a6[i] == b->addr.a6[i])
 			continue;
-		if (a->a6[i] < b->a6[i])
+		if (a->addr.a6[i] < b->addr.a6[i])
 			return -1;
 		return 1;
 	}
@@ -510,7 +510,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 		p->daddr = *daddr;
 		atomic_set(&p->refcnt, 1);
 		atomic_set(&p->rid, 0);
-		atomic_set(&p->ip_id_count, secure_ip_id(daddr->a4));
+		atomic_set(&p->ip_id_count, secure_ip_id(daddr->addr.a4));
 		p->tcp_ts_stamp = 0;
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 02f583b..e2b9be2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1341,7 +1341,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (dst = inet_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
-		    peer->daddr.a4 == saddr) {
+		    peer->daddr.addr.a4 == saddr) {
 			inet_peer_refcheck(peer);
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 20aa95e..d6954e3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1323,7 +1323,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (dst = inet6_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt6_get_peer((struct rt6_info *)dst)) != NULL &&
-		    ipv6_addr_equal((struct in6_addr *)peer->daddr.a6,
+		    ipv6_addr_equal((struct in6_addr *)peer->daddr.addr.a6,
 				    &treq->rmt_addr)) {
 			inet_peer_refcheck(peer);
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
-- 
1.7.4

