From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next v2 2/5] tcp: metrics: Add source-address to
 tcp-metrics
Date: Wed, 8 Jan 2014 23:43:44 +0100
Message-ID: <20140108224344.GE4700@cpaasch-mac>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
 <1389193559-16756-3-git-send-email-christoph.paasch@uclouvain.be>
 <1389203751.26646.100.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47258 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757167AbaAHWnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 17:43:52 -0500
Content-Disposition: inline
In-Reply-To: <1389203751.26646.100.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On 08/01/14 - 09:55:51, Eric Dumazet wrote:
> On Wed, 2014-01-08 at 16:05 +0100, Christoph Paasch wrote:
> > We add the source-address to the tcp-metrics, so that different metrics
> > will be used per source/destination-pair. We use the destination-hash to
> > store the metric inside the hash-table. That way, deleting and dumping
> > via "ip tcp_metrics" is easy.
> 
> Note that this has the following problem :
> 
> Some applications use a set of source IP addresses to overcome the 64K
> port limitation.

Ok, did not know about that.

> tcp_metrics uses a hard-coded TCP_METRICS_RECLAIM_DEPTH value of 5,
> meaning that cache wont be able to store more than 5 source IP addresses
> (reaching one particular remote IP).

Maybe we could do something like the below (yet untested). That way we allow
up to 32 entries with the same destination but different source and still
only 5 with different destinations.

I guess 32 * 64K connections is enough. :)
We could also make TCP_METRICS_RECLAIM_DEPTH(_DST) a tunable.


diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 699a42faab9c..0418ac318e7d 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -181,13 +181,18 @@ static void tcpm_check_stamp(struct tcp_metrics_block *tm, struct dst_entry *dst
 }
 
 #define TCP_METRICS_RECLAIM_DEPTH	5
+#define TCP_METRICS_RECLAIM_DEPTH_DST	32
 #define TCP_METRICS_RECLAIM_PTR		(struct tcp_metrics_block *) 0x1UL
 
-static struct tcp_metrics_block *tcp_get_encode(struct tcp_metrics_block *tm, int depth)
+static struct tcp_metrics_block *tcp_get_encode(struct tcp_metrics_block *tm,
+						int depth_general,
+						int depth_dst)
 {
 	if (tm)
 		return tm;
-	if (depth > TCP_METRICS_RECLAIM_DEPTH)
+	if (depth_general > TCP_METRICS_RECLAIM_DEPTH)
+		return TCP_METRICS_RECLAIM_PTR;
+	if (depth_dst > TCP_METRICS_RECLAIM_DEPTH_DST)
 		return TCP_METRICS_RECLAIM_PTR;
 	return NULL;
 }
@@ -197,16 +202,19 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *s
 						   struct net *net, unsigned int hash)
 {
 	struct tcp_metrics_block *tm;
-	int depth = 0;
+	int depth_dst = 0, depth_general = 0;
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if (addr_same(&tm->tcpm_saddr, saddr) &&
 		    addr_same(&tm->tcpm_daddr, daddr))
 			break;
-		depth++;
+		if (addr_same(&tm->tcpm_daddr, daddr))
+			depth_dst++;
+		else
+			depth_general++;
 	}
-	return tcp_get_encode(tm, depth);
+	return tcp_get_encode(tm, depth_general, depth_dst);
 }
 
 static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
