From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 03:52:56 +0100
Message-ID: <20130106025256.GY16031@1wt.eu>
References: <20130105214958.GA19814@1wt.eu> <1357427926.1678.4771.camel@edumazet-glaptop> <20130105232913.GQ16031@1wt.eu> <1357430523.1678.4901.camel@edumazet-glaptop> <20130106005053.GS16031@1wt.eu> <1357435276.1678.5067.camel@edumazet-glaptop> <20130106013027.GV16031@1wt.eu> <1357436430.1678.5111.camel@edumazet-glaptop> <1357437086.1678.5135.camel@edumazet-glaptop> <1357438591.1678.5205.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357438591.1678.5205.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 05, 2013 at 06:16:31PM -0800, Eric Dumazet wrote:
> On Sat, 2013-01-05 at 17:51 -0800, Eric Dumazet wrote:
> > On Sat, 2013-01-05 at 17:40 -0800, Eric Dumazet wrote:
> > > On Sun, 2013-01-06 at 02:30 +0100, Willy Tarreau wrote:
> > > 
> > > > Ah interesting because these were some of the mm patches that I had
> > > > tried to revert.
> > > 
> > > Hmm, or we should fix __skb_splice_bits()
> > > 
> > > I'll send a patch.
> > > 
> > 
> > Could you try the following ?
> 
> Or more exactly...
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3ab989b..01f222c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1736,11 +1736,8 @@ static bool __splice_segment(struct page *page, unsigned int poff,
>  		return false;
>  	}
>  
> -	/* ignore any bits we already processed */
> -	if (*off) {
> -		__segment_seek(&page, &poff, &plen, *off);
> -		*off = 0;
> -	}
> +	__segment_seek(&page, &poff, &plen, *off);
> +	*off = 0;
>  
>  	do {
>  		unsigned int flen = min(*len, plen);
> @@ -1768,14 +1765,15 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
>  			      struct splice_pipe_desc *spd, struct sock *sk)
>  {
>  	int seg;
> +	struct page *page = virt_to_page(skb->data);
> +	unsigned int poff = skb->data - (unsigned char *)page_address(page);
>  
>  	/* map the linear part :
>  	 * If skb->head_frag is set, this 'linear' part is backed by a
>  	 * fragment, and if the head is not shared with any clones then
>  	 * we can avoid a copy since we own the head portion of this page.
>  	 */
> -	if (__splice_segment(virt_to_page(skb->data),
> -			     (unsigned long) skb->data & (PAGE_SIZE - 1),
> +	if (__splice_segment(page, poff,
>  			     skb_headlen(skb),
>  			     offset, len, skb, spd,
>  			     skb_head_is_locked(skb),
> 

OK so I observed no change with this patch, either on the loopback
data rate at >16kB MTU, or on the myri. I'm keeping it at hand for
experimentation anyway.

Concerning the loopback MTU, I find it strange that the MTU changes
the splice() behaviour and not send/recv. I thought that there could
be a relation between the MTU and the pipe size, but it does not
appear to be the case either, as I tried various sizes between 16kB
and 256kB without achieving original performance.

I've started to bisect the 10GE issue again (since both issues are
unrelated), but I'll finish tomorrow, it's time to get some sleep
now.

Best regards,
Willy
