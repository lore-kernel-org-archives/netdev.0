From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 2/15] wireless/orinoco: fix up printk text
Date: Tue, 26 Oct 2004 14:39:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098815942.3663.42.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Fix up printk text

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/airport.c.2-printk-fixes	2004-10-25 14:46:53.203320800 -0400
+++ b/drivers/net/wireless/airport.c	2004-10-25 14:53:19.929529480 -0400
@@ -193,14 +193,14 @@
 	hermes_t *hw;
 
 	if (macio_resource_count(mdev) < 1 || macio_irq_count(mdev) < 1) {
-		printk(KERN_ERR PFX "wrong interrupt/addresses in OF tree\n");
+		printk(KERN_ERR PFX "Wrong interrupt/addresses in OF tree\n");
 		return -ENODEV;
 	}
 
 	/* Allocate space for private device-specific data */
 	dev = alloc_orinocodev(sizeof(*card), airport_hard_reset);
 	if (! dev) {
-		printk(KERN_ERR PFX "can't allocate device datas\n");
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		return -ENODEV;
 	}
 	priv = netdev_priv(dev);
@@ -223,11 +223,11 @@
 	/* Setup interrupts & base address */
 	dev->irq = macio_irq(mdev, 0);
 	phys_addr = macio_resource_start(mdev, 0);  /* Physical address */
-	printk(KERN_DEBUG PFX "Airport at physical address %lx\n", phys_addr);
+	printk(KERN_DEBUG PFX "Physical address %lx\n", phys_addr);
 	dev->base_addr = phys_addr;
 	card->vaddr = ioremap(phys_addr, AIRPORT_IO_LEN);
 	if (!card->vaddr) {
-		printk(PFX "ioremap() failed\n");
+		printk(KERN_ERR PFX "ioremap() failed\n");
 		goto failed;
 	}
 
@@ -241,7 +241,7 @@
 	/* Reset it before we get the interrupt */
 	hermes_init(hw);
 
-	if (request_irq(dev->irq, orinoco_interrupt, 0, "Airport", dev)) {
+	if (request_irq(dev->irq, orinoco_interrupt, 0, dev->name, dev)) {
 		printk(KERN_ERR PFX "Couldn't get IRQ %d\n", dev->irq);
 		goto failed;
 	}
@@ -252,7 +252,7 @@
 		printk(KERN_ERR PFX "register_netdev() failed\n");
 		goto failed;
 	}
-	printk(KERN_DEBUG PFX "card registered for interface %s\n", dev->name);
+	printk(KERN_DEBUG PFX "Card registered for interface %s\n", dev->name);
 	card->ndev_registered = 1;
 	return 0;
  failed:
--- a/drivers/net/wireless/hermes.c.2-printk-fixes	2004-10-25 14:54:36.425900264 -0400
+++ b/drivers/net/wireless/hermes.c	2004-10-25 14:59:05.506993720 -0400
@@ -235,13 +235,17 @@
 	err = hermes_issue_cmd(hw, cmd, parm0);
 	if (err) {
 		if (! hermes_present(hw)) {
-			printk(KERN_WARNING "hermes @ %s0x%lx: "
-			       "Card removed while issuing command.\n",
-			       IO_TYPE(hw), hw->iobase);
+			if (net_ratelimit())
+				printk(KERN_WARNING "hermes @ %s0x%lx: "
+				       "Card removed while issuing command "
+				       "0x%04x.\n", IO_TYPE(hw), hw->iobase,
+				       cmd);
 			err = -ENODEV;
 		} else 
-			printk(KERN_ERR "hermes @ %s0x%lx: Error %d issuing command.\n",
-			       IO_TYPE(hw), hw->iobase, err);
+			if (net_ratelimit())
+				printk(KERN_ERR "hermes @ %s0x%lx: "
+				       "Error %d issuing command 0x%04x.\n",
+				       IO_TYPE(hw), hw->iobase, err, cmd);
 		goto out;
 	}
 
