From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH] net: ipv6 bind to device issue
Date: Wed, 21 Apr 2010 09:21:26 +0200
Message-ID: <20100421072126.GB1865@jolsa.lab.eng.brq.redhat.com>
References: <1271767572-5282-1-git-send-email-jolsa@redhat.com>
 <4BCDEED3.7040901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427Ab0DUHXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 03:23:03 -0400
Content-Disposition: inline
In-Reply-To: <4BCDEED3.7040901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 02:13:39PM -0400, Brian Haley wrote:
> Jiri Olsa wrote:
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index c2438e8..7bf7717 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
> >  {
> >  	int flags = 0;
> >  
> > -	if (rt6_need_strict(&fl->fl6_dst))
> > +	if (rt6_need_strict(&fl->fl6_dst) || fl->oif)
> >  		flags |= RT6_LOOKUP_F_IFACE;
> >  
> >  	if (!ipv6_addr_any(&fl->fl6_src))
> 
> Actually, looking at this again, we might want to swap the order
> here since fl->oif should be filled-in for most link-local and
> multicast requests calling this:
> 
> 	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
> 
> Just a thought, but it potentially saves a call to determine
> the scope of the address.
> 
> -Brian

I think it's a good idea, attaching the changed patch

thanks,
jirka
---

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
Signed-off-by: Scott Otto <scott.otto@alcatel-lucent.com>
---
 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2438e8..05ebd78 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 {
 	int flags = 0;
 
-	if (rt6_need_strict(&fl->fl6_dst))
+	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
 		flags |= RT6_LOOKUP_F_IFACE;
 
 	if (!ipv6_addr_any(&fl->fl6_src))

