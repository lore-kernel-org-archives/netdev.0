From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: prints bogus hoplimit
Date: Wed, 18 Mar 2009 16:29:28 -0700
Message-ID: <20090318162928.163a2408@nehalam>
References: <alpine.LSU.2.00.0902241125020.329@fbirervta.pbzchgretzou.qr>
	<20090318151216.60cd0363@nehalam>
	<alpine.LSU.2.00.0903182334410.30559@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49856 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967AbZCRX3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 19:29:36 -0400
In-Reply-To: <alpine.LSU.2.00.0903182334410.30559@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Mar 2009 23:35:12 +0100 (CET)
Jan Engelhardt <jengelh@medozas.de> wrote:

> 
> On Wednesday 2009-03-18 23:12, Stephen Hemminger wrote:
> >On Tue, 24 Feb 2009 11:27:52 +0100 (CET)
> >Jan Engelhardt <jengelh@medozas.de> wrote:
> >
> >> $ ip -6 r
> >> fc00::/7 dev rtl0  proto kernel  metric 256  mtu 1500 advmss 1440 
> >> hoplimit 4294967295
> >> 
> >> Most likely, "hoplimit -1" would be the right number, though I am not 
> >> sure if simply changing %u by %d is a correct thing to do, since it 
> >> would affect all fields.
> >> 
> >> ---
> >>  ip/iproute.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>  	if (i != RTAX_RTT && i != RTAX_RTTVAR &&
> >>  	    i != RTAX_RTO_MIN)
> >> -		fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
> >> +		fprintf(fp, " %d", *(unsigned*)RTA_DATA(mxrta[i]));
> >
> >No fix the kernel please.
> >
> And what should the kernel return?

The issue is that the hoplimit metric in ipv6 gets converted
to -1 (if it is zero on the incoming route request)..  

int ip6_route_add(struct fib6_config *cfg)
{
...
	  if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)
                rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;


What should happen is when ip6 returns the route back
on the dump request (rt6_fill_node), it should translate the -1 back to 0
to keep it symmetrical and logical. The metrics are unsigned.

