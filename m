From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Fri, 2 Jul 2004 13:14:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702171415.GA17598@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/8139too.c               |    2 +-
 drivers/net/arcnet/arcnet.c         |    4 ++--
 drivers/net/irda/Kconfig            |    2 +-
 drivers/net/irda/donauboe.c         |    4 ++++
 drivers/net/rrunner.c               |    8 ++++----
 drivers/net/sk98lin/skge.c          |    1 +
 drivers/net/tokenring/Kconfig       |    2 +-
 drivers/net/tokenring/lanstreamer.c |    5 +++++
 drivers/net/wireless/atmel_cs.c     |   20 +++++++++++++++-----
 9 files changed, 34 insertions(+), 14 deletions(-)

through these ChangeSets:

<simon@thekelleys.org.uk> (04/07/02 1.1787)
   [PATCH] [Bug 2948] New: Atmel wireless driver Oopses

<akpm@osdl.org> (04/07/02 1.1786)
   [PATCH] err2-14: skge locking fix
   
   It can return with the lock held.
   
   Found by the Stanford locking checker.
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<jgarzik@pobox.com> (04/07/01 1.1778.4.25)
   [netdrvr] fix warnings found on 64-bit platforms
   
   Updated:  8139too, arcnet/arcnet, rrunner

<jgarzik@pobox.com> (04/07/01 1.1778.4.24)
   [netdrvr] disable certain drivers that are broken on 64-bit
   
   Disable Toshiba FIR IRDA driver (donauboe) and IBM Lanstreamer
   token ring driver on all 64-bit platforms.  Add #error to each driver
   explaining the problem, causing build of driver to fail when
   BITS_PER_LONG == 64.

diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/8139too.c	2004-07-02 13:13:12 -04:00
@@ -777,7 +777,7 @@
 	u8 tmp8;
 	int rc;
 	unsigned int i;
-	u32 pio_start, pio_end, pio_flags, pio_len;
+	unsigned long pio_start, pio_end, pio_flags, pio_len;
 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
 	u32 version;
 
diff -Nru a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
--- a/drivers/net/arcnet/arcnet.c	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/arcnet/arcnet.c	2004-07-02 13:13:12 -04:00
@@ -479,7 +479,7 @@
 		*(uint16_t *) skb_push(skb, 2) = type;
 		if (skb->nh.raw - skb->mac.raw != 2)
 			BUGMSG(D_NORMAL, "arcnet_header: Yikes!  diff (%d) is not 2!\n",
-			       skb->nh.raw - skb->mac.raw);
+			       (int)(skb->nh.raw - skb->mac.raw));
 		return -2;	/* return error -- can't transmit yet! */
 	}
 	/* otherwise, we can just add the header as usual. */
@@ -514,7 +514,7 @@
 	if (skb->nh.raw - skb->mac.raw != 2) {
 		BUGMSG(D_NORMAL,
 		     "rebuild_header: shouldn't be here! (hdrsize=%d)\n",
-		       skb->nh.raw - skb->mac.raw);
+		     (int)(skb->nh.raw - skb->mac.raw));
 		return 0;
 	}
 	type = *(uint16_t *) skb_pull(skb, 2);
diff -Nru a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
--- a/drivers/net/irda/Kconfig	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/irda/Kconfig	2004-07-02 13:13:12 -04:00
@@ -333,7 +333,7 @@
 
 config TOSHIBA_FIR
 	tristate "Toshiba Type-O IR Port"
-	depends on IRDA
+	depends on IRDA && !64BIT
 	help
 	  Say Y here if you want to build support for the Toshiba Type-O IR
 	  and Donau oboe chipsets. These chipsets are used by the Toshiba
diff -Nru a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
--- a/drivers/net/irda/donauboe.c	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/irda/donauboe.c	2004-07-02 13:13:12 -04:00
@@ -1622,6 +1622,10 @@
       goto freeregion;
     }
 
