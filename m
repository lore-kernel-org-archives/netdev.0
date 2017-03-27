From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] cfg80211: Fix array-bounds warning in fragment copy
Date: Mon, 27 Mar 2017 12:32:42 -0700
Message-ID: <20170327193242.GD84219@google.com>
References: <20170325010644.190368-1-mka@chromium.org>
 <1490611679.3393.0.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33148 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbdC0TkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 15:40:19 -0400
Received: by mail-pg0-f45.google.com with SMTP id n5so41991239pgh.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 12:40:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1490611679.3393.0.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Mon, Mar 27, 2017 at 12:47:59PM +0200 Johannes Berg ha dit:

> On Fri, 2017-03-24 at 18:06 -0700, Matthias Kaehlcke wrote:
> > __ieee80211_amsdu_copy_frag intentionally initializes a pointer to
> > array[-1] to increment it later to valid values. clang rightfully
> > generates an array-bounds warning on the initialization statement.
> > Work around this by initializing the pointer to array[0] and
> > decrementing it later, which allows to leave the rest of the
> > algorithm untouched.
> > 
> > Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> > ---
> >  net/wireless/util.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/wireless/util.c b/net/wireless/util.c
> > index 68e5f2ecee1a..d3d459e4a070 100644
> > --- a/net/wireless/util.c
> > +++ b/net/wireless/util.c
> > @@ -659,7 +659,7 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb,
> > struct sk_buff *frame,
> >  			    int offset, int len)
> >  {
> >  	struct skb_shared_info *sh = skb_shinfo(skb);
> > -	const skb_frag_t *frag = &sh->frags[-1];
> > +	const skb_frag_t *frag = &sh->frags[0];
> >  	struct page *frag_page;
> >  	void *frag_ptr;
> >  	int frag_len, frag_size;
> > @@ -669,6 +669,7 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb,
> > struct sk_buff *frame,
> >  	frag_page = virt_to_head_page(skb->head);
> >  	frag_ptr = skb->data;
> >  	frag_size = head_size;
> > +	frag--;
> 
> Isn't it just a question of time until the compiler will see through
> this trick and warn about it?

Maybe.

Actually it seems the algorithm can be easily adapted to increment the
pointer after consumption, which is clearer anyway. I will give this a
shot. I'm not sure how to exercise the code path for testing and would
appreciate help on this end.

Matthias
