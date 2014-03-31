From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gro: restore frag0 optimization
Date: Mon, 31 Mar 2014 16:27:47 -0400 (EDT)
Message-ID: <20140331.162747.1884094141150130320.davem@davemloft.net>
References: <53345A6C.5080008@redhat.com>
	<1395940898.12610.307.camel@edumazet-glaptop2.roam.corp.google.com>
	<1396153701.29410.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	hkchu@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbaCaU1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:27:50 -0400
In-Reply-To: <1396153701.29410.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 29 Mar 2014 21:28:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Main difference between napi_frags_skb() and napi_gro_receive() is that
> the later is called while ethernet header was already pulled by the NIC
> driver (eth_type_trans() was called before napi_gro_receive())
> 
> Jerry Chu in commit 299603e8370a ("net-gro: Prepare GRO stack for the
> upcoming tunneling support") tried to remove this difference by calling
> eth_type_trans() from napi_frags_skb() instead of doing this later from
> napi_frags_finish()
> 
> Goal was that napi_gro_complete() could call 
> ptype->callbacks.gro_complete(skb, 0)  (offset of first network header =
> 0)
> 
> Also, xxx_gro_receive() handlers all use off = skb_gro_offset(skb) to
> point to their own header, for the current skb and ones held in gro_list
> 
> Problem is this cleanup work defeated the frag0 optimization:
> It turns out the consecutive pskb_may_pull() calls are too expensive.
> 
> This patch brings back the frag0 stuff in napi_frags_skb().
> 
> As all skb have their mac header in skb head, we no longer need
> skb_gro_mac_header()
> 
> Reported-by: Michal Schmidt <mschmidt@redhat.com>
> Fixes: 299603e8370a ("net-gro: Prepare GRO stack for the upcoming tunneling support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jerry Chu <hkchu@google.com>
> ---
> David, this patch is definitely risky, I targeted net-next for staging
> it. I tested it with mlx4 NIC.
> 
> BTW, I believe the BUG_ON(skb->end - skb->tail < grow); could trigger
> if the headers are bigger than what the driver allocated for skb->head.
> 
> After encapsulation support added by Jerry, this might happen ?
> 
> We probably need to tweak skb_gro_reset_offset() to cap frag0_len to
> force calling slow path. I'll cook a patch.

Ok, applied, thanks for taking care of this Eric.

We can send to -stable after it's gotten a lot of testing and
auditing.
