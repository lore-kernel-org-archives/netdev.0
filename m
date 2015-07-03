From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] gro: Pull headers into skb head for 1st
 skb in gro list
Date: Fri, 03 Jul 2015 20:44:54 +0200
Message-ID: <1435949094.11970.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435871054-635096-1-git-send-email-tom@herbertland.com>
	 <1435871054-635096-2-git-send-email-tom@herbertland.com>
	 <1435899017.11970.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37dwbV=ztLpS6Z+9upXvCkm0Mk3U4HUbsgmxEWOi3dCKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35239 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332AbbGCSo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 14:44:58 -0400
Received: by wiga1 with SMTP id a1so183989158wig.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 11:44:57 -0700 (PDT)
In-Reply-To: <CALx6S37dwbV=ztLpS6Z+9upXvCkm0Mk3U4HUbsgmxEWOi3dCKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-03 at 11:36 -0700, Tom Herbert wrote:
> On Thu, Jul 2, 2015 at 9:50 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2015-07-02 at 14:04 -0700, Tom Herbert wrote:
> >> When setting up the first skb in a gro list we ensure that all the
> >> headers up to skb_gro_offset have been pulled into head. In subsequent
> >> uses of this skb (e.g. determining same_flow) it is assumed that the
> >> headers can be accessed in the skb head.
> >>
> >> Signed-off-by: Tom Herbert <tom@herbertland.com>
> >> ---
> >>  net/core/dev.c | 4 ++++
> >>  1 file changed, 4 insertions(+)
> >>
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index 6778a99..05e0e37 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -4228,6 +4228,10 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
> >>       } else {
> >>               napi->gro_count++;
> >>       }
> >> +
> >> +     /* Ensure all headers are pulled into head for 1st skb */
> >> +     skb_gro_header_slow(skb, skb_gro_offset(skb), 0);
> >> +
> >>       NAPI_GRO_CB(skb)->count = 1;
> >>       NAPI_GRO_CB(skb)->age = jiffies;
> >>       NAPI_GRO_CB(skb)->last = skb;
> >
> > I do not see how we can reach this point without having headers already
> > pulled.
> >
> > For example, tcp_gro_receive() has :
> >
> >         off = skb_gro_offset(skb);
> >         hlen = off + sizeof(*th);
> >         th = skb_gro_header_fast(skb, off);
> >         if (skb_gro_header_hard(skb, hlen)) {
> >                 th = skb_gro_header_slow(skb, hlen, off);
> >                 if (unlikely(!th))
> >                         goto out;
> >         }
> >
> > So by definition, skb is put in gro_list only if it was fully validated as a GRO
> > candidate.
> >
> That code will access the data from fragments if possible, the
> skb_gro_header_slow is what pulls the data into head. In
> tcp_gro_receive we do tcp_hdr(p) on the 1st skbuf in a gro list so it
> is assumed there that the headers have been pulled into head.

Not really, this code handles the current skb being passed to GRO
engine.

struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)

Then, we parse the gro list later :

for (; (p = *head); head = &p->next) {

And yes, all skb found in gro list already have all headers pulled.

Your patch is not needed.
