From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/8] net: Add FLOWI_FLAG_CAN_SLEEP.
Date: Tue, 01 Mar 2011 15:11:26 -0800 (PST)
Message-ID: <20110301.151126.245404910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757024Ab1CAXKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:10:49 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4F36224C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And set is in contexts where the route resolution can sleep.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h    |    1 +
 include/net/route.h   |    2 ++
 net/ipv4/raw.c        |    3 ++-
 net/ipv4/udp.c        |    6 ++++--
 net/ipv6/ip6_output.c |    2 ++
 5 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index f2080e6..fd04138 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -50,6 +50,7 @@ struct flowi {
 	__u8	flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_PRECOW_METRICS	0x02
+#define FLOWI_FLAG_CAN_SLEEP		0x04
 	union {
 		struct {
 			__be16	sport;
diff --git a/include/net/route.h b/include/net/route.h
index 6de4333..1be5c05 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -185,6 +185,8 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 		fl.flags |= FLOWI_FLAG_ANYSRC;
 	if (protocol == IPPROTO_TCP)
 		fl.flags |= FLOWI_FLAG_PRECOW_METRICS;
+	if (can_sleep)
+		fl.flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	if (!dst || !src) {
 		err = __ip_route_output_key(net, rp, &fl);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index e185765..e8e8613 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -555,7 +555,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				    .fl4_tos = tos,
 				    .proto = inet->hdrincl ? IPPROTO_RAW :
 							     sk->sk_protocol,
-				  };
+				    .flags = FLOWI_FLAG_CAN_SLEEP,
+		};
 		if (!inet->hdrincl) {
 			err = raw_probe_proto_opt(&fl, msg);
 			if (err)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 790187b..c6bcc93 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -914,9 +914,11 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				    .fl4_src = saddr,
 				    .fl4_tos = tos,
 				    .proto = sk->sk_protocol,
-				    .flags = inet_sk_flowi_flags(sk),
+				    .flags = (inet_sk_flowi_flags(sk) |
+					      FLOWI_FLAG_CAN_SLEEP),
 				    .fl_ip_sport = inet->inet_sport,
-				    .fl_ip_dport = dport };
+				    .fl_ip_dport = dport
+		};
 		struct net *net = sock_net(sk);
 
 		security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 28209b2..77b1942 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1026,6 +1026,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
 	if (want_blackhole) {
+		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, fl);
@@ -1070,6 +1071,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
 	if (want_blackhole) {
+		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, fl);
-- 
1.7.4.1

