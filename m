From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: 5/x: [NETDRV] Move register_netdev into probe function
Date: Sun, 6 Jun 2004 18:41:19 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040606084119.GA5399@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au> <405C294D.5040508@pobox.com> <20040520111937.GA21804@gondor.apana.org.au> <20040522074435.GA9628@gondor.apana.org.au> <20040529084109.GA13032@gondor.apana.org.au> <40BE3778.1020404@pobox.com> <20040605052737.GA27406@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040605052737.GA27406@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 05, 2004 at 03:27:37PM +1000, herbert wrote:
> 
> So in its place I present the following patch that merges duplicate
> register_netdev calls by moving them to the probe function.

Here is the patch to move register_netdev into the probe function
for the remaining modules.  This allows us to print the information
that the driver wants to after the device has been registered.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff -Nru a/drivers/net/3c501.c b/drivers/net/3c501.c
--- a/drivers/net/3c501.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/3c501.c	2004-06-06 18:38:44 +10:00
@@ -189,12 +189,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	release_region(dev->base_addr, EL1_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -220,6 +215,7 @@
 	unsigned char station_addr[6];
 	int autoirq = 0;
 	int i;
+	int err;
 
 	/*
 	 *	Reserve I/O resource for exclusive use by this driver
@@ -321,7 +317,11 @@
 	dev->get_stats = &el1_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	return 0;
+
+	err = register_netdev(dev);
+	if (err)
+		release_region(ioaddr, EL1_IO_EXTENT);
+	return err;
 }
 
 /**
diff -Nru a/drivers/net/3c507.c b/drivers/net/3c507.c
--- a/drivers/net/3c507.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/3c507.c	2004-06-06 18:38:44 +10:00
@@ -341,13 +341,7 @@
 
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, EL16_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -453,7 +447,13 @@
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->ethtool_ops = &netdev_ethtool_ops;
  	dev->flags &= ~IFF_MULTICAST;	/* Multicast doesn't work */
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out1;
 	return 0;
+out1:
+	free_irq(irq, dev);
 out:
 	release_region(ioaddr, EL16_IO_EXTENT);
 	return retval;
diff -Nru a/drivers/net/3c527.c b/drivers/net/3c527.c
--- a/drivers/net/3c527.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/3c527.c	2004-06-06 18:38:44 +10:00
@@ -212,7 +212,7 @@
 
 
 /* Index to functions, as function prototypes. */
-static int	mc32_probe1(struct net_device *dev, int ioaddr);
+static int	mc32_probe1(struct net_device *dev, int ioaddr, char *name);
 static int      mc32_command(struct net_device *dev, u16 cmd, void *data, int len);
 static int	mc32_open(struct net_device *dev);
 static void	mc32_timeout(struct net_device *dev);
@@ -266,25 +266,16 @@
 	   Autodetecting MCA cards is extremely simple. 
 	   Just search for the card. */
 
+	err = -ENODEV;
 	for(i = 0; (mc32_adapters[i].name != NULL); i++) {
 		current_mca_slot = 
 			mca_find_unused_adapter(mc32_adapters[i].id, 0);
 
 		if(current_mca_slot != MCA_NOTFOUND) {
-			if(!mc32_probe1(dev, current_mca_slot))
-			{
-				mca_set_adapter_name(current_mca_slot, 
-						mc32_adapters[i].name);
-				mca_mark_as_used(current_mca_slot);
-				err = register_netdev(dev);
-				if (err) {
-					cleanup_card(dev);
-					free_netdev(dev);
-					dev = ERR_PTR(err);
-				}
+			err = mc32_probe1(dev, current_mca_slot,
+					  mc32_adapters[i].name);
+			if (!err)
 				return dev;
-			}
-			
 		}
 	}
 	free_netdev(dev);
@@ -295,6 +286,7 @@
  * mc32_probe1	-	Check a given slot for a board and test the card
  * @dev:  Device structure to fill in
  * @slot: The MCA bus slot being used by this card
+ * @name: Descriptive name of device
  *
  * Decode the slot data and configure the card structures. Having done this we
  * can reset the card and configure it. The card does a full self test cycle
@@ -302,7 +294,7 @@
  * failure case or some addresses we use to find the board internals.
  */
 
-static int __init mc32_probe1(struct net_device *dev, int slot)
+static int __init mc32_probe1(struct net_device *dev, int slot, char *name)
 {
 	static unsigned version_printed;
 	int i, err;
@@ -530,8 +522,16 @@
 	dev->watchdog_timeo	= HZ*5;	/* Board does all the work */
 	dev->ethtool_ops	= &netdev_ethtool_ops;
 
+	mca_set_adapter_name(slot, name);
+	mca_mark_as_used(slot);
+	err = register_netdev(dev);
+	if (err)
+		goto err_exit_mca;
 	return 0;
 
+err_exit_mca:
+	mca_mark_as_unused(slot);
+	mca_set_adapter_name(slot, NULL);
 err_exit_irq:
 	free_irq(dev->irq, dev);
 err_exit_ports:
diff -Nru a/drivers/net/apne.c b/drivers/net/apne.c
--- a/drivers/net/apne.c	2004-06-06 18:38:45 +10:00
+++ b/drivers/net/apne.c	2004-06-06 18:38:45 +10:00
@@ -181,21 +181,13 @@
 		free_netdev(dev);
 		return ERR_PTR(err);
 	}
-	err = register_netdev(dev);
-	if (!err)
-		return dev;
-
-	pcmcia_disable_irq();
-	free_irq(IRQ_AMIGA_PORTS, dev);
-	pcmcia_reset();
-	release_region(IOBASE, 0x20);
-	free_netdev(dev);
-	return ERR_PTR(err);
+	return dev;
 }
 
 static int __init apne_probe1(struct net_device *dev, int ioaddr)
 {
     int i;
+    int err;
     unsigned char SA_prom[32];
     int wordlength = 2;
     const char *name = NULL;
@@ -345,7 +337,14 @@
 
     apne_owned = 1;
 
-    return 0;
+    err = register_netdev(dev);
+    if (err) {
+	pcmcia_disable_irq();
+	free_irq(IRQ_AMIGA_PORTS, dev);
+	pcmcia_reset();
+    }
+
+    return err;
 }
 
 static int
