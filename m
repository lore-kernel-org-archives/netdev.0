From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data
 allocation.
Date: Sun, 06 Aug 2006 23:23:39 -0700 (PDT)
Message-ID: <20060806.232339.30184217.davem@davemloft.net>
References: <20060807060155.GA6487@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54966
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751107AbWHGGXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 02:23:40 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060807060155.GA6487@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 7 Aug 2006 10:01:56 +0400

> +	int order = get_order(size + sizeof(void *));
> +	struct skb_shared_info *sh;
>  
>  	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
>  
> @@ -156,11 +159,28 @@ struct sk_buff *__alloc_skb(unsigned int
>  
>  	/* Get the DATA. Size must match skb_add_mtu(). */
>  	size = SKB_DATA_ALIGN(size);
> -	data = ____kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
> -	if (!data)
> -		goto nodata;
> +	if ((1UL << order) > size + sizeof(void *) + sizeof(struct skb_shared_info)) {

get_order() returns a PAGE_SIZE order not a byte one.  So this test
here at the end is incorrect.  It should probably be something
like "if ((PAGE_SIZE << order) > ..."

I don't know if I want to eat an entire extra allocation for every SKB
just to handle broken e1000 cards that can't be bothered to support
non-power-of-2 receive buffer sizes and a proper MTU setting.

I guess we might have to, but this is extremely unfortunate. :-/

