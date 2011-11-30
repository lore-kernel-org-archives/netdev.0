From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/3] route: set iif and oif information in flowi struct
Date: Thu, 1 Dec 2011 00:37:06 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1111302303330.1678@ja.ssi.bg>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com> <1322511292-1413-3-git-send-email-ulrich.weber@sophos.com> <alpine.LFD.2.00.1111290051240.2497@ja.ssi.bg> <4ED66630.8030308@sophos.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Ulrich Weber <ulrich.weber@Sophos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44146 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107Ab1K3Wgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 17:36:32 -0500
In-Reply-To: <4ED66630.8030308@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 30 Nov 2011, Ulrich Weber wrote:

> > 	OTOH, rt_iif has some complex semantic: original oif
> > or the selected oif. May be you prefer flowi4_oif to hold
> > the selected oif, right?
> I wasn't aware the ip_route_output_slow() might change the original oif.
> You know why this might happen? Shouldn't fib_lookup only return
> a route matching the given oif?

	There are exceptions but only in this form:

	dev_out = net->loopback_dev;

	i.e. when traffic is diverted to loopback device.
In all others cases the provided oif is considered and never
changed.

> Anyway, if thats the case your code above is more correct. The packet
> should always match the xfrm policy where it was originally routed.
> 
> > 	I see one dangerous place that must be checked:
> > icmp_route_lookup. Before now __ip_route_output_key was
> > called after xfrm_decode_session_reverse with 0 in
> > flowi4_oif, i.e. no oif binding was used. But now when
> > decode_session sets flowi4_oif we will restrict the route
> > via this interface?
> Thanks for the hint! Yes the current patch will force the ICMP packet
> over the received interface.
> 
> Will add "fl4_dec.flowi4_oif = 0;" in case the saddr is local, so the
> behavior will be the same. fl4_dec.flowi4_oif will then be set in
> _ip_route_output_key() again.

	Yes, I think this should work. I now see another
unrelated problem with this code. _decode_session4 uses
fl4->flowi4_tos = iph->tos; But we then feed fl4_dec
to __ip_route_output_key without applying IPTOS_RT_MASK.
__ip_route_output_key does not work with plain TOS from IP
header.

	Currently, the situation around flowi4_tos is as follows:

- flowi4_tos:
	- (IPTOS_RT_MASK | RTO_ONLINK) bits when provided to
	__ip_route_output_key

	- on return above value is preserved if route is
	in cache, it is not changed

	- only IPTOS_RT_MASK bits are preserved by
	ip_route_output_slow if the route is not cached
	because flowi4_tos holds the bits that are
	matched by ip rules tos XX

	As result, we can not rely on the RTO_ONLINK bit
	being valid on return. IPTOS_RT_MASK bits are preserved.

- rt_key_tos:
	- (IPTOS_RT_MASK | RTO_ONLINK) bits

	- we have a bug here: ip_route_output_slow filters
	the provided flowi4_tos by removing RTO_ONLINK bit,
	then __mkroute_output tries to get original value
	with the RTO_ONLINK bit but ends up with the
	modified value. We need to provide orig_tos
	to __mkroute_output.

	In XFRM. Currently only xfrm_bundle_create calls
xfrm_get_tos to get a routable TOS value and such value is
provided to xfrm_dst_lookup. It means __xfrm4_dst_lookup gets
such filtered TOS value, lets name it rtos (routing tos) and
provides it to output routing correctly.

	xfrm4_fill_dst probably correctly copies
flowi4_tos into rt_key_tos if fl is result of output route
and not returned by decode_session. Of course, RTO_ONLINK
can be lost. But may be problem can happen at least for icmp.c
for the xfrm_decode_session_reverse -> xfrm_lookup code
where a full IP TOS can be copied by xfrm4_fill_dst:

	rt->rt_key_tos = fl4->flowi4_tos;

	What significance has this assignment? Should we have
valid RTO_ONLINK bit in flowi4_tos ?

	So, the fl4->flowi4_tos = iph->tos code does not
look nice, I don't know if this field is used for some
matching and we need to hold all IP TOS bits. If not, may be
we do not need to play games and have to use this instead:

	fl4->flowi4_tos = iph->tos & IPTOS_RT_MASK;

	because flowi4_tos is a rtos, not an IP TOS field.
Then we can reach xfrm_lookup or __ip_route_output_key safely
after _decode_session4.

Regards

--
Julian Anastasov <ja@ssi.bg>