diff -Nru a/drivers/net/at1700.c b/drivers/net/at1700.c
--- a/drivers/net/at1700.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/at1700.c	2004-06-06 18:38:44 +10:00
@@ -295,12 +295,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -551,8 +546,13 @@
 		goto err_mca;
 	}
 
+	ret = register_netdev(dev);
+	if (ret)
+		goto err_irq;
 	return 0;
 
+err_irq:
+	free_irq(dev->irq, NULL);
 err_mca:
 #ifdef CONFIG_MCA
 	if (slot >= 0)
diff -Nru a/drivers/net/atarilance.c b/drivers/net/atarilance.c
--- a/drivers/net/atarilance.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/atarilance.c	2004-06-06 18:38:44 +10:00
@@ -395,11 +395,7 @@
 	for( i = 0; i < N_LANCE_ADDR; ++i ) {
 		if (lance_probe1( dev, &lance_addr_list[i] )) {
 			found = 1;
-			err = register_netdev(dev);
-			if (!err)
-				return dev;
-			free_irq(dev->irq, dev);
-			break;
+			return dev;
 		}
 	}
 	free_netdev(dev);
@@ -647,6 +643,10 @@
 
 	memset( &lp->stats, 0, sizeof(lp->stats) );
 
+	if (register_netdev(dev)) {
+		free_irq(dev->irq, dev);
+		return 0;
+	}
 	return( 1 );
 }
 
diff -Nru a/drivers/net/bagetlance.c b/drivers/net/bagetlance.c
--- a/drivers/net/bagetlance.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/bagetlance.c	2004-06-06 18:38:44 +10:00
@@ -491,12 +491,7 @@
 	}
 	if (!found)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	free_irq(dev->irq, dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -730,6 +725,10 @@
 
 	memset( &lp->stats, 0, sizeof(lp->stats) );
 
+	if (register_netdev(dev)) {
+		free_irq(dev->irq, dev);
+		return 0;
+	}
 	return( 1 );
 }
 
