From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.3] pcnet32.c non-mii errors with ethtool
Date: Fri, 20 Feb 2004 14:29:30 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402202229.i1KMTVe07355@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pcnet32 devices which do not contain an mii respond incorrectly to
ethtool commands.

Reported by VANDROVE@vc.cvut.cz and Thomas Munck Steenholdt.

--- linux-2.6.3/drivers/net/clean.pcnet32.c	Fri Feb 20 10:59:38 2004
+++ linux-2.6.3/drivers/net/pcnet32.c	Fri Feb 20 14:21:27 2004
@@ -474,22 +474,28 @@
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long flags;
+	int r = -EOPNOTSUPP;
 
-	spin_lock_irqsave(&lp->lock, flags);
-	mii_ethtool_gset(&lp->mii_if, cmd);
-	spin_unlock_irqrestore(&lp->lock, flags);
-	return 0;
+	if (lp->mii) {
+	    spin_lock_irqsave(&lp->lock, flags);
+	    mii_ethtool_gset(&lp->mii_if, cmd);
+	    spin_unlock_irqrestore(&lp->lock, flags);
+	    r = 0;
+	}
+	return r;
 }
 
 static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long flags;
-	int r;
+	int r = -EOPNOTSUPP;
 
-	spin_lock_irqsave(&lp->lock, flags);
-	r = mii_ethtool_sset(&lp->mii_if, cmd);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	if (lp->mii) {
+	    spin_lock_irqsave(&lp->lock, flags);
+	    r = mii_ethtool_sset(&lp->mii_if, cmd);
+	    spin_unlock_irqrestore(&lp->lock, flags);
+	}
 	return r;
 }
 
@@ -509,11 +515,13 @@
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long flags;
-	int r;
+	int r = 1;
 
-	spin_lock_irqsave(&lp->lock, flags);
-	r = mii_link_ok(&lp->mii_if);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	if (lp->mii) {
+	    spin_lock_irqsave(&lp->lock, flags);
+	    r = mii_link_ok(&lp->mii_if);
+	    spin_unlock_irqrestore(&lp->lock, flags);
+	}
 	return r;
 }
 
@@ -533,11 +541,13 @@
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long flags;
-	int r;
+	int r = -EOPNOTSUPP;
 
-	spin_lock_irqsave(&lp->lock, flags);
-	r = mii_nway_restart(&lp->mii_if);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	if (lp->mii) {
+	    spin_lock_irqsave(&lp->lock, flags);
+	    r = mii_nway_restart(&lp->mii_if);
+	    spin_unlock_irqrestore(&lp->lock, flags);
+	}
 	return r;
 }
 

-- 
Don Fry
brazilnut@us.ibm.com
