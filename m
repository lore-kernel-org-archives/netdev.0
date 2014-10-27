From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poor UDP throughput with virtual devices and UFO
Date: Mon, 27 Oct 2014 08:01:29 -0700
Message-ID: <1414422089.16231.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414405781.4492.38.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <edumazet@google.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:41778 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbaJ0PBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 11:01:30 -0400
Received: by mail-pa0-f46.google.com with SMTP id lf10so3977362pab.19
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 08:01:30 -0700 (PDT)
In-Reply-To: <1414405781.4492.38.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-27 at 19:29 +0900, Toshiaki Makita wrote:
> Hi,

...

> I wrote a patch to increase sk_wmem_alloc in skb_segment(), but I'm wondering
> if we can do this change since it has been this way for years and only TCP
> handles it so far (d6a4a1041176 "tcp: GSO should be TSQ friendly").

Thats probably because UFO is kind of strange : No NIC actually does UDP
segmentation.

> ----
> Subject: [PATCH net] gso: Inherit sk_wmem_alloc
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/core/skbuff.c      |  6 +++++-
>  net/ipv4/tcp_offload.c | 13 ++++---------
>  2 files changed, 9 insertions(+), 10 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c16615b..29dc763 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3020,7 +3020,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  							    len, 0);
>  			SKB_GSO_CB(nskb)->csum_start =
>  			    skb_headroom(nskb) + doffset;
> -			continue;
> +			goto set_owner;
>  		}
>  
>  		nskb_frag = skb_shinfo(nskb)->frags;
> @@ -3092,6 +3092,10 @@ perform_csum_check:
>  			SKB_GSO_CB(nskb)->csum_start =
>  			    skb_headroom(nskb) + doffset;
>  		}
> +
> +set_owner:
> +		if (head_skb->sk)
> +			skb_set_owner_w(nskb, head_skb->sk);
>  	} while ((offset += len) < head_skb->len);
>  
>  	/* Some callers want to get the end of the list.
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index 5b90f2f..93758a8 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -139,11 +139,8 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>  			th->check = gso_make_checksum(skb, ~th->check);
>  
>  		seq += mss;
> -		if (copy_destructor) {
> +		if (copy_destructor)
>  			skb->destructor = gso_skb->destructor;
> -			skb->sk = gso_skb->sk;
> -			sum_truesize += skb->truesize;
> -		}
>  		skb = skb->next;
>  		th = tcp_hdr(skb);
>  
> @@ -157,11 +154,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>  	 * is freed by GSO engine
>  	 */
>  	if (copy_destructor) {
> -		swap(gso_skb->sk, skb->sk);
> -		swap(gso_skb->destructor, skb->destructor);
> -		sum_truesize += skb->truesize;
> -		atomic_add(sum_truesize - gso_skb->truesize,
> -			   &skb->sk->sk_wmem_alloc);
> +		skb->destructor = gso_skb->destructor;
> +		gso_skb->destructor = NULL;
> +		atomic_sub(gso_skb->truesize, &skb->sk->sk_wmem_alloc);
>  	}
>  
>  	delta = htonl(oldlen + (skb_tail_pointer(skb) -


Please rewrite your patch to move the code out of tcp_gso_segment() into
skb_segment()

Look how I carefully avoided many atomic operations on
sk->sk_wmem_alloc, but how you removed it. :(

Alternative would be to use a single skb_set_owner_w() on the last
segment, and tweak its truesize to not corrupt sk->sk_wmem_alloc

d6a4a1041176 was needed for people using GSO=off TSO=off on a bonding
device, while best performance is reached with TSO=on so that
segmentation is performed later on the slave device.

Thanks
