From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.11rc2] wireless/orinoco: Update printk()s from upstream
 orinoco
Date: Sat, 22 Jan 2005 21:28:30 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0501222115470.11940@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="279707962-1385008808-1106446908=:11940"
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.58.0501222123490.11940@devserv.devel.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--279707962-1385008808-1106446908=:11940
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.58.0501222123491.11940@devserv.devel.redhat.com>

[PATCH 2.6.11rc2] wireless/orinoco: Update printk()s from upstream orinoco

Update printk() statements to reduce meaningless diff between upstream
orinoco and in-kernel orinoco drivers.

Signed-off-by: Dan Williams <dcbw@redhat.com>


--- a/drivers/net/wireless/orinoco_plx.c.printk	2005-01-22 
16:00:34.743895448 -0500
+++ b/drivers/net/wireless/orinoco_plx.c	2005-01-22 
16:02:19.104030296 -0500
@@ -233,7 +233,8 @@
 
 	/* Allocate network device */
 	dev = alloc_orinocodev(0, NULL);
-	if (! dev) {
+	if (!dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err = -ENOMEM;
 		goto fail;
 	}
@@ -254,15 +255,17 @@
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n", 
pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", 
pdev->irq);
 		err = -EBUSY;
 		goto fail;
 	}
 	dev->irq = pdev->irq;
 
 	err = register_netdev(dev);
-	if (err)
+	if (err) {
+		printk(KERN_ERR PFX "Cannot register network device\n");
 		goto fail;
+	}
 
 	return 0;
 
--- a/drivers/net/wireless/orinoco.c.printk	2005-01-22 
15:38:27.019740200 -0500
+++ b/drivers/net/wireless/orinoco.c	2005-01-22 16:11:17.045250800 
-0500
@@ -805,8 +805,9 @@
  	desc.tx_control = cpu_to_le16(HERMES_TXCTRL_TX_OK | 
HERMES_TXCTRL_TX_EX);
 	err = hermes_bap_pwrite(hw, USER_BAP, &desc, sizeof(desc), txfid, 
0);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d writing Tx descriptor to 
BAP\n",
-		       dev->name, err);
+		if (net_ratelimit())
+			printk(KERN_ERR "%s: Error %d writing Tx 
descriptor "
+			       "to BAP\n", dev->name, err);
 		stats->tx_errors++;
 		goto fail;
 	}
@@ -836,8 +837,9 @@
 		err  = hermes_bap_pwrite(hw, USER_BAP, &hdr, sizeof(hdr),
 					 txfid, HERMES_802_3_OFFSET);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d writing packet 
header to BAP\n",
-			       dev->name, err);
+			if (net_ratelimit())
+				printk(KERN_ERR "%s: Error %d writing 
packet "
+				       "header to BAP\n", dev->name, err);
 			stats->tx_errors++;
 			goto fail;
 		}
@@ -1297,8 +1299,8 @@
 	}
 	break;
 	default:
-		printk(KERN_DEBUG "%s: Unknown information frame received 
"
-		       "(type %04x).\n", dev->name, type);
+		printk(KERN_DEBUG "%s: Unknown information frame received: 
"
+		       "type 0x%04x, length %d\n", dev->name, type, len);
 		/* We don't actually do anything about it */
 		break;
 	}
@@ -1307,7 +1309,7 @@
 static void __orinoco_ev_infdrop(struct net_device *dev, hermes_t *hw)
 {
 	if (net_ratelimit())
-		printk(KERN_WARNING "%s: Information frame lost.\n", 
dev->name);
+		printk(KERN_DEBUG "%s: Information frame lost.\n", 
dev->name);
 }
 
 /********************************************************************/
@@ -1785,7 +1787,8 @@
 		}
 		
 		if (p)
-			printk(KERN_WARNING "Multicast list is longer than 
mc_count\n");
+			printk(KERN_WARNING "%s: Multicast list is "
+			       "longer than mc_count\n", dev->name);
 
 		err = hermes_write_ltv(hw, USER_BAP, 
HERMES_RID_CNFGROUPADDRESSES,
 				       
HERMES_BYTES_TO_RECLEN(priv->mc_count * ETH_ALEN),
@@ -1882,13 +1885,14 @@
 
 	orinoco_unlock(priv, &flags);
 
-	if (priv->hard_reset)
+	if (priv->hard_reset) {
 		err = (*priv->hard_reset)(priv);
-	if (err) {
-		printk(KERN_ERR "%s: orinoco_reset: Error %d "
-		       "performing  hard reset\n", dev->name, err);
-		/* FIXME: shutdown of some sort */
-		return;
+		if (err) {
+			printk(KERN_ERR "%s: orinoco_reset: Error %d "
+			       "performing hard reset\n", dev->name, err);
+			/* FIXME: shutdown of some sort */
+			return;
+		}
 	}
 
 	err = orinoco_reinit_firmware(dev);
@@ -2044,7 +2048,7 @@
 	/* Get the firmware version */
 	err = HERMES_READ_RECORD(hw, USER_BAP, HERMES_RID_STAID, &sta_id);
 	if (err) {
-		printk(KERN_WARNING "%s: Error %d reading firmware info. 
Wildly guessing capabilities...\n",
+		printk(KERN_ERR "%s: Cannot read station identity: error 
%d\n",
 		       dev->name, err);
 		memset(&sta_id, 0, sizeof(sta_id));
 	}
@@ -2053,7 +2057,7 @@
 	le16_to_cpus(&sta_id.variant);
 	le16_to_cpus(&sta_id.major);
 	le16_to_cpus(&sta_id.minor);
-	printk(KERN_DEBUG "%s: Station identity %04x:%04x:%04x:%04x\n",
+	printk(KERN_DEBUG "%s: Station identity  %04x:%04x:%04x:%04x\n",
 	       dev->name, sta_id.id, sta_id.variant,
 	       sta_id.major, sta_id.minor);
 
@@ -3045,8 +3049,9 @@
 			priv->mwo_robust = 0;
 		else {
 			if (frq->fixed)
-				printk(KERN_WARNING "%s: Fixed 
fragmentation not \
-supported on this firmware. Using MWO robust instead.\n", dev->name);
+				printk(KERN_WARNING "%s: Fixed 
fragmentation is "
+				       "not supported on this firmware. "
+				       "Using MWO robust instead.\n", 
dev->name);
 			priv->mwo_robust = 1;
 		}
 	} else {
--- a/drivers/net/wireless/hermes.c.printk	2005-01-22 
15:30:50.156194016 -0500
+++ b/drivers/net/wireless/hermes.c	2005-01-22 15:37:31.151233504 
-0500
@@ -67,8 +67,7 @@
  * Debugging helpers
  */
 
-#define IO_TYPE(hw)	((hw)->io_space ? "IO " : "MEM ")
-#define DMSG(stuff...) do {printk(KERN_DEBUG "hermes @ %s0x%x: " , 
IO_TYPE(hw), hw->iobase); \
+#define DMSG(stuff...) do {printk(KERN_DEBUG "hermes @ %p: " , 
hw->iobase); \
 			printk(stuff);} while (0)
 
 #undef HERMES_DEBUG
@@ -200,9 +199,9 @@
 	}
 		
 	if (! (reg & HERMES_EV_CMD)) {
-		printk(KERN_ERR "hermes @ %s0x%lx: " 
+		printk(KERN_ERR "hermes @ %p: " 
 		       "Timeout waiting for card to reset 
(reg=0x%04x)!\n",
-		       IO_TYPE(hw), hw->iobase, reg);
+		       hw->iobase, reg);
 		err = -ETIMEDOUT;
 		goto out;
 	}
@@ -235,13 +234,16 @@
 	err = hermes_issue_cmd(hw, cmd, parm0);
 	if (err) {
 		if (! hermes_present(hw)) {
-			printk(KERN_WARNING "hermes @ %s0x%lx: "
-			       "Card removed while issuing command.\n",
-			       IO_TYPE(hw), hw->iobase);
+			if (net_ratelimit())
+				printk(KERN_WARNING "hermes @ %p: "
+				       "Card removed while issuing command 
"
+				       "0x%04x.\n", hw->iobase, cmd);
 			err = -ENODEV;
 		} else 
-			printk(KERN_ERR "hermes @ %s0x%lx: Error %d 
issuing command.\n",
-			       IO_TYPE(hw), hw->iobase, err);
+			if (net_ratelimit())
+				printk(KERN_ERR "hermes @ %p: "
+				       "Error %d issuing command 
0x%04x.\n",
+				       hw->iobase, err, cmd);
 		goto out;
 	}
 
@@ -254,17 +256,16 @@
 	}
 
 	if (! hermes_present(hw)) {
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
-		       "Card removed while waiting for command 
completion.\n",
-		       IO_TYPE(hw), hw->iobase);
+		printk(KERN_WARNING "hermes @ %p: Card removed "
+		       "while waiting for command 0x%04x completion.\n",
+		       hw->iobase, cmd);
 		err = -ENODEV;
 		goto out;
 	}
 		
 	if (! (reg & HERMES_EV_CMD)) {
-		printk(KERN_ERR "hermes @ %s0x%lx: "
-		       "Timeout waiting for command completion.\n",
-		       IO_TYPE(hw), hw->iobase);
+		printk(KERN_ERR "hermes @ %p: Timeout waiting for "
+		       "command 0x%04x completion.\n", hw->iobase, cmd);
 		err = -ETIMEDOUT;
 		goto out;
 	}
