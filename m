From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH v3 net-next 2/3] tcp: Handle eor bit when coalescing
 skb
Date: Thu, 21 Apr 2016 09:56:33 -0700
Message-ID: <20160421165633.GA74969@kafai-mba.local>
References: <1461133497-1515104-1-git-send-email-kafai@fb.com>
 <1461133497-1515104-3-git-send-email-kafai@fb.com>
 <CACSApvbyD7wFy+y2MrShKRMCTg-zF6UkP-Le867N=ssCYa-Yng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59813 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752172AbcDUQ4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 12:56:47 -0400
Content-Disposition: inline
In-Reply-To: <CACSApvbyD7wFy+y2MrShKRMCTg-zF6UkP-Le867N=ssCYa-Yng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 04:04:54PM -0400, Soheil Hassas Yeganeh wrote:
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index a6e4a83..96bdf98 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -2494,6 +2494,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
> >          * packet counting does not break.
> >          */
> >         TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked & TCPCB_EVER_RETRANS;
> > +       TCP_SKB_CB(skb)->eor = TCP_SKB_CB(next_skb)->eor;
> >
> >         /* changed transmit queue under us so clear hints */
> >         tcp_clear_retrans_hints_partial(tp);
> > @@ -2545,6 +2546,9 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
> >                 if (!tcp_can_collapse(sk, skb))
> >                         break;
> >
> > +               if (TCP_SKB_CB(to)->eor)
> > +                       break;
> > +
>
> nit: Perhaps a better place to check for eor is right after entering
> the loop? to skip a few instructions and tcp_can_collapse, in an
> unlikely case eor is set.
hmm... Not sure I understand it.
You meant moving the unlikely case before (or after?) the more likely
cases which may have a better chance to break the loop sooner?
