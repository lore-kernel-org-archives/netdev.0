From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 05 Oct 2012 14:39:50 +0200
Message-ID: <1349440790.21172.56.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
	 <1349422868.21172.38.camel@edumazet-glaptop>
	 <1349434194.16710.44.camel@sakura.staff.proxad.net>
	 <1349439732.21172.52.camel@edumazet-glaptop>
	 <1349440667.21172.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349440667.21172.54.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-05 at 14:37 +0200, Eric Dumazet wrote:

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index cdc2859..f6c1f52 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1053,11 +1053,22 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  {
>  	int i;
>  	u8 *data;
> -	int size = nhead + skb_end_offset(skb) + ntail;
> +	unsigned int tail_offset = skb_tail_pointer(skb) - skb->head;
> +	int size = nhead + ntail;
>  	long off;
>  
>  	BUG_ON(nhead < 0);
>  
> +	/* callers using nhead == 0 and ntail == 0 wants to get a fresh copy,
> +	 * so allocate same amount of memory (skb_end_offset)
> +	 * For others, they want extra head or tail against the currently
> +	 * used portion of header (skb->head -> skb_tail_pointer).
> +	 * But we dont shrink the head.
> +	 */
> +	if (size)
> +		size += tail_offset;
> +	size = max_t(int, size, skb_end_offset(skb));
> +
>  

This can be factorized to :

	size = tail_offset + nhead + ntail;
	size = max_t(int, size, skb_end_offset(skb));
