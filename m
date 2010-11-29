From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Broken TX checksumming offloads
Date: Mon, 29 Nov 2010 19:13:23 +0000
Message-ID: <1291058003.20703.16.camel@bwh-desktop>
References: <20101129181742.GA29192@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	e1000-devel@lists.sourceforge.net
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50982 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab0K2TNa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 14:13:30 -0500
In-Reply-To: <20101129181742.GA29192@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-29 at 19:17 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Hi!
>=20
> Unless I'm horribly mistaken, generic HW checksumming works as follow=
s:
>  - driver sets netdev->features & NETIF_F_HW_CSUM to indicate support
>    for generic checksumming; if the flag is not set, networking core
>    will checksum skb before calling ndo_start_xmit (let's ignore
>    other checksumming options for now) and not pass skb with
>    skb->ip_summed =3D=3D CHECKSUM_PARTIAL
>  - ndo_start_xmit() should use skb->csum_start and skb->csum_offset
>    (or skb->csum) to update checksum in software or instruct HW to do=
 so
>=20
> Looking at pch_gbe_xmit_frame() and its callee - pch_gbe_tx_queue() i=
t
> looks like the driver should set NETIF_F_IP_CSUM instead of NETIF_F_H=
W_CSUM
> feature.
>
> Similar thing happens in ixgbe driver: it sets NETIF_F_HW_CSUM and ch=
ecks
> for skb->ip_summed =3D=3D CHECKSUM_PARTIAL, but then just warns on pr=
otocols
> other that TCP and SCTP (see: ixgbe_psum()).

AFAIK only {TCP,UDP}/IPv{4,6} use the simple 16-bit checksum algorithm
that NETIF_F_HW_CSUM implies, so in practice it is equivalent to
NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM even though it doesn't mean the sam=
e
thing.

Older kernel versions lacked a definititon of NETIF_F_IPV6_CSUM so
out-of-tree drivers and in-tree drivers that started out-of-tree are
likely to use NETIF_F_HW_CSUM as a workaround for that.

Since the minimum size of a {TCP,UDP}/IPv6/Ethernet frame is 62 bytes +
CRC, the workaround in pch_gbe_tx_queue() may not be needed for IPv6.
(I'm assuming that the critical length of 64 bytes actually includes th=
e
CRC, although the workaround code currently assumes otherwise.)

> This means that these drivers might send packets with broken checksum=
s
> when TX checksumming offload is enabled. I haven't checked other driv=
ers, yet.

They might or they might not; it's hard to tell without access to the
hardware.  But if the driver never references csum_{start,offset} then
it is probably valid to replace NETIF_F_HW_CSUM with NETIF_F_IP_CSUM |
NETIF_F_IPV6_CSUM (and similarly for the ethtool operations).

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

