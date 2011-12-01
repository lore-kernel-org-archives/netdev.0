From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 06/10] e1000e: Support for byte queue limits
Date: Thu, 1 Dec 2011 08:32:16 -0800
Message-ID: <CA+mtBx80aoWtDh3=gMnfVCi9r5E_bjqgreoa-yjwDc5+kcocjg@mail.gmail.com>
References: <alpine.DEB.2.00.1111281819350.24413@pokey.mtv.corp.google.com>
	<20111129130137.000009ce@unknown>
	<CA+mtBx-8AzEyUc3GVD+mEQoqUZeaB9hjSJonRW_SjOQaTx51mQ@mail.gmail.com>
	<1322734334.2335.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44169 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab1LAQcR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 11:32:17 -0500
Received: by iage36 with SMTP id e36so2710977iag.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 08:32:17 -0800 (PST)
In-Reply-To: <1322734334.2335.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> OK, as stated on your other thread, its obvious this driver (and
> probably other intel drivers) made assumptions that are now obsolete,
> since skb head can contain some data payload, not only (MAC+IP+TCP)
> headers.
>
Looks like similar is in several Intel drivers.  Only other driver I
found that is using the false assumption is tg3 IPv6 gso path.

> If Intel guys cannot afford approximate the bytecount by skb->len, I
> suggest to use same trick found in
> drivers/net/ethernet/intel/igb/igb_main.c
>
> static int igb_tso(struct igb_ring *tx_ring,
> ...
> =A0 =A0 =A0 =A0/* compute header lengths */
> =A0 =A0 =A0 =A0l4len =3D tcp_hdrlen(skb);
> =A0 =A0 =A0 =A0*hdr_len =3D skb_transport_offset(skb) + l4len;
>
I noticed a similar technique used by several drivers.  it's fine if
it already knew the packet was TCP.  Just assuming that a GSO packet
is TCP might be a new bug, so in the e1000e driver they would need to
check the type (gso_type =3D=3D SKB_GSO_TCPV4 or SKB_GSO_TCPV6).

I'm not sure that tcp_hdrlen is even being used correctly in the other
drivers.  For instance in bnx2x, tcp_hdrlen is called after checking
skb_is_gso_v6(skb) and skb_is_gso(skb).  If the former is true then in
fact it is a TCP packet (gso_type is SKB_GSO_TCPV6) , but the if the
latter is true it only proves that is is GSO packet (gso_type not
checked, only gso_size>0)--  the packet might be a fragment UDP packet
for instance, so tcphdr_len is not valid on those skbs.