diff -Nru a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
--- a/drivers/net/ewrk3.c	2004-06-06 18:38:45 +10:00
+++ b/drivers/net/ewrk3.c	2004-06-06 18:38:45 +10:00
@@ -378,14 +378,6 @@
 	err = isa_probe(dev, iobase);
 	if (err != 0) 
 		err = eisa_probe(dev, iobase);
-
-	if (err)
-		return err;
-
-	err = register_netdev(dev);
-	if (err)
-		release_region(dev->base_addr, EWRK3_TOTAL_SIZE);
-
 	return err;
 }
 
@@ -615,7 +607,7 @@
 	
 	dev->mem_start = 0;
 
-	return 0;
+	return register_netdev(dev);
 }
 
 
diff -Nru a/drivers/net/fec.c b/drivers/net/fec.c
--- a/drivers/net/fec.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/fec.c	2004-06-06 18:38:44 +10:00
@@ -1789,7 +1789,9 @@
 	mii_queue(dev, mk_mii_read(MII_REG_PHYIR1), mii_discover_phy);
 
 	found++;
-	return 0;
+
+	/* XXX: missing cleanup here */
+	return register_netdev(dev);
 }
 
 /* This function is called to start or restart the FEC during a link
@@ -1960,11 +1962,6 @@
 		return err;
 	}
 
-	if (register_netdev(dev) != 0) {
-		/* XXX: missing cleanup here */
-		free_netdev(dev);
-		return -EIO;
-	}
 	fec_dev = dev;
 	return(0);
 }
diff -Nru a/drivers/net/fmv18x.c b/drivers/net/fmv18x.c
--- a/drivers/net/fmv18x.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/fmv18x.c	2004-06-06 18:38:44 +10:00
@@ -163,13 +163,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, FMV18X_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -305,6 +299,10 @@
 	dev->watchdog_timeo	= HZ/10;
 	dev->get_stats		= net_get_stats;
 	dev->set_multicast_list = set_multicast_list;
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out_irq;
 	return 0;
 
 out_irq:
diff -Nru a/drivers/net/hplance.c b/drivers/net/hplance.c
--- a/drivers/net/hplance.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/hplance.c	2004-06-06 18:38:44 +10:00
@@ -50,7 +50,7 @@
  * plus board-specific init, open and close actions. 
  * Oh, and we need to tell the generic code how to read and write LANCE registers...
  */
-static void hplance_init(struct net_device *dev, int scode);
+static int hplance_init(struct net_device *dev, int scode);
 static int hplance_open(struct net_device *dev);
 static int hplance_close(struct net_device *dev);
 static void hplance_writerap(void *priv, unsigned short value);
@@ -95,8 +95,7 @@
                         break;
                 
 		dio_config_board(scode);
