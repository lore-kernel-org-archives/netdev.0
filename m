From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Mon, 06 Jun 2011 09:38:19 +0200
Message-ID: <1307345899.3098.3.camel@edumazet-laptop>
References: <20110606064603.GB31505@secunet.com>
	 <20110606064802.GC31505@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53130 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab1FFHiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 03:38:23 -0400
Received: by wwa36 with SMTP id 36so3495719wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 00:38:22 -0700 (PDT)
In-Reply-To: <20110606064802.GC31505@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 08:48 +0200, Steffen Klassert a =C3=A9crit=
 :
> Git commit 59104f06 (ip: take care of last fragment in ip_append_data=
)
> added a check to see if we exceed the mtu when we add trailer_len.
> However, the mtu is already subtracted by trailer_len when the
> xfrm transfomation bundles are set up. So IPsec packets with mtu
> size get fragmented, or if the DF bit is set the packets will not
> be send even though they match the mtu perfectly fine. This patch
> actually reverts commit 59104f06.
>=20
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---

Woh, I am afraid I wont have time in following days to check your
assertion.

What about original problem then, how should we fix it ?

We do have some cases where at least one fragment (the last one) is
oversized.

I remember I used Nick Bowler scripts at that time, I might find them
again...

[PATCH] ip : take care of last fragment in ip_append_data

While investigating a bit, I found ip_fragment() slow path was taken
because ip_append_data() provides following layout for a send(MTU +
N*(MTU - 20)) syscall :

- one skb with 1500 (mtu) bytes
- N fragments of 1480 (mtu-20) bytes (before adding IP header)
last fragment gets 17 bytes of trail data because of following bit:

        if (datalen =3D=3D length + fraggap)
                alloclen +=3D rt->dst.trailer_len;

Then esp4 adds 16 bytes of data (while trailer_len is 17... hmm...
another bug ?)

In ip_fragment(), we notice last fragment is too big (1496 + 20) > mtu,
so we take slow path, building another skb chain.

In order to avoid taking slow path, we should correct ip_append_data()
to make sure last fragment has real trail space, under mtu...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>


