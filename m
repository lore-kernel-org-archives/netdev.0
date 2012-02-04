From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: reset flowi parameters on route connect
Date: Sun,  5 Feb 2012 01:04:46 +0200
Message-ID: <1328396686-15430-1-git-send-email-ja@ssi.bg>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39919 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752767Ab2BDXEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Feb 2012 18:04:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Eric Dumazet found that commit 813b3b5db83
(ipv4: Use caller's on-stack flowi as-is in output
route lookups.) that comes in 3.0 added a regression.
The problem appears to be that resulting flowi4_oif is
used incorrectly as input parameter to some routing lookups.
The result is that when connecting to local port without
listener if the IP address that is used is not on a loopback
interface we incorrectly assign RTN_UNICAST to the output
route because no route is matched by oif=lo. The RST packet
can not be sent immediately by tcp_v4_send_reset because
it expects RTN_LOCAL.

	So, change ip_route_connect and ip_route_newports to
update the flowi4 fields that are input parameters because
we do not want unnecessary binding to oif.

	To make it clear what are the input parameters that
can be modified during lookup and to show which fields of
floiw4 are reused add a new function to update the flowi4
structure: flowi4_update_output.

Thanks to Yurij M. Plotnikov for providing a bug report including a
program to reproduce the problem.

Thanks to Eric Dumazet for tracking the problem down to
tcp_v4_send_reset and providing initial fix.

Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Eric, please comment and ack this change by signing it.

 include/net/flow.h  |   10 ++++++++++
 include/net/route.h |    4 ++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 9b58243..6c469db 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -93,6 +93,16 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->fl4_dport = dport;
 	fl4->fl4_sport = sport;
 }
+
+/* Reset some input parameters after previous lookup */
+static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
+					__be32 daddr, __be32 saddr)
+{
+	fl4->flowi4_oif = oif;
+	fl4->flowi4_tos = tos;
+	fl4->daddr = daddr;
+	fl4->saddr = saddr;
+}
 				      
 
 struct flowi6 {
diff --git a/include/net/route.h b/include/net/route.h
index 91855d1..b1c0d5b 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -270,6 +270,7 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 		if (IS_ERR(rt))
 			return rt;
 		ip_rt_put(rt);
+		flowi4_update_output(fl4, oif, tos, fl4->daddr, fl4->saddr);
 	}
 	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 	return ip_route_output_flow(net, fl4, sk);
@@ -284,6 +285,9 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 		fl4->fl4_dport = dport;
 		fl4->fl4_sport = sport;
 		ip_rt_put(rt);
+		flowi4_update_output(fl4, sk->sk_bound_dev_if,
+				     RT_CONN_FLAGS(sk), fl4->daddr,
+				     fl4->saddr);
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		return ip_route_output_flow(sock_net(sk), fl4, sk);
 	}
-- 
1.7.3.4