-                hplance_init(dev, scode);
-		if (!register_netdev(dev)) {
+		if (!hplance_init(dev, scode)) {
 			struct hplance_private *lp = netdev_priv(dev);
 			lp->next_module = root_hplance_dev;
 			root_hplance_dev = lp;
@@ -109,7 +108,7 @@
 }
 
 /* Initialise a single lance board at the given select code */
-static void __init hplance_init(struct net_device *dev, int scode)
+static int __init hplance_init(struct net_device *dev, int scode)
 {
         const char *name = dio_scodetoname(scode);
         void *va = dio_scodetoviraddr(scode);
@@ -158,6 +157,8 @@
         lp->scode = scode;
 	lp->base = va;
 	printk(", irq %d\n", lp->lance.irq);
+
+	return register_netdev(dev);
 }
 
 /* This is disgusting. We have to check the DIO status register for ack every
diff -Nru a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
--- a/drivers/net/ibmlana.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/ibmlana.c	2004-06-06 18:38:44 +10:00
@@ -913,6 +913,7 @@
 {
 	int force_detect = 0;
 	int slot, z;
+	int err;
 	int base = 0, irq = 0, iobase = 0, memlen = 0;
 	ibmlana_priv *priv;
 	ibmlana_medium medium;
@@ -1014,7 +1015,14 @@
 
 	startslot = slot + 1;
 
-	return 0;
+	err = register_netdev(dev);
+	if (err) {
+		release_region(iobase, IBM_LANA_IORANGE);
+		mca_mark_as_unused(slot);
+		mca_set_adapter_name(slot, "");
+		mca_set_adapter_procfn(slot, NULL, NULL);
+	}
+	return err;
 }
 
 /* ------------------------------------------------------------------------
@@ -1047,15 +1055,6 @@
 		dev->irq = irq;
 		dev->base_addr = io;
 		if (ibmlana_probe(dev)) {
-			free_netdev(dev);
-			break;
-		}
-		if (register_netdev(dev)) {
-			ibmlana_priv *priv = dev->priv;
-			release_region(dev->base_addr, IBM_LANA_IORANGE);
-			mca_mark_as_unused(priv->slot);
-			mca_set_adapter_name(priv->slot, "");
-			mca_set_adapter_procfn(priv->slot, NULL, NULL);
 			free_netdev(dev);
 			break;
 		}
diff -Nru a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
--- a/drivers/net/jazzsonic.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/jazzsonic.c	2004-06-06 18:38:44 +10:00
@@ -127,17 +127,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	lp = dev->priv;
-	vdma_free(lp->rba_laddr);
-	kfree(lp->rba);
-	vdma_free(lp->cda_laddr);
-	kfree(lp);
-	release_region(dev->base_addr, 0x100);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -283,7 +273,12 @@
 	SONIC_WRITE(SONIC_FAET,0xffff);
 	SONIC_WRITE(SONIC_MPT,0xffff);
 
+	err = register_netdev(dev);
+	if (err)
+		goto out4;
 	return 0;
+out4:
+	vdma_free(lp->rba_laddr);
 out3:
 	kfree(lp->rba);
 out2:
diff -Nru a/drivers/net/lasi_82596.c b/drivers/net/lasi_82596.c
--- a/drivers/net/lasi_82596.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/lasi_82596.c	2004-06-06 18:38:44 +10:00
@@ -1150,6 +1150,7 @@
 				  struct device *gen_dev)
 {
 	int i;
+	int retval;
 	struct i596_private *lp;
 	char eth_addr[6];
 	dma_addr_t dma_addr;
@@ -1235,7 +1236,13 @@
 
 	CHECK_WBACK_INV(dev->mem_start, sizeof(struct i596_private));
 
-	return 0;
+	retval = register_netdev(netdevice);
+	if (retval) {
+		printk(KERN_WARNING __FILE__ ": register_netdevice ret'd %d\n", retval);
+		dma_free_noncoherent(gen_dev, sizeof(struct i596_private), 
+				     (void *)dev->mem_start, dma_addr);
+	};
+	return retval;
 }
 
 
@@ -1539,15 +1546,6 @@
 		return -ENODEV;
 	}
 
-	retval = register_netdev(netdevice);
-	if (retval) {
-		struct i596_private *lp = netdevice->priv;
-		printk(KERN_WARNING __FILE__ ": register_netdevice ret'd %d\n", retval);
-		dma_free_noncoherent(lp->dev, sizeof(struct i596_private), 
-				    (void *)netdevice->mem_start, lp->dma_addr);
-		free_netdev(netdevice);
-		return -ENODEV;
-	};
 	if (dev->id.sversion == 0x72) {
 		((struct i596_private *)netdevice->priv)->options = OPT_SWAP_PORT;
 	}
diff -Nru a/drivers/net/lp486e.c b/drivers/net/lp486e.c
--- a/drivers/net/lp486e.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/lp486e.c	2004-06-06 18:38:44 +10:00
@@ -1035,6 +1035,10 @@
 	i596_port_do(dev, PORT_SELFTEST, "selftest");
 	i596_port_do(dev, PORT_DUMP, "dump");
 #endif
+
+	ret = register_netdev(dev);
+	if (ret)
+		goto err_out_kfree;
 	return 0;
 
 err_out_kfree:
@@ -1325,12 +1329,6 @@
 	dev->base_addr = io;
 	err = lp486e_probe(dev);
 	if (err) {
-		free_netdev(dev);
-		return err;
-	}
-	err = register_netdev(dev);
-	if (err) {
-		release_region(dev->base_addr, LP486E_TOTAL_SIZE);
 		free_netdev(dev);
 		return err;
 	}
diff -Nru a/drivers/net/mac8390.c b/drivers/net/mac8390.c
--- a/drivers/net/mac8390.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/mac8390.c	2004-06-06 18:38:44 +10:00
@@ -368,9 +368,6 @@
 
 	if (!ndev)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out;
 	return dev;
 
 out:
@@ -438,6 +435,7 @@
 	};
 
 	int access_bitmode;
+	int err;
 	
 	/* Now fill in our stuff */
 	dev->open = &mac8390_open;
@@ -516,6 +514,10 @@
 	}
 		
 	NS8390_init(dev, 0);
