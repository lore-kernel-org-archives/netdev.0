From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: pmtu_expires fixes
Date: Wed, 08 Jun 2011 18:07:07 +0200
Message-ID: <1307549227.3057.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:63696 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab1FHQHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 12:07:11 -0400
Received: by wwk4 with SMTP id 4so3620158wwk.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 09:07:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2c8cec5c10bc (ipv4: Cache learned PMTU information in inetpeer)
added some racy peer->pmtu_expires accesses.

As its value can be changed by another cpu/thread, we should be more
careful, reading its value once.

Add peer_pmtu_expired() and peer_pmtu_cleaned() helpers

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |   78 +++++++++++++++++++++++++--------------------
 1 files changed, 44 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 52b0b95..045f0ec 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1316,6 +1316,23 @@ reject_redirect:
 	;
 }
 
+static bool peer_pmtu_expired(struct inet_peer *peer)
+{
+	unsigned long orig = ACCESS_ONCE(peer->pmtu_expires);
+
+	return orig &&
+	       time_after_eq(jiffies, orig) &&
+	       cmpxchg(&peer->pmtu_expires, orig, 0) == orig;
+}
+
+static bool peer_pmtu_cleaned(struct inet_peer *peer)
+{
+	unsigned long orig = ACCESS_ONCE(peer->pmtu_expires);
+
+	return orig &&
+	       cmpxchg(&peer->pmtu_expires, orig, 0) == orig;
+}
+
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *)dst;
@@ -1331,14 +1348,8 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 						rt_genid(dev_net(dst->dev)));
 			rt_del(hash, rt);
 			ret = NULL;
-		} else if (rt->peer &&
-			   rt->peer->pmtu_expires &&
-			   time_after_eq(jiffies, rt->peer->pmtu_expires)) {
-			unsigned long orig = rt->peer->pmtu_expires;
-
-			if (cmpxchg(&rt->peer->pmtu_expires, orig, 0) == orig)
-				dst_metric_set(dst, RTAX_MTU,
-					       rt->peer->pmtu_orig);
+		} else if (rt->peer && peer_pmtu_expired(rt->peer)) {
+			dst_metric_set(dst, RTAX_MTU, rt->peer->pmtu_orig);
 		}
 	}
 	return ret;
@@ -1531,8 +1542,10 @@ unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
 
 static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer *peer)
 {
-	unsigned long expires = peer->pmtu_expires;
+	unsigned long expires = ACCESS_ONCE(peer->pmtu_expires);
 
+	if (!expires)
+		return;
 	if (time_before(jiffies, expires)) {
 		u32 orig_dst_mtu = dst_mtu(dst);
 		if (peer->pmtu_learned < orig_dst_mtu) {
@@ -1555,10 +1568,11 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 		rt_bind_peer(rt, rt->rt_dst, 1);
 	peer = rt->peer;
 	if (peer) {
+		unsigned long pmtu_expires = ACCESS_ONCE(peer->pmtu_expires);
+
 		if (mtu < ip_rt_min_pmtu)
 			mtu = ip_rt_min_pmtu;
-		if (!peer->pmtu_expires || mtu < peer->pmtu_learned) {
-			unsigned long pmtu_expires;
+		if (!pmtu_expires || mtu < peer->pmtu_learned) {
 
 			pmtu_expires = jiffies + ip_rt_mtu_expires;
 			if (!pmtu_expires)
@@ -1612,13 +1626,14 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 			rt_bind_peer(rt, rt->rt_dst, 0);
 
 		peer = rt->peer;
-		if (peer && peer->pmtu_expires)
+		if (peer) {
 			check_peer_pmtu(dst, peer);
 
-		if (peer && peer->redirect_learned.a4 &&
-		    peer->redirect_learned.a4 != rt->rt_gateway) {
-			if (check_peer_redir(dst, peer))
-				return NULL;
+			if (peer->redirect_learned.a4 &&
+			    peer->redirect_learned.a4 != rt->rt_gateway) {
+				if (check_peer_redir(dst, peer))
+					return NULL;
+			}
 		}
 
 		rt->rt_peer_genid = rt_peer_genid();
@@ -1649,14 +1664,8 @@ static void ipv4_link_failure(struct sk_buff *skb)
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
 
 	rt = skb_rtable(skb);
-	if (rt &&
-	    rt->peer &&
-	    rt->peer->pmtu_expires) {
-		unsigned long orig = rt->peer->pmtu_expires;
-
-		if (cmpxchg(&rt->peer->pmtu_expires, orig, 0) == orig)
-			dst_metric_set(&rt->dst, RTAX_MTU, rt->peer->pmtu_orig);
-	}
+	if (rt && rt->peer && peer_pmtu_cleaned(rt->peer))
+		dst_metric_set(&rt->dst, RTAX_MTU, rt->peer->pmtu_orig);
 }
 
 static int ip_rt_bug(struct sk_buff *skb)
@@ -1770,8 +1779,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			       sizeof(u32) * RTAX_MAX);
 		dst_init_metrics(&rt->dst, peer->metrics, false);
 
-		if (peer->pmtu_expires)
-			check_peer_pmtu(&rt->dst, peer);
+		check_peer_pmtu(&rt->dst, peer);
 		if (peer->redirect_learned.a4 &&
 		    peer->redirect_learned.a4 != rt->rt_gateway) {
 			rt->rt_gateway = peer->redirect_learned.a4;
@@ -2775,7 +2783,8 @@ static int rt_fill_info(struct net *net,
 	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
-	long expires;
+	long expires = 0;
+	const struct inet_peer *peer = rt->peer;
 	u32 id = 0, ts = 0, tsage = 0, error;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
@@ -2823,15 +2832,16 @@ static int rt_fill_info(struct net *net,
 		NLA_PUT_BE32(skb, RTA_MARK, rt->rt_mark);
 
 	error = rt->dst.error;
-	expires = (rt->peer && rt->peer->pmtu_expires) ?
-		rt->peer->pmtu_expires - jiffies : 0;
-	if (rt->peer) {
+	if (peer) {
 		inet_peer_refcheck(rt->peer);
-		id = atomic_read(&rt->peer->ip_id_count) & 0xffff;
-		if (rt->peer->tcp_ts_stamp) {
-			ts = rt->peer->tcp_ts;
-			tsage = get_seconds() - rt->peer->tcp_ts_stamp;
+		id = atomic_read(&peer->ip_id_count) & 0xffff;
+		if (peer->tcp_ts_stamp) {
+			ts = peer->tcp_ts;
+			tsage = get_seconds() - peer->tcp_ts_stamp;
 		}
+		expires = ACCESS_ONCE(peer->pmtu_expires);
+		if (expires)
+			expires -= jiffies;
 	}
 
 	if (rt_is_input_route(rt)) {