@@ -309,16 +310,16 @@
 	}
 	
 	if (! hermes_present(hw)) {
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
+		printk(KERN_WARNING "hermes @ %p: "
 		       "Card removed waiting for frame allocation.\n",
-		       IO_TYPE(hw), hw->iobase);
+		       hw->iobase);
 		return -ENODEV;
 	}
 		
 	if (! (reg & HERMES_EV_ALLOC)) {
-		printk(KERN_ERR "hermes @ %s0x%lx: "
+		printk(KERN_ERR "hermes @ %p: "
 		       "Timeout waiting for frame allocation\n",
-		       IO_TYPE(hw), hw->iobase);
+		       hw->iobase);
 		return -ETIMEDOUT;
 	}
 
@@ -383,12 +384,17 @@
 		reg = hermes_read_reg(hw, oreg);
 	}
 
-	if (reg & HERMES_OFFSET_BUSY) {
-		return -ETIMEDOUT;
-	}
+	if (reg != offset) {
+		printk(KERN_ERR "hermes @ %p: BAP%d offset %s: "
+		       "reg=0x%x id=0x%x offset=0x%x\n", hw->iobase, bap,
+		       (reg & HERMES_OFFSET_BUSY) ? "timeout" : "error",
+		       reg, id, offset);
+
+		if (reg & HERMES_OFFSET_BUSY) {
+			return -ETIMEDOUT;
+		}
 
-	if (reg & HERMES_OFFSET_ERR) {
-		return -EIO;
+		return -EIO;		/* error or wrong offset */
 	}
 
 	return 0;
@@ -484,14 +490,13 @@
 		*length = rlength;
 
 	if (rtype != rid)
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
-		       "hermes_read_ltv(): rid  (0x%04x) does not match 
type (0x%04x)\n",
-		       IO_TYPE(hw), hw->iobase, rid, rtype);
+		printk(KERN_WARNING "hermes @ %p: %s(): "
+		       "rid (0x%04x) does not match type (0x%04x)\n",
+		       hw->iobase, __FUNCTION__, rid, rtype);
 	if (HERMES_RECLEN_TO_BYTES(rlength) > bufsize)
-		printk(KERN_WARNING "hermes @ %s0x%lx: "
+		printk(KERN_WARNING "hermes @ %p: "
 		       "Truncating LTV record from %d to %d bytes. "
-		       "(rid=0x%04x, len=0x%04x)\n",
-		       IO_TYPE(hw), hw->iobase,
+		       "(rid=0x%04x, len=0x%04x)\n", hw->iobase,
 		       HERMES_RECLEN_TO_BYTES(rlength), bufsize, rid, 
rlength);
 
 	nwords = min((unsigned)rlength - 1, bufsize / 2);
--- a/drivers/net/wireless/orinoco.h.printk	2005-01-22 
15:55:00.374727288 -0500
+++ b/drivers/net/wireless/orinoco.h	2005-01-22 15:55:37.219126088 
-0500
@@ -127,7 +127,7 @@
 {
 	spin_lock_irqsave(&priv->lock, *flags);
 	if (priv->hw_unavailable) {
-		printk(KERN_DEBUG "orinoco_lock() called with 
hw_unavailable (dev=%p)\n",
+		DEBUG(1, "orinoco_lock() called with hw_unavailable 
(dev=%p)\n",
 		       priv->ndev);
 		spin_unlock_irqrestore(&priv->lock, *flags);
 		return -EBUSY;
--- a/drivers/net/wireless/orinoco_cs.c.printk	2005-01-22 
15:51:59.049292944 -0500
+++ b/drivers/net/wireless/orinoco_cs.c	2005-01-22 15:54:09.128517896 
-0500
@@ -390,7 +390,7 @@
 		last_ret = pcmcia_get_next_tuple(handle, &tuple);
 		if (last_ret  == CS_NO_MORE_ITEMS) {
 			printk(KERN_ERR PFX "GetNextTuple(): No matching "
-			       "CIS configuration, maybe you need the "
+			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=1 parameter.\n");
 			goto cs_failed;
 		}
--- a/drivers/net/wireless/orinoco_tmd.c.printk	2005-01-22 
16:02:48.677534440 -0500
+++ b/drivers/net/wireless/orinoco_tmd.c	2005-01-22 
16:04:42.437240336 -0500
@@ -91,15 +91,16 @@
 	struct net_device *dev = NULL;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return err;
+	}
 
 	printk(KERN_DEBUG PFX "TMD setup\n");
 	pccard_ioaddr = pci_resource_start(pdev, 2);
 	pccard_iolen = pci_resource_len(pdev, 2);
 	if (! request_region(pccard_ioaddr, pccard_iolen, DRIVER_NAME)) {
-		printk(KERN_ERR PFX "I/O resource at 0x%lx len 0x%lx 
busy\n",
-			pccard_ioaddr, pccard_iolen);
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
 		pccard_ioaddr = 0;
 		err = -EBUSY;
 		goto fail;
@@ -117,6 +118,7 @@
 	/* Allocate network device */
 	dev = alloc_orinocodev(0, NULL);
 	if (! dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err = -ENOMEM;
 		goto fail;
 	}
@@ -137,16 +139,17 @@
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n",
-		       pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", 
pdev->irq);
 		err = -EBUSY;
 		goto fail;
 	}
 	dev->irq = pdev->irq;
 
 	err = register_netdev(dev);
-	if (err)
-		goto fail;
+	if (err) {
+		printk(KERN_ERR PFX "Cannot register network device\n");
+ 		goto fail;
+	}
 
 	return 0;
 
--- a/drivers/net/wireless/orinoco_pci.c.printk	2005-01-22 
15:56:16.569143976 -0500
+++ b/drivers/net/wireless/orinoco_pci.c	2005-01-22 
16:13:31.993735512 -0500
@@ -183,7 +183,6 @@
 		printk(KERN_ERR PFX "Busy timeout\n");
 		return -ETIMEDOUT;
 	}
-	printk(KERN_NOTICE "pci_cor : reg = 0x%X - %lX - %lX\n", reg, 
timeout, jiffies);
 
 	return 0;
 }
@@ -202,15 +201,19 @@
 	struct net_device *dev = NULL;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return err;
+	}
 
 	/* Resource 0 is mapped to the hermes registers */
 	pci_iorange = pci_resource_start(pdev, 0);
 	pci_iolen = pci_resource_len(pdev, 0);
 	pci_ioaddr = ioremap(pci_iorange, pci_iolen);
-	if (! pci_iorange)
+	if (!pci_iorange) {
+		printk(KERN_ERR PFX "Cannot remap hardware registers\n");
 		goto fail;
+	}
 
 	/* Allocate network device */
 	dev = alloc_orinocodev(0, NULL);
