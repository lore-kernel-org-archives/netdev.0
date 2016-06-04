From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net] bridge: Fix incorrect re-injection of STP packets
Date: Sat, 4 Jun 2016 09:41:41 +0300
Message-ID: <20160604094141.7dcc5687@halley>
References: <1464946785-7651-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<eladr@mellanox.com>, <ogerlitz@mellanox.com>, <jiri@mellanox.com>,
	<yotamg@mellanox.com>, <nogahf@mellanox.com>,
	Florian Westphal <fw@strlen.de>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33987 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcFDGl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 02:41:56 -0400
Received: by mail-wm0-f67.google.com with SMTP id n184so3776496wmn.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 23:41:55 -0700 (PDT)
In-Reply-To: <1464946785-7651-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 3 Jun 2016 12:39:45 +0300 Ido Schimmel <idosch@mellanox.com> wrote:
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 1607977..c73ed44 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -223,9 +223,7 @@ static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_bu
>  	if (p->flags & BR_LEARNING && br_should_learn(p, skb, &vid))
>  		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
>  
> -	BR_INPUT_SKB_CB(skb)->brdev = p->br->dev;
> -	br_pass_frame_up(skb);
> -	return 0;
> +	return RX_HANDLER_PASS;
>  }
>  
>  /*
> @@ -238,6 +236,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>  	struct sk_buff *skb = *pskb;
>  	const unsigned char *dest = eth_hdr(skb)->h_dest;
>  	br_should_route_hook_t *rhook;
> +	int err;
>  
>  	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
>  		return RX_HANDLER_PASS;
> @@ -287,8 +286,11 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>  		}
>  
>  		/* Deliver packet to local host only */
> -		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, dev_net(skb->dev),
> -			NULL, skb, skb->dev, NULL, br_handle_local_finish);
> +		err = NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, dev_net(skb->dev),
> +			      NULL, skb, skb->dev, NULL,
> +			      br_handle_local_finish);
> +		if (err == RX_HANDLER_PASS)
> +			return RX_HANDLER_PASS;
>  		return RX_HANDLER_CONSUMED;

Seems '*pskb = skb' is needed prior returning RX_HANDLER_PASS - there's
a 'skb = skb_share_check()' at beginning of br_handle_frame.

(The *pskb = skb was present prior 8626c56c8279, but gone since there
was no longer an RX_HANDLER_PASS return).

One nit to consider:

The fix relies on the fact that RX_HANDLER_PASS != 0 (otherwise we end up
not knowing whether skb was STOLEN or br_handle_local_finish has
executed, which was the original problem 8626c56c8279 tried to address).

No reason to use the RX_HANDLER_xxx enumeration space as the ret code
of an 'okfn' (br_handle_local_finish in this case).
Some positive value locally defined in br_input.c (and documented in
br_handle_local_finish) would do.

Regards,
Shmulik
