From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 4 2.6.7-bk6] pcnet32: acknowledge all interrupts early.
Date: Wed, 23 Jun 2004 14:13:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406232113.i5NLDcx16514@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A recent change I made broke pcnet32 in a way that allowed real hardware
to work, but broke VMWare.  This patch acknowledges all interrupts early
in the pcnet32_interrupt while loop.  Without this patch on real hardware
the first transmit operation would clear the 'init' interrupt, but in
VMWare it would rain interrupts.  Keith Moore did more testing for me
on VMWare and I did a better job testing on hardware.  Petr Vandrovec
correctly pointed out the source of the problem on lkml.

This patch is not needed for 2.4.27-rc1 unless my patch labeled
"pcnet32: recover after rx hang" is applied (which it has not).

signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.7-bk6/drivers/net/orig.pcnet32.c	Wed Jun 23 08:59:52 2004
+++ linux-2.6.7-bk6/drivers/net/pcnet32.c	Wed Jun 23 12:56:09 2004
@@ -1753,7 +1753,7 @@ pcnet32_interrupt(int irq, void *dev_id,
     spin_lock(&lp->lock);
 
     rap = lp->a.read_rap(ioaddr);
-    while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8600 && --boguscnt >= 0) {
+    while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8f00 && --boguscnt >= 0) {
 	if (csr0 == 0xffff) {
 	    break;			/* PCMCIA remove happened */
 	}

-- 
Don Fry
brazilnut@us.ibm.com
