From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers are removed
Date: Fri, 1 Jun 2007 14:55:30 +0200
Message-ID: <200706011455.31220@nienna>
References: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli> <200705311450.36492@nienna> <Pine.LNX.4.58.0706010123020.2683@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	horms@verge.net.au, jkrzyszt@tis.icnet.pl, hidden@sch.bme.hu,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:1717 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754673AbXFAMzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 08:55:36 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id AB49CC00E1
	for <netdev@vger.kernel.org>; Fri,  1 Jun 2007 14:55:33 +0200 (CEST)
In-Reply-To: <Pine.LNX.4.58.0706010123020.2683@u.domain.uli>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Friday 01 June 2007 01:18, Julian Anastasov wrote:
> 	What about something like this, it even reduces checks
> in the fast path. You can post new version if the following change
> looks good to you and to other developers. If additional sign line is
> needed here it is:
>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>
>[...]
> 	Or we can go further and to avoid ip_dev_find? For me, this
> second variant is preferred because calling ip_dev_find() is useless
> for FLOWI_FLAG_ANYSRC.

  You're right. Although I don't really like duplicating the ip_dev_find()
call, it's still better than the previous patch.

-- 
 Regards,
  Krisztian Kovacs


Loosen source address check on IPv4 output

ip_route_output() contains a check to make sure that no flows with
non-local source IP addresses are routed. This obviously makes using
such addresses impossible.

This patch introduces a flowi flag which makes omitting this check
possible.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

 include/net/flow.h |    1 +
 net/ipv4/route.c   |   20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index f3cc1f8..1bfc0dc 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -49,6 +49,7 @@ struct flowi {
 	__u8	proto;
 	__u8	flags;
 #define FLOWI_FLAG_MULTIPATHOLDROUTE 0x01
+#define FLOWI_FLAG_ANYSRC 0x02
 	union {
 		struct {
 			__be16	sport;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8603cfb..4acd3de 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2394,11 +2394,6 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 		    ZERONET(oldflp->fl4_src))
 			goto out;
 
-		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
-			goto out;
-
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
 		   1. ip_dev_find(saddr) can return wrong iface, if saddr is
@@ -2409,6 +2404,11 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 
 		if (oldflp->oif == 0
 		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
+
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
 			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
@@ -2427,9 +2427,15 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 			fl.oif = dev_out->ifindex;
 			goto make_route;
 		}
-		if (dev_out)
+
+		if (!(oldflp->flags & FLOWI_FLAG_ANYSRC)) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
 			dev_put(dev_out);
-		dev_out = NULL;
+			dev_out = NULL;
+		}
 	}
 
 
