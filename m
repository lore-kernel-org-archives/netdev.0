From: Don Fry <brazilnut@us.ibm.com>
Subject: [patch 2.4.25 15/15] pcnet32 non-mii link state fix
Date: Wed, 25 Feb 2004 12:10:25 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402252010.i1PKAPr21669@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch correctly returns the link state of an adapter which does not
have an MII.  Tested by myself and the patch author Thomas Munck Steenholdt
<tmus@tmus.dk>.

--- linux-2.4.25/drivers/net/debug.pcnet32.c	Wed Feb 25 11:55:25 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Wed Feb 25 11:56:44 2004
@@ -521,13 +521,17 @@
 {
     struct pcnet32_private *lp = dev->priv;
     unsigned long flags;
-    int r = 1;
+    int r;
 
+    spin_lock_irqsave(&lp->lock, flags);
     if (lp->mii) {
-	spin_lock_irqsave(&lp->lock, flags);
 	r = mii_link_ok(&lp->mii_if);
-	spin_unlock_irqrestore(&lp->lock, flags);
+    } else {
+	ulong ioaddr = dev->base_addr;	/* card base I/O address */
+	r = (lp->a.read_bcr(ioaddr, 4) != 0xc0);
     }
+    spin_unlock_irqrestore(&lp->lock, flags);
+
     return r;
 }
 

-- 
Don Fry
brazilnut@us.ibm.com
