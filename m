From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next v2] candev: allow SJW user setting for bittiming
 calculation
Date: Thu, 22 Sep 2011 12:28:54 +0200
Message-ID: <4E7B0DE6.9020807@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	=?windows-1252?Q?Pavel_P=ED=9Aa?= <pisa@cmp.felk.cvut.cz>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:41634 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710Ab1IVK3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 06:29:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for SJW user settings to not set the synchronization
jump width (SJW) to 1 in any case when using the in-kernel bittiming
calculation.

The ip-tool from iproute2 already supports to pass the user defined SJW
value. The given SJW value is sanitized with the controller specific sjw_max
and the calculated tseg2 value. As the SJW can have values up to 4 providing
this value will lead to the maximum possible SJW automatically. A higher SJW
allows higher controller oscillator tolerances.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

v2: Resend due to wrong mail address header encoding.

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 9bf1116..25695bd 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -150,7 +150,19 @@ static int can_calc_bittiming(struct net_device *dev,
struct can_bittiming *bt)
 	bt->prop_seg = tseg1 / 2;
 	bt->phase_seg1 = tseg1 - bt->prop_seg;
 	bt->phase_seg2 = tseg2;
-	bt->sjw = 1;
+
+	/* check for sjw user settings */
+	if (!bt->sjw || !btc->sjw_max)
+		bt->sjw = 1;
+	else {
+		/* bt->sjw is at least 1 -> sanitize upper bound to sjw_max */
+		if (bt->sjw > btc->sjw_max)
+			bt->sjw = btc->sjw_max;
+		/* bt->sjw must not be higher than tseg2 */
+		if (tseg2 < bt->sjw)
+			bt->sjw = tseg2;
+	}
+
 	bt->brp = best_brp;
 	/* real bit-rate */
 	bt->bitrate = priv->clock.freq / (bt->brp * (tseg1 + tseg2 + 1));
