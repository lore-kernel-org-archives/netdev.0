From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 14:40:37 -0400
Message-ID: <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>
References: <1334653608.6226.11.camel@edumazet-laptop>
	<1334654187.2696.2.camel@jtkirshe-mobl>
	<4F8D93E1.9090000@intel.com>
	<1334681204.2472.41.camel@edumazet-glaptop>
	<1334698722.2472.71.camel@edumazet-glaptop>
	<1334764184.2472.299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:55595 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab2DRSki convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 14:40:38 -0400
Received: by qafi31 with SMTP id i31so1024977qaf.1
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 11:40:38 -0700 (PDT)
In-Reply-To: <1334764184.2472.299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 18, 2012 at 11:49 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While doing netperf sessions on 10Gb Intel nics (ixgbe), I noticed
> unexpected profiling results, with pskb_expand_head() being in the to=
p.
>
> After further analysis, I found we hit badly page refcounts,
> because when we transmit full size skb (64 KB), we can receive ACK fo=
r
> the first segments of the frame while skb was not completely sent by
> NIC.
>
> It takes ~54 us to send a full TSO packet at 10Gb speed, but with a
> close peer, we can receive TCP ACK in less than 50 us rtt.
>
> This is also true on 1Gb links but we were limited by wire speed, not
> cpu.
>
> When we try to trim skb, tcp_trim_head() has to call pskb_expand_head=
(),
> because the skb clone we did for transmit is still alive in TX ring
> buffer.
>
> pskb_expand_head() is really expensive : It has to make about 16+16
> atomic operations on page refcounts, not counting the skb head
> reallocation/copy. It increases chances of false sharing.
>
> In fact, we dont really need to trim skb. This costly operation can b=
e
> delayed to the point it is really needed : Thats when a retransmit mu=
st
> happen.
>
> Most of the time, upcoming ACKS will ack the whole packet, and we can
> free it with minimal cost (since clone was already freed by TX
> completion)
>
> Of course, this means we dont uncharge the acked part from socket lim=
its
> until retransmit, but this is hardly a concern with current autotunin=
g
> (around 4MB per socket)
> Even with small cwnd limit, a single packet can not hold more than ha=
lf
> the window.
>
> Performance results on my Q6600 cpu and 82599EB 10-Gigabit card :
> About 3% less cpu used for same workload (single netperf TCP_STREAM),
> bounded by x4 PCI-e slots (4660 Mbits).
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Nice find!

> + =C2=A0 =C2=A0 =C2=A0 prev_packets_acked =3D tcp_skb_pcount(skb);

=46WIW, I'd find old_pcount or prev_pcount a little easier to read than
prev_packets_acked here (I see "oldpcount" is used in tcp_output
in a similar context).

> =C2=A0 =C2=A0 =C2=A0 =C2=A0TCP_SKB_CB(skb)->seq +=3D len;
> + =C2=A0 =C2=A0 =C2=A0 TCP_SKB_CB(skb)->header.offset_ack =3D 0;

If the caller decides to trim a prefix of the skb that does not extend
to snd_una, then setting offset_ack to 0 here will cause us to forget
that some prefix is ACKed when we should have remembered this.
However, the API for the function invites the caller to chop off an
arbitrary amount (and there's no comment to disuade the caller from
trying this). This seems to risk bugs in the future.

To attempt to make this API safer and simpler for future generations,
what do you think about calculating the len inside tcp_trim_head(),
something like:

static int tcp_trim_head(struct sock *sk, struct sk_buff *skb)
{
  u32 len =3D tp->snd_una - TCP_SKB_CB(skb)->seq;
=2E..

=2E..
 if (tcp_trim_head(sk, skb))
=2E..

neal
