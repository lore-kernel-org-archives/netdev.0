From: Andy Walls <awalls@md.metrocast.net>
Subject: [PATCH] IPv4: route.c: Change checks against 0xffffffff to
 ipv4_is_lbcast()
Date: Sun, 17 Oct 2010 21:11:22 -0400
Message-ID: <1287364282.2320.20.camel@morgan.silverblock.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Change a few checks against the hardcoded broadcast address,
0xffffffff, to ipv4_is_lbcast().  Remove some existing checks
using ipv4_is_lbcast() that are now obviously superfluous.

Signed-off-by: Andy Walls <awalls@md.metrocast.net>
---
 net/ipv4/route.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3f56b6e..d78c764 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2124,7 +2124,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	    ipv4_is_loopback(saddr))
 		goto martian_source;
 
-	if (daddr == htonl(0xFFFFFFFF) || (saddr == 0 && daddr == 0))
+	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
 	/* Accept zero addresses only to limited broadcast;
@@ -2133,8 +2133,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_zeronet(saddr))
 		goto martian_source;
 
-	if (ipv4_is_lbcast(daddr) || ipv4_is_zeronet(daddr) ||
-	    ipv4_is_loopback(daddr))
+	if (ipv4_is_zeronet(daddr) || ipv4_is_loopback(daddr))
 		goto martian_destination;
 
 	/*
@@ -2370,11 +2369,11 @@ static int __mkroute_output(struct rtable **result,
 	if (ipv4_is_loopback(fl->fl4_src) && !(dev_out->flags&IFF_LOOPBACK))
 		return -EINVAL;
 
-	if (fl->fl4_dst == htonl(0xFFFFFFFF))
+	if (ipv4_is_lbcast(fl->fl4_dst))
 		res->type = RTN_BROADCAST;
 	else if (ipv4_is_multicast(fl->fl4_dst))
 		res->type = RTN_MULTICAST;
-	else if (ipv4_is_lbcast(fl->fl4_dst) || ipv4_is_zeronet(fl->fl4_dst))
+	else if (ipv4_is_zeronet(fl->fl4_dst))
 		return -EINVAL;
 
 	if (dev_out->flags & IFF_LOOPBACK)
@@ -2543,7 +2542,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 
 		if (oldflp->oif == 0 &&
 		    (ipv4_is_multicast(oldflp->fl4_dst) ||
-		     oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+		     ipv4_is_lbcast(oldflp->fl4_dst))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 			dev_out = ip_dev_find(net, oldflp->fl4_src);
 			if (dev_out == NULL)
@@ -2592,7 +2591,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 		}
 
 		if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
-		    oldflp->fl4_dst == htonl(0xFFFFFFFF)) {
+		    ipv4_is_lbcast(oldflp->fl4_dst)) {
 			if (!fl.fl4_src)
 				fl.fl4_src = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_LINK);
-- 
1.7.2.3
