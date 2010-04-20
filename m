From: Jiri Olsa <jolsa@redhat.com>
Subject: [PATCH] net: ipv6 bind to device issue
Date: Tue, 20 Apr 2010 14:46:12 +0200
Message-ID: <1271767572-5282-1-git-send-email-jolsa@redhat.com>
Cc: netdev@vger.kernel.org, Jiri Olsa <jolsa@redhat.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546Ab0DTMrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 08:47:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

The issue raises when having 2 NICs both assigned the same
IPv6 global address.

If a sender binds to a particular NIC (SO_BINDTODEVICE),
the outgoing traffic is being sent via the first found.
The bonded device is thus not taken into an account during the
routing.


>From the ip6_route_output function:

If the binding address is multicast, linklocal or loopback,
the RT6_LOOKUP_F_IFACE bit is set, but not for global address.

So binding global address will neglect SO_BINDTODEVICE-binded device,
because the fib6_rule_lookup function path won't check for the
flowi::oif field and take first route that fits.

Following patch should handle the issue.

wbr,
jirka


Signed-off-by: Jiri Olsa <jolsa@redhat.com>
---
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2438e8..7bf7717 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 {
 	int flags = 0;
 
-	if (rt6_need_strict(&fl->fl6_dst))
+	if (rt6_need_strict(&fl->fl6_dst) || fl->oif)
 		flags |= RT6_LOOKUP_F_IFACE;
 
 	if (!ipv6_addr_any(&fl->fl6_src))
