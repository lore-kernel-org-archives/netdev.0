From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] lmc: Read outside array bounds
Date: Mon, 10 Aug 2009 13:29:52 +0200
Message-ID: <4A8004B0.5000504@gmail.com>
References: <4A6B84A9.7020506@gmail.com>	<20090728144307.c189810b.akpm@linux-foundation.org>	<4A7C401B.7090301@gmail.com> <20090809.212725.218498673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:63296 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbZHJL0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 07:26:04 -0400
Received: by ewy10 with SMTP id 10so2923208ewy.37
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 04:26:04 -0700 (PDT)
In-Reply-To: <20090809.212725.218498673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dev_alloc_skb() fails on the first iteration of the allocation loop,
then we end up writing before the start of the array.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
>>> First of all, if we allocated at least one buffer we should
>>> mark the last one in the code right after this loop.
>>>
>>> Second of all, we should purge the TX skbs in the next
>>> loop even if we could not allocate even one RX buffer.
>>>
>>> The thing to do is probably to guard the set of "[i-1]" RX ring
>>> accesses with a "if (i != 0)" check.
>> Forgot a bit about this one, but I hope this is what you meant?
> 
> It's not correct to limit the TX ring loop by how many RX
> ring buffers we've been able to successfully allocate,
> that doesn't make any sense.
> 
> I'm talking about the second loop which you unexplainably
> changed to "for (j = 0; j < i; ..."

Ok, I apparently completely misunderstood. One remaining question is whether
the base address should still be written if i is 0?

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 45b1822..8b61660 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1897,11 +1897,12 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
     /*
      * Sets end of ring
      */
-    sc->lmc_rxring[i - 1].length |= 0x02000000; /* Set end of buffers flag */
-    sc->lmc_rxring[i - 1].buffer2 = virt_to_bus (&sc->lmc_rxring[0]); /* Point back to the start */
+    if (i != 0) {
+        sc->lmc_rxring[i - 1].length |= 0x02000000; /* Set end of buffers flag */
+        sc->lmc_rxring[i - 1].buffer2 = virt_to_bus(&sc->lmc_rxring[0]); /* Point back to the start */
+    }
     LMC_CSR_WRITE (sc, csr_rxlist, virt_to_bus (sc->lmc_rxring)); /* write base address */
 
-
     /* Initialize the transmit rings and buffers */
     for (i = 0; i < LMC_TXDESCS; i++)
     {