@@ -254,17 +258,17 @@
 	}
 
 	if (! hermes_present(hw)) {
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
-		       "Card removed while waiting for command completion.\n",
-		       IO_TYPE(hw), hw->iobase);
+		printk(KERN_WARNING "hermes @ %s0x%lx: Card removed "
+		       "while waiting for command 0x%04x completion.\n",
+		       IO_TYPE(hw), hw->iobase, cmd);
 		err = -ENODEV;
 		goto out;
 	}
 		
 	if (! (reg & HERMES_EV_CMD)) {
-		printk(KERN_ERR "hermes @ %s0x%lx: "
-		       "Timeout waiting for command completion.\n",
-		       IO_TYPE(hw), hw->iobase);
+		printk(KERN_ERR "hermes @ %s0x%lx: Timeout waiting for "
+		       "command 0x%04x completion.\n", IO_TYPE(hw),
+		       hw->iobase, cmd);
 		err = -ETIMEDOUT;
 		goto out;
 	}
@@ -383,12 +387,18 @@
 		reg = hermes_read_reg(hw, oreg);
 	}
 
-	if (reg & HERMES_OFFSET_BUSY) {
-		return -ETIMEDOUT;
-	}
-
-	if (reg & HERMES_OFFSET_ERR) {
-		return -EIO;
+	if (reg != offset) {
+		printk(KERN_ERR "hermes @ %s0x%lx: BAP%d offset %s: "
+		       "reg=0x%x id=0x%x offset=0x%x\n", IO_TYPE(hw),
+		       hw->iobase, bap,
+		       (reg & HERMES_OFFSET_BUSY) ? "timeout" : "error",
+		       reg, id, offset);
+
+		if (reg & HERMES_OFFSET_BUSY) {
+			return -ETIMEDOUT;
+		}
+ 
+		return -EIO;		/* error or wrong offset */
 	}
 
 	return 0;
@@ -484,9 +494,9 @@
 		*length = rlength;
 
 	if (rtype != rid)
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
-		       "hermes_read_ltv(): rid  (0x%04x) does not match type (0x%04x)\n",
-		       IO_TYPE(hw), hw->iobase, rid, rtype);
+		printk(KERN_WARNING "hermes @ %s0x%lx: %s(): "
+		       "rid (0x%04x) does not match type (0x%04x)\n",
+		       IO_TYPE(hw), hw->iobase, __FUNCTION__, rid, rtype);
 	if (HERMES_RECLEN_TO_BYTES(rlength) > bufsize)
 		printk(KERN_WARNING "hermes @ %s0x%lx: "
 		       "Truncating LTV record from %d to %d bytes. "
--- a/drivers/net/wireless/orinoco.c.2-printk-fixes	2004-10-25 15:00:16.087263888 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-25 15:09:14.310441528 -0400
@@ -807,8 +807,9 @@
  	desc.tx_control = cpu_to_le16(HERMES_TXCTRL_TX_OK | HERMES_TXCTRL_TX_EX);
 	err = hermes_bap_pwrite(hw, USER_BAP, &desc, sizeof(desc), txfid, 0);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d writing Tx descriptor to BAP\n",
-		       dev->name, err);
+		if (net_ratelimit())
+			printk(KERN_ERR "%s: Error %d writing Tx descriptor "
+			       "to BAP\n", dev->name, err);
 		stats->tx_errors++;
 		goto fail;
 	}
@@ -838,8 +839,9 @@
 		err  = hermes_bap_pwrite(hw, USER_BAP, &hdr, sizeof(hdr),
 					 txfid, HERMES_802_3_OFFSET);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d writing packet header to BAP\n",
-			       dev->name, err);
+			if (net_ratelimit())
+				printk(KERN_ERR "%s: Error %d writing packet "
+				       "header to BAP\n", dev->name, err);
 			stats->tx_errors++;
 			goto fail;
 		}
@@ -1299,8 +1301,8 @@
 	}
 	break;
 	default:
