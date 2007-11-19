From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 01/22] NET: DM9000 use dev_xxx() instead of printk for output.
Date: Mon, 19 Nov 2007 20:39:11 +0000
Message-ID: <20071119204012.926963359@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61692 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752342AbXKSVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:18:18 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-devmacros.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move to using dev_dbg() and friends for the output of
information to the user.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.22-quilt4/drivers/net/dm9000.c
===================================================================
--- linux-2.6.22-quilt4.orig/drivers/net/dm9000.c
+++ linux-2.6.22-quilt4/drivers/net/dm9000.c
@@ -142,6 +142,8 @@ typedef struct board_info {
 	void (*outblk)(void __iomem *port, void *data, int length);
 	void (*dumpblk)(void __iomem *port, int length);
 
+	struct device	*dev;	     /* parent device */
+
 	struct resource	*addr_res;   /* resources found */
 	struct resource *data_res;
 	struct resource	*addr_req;   /* resources requested */
@@ -187,7 +189,8 @@ static void program_eeprom(board_info_t 
 static void
 dm9000_reset(board_info_t * db)
 {
-	PRINTK1("dm9000x: resetting\n");
+	dev_dbg(db->dev, "resetting device\n");
+
 	/* RESET device */
 	writeb(DM9000_NCR, db->io_addr);
 	udelay(200);
@@ -303,14 +306,10 @@ static void dm9000_set_io(struct board_i
 		db->inblk   = dm9000_inblk_8bit;
 		break;
 
-	case 2:
-		db->dumpblk = dm9000_dumpblk_16bit;
-		db->outblk  = dm9000_outblk_16bit;
-		db->inblk   = dm9000_inblk_16bit;
-		break;
 
 	case 3:
-		printk(KERN_ERR PFX ": 3 byte IO, falling back to 16bit\n");
+		dev_dbg(db->dev, ": 3 byte IO, falling back to 16bit\n");
+	case 2:
 		db->dumpblk = dm9000_dumpblk_16bit;
 		db->outblk  = dm9000_outblk_16bit;
 		db->inblk   = dm9000_inblk_16bit;
@@ -413,19 +412,21 @@ dm9000_probe(struct platform_device *pde
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof (struct board_info));
 	if (!ndev) {
-		printk("%s: could not allocate device.\n", CARDNAME);
+		dev_err(&pdev->dev, "could not allocate device.\n");
 		return -ENOMEM;
 	}
 
 	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	PRINTK2("dm9000_probe()");
+	dev_dbg(&pdev->dev, "probing device\n");
 
 	/* setup board info structure */
 	db = (struct board_info *) ndev->priv;
 	memset(db, 0, sizeof (*db));
 
+	db->dev = &pdev->dev;
+
 	spin_lock_init(&db->lock);
 
 	if (pdev->num_resources < 2) {
@@ -454,7 +455,7 @@ dm9000_probe(struct platform_device *pde
 
 		if (db->addr_res == NULL || db->data_res == NULL ||
 		    db->irq_res == NULL) {
-			printk(KERN_ERR PFX "insufficient resources\n");
+			dev_err(db->dev, "insufficient resources\n");
 			ret = -ENOENT;
 			goto out;
 		}
@@ -464,7 +465,7 @@ dm9000_probe(struct platform_device *pde
 						  pdev->name);
 
 		if (db->addr_req == NULL) {
-			printk(KERN_ERR PFX "cannot claim address reg area\n");
+			dev_err(db->dev, "cannot claim address reg area\n");
 			ret = -EIO;
 			goto out;
 		}
@@ -472,7 +473,7 @@ dm9000_probe(struct platform_device *pde
 		db->io_addr = ioremap(db->addr_res->start, i);
 
 		if (db->io_addr == NULL) {
-			printk(KERN_ERR "failed to ioremap address reg\n");
+			dev_err(db->dev, "failed to ioremap address reg\n");
 			ret = -EINVAL;
 			goto out;
 		}
@@ -482,7 +483,7 @@ dm9000_probe(struct platform_device *pde
 						  pdev->name);
 
 		if (db->data_req == NULL) {
-			printk(KERN_ERR PFX "cannot claim data reg area\n");
+			dev_err(db->dev, "cannot claim data reg area\n");
 			ret = -EIO;
 			goto out;
 		}
@@ -490,7 +491,7 @@ dm9000_probe(struct platform_device *pde
 		db->io_data = ioremap(db->data_res->start, iosize);
 
 		if (db->io_data == NULL) {
-			printk(KERN_ERR "failed to ioremap data reg\n");
+			dev_err(db->dev,"failed to ioremap data reg\n");
 			ret = -EINVAL;
 			goto out;
 		}
@@ -544,11 +545,11 @@ dm9000_probe(struct platform_device *pde
 
 		if (id_val == DM9000_ID)
 			break;
-		printk("%s: read wrong id 0x%08x\n", CARDNAME, id_val);
+		dev_err(db->dev, "read wrong id 0x%08x\n", id_val);
 	}
 
 	if (id_val != DM9000_ID) {
-		printk("%s: wrong id: 0x%08x\n", CARDNAME, id_val);
+		dev_err(db->dev, "wrong id: 0x%08x\n", id_val);
 		goto release;
 	}
 
@@ -596,8 +597,8 @@ dm9000_probe(struct platform_device *pde
 	}
 
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		printk("%s: Invalid ethernet MAC address.  Please "
-		       "set using ifconfig\n", ndev->name);
+		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
+			 "set using ifconfig\n", ndev->name);
 
 	platform_set_drvdata(pdev, ndev);
 	ret = register_netdev(ndev);
@@ -613,7 +614,7 @@ dm9000_probe(struct platform_device *pde
 
  release:
  out:
-	printk("%s: not found (%d).\n", CARDNAME, ret);
+	dev_err(db->dev, "not found (%d).\n", ret);
 
 	dm9000_release_board(pdev, db);
 	free_netdev(ndev);
@@ -630,7 +631,7 @@ dm9000_open(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
 
-	PRINTK2("entering dm9000_open\n");
+	dev_dbg(db->dev, "entering %s\n", __func__);
 
 	if (request_irq(dev->irq, &dm9000_interrupt, DM9000_IRQ_FLAGS, dev->name, dev))
 		return -EAGAIN;
@@ -916,7 +917,7 @@ dm9000_rx(struct net_device *dev)
 
 		/* Status check: this byte must be 0 or 1 */
 		if (rxbyte > DM9000_PKT_RDY) {
-			printk("status check failed: %d\n", rxbyte);
+			dev_warn(db->dev, "status check fail: %d\n", rxbyte);
 			iow(db, DM9000_RCR, 0x00);	/* Stop Device */
 			iow(db, DM9000_ISR, IMR_PAR);	/* Stop INT request */
 			return;
@@ -936,25 +937,25 @@ dm9000_rx(struct net_device *dev)
 		/* Packet Status check */
 		if (RxLen < 0x40) {
 			GoodPacket = false;
-			PRINTK1("Bad Packet received (runt)\n");
+			dev_dbg(db->dev, "Bad Packet received (runt)\n");
 		}
 
 		if (RxLen > DM9000_PKT_MAX) {
-			PRINTK1("RST: RX Len:%x\n", RxLen);
+			dev_dbg(db->dev, "RST: RX Len:%x\n", RxLen);
 		}
 
 		if (rxhdr.RxStatus & 0xbf) {
 			GoodPacket = false;
 			if (rxhdr.RxStatus & 0x01) {
-				PRINTK1("fifo error\n");
+				dev_dbg(db->dev, "fifo error\n");
 				db->stats.rx_fifo_errors++;
 			}
 			if (rxhdr.RxStatus & 0x02) {
-				PRINTK1("crc error\n");
+				dev_dbg(db->dev, "crc error\n");
 				db->stats.rx_crc_errors++;
 			}
 			if (rxhdr.RxStatus & 0x80) {
-				PRINTK1("length error\n");
+				dev_dbg(db->dev, "length error\n");
 				db->stats.rx_length_errors++;
 			}
 		}
@@ -1203,8 +1204,7 @@ dm9000_drv_remove(struct platform_device
 	dm9000_release_board(pdev, (board_info_t *) ndev->priv);
 	free_netdev(ndev);		/* free device structure */
 
-	PRINTK1("clean_module() exit\n");
-
+	dev_dbg(&pdev->dev, "released and freed device\n");
 	return 0;
 }
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
