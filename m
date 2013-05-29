From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 7/7] net,ipv4,ipv6: Correct assignment of
 skb->network_header to skb->tail
Date: Tue, 28 May 2013 22:35:51 -0700
Message-ID: <1369805751.5109.1.camel@edumazet-glaptop>
References: <1369805268-6291-1-git-send-email-horms@verge.net.au>
	 <1369805268-6291-8-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:64049 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883Ab3E2Ffx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:35:53 -0400
Received: by mail-pd0-f180.google.com with SMTP id 14so6068073pdc.39
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 22:35:53 -0700 (PDT)
In-Reply-To: <1369805268-6291-8-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-29 at 14:27 +0900, Simon Horman wrote:
> This corrects an regression introduced by "net: Use 16bits for *_headers
> fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
> that case skb->tail will be a pointer however skb->network_header is now
> an offset.
> 
> This patch corrects the problem by adding a wrapper to return skb tail as
> an offset regardless of the value of NET_SKBUFF_DATA_USES_OFFSET. It seems
> that skb->tail that this offset may be more than 64k and some care has been
> taken to treat such cases as an error.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  include/linux/skbuff.h |    9 +++++++++
>  net/core/netpoll.c     |    9 ++++++++-
>  net/core/pktgen.c      |   16 ++++++++++++++--
>  net/ipv4/ipmr.c        |    8 +++++++-
>  4 files changed, 38 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 8f2b830..26ed287 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1391,6 +1391,11 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
>  	skb_reset_tail_pointer(skb);
>  	skb->tail += offset;
>  }
> +
> +static inline __u64 skb_tail_offset(const struct sk_buff *skb)
> +{
> +	return skb->tail;
> +}
>  #else /* NET_SKBUFF_DATA_USES_OFFSET */
>  static inline unsigned char *skb_tail_pointer(const struct sk_buff *skb)
>  {
> @@ -1407,6 +1412,10 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
>  	skb->tail = skb->data + offset;
>  }
>  
> +static inline __u64 skb_tail_offset(const struct sk_buff *skb)
> +{
> +	return skb->tail - skb->head;
> +}
>  #endif /* NET_SKBUFF_DATA_USES_OFFSET */
>  

Are you sure __u64 is needed on 32bit arches ?
