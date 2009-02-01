From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] net: variables reach -1, but 0 tested
Date: Sun, 01 Feb 2009 17:23:29 +0100
Message-ID: <4985CC81.1040801@gmail.com>
References: <498429AE.1080404@gmail.com> <1233434112.5903.28.camel@desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Daniel Walker <dwalker@fifo99.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:14099 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbZBAQXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 11:23:33 -0500
In-Reply-To: <1233434112.5903.28.camel@desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Walker wrote:
> On Sat, 2009-01-31 at 11:36 +0100, Roel Kluin wrote:
> 
>>  
>> -	while (limit--) {
>> +	while (--limit) {
>>  		val = phy_read(phy, MII_BMCR);
>>  		if (val >= 0 && (val & BMCR_RESET) == 0)
>>  			break;
> 
> It looks like these are checked for <= to 0 , are these changes strictly
> nessesary?

Although the chance that this goes wrong in practice is small, my change
was correct:

In the last iteration, limit is 1 when the test occurs, before the
decrement causes limit to become 0. If just then the break occurs,
we continue after the loop with:

        if ((val & BMCR_ISOLATE) && limit > 0)
                phy_write(phy, MII_BMCR, val & ~BMCR_ISOLATE);

        return limit <= 0;

Since limit is 0, the phy_write won't occur and the return is 1, this is
not desired, I assume.

With the prefix decrement limit is always greater than 0 when the break
occurs. I do agree that the chance that this goes wrong in practice could
be small.

>>  	/* make sure EEPROM has finished loading before setting GPIO_CFG */
>>  	timeout=1000;
>> -	while ( timeout-- && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
>> +	while ( --timeout && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
>>  		udelay(10);
> 
> If your doing "timeOut" to "timeout" below may as well drop the space
> above after the "(" ..

Ok, here it is again:

while (timeout--) { ... }

timeout becomes -1 if the loop isn't ended otherwise, not 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/ibm_newemac/phy.c |    4 ++--
 drivers/net/smc911x.c         |    4 ++--
 drivers/net/smsc9420.c        |   12 ++++++------
 drivers/net/sungem.c          |    2 +-
 drivers/net/sunqe.c           |    2 +-
 drivers/net/tsi108_eth.c      |    2 +-
 drivers/net/tulip/de2104x.c   |    2 +-
 7 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/phy.c
index c40cd8d..ac9d964 100644
--- a/drivers/net/ibm_newemac/phy.c
+++ b/drivers/net/ibm_newemac/phy.c
@@ -60,7 +60,7 @@ int emac_mii_reset_phy(struct mii_phy *phy)
 
 	udelay(300);
 
-	while (limit--) {
+	while (--limit) {
 		val = phy_read(phy, MII_BMCR);
 		if (val >= 0 && (val & BMCR_RESET) == 0)
 			break;
@@ -84,7 +84,7 @@ int emac_mii_reset_gpcs(struct mii_phy *phy)
 
 	udelay(300);
 
-	while (limit--) {
+	while (--limit) {
 		val = gpcs_phy_read(phy, MII_BMCR);
 		if (val >= 0 && (val & BMCR_RESET) == 0)
 			break;
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index bf3aa2a..223cde0 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -220,9 +220,9 @@ static void smc911x_reset(struct net_device *dev)
 
 	/* make sure EEPROM has finished loading before setting GPIO_CFG */
 	timeout=1000;
-	while ( timeout-- && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
+	while (--timeout && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_))
 		udelay(10);
-	}
+
 	if (timeout == 0){
 		PRINTK("%s: smc911x_reset timeout waiting for EEPROM busy\n", dev->name);
 		return;
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index c14a4c6..41f5303 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -498,7 +498,7 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 static void smsc9420_stop_tx(struct smsc9420_pdata *pd)
 {
 	u32 dmac_control, mac_cr, dma_intr_ena;
-	int timeOut = 1000;
+	int timeout = 1000;
 
 	/* disable TX DMAC */
 	dmac_control = smsc9420_reg_read(pd, DMAC_CONTROL);
@@ -506,13 +506,13 @@ static void smsc9420_stop_tx(struct smsc9420_pdata *pd)
 	smsc9420_reg_write(pd, DMAC_CONTROL, dmac_control);
 
 	/* Wait max 10ms for transmit process to stop */
-	while (timeOut--) {
+	while (--timeout) {
 		if (smsc9420_reg_read(pd, DMAC_STATUS) & DMAC_STS_TS_)
 			break;
 		udelay(10);
 	}
 
-	if (!timeOut)
+	if (!timeout)
 		smsc_warn(IFDOWN, "TX DMAC failed to stop");
 
 	/* ACK Tx DMAC stop bit */
@@ -596,7 +596,7 @@ static void smsc9420_free_rx_ring(struct smsc9420_pdata *pd)
 
 static void smsc9420_stop_rx(struct smsc9420_pdata *pd)
 {
-	int timeOut = 1000;
+	int timeout = 1000;
 	u32 mac_cr, dmac_control, dma_intr_ena;
 
 	/* mask RX DMAC interrupts */
@@ -617,13 +617,13 @@ static void smsc9420_stop_rx(struct smsc9420_pdata *pd)
 	smsc9420_pci_flush_write(pd);
 
 	/* wait up to 10ms for receive to stop */
-	while (timeOut--) {
+	while (--timeout) {
 		if (smsc9420_reg_read(pd, DMAC_STATUS) & DMAC_STS_RS_)
 			break;
 		udelay(10);
 	}
 
-	if (!timeOut)
+	if (!timeout)
 		smsc_warn(IFDOWN, "RX DMAC did not stop! timeout.");
 
 	/* ACK the Rx DMAC stop bit */
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 86c765d..b17efa9 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -148,7 +148,7 @@ static u16 __phy_read(struct gem *gp, int phy_addr, int reg)
 	cmd |= (MIF_FRAME_TAMSB);
 	writel(cmd, gp->regs + MIF_FRAME);
 
-	while (limit--) {
+	while (--limit) {
 		cmd = readl(gp->regs + MIF_FRAME);
 		if (cmd & MIF_FRAME_TALSB)
 			break;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 6e8f377..fe0c3f2 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -227,7 +227,7 @@ static int qe_init(struct sunqe *qep, int from_irq)
 	if (!(sbus_readb(mregs + MREGS_PHYCONFIG) & MREGS_PHYCONFIG_LTESTDIS)) {
 		int tries = 50;
 
-		while (tries--) {
+		while (--tries) {
 			u8 tmp;
 
 			mdelay(5);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 75461db..a9fd2b2 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1237,7 +1237,7 @@ static void tsi108_init_phy(struct net_device *dev)
 	spin_lock_irqsave(&phy_lock, flags);
 
 	tsi108_write_mii(data, MII_BMCR, BMCR_RESET);
-	while (i--){
+	while (--i) {
 		if(!(tsi108_read_mii(data, MII_BMCR) & BMCR_RESET))
 			break;
 		udelay(10);
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index d5d53b6..0bf2114 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -392,7 +392,7 @@ static void de_rx (struct de_private *de)
 	unsigned drop = 0;
 	int rc;
 
-	while (rx_work--) {
+	while (--rx_work) {
 		u32 status, len;
 		dma_addr_t mapping;
 		struct sk_buff *skb, *copy_skb;
