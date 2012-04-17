From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next] dmfe: enforce consistent timing delay.
Date: Tue, 17 Apr 2012 23:11:40 +0200
Message-ID: <20120417211140.GA12909@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Grant Grundler <grantgrundler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39485 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751024Ab2DQVQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 17:16:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not always use the same timing for what looks like
the same operations.

- DCR0
  Use the same udelay everywhere for reset. Upper bound is 100 us.
- DCR9
  Use 5us delay for srom clock. 1us delay for phy_write_1bit (writes
  PHY_DATA_[01]) are not changed as they stay withing a 2,5MHz MDIO
  clock range.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---

I noticed those while staring at the driver.

Grant, regarding your previous remarks, I do not see where the problem
could be with posted writes MMIO accesses:
- the driver has always used the first (#0) bar register. It's hardcoded.
  The driver still uses this same bar register.
- the driver has never checked whether bar #0 was related to I/O or
  memory space. It assumed an I/O decoder and issued out* instructions.
- the DM9102 datasheet states BAR #0 is an IO only BAR. No idea for the
  DM9132, 9100 and 9009 though.

My changes have replaced in/out* accesses with ioread/write* - mostly
to help detecting places where type checking would have uncloaked a
forgotten net_device.base_addr.

Thus, if someone has a dmfe device including a MMIO space decoder behind
bar #0, iowrite* will now emit memory write instructions where the driver
previously used I/O operations. It may not work very well due to posted
writes issues, sure. However I wonder on which platform - if any - the
former MMIO space + I/O accesses (!) combo would have behaved correctly.

?

 drivers/net/ethernet/dec/tulip/dmfe.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 0ef5b68..4d6fe60 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -767,7 +767,7 @@ static int dmfe_stop(struct DEVICE *dev)
 
 	/* Reset & stop DM910X board */
 	dw32(DCR0, DM910X_RESET);
-	udelay(5);
+	udelay(100);
 	phy_write(ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
 
 	/* free interrupt */
@@ -1601,7 +1601,9 @@ static u16 read_srom_word(void __iomem *ioaddr, int offset)
 	int i;
 
 	dw32(DCR9, CR9_SROM_READ);
+	udelay(5);
 	dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
+	udelay(5);
 
 	/* Send the Read Command 110b */
 	srom_clk_write(ioaddr, SROM_DATA_1);
@@ -1615,6 +1617,7 @@ static u16 read_srom_word(void __iomem *ioaddr, int offset)
 	}
 
 	dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
+	udelay(5);
 
 	for (i = 16; i > 0; i--) {
 		dw32(DCR9, CR9_SROM_READ | CR9_SRCS | CR9_SRCLK);
@@ -1626,6 +1629,7 @@ static u16 read_srom_word(void __iomem *ioaddr, int offset)
 	}
 
 	dw32(DCR9, CR9_SROM_READ);
+	udelay(5);
 	return srom_data;
 }
 
-- 
1.7.7.6
