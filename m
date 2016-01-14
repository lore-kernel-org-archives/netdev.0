From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 1/4] net: Move GSO csum into SKB_GSO_CB
Date: Thu, 14 Jan 2016 11:10:41 +0000
Message-ID: <56978231.30002@solarflare.com>
References: <20160114045532.5119.56124.stgit@localhost.localdomain>
 <20160114051202.5119.50169.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <aduyck@mirantis.com>, <netdev@vger.kernel.org>,
	<tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:13137 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753043AbcANLKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 06:10:48 -0500
In-Reply-To: <20160114051202.5119.50169.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/01/16 05:12, Alexander Duyck wrote:
> This patch moves the checksum maintained by GSO out of skb->csum and into
> the GSO context block in order to allow for us to work on outer checksums
> while maintaining the inner checksum offsets in the case of the inner
> checksum being offloaded, while the outer checksums will be computed.
>
> While updating the code I also did a minor cleanu-up on gso_make_checksum.
> The change is mostly to make it so that we store the values and compute the
> checksum instead of computing the checksum and then storing the values we
> needed to update.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  include/linux/skbuff.h |   14 +++++++-------
>  net/core/skbuff.c      |   16 +++++++++-------
>  2 files changed, 16 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 6b6bd42d6134..0150abb81929 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3532,6 +3532,7 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
>  struct skb_gso_cb {
>  	int	mac_offset;
>  	int	encap_level;
> +	__wsum	csum;
>  	__u16	csum_start;
>  };
>  #define SKB_GSO_CB(skb) ((struct skb_gso_cb *)(skb)->cb)
> @@ -3567,15 +3568,14 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
>   */
>  static inline __sum16 gso_make_checksum(struct sk_buff *skb, __wsum res)
>  {
> -	int plen = SKB_GSO_CB(skb)->csum_start - skb_headroom(skb) -
> -		   skb_transport_offset(skb);
> -	__wsum partial;
> +	unsigned char *csum_start = skb_transport_header(skb);
> +	int plen = (skb->head + SKB_GSO_CB(skb)->csum_start) - csum_start;
> +	__wsum partial = SKB_GSO_CB(skb)->csum;
>  
> -	partial = csum_partial(skb_transport_header(skb), plen, skb->csum);
> -	skb->csum = res;
> -	SKB_GSO_CB(skb)->csum_start -= plen;
> +	SKB_GSO_CB(skb)->csum = res;
> +	SKB_GSO_CB(skb)->csum_start = csum_start - skb->head;
>  
> -	return csum_fold(partial);
> +	return csum_fold(csum_partial(csum_start, plen, partial));
>  }
Update the comment above this function?

Apart from that this looks good.
