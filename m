From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.4.25 pcnet32.c bus master arbitration failure fix
Date: Thu, 19 Feb 2004 13:54:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402192154.i1JLsfX05464@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The driver did not properly serialize accesses to chip registers, resulting
in reading/writing the wrong register.  This patch eliminates this problem
and gets rid of the cause of the symptom of 'bus master arbitration failure'.

It was easier to use generic_mii_ioctl than modify the current pcnet32_ioctl
routine with the necessary locks.  This has been re-tested on an IA32 system.

--- linux-2.4.25/drivers/net/rmm.pcnet32.c	Thu Feb 19 13:34:29 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Thu Feb 19 13:48:02 2004
@@ -713,6 +713,8 @@
     lp->name = chipname;
     lp->shared_irq = shared;
     lp->mii_if.full_duplex = fdx;
+    lp->mii_if.phy_id_mask = 0x1f;
+    lp->mii_if.reg_num_mask = 0x1f;
     lp->dxsuflo = dxsuflo;
     lp->ltint = ltint;
     lp->mii = mii;
@@ -784,6 +786,9 @@
 	}
     }
 
+    /* Set the mii phy_id so that we can query the link state */
+    if (lp->mii)
+	lp->mii_if.phy_id = ((lp->a.read_bcr (ioaddr, 33)) >> 5) & 0x1f;
     
     /* The PCNET32-specific entries in the device structure. */
     dev->open = &pcnet32_open;
@@ -1604,12 +1609,18 @@
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
@@ -1640,36 +1651,24 @@
 
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
 
 static struct pci_driver pcnet32_driver = {

-- 
Don Fry
brazilnut@us.ibm.com
