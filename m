From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 00:06:50 +0000
Message-ID: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <christoph.paasch@uclouvain.be>,
	<herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>,
	<hkchu@google.com>, <mwdalton@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22501 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381Ab3J3AGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:06:54 -0400
In-Reply-To: <20131029.194446.2215574000648693370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 19:44 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 29 Oct 2013 08:12:35 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> > by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> > 
> > (Jerry is working on adding native GRO support for tunnels)
> > 
> > skb_segment() only deals with a frag_list chain containing MSS sized
> > fragments.
> > 
> > This patch adds support any kind of frag, and adds a new sysctl,
> > as clearly the GRO layer should avoid building frag_list skbs
> > on a router, as the segmentation is adding cpu overhead.
> > 
> > Note that we could try to reuse page fragments instead of doing
> > copy to linear skbs, but this requires a fair amount of work,
> > and possible truesize nightmares, as we do not track individual
> > (per page fragment) truesizes.
> > 
> > /proc/sys/net/core/gro_frag_list_enable possible values are :
> > 
> > 0 : GRO layer is not allowed to use frag_list to extend skb capacity
> > 1 : GRO layer is allowed to use frag_list, but skb_segment()
> >     automatically sets the sysctl to 0.
> > 2 : GRO is allowed to use frag_list, and skb_segment() wont
> >     clear the sysctl.
> > 
> > Default value is 1 : automatic discovery
> > 
> > Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> > Reported-by: Jerry Chu <hkchu@google.com>
> > Cc: Michael Dalton <mwdalton@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> > v2: added missing sysctl definition in skbuff.c
> 
> I do not like the idea of packet actions indirectly changing sysctl
> values, even if you document it sufficiently as you have here.
> 
> Plus this puts the sysctl change logic in a fast path.
> 
> I would suggest instead making it change in response to changes to
> ip_forward, as we do with per-device LRO settings.  This means that,
> like ip_forward, you should also make this sysctl a global + devinet
> per-device sysctl.
> 
> You might even emit a pr_info() when this logic triggers, and if you
> are ambitious enough keep track of the previous GRO sysctl state so
> you can restore it if ip_forward is set back to zero.

Speaking of which: insteading of disabling LRO once, we really ought to
keep count of the forwarders (IPv4 routing, IPv6 routing, bridge) and
use that to mask out LRO in netdev_fix_features().

I think that the forwarder count is also needed for this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
