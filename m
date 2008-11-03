From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 03/15] tg3: Preserve DASH connectivity when WOL enabled
Date: Mon, 3 Nov 2008 02:10:57 -0800
Message-ID: <1225751619.6172@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2838 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756612AbYKCWdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DASH firmware runs on the APE side of the chip, but it requires a few MAC
to be programmed correctly.

When WOL is enabled and management firmware is disabled, incoming
packets are evaluated and discarded at the chip's rule processor.
When management firmware is enabled, the hardware must be informed that
there are agents further up the stack that still use the incoming
frames.  Normally management firmware will configure the MAC correctly
on its own, but there can be cases where the setting could get clobbered
by the driver.  The first hunk of this patch preserves this setting.

The second hunk of this patch wipes out the driver present signature of
the APE memory space.  By doing so, the DASH firmware can assume
driver absent behavior.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   15 ++++++++++++++-
 drivers/net/tg3.h |    1 +
 2 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e129a6a..e04cd98 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2156,8 +2156,14 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			tw32(MAC_LED_CTRL, tp->led_ctrl);
 
 		if (pci_pme_capable(tp->pdev, state) &&
-		     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE))
+		     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)) {
 			mac_mode |= MAC_MODE_MAGIC_PKT_ENABLE;
+			if (((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+			    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) &&
+			    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
+			     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)))
+				mac_mode |= MAC_MODE_KEEP_FRAME_IN_WOL;
+		}
 
 		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
 			mac_mode |= tp->mac_mode &
@@ -5562,6 +5568,13 @@ static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
 			event = APE_EVENT_STATUS_STATE_START;
 			break;
 		case RESET_KIND_SHUTDOWN:
+			/* With the interface we are currently using,
+			 * APE does not track driver state.  Wiping
+			 * out the HOST SEGMENT SIGNATURE forces
+			 * the APE to assume OS absent status.
+			 */
+			tg3_ape_write32(tp, TG3_APE_HOST_SEG_SIG, 0x0);
+
 			event = APE_EVENT_STATUS_STATE_UNLOAD;
 			break;
 		case RESET_KIND_SUSPEND:
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 66055a9..65b5ff4 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -327,6 +327,7 @@
 #define  MAC_MODE_TDE_ENABLE		 0x00200000
 #define  MAC_MODE_RDE_ENABLE		 0x00400000
 #define  MAC_MODE_FHDE_ENABLE		 0x00800000
+#define  MAC_MODE_KEEP_FRAME_IN_WOL	 0x01000000
 #define  MAC_MODE_APE_RX_EN		 0x08000000
 #define  MAC_MODE_APE_TX_EN		 0x10000000
 #define MAC_STATUS			0x00000404
-- 
1.5.6.4



