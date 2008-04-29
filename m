From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPv4] UFO: prevent generation of chained skb
Date: Tue, 29 Apr 2008 03:27:14 -0700 (PDT)
Message-ID: <20080429.032714.263350536.davem@davemloft.net>
References: <BAY121-W44CAF03A4C79BFC4FEEEBDB6DE0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: bkostya@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753429AbYD2K1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:27:15 -0400
In-Reply-To: <BAY121-W44CAF03A4C79BFC4FEEEBDB6DE0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kostya B <bkostya@hotmail.com>
Date: Mon, 28 Apr 2008 12:13:27 +0000

> 
> [IPv4] UFO: prevent generation of chained skb destined to UFO device
> 
> Problem:
> ip_append_data() could wrongly generate a chained skb for devices which support UFO.
> When sk_write_queue is not empty (e.g. MSG_MORE), __instead__ of appending data 
> into the next nr_frag of the queued skb, a new chained skb is created.
> 
> I would normally assume UFO device should get data in nr_frags and not in frag_list.
> Later the udp4_hwcsum_outgoing() resets csum to NONE and skb_gso_segment() has oops.
> 
> Proposal:
> 1. Even length is less than mtu, employ ip_ufo_append_data() and append data to the  __existed__ skb in the sk_write_queue.
> 
> 2. ip_ufo_append_data() is fixed due to a wrong manipulation of peek-ing and later enqueue-ing of the same skb.
> Now, enqueuing is always performed, because on error the further ip_flush_pending_frames() would release the queued skb.
> 
> 
> Signed-off-by: Kostya B 

Mostly this looks fine to me.

Herbert, can you take a quick look at this?

Thanks.

> 
> ---
> 
> net/ipv4/ip_output.c |   25 +++++++++----------------
> 1 file changed, 9 insertions(+), 16 deletions(-)
> 
> diff -uprN -X linux-2.6.25-git11/Documentation/dontdiff linux-2.6.25-git11/net/ipv4/ip_output.c linux-2.6.25-git11-fix/net/ipv4/ip_output.c
> --- linux-2.6.25-git11/net/ipv4/ip_output.c     2008-04-28 12:22:00.000000000 +0300
> +++ linux-2.6.25-git11-fix/net/ipv4/ip_output.c 2008-04-28 14:02:41.000000000 +0300
> @@ -753,23 +753,15 @@ static inline int ip_ufo_append_data(str
>                 skb->ip_summed = CHECKSUM_PARTIAL;
>                 skb->csum = 0;
>                 sk->sk_sndmsg_off = 0;
> +
> +                /* specify the length of each IP datagram fragment*/
> +                skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
> +                skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> +                __skb_queue_tail(&sk->sk_write_queue, skb);
>         }
> 
> -       err = skb_append_datato_frags(sk,skb, getfrag, from,
> +       return skb_append_datato_frags(sk,skb, getfrag, from,
>                                (length - transhdrlen));
> -       if (!err) {
> -               /* specify the length of each IP datagram fragment*/
> -               skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
> -               skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> -               __skb_queue_tail(&sk->sk_write_queue, skb);
> -
> -               return 0;
> -       }
> -       /* There is not enough support do UFO ,
> -        * so follow normal path
> -        */
> -       kfree_skb(skb);
> -       return err;
>  }
> 
>  /*
> @@ -863,8 +855,9 @@ int ip_append_data(struct sock *sk,
>                 csummode = CHECKSUM_PARTIAL;
> 
>         inet->cork.length += length;
> -       if (((length> mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
> -                       (rt->u.dst.dev->features & NETIF_F_UFO)) {
> +       if (((length> mtu) || !skb_queue_empty(&sk->sk_write_queue)) &&
> +           (sk->sk_protocol == IPPROTO_UDP) &&
> +           (rt->u.dst.dev->features & NETIF_F_UFO)) {
> 
>                 err = ip_ufo_append_data(sk, getfrag, from, length, hh_len,
>                                          fragheaderlen, transhdrlen, mtu,
> ---
> _________________________________________________________________
> Explore the seven wonders of the world
> http://search.msn.com/results.aspx?q=7+wonders+world&mkt=en-US&form=QBRE
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