+
+	err = register_netdev(dev);
+	if (err)
+		return err;
 
 	/* Good, done, now spit out some messages */
 	printk(KERN_INFO "%s: %s in slot %X (type %s)\n",
diff -Nru a/drivers/net/macsonic.c b/drivers/net/macsonic.c
--- a/drivers/net/macsonic.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/macsonic.c	2004-06-06 18:38:44 +10:00
@@ -132,12 +132,7 @@
 	if (err)
 		goto out;
 found:
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	kfree(dev->priv);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -163,6 +158,7 @@
 {
 	struct sonic_local* lp = NULL;
 	int i;
+	int err;
 
 	/* Allocate the entire chunk of memory for the descriptors.
            Note that this cannot cross a 64K boundary. */
@@ -253,7 +249,10 @@
 	sonic_write(dev, SONIC_FAET, 0xffff);
 	sonic_write(dev, SONIC_MPT, 0xffff);
 
-	return 0;
+	err = register_netdev(dev);
+	if (err)
+		kfree(lp);
+	return err;
 }
 
 int __init mac_onboard_sonic_ethernet_addr(struct net_device* dev)
diff -Nru a/drivers/net/ni5010.c b/drivers/net/ni5010.c
--- a/drivers/net/ni5010.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/ni5010.c	2004-06-06 18:38:44 +10:00
@@ -161,12 +161,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	release_region(dev->base_addr, NI5010_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -352,6 +347,10 @@
 	outb(0, EDLC_XMASK);	/* Mask all xmit interrupts */
 	outb(0xff, EDLC_RCLR);	/* Kill all pending rcv interrupts */
 	outb(0xff, EDLC_XCLR); 	/* Kill all pending xmt interrupts */
+
+	err = register_netdev(dev);
+	if (err)
+		goto out;
 
 	printk(KERN_INFO "%s: NI5010 found at 0x%x, using IRQ %d", dev->name, ioaddr, dev->irq);
 	if (dev->dma) printk(" & DMA %d", dev->dma);
diff -Nru a/drivers/net/ni52.c b/drivers/net/ni52.c
--- a/drivers/net/ni52.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/ni52.c	2004-06-06 18:38:44 +10:00
@@ -406,12 +406,7 @@
 	if (err)
 		goto out;
 got_it:
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	release_region(dev->base_addr, NI52_TOTAL_SIZE);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -545,6 +540,9 @@
 
 	dev->if_port 		= 0;
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto out;
 	return 0;
 out:
 	release_region(ioaddr, NI52_TOTAL_SIZE);
diff -Nru a/drivers/net/ni65.c b/drivers/net/ni65.c
--- a/drivers/net/ni65.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/ni65.c	2004-06-06 18:38:44 +10:00
@@ -392,12 +392,7 @@
 	if (err)
 		goto out;
 
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -409,6 +404,7 @@
 static int __init ni65_probe1(struct net_device *dev,int ioaddr)
 {
 	int i,j;
+	int err;
 	struct priv *p;
 	unsigned long flags;
 
@@ -559,7 +555,11 @@
 	dev->watchdog_timeo	= HZ/2;
 	dev->get_stats		= ni65_get_stats;
 	dev->set_multicast_list = set_multicast_list;
-	return 0; /* everything is OK */
+
+	err = register_netdev(dev);
+	if (err)
+		cleanup_card(dev);
+	return err;
 }
 
 /*
diff -Nru a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
--- a/drivers/net/seeq8005.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/seeq8005.c	2004-06-06 18:38:44 +10:00
@@ -133,12 +133,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	release_region(dev->base_addr, SEEQ8005_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -341,6 +336,9 @@
 	dev->set_multicast_list = set_multicast_list;
 	dev->flags &= ~IFF_MULTICAST;
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto out;
 	return 0;
 out:
 	release_region(ioaddr, SEEQ8005_IO_EXTENT);
diff -Nru a/drivers/net/sk_g16.c b/drivers/net/sk_g16.c
--- a/drivers/net/sk_g16.c	2004-06-06 18:38:45 +10:00
+++ b/drivers/net/sk_g16.c	2004-06-06 18:38:45 +10:00
@@ -581,16 +581,10 @@
 			release_region(io, ETHERCARD_TOTAL_SIZE);
 		}
 	}
-err_out:
 	free_netdev(dev);
 	return ERR_PTR(err);
 
 got_it:
-	err = register_netdev(dev);
-	if (err) {
-		release_region(dev->base_addr, ETHERCARD_TOTAL_SIZE);
-		goto err_out;
-	}
 	return dev;
 
 } /* End of SK_init */
@@ -833,7 +827,9 @@
     SK_print_pos(dev, "End of SK_probe");
     SK_print_ram(dev);
 #endif 
-    return 0;                            /* Initialization done */
+
+    return register_netdev(dev);
+    /* Initialization done */
 } /* End of SK_probe() */
 
 
diff -Nru a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
--- a/drivers/net/smc-ultra32.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/smc-ultra32.c	2004-06-06 18:38:44 +10:00
@@ -143,12 +143,7 @@
 	}
 	if (base >= 0x9000)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -275,6 +270,9 @@
 #endif
 	NS8390_init(dev, 0);
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto out;
 	return 0;
 out:
 	release_region(ioaddr, ULTRA32_IO_EXTENT);
