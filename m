From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net] net_sched: fix mirrored packets checksum
Date: Thu, 30 Jun 2016 21:50:59 +0200
Message-ID: <57757823.4090000@iogearbox.net>
References: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <tom@herbertland.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41256 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbcF3TvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 15:51:08 -0400
In-Reply-To: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On 06/30/2016 07:15 PM, Cong Wang wrote:
> Similar to commit 9b368814b336 ("net: fix bridge multicast packet checksum validation")
> we need to fixup the checksum for CHECKSUM_COMPLETE when
> pushing skb on RX path. Otherwise we get similar splats.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   include/linux/skbuff.h | 19 +++++++++++++++++++
>   net/core/skbuff.c      | 18 ------------------
>   net/sched/act_mirred.c |  2 +-
>   3 files changed, 20 insertions(+), 19 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index ee38a41..61ab566 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2870,6 +2870,25 @@ static inline void skb_postpush_rcsum(struct sk_buff *skb,
>   }
>
>   /**
> + *	skb_push_rcsum - push skb and update receive checksum
> + *	@skb: buffer to update
> + *	@len: length of data pulled
> + *
> + *	This function performs an skb_push on the packet and updates
> + *	the CHECKSUM_COMPLETE checksum.  It should be used on
> + *	receive path processing instead of skb_push unless you know
> + *	that the checksum difference is zero (e.g., a valid IP header)
> + *	or you are setting ip_summed to CHECKSUM_NONE.
> + */
> +static inline unsigned char *skb_push_rcsum(struct sk_buff *skb,
> +					    unsigned int len)
> +{
> +	skb_push(skb, len);
> +	skb_postpush_rcsum(skb, skb->data, len);
> +	return skb->data;
> +}
> +
> +/**
>    *	pskb_trim_rcsum - trim received skb and update checksum
>    *	@skb: buffer to trim
>    *	@len: new length
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f2b77e5..eb12d21 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3016,24 +3016,6 @@ int skb_append_pagefrags(struct sk_buff *skb, struct page *page,
>   EXPORT_SYMBOL_GPL(skb_append_pagefrags);
>
>   /**
> - *	skb_push_rcsum - push skb and update receive checksum
> - *	@skb: buffer to update
> - *	@len: length of data pulled
> - *
> - *	This function performs an skb_push on the packet and updates
> - *	the CHECKSUM_COMPLETE checksum.  It should be used on
> - *	receive path processing instead of skb_push unless you know
> - *	that the checksum difference is zero (e.g., a valid IP header)
> - *	or you are setting ip_summed to CHECKSUM_NONE.
> - */
> -static unsigned char *skb_push_rcsum(struct sk_buff *skb, unsigned len)
> -{
> -	skb_push(skb, len);
> -	skb_postpush_rcsum(skb, skb->data, len);
> -	return skb->data;
> -}
> -
> -/**
>    *	skb_pull_rcsum - pull skb and update receive checksum
>    *	@skb: buffer to update
>    *	@len: length of data pulled

Fix looks good to me, just a minor comment.

Maybe makes sense to move skb_push_rcsum() but /also/ skb_pull_rcsum()
to the header then? Both seem similarly small at least (could be split
f.e into two patches then, first for the move, second for the actual fix).

Thanks,
Daniel
