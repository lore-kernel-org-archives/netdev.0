From: Pierre TARDY <pierre.tardy@freescale.com>
Subject: [PATCH] smc911x
Date: Tue, 19 Dec 2006 18:02:57 +0100
Message-ID: <45881B41.1070109@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030907080104010900080205"
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:57378 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932851AbWLSR2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 12:28:15 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id kBJIPfuH005381
	for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 11:25:41 -0700 (MST)
Received: from [10.160.40.122] ([10.160.40.122])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id kBJH2vUG012930
	for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 11:02:58 -0600 (CST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030907080104010900080205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Attached a patch on smc911x driver, which corrects obvious errors in the 
16bit chips support of this driver.

Please note that this driver still do NOT support 16bit chips (9115 and 
9117), as it claims to, there may be mistakes in the data fifo 
managment, this patch enable the driver to init the chip, but the data 
is then corrupted.

I managed to make my chip work with the driver smsc911x (out of the 
box), from smsc, which has been refused to be included in the kernel tree.
http://thread.gmane.org/gmane.linux.network.general/10498/focus=40384

I think it my be a good idea to reconsider this choice
- smsc911x has more chance to be supported as it has originally been 
made by the manufacturer of the chip.
- smc911x is mono chip (do not work with 9117 at least), mono arch and 
mono plateform (restricted to PXA), while smsc911x has been tested on 
various chips by smsc

The only thing that is missing in smsc911x is dma support, which is very 
architecture dependant ( There is one way to do dma with the pxa, 
another on the freescale mxc plateforms, another on the x86..)

-- 
Pierre Tardy


--------------030907080104010900080205
Content-Type: text/x-patch;
 name="smc911x_16bit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="smc911x_16bit.patch"

--- linux-2.6.18.1.orig/drivers/net/smc911x.h	2006-10-14 05:34:03.000000000 +0200
+++ linux-2.6.18.1/drivers/net/smc911x.h	2006-12-19 11:22:39.000000000 +0100
@@ -46,13 +46,13 @@
 #if	SMC_USE_16BIT
 #define SMC_inb(a, r)			 readb((a) + (r))
 #define SMC_inw(a, r)			 readw((a) + (r))
-#define SMC_inl(a, r)			 ((SMC_inw(a, r) & 0xFFFF)+(SMC_inw(a+2, r)<<16))
+#define SMC_inl(a, r)			 ((SMC_inw(a, r) & 0xFFFF)|(SMC_inw(a+2, r)<<16))
 #define SMC_outb(v, a, r)		 writeb(v, (a) + (r))
 #define SMC_outw(v, a, r)		 writew(v, (a) + (r))
 #define SMC_outl(v, a, r) 			 \
 	do{					 \
-		 writel(v & 0xFFFF, (a) + (r));	 \
-		 writel(v >> 16, (a) + (r) + 2); \
+		 writew((v) & 0xFFFF, (a) + (r));	 \
+		 writew((v) >> 16, (a) + (r) + 2); \
 	 } while (0)
 #define SMC_insl(a, r, p, l)	 readsw((short*)((a) + (r)), p, l*2)
 #define SMC_outsl(a, r, p, l)	 writesw((short*)((a) + (r)), p, l*2)

--------------030907080104010900080205--
