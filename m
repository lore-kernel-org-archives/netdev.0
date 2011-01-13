From: Simon Horman <horms@verge.net.au>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Thu, 13 Jan 2011 15:34:22 +0900
Message-ID: <20110113063422.GB14643@verge.net.au>
References: <20101203103447.GA29714@hostway.ca>
 <1291375743.2897.141.camel@edumazet-laptop>
 <20101203123617.GA6993@verge.net.au>
 <20101209023509.GA21216@hostway.ca>
 <1291863119.2795.29.camel@edumazet-laptop>
 <20101222233948.GC17581@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54264 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab1AMGe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 01:34:26 -0500
Content-Disposition: inline
In-Reply-To: <20101222233948.GC17581@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 22, 2010 at 03:39:48PM -0800, Simon Kirby wrote:
> On Thu, Dec 09, 2010 at 03:51:59AM +0100, Eric Dumazet wrote:
> 
> > Le mercredi 08 d??cembre 2010 ?? 18:35 -0800, Simon Kirby a ??crit :
> > 
> > > Right.  So, on 2.6.35, ethtool shows:
> > > 
> > > # ethtool -k eth1
> > > Offload parameters for eth1:
> > > rx-checksumming: on
> > > tx-checksumming: on
> > > scatter-gather: on
> > > tcp segmentation offload: on
> > > udp fragmentation offload: off
> > > generic segmentation offload: on
> > > large receive offload: off
> > > 
> > > # ethtool -k eth1.39
> > > Offload parameters for eth1.39:
> > > rx-checksumming: on
> > > tx-checksumming: off
> > > scatter-gather: off
> > > tcp segmentation offload: off
> > > udp fragmentation offload: off
> > > generic segmentation offload: off
> > > large receive offload: off
> > > 
> > > On 2.6.36, ethtool shows:
> > > 
> > > # ethtool -k eth1
> > > Offload parameters for eth1:
> > > rx-checksumming: on
> > > tx-checksumming: on
> > > scatter-gather: on
> > > tcp segmentation offload: on
> > > udp fragmentation offload: off
> > > generic segmentation offload: on
> > > large receive offload: off
> > > 
> > > # ethtool -k eth1.39
> > > Offload parameters for eth1.39:
> > > rx-checksumming: on
> > > tx-checksumming: on
> > > scatter-gather: on
> > > tcp segmentation offload: on
> > > udp fragmentation offload: off
> > > generic segmentation offload: on
> > > large receive offload: off
> > > 
> > > And if I set it with ethtool -K eth1.39 gso off; ethtool -K eth1 gso off,
> > > it says "off", but I still see merged frames, as verified with an nc <
> > > /dev/zero and tcpdump -i any -n 'length > 1500'.
> > 
> > Yep, but you also have "tso on" by default on 2.6.36 and eth1.39 (vlan)
> 
> and turning it off makes no difference, either.  Even if I down/up the
> interface after.  I still see merged packets on receive, even if I try to
> use ethtool to turn off everything that is "on".  It's as if the new code
> to enable it on vlans works, but the disable from ethtool does not.
> 
> In other words, I cannot find a way to disable it (and thus make LVS
> work) on 2.6.36 or 2.6.37-rc6.

Hi Simon,

thanks for prodding me to respond to this post offline and sorry for not
responding earlier.

Firstly, I think that this is a receive-side problem so I don't believe
that GSO (generic segmentation offload) or other transmit-side options are
likely to have any affect.

My understanding is that on the receive-side there are two options which
when enabled can result in the behaviour that you describe.

* LRO (large receive offload)

  You have this disabled, and assuming it really is disabled it
  shouldn't be causing a problem.

* GRO (generic receive offload)

  This does not seem to be in the output of your ethtool commands at all.
  So I wonder if your ethtool is too old to support this option?

  In any case, I was able to reproduce the problem that you describe (or at
  least something very similar) using 2.6.36 with GRO enabled on eth1.1 and
  the problem did not manifest when I disabled GRO on eth1.1.

N.B: I'm not sure that I have any hardware whose driver supports LRO
     so my tests were made without LRO support.

> One interesting note is that if I destroy and recreate the VLAN interface,
> it comes back with gso enabled:

I guess that relate to how the default is set.
I don't imagine that it is the cause of the problem that you are seeing.
