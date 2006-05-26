From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] ROUTE: Don't try less preferred routes for on-link
 routes.
Date: Fri, 26 May 2006 20:01:56 +0900 (JST)
Message-ID: <20060526.200156.83522671.yoshfuji@linux-ipv6.org>
References: <Pine.SOC.4.61.0605261134250.18708@math.ut.ee>
	<20060526.190856.33048221.yoshfuji@linux-ipv6.org>
	<Pine.SOC.4.61.0605261344340.26383@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34567 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751392AbWEZLBa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 07:01:30 -0400
To: davem@davemloft.net
In-Reply-To: <Pine.SOC.4.61.0605261344340.26383@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

In article <Pine.SOC.4.61.0605261344340.26383@math.ut.ee> (at Fri, 26 May 2006 13:44:59 +0300 (EEST)), Meelis Roos <mroos@linux.ee> says:

> >> The unreachable route works now but LAN routing still does not work.
> >> Locally generated ICMPv6 packets that should go to LAN interface still
> >> go to tun6to4.
> >
> > Please try this.
> 
> This works for both unreachable and LAN routes, thanks!

Please push this to 2.6.17-final.

Regards,

-------
[IPV6] ROUTE: Don't try less preferred routes for on-link routes.

In addition to the real on-link routes, NONEXTHOP routes
should be considered on-link.

Problem reported by Meelis Roos <mroos@linux.ee>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Acked-by: Meelis Roos <mroos@linux.ee>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0190e39..8a77793 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -280,10 +280,13 @@ static int inline rt6_check_neigh(struct
 {
 	struct neighbour *neigh = rt->rt6i_nexthop;
 	int m = 0;
-	if (neigh) {
+	if (rt->rt6i_flags & RTF_NONEXTHOP ||
+	    !(rt->rt6i_flags & RTF_GATEWAY))
+		m = 1;
+	else if (neigh) {
 		read_lock_bh(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
-			m = 1;
+			m = 2;
 		read_unlock_bh(&neigh->lock);
 	}
 	return m;
@@ -292,15 +295,18 @@ static int inline rt6_check_neigh(struct
 static int rt6_score_route(struct rt6_info *rt, int oif,
 			   int strict)
 {
-	int m = rt6_check_dev(rt, oif);
+	int m, n;
+		
+	m = rt6_check_dev(rt, oif);
 	if (!m && (strict & RT6_SELECT_F_IFACE))
 		return -1;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;
 #endif
-	if (rt6_check_neigh(rt))
+	n = rt6_check_neigh(rt);
+	if (n > 1)
 		m |= 16;
-	else if (strict & RT6_SELECT_F_REACHABLE)
+	else if (!n && strict & RT6_SELECT_F_REACHABLE)
 		return -1;
 	return m;
 }

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
