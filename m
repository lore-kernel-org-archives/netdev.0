From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net] net: usbnet: fix tx_dropped statistics
Date: Thu, 31 Jan 2013 19:36:05 +0100
Message-ID: <1359657365-2879-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54010 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755795Ab3AaSgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 13:36:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is normal for minidrivers accumulating frames to return NULL
from their tx_fixup function. We do not want to count this as a
drop, or log any debug messages.  A different exit path is
therefore chosen for such drivers, skipping the debug message
and the tx_dropped increment.

The test for accumulating drivers was however completely bogus,
making the exit path selection depend on whether the user had
enabled tx_err logging or not. This would arbitrarily mess up
accounting for both accumulating and non-accumulating minidrivers,
and would result in unwanted debug messages for the accumulating
drivers.

=46ix by testing for FLAG_MULTI_PACKET instead, which probably was
the intention from the beginning.  This usage match the documented
behaviour of this flag:

 Indicates to usbnet, that USB driver accumulates multiple IP packets.
 Affects statistic (counters) and short packet handling.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/usbnet.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9778377..5e33606 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1125,13 +1125,11 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *=
skb,
 	if (info->tx_fixup) {
 		skb =3D info->tx_fixup (dev, skb, GFP_ATOMIC);
 		if (!skb) {
-			if (netif_msg_tx_err(dev)) {
-				netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
-				goto drop;
-			} else {
-				/* cdc_ncm collected packet; waits for more */
+			/* packet collected; minidriver waiting for more */
+			if (info->flags & FLAG_MULTI_PACKET)
 				goto not_drop;
-			}
+			netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
+			goto drop;
 		}
 	}
 	length =3D skb->len;
--=20
1.7.10.4
