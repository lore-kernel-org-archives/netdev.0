From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect
 forwarding path against pmtu spoofing
Date: Wed, 18 Dec 2013 17:34:42 -0500 (EST)
Message-ID: <20131218.173442.336109133942416102.davem@davemloft.net>
References: <20131215022336.GA27866@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3LRWeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 17:34:46 -0500
In-Reply-To: <20131215022336.GA27866@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 15 Dec 2013 03:23:36 +0100

> While forwarding we should not use the protocol path mtu to calculate
> the mtu for a forwarded packet but instead use the interface mtu.
> 
> We mark forwarded skbs in ip_forward with IPSKB_FORWARDED which was
> introduced for multicast forwarding. But as it does not conflict with
> our usage in unicast code path it is perfect for reuse.
> 
> I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
> along with the new ip_dst_mtu_secure to net/ip.h to fix circular
> dependencies because of IPSKB_FORWARDED.
> 
> Because someone might have written a software which does probe
> destinations manually and expects the kernel to honour those path mtus
> I introduced a new per-namespace "forwarding_uses_pmtu" knob so someone
> can disable this new behaviour. We also use mtus which are locked on a
> route for forwarding.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Sockets aren't the only entity that create cached PMTU information
we might like to use during forwarding, tunnels do too.

I'm afraid what the side effects of this change will be in that
situation, because the dst_mtu() is exactly what will allow us
to relay the ICMP back to the pre-decapsulation source address
properly.

In any event, this code was made to explicitly behave this way
back in 2007 by John Heffner, maybe he has some opinions too.
