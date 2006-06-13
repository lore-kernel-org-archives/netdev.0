From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.18 3/6] bnx2: Use CPU native page size
Date: Tue, 13 Jun 2006 11:19:42 -0700
Message-ID: <1150222782.26368.34.camel@rh4>
References: <1150157833.26173.8.camel@rh4>
 <20060612.222036.15588314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:20494 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932204AbWFMSTA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 14:19:00 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060612.222036.15588314.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-12 at 22:20 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Mon, 12 Jun 2006 17:17:13 -0700
> 
> > Use CPU native page size to determine various ring sizes. This allows
> > order-0 memory allocations on all systems.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Are you sure you want to do this when the base page size is up to 64K
> on some IA64/PowerPC64/Sparc64 configurations?
> 
> Maybe you can use a limit with some ifdef tests, something like:
> 
> #if PAGE_SHIFT > 13
> #define BCM_PAGE_BITS 13
> #else
> #define BCM_PAGE_BITS PAGE_SHIFT
> #endif
> 
> which would limit it to 8K.
> 
Yes, this makes sense. Here's the revised patch:

Use CPU native page size to determine various ring sizes. This allows
order-0 memory allocations on all systems.

Added check to limit the page size to 16K since that's the maximum rx
ring size that will be used. This will prevent using unnecessarily
large page sizes on some architectures with large page sizes.
[Suggested by David Miller]

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 49c09da..cefb129 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -32,6 +32,7 @@
 #include <asm/irq.h>
 #include <linux/delay.h>
 #include <asm/byteorder.h>
+#include <asm/page.h>
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index ea1ab06..69cebd9 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -3750,7 +3750,12 @@ struct l2_fhdr {
 #define DMA_READ_CHANS	5
 #define DMA_WRITE_CHANS	3
 
-#define BCM_PAGE_BITS	12
+/* Use CPU native page size up to 16K for the ring sizes.  */
+#if (PAGE_SHIFT > 14)
+#define BCM_PAGE_BITS	14
+#else
+#define BCM_PAGE_BITS	PAGE_SHIFT
+#endif
 #define BCM_PAGE_SIZE	(1 << BCM_PAGE_BITS)
 
 #define TX_DESC_CNT  (BCM_PAGE_SIZE / sizeof(struct tx_bd))
@@ -3773,7 +3778,7 @@ struct l2_fhdr {
 
 #define RX_RING_IDX(x) ((x) & bp->rx_max_ring_idx)
 
-#define RX_RING(x) (((x) & ~MAX_RX_DESC_CNT) >> 8)
+#define RX_RING(x) (((x) & ~MAX_RX_DESC_CNT) >> (BCM_PAGE_BITS - 4))
 #define RX_IDX(x) ((x) & MAX_RX_DESC_CNT)
 
 /* Context size. */


