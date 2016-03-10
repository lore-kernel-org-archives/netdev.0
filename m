From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v3] tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In
Date: Wed, 9 Mar 2016 17:55:00 -0800
Message-ID: <20160310015500.GA68025@kafai-mba.local>
References: <1457548994-823272-1-git-send-email-kafai@fb.com>
 <CAK6E8=fxc+uefYnnEb1Np7OUTNASXvYeOfJOtEeABdWOqEY_=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46875 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753666AbcCJBzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 20:55:33 -0500
Content-Disposition: inline
In-Reply-To: <CAK6E8=fxc+uefYnnEb1Np7OUTNASXvYeOfJOtEeABdWOqEY_=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 03:11:50PM -0800, Yuchung Cheng wrote:
> On Wed, Mar 9, 2016 at 10:43 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> > diff --git a/include/net/tcp.h b/include/net/tcp.h
> > index e90db85..24557a8 100644
> > --- a/include/net/tcp.h
> > +++ b/include/net/tcp.h
> > @@ -1816,4 +1816,14 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
> >         skb->truesize = 2;
> >  }
> >
> > +static inline void tcp_segs_in(struct tcp_sock *tp, const struct sk_buff *skb)
> > +{
> > +       u16 segs_in;
> > +
> > +       segs_in = max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> > +       tp->segs_in += segs_in;
> > +       if (skb->len > tcp_hdrlen(skb))
> > +               tp->data_segs_in += segs_in;
> > +}
> > +
> >  #endif /* _TCP_H */
> > diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> > index fdb286d..f583c85 100644
> > --- a/net/ipv4/tcp_fastopen.c
> > +++ b/net/ipv4/tcp_fastopen.c
> > @@ -131,6 +131,7 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
> >  void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
> >  {
> >         struct tcp_sock *tp = tcp_sk(sk);
> > +       u16 segs_in;
> >
> >         if (TCP_SKB_CB(skb)->end_seq == tp->rcv_nxt)
> >                 return;
> > @@ -154,6 +155,9 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
> >          * as we certainly are not changing upper 32bit value (0)
> >          */
> >         tp->bytes_received = skb->len;
> > +       segs_in = max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> > +       tp->segs_in = segs_in;
> > +       tp->data_segs_in = segs_in;
> why not use the new tcp_segs_in() helper?
It is because
segs_in has been set to 1 by tcp_create_openreq_child(), so calling
tcp_segs_in() will have it double counted
and
tcphdr has been pulled from skb, so skb->len does not include tcp_hdrlen.

I will add some remark in this change.
