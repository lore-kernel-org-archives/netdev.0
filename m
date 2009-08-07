From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] lmc: Read outside array bounds
Date: Fri, 07 Aug 2009 16:54:19 +0200
Message-ID: <4A7C401B.7090301@gmail.com>
References: <4A6B84A9.7020506@gmail.com> <20090728144307.c189810b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, khc@pm.waw.pl,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:33687 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbZHGOut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 10:50:49 -0400
Received: by ewy10 with SMTP id 10so1588910ewy.37
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 07:50:48 -0700 (PDT)
In-Reply-To: <20090728144307.c189810b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dev_alloc_skb() fails on the first iteration of the allocation loop, and we
break out of the loop, then we end up writing before the start of the array.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
> First of all, if we allocated at least one buffer we should
> mark the last one in the code right after this loop.
> 
> Second of all, we should purge the TX skbs in the next
> loop even if we could not allocate even one RX buffer.
>
> The thing to do is probably to guard the set of "[i-1]" RX ring
> accesses with a "if (i != 0)" check.

Forgot a bit about this one, but I hope this is what you meant?

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 45b1822..b26fabb 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1838,7 +1838,7 @@ void lmc_mii_writereg (lmc_softc_t * const sc, unsigned devaddr, unsigned regno,
 
 static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
 {
-    int i;
+    int i, j;
 
     lmc_trace(sc->lmc_device, "lmc_softreset in");
 
@@ -1897,24 +1897,27 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
     /*
      * Sets end of ring
      */
-    sc->lmc_rxring[i - 1].length |= 0x02000000; /* Set end of buffers flag */
-    sc->lmc_rxring[i - 1].buffer2 = virt_to_bus (&sc->lmc_rxring[0]); /* Point back to the start */
-    LMC_CSR_WRITE (sc, csr_rxlist, virt_to_bus (sc->lmc_rxring)); /* write base address */
+    if (i > 0) {
+        sc->lmc_rxring[i - 1].length |= 0x02000000; /* Set end of buffers flag */
+        sc->lmc_rxring[i - 1].buffer2 = virt_to_bus(&sc->lmc_rxring[0]); /* Point back to the start */
+        LMC_CSR_WRITE(sc, csr_rxlist, virt_to_bus(sc->lmc_rxring)); /* write base address */
+    }
 
 
     /* Initialize the transmit rings and buffers */
-    for (i = 0; i < LMC_TXDESCS; i++)
-    {
-        if (sc->lmc_txq[i] != NULL){		/* have buffer */
-            dev_kfree_skb(sc->lmc_txq[i]);	/* free it */
+    for (j = 0; j < i; j++) {
+        if (sc->lmc_txq[j] != NULL) {		/* have buffer */
+            dev_kfree_skb(sc->lmc_txq[j]);	/* free it */
 	    sc->lmc_device->stats.tx_dropped++;	/* We just dropped a packet */
         }
-        sc->lmc_txq[i] = NULL;
-        sc->lmc_txring[i].status = 0x00000000;
-        sc->lmc_txring[i].buffer2 = virt_to_bus (&sc->lmc_txring[i + 1]);
+        sc->lmc_txq[j] = NULL;
+        sc->lmc_txring[j].status = 0x00000000;
+        sc->lmc_txring[j].buffer2 = virt_to_bus(&sc->lmc_txring[j + 1]);
+    }
+    if (j > 0) {
+        sc->lmc_txring[j - 1].buffer2 = virt_to_bus(&sc->lmc_txring[0]);
+        LMC_CSR_WRITE(sc, csr_txlist, virt_to_bus(sc->lmc_txring));
     }
-    sc->lmc_txring[i - 1].buffer2 = virt_to_bus (&sc->lmc_txring[0]);
-    LMC_CSR_WRITE (sc, csr_txlist, virt_to_bus (sc->lmc_txring));
 
     lmc_trace(sc->lmc_device, "lmc_softreset out");
 }
