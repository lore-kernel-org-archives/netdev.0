From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: set retransmit_high on loop exit
Date: Wed, 14 May 2014 14:46:52 -0400
Message-ID: <CADVnQy=s6mVpVzNKhSQw9ZULsomz=Qj9Xu-iOfREH3Z9gyMfbg@mail.gmail.com>
References: <b1093d318477c57478b0b64475d9066710d7c75b.1399812676.git.panweiping3@gmail.com>
	<20140514.140828.379626997254455792.davem@davemloft.net>
	<1400092038.7973.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, panweiping3@gmail.com,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:59752 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaENSqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:46:54 -0400
Received: by mail-we0-f179.google.com with SMTP id q59so2344312wes.24
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 11:46:52 -0700 (PDT)
In-Reply-To: <1400092038.7973.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 2:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-05-14 at 14:08 -0400, David Miller wrote:
>> From: Weiping Pan <panweiping3@gmail.com>
>> Date: Sun, 11 May 2014 20:57:30 +0800
>>
>> > To save some CPU cycles slightly.
>> >
>> > Signed-off-by: Weiping Pan <panweiping3@gmail.com>
>>
>> Can a TCP expert please review this?
>>
>> > ---
>> >  net/ipv4/tcp_input.c | 8 ++++++--
>> >  1 file changed, 6 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> > index d6b46eb..e431037 100644
>> > --- a/net/ipv4/tcp_input.c
>> > +++ b/net/ipv4/tcp_input.c
>> > @@ -1941,8 +1941,13 @@ void tcp_enter_loss(struct sock *sk, int how)
>> >     tcp_clear_all_retrans_hints(tp);
>> >
>> >     tcp_for_write_queue(skb, sk) {
>> > -           if (skb == tcp_send_head(sk))
>> > +           if (skb == tcp_send_head(sk)) {
>> > +                   if (skb != tcp_write_queue_head(sk)) {
>> > +                           skb = tcp_write_queue_prev(sk, skb);
>> > +                           tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
>> > +                   }
>> >                     break;
>> > +           }
>> >
>> >             if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
>> >                     tp->undo_marker = 0;
>> > @@ -1952,7 +1957,6 @@ void tcp_enter_loss(struct sock *sk, int how)
>> >                     TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
>> >                     TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
>> >                     tp->lost_out += tcp_skb_pcount(skb);
>> > -                   tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
>> >             }
>> >     }
>> >     tcp_verify_left_out(tp);
>> > --
>
> Frankly I do not see the point here.
>
> This adds code and conditional jumps, while original code is 2
> instructions with no cache line misses, and is cleaner IMHO.

I very much agree with Eric that the original code is simpler,
cleaner, and almost certainly just as fast as the code in the patch.

In addition, the patch has at least one significant bug: it sets
tp->retransmit_high to the end of the last skb even when the last skb
has been SACKed. We don't want to do that. :-)

neal
