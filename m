From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC net-next] net: Assert napi_gro_cb size against skb->cb[]
Date: Fri, 31 Jul 2015 13:14:07 -0700
Message-ID: <CALx6S37j0iXVPkcRTFqFZSjWNqWC_JSOHprWGvFy6pDC9jvF2A@mail.gmail.com>
References: <1438368669-659-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, daniel@iogearbox.net,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38830 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598AbbGaUOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 16:14:08 -0400
Received: by iggf3 with SMTP id f3so24007373igg.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 13:14:07 -0700 (PDT)
In-Reply-To: <1438368669-659-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 11:51 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 64-bits hosts, napi_gro_cb is 48 bytes, which is exactly the size of
> skb->cb[], while on 32-bits hosts it is 36 bytes, but if it were to
> grow, we would not be catching a size inflation as we should.
>
> Make sure that we have enough room for a napi_gro_cb to be hosted in
> skb->cb[], and put this build-time assertion in skb_gro_reset_offset()
> since this function is invoked by the GRO layers entry points.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/core/dev.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4870c3556a5a..20bc82604b75 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4115,6 +4115,8 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
>         const struct skb_shared_info *pinfo = skb_shinfo(skb);
>         const skb_frag_t *frag0 = &pinfo->frags[0];
>
> +       BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct napi_gro_cb));
> +
Maybe sizeof(struct napi_gro_cb) > sizeof(skb->cb) since this about
napi_gro_cb being too big, not cb being too small.

>         NAPI_GRO_CB(skb)->data_offset = 0;
>         NAPI_GRO_CB(skb)->frag0 = NULL;
>         NAPI_GRO_CB(skb)->frag0_len = 0;
> --
> 2.1.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
