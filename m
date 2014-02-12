From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 04/10] ieee802154: support
	100kbps QPSK/EU in at86rf230
Date: Wed, 12 Feb 2014 17:37:08 +0100
Message-ID: <1392223034-19955-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1392223034-19955-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The standard assigns channel 0 on page 2 to be 100kbps QPSK in the
868.3MHz band. Add support to the at86rf230 driver for this channel and
page, at the moment predicated only for the RF212 chip.

Per the datasheet, configurations for page 0, channels 0 to 10 and page
2, channels 0 to 10 differ only in the BPSK_QPSK bit. Support for
channels 1 to 10 is untested.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 99bc822..f6338c4 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -106,7 +106,8 @@ static inline int is_rf212(struct at86rf230_local *local)
 #define	SR_OQPSK_DATA_RATE	0x0c, 0x03, 0
 #define	SR_SUB_MODE		0x0c, 0x04, 2
 #define	SR_BPSK_QPSK		0x0c, 0x08, 3
-#define	SR_RESERVED_0c_4	0x0c, 0x70, 4
+#define	SR_OQPSK_SUB1_RC_EN	0x0c, 0x10, 4
+#define	SR_RESERVED_0c_5	0x0c, 0x60, 5
 #define	SR_RX_SAFE_MODE		0x0c, 0x80, 7
 #define	RG_ANT_DIV	(0x0d)
 #define	SR_ANT_CTRL		0x0d, 0x03, 0
@@ -595,6 +596,14 @@ at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
 	if (rc < 0)
 		return rc;
 
+	if (page == 0)
+		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 0);
+	else
+		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 1);
+
+	if (rc < 0)
+		return rc;
+
 	return at86rf230_write_subreg(lp, SR_CHANNEL, channel);
 }
 
@@ -623,6 +632,7 @@ at86rf230_channel(struct ieee802154_dev *dev, int page, int channel)
 
 	msleep(1); /* Wait for PLL */
 	dev->phy->current_channel = channel;
+	dev->phy->current_page = page;
 
 	return 0;
 }
@@ -1067,9 +1077,10 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	spi_set_drvdata(spi, lp);
 
-	if (is_rf212(lp))
+	if (is_rf212(lp)) {
 		dev->phy->channels_supported[0] = 0x00007FF;
-	else
+		dev->phy->channels_supported[2] = 0x00007FF;
+	} else
 		dev->phy->channels_supported[0] = 0x7FFF800;
 
 	rc = at86rf230_hw_init(lp);
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
