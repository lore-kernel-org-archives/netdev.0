From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 4/10] hostap: Add support for multi-func SanDisk ConnectPlus
Date: Sat, 12 Mar 2005 16:31:32 -0800
Message-ID: <20050313003132.GE8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Added support for the special initialization needed for the
wireless part of multi-function SanDisk ConnectPlus CF cards
(manfid 0xd601, 0x0101).

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_cs.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_cs.c	2005-03-12 16:10:53.000000000 -0800
@@ -217,6 +217,137 @@
 	return 0;
 }
 
+
+/*
+ * SanDisk CompactFlash WLAN Flashcard - Product Manual v1.0
+ * Document No. 20-10-00058, January 2004
+ * http://www.sandisk.com/pdf/industrial/ProdManualCFWLANv1.0.pdf
+ */
+#define SANDISK_WLAN_ACTIVATION_OFF 0x40
+#define SANDISK_HCR_OFF 0x42
+
+
+static void sandisk_set_iobase(local_info_t *local)
+{
+	int res;
+	conf_reg_t reg;
+
+	reg.Function = 0;
+	reg.Action = CS_WRITE;
+	reg.Offset = 0x10; /* 0x3f0 IO base 1 */
+	reg.Value = local->link->io.BasePort1 & 0x00ff;
+	res = pcmcia_access_configuration_register(local->link->handle, &reg);
+	if (res != CS_SUCCESS) {
+		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 0 -"
+		       " res=%d\n", res);
+	}
+	udelay(10);
+
+	reg.Function = 0;
+	reg.Action = CS_WRITE;
+	reg.Offset = 0x12; /* 0x3f2 IO base 2 */
+	reg.Value = (local->link->io.BasePort1 & 0xff00) >> 8;
+	res = pcmcia_access_configuration_register(local->link->handle, &reg);
+	if (res != CS_SUCCESS) {
+		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 1 -"
+		       " res=%d\n", res);
+	}
+}
+
+
+static void sandisk_write_hcr(local_info_t *local, int hcr)
+{
+	struct net_device *dev = local->dev;
+	int i;
+
+	HFA384X_OUTB(0x80, SANDISK_WLAN_ACTIVATION_OFF);
+	udelay(50);
+	for (i = 0; i < 10; i++) {
+		HFA384X_OUTB(hcr, SANDISK_HCR_OFF);
+	}
+	udelay(55);
+	HFA384X_OUTB(0x45, SANDISK_WLAN_ACTIVATION_OFF);
+}
+
+
+static void sandisk_enable_wireless(struct net_device *dev)
+{
+	int res;
+	conf_reg_t reg;
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+	tuple_t tuple;
+	cisparse_t parse;
+	u_char buf[64];
+
+	if (local->link->io.NumPorts1 < 0x42) {
+		/* Not enough ports to be SanDisk multi-function card */
+		return;
+	}
+
+	tuple.DesiredTuple = CISTPL_MANFID;
+	tuple.Attributes = TUPLE_RETURN_COMMON;
+	tuple.TupleData = buf;
+	tuple.TupleDataMax = sizeof(buf);
+	tuple.TupleOffset = 0;
+	if (pcmcia_get_first_tuple(local->link->handle, &tuple) ||
+	    pcmcia_get_tuple_data(local->link->handle, &tuple) ||
+	    pcmcia_parse_tuple(local->link->handle, &tuple, &parse) ||
+	    parse.manfid.manf != 0xd601 || parse.manfid.card != 0x0101) {
+		/* No SanDisk manfid found */
+		return;
+	}
+
+	tuple.DesiredTuple = CISTPL_LONGLINK_MFC;
+	if (pcmcia_get_first_tuple(local->link->handle, &tuple) ||
+	    pcmcia_get_tuple_data(local->link->handle, &tuple) ||
+	    pcmcia_parse_tuple(local->link->handle, &tuple, &parse) ||
+		parse.longlink_mfc.nfn < 2) {
+		/* No multi-function links found */
+		return;
+	}
+
+	printk(KERN_DEBUG "%s: Multi-function SanDisk ConnectPlus detected"
+	       " - using vendor-specific initialization\n", dev->name);
+	local->sandisk_connectplus = 1;
+
+	reg.Function = 0;
+	reg.Action = CS_WRITE;
+	reg.Offset = CISREG_COR;
+	reg.Value = COR_SOFT_RESET;
+	res = pcmcia_access_configuration_register(local->link->handle, &reg);
+	if (res != CS_SUCCESS) {
+		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
+		       dev->name, res);
+		return;
+	}
+	mdelay(5);
+
+	reg.Function = 0;
+	reg.Action = CS_WRITE;
+	reg.Offset = CISREG_COR;
+	/*
+	 * Do not enable interrupts here to avoid some bogus events. Interrupts
+	 * will be enabled during the first cor_sreset call.
+	 */
+	reg.Value = COR_LEVEL_REQ | 0x8 | COR_ADDR_DECODE | COR_FUNC_ENA;
+	res = pcmcia_access_configuration_register(local->link->handle, &reg);
+	if (res != CS_SUCCESS) {
+		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
+		       dev->name, res);
+		return;
+	}
+	mdelay(5);
+
+	sandisk_set_iobase(local);
+
+	HFA384X_OUTB(0xc5, SANDISK_WLAN_ACTIVATION_OFF);
+	udelay(10);
+	HFA384X_OUTB(0x4b, SANDISK_WLAN_ACTIVATION_OFF);
+	udelay(10);
+}
+
+
 static void prism2_pccard_cor_sreset(local_info_t *local)
 {
 	int res;
@@ -247,9 +378,11 @@
 		return;
 	}
 
-	mdelay(2);
+	mdelay(local->sandisk_connectplus ? 5 : 2);
 
 	reg.Value &= ~COR_SOFT_RESET;
+	if (local->sandisk_connectplus)
+		reg.Value |= COR_IREQ_ENA;
 	res = pcmcia_access_configuration_register(local->link->handle, &reg);
 	if (res != CS_SUCCESS) {
 		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 3 (%d)\n",
@@ -257,7 +390,10 @@
 		return;
 	}
 
-	mdelay(2);
+	mdelay(local->sandisk_connectplus ? 5 : 2);
+
+	if (local->sandisk_connectplus)
+		sandisk_set_iobase(local);
 }
 
 
@@ -270,6 +406,11 @@
 	if (!prism2_pccard_card_present(local))
 	       return;
 
+	if (local->sandisk_connectplus) {
+		sandisk_write_hcr(local, hcr);
+		return;
+	}
+
 	reg.Function = 0;
 	reg.Action = CS_READ;
 	reg.Offset = CISREG_COR;
@@ -643,6 +784,8 @@
 
 	local->shutdown = 0;
 
+	sandisk_enable_wireless(dev);
+
 	ret = prism2_hw_config(dev, 1);
 	if (!ret) {
 		ret = hostap_hw_ready(dev);
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_wlan.h
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_wlan.h	2005-03-12 16:10:42.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_wlan.h	2005-03-12 16:10:53.000000000 -0800
@@ -895,6 +895,7 @@
 #ifdef PRISM2_PCCARD
 	dev_node_t node;
 	dev_link_t *link;
+	int sandisk_connectplus;
 #endif /* PRISM2_PCCARD */
 
 #ifdef PRISM2_PLX


-- 
Jouni Malinen                                            PGP id EFC895FA
