From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_try_coalesce and fraglists (bug?)
Date: Wed, 04 Feb 2015 09:28:01 -0800
Message-ID: <1423070881.907.139.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150204163343.GA857@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkubecek@suse.cz, ying.xue@windriver.com
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:51654 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966519AbbBDR2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 12:28:05 -0500
Received: by mail-ie0-f171.google.com with SMTP id tr6so3749665ieb.2
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 09:28:03 -0800 (PST)
In-Reply-To: <20150204163343.GA857@haze>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 17:33 +0100, Erik Hugne wrote:
> skb_try_coalesce should bail out for a number of reasons, if the target skb is
> cloned, doesn't have enough room, or if either source or target skb have
> fraglists.
> 
> However, it seems that the skb_has_frag_list check is done too late, and a small
> skb may be copied into the tailroom of the head, even if it has a fraglist.
> 
> Wouldn't this be more correct?
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 56db472..8d02140 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4056,6 +4056,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>         if (skb_cloned(to))
>                 return false;
>  
> +       if (skb_has_frag_list(to) || skb_has_frag_list(from))
> +               return false;
> +
>         if (len <= skb_tailroom(to)) {
>                 if (len)
>                         BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
> @@ -4063,9 +4066,6 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>                 return true;
>         }
>  
> -       if (skb_has_frag_list(to) || skb_has_frag_list(from))
> -               return false;
> -
>         if (skb_headlen(from) != 0) {
>                 struct page *page;
>                 unsigned int offset;
> 

Patch is not needed.

If to had a fraglist, skb_tailroom(to) would be 0
