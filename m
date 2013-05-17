From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] MPLS: Add limited GSO support
Date: Fri, 17 May 2013 10:26:14 -0700
Message-ID: <1368811574.3301.109.camel@edumazet-glaptop>
References: <1368773452-32310-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:36253 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245Ab3EQR0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 13:26:15 -0400
Received: by mail-pb0-f43.google.com with SMTP id ma3so1803294pbc.30
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 10:26:15 -0700 (PDT)
In-Reply-To: <1368773452-32310-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 15:50 +0900, Simon Horman wrote:

> @@ -509,6 +511,8 @@ struct sk_buff {
>  		__u32		reserved_tailroom;
>  	};
>  
> +	__be16			inner_protocol;
> +	/* 16/48 bit hole */
>  	sk_buff_data_t		inner_transport_header;
>  	sk_buff_data_t		inner_network_header;
>  	sk_buff_data_t		inner_mac_header;

We are reaching the point where sk_buff is so big that per packet cost
is killing us, and guys want linux kernel bypass.

sizeof(sk_buff) = 0xf8 -> 0x100

sizeof(skbuff_fclone_cache) = 0x200 -> 0x240 

So TCP stack performance is going to be hurt by this change, as the
atomic_t containing fclone_ref will be in a separate cache line.

__copy_skb_header() needs to be smarter and perform a bulk copy using
long words

Maybe we could use 16 bits instead of 32 for the inner_*_headers ?
