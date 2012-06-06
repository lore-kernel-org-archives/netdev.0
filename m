From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v9] tilegx network driver: initial support
Date: Wed, 06 Jun 2012 19:40:59 +0200
Message-ID: <1339004459.26966.31.camel@edumazet-glaptop>
References: <201205201636.q4KGaoA3003845@farm-0027.internal.tilera.com>
	 <20120520.165546.1211013675964130504.davem@davemloft.net>
	 <201205240115.q4O1FwqG006336@lab-41.internal.tilera.com>
	 <20120524.003148.700603156196416506.davem@davemloft.net>
	 <201205251853.q4PIrE7T000723@lab-41.internal.tilera.com>
	 <201206042023.q54KNEZp003834@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, arnd@arndb.de,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206042023.q54KNEZp003834@farm-0002.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-04 at 16:12 -0400, Chris Metcalf wrote:

> +/* Allocate and push a buffer. */
> +static bool tile_net_provide_buffer(bool small)
> +{
> +	int stack = small ? small_buffer_stack : large_buffer_stack;
> +	const unsigned long buffer_alignment = 128;
> +	struct sk_buff *skb;
> +	int len;
> +
> +	len = sizeof(struct sk_buff **) + buffer_alignment;
> +	len += (small ? 128 : 1664);

1664 is a magic number, it should be a nice define

#define ..... ( ETH_DATA_LEN + .... )

> +	skb = dev_alloc_skb(len);
> +	if (skb == NULL)
> +		return false;
> +
> +	/* Make room for a back-pointer to 'skb' and guarantee alignment. */
> +	skb_reserve(skb, sizeof(struct sk_buff **));
> +	skb_reserve(skb, -(long)skb->data & (buffer_alignment - 1));
> +
> +	/* Save a back-pointer to 'skb'. */
> +	*(struct sk_buff **)(skb->data - sizeof(struct sk_buff **)) = skb;
> +
> +	/* Make sure "skb" and the back-pointer have been flushed. */
> +	wmb();

Interesting, have you considered using build_skb() instead of this
convoluted thing ?

This could save some cache misses...
