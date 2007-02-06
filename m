From: KOVACS Krisztian <hidden@balabit.hu>
Subject: IP_FREEBIND and CAP_NET_ADMIN (was: Re: [PATCH/RFC 05/10] Remove local address check on IP output)
Date: Tue, 6 Feb 2007 15:36:18 +0100
Message-ID: <200702061536.18800@nienna>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <20070103163627.14635.88250.stgit@nienna.balabit> <45A48BEB.2070207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:1500 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110AbXBFOgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 09:36:22 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 950B64C168
	for <netdev@vger.kernel.org>; Tue,  6 Feb 2007 15:36:20 +0100 (CET)
In-Reply-To: <45A48BEB.2070207@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 January 2007 07:47, Patrick McHardy wrote:
> KOVACS Krisztian wrote:
> > ip_route_output() contains a check to make sure that no flows with
> > non-local source IP addresses are routed. Unfortunately this check
> > makes it completely impossible to use non-local bound sockets as no
> > outbound packets will make through the stack.
> >
> > This patch moves the interface lookup to the multicast-specific code
> > path as that is the only real user of the interface data looked up.
> >
> > Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
> >
> > ---
> >
> >  net/ipv4/route.c |   13 +++++--------
> >  1 files changed, 5 insertions(+), 8 deletions(-)
> >
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 537b976..bb1158a 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -2498,11 +2498,6 @@ #endif
> >  		    ZERONET(oldflp->fl4_src))
> >  			goto out;
> >
> > -		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
> > -		dev_out = ip_dev_find(oldflp->fl4_src);
> > -		if (dev_out == NULL)
> > -			goto out;
> > -
>
> I'm not sure how exactly this is used by applications, but couldn't you
> restrict this to sockets without freebind?

As it turned out since I've submitted this patch simply removing the 
branch in the quoted patch above is not good, as that'd allow all local 
users to generate connections from a non-local IP address. (Since setting 
IP_FREEBIND does not require CAP_NET_ADMIN.)

I've attempted to restrict the removal of the check to certain sockets, 
but it is more difficult than expected. It'd require touching a lot of 
areas of the kernel code, as the socket is not available at times where 
an output routing lookup is requested.

In fact the only thing available when making the decision in 
ip_route_output_slow() is a struct flowi. I've tried to stuff a flag bit 
into "struct flowi", but that solution seems to be very risky, as the 
value for "struct flowi->flags" is not consulted at a lot of places. IMHO 
the result would be far from pretty... (And I have to admit that I don't 
really know what flowi->flags is used for. I've found no in-tree user of 
that field. The only defined flag bit, FLOWI_FLAG_MULTIPATHOLDROUTE, has 
no in-tree user either.)

And even if we have this flag in place, it's not enough to set it for 
certain sockets in ip_route_connect(): this would not handle SYN+ACK or 
ACK packets sent in response for redirected TCP connection attempts. And 
who knows what else is still hiding there: ip_route_output_*() calls are 
pretty much everywhere in the whole net/ipv4 directory.

So I think the cleanest solution would be to require CAP_NET_ADMIN for 
IP_FREEBIND. This way, a non-root process would not be allowed to bind to 
a non-local socket, thus it would not be possible to initiate connections 
from a non-local IP.

As this would be a change in the kernel ABI, me and Balazs have tried to 
search for applications using the IP_FREEBIND option using Google 
codesearch (www.google.com/codesearch).

Outside libc and kernel, we've found only three applications that mention
this option:
* socat: which allows setting all socket options by the user (I doubt 
using IP_FREEBIND with socat has any meaningful use)
* strace: to be able to dump IP_FREEBIND
* qemu: for emulating Linux system calls

Neither of these require IP_FREEBIND as core functionality, and will 
probably work if IP_FREEBIND would be bound to CAP_NET_ADMIN.

So the question is: shall we take the IP_FREEBIND approach, this would 
change a hardly ever used interface by requiring CAP_NET_ADMIN 
capabilities, or we should try finding all the scattered places in the 
Linux IP stack which does a route lookup?

-- 
 Regards,
  Krisztian Kovacs