@@ -237,8 +240,7 @@
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n",
-		       pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", 
pdev->irq);
 		err = -EBUSY;
 		goto fail;
 	}
@@ -246,7 +248,7 @@
 
 	/* Perform a COR reset to start the card */
 	if(orinoco_pci_cor_reset(priv) != 0) {
-		printk(KERN_ERR "%s: Failed to start the card\n", 
dev->name);
+		printk(KERN_ERR PFX "Initial reset failed\n");
 		err = -ETIMEDOUT;
 		goto fail;
 	}
@@ -257,7 +259,7 @@
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR "%s: Failed to register net device\n", 
dev->name);
+		printk(KERN_ERR PFX "Failed to register net device\n");
 		goto fail;
 	}
 
--- a/drivers/net/wireless/airport.c.printk	2005-01-22 
15:26:54.221061608 -0500
+++ b/drivers/net/wireless/airport.c	2005-01-22 15:28:55.964553784 
-0500
@@ -194,14 +194,14 @@
 	hermes_t *hw;
 
 	if (macio_resource_count(mdev) < 1 || macio_irq_count(mdev) < 1) {
-		printk(KERN_ERR PFX "wrong interrupt/addresses in OF 
tree\n");
+		printk(KERN_ERR PFX "Wrong interrupt/addresses in OF 
tree\n");
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
@@ -224,11 +224,11 @@
 	/* Setup interrupts & base address */
 	dev->irq = macio_irq(mdev, 0);
 	phys_addr = macio_resource_start(mdev, 0);  /* Physical address */
-	printk(KERN_DEBUG PFX "Airport at physical address %lx\n", 
phys_addr);
+	printk(KERN_DEBUG PFX "Physical address %lx\n", phys_addr);
 	dev->base_addr = phys_addr;
 	card->vaddr = ioremap(phys_addr, AIRPORT_IO_LEN);
 	if (!card->vaddr) {
-		printk(PFX "ioremap() failed\n");
+		printk(KERN_ERR PFX "ioremap() failed\n");
 		goto failed;
 	}
 
@@ -253,7 +253,7 @@
 		printk(KERN_ERR PFX "register_netdev() failed\n");
 		goto failed;
 	}
-	printk(KERN_DEBUG PFX "card registered for interface %s\n", 
dev->name);
+	printk(KERN_DEBUG PFX "Card registered for interface %s\n", 
dev->name);
 	card->ndev_registered = 1;
 	return 0;
  failed:

--279707962-1385008808-1106446908=:11940
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="1.orinoco-merge-printk-fixes.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0501222121480.11940@devserv.devel.redhat.com>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="1.orinoco-merge-printk-fixes.patch"

LS0tIGEvZHJpdmVycy9uZXQvd2lyZWxlc3Mvb3Jpbm9jb19wbHguYy5wcmlu
dGsJMjAwNS0wMS0yMiAxNjowMDozNC43NDM4OTU0NDggLTA1MDANCisrKyBi
L2RyaXZlcnMvbmV0L3dpcmVsZXNzL29yaW5vY29fcGx4LmMJMjAwNS0wMS0y
MiAxNjowMjoxOS4xMDQwMzAyOTYgLTA1MDANCkBAIC0yMzMsNyArMjMzLDgg
QEANCiANCiAJLyogQWxsb2NhdGUgbmV0d29yayBkZXZpY2UgKi8NCiAJZGV2
ID0gYWxsb2Nfb3Jpbm9jb2RldigwLCBOVUxMKTsNCi0JaWYgKCEgZGV2KSB7
DQorCWlmICghZGV2KSB7DQorCQlwcmludGsoS0VSTl9FUlIgUEZYICJDYW5u
b3QgYWxsb2NhdGUgbmV0d29yayBkZXZpY2VcbiIpOw0KIAkJZXJyID0gLUVO
T01FTTsNCiAJCWdvdG8gZmFpbDsNCiAJfQ0KQEAgLTI1NCwxNSArMjU1LDE3
IEBADQogCWVyciA9IHJlcXVlc3RfaXJxKHBkZXYtPmlycSwgb3Jpbm9jb19p
bnRlcnJ1cHQsIFNBX1NISVJRLA0KIAkJCSAgZGV2LT5uYW1lLCBkZXYpOw0K
IAlpZiAoZXJyKSB7DQotCQlwcmludGsoS0VSTl9FUlIgUEZYICJFcnJvciBh
bGxvY2F0aW5nIElSUSAlZC5cbiIsIHBkZXYtPmlycSk7DQorCQlwcmludGso
S0VSTl9FUlIgUEZYICJDYW5ub3QgYWxsb2NhdGUgSVJRICVkXG4iLCBwZGV2
LT5pcnEpOw0KIAkJZXJyID0gLUVCVVNZOw0KIAkJZ290byBmYWlsOw0KIAl9
DQogCWRldi0+aXJxID0gcGRldi0+aXJxOw0KIA0KIAllcnIgPSByZWdpc3Rl
cl9uZXRkZXYoZGV2KTsNCi0JaWYgKGVycikNCisJaWYgKGVycikgew0KKwkJ
cHJpbnRrKEtFUk5fRVJSIFBGWCAiQ2Fubm90IHJlZ2lzdGVyIG5ldHdvcmsg
ZGV2aWNlXG4iKTsNCiAJCWdvdG8gZmFpbDsNCisJfQ0KIA0KIAlyZXR1cm4g
MDsNCiANCi0tLSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL29yaW5vY28uYy5w
cmludGsJMjAwNS0wMS0yMiAxNTozODoyNy4wMTk3NDAyMDAgLTA1MDANCisr
KyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL29yaW5vY28uYwkyMDA1LTAxLTIy
IDE2OjExOjE3LjA0NTI1MDgwMCAtMDUwMA0KQEAgLTgwNSw4ICs4MDUsOSBA
QA0KICAJZGVzYy50eF9jb250cm9sID0gY3B1X3RvX2xlMTYoSEVSTUVTX1RY
Q1RSTF9UWF9PSyB8IEhFUk1FU19UWENUUkxfVFhfRVgpOw0KIAllcnIgPSBo
ZXJtZXNfYmFwX3B3cml0ZShodywgVVNFUl9CQVAsICZkZXNjLCBzaXplb2Yo
ZGVzYyksIHR4ZmlkLCAwKTsNCiAJaWYgKGVycikgew0KLQkJcHJpbnRrKEtF
Uk5fRVJSICIlczogRXJyb3IgJWQgd3JpdGluZyBUeCBkZXNjcmlwdG9yIHRv
IEJBUFxuIiwNCi0JCSAgICAgICBkZXYtPm5hbWUsIGVycik7DQorCQlpZiAo
bmV0X3JhdGVsaW1pdCgpKQ0KKwkJCXByaW50ayhLRVJOX0VSUiAiJXM6IEVy
cm9yICVkIHdyaXRpbmcgVHggZGVzY3JpcHRvciAiDQorCQkJICAgICAgICJ0
byBCQVBcbiIsIGRldi0+bmFtZSwgZXJyKTsNCiAJCXN0YXRzLT50eF9lcnJv
cnMrKzsNCiAJCWdvdG8gZmFpbDsNCiAJfQ0KQEAgLTgzNiw4ICs4MzcsOSBA
QA0KIAkJZXJyICA9IGhlcm1lc19iYXBfcHdyaXRlKGh3LCBVU0VSX0JBUCwg
Jmhkciwgc2l6ZW9mKGhkciksDQogCQkJCQkgdHhmaWQsIEhFUk1FU184MDJf
M19PRkZTRVQpOw0KIAkJaWYgKGVycikgew0KLQkJCXByaW50ayhLRVJOX0VS
UiAiJXM6IEVycm9yICVkIHdyaXRpbmcgcGFja2V0IGhlYWRlciB0byBCQVBc
biIsDQotCQkJICAgICAgIGRldi0+bmFtZSwgZXJyKTsNCisJCQlpZiAobmV0
X3JhdGVsaW1pdCgpKQ0KKwkJCQlwcmludGsoS0VSTl9FUlIgIiVzOiBFcnJv
ciAlZCB3cml0aW5nIHBhY2tldCAiDQorCQkJCSAgICAgICAiaGVhZGVyIHRv
IEJBUFxuIiwgZGV2LT5uYW1lLCBlcnIpOw0KIAkJCXN0YXRzLT50eF9lcnJv
cnMrKzsNCiAJCQlnb3RvIGZhaWw7DQogCQl9DQpAQCAtMTI5Nyw4ICsxMjk5
LDggQEANCiAJfQ0KIAlicmVhazsNCiAJZGVmYXVsdDoNCi0JCXByaW50ayhL
RVJOX0RFQlVHICIlczogVW5rbm93biBpbmZvcm1hdGlvbiBmcmFtZSByZWNl
aXZlZCAiDQotCQkgICAgICAgIih0eXBlICUwNHgpLlxuIiwgZGV2LT5uYW1l
LCB0eXBlKTsNCisJCXByaW50ayhLRVJOX0RFQlVHICIlczogVW5rbm93biBp
bmZvcm1hdGlvbiBmcmFtZSByZWNlaXZlZDogIg0KKwkJICAgICAgICJ0eXBl
IDB4JTA0eCwgbGVuZ3RoICVkXG4iLCBkZXYtPm5hbWUsIHR5cGUsIGxlbik7
DQogCQkvKiBXZSBkb24ndCBhY3R1YWxseSBkbyBhbnl0aGluZyBhYm91dCBp
dCAqLw0KIAkJYnJlYWs7DQogCX0NCkBAIC0xMzA3LDcgKzEzMDksNyBAQA0K
IHN0YXRpYyB2b2lkIF9fb3Jpbm9jb19ldl9pbmZkcm9wKHN0cnVjdCBuZXRf
ZGV2aWNlICpkZXYsIGhlcm1lc190ICpodykNCiB7DQogCWlmIChuZXRfcmF0
ZWxpbWl0KCkpDQotCQlwcmludGsoS0VSTl9XQVJOSU5HICIlczogSW5mb3Jt
YXRpb24gZnJhbWUgbG9zdC5cbiIsIGRldi0+bmFtZSk7DQorCQlwcmludGso
S0VSTl9ERUJVRyAiJXM6IEluZm9ybWF0aW9uIGZyYW1lIGxvc3QuXG4iLCBk
ZXYtPm5hbWUpOw0KIH0NCiANCiAvKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKiov
DQpAQCAtMTc4NSw3ICsxNzg3LDggQEANCiAJCX0NCiAJCQ0KIAkJaWYgKHAp
DQotCQkJcHJpbnRrKEtFUk5fV0FSTklORyAiTXVsdGljYXN0IGxpc3QgaXMg
bG9uZ2VyIHRoYW4gbWNfY291bnRcbiIpOw0KKwkJCXByaW50ayhLRVJOX1dB
Uk5JTkcgIiVzOiBNdWx0aWNhc3QgbGlzdCBpcyAiDQorCQkJICAgICAgICJs
b25nZXIgdGhhbiBtY19jb3VudFxuIiwgZGV2LT5uYW1lKTsNCiANCiAJCWVy
ciA9IGhlcm1lc193cml0ZV9sdHYoaHcsIFVTRVJfQkFQLCBIRVJNRVNfUklE
X0NORkdST1VQQUREUkVTU0VTLA0KIAkJCQkgICAgICAgSEVSTUVTX0JZVEVT
X1RPX1JFQ0xFTihwcml2LT5tY19jb3VudCAqIEVUSF9BTEVOKSwNCkBAIC0x
ODgyLDEzICsxODg1LDE0IEBADQogDQogCW9yaW5vY29fdW5sb2NrKHByaXYs
ICZmbGFncyk7DQogDQotCWlmIChwcml2LT5oYXJkX3Jlc2V0KQ0KKwlpZiAo
cHJpdi0+aGFyZF9yZXNldCkgew0KIAkJZXJyID0gKCpwcml2LT5oYXJkX3Jl
c2V0KShwcml2KTsNCi0JaWYgKGVycikgew0KLQkJcHJpbnRrKEtFUk5fRVJS
ICIlczogb3Jpbm9jb19yZXNldDogRXJyb3IgJWQgIg0KLQkJICAgICAgICJw
ZXJmb3JtaW5nICBoYXJkIHJlc2V0XG4iLCBkZXYtPm5hbWUsIGVycik7DQot
CQkvKiBGSVhNRTogc2h1dGRvd24gb2Ygc29tZSBzb3J0ICovDQotCQlyZXR1
cm47DQorCQlpZiAoZXJyKSB7DQorCQkJcHJpbnRrKEtFUk5fRVJSICIlczog
b3Jpbm9jb19yZXNldDogRXJyb3IgJWQgIg0KKwkJCSAgICAgICAicGVyZm9y
bWluZyBoYXJkIHJlc2V0XG4iLCBkZXYtPm5hbWUsIGVycik7DQorCQkJLyog
RklYTUU6IHNodXRkb3duIG9mIHNvbWUgc29ydCAqLw0KKwkJCXJldHVybjsN
CisJCX0NCiAJfQ0KIA0KIAllcnIgPSBvcmlub2NvX3JlaW5pdF9maXJtd2Fy
ZShkZXYpOw0KQEAgLTIwNDQsNyArMjA0OCw3IEBADQogCS8qIEdldCB0aGUg
ZmlybXdhcmUgdmVyc2lvbiAqLw0KIAllcnIgPSBIRVJNRVNfUkVBRF9SRUNP
UkQoaHcsIFVTRVJfQkFQLCBIRVJNRVNfUklEX1NUQUlELCAmc3RhX2lkKTsN
CiAJaWYgKGVycikgew0KLQkJcHJpbnRrKEtFUk5fV0FSTklORyAiJXM6IEVy
cm9yICVkIHJlYWRpbmcgZmlybXdhcmUgaW5mby4gV2lsZGx5IGd1ZXNzaW5n
IGNhcGFiaWxpdGllcy4uLlxuIiwNCisJCXByaW50ayhLRVJOX0VSUiAiJXM6
IENhbm5vdCByZWFkIHN0YXRpb24gaWRlbnRpdHk6IGVycm9yICVkXG4iLA0K
IAkJICAgICAgIGRldi0+bmFtZSwgZXJyKTsNCiAJCW1lbXNldCgmc3RhX2lk
LCAwLCBzaXplb2Yoc3RhX2lkKSk7DQogCX0NCkBAIC0yMDUzLDcgKzIwNTcs
NyBAQA0KIAlsZTE2X3RvX2NwdXMoJnN0YV9pZC52YXJpYW50KTsNCiAJbGUx
Nl90b19jcHVzKCZzdGFfaWQubWFqb3IpOw0KIAlsZTE2X3RvX2NwdXMoJnN0
YV9pZC5taW5vcik7DQotCXByaW50ayhLRVJOX0RFQlVHICIlczogU3RhdGlv
biBpZGVudGl0eSAlMDR4OiUwNHg6JTA0eDolMDR4XG4iLA0KKwlwcmludGso
S0VSTl9ERUJVRyAiJXM6IFN0YXRpb24gaWRlbnRpdHkgICUwNHg6JTA0eDol
MDR4OiUwNHhcbiIsDQogCSAgICAgICBkZXYtPm5hbWUsIHN0YV9pZC5pZCwg
c3RhX2lkLnZhcmlhbnQsDQogCSAgICAgICBzdGFfaWQubWFqb3IsIHN0YV9p
ZC5taW5vcik7DQogDQpAQCAtMzA0NSw4ICszMDQ5LDkgQEANCiAJCQlwcml2
LT5td29fcm9idXN0ID0gMDsNCiAJCWVsc2Ugew0KIAkJCWlmIChmcnEtPmZp
eGVkKQ0KLQkJCQlwcmludGsoS0VSTl9XQVJOSU5HICIlczogRml4ZWQgZnJh
Z21lbnRhdGlvbiBub3QgXA0KLXN1cHBvcnRlZCBvbiB0aGlzIGZpcm13YXJl
LiBVc2luZyBNV08gcm9idXN0IGluc3RlYWQuXG4iLCBkZXYtPm5hbWUpOw0K
KwkJCQlwcmludGsoS0VSTl9XQVJOSU5HICIlczogRml4ZWQgZnJhZ21lbnRh
dGlvbiBpcyAiDQorCQkJCSAgICAgICAibm90IHN1cHBvcnRlZCBvbiB0aGlz
IGZpcm13YXJlLiAiDQorCQkJCSAgICAgICAiVXNpbmcgTVdPIHJvYnVzdCBp
bnN0ZWFkLlxuIiwgZGV2LT5uYW1lKTsNCiAJCQlwcml2LT5td29fcm9idXN0
ID0gMTsNCiAJCX0NCiAJfSBlbHNlIHsNCi0tLSBhL2RyaXZlcnMvbmV0L3dp
cmVsZXNzL2hlcm1lcy5jLnByaW50awkyMDA1LTAxLTIyIDE1OjMwOjUwLjE1
NjE5NDAxNiAtMDUwMA0KKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvaGVy
bWVzLmMJMjAwNS0wMS0yMiAxNTozNzozMS4xNTEyMzM1MDQgLTA1MDANCkBA
IC02Nyw4ICs2Nyw3IEBADQogICogRGVidWdnaW5nIGhlbHBlcnMNCiAgKi8N
CiANCi0jZGVmaW5lIElPX1RZUEUoaHcpCSgoaHcpLT5pb19zcGFjZSA/ICJJ
TyAiIDogIk1FTSAiKQ0KLSNkZWZpbmUgRE1TRyhzdHVmZi4uLikgZG8ge3By
aW50ayhLRVJOX0RFQlVHICJoZXJtZXMgQCAlczB4JXg6ICIgLCBJT19UWVBF
KGh3KSwgaHctPmlvYmFzZSk7IFwNCisjZGVmaW5lIERNU0coc3R1ZmYuLi4p
IGRvIHtwcmludGsoS0VSTl9ERUJVRyAiaGVybWVzIEAgJXA6ICIgLCBody0+
aW9iYXNlKTsgXA0KIAkJCXByaW50ayhzdHVmZik7fSB3aGlsZSAoMCkNCiAN
CiAjdW5kZWYgSEVSTUVTX0RFQlVHDQpAQCAtMjAwLDkgKzE5OSw5IEBADQog
CX0NCiAJCQ0KIAlpZiAoISAocmVnICYgSEVSTUVTX0VWX0NNRCkpIHsNCi0J
CXByaW50ayhLRVJOX0VSUiAiaGVybWVzIEAgJXMweCVseDogIiANCisJCXBy
aW50ayhLRVJOX0VSUiAiaGVybWVzIEAgJXA6ICIgDQogCQkgICAgICAgIlRp
bWVvdXQgd2FpdGluZyBmb3IgY2FyZCB0byByZXNldCAocmVnPTB4JTA0eCkh
XG4iLA0KLQkJICAgICAgIElPX1RZUEUoaHcpLCBody0+aW9iYXNlLCByZWcp
Ow0KKwkJICAgICAgIGh3LT5pb2Jhc2UsIHJlZyk7DQogCQllcnIgPSAtRVRJ
TUVET1VUOw0KIAkJZ290byBvdXQ7DQogCX0NCkBAIC0yMzUsMTMgKzIzNCwx
NiBAQA0KIAllcnIgPSBoZXJtZXNfaXNzdWVfY21kKGh3LCBjbWQsIHBhcm0w
KTsNCiAJaWYgKGVycikgew0KIAkJaWYgKCEgaGVybWVzX3ByZXNlbnQoaHcp
KSB7DQotCQkJcHJpbnRrKEtFUk5fV0FSTklORyAiaGVybWVzIEAgJXMweCVs
eDogIg0KLQkJCSAgICAgICAiQ2FyZCByZW1vdmVkIHdoaWxlIGlzc3Vpbmcg
Y29tbWFuZC5cbiIsDQotCQkJICAgICAgIElPX1RZUEUoaHcpLCBody0+aW9i
YXNlKTsNCisJCQlpZiAobmV0X3JhdGVsaW1pdCgpKQ0KKwkJCQlwcmludGso
S0VSTl9XQVJOSU5HICJoZXJtZXMgQCAlcDogIg0KKwkJCQkgICAgICAgIkNh
cmQgcmVtb3ZlZCB3aGlsZSBpc3N1aW5nIGNvbW1hbmQgIg0KKwkJCQkgICAg
ICAgIjB4JTA0eC5cbiIsIGh3LT5pb2Jhc2UsIGNtZCk7DQogCQkJZXJyID0g
LUVOT0RFVjsNCiAJCX0gZWxzZSANCi0JCQlwcmludGsoS0VSTl9FUlIgImhl
cm1lcyBAICVzMHglbHg6IEVycm9yICVkIGlzc3VpbmcgY29tbWFuZC5cbiIs
DQotCQkJICAgICAgIElPX1RZUEUoaHcpLCBody0+aW9iYXNlLCBlcnIpOw0K
KwkJCWlmIChuZXRfcmF0ZWxpbWl0KCkpDQorCQkJCXByaW50ayhLRVJOX0VS
UiAiaGVybWVzIEAgJXA6ICINCisJCQkJICAgICAgICJFcnJvciAlZCBpc3N1
aW5nIGNvbW1hbmQgMHglMDR4LlxuIiwNCisJCQkJICAgICAgIGh3LT5pb2Jh
c2UsIGVyciwgY21kKTsNCiAJCWdvdG8gb3V0Ow0KIAl9DQogDQpAQCAtMjU0
LDE3ICsyNTYsMTYgQEANCiAJfQ0KIA0KIAlpZiAoISBoZXJtZXNfcHJlc2Vu
dChodykpIHsNCi0JCXByaW50ayhLRVJOX1dBUk5JTkcgImhlcm1lcyBAICVz
MHglbHg6ICINCi0JCSAgICAgICAiQ2FyZCByZW1vdmVkIHdoaWxlIHdhaXRp
bmcgZm9yIGNvbW1hbmQgY29tcGxldGlvbi5cbiIsDQotCQkgICAgICAgSU9f
VFlQRShodyksIGh3LT5pb2Jhc2UpOw0KKwkJcHJpbnRrKEtFUk5fV0FSTklO
RyAiaGVybWVzIEAgJXA6IENhcmQgcmVtb3ZlZCAiDQorCQkgICAgICAgIndo
aWxlIHdhaXRpbmcgZm9yIGNvbW1hbmQgMHglMDR4IGNvbXBsZXRpb24uXG4i
LA0KKwkJICAgICAgIGh3LT5pb2Jhc2UsIGNtZCk7DQogCQllcnIgPSAtRU5P
REVWOw0KIAkJZ290byBvdXQ7DQogCX0NCiAJCQ0KIAlpZiAoISAocmVnICYg
SEVSTUVTX0VWX0NNRCkpIHsNCi0JCXByaW50ayhLRVJOX0VSUiAiaGVybWVz
IEAgJXMweCVseDogIg0KLQkJICAgICAgICJUaW1lb3V0IHdhaXRpbmcgZm9y
IGNvbW1hbmQgY29tcGxldGlvbi5cbiIsDQotCQkgICAgICAgSU9fVFlQRSho
dyksIGh3LT5pb2Jhc2UpOw0KKwkJcHJpbnRrKEtFUk5fRVJSICJoZXJtZXMg
QCAlcDogVGltZW91dCB3YWl0aW5nIGZvciAiDQorCQkgICAgICAgImNvbW1h
bmQgMHglMDR4IGNvbXBsZXRpb24uXG4iLCBody0+aW9iYXNlLCBjbWQpOw0K
IAkJZXJyID0gLUVUSU1FRE9VVDsNCiAJCWdvdG8gb3V0Ow0KIAl9DQpAQCAt
MzA5LDE2ICszMTAsMTYgQEANCiAJfQ0KIAkNCiAJaWYgKCEgaGVybWVzX3By
ZXNlbnQoaHcpKSB7DQotCQlwcmludGsoS0VSTl9XQVJOSU5HICJoZXJtZXMg
QCAlczB4JWx4OiAiDQorCQlwcmludGsoS0VSTl9XQVJOSU5HICJoZXJtZXMg
QCAlcDogIg0KIAkJICAgICAgICJDYXJkIHJlbW92ZWQgd2FpdGluZyBmb3Ig
ZnJhbWUgYWxsb2NhdGlvbi5cbiIsDQotCQkgICAgICAgSU9fVFlQRShodyks
IGh3LT5pb2Jhc2UpOw0KKwkJICAgICAgIGh3LT5pb2Jhc2UpOw0KIAkJcmV0
dXJuIC1FTk9ERVY7DQogCX0NCiAJCQ0KIAlpZiAoISAocmVnICYgSEVSTUVT
X0VWX0FMTE9DKSkgew0KLQkJcHJpbnRrKEtFUk5fRVJSICJoZXJtZXMgQCAl
czB4JWx4OiAiDQorCQlwcmludGsoS0VSTl9FUlIgImhlcm1lcyBAICVwOiAi
DQogCQkgICAgICAgIlRpbWVvdXQgd2FpdGluZyBmb3IgZnJhbWUgYWxsb2Nh
dGlvblxuIiwNCi0JCSAgICAgICBJT19UWVBFKGh3KSwgaHctPmlvYmFzZSk7
DQorCQkgICAgICAgaHctPmlvYmFzZSk7DQogCQlyZXR1cm4gLUVUSU1FRE9V
VDsNCiAJfQ0KIA0KQEAgLTM4MywxMiArMzg0LDE3IEBADQogCQlyZWcgPSBo
ZXJtZXNfcmVhZF9yZWcoaHcsIG9yZWcpOw0KIAl9DQogDQotCWlmIChyZWcg
JiBIRVJNRVNfT0ZGU0VUX0JVU1kpIHsNCi0JCXJldHVybiAtRVRJTUVET1VU
Ow0KLQl9DQorCWlmIChyZWcgIT0gb2Zmc2V0KSB7DQorCQlwcmludGsoS0VS
Tl9FUlIgImhlcm1lcyBAICVwOiBCQVAlZCBvZmZzZXQgJXM6ICINCisJCSAg
ICAgICAicmVnPTB4JXggaWQ9MHgleCBvZmZzZXQ9MHgleFxuIiwgaHctPmlv
YmFzZSwgYmFwLA0KKwkJICAgICAgIChyZWcgJiBIRVJNRVNfT0ZGU0VUX0JV
U1kpID8gInRpbWVvdXQiIDogImVycm9yIiwNCisJCSAgICAgICByZWcsIGlk
LCBvZmZzZXQpOw0KKw0KKwkJaWYgKHJlZyAmIEhFUk1FU19PRkZTRVRfQlVT
WSkgew0KKwkJCXJldHVybiAtRVRJTUVET1VUOw0KKwkJfQ0KIA0KLQlpZiAo
cmVnICYgSEVSTUVTX09GRlNFVF9FUlIpIHsNCi0JCXJldHVybiAtRUlPOw0K
KwkJcmV0dXJuIC1FSU87CQkvKiBlcnJvciBvciB3cm9uZyBvZmZzZXQgKi8N
CiAJfQ0KIA0KIAlyZXR1cm4gMDsNCkBAIC00ODQsMTQgKzQ5MCwxMyBAQA0K
IAkJKmxlbmd0aCA9IHJsZW5ndGg7DQogDQogCWlmIChydHlwZSAhPSByaWQp
DQotCQlwcmludGsoS0VSTl9XQVJOSU5HICJoZXJtZXMgQCAlczB4JWx4OiAi
DQotCQkgICAgICAgImhlcm1lc19yZWFkX2x0digpOiByaWQgICgweCUwNHgp
IGRvZXMgbm90IG1hdGNoIHR5cGUgKDB4JTA0eClcbiIsDQotCQkgICAgICAg
SU9fVFlQRShodyksIGh3LT5pb2Jhc2UsIHJpZCwgcnR5cGUpOw0KKwkJcHJp
bnRrKEtFUk5fV0FSTklORyAiaGVybWVzIEAgJXA6ICVzKCk6ICINCisJCSAg
ICAgICAicmlkICgweCUwNHgpIGRvZXMgbm90IG1hdGNoIHR5cGUgKDB4JTA0
eClcbiIsDQorCQkgICAgICAgaHctPmlvYmFzZSwgX19GVU5DVElPTl9fLCBy
aWQsIHJ0eXBlKTsNCiAJaWYgKEhFUk1FU19SRUNMRU5fVE9fQllURVMocmxl
bmd0aCkgPiBidWZzaXplKQ0KLQkJcHJpbnRrKEtFUk5fV0FSTklORyAiaGVy
bWVzIEAgJXMweCVseDogIg0KKwkJcHJpbnRrKEtFUk5fV0FSTklORyAiaGVy
bWVzIEAgJXA6ICINCiAJCSAgICAgICAiVHJ1bmNhdGluZyBMVFYgcmVjb3Jk
IGZyb20gJWQgdG8gJWQgYnl0ZXMuICINCi0JCSAgICAgICAiKHJpZD0weCUw
NHgsIGxlbj0weCUwNHgpXG4iLA0KLQkJICAgICAgIElPX1RZUEUoaHcpLCBo
dy0+aW9iYXNlLA0KKwkJICAgICAgICIocmlkPTB4JTA0eCwgbGVuPTB4JTA0
eClcbiIsIGh3LT5pb2Jhc2UsDQogCQkgICAgICAgSEVSTUVTX1JFQ0xFTl9U
T19CWVRFUyhybGVuZ3RoKSwgYnVmc2l6ZSwgcmlkLCBybGVuZ3RoKTsNCiAN
CiAJbndvcmRzID0gbWluKCh1bnNpZ25lZClybGVuZ3RoIC0gMSwgYnVmc2l6
ZSAvIDIpOw0KLS0tIGEvZHJpdmVycy9uZXQvd2lyZWxlc3Mvb3Jpbm9jby5o
LnByaW50awkyMDA1LTAxLTIyIDE1OjU1OjAwLjM3NDcyNzI4OCAtMDUwMA0K
KysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3Mvb3Jpbm9jby5oCTIwMDUtMDEt
MjIgMTU6NTU6MzcuMjE5MTI2MDg4IC0wNTAwDQpAQCAtMTI3LDcgKzEyNyw3
IEBADQogew0KIAlzcGluX2xvY2tfaXJxc2F2ZSgmcHJpdi0+bG9jaywgKmZs
YWdzKTsNCiAJaWYgKHByaXYtPmh3X3VuYXZhaWxhYmxlKSB7DQotCQlwcmlu
dGsoS0VSTl9ERUJVRyAib3Jpbm9jb19sb2NrKCkgY2FsbGVkIHdpdGggaHdf
dW5hdmFpbGFibGUgKGRldj0lcClcbiIsDQorCQlERUJVRygxLCAib3Jpbm9j
b19sb2NrKCkgY2FsbGVkIHdpdGggaHdfdW5hdmFpbGFibGUgKGRldj0lcClc
biIsDQogCQkgICAgICAgcHJpdi0+bmRldik7DQogCQlzcGluX3VubG9ja19p
cnFyZXN0b3JlKCZwcml2LT5sb2NrLCAqZmxhZ3MpOw0KIAkJcmV0dXJuIC1F
QlVTWTsNCi0tLSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL29yaW5vY29fY3Mu
Yy5wcmludGsJMjAwNS0wMS0yMiAxNTo1MTo1OS4wNDkyOTI5NDQgLTA1MDAN
CisrKyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL29yaW5vY29fY3MuYwkyMDA1
LTAxLTIyIDE1OjU0OjA5LjEyODUxNzg5NiAtMDUwMA0KQEAgLTM5MCw3ICsz
OTAsNyBAQA0KIAkJbGFzdF9yZXQgPSBwY21jaWFfZ2V0X25leHRfdHVwbGUo
aGFuZGxlLCAmdHVwbGUpOw0KIAkJaWYgKGxhc3RfcmV0ICA9PSBDU19OT19N
T1JFX0lURU1TKSB7DQogCQkJcHJpbnRrKEtFUk5fRVJSIFBGWCAiR2V0TmV4
dFR1cGxlKCk6IE5vIG1hdGNoaW5nICINCi0JCQkgICAgICAgIkNJUyBjb25m
aWd1cmF0aW9uLCBtYXliZSB5b3UgbmVlZCB0aGUgIg0KKwkJCSAgICAgICAi
Q0lTIGNvbmZpZ3VyYXRpb24uICBNYXliZSB5b3UgbmVlZCB0aGUgIg0KIAkJ
CSAgICAgICAiaWdub3JlX2Npc192Y2M9MSBwYXJhbWV0ZXIuXG4iKTsNCiAJ
CQlnb3RvIGNzX2ZhaWxlZDsNCiAJCX0NCi0tLSBhL2RyaXZlcnMvbmV0L3dp
cmVsZXNzL29yaW5vY29fdG1kLmMucHJpbnRrCTIwMDUtMDEtMjIgMTY6MDI6
NDguNjc3NTM0NDQwIC0wNTAwDQorKysgYi9kcml2ZXJzL25ldC93aXJlbGVz
cy9vcmlub2NvX3RtZC5jCTIwMDUtMDEtMjIgMTY6MDQ6NDIuNDM3MjQwMzM2
IC0wNTAwDQpAQCAtOTEsMTUgKzkxLDE2IEBADQogCXN0cnVjdCBuZXRfZGV2
aWNlICpkZXYgPSBOVUxMOw0KIA0KIAllcnIgPSBwY2lfZW5hYmxlX2Rldmlj
ZShwZGV2KTsNCi0JaWYgKGVycikNCi0JCXJldHVybiAtRUlPOw0KKwlpZiAo
ZXJyKSB7DQorCQlwcmludGsoS0VSTl9FUlIgUEZYICJDYW5ub3QgZW5hYmxl
IFBDSSBkZXZpY2VcbiIpOw0KKwkJcmV0dXJuIGVycjsNCisJfQ0KIA0KIAlw
cmludGsoS0VSTl9ERUJVRyBQRlggIlRNRCBzZXR1cFxuIik7DQogCXBjY2Fy
ZF9pb2FkZHIgPSBwY2lfcmVzb3VyY2Vfc3RhcnQocGRldiwgMik7DQogCXBj
Y2FyZF9pb2xlbiA9IHBjaV9yZXNvdXJjZV9sZW4ocGRldiwgMik7DQogCWlm
ICghIHJlcXVlc3RfcmVnaW9uKHBjY2FyZF9pb2FkZHIsIHBjY2FyZF9pb2xl
biwgRFJJVkVSX05BTUUpKSB7DQotCQlwcmludGsoS0VSTl9FUlIgUEZYICJJ
L08gcmVzb3VyY2UgYXQgMHglbHggbGVuIDB4JWx4IGJ1c3lcbiIsDQotCQkJ
cGNjYXJkX2lvYWRkciwgcGNjYXJkX2lvbGVuKTsNCisJCXByaW50ayhLRVJO
X0VSUiBQRlggIkNhbm5vdCBvYnRhaW4gUENJIHJlc291cmNlc1xuIik7DQog
CQlwY2NhcmRfaW9hZGRyID0gMDsNCiAJCWVyciA9IC1FQlVTWTsNCiAJCWdv
dG8gZmFpbDsNCkBAIC0xMTcsNiArMTE4LDcgQEANCiAJLyogQWxsb2NhdGUg
bmV0d29yayBkZXZpY2UgKi8NCiAJZGV2ID0gYWxsb2Nfb3Jpbm9jb2Rldigw
LCBOVUxMKTsNCiAJaWYgKCEgZGV2KSB7DQorCQlwcmludGsoS0VSTl9FUlIg
UEZYICJDYW5ub3QgYWxsb2NhdGUgbmV0d29yayBkZXZpY2VcbiIpOw0KIAkJ
ZXJyID0gLUVOT01FTTsNCiAJCWdvdG8gZmFpbDsNCiAJfQ0KQEAgLTEzNywx
NiArMTM5LDE3IEBADQogCWVyciA9IHJlcXVlc3RfaXJxKHBkZXYtPmlycSwg
b3Jpbm9jb19pbnRlcnJ1cHQsIFNBX1NISVJRLA0KIAkJCSAgZGV2LT5uYW1l
LCBkZXYpOw0KIAlpZiAoZXJyKSB7DQotCQlwcmludGsoS0VSTl9FUlIgUEZY
ICJFcnJvciBhbGxvY2F0aW5nIElSUSAlZC5cbiIsDQotCQkgICAgICAgcGRl
di0+aXJxKTsNCisJCXByaW50ayhLRVJOX0VSUiBQRlggIkNhbm5vdCBhbGxv
Y2F0ZSBJUlEgJWRcbiIsIHBkZXYtPmlycSk7DQogCQllcnIgPSAtRUJVU1k7
DQogCQlnb3RvIGZhaWw7DQogCX0NCiAJZGV2LT5pcnEgPSBwZGV2LT5pcnE7
DQogDQogCWVyciA9IHJlZ2lzdGVyX25ldGRldihkZXYpOw0KLQlpZiAoZXJy
KQ0KLQkJZ290byBmYWlsOw0KKwlpZiAoZXJyKSB7DQorCQlwcmludGsoS0VS
Tl9FUlIgUEZYICJDYW5ub3QgcmVnaXN0ZXIgbmV0d29yayBkZXZpY2VcbiIp
Ow0KKyAJCWdvdG8gZmFpbDsNCisJfQ0KIA0KIAlyZXR1cm4gMDsNCiANCi0t
LSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL29yaW5vY29fcGNpLmMucHJpbnRr
CTIwMDUtMDEtMjIgMTU6NTY6MTYuNTY5MTQzOTc2IC0wNTAwDQorKysgYi9k
cml2ZXJzL25ldC93aXJlbGVzcy9vcmlub2NvX3BjaS5jCTIwMDUtMDEtMjIg
MTY6MTM6MzEuOTkzNzM1NTEyIC0wNTAwDQpAQCAtMTgzLDcgKzE4Myw2IEBA
DQogCQlwcmludGsoS0VSTl9FUlIgUEZYICJCdXN5IHRpbWVvdXRcbiIpOw0K
IAkJcmV0dXJuIC1FVElNRURPVVQ7DQogCX0NCi0JcHJpbnRrKEtFUk5fTk9U
SUNFICJwY2lfY29yIDogcmVnID0gMHglWCAtICVsWCAtICVsWFxuIiwgcmVn
LCB0aW1lb3V0LCBqaWZmaWVzKTsNCiANCiAJcmV0dXJuIDA7DQogfQ0KQEAg
LTIwMiwxNSArMjAxLDE5IEBADQogCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYg
PSBOVUxMOw0KIA0KIAllcnIgPSBwY2lfZW5hYmxlX2RldmljZShwZGV2KTsN
Ci0JaWYgKGVycikNCi0JCXJldHVybiAtRUlPOw0KKwlpZiAoZXJyKSB7DQor
CQlwcmludGsoS0VSTl9FUlIgUEZYICJDYW5ub3QgZW5hYmxlIFBDSSBkZXZp
Y2VcbiIpOw0KKwkJcmV0dXJuIGVycjsNCisJfQ0KIA0KIAkvKiBSZXNvdXJj
ZSAwIGlzIG1hcHBlZCB0byB0aGUgaGVybWVzIHJlZ2lzdGVycyAqLw0KIAlw
Y2lfaW9yYW5nZSA9IHBjaV9yZXNvdXJjZV9zdGFydChwZGV2LCAwKTsNCiAJ
cGNpX2lvbGVuID0gcGNpX3Jlc291cmNlX2xlbihwZGV2LCAwKTsNCiAJcGNp
X2lvYWRkciA9IGlvcmVtYXAocGNpX2lvcmFuZ2UsIHBjaV9pb2xlbik7DQot
CWlmICghIHBjaV9pb3JhbmdlKQ0KKwlpZiAoIXBjaV9pb3JhbmdlKSB7DQor
CQlwcmludGsoS0VSTl9FUlIgUEZYICJDYW5ub3QgcmVtYXAgaGFyZHdhcmUg
cmVnaXN0ZXJzXG4iKTsNCiAJCWdvdG8gZmFpbDsNCisJfQ0KIA0KIAkvKiBB
bGxvY2F0ZSBuZXR3b3JrIGRldmljZSAqLw0KIAlkZXYgPSBhbGxvY19vcmlu
b2NvZGV2KDAsIE5VTEwpOw0KQEAgLTIzNyw4ICsyNDAsNyBAQA0KIAllcnIg
PSByZXF1ZXN0X2lycShwZGV2LT5pcnEsIG9yaW5vY29faW50ZXJydXB0LCBT
QV9TSElSUSwNCiAJCQkgIGRldi0+bmFtZSwgZGV2KTsNCiAJaWYgKGVycikg
ew0KLQkJcHJpbnRrKEtFUk5fRVJSIFBGWCAiRXJyb3IgYWxsb2NhdGluZyBJ
UlEgJWQuXG4iLA0KLQkJICAgICAgIHBkZXYtPmlycSk7DQorCQlwcmludGso
S0VSTl9FUlIgUEZYICJDYW5ub3QgYWxsb2NhdGUgSVJRICVkXG4iLCBwZGV2
LT5pcnEpOw0KIAkJZXJyID0gLUVCVVNZOw0KIAkJZ290byBmYWlsOw0KIAl9
DQpAQCAtMjQ2LDcgKzI0OCw3IEBADQogDQogCS8qIFBlcmZvcm0gYSBDT1Ig
cmVzZXQgdG8gc3RhcnQgdGhlIGNhcmQgKi8NCiAJaWYob3Jpbm9jb19wY2lf
Y29yX3Jlc2V0KHByaXYpICE9IDApIHsNCi0JCXByaW50ayhLRVJOX0VSUiAi
JXM6IEZhaWxlZCB0byBzdGFydCB0aGUgY2FyZFxuIiwgZGV2LT5uYW1lKTsN
CisJCXByaW50ayhLRVJOX0VSUiBQRlggIkluaXRpYWwgcmVzZXQgZmFpbGVk
XG4iKTsNCiAJCWVyciA9IC1FVElNRURPVVQ7DQogCQlnb3RvIGZhaWw7DQog
CX0NCkBAIC0yNTcsNyArMjU5LDcgQEANCiANCiAJZXJyID0gcmVnaXN0ZXJf
bmV0ZGV2KGRldik7DQogCWlmIChlcnIpIHsNCi0JCXByaW50ayhLRVJOX0VS
UiAiJXM6IEZhaWxlZCB0byByZWdpc3RlciBuZXQgZGV2aWNlXG4iLCBkZXYt
Pm5hbWUpOw0KKwkJcHJpbnRrKEtFUk5fRVJSIFBGWCAiRmFpbGVkIHRvIHJl
Z2lzdGVyIG5ldCBkZXZpY2VcbiIpOw0KIAkJZ290byBmYWlsOw0KIAl9DQog
DQotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy9haXJwb3J0LmMucHJpbnRr
CTIwMDUtMDEtMjIgMTU6MjY6NTQuMjIxMDYxNjA4IC0wNTAwDQorKysgYi9k
cml2ZXJzL25ldC93aXJlbGVzcy9haXJwb3J0LmMJMjAwNS0wMS0yMiAxNToy
ODo1NS45NjQ1NTM3ODQgLTA1MDANCkBAIC0xOTQsMTQgKzE5NCwxNCBAQA0K
IAloZXJtZXNfdCAqaHc7DQogDQogCWlmIChtYWNpb19yZXNvdXJjZV9jb3Vu
dChtZGV2KSA8IDEgfHwgbWFjaW9faXJxX2NvdW50KG1kZXYpIDwgMSkgew0K
LQkJcHJpbnRrKEtFUk5fRVJSIFBGWCAid3JvbmcgaW50ZXJydXB0L2FkZHJl
c3NlcyBpbiBPRiB0cmVlXG4iKTsNCisJCXByaW50ayhLRVJOX0VSUiBQRlgg
Ildyb25nIGludGVycnVwdC9hZGRyZXNzZXMgaW4gT0YgdHJlZVxuIik7DQog
CQlyZXR1cm4gLUVOT0RFVjsNCiAJfQ0KIA0KIAkvKiBBbGxvY2F0ZSBzcGFj
ZSBmb3IgcHJpdmF0ZSBkZXZpY2Utc3BlY2lmaWMgZGF0YSAqLw0KIAlkZXYg
PSBhbGxvY19vcmlub2NvZGV2KHNpemVvZigqY2FyZCksIGFpcnBvcnRfaGFy
ZF9yZXNldCk7DQogCWlmICghIGRldikgew0KLQkJcHJpbnRrKEtFUk5fRVJS
IFBGWCAiY2FuJ3QgYWxsb2NhdGUgZGV2aWNlIGRhdGFzXG4iKTsNCisJCXBy
aW50ayhLRVJOX0VSUiBQRlggIkNhbm5vdCBhbGxvY2F0ZSBuZXR3b3JrIGRl
dmljZVxuIik7DQogCQlyZXR1cm4gLUVOT0RFVjsNCiAJfQ0KIAlwcml2ID0g
bmV0ZGV2X3ByaXYoZGV2KTsNCkBAIC0yMjQsMTEgKzIyNCwxMSBAQA0KIAkv
KiBTZXR1cCBpbnRlcnJ1cHRzICYgYmFzZSBhZGRyZXNzICovDQogCWRldi0+
aXJxID0gbWFjaW9faXJxKG1kZXYsIDApOw0KIAlwaHlzX2FkZHIgPSBtYWNp
b19yZXNvdXJjZV9zdGFydChtZGV2LCAwKTsgIC8qIFBoeXNpY2FsIGFkZHJl
c3MgKi8NCi0JcHJpbnRrKEtFUk5fREVCVUcgUEZYICJBaXJwb3J0IGF0IHBo
eXNpY2FsIGFkZHJlc3MgJWx4XG4iLCBwaHlzX2FkZHIpOw0KKwlwcmludGso
S0VSTl9ERUJVRyBQRlggIlBoeXNpY2FsIGFkZHJlc3MgJWx4XG4iLCBwaHlz
X2FkZHIpOw0KIAlkZXYtPmJhc2VfYWRkciA9IHBoeXNfYWRkcjsNCiAJY2Fy
ZC0+dmFkZHIgPSBpb3JlbWFwKHBoeXNfYWRkciwgQUlSUE9SVF9JT19MRU4p
Ow0KIAlpZiAoIWNhcmQtPnZhZGRyKSB7DQotCQlwcmludGsoUEZYICJpb3Jl
bWFwKCkgZmFpbGVkXG4iKTsNCisJCXByaW50ayhLRVJOX0VSUiBQRlggImlv
cmVtYXAoKSBmYWlsZWRcbiIpOw0KIAkJZ290byBmYWlsZWQ7DQogCX0NCiAN
CkBAIC0yNTMsNyArMjUzLDcgQEANCiAJCXByaW50ayhLRVJOX0VSUiBQRlgg
InJlZ2lzdGVyX25ldGRldigpIGZhaWxlZFxuIik7DQogCQlnb3RvIGZhaWxl
ZDsNCiAJfQ0KLQlwcmludGsoS0VSTl9ERUJVRyBQRlggImNhcmQgcmVnaXN0
ZXJlZCBmb3IgaW50ZXJmYWNlICVzXG4iLCBkZXYtPm5hbWUpOw0KKwlwcmlu
dGsoS0VSTl9ERUJVRyBQRlggIkNhcmQgcmVnaXN0ZXJlZCBmb3IgaW50ZXJm
YWNlICVzXG4iLCBkZXYtPm5hbWUpOw0KIAljYXJkLT5uZGV2X3JlZ2lzdGVy
ZWQgPSAxOw0KIAlyZXR1cm4gMDsNCiAgZmFpbGVkOg0K

--279707962-1385008808-1106446908=:11940--
