From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH net-next v3] candev: allow SJW user setting for bittiming
	calculation
Date: Wed, 28 Sep 2011 14:50:11 +0200
Message-ID: <4E831803.7020409@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for SJW user settings to not set the synchronization
jump width (SJW) to 1 in any case when using the in-kernel bittiming
calculation.

The ip-tool from iproute2 already supports to pass the user defined SJW
value. The given SJW value is sanitized with the controller specific sjw_max
and the calculated tseg2 value. As the SJW can have values up to 4 providing
this value will lead to the maximum possible SJW automatically. A higher SJW
allows higher controller oscillator tolerances.

Signed-off-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

---

v2: Resend due to wrong mail address header encoding.
v3: - Detected malformed patch format due to line break in function name
    - Added Acked-by: from Wolfgang Grandegger

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 9bf1116..25695bd 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -150,7 +150,19 @@ static int can_calc_bittiming(struct net_device *dev, struct can_bittiming *bt)
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
