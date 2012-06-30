From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Sat, 30 Jun 2012 12:25:53 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1206301218150.1593@ja.ssi.bg>
References: <20120628.035946.1026666621448892198.davem@davemloft.net> <alpine.LFD.2.00.1206282309340.1722@ja.ssi.bg> <20120628.184500.114483408843364230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35919 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab2F3JTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2012 05:19:55 -0400
In-Reply-To: <20120628.184500.114483408843364230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 28 Jun 2012, David Miller wrote:

> ipv4: Fix bugs in fib_compute_spec_dst().

	Some more thoughts on this topic...

	I'm wondering, may be ip_options_echo wants to put
local IP for srr. ip_options_echo is called by ip_send_unicast_reply.
ip_send_unicast_reply supports source address spoofing for
tproxy (arg.flags & IP_REPLY_ARG_NOSRCCHECK).

	May be the tproxy users add local routes to redirect
the traffic to local stack but daddr is preserved (non-local).
So, rt_flags will have RTCF_LOCAL but for srr purposes we
need local address, right?

	There can be optimization in ip_options_echo to
avoid fib_compute_spec_dst if daddr is not needed. It seems
it is needed only in the sopt->srr case.

	It seems ip_options_compile can be called by
ip_rcv_options (ip_rcv_finish) just after ip_route_input_noref
but before dst_input. It means, it can happen for forwarding,
not just for local delivery.

	To summarize, we can not rely on iph->daddr to be
local address if RTCF_LOCAL is set. There is always the risk to
work with redirected or forwarded traffic. Even for the PKTINFO
case we should make sure ipi_spec_dst is a local address (original
daddr goes to ipi_addr anyways), in case later ipi_spec_dst
is used again for sending in PKTINFO.

	For now, I see only one possible optimization.
When fib_lookup returns res.fi and res.type is RTN_LOCAL
we can check fib_protocol. If fib_protocol is not
RTPROT_KERNEL we will add RTCF_MAYBE_LOCAL (new flag) to rt_flags.
It will lead to slow lookups to validate the iph->daddr
if used later as source address, like in the spec_dst case.

	For the common case of local routes created by fib_magic()
we will use iph->daddr in fib_compute_spec_dst as follows:

	if (rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST |
			    RTCF_LOCAL | RTCF_MAYBE_LOCAL) == RTCF_LOCAL))
		return ip_hdr(skb)->daddr;
	/* For mcast, forwarding and spoofing we take the slow path */

	If users add local RTPROT_KERNEL routes, later
the outgoing traffic will anyways fail in some output route lookup
because FLOWI_FLAG_ANYSRC is set in rare cases. But also
users can break srr in this way, so there is some risk.

Regards

--
Julian Anastasov <ja@ssi.bg>