-		printk(KERN_DEBUG "%s: Unknown information frame received "
-		       "(type %04x).\n", dev->name, type);
+		printk(KERN_DEBUG "%s: Unknown information frame received: "
+		       "type 0x%04x, length %d\n", dev->name, type, len);
 		/* We don't actually do anything about it */
 		break;
 	}
@@ -1309,7 +1311,7 @@
 static void __orinoco_ev_infdrop(struct net_device *dev, hermes_t *hw)
 {
 	if (net_ratelimit())
-		printk(KERN_WARNING "%s: Information frame lost.\n", dev->name);
+		printk(KERN_DEBUG "%s: Information frame lost.\n", dev->name);
 }
 
 /********************************************************************/
@@ -1787,7 +1789,8 @@
 		}
 		
 		if (p)
-			printk(KERN_WARNING "Multicast list is longer than mc_count\n");
+			printk(KERN_WARNING "%s: Multicast list is "
+			       "longer than mc_count\n", dev->name);
 
 		err = hermes_write_ltv(hw, USER_BAP, HERMES_RID_CNFGROUPADDRESSES,
 				       HERMES_BYTES_TO_RECLEN(priv->mc_count * ETH_ALEN),
@@ -2049,7 +2052,7 @@
 	/* Get the firmware version */
 	err = HERMES_READ_RECORD(hw, USER_BAP, HERMES_RID_STAID, &sta_id);
 	if (err) {
-		printk(KERN_WARNING "%s: Error %d reading firmware info. Wildly guessing capabilities...\n",
+		printk(KERN_ERR "%s: Cannot read station identity: error %d\n",
 		       dev->name, err);
 		memset(&sta_id, 0, sizeof(sta_id));
 	}
@@ -2058,7 +2061,7 @@
 	le16_to_cpus(&sta_id.variant);
 	le16_to_cpus(&sta_id.major);
 	le16_to_cpus(&sta_id.minor);
-	printk(KERN_DEBUG "%s: Station identity %04x:%04x:%04x:%04x\n",
+	printk(KERN_DEBUG "%s: Station identity  %04x:%04x:%04x:%04x\n",
 	       dev->name, sta_id.id, sta_id.variant,
 	       sta_id.major, sta_id.minor);
 
@@ -3074,8 +3077,9 @@
 			priv->mwo_robust = 0;
 		else {
 			if (frq->fixed)
-				printk(KERN_WARNING "%s: Fixed fragmentation not \
-supported on this firmware. Using MWO robust instead.\n", dev->name);
+				printk(KERN_WARNING "%s: Fixed fragmentation is "
+				       "not supported on this firmware. "
+				       "Using MWO robust instead.\n", dev->name);
 			priv->mwo_robust = 1;
 		}
 	} else {
--- a/drivers/net/wireless/orinoco_cs.c.2-printk-fixes	2004-10-25 15:11:03.156894352 -0400
+++ b/drivers/net/wireless/orinoco_cs.c	2004-10-25 15:11:39.137424480 -0400
@@ -405,7 +405,7 @@
 		last_ret = pcmcia_get_next_tuple(handle, &tuple);
 		if (last_ret  == CS_NO_MORE_ITEMS) {
 			printk(KERN_ERR PFX "GetNextTuple(): No matching "
-			       "CIS configuration, maybe you need the "
+			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=1 parameter.\n");
 			goto cs_failed;
 		}
--- a/drivers/net/wireless/orinoco_pci.c.2-printk-fixes	2004-10-25 15:13:44.962296192 -0400
+++ b/drivers/net/wireless/orinoco_pci.c	2004-10-25 15:15:58.936928952 -0400
@@ -237,8 +237,7 @@
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n",
-		       pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
 		goto fail;
 	}
@@ -257,7 +256,7 @@
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR "%s: Failed to register net device\n", dev->name);
+		printk(KERN_ERR PFX "Failed to register net device\n");
 		goto fail;
 	}
 
