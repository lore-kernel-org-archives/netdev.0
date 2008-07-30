From: akpm@linux-foundation.org
Subject: [patch nacked? 4/4] smc-ultra: get rid of "eth%d" message
Date: Wed, 30 Jul 2008 12:40:50 -0700
Message-ID: <200807301940.m6UJeoGG012686@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	nm127@freemail.hu
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37325 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754025AbYG3Tyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:54:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: M=E1rton N=E9meth <nm127@freemail.hu>

Print out the dev->name only after register_netdev().  If the dev->name=
 is
printk()ed out before calling register_netdev() the result will be "eth=
%d"
in the dmesg instead of "eth0".

Signed-off-by: M=E1rton N=E9meth <nm127@freemail.hu>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc-ultra.c |   33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff -puN drivers/net/smc-ultra.c~smc-ultra-get-rid-of-eth%d-message dr=
ivers/net/smc-ultra.c
--- a/drivers/net/smc-ultra.c~smc-ultra-get-rid-of-eth%d-message
+++ a/drivers/net/smc-ultra.c
@@ -228,9 +228,6 @@ static int __init ultra_probe1(struct ne
 	for (i =3D 0; i < 6; i++)
 		dev->dev_addr[i] =3D inb(ioaddr + 8 + i);
=20
-	printk("%s: %s at %#3x, %s", dev->name, model_name,
-	       ioaddr, print_mac(mac, dev->dev_addr));
-
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
 	outb(0x80 | reg4, ioaddr + 4);
@@ -253,8 +250,10 @@ static int __init ultra_probe1(struct ne
 		irq =3D irqmap[((irqreg & 0x40) >> 4) + ((irqreg & 0x0c) >> 2)];
=20
 		if (irq =3D=3D 0) {
-			printk(", failed to detect IRQ line.\n");
-			retval =3D  -EAGAIN;
+			printk(KERN_ERR "%s at %#3x, %s, "
+			       "failed to detect IRQ line.\n", model_name,
+			       ioaddr, print_mac(mac, dev->dev_addr));
+			retval =3D -EAGAIN;
 			goto out;
 		}
 		dev->irq =3D irq;
@@ -280,22 +279,19 @@ static int __init ultra_probe1(struct ne
=20
 	ei_status.mem =3D ioremap(dev->mem_start, (ei_status.stop_page - STAR=
T_PG)*256);
 	if (!ei_status.mem) {
-		printk(", failed to ioremap.\n");
-		retval =3D  -ENOMEM;
+		printk(KERN_ERR "%s at %#3x, %s, failed to ioremap.\n",
+		       model_name, ioaddr, print_mac(mac, dev->dev_addr));
+		retval =3D -ENOMEM;
 		goto out;
 	}
=20
 	dev->mem_end =3D dev->mem_start + (ei_status.stop_page - START_PG)*25=
6;
=20
 	if (piomode) {
-		printk(",%s IRQ %d programmed-I/O mode.\n",
-			   eeprom_irq ? "EEPROM" : "assigned ", dev->irq);
 		ei_status.block_input =3D &ultra_pio_input;
 		ei_status.block_output =3D &ultra_pio_output;
 		ei_status.get_8390_hdr =3D &ultra_pio_get_hdr;
 	} else {
-		printk(",%s IRQ %d memory %#lx-%#lx.\n", eeprom_irq ? "" : "assigned=
 ",
-			   dev->irq, dev->mem_start, dev->mem_end-1);
 		ei_status.block_input =3D &ultra_block_input;
 		ei_status.block_output =3D &ultra_block_output;
 		ei_status.get_8390_hdr =3D &ultra_get_8390_hdr;
@@ -311,6 +307,21 @@ static int __init ultra_probe1(struct ne
 	retval =3D register_netdev(dev);
 	if (retval)
 		goto out;
+
+	if (piomode) {
+		printk(KERN_INFO "%s: %s at %#3x, %s,"
+			"%s IRQ %d programmed-I/O mode.\n",
+			dev->name, model_name, ioaddr,
+			print_mac(mac, dev->dev_addr),
+			eeprom_irq ? " EEPROM" : " assigned", dev->irq);
+	} else {
+		printk(KERN_INFO "%s: %s at %#3x, %s,"
+			"%s IRQ %d memory %#lx-%#lx.\n",
+			dev->name, model_name, ioaddr,
+			print_mac(mac, dev->dev_addr),
+			eeprom_irq ? "" : " assigned",
+			dev->irq, dev->mem_start, dev->mem_end-1);
+	}
 	return 0;
 out:
 	release_region(ioaddr, ULTRA_IO_EXTENT);
_
