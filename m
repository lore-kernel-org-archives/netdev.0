From: Grant Grundler <grundler@parisc-linux.org>
Subject: [PATCH] 2.6.25-rc4 de_stop_rxtx polling wrong
Date: Sat, 8 Mar 2008 18:33:16 -0700
Message-ID: <20080309013316.GD25083@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jgarzik@pobox.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:48761 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494AbYCIBd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2008 20:33:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,
This untested patch _should_ fix:
	"(net de2104x) Kernel panic with de2104x tulip driver on boot"	
	http://bugzilla.kernel.org/show_bug.cgi?id=3156

But the bug submitter isn't responding.  Same fix has been applied
to tulip.c (several years ago) and uli526x.c (Feb 2008) drivers.

Patch was originally against 2.6.23 but applies clean against 2.6.25-rc4.

[ The panic reported in the bug report was removed in a recently
  (march 2008) accepted patch from Ondrej Zary. ]


Signed-off-by: Grant Grundler <grundler@parisc-linux.org>


--- linux-2.6.23/drivers/net/tulip/de2104x.c	2007-10-09 13:31:38.000000000 -0700
+++ linux-2.6.23/drivers/net/tulip/de2104x.c-ggg	2007-11-02 23:24:46.000000000 -0700
@@ -842,7 +842,7 @@
 static void de_stop_rxtx (struct de_private *de)
 {
 	u32 macmode;
-	unsigned int work = 1000;
+	unsigned int i = 1300/100;
 
 	macmode = dr32(MacMode);
 	if (macmode & RxTx) {
@@ -850,10 +850,14 @@
 		dr32(MacMode);
 	}
 
-	while (--work > 0) {
+	/* wait until in-flight frame completes.
+	 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
+	 * Typically expect this loop to end in < 50 us on 100BT.
+	 */
+	while (--i) {
 		if (!de_is_running(de))
 			return;
-		cpu_relax();
+		udelay(100);
 	}
 
 	printk(KERN_WARNING "%s: timeout expired stopping DMA\n", de->dev->name);

