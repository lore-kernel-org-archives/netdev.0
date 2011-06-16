From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netdev: bfin_mac: fix memory leak when freeing dma descriptors
Date: Thu, 16 Jun 2011 18:31:58 -0400
Message-ID: <1308263518-22724-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:40576 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180Ab1FPWb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2011 18:31:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

The size of the desc array is not the size of the desc structure, so
when we try to free up things, we leak some parts.

Reported-by: Regis Dargent <rdargent@edevice.com>
Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 68d45ba..6c019e1 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -52,13 +52,13 @@ MODULE_DESCRIPTION(DRV_DESC);
 MODULE_ALIAS("platform:bfin_mac");
 
 #if defined(CONFIG_BFIN_MAC_USE_L1)
-# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
-# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
+# define bfin_mac_alloc(dma_handle, size, num)  l1_data_sram_zalloc(size*num)
+# define bfin_mac_free(dma_handle, ptr, num)    l1_data_sram_free(ptr)
 #else
-# define bfin_mac_alloc(dma_handle, size) \
-	dma_alloc_coherent(NULL, size, dma_handle, GFP_KERNEL)
-# define bfin_mac_free(dma_handle, ptr) \
-	dma_free_coherent(NULL, sizeof(*ptr), ptr, dma_handle)
+# define bfin_mac_alloc(dma_handle, size, num) \
+	dma_alloc_coherent(NULL, size*num, dma_handle, GFP_KERNEL)
+# define bfin_mac_free(dma_handle, ptr, num) \
+	dma_free_coherent(NULL, sizeof(*ptr)*num, ptr, dma_handle)
 #endif
 
 #define PKT_BUF_SZ 1580
@@ -95,7 +95,7 @@ static void desc_list_free(void)
 				t = t->next;
 			}
 		}
-		bfin_mac_free(dma_handle, tx_desc);
+		bfin_mac_free(dma_handle, tx_desc, CONFIG_BFIN_TX_DESC_NUM);
 	}
 
 	if (rx_desc) {
@@ -109,7 +109,7 @@ static void desc_list_free(void)
 				r = r->next;
 			}
 		}
-		bfin_mac_free(dma_handle, rx_desc);
+		bfin_mac_free(dma_handle, rx_desc, CONFIG_BFIN_RX_DESC_NUM);
 	}
 }
 
@@ -126,13 +126,13 @@ static int desc_list_init(void)
 #endif
 
 	tx_desc = bfin_mac_alloc(&dma_handle,
-				sizeof(struct net_dma_desc_tx) *
+				sizeof(struct net_dma_desc_tx),
 				CONFIG_BFIN_TX_DESC_NUM);
 	if (tx_desc == NULL)
 		goto init_error;
 
 	rx_desc = bfin_mac_alloc(&dma_handle,
-				sizeof(struct net_dma_desc_rx) *
+				sizeof(struct net_dma_desc_rx),
 				CONFIG_BFIN_RX_DESC_NUM);
 	if (rx_desc == NULL)
 		goto init_error;
-- 
1.7.5.3

