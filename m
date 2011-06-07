From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [PATCH] e100: Fix inconsistency in bad frames handling
Date: Mon, 6 Jun 2011 21:44:54 -0700
Message-ID: <20110606214454.4108aff4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrea Merello <andrea.merello@gmail.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60337 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750911Ab1FGEoI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 00:44:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 5 Jun 2011 03:14:49 +0200
=46rom: Andrea Merello <andrea.merello@gmail.com>
To: linux-kernel@vger.kernel.org
Subject: [PATCH] e100: Fix inconsistency in bad frames handling


Hello!

In e100 driver it seems that the intention was to accept bad frames in
promiscuous mode and loopback mode.
I think this is evident because of the following code in the driver:

if (nic->flags & promiscuous || nic->loopback) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0config->rx_save_bad_frames =3D 0x1; =A0 =
=A0 =A0 /* 1=3Dsave, 0=3Ddiscard */
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0config->rx_discard_short_frames =3D 0x0;=
 =A0/* 1=3Ddiscard, 0=3Dsave */
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0config->promiscuous_mode =3D 0x1; =A0 =A0=
 =A0 =A0 /* 1=3Don, 0=3Doff */
=A0 =A0 =A0 =A0}


However this intention is not really realized because bad frames are
discarded later by SW check.
This patch finally honors the above intention, making the RX code to
let bad frames to pass when the NIC is in promiscuous or loopback
mode.

This helped me a lot to debug an FPGA ethernet core.
Maybe it can be also useful to someone else..

Thanks
Andrea

=A0--- drivers/net/e100_orig.c =A0 =A0 2011-06-14 23:29:38.322267075 +0=
200
+++ drivers/net/e100.c =A02011-06-14 23:34:10.700791472 +0200
@@ -1975,7 +1975,8 @@ static int e100_rx_indicate(struct nic *
=A0 =A0 =A0 =A0skb_put(skb, actual_size);
=A0 =A0 =A0 =A0skb->protocol =3D eth_type_trans(skb, nic->netdev);

- =A0 =A0 =A0 if (unlikely(!(rfd_status & cb_ok))) {
+ =A0 =A0 =A0 if (unlikely(!(nic->flags & promiscuous || nic->loopback)=
 &&
+ =A0 =A0 =A0 =A0 =A0 !(rfd_status & cb_ok))) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Don't indicate if hardware indicates =
errors */
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb_any(skb);
=A0 =A0 =A0 =A0} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
