From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 1/7] net: ethernet: ti: cpdma: am437x: allow descs to be plased in ddr
Date: Fri, 6 Jan 2017 14:07:29 -0600
Message-ID: <20170106200735.4210-2-grygorii.strashko@ti.com>
References: <20170106200735.4210-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:11068 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937982AbdAFUHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:07:40 -0500
In-Reply-To: <20170106200735.4210-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's observed that cpsw/cpdma is not working properly when CPPI
descriptors are placed in DDR instead of internal CPPI RAM on am437x
SoC:
- rx/tx silently stops processing packets;
- or - after boot it's working for sometime, but stuck once Network
load is increased (ping is working, but iperf is not).
(The same issue has not been reproduced on am335x and am57xx).

It seems that write to HDP register processed faster by interconnect
than writing of descriptor memory buffer in DDR, which is probably
caused by store buffer / write buffer differences as these functions
are implemented differently across devices. So, to fix this i come up
with two minimal, required changes:

1) all accesses to the channel register HDP/CP/RXFREE registers should
be done using sync IO accessors readl()/writel(), because all previous
memory writes writes have to be completed before starting channel
(write to HDP) or completing desc processing.

2) the change 1 only doesn't work on am437x and additional reading of
desc's field is required right after the new descriptor was filled
with data and before pointer on it will be stored in
prev_desc->hw_next field or HDP register.

In addition, to above changes this patch eliminates all relaxed ordering
I/O accessors in this driver as suggested by David Miller to avoid such
kind of issues in the future, but with one exception - relaxed IO accessors
will still be used to fill desc in cpdma_chan_submit(), which is safe as
there is read barrier at the end of write sequence, and because sync IO
accessors usage here will affect on net performance.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 40 ++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 36518fc..d6f0ded 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -166,12 +166,12 @@ static struct cpdma_control_info controls[] = {
 #define num_chan	params.num_chan
 
 /* various accessors */
-#define dma_reg_read(ctlr, ofs)		__raw_readl((ctlr)->dmaregs + (ofs))
-#define chan_read(chan, fld)		__raw_readl((chan)->fld)
-#define desc_read(desc, fld)		__raw_readl(&(desc)->fld)
-#define dma_reg_write(ctlr, ofs, v)	__raw_writel(v, (ctlr)->dmaregs + (ofs))
-#define chan_write(chan, fld, v)	__raw_writel(v, (chan)->fld)
-#define desc_write(desc, fld, v)	__raw_writel((u32)(v), &(desc)->fld)
+#define dma_reg_read(ctlr, ofs)		readl((ctlr)->dmaregs + (ofs))
+#define chan_read(chan, fld)		readl((chan)->fld)
+#define desc_read(desc, fld)		readl(&(desc)->fld)
+#define dma_reg_write(ctlr, ofs, v)	writel(v, (ctlr)->dmaregs + (ofs))
+#define chan_write(chan, fld, v)	writel(v, (chan)->fld)
+#define desc_write(desc, fld, v)	writel((u32)(v), &(desc)->fld)
 
 #define cpdma_desc_to_port(chan, mode, directed)			\
 	do {								\
@@ -542,10 +542,10 @@ int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 	}
 
 	for (i = 0; i < ctlr->num_chan; i++) {
-		__raw_writel(0, ctlr->params.txhdp + 4 * i);
-		__raw_writel(0, ctlr->params.rxhdp + 4 * i);
-		__raw_writel(0, ctlr->params.txcp + 4 * i);
-		__raw_writel(0, ctlr->params.rxcp + 4 * i);
+		writel(0, ctlr->params.txhdp + 4 * i);
+		writel(0, ctlr->params.rxhdp + 4 * i);
+		writel(0, ctlr->params.txcp + 4 * i);
+		writel(0, ctlr->params.rxcp + 4 * i);
 	}
 
 	dma_reg_write(ctlr, CPDMA_RXINTMASKCLEAR, 0xffffffff);
@@ -1061,13 +1061,17 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 	mode = CPDMA_DESC_OWNER | CPDMA_DESC_SOP | CPDMA_DESC_EOP;
 	cpdma_desc_to_port(chan, mode, directed);
 
-	desc_write(desc, hw_next,   0);
-	desc_write(desc, hw_buffer, buffer);
-	desc_write(desc, hw_len,    len);
-	desc_write(desc, hw_mode,   mode | len);
-	desc_write(desc, sw_token,  token);
-	desc_write(desc, sw_buffer, buffer);
-	desc_write(desc, sw_len,    len);
+	/* Relaxed IO accessors can be used here as there is read barrier
+	 * at the end of write sequence.
+	 */
+	writel_relaxed(0, &desc->hw_next);
+	writel_relaxed(buffer, &desc->hw_buffer);
+	writel_relaxed(len, &desc->hw_len);
+	writel_relaxed(mode | len, &desc->hw_mode);
+	writel_relaxed(token, &desc->sw_token);
+	writel_relaxed(buffer, &desc->sw_buffer);
+	writel_relaxed(len, &desc->sw_len);
+	desc_read(desc, sw_len);
 
 	__cpdma_chan_submit(chan, desc);
 
@@ -1136,7 +1140,7 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 	}
 	desc_dma = desc_phys(pool, desc);
 
-	status	= __raw_readl(&desc->hw_mode);
+	status	= desc_read(desc, hw_mode);
 	outlen	= status & 0x7ff;
 	if (status & CPDMA_DESC_OWNER) {
 		chan->stats.busy_dequeue++;
-- 
2.10.1.dirty
