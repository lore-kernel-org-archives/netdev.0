From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) acenic - don't spin forever in hard_start_xmit
Date: Mon, 20 Sep 2004 10:47:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920104724.2a5d2b47@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If driver is stuck due to ring full and hardware or link error, don't spin
forever in the hard_start_xmit routine.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-09-20 10:47:22 -07:00
+++ b/drivers/net/acenic.c	2004-09-20 10:47:22 -07:00
@@ -2499,6 +2499,7 @@
 	struct ace_regs __iomem *regs = ap->regs;
 	struct tx_desc *desc;
 	u32 idx, flagsize;
+	unsigned long maxjiff = jiffies + 3*HZ;
 
 restart:
 	idx = ap->tx_prd;
@@ -2602,7 +2603,7 @@
 	}
 
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 
 overflow:
 	/*
@@ -2621,8 +2622,15 @@
 	 * Alternative is to return with 1 not throttling queue. In this
 	 * case loop becomes longer, no more useful effects.
 	 */
-	barrier();
-	goto restart;
+	if (time_before(jiffies, maxjiff)) {
+		barrier();
+		cpu_relax();
+		goto restart;
+	}
+	
+	/* The ring is stuck full. */
+	printk(KERN_WARNING "%s: Transmit ring stuck full\n", dev->name);
+	return NETDEV_TX_BUSY;
 }
 
 
