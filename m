From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Broken TX checksumming offloads
Date: Mon, 29 Nov 2010 19:17:42 +0100
Message-ID: <20101129181742.GA29192@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55587 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754840Ab0K2SRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 13:17:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Unless I'm horribly mistaken, generic HW checksumming works as follows:
 - driver sets netdev->features & NETIF_F_HW_CSUM to indicate support
   for generic checksumming; if the flag is not set, networking core
   will checksum skb before calling ndo_start_xmit (let's ignore
   other checksumming options for now) and not pass skb with
   skb->ip_summed =3D=3D CHECKSUM_PARTIAL
 - ndo_start_xmit() should use skb->csum_start and skb->csum_offset
   (or skb->csum) to update checksum in software or instruct HW to do s=
o

Looking at pch_gbe_xmit_frame() and its callee - pch_gbe_tx_queue() it
looks like the driver should set NETIF_F_IP_CSUM instead of NETIF_F_HW_=
CSUM
feature.

Similar thing happens in ixgbe driver: it sets NETIF_F_HW_CSUM and chec=
ks
for skb->ip_summed =3D=3D CHECKSUM_PARTIAL, but then just warns on prot=
ocols
other that TCP and SCTP (see: ixgbe_psum()).

This means that these drivers might send packets with broken checksums
when TX checksumming offload is enabled. I haven't checked other driver=
s, yet.

Best Regards,
Micha=B3 Miros=B3aw
