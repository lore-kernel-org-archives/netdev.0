From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/4] net: allow setting congctl via routing
 table
Date: Fri, 05 Dec 2014 22:03:33 +0100
Message-ID: <1417813413.6122.7.camel@localhost>
References: <1417793092-6263-1-git-send-email-dborkman@redhat.com>
	 <CAA93jw46b5hCFPAwziyTRpTAzLdXeb4nrTEZXiEqxYWhRi49CA@mail.gmail.com>
	 <1417804540.2462.4.camel@localhost>
	 <CAA93jw5SCx32T1Z-cSeAyHFWiQsW9gp20Qoq3v=w_RO7sq=VoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33138 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751915AbaLEVDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 16:03:36 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 7817E20809
	for <netdev@vger.kernel.org>; Fri,  5 Dec 2014 16:03:35 -0500 (EST)
In-Reply-To: <CAA93jw5SCx32T1Z-cSeAyHFWiQsW9gp20Qoq3v=w_RO7sq=VoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Fr, 2014-12-05 at 11:05 -0800, Dave Taht wrote:
> On Fri, Dec 5, 2014 at 10:35 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Fr, 2014-12-05 at 08:35 -0800, Dave Taht wrote:
> >> On Fri, Dec 5, 2014 at 7:24 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> >> > This is the second part of our work and allows for setting the congestion
> >> > control algorithm via routing table. For details, please see individual
> >> > patches.
> >> >
> >> > Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.
> >> >
> >> > Thanks!
> >> >
> >> > Daniel Borkmann (4):
> >> >   net: tcp: refactor reinitialization of congestion control
> >> >   net: tcp: add key management to congestion control
> >> >   net: tcp: add RTAX_CC_ALGO fib handling
> >> >   net: tcp: add per route congestion control
> >>
> >>
> >> Very interesting. Have you tried something other than dctcp here
> >> (e.g. westwood or lp?)
> >>
> >> Have you considered the case where the route changes underneath
> >> you from one device to another?
> >
> > Notice, there is no way the state of a tcp congestion control algorithm
> > can be converted to be used by a different one, so this would only
> > affect new tcp connections via this interface.
> 
> You are missing the point. If the route changes from a path that
> is DCTCP capable to one that is not, (say you fail over to a backup link)

I don't think that today's datacenter are designed that the backup path
has less performance than the primary link (different AQM settings). It
is much more important e.g. to allow the connections to a e.g. database
server selecting dctcp as CC and having all connections going to the
internet using some "ordinary" tcp congestion algorithm.

> and flows persist, bad things will happen. DCTCP, in particular, depends
> upon a very specific AQM configuration on all the hops in the path, without that
> it can be very aggressive.

That's for sure.

> I do think it is feasible to convert from at least some of the
> core state from one tcp congestion control algorithm to another.

Hmm, I haven't looked if that is possible. It might be.

> >> Example, here I am routing everything through eth0, where I
> >> would want cubic, probably...
> >>
> >> root@ganesha:~/git/tinc# ip route
> >> default via 172.26.16.1 dev eth0  proto babel onlink
> >> 69.181.216.0/22 via 172.26.16.1 dev eth0  proto babel onlink
> >> 169.254.0.0/16 dev eth0  scope link  metric 1000
> >> 172.26.16.0/24 dev eth0  proto kernel  scope link  src 172.26.16.177
> >> 172.26.16.1 via 172.26.16.1 dev eth0  proto babel onlink
> >> 172.26.16.112 via 172.26.16.112 dev eth0  proto babel onlink
> >> 172.26.17.0/24 via 172.26.16.1 dev eth0  proto babel onlink
> >> 172.26.17.3 via 172.26.16.1 dev eth0  proto babel onlink
> >> 172.26.17.227 via 172.26.16.1 dev eth0  proto babel onlink
> >> 192.168.7.0/30 dev eth1  proto kernel  scope link  src 192.168.7.1  metric 1
> >> 192.168.7.2 via 172.26.16.112 dev eth0  proto babel onlink
> >>
> >> And I pull the plug, and everything flips over to wlan0,
> >> where I might want westwood (or something saner than
> >> that. It might be nice to have a per-device cc default
> >> algorithm...)
> >
> > Something like that might be possible with metrics and "via ... dev if0
> > metric xxx" routes, which will be cleaned up as soon as the interface
> > goes down and the fallback will be to a route with a different
> > congestion algorithm.
> 
> mmm... I do dynamic routing via various routing protocols, which
> generally don't bother with inserting more than one metric.

I totally understand, they might even remove the routes and re-add them,
thus losing the tcp cc property.

> While we are thinking through this, what happens with tunnels?

Tunnels should behave just like ordinary interfaces, but depending how
they get routed it might make problems regarding DCTCP.

> This route in my network switches between interfaces and routes
> depending on which is best.
> 
> fde5:dfb9:df90:fff0::/64 dev vpn6  proto kernel  metric 256
> fde5:dfb9:df90:fff0::/60 via fde5:dfb9:df90:fff0::1 dev vpn6  metric 1024
> 
> 
> >> root@ganesha:~/git/tinc# ip route
> >> default via 172.26.17.224 dev wlan0  proto babel onlink
> >> 69.181.216.0/22 via 172.26.17.224 dev wlan0  proto babel onlink
> >> 169.254.0.0/16 dev eth0  scope link  metric 1000
> >> 172.26.16.0/24 dev eth0  proto kernel  scope link  src 172.26.16.177
> >> 172.26.16.1 via 172.26.17.227 dev wlan0  proto babel onlink
> >> 172.26.16.112 via 172.26.17.227 dev wlan0  proto babel onlink
> >> 172.26.17.0/24 via 172.26.17.224 dev wlan0  proto babel onlink
> >> 172.26.17.3 via 172.26.17.227 dev wlan0  proto babel onlink
> >> 172.26.17.227 via 172.26.17.227 dev wlan0  proto babel onlink
> >> 192.168.7.0/30 dev eth1  proto kernel  scope link  src 192.168.7.1  metric 1
> >> 192.168.7.2 via 172.26.17.227 dev wlan0  proto babel onlink

Please note, that is is an end-node only feature. Normally, routers
don't do heavy tcp processing, thus using this feature on a router
wasn't considered by us. That's the same problematic like e.g.
tcp_quick_ack.

As soon as you have control over the application and it allows you to
bind to an interface via SO_BINDTODEVICE, you are able to select the
congestion control algorithm by using ip rule oif matching. But the
application could also chose the CC also by itself by using
'TCP_CONGESTION' setsockopt on a per-socket basis if you have source
access.

Bye,
Hannes
