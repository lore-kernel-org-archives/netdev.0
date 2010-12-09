From: Simon Kirby <sim@hostway.ca>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Wed, 8 Dec 2010 18:35:09 -0800
Message-ID: <20101209023509.GA21216@hostway.ca>
References: <20101203103447.GA29714@hostway.ca> <1291375743.2897.141.camel@edumazet-laptop> <20101203123617.GA6993@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:47949 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754890Ab0LICfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 21:35:12 -0500
Content-Disposition: inline
In-Reply-To: <20101203123617.GA6993@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 03, 2010 at 09:36:19PM +0900, Simon Horman wrote:

> On Fri, Dec 03, 2010 at 12:29:03PM +0100, Eric Dumazet wrote:
> > Le vendredi 03 d??cembre 2010 ?? 02:34 -0800, Simon Kirby a ??crit :
> > > Hello!
> > > 
> > > We upgraded some LVS (DR) servers from 2.6.35 to 2.6.36 on tg3 cards
> > > (partno(BCM95721) rev 4201) with VLAN tags in use, to think that
> > > everything looked great, but in fact...
> > > 
> > > LVS was receiving magically-merged TCP packets which it tried to forward
> > > on to the real server, only to get annoyed at itself for trying to
> > > forward a packet bigger than the device MTU:
> > > 
> > > IP A.47376 > B.529: . 175488:176936(1448) ack 1 win 92 <nop,nop,timestamp 52737308 29656081>
> > > IP A.47376 > B.529: . 176936:179832(2896) ack 1 win 92 <nop,nop,timestamp 52737325 29656098>
> > > IP B > A: ICMP B unreachable - need to frag (mtu 1500), length 556
> > > 
> > 
> > Hi Simon
> > 
> > This is a tcpdump on A ?
> > Could you take it also on B ?
> > 
> > tcpdump displays large buffers, but they should be split (of course)
> > when sent on wire.

I assume you don't need this anymore since the problem was figured out?
Otherwise, let me know.

> > > This caused packet loss for any merged frames, which caused abysmal
> > > performance for uploads via the LVS server.  Local performance to or
> > > from the box is still fine, because the stack doesn't care, only the
> > > forwarding part of LVS is running into the problem.
> > > 
> > > Furthermore, disabling _everything_ reported by ethtool -k doesn't seem
> > > to change the result, even if I down/up the interface after, and even if
> > > I try on every single interface including the VLANned ones.  This seems
> > > to be another bug.  Reverting to 2.6.35 makes it all work again.
> > > 
> > > Possibly related to commit 7fe876af921d1d2bc8353e0062c10ff35e902653
> > > 
> > > So how should this be fixed?  Should LVS be taught to fragment, or must
> > > we disable the merging in this case?  It seems like it would work well if
> > > the sending side could do the same offload in reverse, but I'm not sure
> > > if that would be possible.
> > > 
> > > Simon-
> > 
> > 
> > I believe Simon Horman has some patches for GRO and LVS.
> > 
> > Please send the results of "ethtool -k eth0" on all your nics / vlans ?
> > 
> > For TSO, I am not sure why and where it could matter...
> 
> There is a patch to teach LVS how to cope with GRO in nf-next-2.6
> and I expect it to be included in 2.6.38. The patch is "ipvs: allow
> transmit of GRO aggregated skbs" and perhaps it should be considered
> for 2.6.37 and stable. In general the work around is to disable GRO.
> 
> The patch does not resolve the incompatibility of LVS with LRO.
> The work around there is to disable LRO. I'm not entirely sure
> how to teach LVS to disable LRO automatically, or if its desirable.

Yeah, things will still break if the interfaces have mismatched GRO
support, etc.

It would be nice if it could be all smart about it, but I don't see how
this could be done sanely, as it doesn't know if the destination
interface could support GRO transmission until it has gone through the
LVS processing.  Would software GRO be faster on transmission be faster
than no GRO at all?

> Simon, you mention that you disabled everything with ethtool, but the
> tcpdump above shows a 2896 byte packet, which seems that GRO (or LRO?) is
> active. So perhaps as you speculate that is a bug

Right.  So, on 2.6.35, ethtool shows:

# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off

# ethtool -k eth1.39
Offload parameters for eth1.39:
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
large receive offload: off

On 2.6.36, ethtool shows:

# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off

# ethtool -k eth1.39
Offload parameters for eth1.39:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off

And if I set it with ethtool -K eth1.39 gso off; ethtool -K eth1 gso off,
it says "off", but I still see merged frames, as verified with an nc <
/dev/zero and tcpdump -i any -n 'length > 1500'.

> I will prepare a backport of the "ipvs: allow transmit of GRO aggregated
> skbs" patch to v2.6.36 and post it shortly.  Testing to see if that
> resolves the problem that you are seeing would probably be a good start.

I can test this in our case, and it should specifically work on the
servers we were seeing the problem on, but it still needs some
complicated logic to be safe for all cases (like when LVS decides to
route out an interface without GRO).  Anyway, thanks!

Simon-
