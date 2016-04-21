From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [RFC PATCH v3 net-next 2/3] tcp: Handle eor bit when coalescing skb
Date: Thu, 21 Apr 2016 17:14:37 -0400
Message-ID: <CACSApvZO9d9B-5YOxm7LbpOvtORXQctTiocAY+2tigugDqr0eg@mail.gmail.com>
References: <1461133497-1515104-1-git-send-email-kafai@fb.com>
 <1461133497-1515104-3-git-send-email-kafai@fb.com> <CACSApvbyD7wFy+y2MrShKRMCTg-zF6UkP-Le867N=ssCYa-Yng@mail.gmail.com>
 <20160421165633.GA74969@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33416 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbcDUVPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 17:15:17 -0400
Received: by mail-oi0-f41.google.com with SMTP id r78so100128467oie.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 14:15:17 -0700 (PDT)
In-Reply-To: <20160421165633.GA74969@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 12:56 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Wed, Apr 20, 2016 at 04:04:54PM -0400, Soheil Hassas Yeganeh wrote:
>> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> > index a6e4a83..96bdf98 100644
>> > --- a/net/ipv4/tcp_output.c
>> > +++ b/net/ipv4/tcp_output.c
>> > @@ -2494,6 +2494,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
>> >          * packet counting does not break.
>> >          */
>> >         TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked & TCPCB_EVER_RETRANS;
>> > +       TCP_SKB_CB(skb)->eor = TCP_SKB_CB(next_skb)->eor;
>> >
>> >         /* changed transmit queue under us so clear hints */
>> >         tcp_clear_retrans_hints_partial(tp);
>> > @@ -2545,6 +2546,9 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
>> >                 if (!tcp_can_collapse(sk, skb))
>> >                         break;
>> >
>> > +               if (TCP_SKB_CB(to)->eor)
>> > +                       break;
>> > +
>>
>> nit: Perhaps a better place to check for eor is right after entering
>> the loop? to skip a few instructions and tcp_can_collapse, in an
>> unlikely case eor is set.
> hmm... Not sure I understand it.
> You meant moving the unlikely case before (or after?) the more likely
> cases which may have a better chance to break the loop sooner?

Well I don't have strong preference here. So, feel free to ignore.
Though I'm not sure how "likely" are the checks in tcp_can_collapse.

On another note, do you think putting this is a self-documenting
helper function, say tcp_can_collapse_to(), would help readability?

Thanks.
