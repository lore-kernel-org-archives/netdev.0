From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 1/2] pcnet32: factor out pcnet32_clr_suspend()
Date: Mon, 13 Feb 2017 23:45:46 +0100
Message-ID: <1487025947-28867-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: <pcnet32@frontier.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the code to clear SUSPEND flag to a separate function to simplify
code.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/amd/pcnet32.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 41e58cc..ade3289 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1108,6 +1108,13 @@ static int pcnet32_suspend(struct net_device *dev, unsigned long *flags,
 	return 1;
 }
 
+static void pcnet32_clr_suspend(struct pcnet32_private *lp, ulong ioaddr)
+{
+	int csr5 = lp->a->read_csr(ioaddr, CSR5);
+	/* clear SUSPEND (SPND) - CSR5 bit 0 */
+	lp->a->write_csr(ioaddr, CSR5, csr5 & ~CSR5_SUSPEND);
+}
+
 /*
  * process one receive descriptor entry
  */
@@ -1430,13 +1437,8 @@ static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		}
 	}
 
-	if (!(csr0 & CSR0_STOP)) {	/* If not stopped */
-		int csr5;
-
-		/* clear SUSPEND (SPND) - CSR5 bit 0 */
-		csr5 = a->read_csr(ioaddr, CSR5);
-		a->write_csr(ioaddr, CSR5, csr5 & (~CSR5_SUSPEND));
-	}
+	if (!(csr0 & CSR0_STOP))	/* If not stopped */
+		pcnet32_clr_suspend(lp, ioaddr);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
@@ -2680,10 +2682,7 @@ static void pcnet32_set_multicast_list(struct net_device *dev)
 	}
 
 	if (suspended) {
-		int csr5;
-		/* clear SUSPEND (SPND) - CSR5 bit 0 */
-		csr5 = lp->a->read_csr(ioaddr, CSR5);
-		lp->a->write_csr(ioaddr, CSR5, csr5 & (~CSR5_SUSPEND));
+		pcnet32_clr_suspend(lp, ioaddr);
 	} else {
 		lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);
 		pcnet32_restart(dev, CSR0_NORMAL);
-- 
Ondrej Zary
