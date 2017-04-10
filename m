From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH v2] cfg80211: Fix array-bounds warning in fragment copy
Date: Mon, 10 Apr 2017 14:36:04 -0700
Message-ID: <20170410213604.GB28657@google.com>
References: <20170327195822.123034-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35608 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752766AbdDJVgG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 17:36:06 -0400
Received: by mail-pf0-f179.google.com with SMTP id i5so39008118pfc.2
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 14:36:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170327195822.123034-1-mka@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Mon, Mar 27, 2017 at 12:58:22PM -0700 Matthias Kaehlcke ha dit:

> __ieee80211_amsdu_copy_frag intentionally initializes a pointer to
> array[-1] to increment it later to valid values. clang rightfully
> generates an array-bounds warning on the initialization statement.
> 
> Initialize the pointer to array[0] and change the algorithm from
> increment before to increment after consume.
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> ---
>  net/wireless/util.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/wireless/util.c b/net/wireless/util.c
> index 68e5f2ecee1a..52795ae5337f 100644
> --- a/net/wireless/util.c
> +++ b/net/wireless/util.c
> @@ -659,7 +659,7 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb, struct sk_buff *frame,
>  			    int offset, int len)
>  {
>  	struct skb_shared_info *sh = skb_shinfo(skb);
> -	const skb_frag_t *frag = &sh->frags[-1];
> +	const skb_frag_t *frag = &sh->frags[0];
>  	struct page *frag_page;
>  	void *frag_ptr;
>  	int frag_len, frag_size;
> @@ -672,10 +672,10 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb, struct sk_buff *frame,
>  
>  	while (offset >= frag_size) {
>  		offset -= frag_size;
> -		frag++;
>  		frag_page = skb_frag_page(frag);
>  		frag_ptr = skb_frag_address(frag);
>  		frag_size = skb_frag_size(frag);
> +		frag++;
>  	}
>  
>  	frag_ptr += offset;
> @@ -687,12 +687,12 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb, struct sk_buff *frame,
>  	len -= cur_len;
>  
>  	while (len > 0) {
> -		frag++;
>  		frag_len = skb_frag_size(frag);
>  		cur_len = min(len, frag_len);
>  		__frame_add_frag(frame, skb_frag_page(frag),
>  				 skb_frag_address(frag), cur_len, frag_len);
>  		len -= cur_len;
> +		frag++;
>  	}
>  }
>  

Ping, any feedback on this patch?

Thanks

Matthias
