From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Possible networking regression in 3.6.0
Date: Wed, 3 Oct 2012 02:24:53 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
References: <506955F3.8050304@googlemail.com>  <1349082950.12401.669.camel@edumazet-glaptop>  <20121001193434.GA14236@redhat.com>  <20121001.160115.1816241312626722150.davem@davemloft.net>  <1349121884.12401.721.camel@edumazet-glaptop>
 <1349192133.12401.768.camel@edumazet-glaptop> <1349192919.12401.778.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de, Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46672 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753407Ab2JBXUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 19:20:03 -0400
In-Reply-To: <1349192919.12401.778.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 2 Oct 2012, Eric Dumazet wrote:

> > David, shouldnt we use a nh_rth_forward instead of a nh_rth_input in
> > __mkroute_input() ?
> > 
> > (And change rt_cache_route() as well ?)
> > 
> > I am testing a patch right now.
> 
> Yeah, this patch seems to fix the bug for me.
> 
> [PATCH] ipv4: properly cache forward routes
> 
> commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
> introduced a regression for forwarding.
> 
> This was hard to reproduce but the symptom was that packets were
> delivered to local host instead of being forwarded.
> 
> Add a separate cache (nh_rth_forward) to solve the problem.

	Can it be a problem related to fib_info reuse
from different routes. For example, when local IP address
is created for subnet we have:

broadcast 192.168.0.255 dev DEV  proto kernel  scope link  src 192.168.0.1
192.168.0.0/24 dev DEV  proto kernel  scope link  src 192.168.0.1
local 192.168.0.1 dev DEV  proto kernel  scope host  src 192.168.0.1

	The "dev DEV  proto kernel  scope link  src 192.168.0.1" is
a reused fib_info structure where we put cached routes.
The result can be same fib_info for 192.168.0.255 and
192.168.0.0/24. RTN_BROADCAST is cached only for input
routes. Incoming broadcast to 192.168.0.255 can be cached
and can cause problems for traffic forwarded to 192.168.0.0/24.
So, this patch should solve the problem because it
separates the broadcast from unicast traffic.

	And the ip_route_input_slow caching will work for
local and broadcast input routes (above routes 1 and 3) just
because they differ in scope and use different fib_info.

	Another possible failure is for output routes:

multicast 224.0.0.0/4 fib_info
with unicast
192.168.0.0/24 fib_info

	The multicast sets RTCF_MULTICAST | RTCF_LOCAL
and can cause problems for generated unicast traffic on
fib_info reuse. Depends on the scope, for multicast it is
usually scope global, so may be it is difficult to happen
in practice.

	__mkroute_output works for local/unicast routes
because they differ in scope.

> Many thanks to Chris Clayton for his patience and help.
> 
> Reported-by: Chris Clayton <chris2553@googlemail.com>
> Bisected-by: Chris Clayton <chris2553@googlemail.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/ip_fib.h     |    1 +
>  net/ipv4/fib_semantics.c |    1 +
>  net/ipv4/route.c         |   16 ++++++++--------
>  3 files changed, 10 insertions(+), 8 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>
