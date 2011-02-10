From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 2/5] inetpeer: Add redirect and PMTU discovery cached
 info.
Date: Wed, 09 Feb 2011 22:13:14 -0800 (PST)
Message-ID: <20110209.221314.39184889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33140
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752200Ab1BJGMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 01:12:38 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DE8EB24C088
	for <netdev@vger.kernel.org>; Wed,  9 Feb 2011 22:13:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Validity of the cached PMTU information is indicated by it's
expiration value being non-zero, just as per dst->expires.

The scheme we will use is that we will remember the pre-ICMP value
held in the metrics or route entry, and then at expiration time
we will restore that value.

In this way PMTU expiration does not kill off the cached route as is
done currently.

Redirect information is permanent, or at least until another redirect
is received.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |   18 +++++++++++-------
 net/ipv4/inetpeer.c    |    2 ++
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 60e2cd8..e6dd8da6 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -43,13 +43,17 @@ struct inet_peer {
 	 */
 	union {
 		struct {
-			atomic_t	rid;		/* Frag reception counter */
-			atomic_t	ip_id_count;	/* IP ID for the next packet */
-			__u32		tcp_ts;
-			__u32		tcp_ts_stamp;
-			u32		metrics[RTAX_MAX];
-			u32		rate_tokens;	/* rate limiting for ICMP */
-			unsigned long	rate_last;
+			atomic_t			rid;		/* Frag reception counter */
+			atomic_t			ip_id_count;	/* IP ID for the next packet */
+			__u32				tcp_ts;
+			__u32				tcp_ts_stamp;
+			u32				metrics[RTAX_MAX];
+			u32				rate_tokens;	/* rate limiting for ICMP */
+			unsigned long			rate_last;
+			unsigned long			pmtu_expires;
+			u32				pmtu_orig;
+			u32				pmtu_learned;
+			struct inetpeer_addr_base	redirect_learned;
 		};
 		struct rcu_head         rcu;
 	};
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 4346c38..48f8d45 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -515,6 +515,8 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
 		p->rate_last = 0;
+		p->pmtu_expires = 0;
+		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
 		INIT_LIST_HEAD(&p->unused);
 
 
-- 
1.7.4

