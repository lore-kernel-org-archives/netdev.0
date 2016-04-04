From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH] net: socket: return a proper error code when source address becomes nonlocal
Date: Mon,  4 Apr 2016 00:09:29 -0700
Message-ID: <1459753769-4290-1-git-send-email-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <liping.zhang@spreadtrum.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:49574 "EHLO m50-133.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754471AbcDDHZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 03:25:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

1. Socket can use bind(directly) or connect(indirectly) to bind to a local
   ip address, and later if the network becomes down, that cause the source
   address becomes nonlocal, then send() call will fail and return EINVAL.
   But this error code is confusing, acctually we did not pass any invalid
   arguments. Furthermore, send() maybe return ok at first, it now returns
   fail just because of a temporary network problem, i.e. when the network
   recovery, send() call will become ok. Return EADDRNOTAVAIL instead of
   EINVAL in such situation is better.
2. We can use IPV6_PKTINFO to specify the ipv6 source address when call
   sendmsg() to send packet, but if the address is not available, call will
   fail and EINVAL is returned. This error code is not very appropriate,
   it failed maybe just because of a temporary network problem. Also
   RFC3542, section 6.6 describe an example returns EADDRNOTAVAIL:
   "ipi6_ifindex specifies an interface but the address ipi6_addr is not
   available for use on that interface.". So return EADDRNOTAVAIL instead
   of EINVAL here.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
---
 net/ipv4/route.c    |    6 ++++--
 net/ipv6/datagram.c |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c6229..857f7b3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2149,11 +2149,13 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 
 	rcu_read_lock();
 	if (fl4->saddr) {
-		rth = ERR_PTR(-EINVAL);
+		rth = ERR_PTR(-EADDRNOTAVAIL);
 		if (ipv4_is_multicast(fl4->saddr) ||
 		    ipv4_is_lbcast(fl4->saddr) ||
-		    ipv4_is_zeronet(fl4->saddr))
+		    ipv4_is_zeronet(fl4->saddr)) {
+			rth = ERR_PTR(-EINVAL);
 			goto out;
+		}
 
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 4281621..04d62e8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -746,7 +746,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 						   strict ? dev : NULL, 0) &&
 				    !ipv6_chk_acast_addr_src(net, dev,
 							     &src_info->ipi6_addr))
-					err = -EINVAL;
+					err = -EADDRNOTAVAIL;
 				else
 					fl6->saddr = src_info->ipi6_addr;
 			}
-- 
1.7.9.5
