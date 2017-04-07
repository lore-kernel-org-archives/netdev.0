From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/1] skbuff: Extend gso_type to unsigned int.
Date: Fri, 7 Apr 2017 13:36:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFC87C0@AcuExch.aculab.com>
References: <1491207352-27585-1-git-send-email-steffen.klassert@secunet.com>
 <1491207352-27585-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Steffen Klassert' <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:52433 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756430AbdDGNgM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 09:36:12 -0400
In-Reply-To: <1491207352-27585-2-git-send-email-steffen.klassert@secunet.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert
> Sent: 03 April 2017 09:16
> All available gso_type flags are currently in use, so
> extend gso_type from 'unsigned short' to 'unsigned int'
> to be able to add further flags.
> 
> We also reorder the struct skb_shared_info to use
> two bytes of the four byte hole before dataref.
> All fields before _unused are cleared now, i.e.
> two bytes more than before the change.
...
> -	 * Warning : all fields before dataref are cleared in __alloc_skb()
> +	 * Warning : all fields before _unused are cleared in __alloc_skb()
>  	 */
> +	unsigned short	_unused;
>  	atomic_t	dataref;
> 
>  	/* Intermediate layers must ensure that destructor_arg
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9f78109..8796b93 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -257,7 +257,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
> 
>  	/* make sure we initialize shinfo sequentially */
>  	shinfo = skb_shinfo(skb);
> -	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> +	memset(shinfo, 0, offsetof(struct skb_shared_info, _unused));
>  	atomic_set(&shinfo->dataref, 1);
>  	kmemcheck_annotate_variable(shinfo->destructor_arg);

Is it worth adding a specific field name for the end of the 'zero' area?
Either as a #define or anonymous union.

I think that changing the definition to:
	union {
		unsigned short	_unused;
		atomic_t	dataref;
	};
would require no other changes.

	David
