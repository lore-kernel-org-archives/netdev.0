From: David Miller <davem@davemloft.net>
Subject: Re: [net:master 41/49] drivers/net/ethernet/cadence/macb.c:164:1:
 error: macro "writel" passed 3 arguments, but takes just 2
Date: Mon, 27 Jul 2015 14:25:21 -0700 (PDT)
Message-ID: <20150727.142521.968868804720368489.davem@davemloft.net>
References: <201507271704.JPi1M8WE%fengguang.wu@intel.com>
	<1437995273.29746.84.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, kbuild-all@01.org, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbbG0VZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:25:24 -0400
In-Reply-To: <1437995273.29746.84.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon, 27 Jul 2015 14:07:53 +0300

> I do use compiler from Debian for AVR32, didn't check this on other
> architectures.
> 
> Possible something like following will fix it:

That isn't going to fix it.  You misunderstand the nature of the problem
I think, the issue looks like this:

====================
#define readl(x, y)		((x) + (y))

struct foo {
	int (*readl)(int x, int y, int z);
};

int test(struct foo *p)
{
	p->readl(1, 2, 3);
}
====================

Archs typically define readl as a macro, so when you do things like
p->readl() CPP tries to expand the macro when it sees the "readl("
part, and that's the fundamental issue.

We have to rename the method names so that the macro expansion does't
interfere.

Here is the fix I am committing to fix this:

====================
[PATCH] macb: Fix build with macro'ized readl/writel.

If an architecture defines readl/writel using CPP macros, we
get the following kinds of build failure:

> > > drivers/net/ethernet/cadence/macb.c:164:1: error: macro "writel"
> > > passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA1B, bottom);
>     ^

Rename the methods so that this doesn't happen.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/cadence/macb.c | 14 +++++++-------
 drivers/net/ethernet/cadence/macb.h | 16 ++++++++--------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c638757..bf9eb2e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -506,7 +506,7 @@ static void macb_update_stats(struct macb *bp)
 	WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
 
 	for(; p < end; p++, offset += 4)
-		*p += bp->readl(bp, offset);
+		*p += bp->macb_reg_readl(bp, offset);
 }
 
 static int macb_halt_tx(struct macb *bp)
@@ -1934,14 +1934,14 @@ static void gem_update_stats(struct macb *bp)
 
 	for (i = 0; i < GEM_STATS_LEN; ++i, ++p) {
 		u32 offset = gem_statistics[i].offset;
-		u64 val = bp->readl(bp, offset);
+		u64 val = bp->macb_reg_readl(bp, offset);
 
 		bp->ethtool_stats[i] += val;
 		*p += val;
 
 		if (offset == GEM_OCTTXL || offset == GEM_OCTRXL) {
 			/* Add GEM_OCTTXH, GEM_OCTRXH */
-			val = bp->readl(bp, offset + 4);
+			val = bp->macb_reg_readl(bp, offset + 4);
 			bp->ethtool_stats[i] += ((u64)val) << 32;
 			*(++p) += val;
 		}
@@ -2867,11 +2867,11 @@ static int macb_probe(struct platform_device *pdev)
 	bp->regs = mem;
 	bp->native_io = native_io;
 	if (native_io) {
-		bp->readl = hw_readl_native;
-		bp->writel = hw_writel_native;
+		bp->macb_reg_readl = hw_readl_native;
+		bp->macb_reg_writel = hw_writel_native;
 	} else {
-		bp->readl = hw_readl;
-		bp->writel = hw_writel;
+		bp->macb_reg_readl = hw_readl;
+		bp->macb_reg_writel = hw_writel;
 	}
 	bp->num_queues = num_queues;
 	bp->queue_mask = queue_mask;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 2aa102e..1895b6b 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -429,12 +429,12 @@
 	 | GEM_BF(name, value))
 
 /* Register access macros */
-#define macb_readl(port, reg)		(port)->readl((port), MACB_##reg)
-#define macb_writel(port, reg, value)	(port)->writel((port), MACB_##reg, (value))
-#define gem_readl(port, reg)		(port)->readl((port), GEM_##reg)
-#define gem_writel(port, reg, value)	(port)->writel((port), GEM_##reg, (value))
-#define queue_readl(queue, reg)		(queue)->bp->readl((queue)->bp, (queue)->reg)
-#define queue_writel(queue, reg, value)	(queue)->bp->writel((queue)->bp, (queue)->reg, (value))
+#define macb_readl(port, reg)		(port)->macb_reg_readl((port), MACB_##reg)
+#define macb_writel(port, reg, value)	(port)->macb_reg_writel((port), MACB_##reg, (value))
+#define gem_readl(port, reg)		(port)->macb_reg_readl((port), GEM_##reg)
+#define gem_writel(port, reg, value)	(port)->macb_reg_writel((port), GEM_##reg, (value))
+#define queue_readl(queue, reg)		(queue)->bp->macb_reg_readl((queue)->bp, (queue)->reg)
+#define queue_writel(queue, reg, value)	(queue)->bp->macb_reg_writel((queue)->bp, (queue)->reg, (value))
 
 /* Conditional GEM/MACB macros.  These perform the operation to the correct
  * register dependent on whether the device is a GEM or a MACB.  For registers
@@ -782,8 +782,8 @@ struct macb {
 	bool			native_io;
 
 	/* hardware IO accessors */
-	u32	(*readl)(struct macb *bp, int offset);
-	void	(*writel)(struct macb *bp, int offset, u32 value);
+	u32	(*macb_reg_readl)(struct macb *bp, int offset);
+	void	(*macb_reg_writel)(struct macb *bp, int offset, u32 value);
 
 	unsigned int		rx_tail;
 	unsigned int		rx_prepared_head;
-- 
2.1.0
