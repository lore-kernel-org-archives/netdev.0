From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.6.3 pcnet32.c bus master arbitration failure fix
Date: Wed, 18 Feb 2004 14:29:27 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402182229.i1IMTRA03869@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the first of several individual patches to 2.6.3 for the pcnet32
driver.

The driver did not properly serialize accesses to chip registers, resulting
in reading/writing the wrong register.  This patch eliminates this problem
and gets rid of the cause of the symptom of 'bus master arbitration failure'.

It was easier to use generic_mii_ioctl than modify the current pcnet32_ioctl
routine with the necessary locks.  This has been re-tested on an IA32 system.


--- linux-2.6.3/drivers/net/orig.pcnet32.c	Tue Feb 17 19:57:21 2004
+++ linux-2.6.3/drivers/net/pcnet32.c	Wed Feb 18 12:35:33 2004
@@ -720,6 +720,8 @@
     lp->name = chipname;
     lp->shared_irq = shared;
     lp->mii_if.full_duplex = fdx;
+    lp->mii_if.phy_id_mask = 0x1f;
+    lp->mii_if.reg_num_mask = 0x1f;
     lp->dxsuflo = dxsuflo;
     lp->ltint = ltint;
     lp->mii = mii;
@@ -1625,12 +1627,18 @@
 	}
 	/* restart autonegotiation */
 	case ETHTOOL_NWAY_RST: {
-		return mii_nway_restart(&lp->mii_if);
+		int r;
+		spin_lock_irq(&lp->lock);
+		r = mii_nway_restart(&lp->mii_if);
+		spin_unlock_irq(&lp->lock);
+		return r;
 	}
 	/* get link status */
 	case ETHTOOL_GLINK: {
 		struct ethtool_value edata = {ETHTOOL_GLINK};
+		spin_lock_irq(&lp->lock);
 		edata.data = mii_link_ok(&lp->mii_if);
+		spin_unlock_irq(&lp->lock);
 		if (copy_to_user(useraddr, &edata, sizeof(edata)))
 			return -EFAULT;
 		return 0;
@@ -1661,45 +1669,37 @@
 
 static int pcnet32_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    unsigned long ioaddr = dev->base_addr;
     struct pcnet32_private *lp = dev->priv;	 
     struct mii_ioctl_data *data = (struct mii_ioctl_data *)&rq->ifr_data;
-    int phyaddr = lp->a.read_bcr (ioaddr, 33);
+    int rc;
+    unsigned long flags;
 
     if (cmd == SIOCETHTOOL)
 	return pcnet32_ethtool_ioctl(dev, (void *) rq->ifr_data);
 
+    /* SIOC[GS]MIIxxx ioctls */
     if (lp->mii) {
-	switch(cmd) {
-	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
-	    data->phy_id = (phyaddr >> 5) & 0x1f;
-	    /* Fall Through */
-	case SIOCGMIIREG:		/* Read MII PHY register. */
-	    lp->a.write_bcr (ioaddr, 33, ((data->phy_id & 0x1f) << 5) | (data->reg_num & 0x1f));
-	    data->val_out = lp->a.read_bcr (ioaddr, 34);
-	    lp->a.write_bcr (ioaddr, 33, phyaddr);
-	    return 0;
-	case SIOCSMIIREG:		/* Write MII PHY register. */
-	    if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-	    lp->a.write_bcr (ioaddr, 33, ((data->phy_id & 0x1f) << 5) | (data->reg_num & 0x1f));
-	    lp->a.write_bcr (ioaddr, 34, data->val_in);
-	    lp->a.write_bcr (ioaddr, 33, phyaddr);
-	    return 0;
-	default:
-	    return -EOPNOTSUPP;
-	}
+	spin_lock_irqsave(&lp->lock, flags);
+	rc = generic_mii_ioctl(&lp->mii_if, data, cmd, NULL);
+	spin_unlock_irqrestore(&lp->lock, flags);
+    } else {
+	rc = -EOPNOTSUPP;
     }
-    return -EOPNOTSUPP;
+
+    return rc;
 }
 
 static void pcnet32_watchdog(struct net_device *dev)
 {
     struct pcnet32_private *lp = dev->priv;
+    unsigned long flags;
 
     /* Print the link status if it has changed */
-    if (lp->mii)
+    if (lp->mii) {
+	spin_lock_irqsave(&lp->lock, flags);
 	mii_check_media (&lp->mii_if, 1, 0);
+	spin_unlock_irqrestore(&lp->lock, flags);
+    }
 
     mod_timer (&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
 }

-- 
Don Fry
brazilnut@us.ibm.com
