From: Simon Kirby <sim@hostway.ca>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Wed, 22 Dec 2010 15:39:48 -0800
Message-ID: <20101222233948.GC17581@hostway.ca>
References: <20101203103447.GA29714@hostway.ca> <1291375743.2897.141.camel@edumazet-laptop> <20101203123617.GA6993@verge.net.au> <20101209023509.GA21216@hostway.ca> <1291863119.2795.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:55470 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751394Ab0LVXju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 18:39:50 -0500
Content-Disposition: inline
In-Reply-To: <1291863119.2795.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 09, 2010 at 03:51:59AM +0100, Eric Dumazet wrote:

> Le mercredi 08 d??cembre 2010 ?? 18:35 -0800, Simon Kirby a ??crit :
> 
> > Right.  So, on 2.6.35, ethtool shows:
> > 
> > # ethtool -k eth1
> > Offload parameters for eth1:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp segmentation offload: on
> > udp fragmentation offload: off
> > generic segmentation offload: on
> > large receive offload: off
> > 
> > # ethtool -k eth1.39
> > Offload parameters for eth1.39:
> > rx-checksumming: on
> > tx-checksumming: off
> > scatter-gather: off
> > tcp segmentation offload: off
> > udp fragmentation offload: off
> > generic segmentation offload: off
> > large receive offload: off
> > 
> > On 2.6.36, ethtool shows:
> > 
> > # ethtool -k eth1
> > Offload parameters for eth1:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp segmentation offload: on
> > udp fragmentation offload: off
> > generic segmentation offload: on
> > large receive offload: off
> > 
> > # ethtool -k eth1.39
> > Offload parameters for eth1.39:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp segmentation offload: on
> > udp fragmentation offload: off
> > generic segmentation offload: on
> > large receive offload: off
> > 
> > And if I set it with ethtool -K eth1.39 gso off; ethtool -K eth1 gso off,
> > it says "off", but I still see merged frames, as verified with an nc <
> > /dev/zero and tcpdump -i any -n 'length > 1500'.
> 
> Yep, but you also have "tso on" by default on 2.6.36 and eth1.39 (vlan)

and turning it off makes no difference, either.  Even if I down/up the
interface after.  I still see merged packets on receive, even if I try to
use ethtool to turn off everything that is "on".  It's as if the new code
to enable it on vlans works, but the disable from ethtool does not.

In other words, I cannot find a way to disable it (and thus make LVS
work) on 2.6.36 or 2.6.37-rc6.

One interesting note is that if I destroy and recreate the VLAN interface,
it comes back with gso enabled:

# ethtool -K eth1 gso off
# ethtool -K eth1.39 gso off
# ethtool -K eth1 tso off
# ethtool -K eth1.39 tso off
# ifdown eth1.39
Removed VLAN -:eth1.39:-
# ifconfig eth1 down
# ifup eth1.39
Added VLAN with VID == 39 to IF -:eth1:-
# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
large receive offload: off
# ethtool -k eth1.39
Offload parameters for eth1.39:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off
# ethtool -K eth1.39 gso off
# ethtool -k eth1.39
Offload parameters for eth1.39:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
large receive offload: off
# ifdown eth1.39; ifup eth1.39
Removed VLAN -:eth1.39:-
Added VLAN with VID == 39 to IF -:eth1:-
# ethtool -k eth1.39
Offload parameters for eth1.39:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off

So, the bug seems to related using it on VLANs.

Simon-

> > > I will prepare a backport of the "ipvs: allow transmit of GRO aggregated
> > > skbs" patch to v2.6.36 and post it shortly.  Testing to see if that
> > > resolves the problem that you are seeing would probably be a good start.
> > 
> > I can test this in our case, and it should specifically work on the
> > servers we were seeing the problem on, but it still needs some
> > complicated logic to be safe for all cases (like when LVS decides to
> > route out an interface without GRO).  Anyway, thanks!
> > 
> > Simon-
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
