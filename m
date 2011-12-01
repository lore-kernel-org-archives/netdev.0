From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 06/10] e1000e: Support for byte queue limits
Date: Thu, 01 Dec 2011 11:12:14 +0100
Message-ID: <1322734334.2335.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111281819350.24413@pokey.mtv.corp.google.com>
	 <20111129130137.000009ce@unknown>
	 <CA+mtBx-8AzEyUc3GVD+mEQoqUZeaB9hjSJonRW_SjOQaTx51mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:64461 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788Ab1LAKMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 05:12:18 -0500
Received: by vcbfk14 with SMTP id fk14so1269879vcb.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 02:12:18 -0800 (PST)
In-Reply-To: <CA+mtBx-8AzEyUc3GVD+mEQoqUZeaB9hjSJonRW_SjOQaTx51mQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 17:04 -0800, Tom Herbert a =C3=A9cr=
it :
> > whats wrong with using total_tx_bytes or buffer_info->bytecount?  i=
t
> > contains the "bytes on the wire" value which will be slightly large=
r
> > than skb->len, but avoids warming the skb->len cacheline unnecessar=
ily.
> >
>=20
> This makes sense.  I made the changes, but the limits computed are
> much higher than with using sbk->len.  I suspect there may be a bug i=
n
> GSO path.
>=20
> For instance, in the driver at:
>=20
>   bytecount =3D ((segs - 1) * skb_headlen(skb)) + skb->len;
>=20
> I see cases like:
>=20
>   segs=3D34, skb_header_len(skb)=3D70, skb->len=3D49298 so bytecount=3D=
51608
>=20
> Which seems reasonable... but, I also see things like:
>=20
>   segs=3D45, skb_header_len(skb)=3D1522, skb->len=3D65226, so bytecou=
nt=3D 132194
>                                                       ^^^^
> Which doesn't seem right at all.  I am thinking there may be a bug
> setting skb->data_len improperly.
>=20

OK, as stated on your other thread, its obvious this driver (and
probably other intel drivers) made assumptions that are now obsolete,
since skb head can contain some data payload, not only (MAC+IP+TCP)
headers.

If Intel guys cannot afford approximate the bytecount by skb->len, I
suggest to use same trick found in=20
drivers/net/ethernet/intel/igb/igb_main.c

static int igb_tso(struct igb_ring *tx_ring,=20
=2E..
        /* compute header lengths */
        l4len =3D tcp_hdrlen(skb);
        *hdr_len =3D skb_transport_offset(skb) + l4len;

        /* update gso size and bytecount with header size */
        first->gso_segs =3D skb_shinfo(skb)->gso_segs;
        first->bytecount +=3D (first->gso_segs - 1) * *hdr_len;
