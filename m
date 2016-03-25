From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH] tcp: Add SOF_TIMESTAMPING_TX_EOR and allow MSG_EOR in tcp_sendmsg
Date: Fri, 25 Mar 2016 16:05:51 -0700
Message-ID: <CAK6E8=ekVGq9E3sZEcZVdSEfTxxZ74W7FdW1YmKS-GFASQbJnw@mail.gmail.com>
References: <1458859592-751521-1-git-send-email-kafai@fb.com> <CAF=yD-JPvjNz=CZH6X=Hj+0vSyTyZcwKJoeTdOZKjx1Ys17DNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	Network Development <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35134 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcCYXGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 19:06:33 -0400
Received: by mail-wm0-f51.google.com with SMTP id l68so30265632wml.0
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 16:06:32 -0700 (PDT)
In-Reply-To: <CAF=yD-JPvjNz=CZH6X=Hj+0vSyTyZcwKJoeTdOZKjx1Ys17DNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 6:39 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>
> > This patch allows the user process to use MSG_EOR during
> > tcp_sendmsg to tell the kernel that it is the last byte
> > of an application response message.
> >
> > The user process can use the new SOF_TIMESTAMPING_TX_EOR to
> > ask the kernel to only track timestamp of the MSG_EOR byte.
>
> Selective timestamp requests is a useful addition. Soheil (cc-ed) also
> happens to be looking at this. That approach uses cmsg to selectively
> tag send calls, avoiding the need to define a new SOF_ flag.
>
> > The current SOF_TIMESTAMPING_TX_ACK is tracking the last
> > byte appended to a skb during the tcp_sendmsg.  It may track
> > multiple bytes if the response spans across multiple skbs.
>
> It only tracks the last byte of the buffer passed in sendmsg. If a
> sendmsg results in multiple skbuffs, only the last skb is tracked. It
> is, however, possible that that skbuff is appended to in a follow-on
> sendmsg call. If multiple calls enable recording on an skbuff, only
> the last record request on an skb is kept.
>
> > it is enough to measure the response latency for application
> > protocol with a single request/response at a time (like HTTP 1.1
> > without pipeline), it does not work well for application protocol
> > with >1 pipeline responses (like HTTP2).
Looks like an interesting and useful patch. Since HTTP2 allows
multiplexing data stream frames from multiple logical streams on a
single socket,
how would you instrument to measure the latency of each stream? e.g.,

sendmsg of data_frame_1_of_stream_a
sendmsg of data_frame_1_of_stream_b
sendmsg of data_frame_2_of_stream_a
sendmsg of data_frame_1_of_stream_c
sendmsg of data_frame_2_of_stream_b


> >
> > Each skb can only track one tskey (which is the seq number of
> > the last byte of the message).   To allow tracking the
> > last byte of multiple response messages, this patch takes an approach
> > by not appending to the last skb during tcp_sendmsg if the last skb's
> > tskey will be overwritten.  A similar case also happens during retransmit.
> >
> > This approach avoids introducing another list to track the tskey.  The
> > downside is that it will have less gso benefit and/or more outgoing
> > packets.  Practically, due to the amount of measurement data generated,
> > sampling is usually used in production. (i.e. not every connection is
> > tracked).
>
> Agreed. This is the simplest approach to avoiding timestamp request
> overwrites. A list-based approach quickly becomes complex as skbuffs
> can be split and merged at various points.
>
> Since this use is rare, I would suggest making the code even simpler
> by just jumping to new_segment on a call with this MSG option (or
> cmsg) set, avoiding tcp_tx_ts_noappend_skb() on each new segment.
+1

