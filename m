From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Fri, 26 May 2006 19:08:56 +0900 (JST)
Message-ID: <20060526.190856.33048221.yoshfuji@linux-ipv6.org>
References: <20060526.104001.96071021.yoshfuji@linux-ipv6.org>
	<20060526.104245.106225873.yoshfuji@linux-ipv6.org>
	<Pine.SOC.4.61.0605261134250.18708@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33287 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751365AbWEZKI1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 06:08:27 -0400
To: mroos@linux.ee
In-Reply-To: <Pine.SOC.4.61.0605261134250.18708@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <Pine.SOC.4.61.0605261134250.18708@math.ut.ee> (at Fri, 26 May 2006 11:35:53 +0300 (EEST)), Meelis Roos <mroos@linux.ee> says:

> The unreachable route works now but LAN routing still does not work. 
> Locally generated ICMPv6 packets that should go to LAN interface still 
> go to tun6to4.

Please try this.

----
[IPV6] ROUTE: Don't try less preferred routes for on-link routes.

In addition to the real on-link routes, NONEXTHOP routes
should be considered on-link.

Problem reported by Meelis Roos <mroos@linux.ee>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

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


--yoshfuji
