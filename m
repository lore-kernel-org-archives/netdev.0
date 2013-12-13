From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 11:22:56 -0500
Message-ID: <CADVnQynu9kbaqMW+eTMsp8jgydiLf9-nxnp-z_s789Q1eSPPmw@mail.gmail.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
	<1386946449.19078.147.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:46614 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125Ab3LMQW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 11:22:57 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so829958eek.13
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 08:22:56 -0800 (PST)
In-Reply-To: <1386946449.19078.147.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 9:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-13 at 09:15 -0500, Neal Cardwell wrote:
>
>> Seems like a nice improvement, but if we apply this patch then AFAICT
>> to get the Nagle-enabled case right we also have to update
>> tcp_minshall_update() to notice these new non-MSS-aligned segments
>> going out, and count those as non-full-size segments for the
>> minshall-nagle check (to ensure we have no more than one outstanding
>> un-ACKed sub-MSS packet). Maybe something like (please excuse the
>> formatting):
>>
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 70e55d2..a2ec237 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -980,7 +980,8 @@ bool tcp_is_cwnd_limited(const struct sock *sk,
>> u32 in_flight);
>>  static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
>>                                        const struct sk_buff *skb)
>>  {
>> -       if (skb->len < mss)
>> +       if (skb->len < mss ||
>> +           tcp_skb_pcount(skb) * tcp_skb_mss(skb) > skb->len)
>>                 tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
>>  }
>
> Very good point Neal, but dont you think tcp_skb_mss(skb) is equal to
> mss at this point ? (We normally have synced with tso_segs =
> tcp_init_tso_segs(sk, skb, mss_now);)
>
> (Just trying to make this code more understandable...)
>
> Also I think we should move this helper out of include/net/tcp.h, we
> only use it from tcp_output.c
>
> I'll submit a v2, rewording the comment in front of
> tcp_mss_split_point()

Yes, I like your ideas to use mss_now instead, move
tcp_minshall_update() to tcp_output.c (next to tcp_minshall_check()?),
and update the comment in front of tcp_mss_split_point().

And given that mss_now is more sane than tcp_skb_mss(skb) (which is
zero for one-MSS skbs) I think maybe we can make it something like:

 static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned
int mss_now,
                                       const struct sk_buff *skb)
 {
         if (skb->len < tcp_skb_pcount(skb) * mss_now)
                tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
 }

neal
