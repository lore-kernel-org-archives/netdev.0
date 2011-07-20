From: Florian Westphal <fw@strlen.de>
Subject: icmp_route_lookup returns wrong source address information
Date: Wed, 20 Jul 2011 21:22:58 +0200
Message-ID: <20110720192258.GA21528@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:49123 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752017Ab1GTTW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 15:22:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

With linux-2.6 and net-next trees, whenever an icmp error message is
sent in response to a to-be-forwarded packet, the destination address
of the original packet is used as the IP header source address.

Example:
$ traceroute breakpoint.cc
traceroute to breakpoint.cc (85.10.199.196), 30 hops max, 40 byte packets
 1  chamillionaire.breakpoint.cc (85.10.199.196)  0.476 ms  0.468 ms  0.793 ms

But the expected 1st hop is 192.168.20.7 in my setup.

I bisected this down to 77968b78242ee25e2a4d759f0fca8dd52df6d479
("ipv4: Pass flow keys down into datagram packet building engine.")

Specifically, it is caused by this hunk:

-static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
+static struct rtable *icmp_route_lookup(struct net *net,
+					struct flowi4 *fl4,
[..]
 {
-	struct flowi4 fl4 = {
-		.daddr = (param->replyopts.opt.opt.srr ?
-			  param->replyopts.opt.opt.faddr : iph->saddr),
-		.saddr = saddr,
-		.flowi4_tos = RT_TOS(tos),
-		.flowi4_proto = IPPROTO_ICMP,
-		.fl4_icmp_type = type,
-		.fl4_icmp_code = code,
-	};
 	struct rtable *rt, *rt2;
 	int err;
[..]
-	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(&fl4), AF_INET);
+	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(fl4), AF_INET);
 	if (err)
 		goto relookup_failed;

Problem is that xfrm_decode_session_reverse() may rebuild fl4 from scratch.

In my setup, "goto relookup_failed" will be hit a bit later on, and fl4->saddr will
be set to iph->daddr...

Thanks,
Florian
