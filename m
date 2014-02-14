From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 04/10] ieee802154: support 100kbps QPSK/EU in at86rf230
Date: Fri, 14 Feb 2014 23:49:26 +0100
Message-ID: <1392418172-5305-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:44000 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbaBNW6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:58:31 -0500
In-Reply-To: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The standard assigns channel 0 on page 2 to be 100kbps QPSK in the
868.3MHz band. Add support to the at86rf230 driver for this channel and
page, at the moment predicated only for the RF212 chip.

Per the datasheet, configurations for page 0, channels 0 to 10 and page
2, channels 0 to 10 differ only in the BPSK_QPSK bit. Support for
channels 1 to 10 is untested.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index d2841b8..bc80ca93 100644
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
@@ -594,6 +595,13 @@ at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
 	if (rc < 0)
 		return rc;
 
+	if (page == 0)
+		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 0);
+	else
+		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 1);
+	if (rc < 0)
+		return rc;
+
 	return at86rf230_write_subreg(lp, SR_CHANNEL, channel);
 }
 
@@ -621,6 +629,7 @@ at86rf230_channel(struct ieee802154_dev *dev, int page, int channel)
 
 	msleep(1); /* Wait for PLL */
 	dev->phy->current_channel = channel;
+	dev->phy->current_page = page;
 
 	return 0;
 }
@@ -1065,10 +1074,12 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	spi_set_drvdata(spi, lp);
 
-	if (is_rf212(lp))
+	if (is_rf212(lp)) {
 		dev->phy->channels_supported[0] = 0x00007FF;
-	else
+		dev->phy->channels_supported[2] = 0x00007FF;
+	} else {
 		dev->phy->channels_supported[0] = 0x7FFF800;
+	}
 
 	rc = at86rf230_hw_init(lp);
 	if (rc)
-- 
1.8.5.4
