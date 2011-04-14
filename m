From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 17:55:37 +0200
Message-ID: <1302796537.3248.22.camel@edumazet-laptop>
References: <4DA522B2.90200@scotdoyle.com> <4DA5BCF7.9020606@scotdoyle.com>
	 <1302708487.3725.0.camel@edumazet-laptop>
	 <20110413.144812.116375845.davem@davemloft.net>
	 <1302748276.3549.20.camel@edumazet-laptop> <20110413195424.1d2393c6@s6510>
	 <1302750214.3549.34.camel@edumazet-laptop>
	 <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, lkml@scotdoyle.com,
	netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62210 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759196Ab1DNPzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 11:55:41 -0400
Received: by wya21 with SMTP id 21so1526729wya.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 08:55:40 -0700 (PDT)
In-Reply-To: <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scot Doyle demonstrated ip_options_compile() could be called with an skb
without an attached route, using a setup involving a bridge, netfilter,
and forged IP packets.

Let's make ip_options_compile() and ip_options_rcv_srr() a bit more
robust, instead of changing bridge/netfilter code.

With help from Hiroaki SHIMODA.

Reported-by: Scot Doyle <lkml@scotdoyle.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
v2: ip_options_rcv_srr() fix as well, from Hiroaki

 net/ipv4/ip_options.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 28a736f..2391b24 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -329,7 +329,7 @@ int ip_options_compile(struct net *net,
 					pp_ptr = optptr + 2;
 					goto error;
 				}
-				if (skb) {
+				if (rt) {
 					memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
 					opt->is_changed = 1;
 				}
@@ -371,7 +371,7 @@ int ip_options_compile(struct net *net,
 						goto error;
 					}
 					opt->ts = optptr - iph;
-					if (skb) {
+					if (rt)  {
 						memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
 						timeptr = (__be32*)&optptr[optptr[2]+3];
 					}
@@ -603,7 +603,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	unsigned long orefdst;
 	int err;
 
-	if (!opt->srr)
+	if (!opt->srr || !rt)
 		return 0;
 
 	if (skb->pkt_type != PACKET_HOST)


