From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 04/10] net: smc911x: use io{read,write}*_rep accessors
Date: Tue, 11 Dec 2012 14:49:49 +0000
Message-ID: <20121211144949.GD16759@mudshark.cambridge.arm.com>
References: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
 <1355166762-15133-5-git-send-email-will.deacon@arm.com>
 <20121210.154705.1773845547652835423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"james.hogan@imgtec.com" <james.hogan@imgtec.com>,
	"matthew@mattleach.net" <matthew@mattleach.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121210.154705.1773845547652835423.davem@davemloft.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, Dec 10, 2012 at 08:47:05PM +0000, David Miller wrote:
> From: Will Deacon <will.deacon@arm.com>
> Date: Mon, 10 Dec 2012 19:12:36 +0000
> 
> > From: Matthew Leach <matthew@mattleach.net>
> > 
> > The {read,write}s{b,w,l} operations are not defined by all
> > architectures and are being removed from the asm-generic/io.h
> > interface.
> > 
> > This patch replaces the usage of these string functions in the smc911x
> > accessors with io{read,write}{8,16,32}_rep calls instead.
> > 
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Matthew Leach <matthew@mattleach.net>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> This misses the two uses in smsc911x_tx_writefifo and
> smsc911x_rx_readfifo.

Well spotted, updated patch below.

Cheers,

Will

--->8

>From b46e33465e755e945136d19938c9a8331cbafce7 Mon Sep 17 00:00:00 2001
From: Matthew Leach <matthew@mattleach.net>
Date: Tue, 6 Nov 2012 14:51:11 +0000
Subject: [PATCH v3] net: smc911x: use io{read,write}*_rep accessors

The {read,write}s{b,w,l} operations are not defined by all
architectures and are being removed from the asm-generic/io.h
interface.

This patch replaces the usage of these string functions in the smc911x
accessors with io{read,write}{8,16,32}_rep calls instead.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Matthew Leach <matthew@mattleach.net>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 drivers/net/ethernet/smsc/smc911x.h  | 16 ++++++++--------
 drivers/net/ethernet/smsc/smsc911x.c |  8 ++++----
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
index 3269292..d51261b 100644
--- a/drivers/net/ethernet/smsc/smc911x.h
+++ b/drivers/net/ethernet/smsc/smc911x.h
@@ -159,12 +159,12 @@ static inline void SMC_insl(struct smc911x_local *lp, int reg,
 	void __iomem *ioaddr = lp->base + reg;
 
 	if (lp->cfg.flags & SMC911X_USE_32BIT) {
-		readsl(ioaddr, addr, count);
+		ioread32_rep(ioaddr, addr, count);
 		return;
 	}
 
 	if (lp->cfg.flags & SMC911X_USE_16BIT) {
-		readsw(ioaddr, addr, count * 2);
+		ioread16_rep(ioaddr, addr, count * 2);
 		return;
 	}
 
@@ -177,12 +177,12 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 	void __iomem *ioaddr = lp->base + reg;
 
 	if (lp->cfg.flags & SMC911X_USE_32BIT) {
-		writesl(ioaddr, addr, count);
+		iowrite32_rep(ioaddr, addr, count);
 		return;
 	}
 
 	if (lp->cfg.flags & SMC911X_USE_16BIT) {
-		writesw(ioaddr, addr, count * 2);
+		iowrite16_rep(ioaddr, addr, count * 2);
 		return;
 	}
 
@@ -196,14 +196,14 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 		 writew(v & 0xFFFF, (lp)->base + (r));	 \
 		 writew(v >> 16, (lp)->base + (r) + 2); \
 	 } while (0)
-#define SMC_insl(lp, r, p, l)	 readsw((short*)((lp)->base + (r)), p, l*2)
-#define SMC_outsl(lp, r, p, l)	 writesw((short*)((lp)->base + (r)), p, l*2)
+#define SMC_insl(lp, r, p, l)	 ioread16_rep((short*)((lp)->base + (r)), p, l*2)
+#define SMC_outsl(lp, r, p, l)	 iowrite16_rep((short*)((lp)->base + (r)), p, l*2)
 
 #elif	SMC_USE_32BIT
 #define SMC_inl(lp, r)		 readl((lp)->base + (r))
 #define SMC_outl(v, lp, r)	 writel(v, (lp)->base + (r))
-#define SMC_insl(lp, r, p, l)	 readsl((int*)((lp)->base + (r)), p, l)
-#define SMC_outsl(lp, r, p, l)	 writesl((int*)((lp)->base + (r)), p, l)
+#define SMC_insl(lp, r, p, l)	 ioread32_rep((int*)((lp)->base + (r)), p, l)
+#define SMC_outsl(lp, r, p, l)	 iowrite32_rep((int*)((lp)->base + (r)), p, l)
 
 #endif /* SMC_USE_16BIT */
 #endif /* SMC_DYNAMIC_BUS_CONFIG */
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index c53c0f4..9d46167 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -253,7 +253,7 @@ smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
-		writesl(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
+		iowrite32_rep(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
 		goto out;
 	}
 
@@ -285,7 +285,7 @@ smsc911x_tx_writefifo_shift(struct smsc911x_data *pdata, unsigned int *buf,
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
-		writesl(pdata->ioaddr + __smsc_shift(pdata,
+		iowrite32_rep(pdata->ioaddr + __smsc_shift(pdata,
 						TX_DATA_FIFO), buf, wordcount);
 		goto out;
 	}
@@ -319,7 +319,7 @@ smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
-		readsl(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
+		ioread32_rep(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
 		goto out;
 	}
 
@@ -351,7 +351,7 @@ smsc911x_rx_readfifo_shift(struct smsc911x_data *pdata, unsigned int *buf,
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
-		readsl(pdata->ioaddr + __smsc_shift(pdata,
+		ioread32_rep(pdata->ioaddr + __smsc_shift(pdata,
 						RX_DATA_FIFO), buf, wordcount);
 		goto out;
 	}
-- 
1.8.0
