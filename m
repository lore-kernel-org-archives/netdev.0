From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Fix an usage of streaming DMA API.
Date: Wed, 14 Mar 2007 01:02:20 +0900 (JST)
Message-ID: <20070314.010220.65192616.anemo@mba.ocn.ne.jp>
References: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:61751 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbXCMQCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 12:02:23 -0400
In-Reply-To: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tc35815 driver lacks a call to pci_dma_sync_single_for_device() on
receiving.  Recent fix of MIPS dma_sync_single_for_cpu() reveal this
bug.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
This patch can be applied to netdev-2.6 tree or 2.6.21-rc3-mm2.

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index ec888db..eed78b5 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -58,12 +58,13 @@
  *	1.34	Fix netpoll locking.  "BH rule" for NAPI is not enough with
  *		netpoll, hard_start_xmit might be called from irq context.
  *		PM support.
+ *	1.35	Fix an usage of streaming DMA API.
  */
 
 #ifdef TC35815_NAPI
-#define DRV_VERSION	"1.34-NAPI"
+#define DRV_VERSION	"1.35-NAPI"
 #else
-#define DRV_VERSION	"1.34"
+#define DRV_VERSION	"1.35"
 #endif
 static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #define MODNAME			"tc35815"
@@ -1551,6 +1552,11 @@ tc35815_rx(struct net_device *dev)
 							    PCI_DMA_FROMDEVICE);
 #endif
 				memcpy(data + offset, rxbuf, len);
+#ifdef TC35815_DMA_SYNC_ONDEMAND
+				pci_dma_sync_single_for_device(lp->pci_dev,
+							       dma, len,
+							       PCI_DMA_FROMDEVICE);
+#endif
 				offset += len;
 				cur_bd++;
 			}
