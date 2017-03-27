From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: Fix array-bounds warning in fragment copy
Date: Mon, 27 Mar 2017 12:47:59 +0200
Message-ID: <1490611679.3393.0.camel@sipsolutions.net>
References: <20170325010644.190368-1-mka@chromium.org>
         (sfid-20170325_020717_155658_DF54EC50)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>
To: Matthias Kaehlcke <mka@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46160 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751559AbdC0KsM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 06:48:12 -0400
In-Reply-To: <20170325010644.190368-1-mka@chromium.org> (sfid-20170325_020717_155658_DF54EC50)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-24 at 18:06 -0700, Matthias Kaehlcke wrote:
> __ieee80211_amsdu_copy_frag intentionally initializes a pointer to
> array[-1] to increment it later to valid values. clang rightfully
> generates an array-bounds warning on the initialization statement.
> Work around this by initializing the pointer to array[0] and
> decrementing it later, which allows to leave the rest of the
> algorithm untouched.
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> ---
>  net/wireless/util.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/wireless/util.c b/net/wireless/util.c
> index 68e5f2ecee1a..d3d459e4a070 100644
> --- a/net/wireless/util.c
> +++ b/net/wireless/util.c
> @@ -659,7 +659,7 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb,
> struct sk_buff *frame,
>  			    int offset, int len)
>  {
>  	struct skb_shared_info *sh = skb_shinfo(skb);
> -	const skb_frag_t *frag = &sh->frags[-1];
> +	const skb_frag_t *frag = &sh->frags[0];
>  	struct page *frag_page;
>  	void *frag_ptr;
>  	int frag_len, frag_size;
> @@ -669,6 +669,7 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb,
> struct sk_buff *frame,
>  	frag_page = virt_to_head_page(skb->head);
>  	frag_ptr = skb->data;
>  	frag_size = head_size;
> +	frag--;

Isn't it just a question of time until the compiler will see through
this trick and warn about it?

johannes
