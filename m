From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: fix Mobile IPv6 regression
Date: Fri, 28 May 2010 14:17:43 -0400
Message-ID: <4C0008C7.7020302@hp.com>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>	<8739xdqsuz.fsf@small.ssi.corp> <4BFECA65.7030102@hp.com>	<4BFEE49C.8060301@lucent.com> <87hblss92x.fsf@small.ssi.corp> <4C00047D.3010404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Scott C Otto <otts@alcatel-lucent.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:37959 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab0E1SRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 14:17:48 -0400
In-Reply-To: <4C00047D.3010404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f4f914b5 (net: ipv6 bind to device issue) caused
a regression with Mobile IPv6 when it changed the meaning
of fl->oif to become a strict requirement of the route
lookup.  Instead, only force strict mode when
sk->sk_bound_dev_if is set on the calling socket, getting
the intended behavior and fixing the regression.

Tested-by: Arnaud Ebalard <arno@natisbad.org>
Signed-off-by: Brian Haley <brian.haley@hp.com>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 294cbe8..252d761 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -814,7 +814,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 {
 	int flags = 0;
 
-	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
+	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl->fl6_dst))
 		flags |= RT6_LOOKUP_F_IFACE;
 
 	if (!ipv6_addr_any(&fl->fl6_src))
