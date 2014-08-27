From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next] ipv6: stop sending PTB packets for MTU <
 1280
Date: Thu, 28 Aug 2014 01:07:23 +0200
Message-ID: <1409180843.16990.33.camel@localhost>
References: <53F39E50.1020209@gont.com.ar>
		 <1409005545-24910-2-git-send-email-hagen@jauu.net>
	 <1409006842.6274.69.camel@localhost> <53FE4086.8040708@si6networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Fernando Gont <fgont@si6networks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44098 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964814AbaH0XHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:07:25 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 17DA3202B7
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 19:07:25 -0400 (EDT)
In-Reply-To: <53FE4086.8040708@si6networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fernando,

On Mi, 2014-08-27 at 17:33 -0300, Fernando Gont wrote:
> On 08/25/2014 07:47 PM, Hannes Frederic Sowa wrote:
> > Hi Hagen,
> > 
> > On Di, 2014-08-26 at 00:25 +0200, Hagen Paul Pfeifer wrote:
> >> Reduce the attack vector and stop generating ICMPv6 packet to big for
> >> packets smaller then the minimal required IPv6 MTU.
> >>
> >> See
> >> http://tools.ietf.org/html/draft-gont-6man-deprecate-atomfrag-generation-00
> > 
> > I wonder if we should wait until this gets RFC status?
> > 
> > I very much welcome this decision! I already raised this problem some
> > time ago:
> > http://lists.openwall.net/netdev/2013/12/31/17
> 
> FWIW, this issue you reported is related, but different from the one
> I've described. The one I've described is based on sending ICMPv6
> PTB<1280.   RFC2460 states that when you receive an ICMPv6 PTB<1280 you
> should add a Fragment Header to all packets sent to that destination
> (i.e., produce the so called "IPv6 atomic fragments").
> 
> These "atomic fragments" have an offset=0, and MF=0 -- i.e., they are
> not really fragmented.

Sure, in this specific thread I was mostly concerned with DNS packet
blackholing in forwarding path. Because of DNSSEC packets also easily
getting bigger than 1280 bytes this effect could also hurt people
without dst_allfrag being true (the function which checks if atomic
fragments are in effect along a route because of a <1280 PtB
notification before). At that time, I had atomic fragments in mind, they
just weren't that much of a problem as we are not concerned about them
in forwarding path and don't check for dst_allfrag there. But we also
had other changes to harden the host side in regard to PtB acceptance,
specifically this also helps to harden against spoofed PtB with mtu <
1280, see below.

At former times Linux used path mtu information in the forwarding path,
so not only the end system would be vulnerable, but all systems along
the way if one could sneak in a PtB error to reduce path mtu. This could
get used to inject PtB notifications even into full quadruple looked up
connections by just letting the router returning the PtB error instead
of directly spoofing it. At least there is no way you could generate
PtBs with mtus smaller than 1280, so no problems in regard to atomic
fragments.

You still had to ensure to hit a live socket, though. On DNS servers
with UDP this could be easily done because on unconnected sockets we
only do a 2-tuple lookup on the socket to validate the PtB error, so it
was easily possible to hit unconnected DNS servers ports on a router.

For protection on the host side:

In case you have an IPv6 socket and you want to ensure that no PtB
information will be accepted by it you already can set IP_MTU_DISCOVER
to IP_PMTUDISC_OMIT (or to IP_PMTUDISC_INTERFACE but kernel will then
start to reject creating fragments at all and will signal error to user
space). This is already implemented in unbound and hopefully already
found its way into BIND to protect DNS.

> Hence the trivial way to mitigate this attack is to drop incoming ICMPv6
> PTB1280 (or, at the very least, don't react to them by sending all
> subsequent packets with a Fragment Header).

Yes, atomic fragments aggravate this problem.

In retrospect, I don't know about other operationg systems, at that time
I only checked Linux and FreeBSD:

FreeBSD only uses interface MTU to check if PtB should be generated in
forwarding path.
Linux used to check path mtu but I converted that to checks for
interface mtu only in fwd path, too.

FreeBSD only accepts PtB information for TCP connections where the inner
data of the ICMP error matches the full quadruple of a tcp connected
socket. FreeBSD also validates that the ICMP(v6) is in the TCP window.

FreeBSD does not deal with PtB information on UDP sockets at all!

Linux does the same for TCP sockets (also checks windowing information).
But Linux also accepts 2-tuple UDP PtB errors (unconnected sockets),
this is now configurable on a per socket basis but we don't have a way
to turn this mode on globally as this is possible for IPv4.

That said, it is not that easy to forge PtB information any more. Only
systems where unconnected UDP sockets are exposed may be easily attacked
(but this is still a big enough attack vector). On TCP connections one
would need to spray a lot of packets against those hosts to match full
quadruple and get into the TCP window.

Bye,
Hannes
