From: David Miller <davem@davemloft.net>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 21 Feb 2012 14:11:31 -0500 (EST)
Message-ID: <20120221.141131.43470109990118714.davem@davemloft.net>
References: <1329431746.2438.8.camel@edumazet-laptop>
	<CADVnQynNEzJQvWdFeSDadPA7uZsraC64m=kNwe8M8sDsCyBD1Q@mail.gmail.com>
	<1329849683.18384.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, alekcejk@googlemail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab2BUTLg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:11:36 -0500
In-Reply-To: <1329849683.18384.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 19:41:23 +0100

> Le vendredi 17 f=E9vrier 2012 =E0 11:41 -0500, Neal Cardwell a =E9cri=
t :
>> On Thu, Feb 16, 2012 at 5:35 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > An incoming skb is considered as "good citizen" in term of memory =
usage
>> > if its truesize is no more than
>> > len + len/4   (if adv_win_scale =3D=3D 2)
>> >
>> > That was true when truesize was 1500+NET_SKB_PAD+sizeof(sk_buff),
>> > but not true anymore when truesize is 2048+sizeof(sk_buff), or eve=
n more
>> > when its 4096+sizeof(sk_buff)
>> >
>> > So receiver doesnt increase rcv_ssthresh and cannot open its windo=
w.
>> >
>> > tcp_grow_window() should be tweaked to :
>> >
>> > 1) Relax the requirements
>> > 2) Allow bigger increase in case of super packets (LRO/GRO)
>>=20
>> That sounds great. Is this something you're planning on tackling?
>>=20
>=20
> Hmm, I thought about following (untested) patch :
>=20
> Idea is to increase rcv_sshthresh by 2*len * (len/truesize), instead =
of
> 2*mss.

This looks like a good start.

I think the core task is to seperate two things:

1) The test for "full size SKB" which erroneously is done using that
   "X + (X/N)" formula.

   To be quite honest, I think we don't care about this condition at
   all.  What we really care about is whether the frame was a full MSS
   (or at least, close to it).

2) The growth calculation which does in fact need to be based upon
   truesize because this determines what we'll need to do to make
   more frames actually fit in the receive window given the witnessed
   truesize ratio.

And it seems your patch takes care of #2 but not #1.

The error in the current code is that it tries to estimate what a
"good" truesize might look like with a very ad-hoc sysctl that is, at
best, magic.  We should kill this sysctl and everything using it, and
therefore make our decisions on window growth purely based upon
skb->len and MSS.
