From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Sat, 03 Dec 2011 16:09:52 +0100
Message-ID: <1322924992.2762.117.camel@edumazet-laptop>
References: <1322857369.2762.63.camel@edumazet-laptop>
	 <20111202.152426.447759025066188323.davem@davemloft.net>
	 <1322858756.2762.68.camel@edumazet-laptop>
	 <20111202.163024.1294014889349291295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43444 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab1LCPKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 10:10:00 -0500
Received: by bkbzv3 with SMTP id zv3so266533bkb.19
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 07:09:59 -0800 (PST)
In-Reply-To: <20111202.163024.1294014889349291295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 16:30 -0500, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 02 Dec 2011 21:45:56 +0100
>=20
> > Retransmits could transmits 3 bytes already ACKed, is it a big deal=
 ?
>=20
> Unfortunately this kind of adjustment doesn't work.
>=20
> When we trim the head in response to ACK'd data, the stack assumes th=
at
> the first byte sitting at the front of the retransmit queue is ->snd_=
una.
>=20
> So if you just back align the pull, and don't make amends for the set=
ting
> of ->snd_una, we'll retransmit the wrong bytes.  The send queue will =
be
> out of sync with the sequence number state of the socket.
>=20
> This has implications for SACK tagging state bit in the transmit queu=
e
> as well.
>=20
> In fact, this is a real dangerous road to go down, I think :-)


Yeah, it was not a good idea :)

My plan is to add a third parameter to pskb_copy(struct sk_buff *skb,
gfp_t gfp_mask, int reserve)

and use pskb_copy() in tcp_retransmit_skb() if it appears we need
between 1 and 3 bytes to re-align skb head before calling
tcp_transmit_skb(), (if NET_IP_ALIGN is not null)

[ In the unlikely case we had to allocate a new skb with pskb_copy(), w=
e
will pass clone_it=3D0 to tcp_transmit_skb() ]

I'll send a fully tested patch before the end of week end.

Thanks !
