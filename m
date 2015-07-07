From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net-next] tcp: always send a quick ack when quickacks are enabled
Date: Tue, 7 Jul 2015 17:22:19 +1000
Message-ID: <CAGHK07AKzaQm_T8d3E54xRtidOuaE2jetoVJKZ+=o0U7axhAkw@mail.gmail.com>
References: <1436242926-21416-1-git-send-email-jmaxwell37@gmail.com>
	<1436252703.4571.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jmorris <jmorris@namei.org>, yoshfuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jon Maxwell <jmaxwell@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36144 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbbGGHWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 03:22:20 -0400
In-Reply-To: <1436252703.4571.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, 2015-07-07 at 14:22 +1000, Jon Maxwell wrote:
>
>
> > @@ -4887,6 +4884,7 @@ static inline void tcp_data_snd_check(struct sock
> > *sk)
> >  static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
> >  {
> >      struct tcp_sock *tp = tcp_sk(sk);
> > +    const struct dst_entry *dst = __sk_dst_get(sk);
> >
> >          /* More than one full frame received... */
> >      if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
> > @@ -4896,6 +4894,8 @@ static void __tcp_ack_snd_check(struct sock *sk, int
> > ofo_possible)
> >           __tcp_select_window(sk) >= tp->rcv_wnd) ||
> >          /* We ACK each frame or... */
> >          tcp_in_quickack_mode(sk) ||
> > +        /* quickack on dst */
> > +        (dst && dst_metric(dst, RTAX_QUICKACK)) ||
> >          /* We have out of order data. */
> >          (ofo_possible && skb_peek(&tp->out_of_order_queue))) {
>
> This logic should be moved to tcp_in_quickack_mode() ?

Yes agreed that's a better place for the check seeing that we
already check the other quickack conditions there as well.

>
> Note I placed the dst test before others, to reduce jump prediction
> misses.
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 684f095d196e..69ec8d25a2e5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -196,11 +196,13 @@ static void tcp_enter_quickack_mode(struct sock *sk)
>   * and the session is not interactive.
>   */
>
> -static inline bool tcp_in_quickack_mode(const struct sock *sk)
> +static bool tcp_in_quickack_mode(struct sock *sk)
>  {
>      const struct inet_connection_sock *icsk = inet_csk(sk);
> +    const struct dst_entry *dst = __sk_dst_get(sk);
>
> -    return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
> +    return (dst && dst_metric(dst, RTAX_QUICKACK)) ||
> +           (icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong);
>  }
>
>  static void tcp_ecn_queue_cwr(struct tcp_sock *tp)
>
>

On Tue, Jul 7, 2015 at 5:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-07-07 at 14:22 +1000, Jon Maxwell wrote:
>
>
>> @@ -4887,6 +4884,7 @@ static inline void tcp_data_snd_check(struct sock *sk)
>>  static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
>>  {
>>       struct tcp_sock *tp = tcp_sk(sk);
>> +     const struct dst_entry *dst = __sk_dst_get(sk);
>>
>>           /* More than one full frame received... */
>>       if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
>> @@ -4896,6 +4894,8 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
>>            __tcp_select_window(sk) >= tp->rcv_wnd) ||
>>           /* We ACK each frame or... */
>>           tcp_in_quickack_mode(sk) ||
>> +         /* quickack on dst */
>> +         (dst && dst_metric(dst, RTAX_QUICKACK)) ||
>>           /* We have out of order data. */
>>           (ofo_possible && skb_peek(&tp->out_of_order_queue))) {
>
> This logic should be moved to tcp_in_quickack_mode() ?
>
> Note I placed the dst test before others, to reduce jump prediction
> misses.
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 684f095d196e..69ec8d25a2e5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -196,11 +196,13 @@ static void tcp_enter_quickack_mode(struct sock *sk)
>   * and the session is not interactive.
>   */
>
> -static inline bool tcp_in_quickack_mode(const struct sock *sk)
> +static bool tcp_in_quickack_mode(struct sock *sk)
>  {
>         const struct inet_connection_sock *icsk = inet_csk(sk);
> +       const struct dst_entry *dst = __sk_dst_get(sk);
>
> -       return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
> +       return (dst && dst_metric(dst, RTAX_QUICKACK)) ||
> +              (icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong);
>  }
>
>  static void tcp_ecn_queue_cwr(struct tcp_sock *tp)
>
>
>
>
