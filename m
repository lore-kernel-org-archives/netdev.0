From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to
 protect forward path to use pmtu info
Date: Mon, 30 Dec 2013 22:20:44 -0500 (EST)
Message-ID: <20131230.222044.884570280065942449.davem@davemloft.net>
References: <20131220130822.GD32129@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab3LaDUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 22:20:48 -0500
In-Reply-To: <20131220130822.GD32129@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 20 Dec 2013 14:08:22 +0100

> Provide a mode where the forwarding path does not use the protocol path
> MTU to calculate the maximum size for a forwarded packet but instead
> uses the interface or the per-route locked MTU.
> 
> It is easy to inject bogus or malicious path mtu information which
> will cause either unneeded fragmentation-needed icmp errors (in case
> of DF-bit set) or unnecessary fragmentation of packets (by default down
> to min_pmtu). This could be used to either create blackholes on routers
> (if the generated DF-bit gets dropped later on) or to leverage attacks
> on fragmentation.
> 
> Forwarded skbs are marked with IPSKB_FORWARDED in ip_forward. This flag
> was introduced for multicast forwarding, but as it does not conflict with
> our usage in the unicast code path it is perfect for reuse.
> 
> I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
> along with the new ip_dst_mtu_secure to net/ip.h to fix circular
> dependencies because of IPSKB_FORWARDED.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> v2:
> * forwarding_uses_pmtu default to on
> * reworded documentation and changelog

Sorry Hannes, I'm still not happy with this change at all.

First of all, you misunderstood what I said last time around.
I basically was trying to say that if you make this facility
available at all, distributions are going to turn it on by
default even if you make the kernel default to off.

That drives me nuts, and I don't want to give people this
opportunity to screw things up again just like they did
for rp_filter, which also defaults to off.

Secondly, I don't see how this is as big of an issue as you
present it to be.  At best, the language is way too strong.

How can PMTU information be injected into the kernel?

Local connections, well we want that and it's good.  And for TCP you
have to be able to inject a valid TCP packet that can be validated by
the stack for the PMTU information to stick.

Tunnels, well you said that tunnels don't apply to this change.

The only thing left are things like AH and ESP, which also perform
some level of validation making sure that some state exists.  And
frankly for non-tunneled IPSEC this PMTU information is absolutely
essential.

I really don't want to apply these changes, sorry.
