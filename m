From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 1/4] net: skbuff: add skb_append_pagefrags and
 use it
Date: Wed, 20 May 2015 10:51:22 -0700
Message-ID: <CAHA+R7OufGJEAZ6d7DB6YaCkqXdjDU9bgwjramRtZT=9z_Hk4w@mail.gmail.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
	<9b4f1db599452ad72b0f5dcd95d66311af6eaa58.1432135413.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:34942 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbbETRvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 13:51:23 -0400
Received: by wicmx19 with SMTP id mx19so163586428wic.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 10:51:22 -0700 (PDT)
In-Reply-To: <9b4f1db599452ad72b0f5dcd95d66311af6eaa58.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 8:35 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> +int skb_append_pagefrags(struct sk_buff *skb, struct page *page,
> +                        int offset, size_t size)
> +{
> +       int i = skb_shinfo(skb)->nr_frags;
> +
> +       if (skb_can_coalesce(skb, i, page, offset)) {
> +               skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], size);
> +       } else if (i < MAX_SKB_FRAGS) {
> +               get_page(page);
> +               skb_fill_page_desc(skb, i, page, offset, size);
> +       } else {
> +               return -EMSGSIZE;
> +       }
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL(skb_append_pagefrags);
> +
>  /**
>   *     skb_pull_rcsum - pull skb and update receive checksum
>   *     @skb: buffer to update
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 8d91b92..35ff40f 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1292,12 +1292,8 @@ ssize_t  ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
>                 i = skb_shinfo(skb)->nr_frags;
>                 if (len > size)
>                         len = size;
> -               if (skb_can_coalesce(skb, i, page, offset)) {
> -                       skb_frag_size_add(&skb_shinfo(skb)->frags[i-1], len);
> -               } else if (i < MAX_SKB_FRAGS) {
> -                       get_page(page);
> -                       skb_fill_page_desc(skb, i, page, offset, len);
> -               } else {
> +
> +               if (skb_append_pagefrags(skb, page, offset, len)) {
>                         err = -EMSGSIZE;
>                         goto error;
>                 }

The 'i' can be removed now.
