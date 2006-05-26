From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Fri, 26 May 2006 10:40:01 +0900 (JST)
Message-ID: <20060526.104001.96071021.yoshfuji@linux-ipv6.org>
References: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
	<Pine.LNX.4.64.0605151904110.12081@netcore.fi>
	<Pine.SOC.4.61.0605260219270.13718@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:1286 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751167AbWEZBjf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 21:39:35 -0400
To: mroos@linux.ee
In-Reply-To: <Pine.SOC.4.61.0605260219270.13718@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <Pine.SOC.4.61.0605260219270.13718@math.ut.ee> (at Fri, 26 May 2006 02:24:19 +0300 (EEST)), Meelis Roos <mroos@linux.ee> says:

> 
> (To YOSHIFUJI Hideaki: this is about the
> http://comments.gmane.org/gmane.linux.network/35262 thread)
> 
> Tracked it down to IPV6 merge at 2006-03-21:
> commit cd85f6e2f58282186ad720fc18482be228f0b972 is good (right before 
> the bunch of patches)
> commit b00055aacdb172c05067612278ba27265fcd05ce is bad (right after the 
> bunch of changes)

I guess rt6_select() is returning &ip6_null_entry and
the caller is finding next best route; e.g. default route.

Does this solve your problem?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0190e39..93eb33c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -280,10 +280,12 @@ static int inline rt6_check_neigh(struct
 {
 	struct neighbour *neigh = rt->rt6i_nexthop;
 	int m = 0;
-	if (neigh) {
+	if (rt->rt6i_flags & RTF_NONEXTHOP)
+		m = 1;
+	else if (neigh) {
 		read_lock_bh(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
-			m = 1;
+			m = 2;
 		read_unlock_bh(&neigh->lock);
 	}
 	return m;
@@ -292,15 +294,18 @@ static int inline rt6_check_neigh(struct
 static int rt6_score_route(struct rt6_info *rt, int oif,
 			   int strict)
 {
-	int m = rt6_check_dev(rt, oif);
+	int m, n
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
