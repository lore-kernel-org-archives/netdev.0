From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: gro vs vlan in myri10ge
Date: Thu, 15 Nov 2012 20:39:56 +0000
Message-ID: <1353011996.4867.74.camel@deadeye.wl.decadent.org.uk>
References: <509C6858.6010105@myri.com>
	 <1352428870.19779.496.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29310 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab2KOU7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 15:59:23 -0500
In-Reply-To: <1352428870.19779.496.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 18:41 -0800, Eric Dumazet wrote:
> On Thu, 2012-11-08 at 21:20 -0500, Andrew Gallatin wrote:
> > Hi,
> > 
> > I've wanted to convert myri10ge from LRO to GRO for quite a while.
> > The problem I'm facing is that the NIC cannot perform hardware vlan
> > tag offload, so GRO performance is far below LRO performance when
> > receiving vlan tagged TCP traffic.

Thanks for the reminder; I need to deal with this in sfc as well.

> > If a vlan tagged frame is passed to lro_receive_frags(), inet_lro will
> > look at the encapsulated IPv4 frame and TCP aggregation will succeed.
> > However, it appears that GRO will not do this.  When I patch the
> > driver to use GRO, and configure a vlan interface, I see high CPU
> > utilization and poor bandwidth when I'm receiving a netperf TCP stream
> > on the vlan interface.  If I use LRO in an unpatched driver, then I
> > see good receive performance in the same scenario.
> > 
> > What is the best way to "fix" this?
> > 
> > Unless I'm just using GRO wrong, it seems that the simplest thing for
> > me to do is to claim NETIF_F_HW_VLAN_RX, but pop the tags in the
> > driver so as to allow myri10ge to pass up a non-encapsulated frame the
> > same way that (nearly?) every other 10GbE NIC does.  I've got a quick
> > and dirty patch that confirms doing the vtag pop in the driver gives
> > me roughly the same performance with GRO as I used to have with LRO.
> > 
> > Is this (popping vlan tags in the driver) acceptable, or is it
> > too much of a layering violation?
> 
> Given GRO assumes NIC does hardware vlan offloading, I guess
> I would chose to do that.

Really, after all the changes in 2.6.37 to unify behaviour between the
offloaded and non-offloaded paths?

> It seems unfortunate to add vlan decap in GRO path, already very
> complex.

True but can't this be done at the top?

I'll post a patch for this shortly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
