From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 1/1] ethernet: dm9000 driver: davicom: upgrade driver
Date: Wed, 27 Mar 2013 06:42:54 +0000 (UTC)
Message-ID: <315925806-1352-1-git-send-email-josright123__11033.582504797$1364366602$gmane$org__18749.7050197393$1364366602$gmane$org@gmail.com>
Cc: linux-kernel@vger.kernel.org, Joseph CHANG <josright123@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Matthew Leach <matthew@mattleach.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joseph CHANG <joseph_chang@davicom.com.tw>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:62499 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab3C0Gmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 02:42:38 -0400
Date: Sat,  5 Jan 1980 21:10:06 +0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixing bug for DM9000B which is a DSP revision!

Had tested to Davicom DM9000 series include DM9000E(analog),
DM9000A(analog), DM9000B(dsp) and DM9000C(dsp) in X86 and
ARM Embedded Linux these years.

Signed-off-by: Joseph CHANG <josright123@gmail.com>
---
 drivers/net/ethernet/davicom/dm9000.c |   12 ++++++++++--
 drivers/net/ethernet/davicom/dm9000.h |   11 ++++++++++-
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 8cdf025..252f1da 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -47,7 +47,7 @@
 #define DM9000_PHY		0x40	/* PHY address 0x01 */
 
 #define CARDNAME	"dm9000"
-#define DRV_VERSION	"1.31"
+#define DRV_VERSION	"1.39"
 
 /*
  * Transmit timeout, default 5 seconds.
@@ -795,6 +795,8 @@ dm9000_init_dm9000(struct net_device *dev)
 
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
 
+	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET); /* PHY RESET */
+
 	ncr = (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
 
 	/* if wol is needed, then always set NCR_WAKEEN otherwise we end
@@ -830,6 +832,8 @@ dm9000_init_dm9000(struct net_device *dev)
 	db->tx_pkt_cnt = 0;
 	db->queue_pkt_len = 0;
 	dev->trans_start = jiffies;
+
+	dm9000_phy_write(dev, 0, MII_DM_DSPCR, DSPCR_INIT_PARAM); /* Init */
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -1502,7 +1506,11 @@ dm9000_probe(struct platform_device *pdev)
 	db->flags |= DM9000_PLATF_SIMPLE_PHY;
 #endif
 
-	dm9000_reset(db);
+	/* Fixing bug on dm9000_probe, takeover dm9000_reset(db),
+	 * Need 'NCR_MAC_LBK' bit to indeed stable our DM9000 fifo
+	 * while probe stage */
+
+	iow(db, DM9000_NCR, NCR_MAC_LBK | NCR_RST);
 
 	/* try multiple times, DM9000 sometimes gets the read wrong */
 	for (i = 0; i < 8; i++) {
diff --git a/drivers/net/ethernet/davicom/dm9000.h b/drivers/net/ethernet/davicom/dm9000.h
index 55688bd..9ce058a 100644
--- a/drivers/net/ethernet/davicom/dm9000.h
+++ b/drivers/net/ethernet/davicom/dm9000.h
@@ -69,7 +69,9 @@
 #define NCR_WAKEEN          (1<<6)
 #define NCR_FCOL            (1<<4)
 #define NCR_FDX             (1<<3)
-#define NCR_LBK             (3<<1)
+
+#define NCR_RESERVED        (3<<1)
+#define NCR_MAC_LBK         (1<<1)
 #define NCR_RST	            (1<<0)
 
 #define NSR_SPEED           (1<<7)
@@ -167,5 +169,12 @@
 #define ISR_LNKCHNG		(1<<5)
 #define ISR_UNDERRUN		(1<<4)
 
+/* Davicom MII registers.
+ */
+
+#define MII_DM_DSPCR		0x1b    /* DSP Control Register */
+
+#define DSPCR_INIT_PARAM	0xE100	/* DSP init parameter */
+
 #endif /* _DM9000X_H_ */
 
-- 
1.7.1
