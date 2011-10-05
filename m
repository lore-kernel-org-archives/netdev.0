From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH] route: fix ICMP redirect validation
Date: Wed,  5 Oct 2011 11:20:04 -0300
Message-ID: <1317824404-9513-1-git-send-email-fbl@redhat.com>
Cc: David Miller <davem@davemloft.net>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934342Ab1JEOUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 10:20:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit f39925dbde7788cfb96419c0f092b086aa325c0f
(ipv4: Cache learned redirect information in inetpeer.)
removed some ICMP packet validations which are required by
RFC 1122, section 3.2.2.2:
...
  A Redirect message SHOULD be silently discarded if the new
  gateway address it specifies is not on the same connected
  (sub-) net through which the Redirect arrived [INTRO:2,
  Appendix A], or if the source of the Redirect is not the
  current first-hop gateway for the specified destination (see
  Section 3.3.1).

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 net/ipv4/route.c |   47 ++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 26c77e1..1c11f28 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1308,7 +1308,12 @@ static void rt_del(unsigned hash, struct rtable *rt)
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
 {
+	int s, i;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
+	__be32 skeys[2] = { saddr, 0 };
+	int    ikeys[2] = { dev->ifindex, 0 };
 	struct inet_peer *peer;
 	struct net *net;
 
@@ -1321,6 +1326,9 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	    ipv4_is_zeronet(new_gw))
 		goto reject_redirect;
 
+	if (!rt_caching(net))
+		goto reject_redirect;;
+
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
 		if (!inet_addr_onlink(in_dev, new_gw, old_gw))
 			goto reject_redirect;
@@ -1331,13 +1339,42 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			goto reject_redirect;
 	}
 
-	peer = inet_getpeer_v4(daddr, 1);
-	if (peer) {
-		peer->redirect_learned.a4 = new_gw;
+	for (s = 0; s < 2; s++) {
+		for (i = 0; i < 2; i++) {
+			unsigned int hash = rt_hash(daddr, skeys[s],
+						    ikeys[i], rt_genid(net));
 
-		inet_putpeer(peer);
+			rthp=&rt_hash_table[hash].chain;
 
-		atomic_inc(&__rt_peer_genid);
+			while ((rth = rcu_dereference(*rthp)) != NULL) {
+
+				if (rth->rt_key_dst != daddr ||
+				    rth->rt_key_src != skeys[s] ||
+				    rth->rt_oif != ikeys[i] ||
+				    rt_is_input_route(rth) ||
+				    rt_is_expired(rth) ||
+				    !net_eq(dev_net(rth->dst.dev), net)) {
+					rthp = &rth->dst.rt_next;
+					continue;
+				}
+
+				if (rth->rt_dst != daddr ||
+				    rth->rt_src != saddr ||
+				    rth->rt_gateway != old_gw ||
+				    rth->dst.dev != dev ||
+				    rth->dst.error)
+					break;
+
+				peer = inet_getpeer_v4(daddr, 1);
+				if (peer) {
+					peer->redirect_learned.a4 = new_gw;
+					inet_putpeer(peer);
+					atomic_inc(&__rt_peer_genid);
+				}
+
+				break;
+			}
+		}
 	}
 	return;
 
-- 
1.7.6