+#if (BITS_PER_LONG == 64)
+#error broken on 64-bit:  casts pointer to 32-bit, and then back to pointer.
+#endif
+
   /*We need to align the taskfile on a taskfile size boundary */
   {
     unsigned long addr;
diff -Nru a/drivers/net/rrunner.c b/drivers/net/rrunner.c
--- a/drivers/net/rrunner.c	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/rrunner.c	2004-07-02 13:13:12 -04:00
@@ -1335,10 +1335,10 @@
 	if (rrpriv->tx_skbuff[cons]){
 		len = min_t(int, 0x80, rrpriv->tx_skbuff[cons]->len);
 		printk("skbuff for cons %i is valid - dumping data (0x%x bytes - skbuff len 0x%x)\n", cons, len, rrpriv->tx_skbuff[cons]->len);
-		printk("mode 0x%x, size 0x%x,\n phys %08x, skbuff-addr %08lx, truesize 0x%x\n",
+		printk("mode 0x%x, size 0x%x,\n phys %08Lx, skbuff-addr %08lx, truesize 0x%x\n",
 		       rrpriv->tx_ring[cons].mode,
 		       rrpriv->tx_ring[cons].size,
-		       rrpriv->tx_ring[cons].addr.addrlo,
+		       (unsigned long long) rrpriv->tx_ring[cons].addr.addrlo,
 		       (unsigned long)rrpriv->tx_skbuff[cons]->data,
 		       (unsigned int)rrpriv->tx_skbuff[cons]->truesize);
 		for (i = 0; i < len; i++){
@@ -1351,10 +1351,10 @@
 
 	printk("dumping TX ring info:\n");
 	for (i = 0; i < TX_RING_ENTRIES; i++)
-		printk("mode 0x%x, size 0x%x, phys-addr %08x\n",
+		printk("mode 0x%x, size 0x%x, phys-addr %08Lx\n",
 		       rrpriv->tx_ring[i].mode,
 		       rrpriv->tx_ring[i].size,
-		       rrpriv->tx_ring[i].addr.addrlo);
+		       (unsigned long long) rrpriv->tx_ring[i].addr.addrlo);
 
 }
 
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/sk98lin/skge.c	2004-07-02 13:13:12 -04:00
@@ -1927,6 +1927,7 @@
 	*/
 	if (BytesSend < C_LEN_ETHERNET_MINSIZE) {
 		if ((pMessage = skb_padto(pMessage, C_LEN_ETHERNET_MINSIZE)) == NULL) {
+			spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
 			return 0;
 		}
 		pMessage->len = C_LEN_ETHERNET_MINSIZE;
diff -Nru a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
--- a/drivers/net/tokenring/Kconfig	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/tokenring/Kconfig	2004-07-02 13:13:12 -04:00
@@ -54,7 +54,7 @@
 
 config IBMLS
 	tristate "IBM Lanstreamer chipset PCI adapter support"
-	depends on TR && PCI
+	depends on TR && PCI && !64BIT
 	help
 	  This is support for IBM Lanstreamer PCI Token Ring Cards.
 
diff -Nru a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
--- a/drivers/net/tokenring/lanstreamer.c	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/tokenring/lanstreamer.c	2004-07-02 13:13:12 -04:00
@@ -129,6 +129,11 @@
 
 #include "lanstreamer.h"
 
+#if (BITS_PER_LONG == 64)
+#error broken on 64-bit: stores pointer to rx_ring->buffer in 32-bit int
+#endif
+
+
 /* I've got to put some intelligence into the version number so that Peter and I know
  * which version of the code somebody has got. 
  * Version Number = a.b.c.d  where a.b.c is the level of code and d is the latest author.
diff -Nru a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
--- a/drivers/net/wireless/atmel_cs.c	2004-07-02 13:13:12 -04:00
+++ b/drivers/net/wireless/atmel_cs.c	2004-07-02 13:13:12 -04:00
@@ -348,9 +348,19 @@
 };
 
 /* This is strictly temporary, until PCMCIA devices get integrated into the device model. */
-static struct device atmel_device = {
-        .bus_id    = "pcmcia",
-};
+static struct device *atmel_device(void)
+{
+	static char *kobj_name = "atmel_cs";
+
+	static struct device dev = {
+		.bus_id    = "pcmcia",
+	};
+	dev.kobj.k_name = kmalloc(strlen(kobj_name)+1, GFP_KERNEL);
+	strcpy(dev.kobj.k_name, kobj_name);
+	kobject_init(&dev.kobj);
+	
+	return &dev;
+}
 
 static void atmel_config(dev_link_t *link)
 {
@@ -537,12 +547,12 @@
 		       "atmel: cannot assign IRQ: check that CONFIG_ISA is set in kernel config.");
 		goto cs_failed;
 	}
-	
+       
 	((local_info_t*)link->priv)->eth_dev = 
 		init_atmel_card(link->irq.AssignedIRQ,
 				link->io.BasePort1,
 				card_index == -1 ? NULL :  card_table[card_index].firmware,
-				&atmel_device,
+				atmel_device(),
 				card_present, 
 				link);
 	if (!((local_info_t*)link->priv)->eth_dev) 
