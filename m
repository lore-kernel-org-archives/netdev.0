From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Sat, 4 Sep 2010 22:34:29 +0200
Message-ID: <20100904203429.GA4891@del.dom.local>
References: <1283338251.2556.124.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52793 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab0IDUeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 16:34:37 -0400
Content-Disposition: inline
In-Reply-To: <1283338251.2556.124.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 09/01/2010 12:50 PM:

> [PATCH] gro: fix different skb headrooms
> 
> packets entering GRO might have different headrooms, even for a given
> flow (because of implementation details in drivers, like copybreak).
> We cant force drivers to deliver packets with a fixed headroom.
> 
> 1) fix skb_segment()
> 
> skb_segment() makes the false assumption headrooms of fragments are same
> than the head. When CHECKSUM_PARTIAL is used, this can give csum_start
> errors, and crash later in skb_copy_and_csum_dev()
> 
> 2) allocate a minimal skb for head of frag_list
> 
> skb_gro_receive() uses netdev_alloc_skb(headroom + skb_gro_offset(p)) to
> allocate a fresh skb. This adds NET_SKB_PAD to a padding already
> provided by netdevice, depending on various things, like copybreak.
> 
> Use alloc_skb() to allocate an exact padding, to reduce cache line
> needs:
> NET_SKB_PAD + NET_IP_ALIGN
> 
> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=16626
> 
> Many thanks to Plamen Petrov, testing many debugging patches !
> With help of Jarek Poplawski.
> 
> Reported-by: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jarek Poplawski <jarkao2@gmail.com>
> ---
> patch against linux-2.6 current tree
> 
>  net/core/skbuff.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
...
> @@ -2702,8 +2706,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>  	} else if (skb_gro_len(p) != pinfo->gso_size)
>  		return -E2BIG;
>  
> -	headroom = skb_headroom(p);
> -	nskb = netdev_alloc_skb(p->dev, headroom + skb_gro_offset(p));
> +	headroom = NET_SKB_PAD + NET_IP_ALIGN;
> +	nskb = alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
>  	if (unlikely(!nskb))
>  		return -ENOMEM;

Hi again,

Just had a second look, and unless I miss something...

Plamen, could you test this patch, too? (Without removing the previous
one.)

Thanks,
Jarek P.

------------------->

[PATCH] gro: Re-fix different skb headrooms

The patch: "gro: fix different skb headrooms" in its part:
"2) allocate a minimal skb for head of frag_list" is buggy. The copied
skb has p->data set at the ip header at the moment, and skb_gro_offset
is the length of ip + tcp headers. So, after the change the length of
mac header is skipped. Later skb_set_mac_header() sets it into the
NET_SKB_PAD area (if it's long enough) and ip header is misaligned at
NET_SKB_PAD + NET_IP_ALIGN offset. There is no reason to assume the
original skb was wrongly allocated, so let's copy it as it was.

bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=16626
fixes commit: 3d3be4333fdf6faa080947b331a6a19bce1a4f57

Reported-by: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 26396ff..c83b421 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2706,7 +2706,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	} else if (skb_gro_len(p) != pinfo->gso_size)
 		return -E2BIG;
 
-	headroom = NET_SKB_PAD + NET_IP_ALIGN;
+	headroom = skb_headroom(p);
 	nskb = alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
 	if (unlikely(!nskb))
 		return -ENOMEM;
