From: Florian Westphal <fw@strlen.de>
Subject: traceroute reporting wrong nexthop addr when xfrm is involved
Date: Wed, 25 Sep 2013 17:42:54 +0200
Message-ID: <20130925154254.GC12025@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39387 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750827Ab3IYPm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 11:42:58 -0400
Received: from fw by Chamillionaire.breakpoint.cc with local (Exim 4.80)
	(envelope-from <fw@strlen.de>)
	id 1VOrEs-0000qg-UV
	for netdev@vger.kernel.org; Wed, 25 Sep 2013 17:42:55 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

When running traceroute to a host behind an ipsec tunnel, the first hop
appears to be the destination host instead of the "real" address, when
"flag icmp" is set on outbound xfrm policy on the 1st hop gateway.

Given

A ---IPSEC ---- B ---<Internal-Network>--- D

D is an arbitrary machine on internal network 10/8, with address
10.128.8.1

A is a client (address: 192.168.20.8), connected to ipsec gateway B with
address 192.168.20.80.  B has "flag icmp" set on its in/fwd/out xfrm policies.

A is configured to encapsulate traffic to either B or the internal network
10/8 in ESP.

B decapsulates packets, (or vv when packets go to A from 10/8 network or B).

This works fine.  However, when running traceroute from
A to D, the very first hop (B) reports the address of D instead:

A $: traceroute -n 10.128.8.1
traceroute to 10.128.8.1 (10.128.8.1), 30 hops max, 40 byte packets using UDP
 1  10.128.8.1 (10.128.8.1)  0.450 ms   0.391 ms   0.357 ms
 2  192.168.10.1 (192.168.10.1)  0.654 ms   0.585 ms   0.642 ms
 3  10.128.128.1 (10.128.128.1)  0.957 ms   0.986 ms   1.410 ms
 4  10.128.254.6 (10.128.254.6)  1.745 ms   1.656 ms   1.240 ms
 5  10.128.8.1 (10.128.8.1)  1.514 ms   1.728 ms   1.495 ms

I tracked this down to icmp.c:icmp_route_lookup()

 447         rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst,
 448                                             flowi4_to_flowi(&fl4_dec), NULL,
 449                                             XFRM_LOOKUP_ICMP);
 450         if (!IS_ERR(rt2)) {
 451                 dst_release(&rt->dst);
 452                 memcpy(fl4, &fl4_dec, sizeof(*fl4));
 453                 rt = rt2;


fl4 has the correct information, fl4.saddr is the one chosen in
icmp_send() earlier - 192.168.20.80 in my case.

xfrm_lookup() succeds and icmp_route_lookup() commits to using rt2.

In my case, fl4_dec.saddr is 10.128.8.1, the memcpy then copies the new
flowi that will be used for the icmp packet.

Removing the memcpy 'fixes' the problem, but I'm not sure if thats
even correct.

Does anyone know what the purpose of fl4_dec is, or if the behaviour
is the expected one?

Thanks,
Florian