diff -Nru a/drivers/net/smc9194.c b/drivers/net/smc9194.c
--- a/drivers/net/smc9194.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/smc9194.c	2004-06-06 18:38:44 +10:00
@@ -722,13 +722,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, SMC_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -1018,8 +1012,13 @@
 	dev->get_stats			= smc_query_statistics;
 	dev->set_multicast_list 	= smc_set_multicast_list;
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto err_irq;
 	return 0;
 
+err_irq:
+	free_irq(dev->irq, dev);
 err_out:
 	release_region(ioaddr, SMC_IO_EXTENT);
 	return retval;
diff -Nru a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
--- a/drivers/net/sun3_82586.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/sun3_82586.c	2004-06-06 18:38:44 +10:00
@@ -320,13 +320,8 @@
 	err = sun3_82586_probe1(dev, ioaddr);
 	if (err)
 		goto out1;
-	err = register_netdev(dev);
-	if (err)
-		goto out2;
 	return dev;
 
-out2:
-	release_region(ioaddr, SUN3_82586_TOTAL_SIZE);
 out1:
 	free_netdev(dev);
 out:
@@ -389,6 +384,10 @@
 	dev->set_multicast_list = set_multicast_list;
 
 	dev->if_port 		= 0;
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out;
 	return 0;
 out:
 	release_region(ioaddr, SUN3_82586_TOTAL_SIZE);
diff -Nru a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
--- a/drivers/net/sun3lance.c	2004-06-06 18:38:44 +10:00
+++ b/drivers/net/sun3lance.c	2004-06-06 18:38:44 +10:00
@@ -279,16 +279,9 @@
 	if (!lance_probe(dev))
 		goto out;
 
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	found = 1;
 	return dev;
 
-out1:
-#ifdef CONFIG_SUN3
-	iounmap((void *)dev->base_addr);
-#endif
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -342,6 +335,7 @@
 
 	REGA(CSR0) = CSR0_STOP; 
 
+	/* XXX - leak */
 	request_irq(LANCE_IRQ, lance_interrupt, SA_INTERRUPT, "SUN3 Lance", dev);
 	dev->irq = (unsigned short)LANCE_IRQ;
 
@@ -397,7 +391,15 @@
 
 	memset( &lp->stats, 0, sizeof(lp->stats) );
 
+	if (register_netdev(dev))
+		goto out_unmap;
 	return 1;
+
+out_unmap:
+#ifdef CONFIG_SUN3
+		iounmap((void *)dev->base_addr);
+#endif
+	return 0;
 }
 
 static int lance_open( struct net_device *dev )

--a8Wt8u1KmwUX3Y2C--
