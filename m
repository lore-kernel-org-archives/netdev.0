From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 19:36:29 +0100
Message-ID: <1322850989.2762.47.camel@edumazet-laptop>
References: <1322827188.2607.19.camel@edumazet-laptop>
	 <1322840663.2762.26.camel@edumazet-laptop>
	 <1322841935.2762.33.camel@edumazet-laptop>
	 <20111202.131304.981034697414242002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60820 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab1LBSgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 13:36:35 -0500
Received: by bkas6 with SMTP id s6so4177022bka.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 10:36:34 -0800 (PST)
In-Reply-To: <20111202.131304.981034697414242002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 13:13 -0500, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 02 Dec 2011 17:05:35 +0100
>=20
> > Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 16:44 +0100, Eric Dumazet =
a =C3=A9crit :
> >=20
> >> [PATCH net-next] tcp: fix tcp_trim_head()
> >>=20
> >> commit f07d960df3 (tcp: avoid frag allocation for small frames)
> >> breaked assumption in tcp stack that skb is either linear (data_le=
n =3D=3D
> >> 0), either fully fragged (data_len =3D=3D len)
> >>=20
> >> Thanks to Vijay for providing a very detailed explanation.
> >>=20
> >> Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> ---
> >=20
> > Another problem is the possible misalignement of skb->data if/when =
we
> > receive an ACK of an odd (not a 4 multiple) tcp sequence.
> >=20
> > So when/if packet is restransmited, tcp header (and IP header as we=
ll)
> > could be misaligned.
> >=20
> > Hmm, I probably miss something obvious, since this problem could ha=
ppen
> > for linear skbs before my patch ?
>=20
> Unfortunately, even if netfilter or the packet scheduler pulled data,=
 this
> misalignment wouldn't happen before your change.
>=20
> Maybe we should revert your frag allocation avoidance change until we=
 can
> sort this out.

The patch I posted should solve the problem Vijay spotted.
(It really does, I tested it, allowing mtu probing)

What I ask now is following problem (even prior to my frag allocation
patch) :

1) We allocate a linear skb (SG being off) to cook a tcp frame of lengt=
h
XXX bytes.

2) We send it.

3) We receive an ACK for first 31 bytes.

4) We trim 31 bytes from the head of skb.  (skb_pull(skb, 31))
    skb->data is now not anymore aligned to a 4 bytes boundary.

5) Later, we need to retransmit skb (XXX minus 31 bytes already ACKed)
   We push TCP header, and skb->data is not aligned.
   TCP header is not aligned anymore. x86 doesnt care, but what about
other arches with misalign traps ?
