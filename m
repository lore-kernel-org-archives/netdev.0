From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Linux kernel patch: elide fib_validate_source() completely when
 possible - bad side effect?
Date: Wed, 22 Jan 2014 23:04:52 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401222222010.1855@ja.home.ssi.bg>
References: <52D945400200005D00047758@gwia2.atlnz.lc> <alpine.LFD.2.11.1401170953370.1827@ja.home.ssi.bg> <52DCF1440200005D000477FD@gwia2.atlnz.lc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: gregory hoggarth <gregory.hoggarth@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49136 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752578AbaAVVGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 16:06:14 -0500
In-Reply-To: <52DCF1440200005D000477FD@gwia2.atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 20 Jan 2014, gregory hoggarth wrote:

> >>> Julian Anastasov <ja@ssi.bg> 17/1/14 09:24 PM >>> 
> >
> >	It seems only __fib_validate_source can reject all kind
> > of broadcast addresses in saddr. ip_route_input_slow() rejects
> > only the well known broadcasts. Without rp_filter may be we
> > can at least drop attempts to send replies back to broadcast
> > addresses? For example, checking result of ip_route_output_key() in
> > icmp_reply():
> >
> >	if (rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
> >		=> ip_rt_put()

> Thank you for your reply.
> 
> While I think your solution may work, isn't the proper approach to drop these 
> rogue packets, rather than wasting CPU and other resources processing them, 
> and then beginning to craft responses which are in turn dropped?

	The problem is that it is __fib_validate_source that
takes time for every packet. And it is a rare case to see
traffic from broadcast addresses. rp_filter set on external
interface will drop such packets. It is an option that one
can use even for internal interface, if needed.

> Also seems better to drop the initial rogue packet, as that should cover all 
> (?) different types of packets, rather than having to add small patches into 
> ICMP, TCP and any other places that may need it.

	Small check looks better compared to FIB lookup for
every received packet. Note that output route can be cached
for sockets, eg. TCP, so such small checks do not occur for
every reply packet.

> So my question really is was the original patch correct and there's something
> wrong with our device configuration, or is this an overlooked / untested side-
> effect from that patch that as a result means the patch should be re-worked?

	I don't remember someone mentioning about such
side-effect, I guess it is overlooked. IMHO, it is not a good
reason to restore the old behavior. Lets see other opinions.

Regards

--
Julian Anastasov <ja@ssi.bg>
