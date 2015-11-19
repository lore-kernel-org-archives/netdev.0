From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Thu, 19 Nov 2015 12:15:39 -0800
Message-ID: <1447964139.22599.246.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151119195419.GA6728@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33275 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161363AbbKSUPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:15:41 -0500
Received: by pabfh17 with SMTP id fh17so94163173pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 12:15:40 -0800 (PST)
In-Reply-To: <20151119195419.GA6728@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 11:54 -0800, Alexei Starovoitov wrote:
> On Thu, Nov 19, 2015 at 11:42:50AM -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Checking if skb is NULL in napi_gro_frags() is too late.
> > 
> > If skb was NULL, we would crash earlier in napi_frags_skb()
> > 
> > Drivers normally catch napi_get_frags() NULL return value
> > before calling napi_gro_frags()
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/core/dev.c |    3 ---
> >  1 file changed, 3 deletions(-)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 41cef3e3f558b857a9093a83f6b0c73f32b8b45f..8d8d34ff68f5800dbcb2958b6a937b9db478e359 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4465,9 +4465,6 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
> >  {
> >  	struct sk_buff *skb = napi_frags_skb(napi);
> >  
> > -	if (!skb)
> > -		return GRO_DROP;
> > -
> 
> I don't get it. napi_frags_skb() can return valid NULL.
> Should it be fixed there as well?
> Must be missing something...


How many times should we crash before napi_frags_skb() returns NULL ?

At least one time, and this is enough really ...


static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
{
        struct sk_buff *skb = napi->skb;
        const struct ethhdr *eth;
        unsigned int hlen = sizeof(*eth);

        napi->skb = NULL;

        skb_reset_mac_header(skb);
        skb_gro_reset_offset(skb);

        eth = skb_gro_header_fast(skb, 0);
        if (unlikely(skb_gro_header_hard(skb, hlen))) {
                eth = skb_gro_header_slow(skb, hlen, 0);
                if (unlikely(!eth)) {
                        napi_reuse_skb(napi, skb);
                        return NULL;
                }
        } else {
                gro_pull_from_frag0(skb, hlen);
                NAPI_GRO_CB(skb)->frag0 += hlen;
                NAPI_GRO_CB(skb)->frag0_len -= hlen;
        }
        __skb_pull(skb, hlen);
        /*
         * This works because the only protocols we care about don't require
         * special handling.
         * We'll fix it up properly in napi_frags_finish()
         */
        skb->protocol = eth->h_proto;

        return skb;
}
