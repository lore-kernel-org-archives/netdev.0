From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sbni -- get rid of check_region
Date: Fri, 3 Oct 2003 11:31:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003113106.45b21aa5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In sbni driver for 2.6.0-test6
Replace check_region with appropriate request_region, and make sure to
do release_region as required in error unwinds.

diff -Nru a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
--- a/drivers/net/wan/sbni.c	Fri Oct  3 11:27:51 2003
+++ b/drivers/net/wan/sbni.c	Fri Oct  3 11:27:51 2003
@@ -292,7 +292,6 @@
 	       != NULL ) {
 		int  pci_irq_line;
 		unsigned long  pci_ioaddr;
-		u16  subsys;
 
 		if( pdev->vendor != SBNI_PCI_VENDOR
 		    &&  pdev->device != SBNI_PCI_DEVICE )
@@ -302,10 +301,13 @@
 		pci_irq_line = pdev->irq;
 
 		/* Avoid already found cards from previous calls */
-		if( !request_region( pci_ioaddr, SBNI_IO_EXTENT, dev->name ) ) {
-			pci_read_config_word( pdev, PCI_SUBSYSTEM_ID, &subsys );
+		if( !request_region( pci_ioaddr, SBNI_IO_EXTENT, dev->name )) {
+			u16  subsys;
+			pci_read_config_word( pdev, PCI_SUBSYSTEM_ID, &subsys);
+
 			if( subsys != 2  ||	/* Dual adapter is present */
-			    check_region( pci_ioaddr += 4, SBNI_IO_EXTENT ) )
+			    !request_region(pci_ioaddr += 4, SBNI_IO_EXTENT,
+					    dev->name) )
 				continue;
 		}
 
@@ -318,10 +320,15 @@
 				pci_irq_line );
 
 		/* avoiding re-enable dual adapters */
-		if( (pci_ioaddr & 7) == 0  &&  pci_enable_device( pdev ) )
-			return  -EIO;
-		if( sbni_probe1( dev, pci_ioaddr, pci_irq_line ) )
+		if( (pci_ioaddr & 7) == 0  &&  pci_enable_device( pdev ) ) {
+			release_region( pci_ioaddr, SBNI_IO_EXTENT);
+			return -EIO;
+		}
+			
+		else if( sbni_probe1( dev, pci_ioaddr, pci_irq_line ) )
 			return  0;
+
+		release_region( pci_ioaddr, SBNI_IO_EXTENT);
 	}
 	return  -ENODEV;
 }
@@ -332,10 +339,8 @@
 {
 	struct net_local  *nl;
 
-	if( sbni_card_probe( ioaddr ) ) {
-		release_region( ioaddr, SBNI_IO_EXTENT );
+	if( sbni_card_probe( ioaddr ) ) 
 		return  0;
-	}
 
 	outb( 0, ioaddr + CSR0 );
 
@@ -352,7 +357,6 @@
 		if( !irq ) {
 			printk( KERN_ERR "%s: can't detect device irq!\n",
 				dev->name );
-			release_region( ioaddr, SBNI_IO_EXTENT );
 			return  0;
 		}
 	} else if( irq == 2 )
@@ -365,7 +369,6 @@
 	nl = dev->priv;
 	if( !nl ) {
 		printk( KERN_ERR "%s: unable to get memory!\n", dev->name );
-		release_region( ioaddr, SBNI_IO_EXTENT );
 		return  0;
 	}
 
