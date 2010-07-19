From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] smsc911x: Add spinlocks around registers access
Date: Mon, 19 Jul 2010 13:42:51 +0100
Message-ID: <20100719123311.21558.37288.stgit@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:39669 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932109Ab0GSMm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 08:42:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On SMP systems, the SMSC911x registers may be accessed by multiple CPUs
and this seems to put the chip in an inconsistent state. The patch adds
spinlocks to the smsc911x_reg_read, smsc911x_reg_write,
smsc911x_rx_readfifo and smsc911x_tx_writefifo functions.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
Cc: stable@kernel.org
---

I've had this patch in my tree for some time. It's the only way I can
get the ARM SMP systems using this controller to work reliable. I
haven't got an ack from Steve yet but the only alternative is to mark
this driver BROKEN_ON_SMP and revert the ARM boards to use the old
smc911x.c driver.

Thanks.


 drivers/net/smsc911x.c |   92 +++++++++++++++++++++++++++---------------------
 1 files changed, 52 insertions(+), 40 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index cc55974..7a7b01a 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -84,8 +84,7 @@ struct smsc911x_data {
 	 */
 	spinlock_t mac_lock;
 
-	/* spinlock to ensure 16-bit accesses are serialised.
-	 * unused with a 32-bit bus */
+	/* spinlock to ensure register accesses are serialised */
 	spinlock_t dev_lock;
 
 	struct phy_device *phy_dev;
@@ -118,37 +117,33 @@ struct smsc911x_data {
 	unsigned int hashlo;
 };
 
-/* The 16-bit access functions are significantly slower, due to the locking
- * necessary.  If your bus hardware can be configured to do this for you
- * (in response to a single 32-bit operation from software), you should use
- * the 32-bit access functions instead. */
-
-static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
+static inline u32 __smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 {
 	if (pdata->config.flags & SMSC911X_USE_32BIT)
 		return readl(pdata->ioaddr + reg);
 
-	if (pdata->config.flags & SMSC911X_USE_16BIT) {
-		u32 data;
-		unsigned long flags;
-
-		/* these two 16-bit reads must be performed consecutively, so
-		 * must not be interrupted by our own ISR (which would start
-		 * another read operation) */
-		spin_lock_irqsave(&pdata->dev_lock, flags);
-		data = ((readw(pdata->ioaddr + reg) & 0xFFFF) |
+	if (pdata->config.flags & SMSC911X_USE_16BIT)
+		return ((readw(pdata->ioaddr + reg) & 0xFFFF) |
 			((readw(pdata->ioaddr + reg + 2) & 0xFFFF) << 16));
-		spin_unlock_irqrestore(&pdata->dev_lock, flags);
-
-		return data;
-	}
 
 	BUG();
 	return 0;
 }
 
-static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
-				      u32 val)
+static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
+{
+	u32 data;
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+	data = __smsc911x_reg_read(pdata, reg);
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+
+	return data;
+}
+
+static inline void __smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
+					u32 val)
 {
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
 		writel(val, pdata->ioaddr + reg);
@@ -156,44 +151,54 @@ static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_16BIT) {
-		unsigned long flags;
-
-		/* these two 16-bit writes must be performed consecutively, so
-		 * must not be interrupted by our own ISR (which would start
-		 * another read operation) */
-		spin_lock_irqsave(&pdata->dev_lock, flags);
 		writew(val & 0xFFFF, pdata->ioaddr + reg);
 		writew((val >> 16) & 0xFFFF, pdata->ioaddr + reg + 2);
-		spin_unlock_irqrestore(&pdata->dev_lock, flags);
 		return;
 	}
 
 	BUG();
 }
 
+static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
+				      u32 val)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+	__smsc911x_reg_write(pdata, reg, val);
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+}
+
 /* Writes a packet to the TX_DATA_FIFO */
 static inline void
 smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
 		      unsigned int wordcount)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+
 	if (pdata->config.flags & SMSC911X_SWAP_FIFO) {
 		while (wordcount--)
-			smsc911x_reg_write(pdata, TX_DATA_FIFO, swab32(*buf++));
-		return;
+			__smsc911x_reg_write(pdata, TX_DATA_FIFO,
+					     swab32(*buf++));
+		goto out;
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
 		writesl(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
-		return;
+		goto out;
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_16BIT) {
 		while (wordcount--)
-			smsc911x_reg_write(pdata, TX_DATA_FIFO, *buf++);
-		return;
+			__smsc911x_reg_write(pdata, TX_DATA_FIFO, *buf++);
+		goto out;
 	}
 
 	BUG();
+out:
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
 /* Reads a packet out of the RX_DATA_FIFO */
@@ -201,24 +206,31 @@ static inline void
 smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
 		     unsigned int wordcount)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+
 	if (pdata->config.flags & SMSC911X_SWAP_FIFO) {
 		while (wordcount--)
-			*buf++ = swab32(smsc911x_reg_read(pdata, RX_DATA_FIFO));
-		return;
+			*buf++ = swab32(__smsc911x_reg_read(pdata,
+							    RX_DATA_FIFO));
+		goto out;
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
 		readsl(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
-		return;
+		goto out;
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_16BIT) {
 		while (wordcount--)
-			*buf++ = smsc911x_reg_read(pdata, RX_DATA_FIFO);
-		return;
+			*buf++ = __smsc911x_reg_read(pdata, RX_DATA_FIFO);
+		goto out;
 	}
 
 	BUG();
+out:
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
 /* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read

