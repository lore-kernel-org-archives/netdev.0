From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 7/7] net: move skb->dropcount to skb->cb[]
Date: Thu, 26 Feb 2015 10:49:09 +0200
Message-ID: <20150226104909.1f2c882d@halley>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-8-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	marcel@holtmann.org, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:38661 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbBZItT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 03:49:19 -0500
Received: by wgha1 with SMTP id a1so8626166wgh.5
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 00:49:18 -0800 (PST)
In-Reply-To: <1424916612-744-8-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2015 04:10:12 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
> diff --git a/include/net/sock.h b/include/net/sock.h
> index d462f5e..8807586 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2078,12 +2078,26 @@ static inline int sock_intr_errno(long timeo)
>  	return timeo == MAX_SCHEDULE_TIMEOUT ? -ERESTARTSYS : -EINTR;
>  }
>  
> +struct sock_skb_cb {
> +	u32 dropcount;
> +};
> +
> +/* Store sock_skb_cb at the end of skb->cb[] so protocol families
> + * using skb->cb[] would keep using it directly and utilize its
> + * alignement guarantee.
> + */
> +#define SOCK_SKB_CB_OFFSET ((FIELD_SIZEOF(struct sk_buff, cb) - \
> +			    sizeof(struct sock_skb_cb)))
> +
> +#define SOCK_SKB_CB(__skb) ((struct sock_skb_cb *)((__skb)->cb + \
> +			    SOCK_SKB_CB_OFFSET))
> +
>  #define sock_skb_cb_check_size(size) \
> -	BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sk_buff, cb))
> +	BUILD_BUG_ON((size) > SOCK_SKB_CB_OFFSET)
>  

You didn't take care of aligning the 'sock_skb_cb'.
(Althogh in practive, dropcount is 4 and cb[] is 48 so you're golden).

How about:

struct sock_skb_cb {
	/* protocol families specifc CBs */
	u8 reserved[__SOCK_SKB_CB_OFFSET];
	struct __sock_skb_cb x;			// name me better!
};

Where '__SOCK_SKB_CB_OFFSET' and '__sock_skb_cb' are as follows:

struct __sock_skb_cb {	// name me better!
	u32 dropcount;
};

#define __SOCK_SKB_CB_OFFSET_UNALIGNED \
	(FIELD_SIZEOF(struct sk_buff, cb) - sizeof(struct __sock_skb_cb))

#define __SOCK_SKB_CB_OFFSET \
	(__SOCK_SKB_CB_OFFSET_UNALIGNED - \
	 (__SOCK_SKB_CB_OFFSET_UNALIGNED % __alignof__(struct __sock_skb_cb)))

This also takes care for alignement of '__sock_skb_cb x' within the CB.

Then,

#define sock_skb_cb_check_size(size) \
	BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sock_skb_cb, reserved))

Regards,
Shmulik
