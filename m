From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Sat, 28 Apr 2012 09:16:43 +0200
Message-ID: <1335597403.2900.29.camel@edumazet-glaptop>
References: <1335522818.2775.227.camel@edumazet-glaptop>
	 <4F9B3980.1080605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52118 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106Ab2D1HQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 03:16:47 -0400
Received: by wgbdr13 with SMTP id dr13so1407762wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 00:16:46 -0700 (PDT)
In-Reply-To: <4F9B3980.1080605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 17:27 -0700, Alexander Duyck wrote:
> On 04/27/2012 03:33 AM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >

> > +struct sk_buff *build_skb(void *data, unsigned int frag_size)
> >  {
> >  	struct skb_shared_info *shinfo;
> >  	struct sk_buff *skb;
> > -	unsigned int size;
> > +	unsigned int size = frag_size ? : ksize(data);
> >  
> >  	skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
> >  	if (!skb)
> >  		return NULL;
> >  
> > -	size = ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> > +	size -= SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> >  
> >  	memset(skb, 0, offsetof(struct sk_buff, tail));
> >  	skb->truesize = SKB_TRUESIZE(size);
> > +	skb->head_frag = frag_size != 0;
> >  	atomic_set(&skb->users, 1);
> >  	skb->head = data;
> >  	skb->data = data;
> 
> This doesn't seem right to me.  You are only counting the piece of the
> page that got filled with data and the piece that will get overwritten
> with the shared info.  What about the rest of the page?  It looks like
> in the tg3 patch you have the driver using a half page.  Based on this
> function I suspect the resultant truesize would be something like 64 +
> 256 + 320 for an ack.  Shouldn't your truesize in that case be 2048 + 256?

Re-reading your mail, I think you missed fact that tg3 driver currently
uses a kmalloc(64+1500+14+SKB_DATA_ALIGN(sizeof(struct
skb_shared_info)) , so basically does a kmalloc(2048). But this is done
before NIC fills the frame in it, so we cant know what will be the frame
length...

So build_skb() does later a ksize(data) and this gives 2048, even for a
small ACK packet ...

So the spirit of this patch is not to change any truesize.

tg3 for example splits a PAGE_SIZE into 2048 bytes frags (2 frags on x86
for example). Its done about the same in Intel IGB driver (IGB assumes
PAGE_SIZE is 4096 since it uses PAGE_SIZE/2)

The only thing that is changed here is where skb->head is allocated
from : kmalloc() caches or a frag from a page (and one reference to
page->_count)

Hope this clears your concern ?
