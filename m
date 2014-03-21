From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 2/3] Altera TSE: Correct typecast issue detected by kbuild test robot
Date: Thu, 20 Mar 2014 20:43:16 -0500
Message-ID: <1395366197-9781-3-git-send-email-vbridgers2013@gmail.com>
References: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:42074 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964895AbaCUBsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:48:03 -0400
Received: by mail-ob0-f181.google.com with SMTP id wp4so1807335obc.26
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 18:48:03 -0700 (PDT)
In-Reply-To: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses a portable pointer arithmetic issue in the
original submission found by the kbuild test robot.

config: make ARCH=i386 allyesconfig

   altera_sgdma.c: In function 'sgdma_txphysaddr':
>> altera_sgdma.c:393:33: warning: cast from
>> pointer to integer of different size [-Wpointer-to-int-cast]
     dma_addr_t offs = (dma_addr_t)((dma_addr_t)desc -
                                    ^
>> altera_sgdma.c:394:5: warning: cast from
>> pointer to integer of different size [-Wpointer-to-int-cast]
        (dma_addr_t)priv->tx_dma_desc);
        ^
   altera_sgdma.c: In function 'sgdma_rxphysaddr':
>> altera_sgdma.c:403:33: warning: cast from
>> pointer to integer of different size [-Wpointer-to-int-cast]
     dma_addr_t offs = (dma_addr_t)((dma_addr_t)desc -
                                    ^
>> altera_sgdma.c:404:5: warning: cast from
>> pointer to integer of different size [-Wpointer-to-int-cast]
        (dma_addr_t)priv->rx_dma_desc);
        ^

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/altera/altera_sgdma.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/ethernet/altera/altera_sgdma.c
index cbeee07..ebc4840 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -390,9 +390,8 @@ sgdma_txphysaddr(struct altera_tse_private *priv,
 		 struct sgdma_descrip *desc)
 {
 	dma_addr_t paddr = priv->txdescmem_busaddr;
-	dma_addr_t offs = (dma_addr_t)((dma_addr_t)desc -
-				(dma_addr_t)priv->tx_dma_desc);
-	return paddr + offs;
+	uintptr_t offs = (uintptr_t)desc - (uintptr_t)priv->tx_dma_desc;
+	return (dma_addr_t)((uintptr_t)paddr + offs);
 }
 
 static dma_addr_t
@@ -400,9 +399,8 @@ sgdma_rxphysaddr(struct altera_tse_private *priv,
 		 struct sgdma_descrip *desc)
 {
 	dma_addr_t paddr = priv->rxdescmem_busaddr;
-	dma_addr_t offs = (dma_addr_t)((dma_addr_t)desc -
-				(dma_addr_t)priv->rx_dma_desc);
-	return paddr + offs;
+	uintptr_t offs = (uintptr_t)desc - (uintptr_t)priv->rx_dma_desc;
+	return (dma_addr_t)((uintptr_t)paddr + offs);
 }
 
 #define list_remove_head(list, entry, type, member)			\
-- 
1.7.9.5
