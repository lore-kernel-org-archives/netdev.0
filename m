From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/8]ipv6: Change final dst lookup arg name to "can_sleep"
Date: Tue, 01 Mar 2011 15:11:32 -0800 (PST)
Message-ID: <20110301.151132.232753967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48516
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756980Ab1CAXKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:10:55 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9113124C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since it indicates whether we are invoked from a sleepable
context or not.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ipv6.h    |    4 ++--
 net/ipv6/ip6_output.c |   12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1fc5631..8f78aac 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -515,11 +515,11 @@ extern int			ip6_dst_lookup(struct sock *sk,
 extern struct dst_entry *	ip6_dst_lookup_flow(struct sock *sk,
 						    struct flowi *fl,
 						    const struct in6_addr *final_dst,
-						    bool want_blackhole);
+						    bool can_sleep);
 extern struct dst_entry *	ip6_sk_dst_lookup_flow(struct sock *sk,
 						       struct flowi *fl,
 						       const struct in6_addr *final_dst,
-						       bool want_blackhole);
+						       bool can_sleep);
 extern int			ip6_dst_blackhole(struct sock *sk,
 						  struct dst_entry **dst,
 						  struct flowi *fl);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 77b1942..b5f8769 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1006,7 +1006,7 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup);
  *	@sk: socket which provides route info
  *	@fl: flow to lookup
  *	@final_dst: final destination address for ipsec lookup
- *	@want_blackhole: IPSEC blackhole handling desired
+ *	@can_sleep: we are in a sleepable context
  *
  *	This function performs a route lookup on the given flow.
  *
@@ -1015,7 +1015,7 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup);
  */
 struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 				      const struct in6_addr *final_dst,
-				      bool want_blackhole)
+				      bool can_sleep)
 {
 	struct dst_entry *dst = NULL;
 	int err;
@@ -1025,7 +1025,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		return ERR_PTR(err);
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
-	if (want_blackhole) {
+	if (can_sleep) {
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
 		if (err == -EREMOTE)
@@ -1046,7 +1046,7 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
  *	@sk: socket which provides the dst cache and route info
  *	@fl: flow to lookup
  *	@final_dst: final destination address for ipsec lookup
- *	@want_blackhole: IPSEC blackhole handling desired
+ *	@can_sleep: we are in a sleepable context
  *
  *	This function performs a route lookup on the given flow with the
  *	possibility of using the cached route in the socket if it is valid.
@@ -1058,7 +1058,7 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
  */
 struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 					 const struct in6_addr *final_dst,
-					 bool want_blackhole)
+					 bool can_sleep)
 {
 	struct dst_entry *dst = sk_dst_check(sk, inet6_sk(sk)->dst_cookie);
 	int err;
@@ -1070,7 +1070,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		return ERR_PTR(err);
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
-	if (want_blackhole) {
+	if (can_sleep) {
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
 		if (err == -EREMOTE)
-- 
1.7.4.1

