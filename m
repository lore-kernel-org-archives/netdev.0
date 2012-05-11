From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH RFC 1/6] skbuff: support per-page destructors in
 copy_ubufs
Date: Fri, 11 May 2012 10:00:00 +0100
Message-ID: <1336726800.23818.33.camel@zakaz.uk.xensource.com>
References: <cover.1336397823.git.mst@redhat.com>
	 <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
	 <1336671977.14220.26.camel@zakaz.uk.xensource.com>
	 <20120510184246.GE14647@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:17968 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757872Ab2EKJAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 05:00:04 -0400
In-Reply-To: <20120510184246.GE14647@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 19:42 +0100, Michael S. Tsirkin wrote:
> On Thu, May 10, 2012 at 06:46:17PM +0100, Ian Campbell wrote:
> > On Mon, 2012-05-07 at 14:54 +0100, Michael S. Tsirkin wrote:
> So the below on top then. I pushed these on
> top of my zerocopy branch - can you confirm pls?

I added these to my test branch:
93772fea6cd66616912101b9e0144dfed645d8fe fix per page destructors in copy ubufs
d72b7ab15f944c5df5f28cce7b5c9a0bca61ff6d clear destructor arg when set zerocopy 

I think you also need, as part of the second one:

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index af2d10e..40ca43e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1744,6 +1744,7 @@ static inline void skb_copy_frag_destructor(struct sk_buff *to,
 {
 	skb_shinfo(to)->tx_flags |= skb_shinfo(from)->tx_flags &
 		SKBTX_DEV_ZEROCOPY;
+	skb_shinfo(to)->destructor_arg = NULL;
 }
 
 /**

I'm seeing copy_ubufs called in my remote NFS test, which I don't think
I expected -- I'll investigate why this is happening today.

Ian.

> 
> ---
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 930a50e..e52bc8d 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1270,8 +1270,10 @@ static inline void skb_frag_set_destructor(struct sk_buff *skb, int i,
>  {
>  	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>  	frag->page.destructor = destroy;
> -	if (destroy)
> +	if (destroy) {
>  		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +		skb_shinfo(skb)->destructor_arg = NULL;
> +	}
>  }
>  
>  /**
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index b7fc47e..453f621 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -753,12 +753,11 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
>  		uarg->callback(uarg);
>  
>  	/* skb frags point to kernel buffers */
> -	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
> +	for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
>  		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
>  		if (unlikely((!uarg && !f->page.destructor)))
>  			continue;
> -		__skb_fill_page_desc(skb, i-1, head, 0,
> -				     skb_shinfo(skb)->frags[i - 1].size);
> +		__skb_fill_page_desc(skb, i, head, 0, f->size);
>  		head = (struct page *)head->private;
>  	}
>  
