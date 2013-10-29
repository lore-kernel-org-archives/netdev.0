From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 19:44:46 -0400 (EDT)
Message-ID: <20131029.194446.2215574000648693370.davem@davemloft.net>
References: <20131029090849.GC5944@cpaasch-mac>
	<1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	<1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834Ab3J2Xou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 19:44:50 -0400
In-Reply-To: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Oct 2013 08:12:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> 
> (Jerry is working on adding native GRO support for tunnels)
> 
> skb_segment() only deals with a frag_list chain containing MSS sized
> fragments.
> 
> This patch adds support any kind of frag, and adds a new sysctl,
> as clearly the GRO layer should avoid building frag_list skbs
> on a router, as the segmentation is adding cpu overhead.
> 
> Note that we could try to reuse page fragments instead of doing
> copy to linear skbs, but this requires a fair amount of work,
> and possible truesize nightmares, as we do not track individual
> (per page fragment) truesizes.
> 
> /proc/sys/net/core/gro_frag_list_enable possible values are :
> 
> 0 : GRO layer is not allowed to use frag_list to extend skb capacity
> 1 : GRO layer is allowed to use frag_list, but skb_segment()
>     automatically sets the sysctl to 0.
> 2 : GRO is allowed to use frag_list, and skb_segment() wont
>     clear the sysctl.
> 
> Default value is 1 : automatic discovery
> 
> Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Reported-by: Jerry Chu <hkchu@google.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: added missing sysctl definition in skbuff.c

I do not like the idea of packet actions indirectly changing sysctl
values, even if you document it sufficiently as you have here.

Plus this puts the sysctl change logic in a fast path.

I would suggest instead making it change in response to changes to
ip_forward, as we do with per-device LRO settings.  This means that,
like ip_forward, you should also make this sysctl a global + devinet
per-device sysctl.

You might even emit a pr_info() when this logic triggers, and if you
are ambitious enough keep track of the previous GRO sysctl state so
you can restore it if ip_forward is set back to zero.

Thanks.