>
> > One of our use case is at the webserver.  The webserver tracks
> > the HTTP2 response latency by measuring when the webserver
> > sends the first byte to the socket till the TCP ACK of the last byte
> > is received.  In the cases where we don't have client side
> > measurement, measuring from the server side is the only option.
> > In the cases we have the client side measurement, the server side
> > data can also be used to justify/cross-check-with the client
> > side data (e.g. is there slowness at the layer above the client's
> > TCP stack).
> >
> > The TCP PRR paper [1] also measures a similar metrics:
> > "The TCP latency of a HTTP response when the server sends the first
> >  byte until it receives the acknowledgment (ACK) for the last byte."
> >
> > [1] Proportional Rate Reduction for TCP:
> > http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/37486.pdf
> >
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > Cc: Willem de Bruijn <willemb@google.com>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > ---
> >  include/uapi/linux/net_tstamp.h |  3 ++-
> >  net/ipv4/tcp.c                  | 23 ++++++++++++++++++-----
> >  net/ipv4/tcp_output.c           |  9 +++++++--
> >  3 files changed, 27 insertions(+), 8 deletions(-)
> >
> > diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
> > index 6d1abea..5376569 100644
> > --- a/include/uapi/linux/net_tstamp.h
> > +++ b/include/uapi/linux/net_tstamp.h
> > @@ -25,8 +25,9 @@ enum {
> >         SOF_TIMESTAMPING_TX_ACK = (1<<9),
> >         SOF_TIMESTAMPING_OPT_CMSG = (1<<10),
> >         SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
> > +       SOF_TIMESTAMPING_TX_EOR = (1<<12),
> >
> > -       SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TSONLY,
> > +       SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_EOR,
> >         SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
> >                                  SOF_TIMESTAMPING_LAST
> >  };
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 08b8b96..7de96eb 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -428,11 +428,16 @@ void tcp_init_sock(struct sock *sk)
> >  }
> >  EXPORT_SYMBOL(tcp_init_sock);
> >
> > -static void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
> > +static void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb, int flags)
> >  {
> >         if (sk->sk_tsflags) {
> > -               struct skb_shared_info *shinfo = skb_shinfo(skb);
> > +               struct skb_shared_info *shinfo;
> >
> > +               if ((sk->sk_tsflags & SOF_TIMESTAMPING_TX_EOR) &&
> > +                   !(flags & MSG_EOR))
> > +                       return;
> > +
> > +               shinfo = skb_shinfo(skb);
> >                 sock_tx_timestamp(sk, &shinfo->tx_flags);
> >                 if (shinfo->tx_flags & SKBTX_ANY_TSTAMP)
> >                         shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
> > @@ -957,7 +962,7 @@ new_segment:
> >                 offset += copy;
> >                 size -= copy;
> >                 if (!size) {
> > -                       tcp_tx_timestamp(sk, skb);
> > +                       tcp_tx_timestamp(sk, skb, flags);
> >                         goto out;
> >                 }
> >
> > @@ -1073,6 +1078,14 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
> >         return err;
> >  }
> >
> > +static bool tcp_tx_ts_noappend_skb(const struct sock *sk,
> > +                                  const struct sk_buff *last_skb, int flags)
> > +{
> > +       return unlikely((sk->sk_tsflags & SOF_TIMESTAMPING_TX_EOR) &&
> > +                       (flags & MSG_EOR) &&
>
> flags seems more likely to be cached than sk->sk_tsflags at this
> point, in which case swap those tests.
>
> > +                       (skb_shinfo(last_skb)->tx_flags & SKBTX_ANY_TSTAMP));
> > +}
> > +
> >  int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>
> for a non-rfc patch, also change do_tcp_sendpages
>
> >  {
> >         struct tcp_sock *tp = tcp_sk(sk);
> > @@ -1144,7 +1157,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> >                         copy = max - skb->len;
> >                 }
> >
> > -               if (copy <= 0) {
> > +               if (copy <= 0 || tcp_tx_ts_noappend_skb(sk, skb, flags)) {
> >  new_segment:
>
> This adds a test to every segment for a niche feature. See my point of
> just jumping here on first entering the loop.
