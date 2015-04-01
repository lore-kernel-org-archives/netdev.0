From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 01 Apr 2015 14:40:36 -0400 (EDT)
Message-ID: <20150401.144036.1354401396349418295.davem@davemloft.net>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbbDASki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 14:40:38 -0400
In-Reply-To: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed,  1 Apr 2015 17:07:44 +0200

> From: "hannes@stressinduktion.org" <hannes@stressinduktion.org>
> 
> We should not consult skb->sk for output decisions in xmit recursion
> levels > 0 in the stack. Otherwise local socket settings could influence
> the result of e.g. tunnel encapsulation process.
> 
> ipv6 does not conform with this in three places:
> 
> 1) ip6_fragment: we do consult ipv6_npinfo for frag_size
> 
> 2) sk_mc_loop in ipv6 uses skb->sk and checks if we should
>    loop the packet back to the local socket
> 
> 3) ip6_skb_dst_mtu could query the settings from the user socket and
>    force a wrong MTU
> 
> Furthermore:
> In sk_mc_loop we could potentially land in WARN_ON(1) if we use a
> PF_PACKET socket ontop of an IPv6-backed vxlan device.
> 
> Reuse xmit_recursion as we are currently only interested in protecting
> tunnel devices.
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> Jiri tried to fix this bug by passing down the tunnel sock pointer.
> Currently there should be no difference in behaviour with this patch.
> 
> http://patchwork.ozlabs.org/patch/380404/
> http://patchwork.ozlabs.org/patch/380406/
> http://patchwork.ozlabs.org/patch/380405/
> 
> In case we do need more specific fragmentation setup semantics we would
> need to go with Jiri's approach. Currently we don't care about sk_mc_loop
> for kernel sockets, so it is easy to just shut them up. Other options
> are safe as well.
> 
> Please review carefully!

As a short term solution I guess this is fine.

I'll let this sit for a day or two so others can review the change.
