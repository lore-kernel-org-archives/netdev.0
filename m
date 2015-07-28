From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v5 1/2] ipv6: change ipv6_stub_impl.ipv6_dst_lookup to take net argument
Date: Tue, 28 Jul 2015 15:27:40 -0700
Message-ID: <1438122461-8350-2-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, hannes@stressinduktion.org,
	rshearma@brocade.com, stephen@networkplumber.org,
	kuznet@ms2.inr.ac.ru, jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33241 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbbG1W1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:27:48 -0400
Received: by pdbnt7 with SMTP id nt7so77485927pdb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:27:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds net argument to ipv6_stub_impl.ipv6_dst_lookup
for use cases where sk is not available (like mpls).
sk appears to be needed to get the namespace 'net' and is optional
otherwise. This patch series changes ipv6_stub_impl.ipv6_dst_lookup
to take net argument. sk remains optional.

All callers of ipv6_stub_impl.ipv6_dst_lookup have been modified
to pass net. I have modified them to use already available
'net' in the scope of the call. I can change them to
sock_net(sk) to avoid any unintended change in behaviour if sock
namespace is different. They dont seem to be from code inspection.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c    |    2 +-
 include/net/addrconf.h |    4 ++--
 include/net/ipv6.h     |    3 ++-
 net/ipv6/icmp.c        |    6 +++---
 net/ipv6/ip6_output.c  |   12 ++++++------
 net/tipc/udp_media.c   |    3 ++-
 6 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 81f0f24..beed5d4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2034,7 +2034,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		fl6.flowi6_mark = skb->mark;
 		fl6.flowi6_proto = IPPROTO_UDP;
 
-		if (ipv6_stub->ipv6_dst_lookup(sk, &ndst, &fl6)) {
+		if (ipv6_stub->ipv6_dst_lookup(vxlan->net, sk, &ndst, &fl6)) {
 			netdev_dbg(dev, "no route to %pI6\n",
 				   &dst->sin6.sin6_addr);
 			dev->stats.tx_carrier_errors++;
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index def59d3..0c3ac5a 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -158,8 +158,8 @@ struct ipv6_stub {
 				 const struct in6_addr *addr);
 	int (*ipv6_sock_mc_drop)(struct sock *sk, int ifindex,
 				 const struct in6_addr *addr);
-	int (*ipv6_dst_lookup)(struct sock *sk, struct dst_entry **dst,
-				struct flowi6 *fl6);
+	int (*ipv6_dst_lookup)(struct net *net, struct sock *sk,
+			       struct dst_entry **dst, struct flowi6 *fl6);
 	void (*udpv6_encap_enable)(void);
 	void (*ndisc_send_na)(struct net_device *dev, struct neighbour *neigh,
 			      const struct in6_addr *daddr,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 82dbdb0..09d0ea4 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -832,7 +832,8 @@ static inline struct sk_buff *ip6_finish_skb(struct sock *sk)
 			      &inet6_sk(sk)->cork);
 }
 
-int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi6 *fl6);
+int ip6_dst_lookup(struct net *net, struct sock *sk, struct dst_entry **dst,
+		   struct flowi6 *fl6);
 struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 				      const struct in6_addr *final_dst);
 struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 713d743..6c2b213 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -329,7 +329,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
 	struct flowi6 fl2;
 	int err;
 
-	err = ip6_dst_lookup(sk, &dst, fl6);
+	err = ip6_dst_lookup(net, sk, &dst, fl6);
 	if (err)
 		return ERR_PTR(err);
 
@@ -361,7 +361,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
 	if (err)
 		goto relookup_failed;
 
-	err = ip6_dst_lookup(sk, &dst2, &fl2);
+	err = ip6_dst_lookup(net, sk, &dst2, &fl2);
 	if (err)
 		goto relookup_failed;
 
@@ -591,7 +591,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	else if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->ucast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl6);
+	err = ip6_dst_lookup(net, sk, &dst, &fl6);
 	if (err)
 		goto out;
 	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), sk, 0);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c5fc852..92b7cf0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -881,10 +881,9 @@ out:
 	return dst;
 }
 
-static int ip6_dst_lookup_tail(struct sock *sk,
+static int ip6_dst_lookup_tail(struct net *net, struct sock *sk,
 			       struct dst_entry **dst, struct flowi6 *fl6)
 {
-	struct net *net = sock_net(sk);
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	struct neighbour *n;
 	struct rt6_info *rt;
@@ -994,10 +993,11 @@ out_err_release:
  *
  *	It returns zero on success, or a standard errno code on error.
  */
-int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi6 *fl6)
+int ip6_dst_lookup(struct net *net, struct sock *sk, struct dst_entry **dst,
+		   struct flowi6 *fl6)
 {
 	*dst = NULL;
-	return ip6_dst_lookup_tail(sk, dst, fl6);
+	return ip6_dst_lookup_tail(net, sk, dst, fl6);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup);
 
@@ -1018,7 +1018,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 	struct dst_entry *dst = NULL;
 	int err;
 
-	err = ip6_dst_lookup_tail(sk, &dst, fl6);
+	err = ip6_dst_lookup_tail(sock_net(sk), sk, &dst, fl6);
 	if (err)
 		return ERR_PTR(err);
 	if (final_dst)
@@ -1052,7 +1052,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 
 	dst = ip6_sk_dst_check(sk, dst, fl6);
 
-	err = ip6_dst_lookup_tail(sk, &dst, fl6);
+	err = ip6_dst_lookup_tail(sock_net(sk), sk, &dst, fl6);
 	if (err)
 		return ERR_PTR(err);
 	if (final_dst)
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 66deebc..c170d31 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -194,7 +194,8 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 			.saddr = src->ipv6,
 			.flowi6_proto = IPPROTO_UDP
 		};
-		err = ipv6_stub->ipv6_dst_lookup(ub->ubsock->sk, &ndst, &fl6);
+		err = ipv6_stub->ipv6_dst_lookup(net, ub->ubsock->sk, &ndst,
+						 &fl6);
 		if (err)
 			goto tx_error;
 		ttl = ip6_dst_hoplimit(ndst);
-- 
1.7.10.4
