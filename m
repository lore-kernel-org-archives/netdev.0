From: "Alexander Indenbaum" <baum@tehutinetworks.net>
Subject: RE: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Mon, 17 Sep 2007 18:54:17 +0200
Message-ID: <20070917165424.0107D75CB6@mail.tehutinetworks.co.il>
References: <20070916141456.32da6855.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0028_01C7F95C.265C0220"
Cc: <jeff@garzik.org>, <davem@davemloft.org>, <netdev@vger.kernel.org>,
	"'Nadav Shemer'" <nadav@tehutinetworks.net>
To: "'Andrew Morton'" <akpm@linux-foundation.org>,
	"'Andy Gospodarek'" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bzq-219-225-50.pop.bezeqint.net ([62.219.225.50]:49080 "EHLO
	mail.tehutinetworks.co.il" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752228AbXIQRXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 13:23:55 -0400
In-Reply-To: <20070916141456.32da6855.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0028_01C7F95C.265C0220
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Andrew,

Please try following patches which should be compatible with net-2.6.24
tree.
Full patch is against net-2.6.24 tree.
Diff patch is delta from previous submission.

Please let us know how it works for you.

Thank you,
Alexander Indenbaum

> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Sunday, September 16, 2007 11:15 PM
> To: Andy Gospodarek
> Cc: jeff@garzik.org; davem@davemloft.org; netdev@vger.kernel.org;
> baum@tehutinetworks.net
> Subject: Re: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
> 
> erp, changes in the net-2.6.24 tree breaks this.
> 
> drivers/net/tehuti.c: In function 'bdx_isr_napi':
> drivers/net/tehuti.c:268: error: too few arguments to function
> 'netif_rx_schedule_prep'
> drivers/net/tehuti.c:269: error: too few arguments to function
> '__netif_rx_schedule'
> drivers/net/tehuti.c: In function 'bdx_poll':
> drivers/net/tehuti.c:302: error: too few arguments to function
> 'netif_rx_complete'
> drivers/net/tehuti.c: In function 'bdx_hw_start':
> drivers/net/tehuti.c:414: error: implicit declaration of function
> 'netif_poll_enable'
> drivers/net/tehuti.c: In function 'bdx_hw_stop':
> drivers/net/tehuti.c:428: error: implicit declaration of function
> 'netif_poll_disable'
> drivers/net/tehuti.c: In function 'bdx_rx_receive':
> drivers/net/tehuti.c:1219: error: 'struct net_device' has no member named
> 'quota'
> drivers/net/tehuti.c:1219: warning: type defaults to 'int' in declaration
> of '_y'
> drivers/net/tehuti.c:1219: error: 'struct net_device' has no member named
> 'quota'
> drivers/net/tehuti.c:1311: error: 'struct net_device' has no member named
> 'quota'
> drivers/net/tehuti.c: In function 'bdx_probe':
> drivers/net/tehuti.c:1994: error: 'struct net_device' has no member named
> 'poll'
> drivers/net/tehuti.c:1995: error: 'struct net_device' has no member named
> 'weight'
> drivers/net/tehuti.c:2058: error: implicit declaration of function
> 'SET_MODULE_OWNER'
> 
> There's a lot of churn in networking at present and I don't have
> time/inclination
> to fix this one up, sorry.

------=_NextPart_000_0028_01C7F95C.265C0220
Content-Type: application/octet-stream;
	name="Tehuti_diff.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="Tehuti_diff.patch"

Index: tehuti.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- tehuti.c	(revision 1513)
+++ tehuti.c	(working copy)
@@ -77,7 +77,7 @@
 /* Definitions needed by ISR or NAPI functions */
 static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo =
*f);
 static void bdx_tx_cleanup(struct bdx_priv *priv);
-static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int *budget);
+static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int budget);
=20
 /* Definitions needed by FW loading */
 static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, =
int size);
@@ -85,6 +85,8 @@
 /* Definitions needed by hw_start */
 static int bdx_tx_init(struct bdx_priv *priv);
 static int bdx_rx_init(struct bdx_priv *priv);
+static void bdx_setmulti(struct net_device *ndev);
+static void bdx_reload_vlan(struct net_device *ndev);
=20
 /* Definitions needed by bdx_close */
 static void bdx_rx_free(struct bdx_priv *priv);
@@ -265,8 +267,8 @@
 		bdx_isr_extra(priv, isr);
=20
 	if (isr & (IR_RX_DESC_0 | IR_TX_FREE_0)) {
-		if (likely(netif_rx_schedule_prep(ndev))) {
-			__netif_rx_schedule(ndev);
+		if (likely(netif_rx_schedule_prep(ndev, &priv->napi))) {
+			__netif_rx_schedule(ndev, &priv->napi);
 			RET(IRQ_HANDLED);
 		} else {
 			/* NOTE: we get here if intr has slipped into window
@@ -286,24 +288,26 @@
 	RET(IRQ_HANDLED);
 }
=20
-static int bdx_poll(struct net_device *ndev, int *budget)
+static int bdx_poll(struct napi_struct *napi, int budget)
 {
-	struct bdx_priv *priv =3D ndev->priv;
+	struct bdx_priv *priv =3D container_of(napi, struct bdx_priv, napi);
+	struct net_device *ndev =3D priv->ndev;
+	int work_done =3D 0;
 	ENTER;
 	bdx_tx_cleanup(priv);
-	if (!bdx_rx_receive(priv, &priv->rxd_fifo0, budget)
-	    || (priv->napi_stop++ >=3D 30)) {
+	work_done =3D bdx_rx_receive(priv, &priv->rxd_fifo0, budget);
+	if ((work_done =3D=3D 0) || (priv->napi_stop++ >=3D 30)) {
 		DBG("rx poll is done. backing to isr-driven\n");
=20
 		/* from time to time we exit to let NAPI layer release
 		 * device lock and allow waiting tasks (eg rmmod) to advance) */
 		priv->napi_stop =3D 0;
=20
-		netif_rx_complete(ndev);
+		netif_rx_complete(ndev, napi);
 		bdx_enable_interrupts(priv);
 		return 0;
 	}
-	return 1;
+	return work_done;
 }
=20
 /* bdx_fw_load - loads firmware to NIC
@@ -413,7 +417,7 @@
 		goto err_irq;
 	bdx_enable_interrupts(priv);
=20
-	netif_poll_enable(priv->ndev);
+	napi_enable(&priv->napi);
=20
 	RET(0);
=20
@@ -427,7 +431,7 @@
 	bdx_disable_interrupts(priv);
 	free_irq(priv->pdev->irq, priv->ndev);
=20
-	netif_poll_disable(priv->ndev);
+	napi_disable(&priv->napi);
 	netif_carrier_off(priv->ndev);
 	netif_stop_queue(priv->ndev);
=20
@@ -1231,7 +1235,7 @@
=20
 /* TBD: replace memcpy func call by explicite inline asm */
=20
-static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int *budget)
+static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int budget)
 {
 	struct sk_buff *skb, *skb2;
 	struct rxd_desc *rxdd;
@@ -1239,7 +1243,6 @@
 	struct rxf_fifo *rxf_fifo;
 	int tmp_len, size;
 	int done =3D 0;
-	int max_done =3D BDX_MAX_RX_DONE;
 	struct rxdb *db =3D NULL;
 	/* Unmarshalled descriptor - copy of descriptor in host order */
 	u32 rxd_val1;
@@ -1247,7 +1250,6 @@
 	u16 rxd_vlan;
=20
 	ENTER;
-	max_done =3D min(*budget, priv->ndev->quota);
=20
 	priv->ndev->last_rx =3D jiffies;
 	f->m.wptr =3D READ_REG(priv, f->m.reg_WPTR) & TXF_WPTR_WR_PTR;
@@ -1327,7 +1329,7 @@
=20
 		NETIF_RX_MUX(priv, rxd_val1, rxd_vlan, skb);
=20
-		if (++done >=3D max_done)
+		if (++done >=3D budget)
 			break;
 	}
=20
@@ -1338,9 +1340,7 @@
=20
 	bdx_rx_alloc_skbs(priv, &priv->rxf_fifo0);
=20
-	*budget -=3D done;
-	priv->ndev->quota -=3D done;
-	RET(done =3D=3D max_done);
+	return done;
 }
=20
 =
/************************************************************************=
*
@@ -2022,8 +2022,6 @@
 		ndev->vlan_rx_register =3D bdx_vlan_rx_register;
 		ndev->vlan_rx_add_vid =3D bdx_vlan_rx_add_vid;
 		ndev->vlan_rx_kill_vid =3D bdx_vlan_rx_kill_vid;
-		ndev->poll =3D bdx_poll;
-		ndev->weight =3D 64;
=20
 		bdx_ethtool_ops(ndev);	/* ethtool interface */
=20
@@ -2081,12 +2079,13 @@
 #endif
 		spin_lock_init(&priv->tx_lock);
=20
+		netif_napi_add(ndev, &priv->napi, bdx_poll, 64);
+
 		/*bdx_hw_reset(priv); */
 		if (bdx_read_mac(priv)) {
 			printk(KERN_ERR "tehuti: load MAC address failed\n");
 			goto err_out_iomap;
 		}
-		SET_MODULE_OWNER(ndev);
 		SET_NETDEV_DEV(ndev, &pdev->dev);
 		if ((err =3D register_netdev(ndev))) {
 			printk(KERN_ERR "tehuti: register_netdev failed\n");
Index: tehuti.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- tehuti.h	(revision 1501)
+++ tehuti.h	(working copy)
@@ -251,6 +251,7 @@
 	void __iomem *pBdxRegs;
 	struct net_device *ndev;
=20
+	struct napi_struct		napi;
 	/* RX FIFOs: 1 for data (full) descs, and 2 for free descs */
 	struct rxd_fifo rxd_fifo0;
 	struct rxf_fifo rxf_fifo0;

------=_NextPart_000_0028_01C7F95C.265C0220
Content-Type: application/octet-stream;
	name="Tehuti_Full.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="Tehuti_Full.patch"

diff --git a/MAINTAINERS b/MAINTAINERS
index 5f26583..36baa9c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3620,6 +3620,14 @@ M:	hlhung3i@gmail.com
 W:	http://tcp-lp-mod.sourceforge.net/
 S:	Maintained
=20
+TEHUTI ETHERNET DRIVER
+P:	Alexander Indenbaum
+M:	baum@tehutinetworks.net
+P:	Andy Gospodarek
+M:	andy@greyhouse.net
+L:	netdev@vger.kernel.org
+S:	Supported
+
 TI FLASH MEDIA INTERFACE DRIVER
 P:      Alex Dubov
 M:      oakad@yahoo.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1c8ef44..a8f7600 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2565,6 +2565,12 @@ config MLX4_DEBUG
 	  debug_level module parameter (which can also be set after
 	  the driver is loaded through sysfs).
=20
+config TEHUTI
+	tristate "Tehuti Networks 10G Ethernet"
+	depends on PCI
+	help
+	  Tehuti Networks 10G Ethernet NIC
+
 endif # NETDEV_10000
=20
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ff4dbca..6c381ba 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_E1000E) +=3D e1000e/
 obj-$(CONFIG_IBM_EMAC) +=3D ibm_emac/
 obj-$(CONFIG_IXGBE) +=3D ixgbe/
 obj-$(CONFIG_IXGB) +=3D ixgb/
+obj-$(CONFIG_TEHUTI) +=3D tehuti/
 obj-$(CONFIG_CHELSIO_T1) +=3D chelsio/
 obj-$(CONFIG_CHELSIO_T3) +=3D cxgb3/
 obj-$(CONFIG_EHEA) +=3D ehea/
diff --git a/drivers/net/tehuti/tehuti.c b/drivers/net/tehuti/tehuti.c
new file mode 100644
index 0000000..3b1fc46
--- /dev/null
+++ b/drivers/net/tehuti/tehuti.c
@@ -0,0 +1,2542 @@
+/*
+ * Tehuti Networks(R) Network Driver
+ * ethtool interface implementation
+ * Copyright (C) 2007 Tehuti Networks Ltd. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+/*
+ * RX HW/SW interaction overview
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ * There are 2 types of RX communication channels betwean driver and =
NIC.
+ * 1) RX Free Fifo - RXF - holds descriptors of empty buffers to accept =
incoming
+ * traffic. This Fifo is filled by SW and is readen by HW. Each =
descriptor holds
+ * info about buffer's location, size and ID. An ID field is used to =
identify a
+ * buffer when it's returned with data via RXD Fifo (see below)
+ * 2) RX Data Fifo - RXD - holds descriptors of full buffers. This Fifo =
is
+ * filled by HW and is readen by SW. Each descriptor holds status and =
ID.
+ * HW pops descriptor from RXF Fifo, stores ID, fills buffer with =
incoming data,
+ * via dma moves it into host memory, builds new RXD descriptor with =
same ID,
+ * pushes it into RXD Fifo and raises interrupt to indicate new RX =
data.
+ *
+ * Current NIC configuration (registers + firmware) makes NIC use 2 RXF =
Fifos.
+ * One holds 1.5K packets and another - 26K packets. Depending on =
incoming
+ * packet size, HW desides on a RXF Fifo to pop buffer from. When =
packet is
+ * filled with data, HW builds new RXD descriptor for it and push it =
into single
+ * RXD Fifo.
+ *
+ * RX SW Data Structures
+ * ~~~~~~~~~~~~~~~~~~~~~
+ * skb db - used to keep track of all skbs owned by SW and their dma =
addresses.
+ * For RX case, ownership lasts from allocating new empty skb for RXF =
until
+ * accepting full skb from RXD and passing it to OS. Each RXF Fifo has =
its own
+ * skb db. Implemented as array with bitmask.
+ * fifo - keeps info about fifo's size and location, relevant HW =
registers,
+ * usage and skb db. Each RXD and RXF Fifo has its own fifo structure.
+ * Implemented as simple struct.
+ *
+ * RX SW Execution Flow
+ * ~~~~~~~~~~~~~~~~~~~~
+ * Upon initialization (ifconfig up) driver creates RX fifos and =
initializes
+ * relevant registers. At the end of init phase, driver enables =
interrupts.
+ * NIC sees that there is no RXF buffers and raises
+ * RD_INTR interrupt, isr fills skbs and Rx begins.
+ * Driver has two receive operation modes:
+ *    NAPI - interrupt-driven mixed with polling
+ *    interrupt-driven only
+ *
+ * Interrupt-driven only flow is following. When buffer is ready, HW =
raises
+ * interrupt and isr is called. isr collects all available packets
+ * (bdx_rx_receive), refills skbs (bdx_rx_alloc_skbs) and exit.
+
+ * Rx buffer allocation note
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~
+ * Driver cares to feed such amount of RxF descriptors that respective =
amount of
+ * RxD descriptors can not fill entire RxD fifo. The main reason is =
lack of
+ * overflow check in Bordeaux for RxD fifo free/used size.
+ * FIXME: this is NOT fully implemented, more work should be done
+ *
+ */
+
+#include "tehuti.h"
+#include "tehuti_fw.h"
+
+static struct pci_device_id __devinitdata bdx_pci_tbl[] =3D {
+	{0x1FC9, 0x3009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x1FC9, 0x3010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x1FC9, 0x3014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0}
+};
+
+MODULE_DEVICE_TABLE(pci, bdx_pci_tbl);
+
+/* Definitions needed by ISR or NAPI functions */
+static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo =
*f);
+static void bdx_tx_cleanup(struct bdx_priv *priv);
+//static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int *budget);
+static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int budget);
+
+/* Definitions needed by FW loading */
+static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, =
int size);
+
+/* Definitions needed by hw_start */
+static int bdx_tx_init(struct bdx_priv *priv);
+static int bdx_rx_init(struct bdx_priv *priv);
+static void bdx_setmulti(struct net_device *ndev);
+static void bdx_reload_vlan(struct net_device *ndev);
+
+/* Definitions needed by bdx_close */
+static void bdx_rx_free(struct bdx_priv *priv);
+static void bdx_tx_free(struct bdx_priv *priv);
+
+/* Definitions needed by bdx_probe */
+static void bdx_ethtool_ops(struct net_device *netdev);
+
+/***********************************************************************=
**
+ *    Print Info                                                        =
 *
+ =
*************************************************************************=
/
+
+static void print_hw_id(struct pci_dev *pdev)
+{
+	struct pci_nic *nic =3D pci_get_drvdata(pdev);
+	u16 pci_link_status =3D 0;
+	u16 pci_ctrl =3D 0;
+
+	pci_read_config_word(pdev, PCI_LINK_STATUS_REG, &pci_link_status);
+	pci_read_config_word(pdev, PCI_DEV_CTRL_REG, &pci_ctrl);
+
+	printk(KERN_INFO "tehuti: %s%s\n", BDX_NIC_NAME,
+	       nic->port_num =3D=3D 1 ? "" : ", 2-Port");
+	printk(KERN_INFO
+	       "tehuti: srom 0x%x fpga %d build %u lane# %d"
+	       " max_pl 0x%x mrrs 0x%x\n",
+	       readl(nic->regs + SROM_VER), readl(nic->regs + FPGA_VER) & =
0xFFF,
+	       readl(nic->regs + FPGA_SEED),
+	       GET_LINK_STATUS_LANES(pci_link_status),
+	       GET_DEV_CTRL_MAXPL(pci_ctrl), GET_DEV_CTRL_MRRS(pci_ctrl));
+}
+
+static void print_fw_id(struct pci_nic *nic)
+{
+	printk(KERN_INFO "tehuti: fw 0x%x\n", readl(nic->regs + FW_VER));
+}
+
+static void print_eth_id(struct net_device *ndev)
+{
+	printk(KERN_INFO "%s: %s, Port %c\n", ndev->name, BDX_NIC_NAME,
+	       (ndev->if_port =3D=3D 0) ? 'A' : 'B');
+
+}
+
+/***********************************************************************=
**
+ *    Code                                                              =
 *
+ =
*************************************************************************=
/
+
+#define bdx_enable_interrupts(priv)	\
+	do { WRITE_REG(priv, regIMR, IR_RUN); } while (0)
+#define bdx_disable_interrupts(priv)	\
+	do { WRITE_REG(priv, regIMR, 0); } while (0)
+
+/* bdx_fifo_init
+ * create TX/RX descriptor fifo for host-NIC communication.
+ * 1K extra space is allocated at the end of the fifo to simplify
+ * processing of descriptors that wraps around fifo's end
+ * @priv - NIC private structure
+ * @f - fifo to initialize
+ * @fsz_type - fifo size type: 0-4KB, 1-8KB, 2-16KB, 3-32KB
+ * @reg_XXX - offsets of registers relative to base address
+ *
+ * Returns 0 on success, negative value on failure
+ *
+ */
+static int
+bdx_fifo_init(struct bdx_priv *priv, struct fifo *f, int fsz_type,
+	      u16 reg_CFG0, u16 reg_CFG1, u16 reg_RPTR, u16 reg_WPTR)
+{
+	u16 memsz =3D FIFO_SIZE * (1 << fsz_type);
+
+	memset(f, 0, sizeof(struct fifo));
+	/* pci_alloc_consistent gives us 4k-aligned memory */
+	f->va =3D pci_alloc_consistent(priv->pdev,
+				     memsz + FIFO_EXTRA_SPACE, &f->da);
+	if (!f->va) {
+		ERR("pci_alloc_consistent failed\n");
+		RET(-ENOMEM);
+	}
+	f->reg_CFG0 =3D reg_CFG0;
+	f->reg_CFG1 =3D reg_CFG1;
+	f->reg_RPTR =3D reg_RPTR;
+	f->reg_WPTR =3D reg_WPTR;
+	f->rptr =3D 0;
+	f->wptr =3D 0;
+	f->memsz =3D memsz;
+	f->size_mask =3D memsz - 1;
+	WRITE_REG(priv, reg_CFG0, (u32) ((f->da & TX_RX_CFG0_BASE) | =
fsz_type));
+	WRITE_REG(priv, reg_CFG1, H32_64(f->da));
+
+	RET(0);
+}
+
+/* bdx_fifo_free - free all resources used by fifo
+ * @priv - NIC private structure
+ * @f - fifo to release
+ */
+static void bdx_fifo_free(struct bdx_priv *priv, struct fifo *f)
+{
+	ENTER;
+	if (f->va) {
+		pci_free_consistent(priv->pdev,
+				    f->memsz + FIFO_EXTRA_SPACE, f->va, f->da);
+		f->va =3D NULL;
+	}
+	RET();
+}
+
+/*
+ * bdx_link_changed - notifies OS about hw link state.
+ * @bdx_priv - hw adapter structure
+ */
+static void bdx_link_changed(struct bdx_priv *priv)
+{
+	u32 link =3D READ_REG(priv, regMAC_LNK_STAT) & MAC_LINK_STAT;
+
+	if (!link) {
+		if (netif_carrier_ok(priv->ndev)) {
+			netif_stop_queue(priv->ndev);
+			netif_carrier_off(priv->ndev);
+			ERR("%s: Link Down\n", priv->ndev->name);
+		}
+	} else {
+		if (!netif_carrier_ok(priv->ndev)) {
+			netif_wake_queue(priv->ndev);
+			netif_carrier_on(priv->ndev);
+			ERR("%s: Link Up\n", priv->ndev->name);
+		}
+	}
+}
+
+static void bdx_isr_extra(struct bdx_priv *priv, u32 isr)
+{
+	if (isr & IR_RX_FREE_0) {
+		bdx_rx_alloc_skbs(priv, &priv->rxf_fifo0);
+		DBG("RX_FREE_0\n");
+	}
+
+	if (isr & IR_LNKCHG0)
+		bdx_link_changed(priv);
+
+	if (isr & IR_PCIE_LINK)
+		ERR("%s: PCI-E Link Fault\n", priv->ndev->name);
+
+	if (isr & IR_PCIE_TOUT)
+		ERR("%s: PCI-E Time Out\n", priv->ndev->name);
+
+}
+
+/* bdx_isr - Interrupt Service Routine for Bordeaux NIC
+ * @irq - interrupt number
+ * @ndev - network device
+ * @regs - CPU registers
+ *
+ * Return IRQ_NONE if it was not our interrupt, IRQ_HANDLED - otherwise
+ *
+ * It reads ISR register to know interrupt reasons, and proceed them =
one by one.
+ * Reasons of interest are:
+ *    RX_DESC - new packet has arrived and RXD fifo holds its =
descriptor
+ *    RX_FREE - number of free Rx buffers in RXF fifo gets low
+ *    TX_FREE - packet was transmited and RXF fifo holds its descriptor
+ */
+
+static irqreturn_t bdx_isr_napi(int irq, void *dev)
+{
+	struct net_device *ndev =3D dev;
+	struct bdx_priv *priv =3D ndev->priv;
+	u32 isr;
+
+	ENTER;
+	isr =3D (READ_REG(priv, regISR) & IR_RUN);
+	if (unlikely(!isr)) {
+		bdx_enable_interrupts(priv);
+		return IRQ_NONE;	/* Not our interrupt */
+	}
+
+	if (isr & IR_EXTRA)
+		bdx_isr_extra(priv, isr);
+
+	if (isr & (IR_RX_DESC_0 | IR_TX_FREE_0)) {
+		if (likely(netif_rx_schedule_prep(ndev, &priv->napi))) {
+			__netif_rx_schedule(ndev, &priv->napi);
+			RET(IRQ_HANDLED);
+		} else {
+			/* NOTE: we get here if intr has slipped into window
+			 * between these lines in bdx_poll:
+			 *    bdx_enable_interrupts(priv);
+			 *    return 0;
+			 * currently intrs are disabled (since we read ISR),
+			 * and we have failed to register next poll.
+			 * so we read the regs to trigger chip
+			 * and allow further interupts. */
+			READ_REG(priv, regTXF_WPTR_0);
+			READ_REG(priv, regRXD_WPTR_0);
+		}
+	}
+
+	bdx_enable_interrupts(priv);
+	RET(IRQ_HANDLED);
+}
+
+//static int bdx_poll(struct net_device *ndev, int *budget)
+static int bdx_poll(struct napi_struct *napi, int budget)
+{
+	struct bdx_priv *priv =3D container_of(napi, struct bdx_priv, napi);
+	struct net_device *ndev =3D priv->ndev;
+	int work_done=3D0;
+	ENTER;
+	bdx_tx_cleanup(priv);
+	work_done =3D bdx_rx_receive(priv, &priv->rxd_fifo0, budget);
+	if ((work_done =3D=3D 0) || (priv->napi_stop++ >=3D 30)) {
+		DBG("rx poll is done. backing to isr-driven\n");
+
+		/* from time to time we exit to let NAPI layer release
+		 * device lock and allow waiting tasks (eg rmmod) to advance) */
+		priv->napi_stop =3D 0;
+
+		netif_rx_complete(ndev, napi);
+		bdx_enable_interrupts(priv);
+		return 0;
+	}
+	return work_done;
+}
+
+/* bdx_fw_load - loads firmware to NIC
+ * @priv - NIC private structure
+ * Firmware is loaded via TXD fifo, so it must be initialized first.
+ * Firware must be loaded once per NIC not per PCI device provided by =
NIC (NIC
+ * can have few of them). So all drivers use semaphore register to =
choose one
+ * that will actually load FW to NIC.
+ */
+
+static int bdx_fw_load(struct bdx_priv *priv)
+{
+	int master, i;
+
+	ENTER;
+	master =3D READ_REG(priv, regINIT_SEMAPHORE);
+	if (!READ_REG(priv, regINIT_STATUS) && master) {
+		bdx_tx_push_desc_safe(priv, s_firmLoad, sizeof(s_firmLoad));
+		mdelay(100);
+	}
+	for (i =3D 0; i < 200; i++) {
+		if (READ_REG(priv, regINIT_STATUS))
+			break;
+		mdelay(2);
+	}
+	if (master)
+		WRITE_REG(priv, regINIT_SEMAPHORE, 1);
+
+	if (i =3D=3D 200) {
+		ERR("%s: firmware loading failed\n", priv->ndev->name);
+		DBG("VPC =3D 0x%x VIC =3D 0x%x INIT_STATUS =3D 0x%x i=3D%d\n",
+		    READ_REG(priv, regVPC),
+		    READ_REG(priv, regVIC), READ_REG(priv, regINIT_STATUS), i);
+		RET(-EIO);
+	} else {
+		DBG("%s: firmware loading success\n", priv->ndev->name);
+		RET(0);
+	}
+}
+
+static void bdx_restore_mac(struct net_device *ndev, struct bdx_priv =
*priv)
+{
+	u32 val;
+
+	ENTER;
+	DBG("mac0=3D%x mac1=3D%x mac2=3D%x\n",
+	    READ_REG(priv, regUNC_MAC0_A),
+	    READ_REG(priv, regUNC_MAC1_A), READ_REG(priv, regUNC_MAC2_A));
+
+	val =3D (ndev->dev_addr[0] << 8) | (ndev->dev_addr[1]);
+	WRITE_REG(priv, regUNC_MAC2_A, val);
+	val =3D (ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]);
+	WRITE_REG(priv, regUNC_MAC1_A, val);
+	val =3D (ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]);
+	WRITE_REG(priv, regUNC_MAC0_A, val);
+
+	DBG("mac0=3D%x mac1=3D%x mac2=3D%x\n",
+	    READ_REG(priv, regUNC_MAC0_A),
+	    READ_REG(priv, regUNC_MAC1_A), READ_REG(priv, regUNC_MAC2_A));
+	RET();
+}
+
+/* bdx_hw_start - inits registers and starts HW's Rx and Tx engines
+ * @priv - NIC private structure
+ */
+static int bdx_hw_start(struct bdx_priv *priv)
+{
+	int rc =3D -EIO;
+	struct net_device *ndev =3D priv->ndev;
+
+	ENTER;
+	bdx_link_changed(priv);
+
+	/* 10G overall max length (vlan, eth&ip header, ip payload, crc) */
+	WRITE_REG(priv, regFRM_LENGTH, 0X3FE0);
+	WRITE_REG(priv, regPAUSE_QUANT, 0x96);
+	WRITE_REG(priv, regRX_FIFO_SECTION, 0x800010);
+	WRITE_REG(priv, regTX_FIFO_SECTION, 0xE00010);
+	WRITE_REG(priv, regRX_FULLNESS, 0);
+	WRITE_REG(priv, regTX_FULLNESS, 0);
+	WRITE_REG(priv, regCTRLST,
+		  regCTRLST_BASE | regCTRLST_RX_ENA | regCTRLST_TX_ENA);
+
+	WRITE_REG(priv, regVGLB, 0);
+	WRITE_REG(priv, regMAX_FRAME_A,
+		  priv->rxf_fifo0.m.pktsz & MAX_FRAME_AB_VAL);
+
+	DBG("RDINTCM=3D%08x\n", priv->rdintcm);	/*NOTE: test script uses this =
*/
+	WRITE_REG(priv, regRDINTCM0, priv->rdintcm);
+	WRITE_REG(priv, regRDINTCM2, 0);	/*cpu_to_le32(rcm.val)); */
+
+	DBG("TDINTCM=3D%08x\n", priv->tdintcm);	/*NOTE: test script uses this =
*/
+	WRITE_REG(priv, regTDINTCM0, priv->tdintcm);	/* old val =3D 0x300064 =
*/
+
+	/* Enable timer interrupt once in 2 secs. */
+	/*WRITE_REG(priv, regGTMR0, ((GTMR_SEC * 2) & GTMR_DATA)); */
+	bdx_restore_mac(priv->ndev, priv);
+
+//	WRITE_REG(priv, regGMAC_RXF_A, GMAC_RX_FILTER_OSEN |
+//		  GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB);
+	bdx_setmulti(priv->ndev);
+	bdx_reload_vlan(priv->ndev);
+
+#define BDX_IRQ_TYPE	((priv->nic->irq_type =3D=3D =
IRQ_MSI)?0:IRQF_SHARED)
+	if ((rc =3D request_irq(priv->pdev->irq, &bdx_isr_napi, BDX_IRQ_TYPE,
+			 ndev->name, ndev)))
+		goto err_irq;
+	bdx_enable_interrupts(priv);
+
+	//netif_poll_enable(priv->ndev);
+	napi_enable(&priv->napi);
+
+	RET(0);
+
+err_irq:
+	RET(rc);
+}
+
+static void bdx_hw_stop(struct bdx_priv *priv)
+{
+	ENTER;
+	bdx_disable_interrupts(priv);
+	free_irq(priv->pdev->irq, priv->ndev);
+
+	//netif_poll_disable(priv->ndev);
+	napi_disable(&priv->napi);
+	netif_carrier_off(priv->ndev);
+	netif_stop_queue(priv->ndev);
+
+	RET();
+}
+
+static int bdx_hw_reset_direct(void __iomem *regs)
+{
+	u32 val, i;
+	ENTER;
+
+	/* reset sequences: read, write 1, read, write 0 */
+	val =3D readl(regs + regCLKPLL);
+	writel((val | CLKPLL_SFTRST) + 0x8, regs + regCLKPLL);
+	udelay(50);
+	val =3D readl(regs + regCLKPLL);
+	writel(val & ~CLKPLL_SFTRST, regs + regCLKPLL);
+
+	/* check that the PLLs are locked and reset ended */
+	for (i =3D 0; i < 70; i++, mdelay(10))
+		if ((readl(regs + regCLKPLL) & CLKPLL_LKD) =3D=3D CLKPLL_LKD) {
+			/* do any PCI-E read transaction */
+			readl(regs + regRXD_CFG0_0);
+			return 0;
+		}
+	ERR("tehuti: HW reset failed\n");
+	return 1;		/* failure */
+}
+
+static int bdx_hw_reset(struct bdx_priv *priv)
+{
+	u32 val, i;
+	ENTER;
+
+	if (priv->port =3D=3D 0) {
+		/* reset sequences: read, write 1, read, write 0 */
+		val =3D READ_REG(priv, regCLKPLL);
+		WRITE_REG(priv, regCLKPLL, (val | CLKPLL_SFTRST) + 0x8);
+		udelay(50);
+		val =3D READ_REG(priv, regCLKPLL);
+		WRITE_REG(priv, regCLKPLL, val & ~CLKPLL_SFTRST);
+	}
+	/* check that the PLLs are locked and reset ended */
+	for (i =3D 0; i < 70; i++, mdelay(10))
+		if ((READ_REG(priv, regCLKPLL) & CLKPLL_LKD) =3D=3D CLKPLL_LKD) {
+			/* do any PCI-E read transaction */
+			READ_REG(priv, regRXD_CFG0_0);
+			return 0;
+		}
+	ERR("tehuti: HW reset failed\n");
+	return 1;		/* failure */
+}
+
+static int bdx_sw_reset(struct bdx_priv *priv)
+{
+	int i;
+
+	ENTER;
+	/* 1. load MAC (obsolete) */
+	/* 2. disable Rx (and Tx) */
+	WRITE_REG(priv, regGMAC_RXF_A, 0);
+	mdelay(100);
+	/* 3. disable port */
+	WRITE_REG(priv, regDIS_PORT, 1);
+	/* 4. disable queue */
+	WRITE_REG(priv, regDIS_QU, 1);
+	/* 5. wait until hw is disabled */
+	for (i =3D 0; i < 50; i++) {
+		if (READ_REG(priv, regRST_PORT) & 1)
+			break;
+		mdelay(10);
+	}
+	if (i =3D=3D 50)
+		ERR("%s: SW reset timeout. continuing anyway\n",
+		    priv->ndev->name);
+
+	/* 6. disable intrs */
+	WRITE_REG(priv, regRDINTCM0, 0);
+	WRITE_REG(priv, regTDINTCM0, 0);
+	WRITE_REG(priv, regIMR, 0);
+	READ_REG(priv, regISR);
+
+	/* 7. reset queue */
+	WRITE_REG(priv, regRST_QU, 1);
+	/* 8. reset port */
+	WRITE_REG(priv, regRST_PORT, 1);
+	/* 9. zero all read and write pointers */
+	for (i =3D regTXD_WPTR_0; i <=3D regTXF_RPTR_3; i +=3D 0x10)
+		DBG("%x =3D %x\n", i, READ_REG(priv, i) & TXF_WPTR_WR_PTR);
+	for (i =3D regTXD_WPTR_0; i <=3D regTXF_RPTR_3; i +=3D 0x10)
+		WRITE_REG(priv, i, 0);
+	/* 10. unseet port disable */
+	WRITE_REG(priv, regDIS_PORT, 0);
+	/* 11. unset queue disable */
+	WRITE_REG(priv, regDIS_QU, 0);
+	/* 12. unset queue reset */
+	WRITE_REG(priv, regRST_QU, 0);
+	/* 13. unset port reset */
+	WRITE_REG(priv, regRST_PORT, 0);
+	/* 14. enable Rx */
+	/* skiped. will be done later */
+	/* 15. save MAC (obsolete) */
+	for (i =3D regTXD_WPTR_0; i <=3D regTXF_RPTR_3; i +=3D 0x10)
+		DBG("%x =3D %x\n", i, READ_REG(priv, i) & TXF_WPTR_WR_PTR);
+
+	RET(0);
+}
+
+/* bdx_reset - performs right type of reset depending on hw type */
+static int bdx_reset(struct bdx_priv *priv)
+{
+	ENTER;
+	RET((priv->pdev->device =3D=3D 0x3009)
+	    ? bdx_hw_reset(priv)
+	    : bdx_sw_reset(priv));
+}
+
+/**
+ * bdx_close - Disables a network interface
+ * @netdev: network interface device structure
+ *
+ * Returns 0, this is not allowed to fail
+ *
+ * The close entry point is called when an interface is de-activated
+ * by the OS.  The hardware is still under the drivers control, but
+ * needs to be disabled.  A global MAC reset is issued to stop the
+ * hardware, and all transmit and receive resources are freed.
+ **/
+static int bdx_close(struct net_device *ndev)
+{
+	struct bdx_priv *priv =3D NULL;
+
+	ENTER;
+	priv =3D ndev->priv;
+	bdx_reset(priv);
+	bdx_hw_stop(priv);
+	bdx_rx_free(priv);
+	bdx_tx_free(priv);
+	RET(0);
+}
+
+/**
+ * bdx_open - Called when a network interface is made active
+ * @netdev: network interface device structure
+ *
+ * Returns 0 on success, negative value on failure
+ *
+ * The open entry point is called when a network interface is made
+ * active by the system (IFF_UP).  At this point all resources needed
+ * for transmit and receive operations are allocated, the interrupt
+ * handler is registered with the OS, the watchdog timer is started,
+ * and the stack is notified that the interface is ready.
+ **/
+static int bdx_open(struct net_device *ndev)
+{
+	struct bdx_priv *priv;
+	int rc;
+
+	ENTER;
+	priv =3D ndev->priv;
+	bdx_reset(priv);
+	if (netif_running(ndev))
+		netif_stop_queue(priv->ndev);
+
+	if ((rc =3D bdx_tx_init(priv)))
+		goto err;
+
+	if ((rc =3D bdx_rx_init(priv)))
+		goto err;
+
+	if ((rc =3D bdx_fw_load(priv)))
+		goto err;
+
+	bdx_rx_alloc_skbs(priv, &priv->rxf_fifo0);
+
+	if ((rc =3D bdx_hw_start(priv)))
+		goto err;
+
+	print_fw_id(priv->nic);
+
+	RET(0);
+
+err:
+	bdx_close(ndev);
+	RET(rc);
+}
+
+static void __init bdx_firmware_endianess(void)
+{
+	int i;
+	for (i =3D 0; i < sizeof(s_firmLoad) / sizeof(u32); i++)
+		s_firmLoad[i] =3D CPU_CHIP_SWAP32(s_firmLoad[i]);
+}
+
+static int bdx_ioctl_priv(struct net_device *ndev, struct ifreq *ifr, =
int cmd)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+	u32 data[3];
+	int error;
+
+	ENTER;
+
+	DBG("jiffies=3D%ld cmd=3D%d\n", jiffies, cmd);
+	if (cmd !=3D SIOCDEVPRIVATE) {
+		error =3D copy_from_user(data, ifr->ifr_data, sizeof(data));
+		if (error) {
+			ERR("cant copy from user\n");
+			RET(error);
+		}
+		DBG("%d 0x%x 0x%x\n", data[0], data[1], data[2]);
+	}
+
+	switch (data[0]) {
+
+	case BDX_OP_READ:
+		data[2] =3D READ_REG(priv, data[1]);
+		DBG("read_reg(0x%x)=3D0x%x (dec %d)\n", data[1], data[2],
+		    data[2]);
+		error =3D copy_to_user(ifr->ifr_data, data, sizeof(data));
+		if (error)
+			RET(error);
+		break;
+
+	case BDX_OP_WRITE:
+		WRITE_REG(priv, data[1], data[2]);
+		DBG("write_reg(0x%x, 0x%x)\n", data[1], data[2]);
+		break;
+
+	default:
+		RET(-EOPNOTSUPP);
+	}
+	return 0;
+}
+
+static int bdx_ioctl(struct net_device *ndev, struct ifreq *ifr, int =
cmd)
+{
+	ENTER;
+	if (cmd >=3D SIOCDEVPRIVATE && cmd <=3D (SIOCDEVPRIVATE + 15))
+		RET(bdx_ioctl_priv(ndev, ifr, cmd));
+	else
+		RET(-EOPNOTSUPP);
+}
+
+/*
+ * __bdx_vlan_rx_vid - private helper for adding/killing VLAN vid
+ *                     by passing VLAN filter table to hardware
+ * @ndev network device
+ * @vid  VLAN vid
+ * @op   add or kill operation
+ */
+static void __bdx_vlan_rx_vid(struct net_device *ndev, uint16_t vid, =
int enable)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+	u32 reg, bit, val;
+
+	ENTER;
+	DBG2("vid=3D%d value=3D%d\n", (int)vid, enable);
+	if (unlikely(vid >=3D 4096)) {
+		ERR("tehuti: invalid VID: %u (> 4096)\n", vid);
+		RET();
+	}
+	reg =3D regVLAN_0 + (vid / 32) * 4;
+	bit =3D 1 << vid % 32;
+	val =3D READ_REG(priv, reg);
+	DBG2("reg=3D%x, val=3D%x, bit=3D%d\n", reg, val, bit);
+	if (enable)
+		val |=3D bit;
+	else
+		val &=3D ~bit;
+	DBG2("new val %x\n", val);
+	WRITE_REG(priv, reg, val);
+	RET();
+}
+
+/*
+ * bdx_vlan_rx_add_vid - kernel hook for adding VLAN vid to hw =
filtering table
+ * @ndev network device
+ * @vid  VLAN vid to add
+ */
+static void bdx_vlan_rx_add_vid(struct net_device *ndev, uint16_t vid)
+{
+	__bdx_vlan_rx_vid(ndev, vid, 1);
+}
+
+/*
+ * bdx_vlan_rx_kill_vid - kernel hook for killing VLAN vid in hw =
filtering table
+ * @ndev network device
+ * @vid  VLAN vid to kill
+ */
+static void bdx_vlan_rx_kill_vid(struct net_device *ndev, unsigned =
short vid)
+{
+	__bdx_vlan_rx_vid(ndev, vid, 0);
+}
+
+/*
+ * bdx_vlan_rx_register - kernel hook for adding VLAN group
+ * @ndev network device
+ * @grp  VLAN group
+ */
+static void
+bdx_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+
+	ENTER;
+	DBG("device=3D'%s', group=3D'%p'\n", ndev->name, grp);
+	priv->vlgrp =3D grp;
+	RET();
+}
+
+/*=20
+ * bdx_reload_vlan - utility functions for re-setting VLAN filters =
according to VLAN group
+ * @ndev network device
+ */
+static void bdx_reload_vlan(struct net_device *ndev)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+	int i;
+
+	ENTER;
+	if (priv->vlgrp) {
+=09
+		DBG("device=3D'%s', group=3D'%p' rewriting VLAN filters\n", =
ndev->name, priv->vlgrp);
+
+		/* First, zero out the filter */
+		for (i =3D 0; i < (VLAN_VID_MASK / 32); i++) {
+			WRITE_REG(priv, regVLAN_0 + (i * 4), 0);
+		}
+	=09
+                for (i =3D 0; i < VLAN_VID_MASK; i++) {
+                        if (vlan_group_get_device(priv->vlgrp, i))
+				__bdx_vlan_rx_vid(ndev, i, 1);
+                }
+	} else {
+		DBG("device=3D'%s', no VLAN\n", ndev->name);
+	}
+	RET();
+}
+
+/**
+ * bdx_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int bdx_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	BDX_ASSERT(ndev =3D=3D 0);
+	ENTER;
+
+	if (new_mtu =3D=3D ndev->mtu)
+		RET(0);
+
+	/* enforce minimum frame size */
+	if (new_mtu < ETH_ZLEN) {
+		ERR("%s: %s mtu %d is less then minimal %d\n",
+		    BDX_DRV_NAME, ndev->name, new_mtu, ETH_ZLEN);
+		RET(-EINVAL);
+	}
+
+	ndev->mtu =3D new_mtu;
+	if (netif_running(ndev)) {
+		bdx_close(ndev);
+		bdx_open(ndev);
+	}
+	RET(0);
+}
+
+static void bdx_setmulti(struct net_device *ndev)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+
+	u32 rxf_val =3D
+	    GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB | GMAC_RX_FILTER_OSEN;
+	int i;
+
+	ENTER;
+	/* IMF - imperfect (hash) rx multicat filter */
+	/* PMF - perfect rx multicat filter */
+
+	/* FIXME: RXE(OFF) */
+	if (ndev->flags & IFF_PROMISC) {
+		rxf_val |=3D GMAC_RX_FILTER_PRM;
+	} else if (ndev->flags & IFF_ALLMULTI) {
+		/* set IMF to accept all multicast frmaes */
+		for (i =3D 0; i < MAC_MCST_HASH_NUM; i++)
+			WRITE_REG(priv, regRX_MCST_HASH0 + i * 4, ~0);
+	} else if (ndev->mc_count) {
+		u8 hash;
+		struct dev_mc_list *mclist;
+		u32 reg, val;
+
+		/* set IMF to deny all multicast frames */
+		for (i =3D 0; i < MAC_MCST_HASH_NUM; i++)
+			WRITE_REG(priv, regRX_MCST_HASH0 + i * 4, 0);
+		/* set PMF to deny all multicast frames */
+		for (i =3D 0; i < MAC_MCST_NUM; i++) {
+			WRITE_REG(priv, regRX_MAC_MCST0 + i * 8, 0);
+			WRITE_REG(priv, regRX_MAC_MCST1 + i * 8, 0);
+		}
+
+		/* use PMF to accept first MAC_MCST_NUM (15) addresses */
+		/* TBD: sort addreses and write them in ascending order
+		 * into RX_MAC_MCST regs. we skip this phase now and accept ALL
+		 * multicast frames throu IMF */
+		mclist =3D ndev->mc_list;
+
+		/* accept the rest of addresses throu IMF */
+		for (; mclist; mclist =3D mclist->next) {
+			hash =3D 0;
+			for (i =3D 0; i < ETH_ALEN; i++)
+				hash ^=3D mclist->dmi_addr[i];
+			reg =3D regRX_MCST_HASH0 + ((hash >> 5) << 2);
+			val =3D READ_REG(priv, reg);
+			val |=3D (1 << (hash % 32));
+			WRITE_REG(priv, reg, val);
+		}
+
+	} else {
+		DBG("only own mac %d\n", ndev->mc_count);
+		rxf_val |=3D GMAC_RX_FILTER_AB;
+	}
+	WRITE_REG(priv, regGMAC_RXF_A, rxf_val);
+	/* enable RX */
+	/* FIXME: RXE(ON) */
+	RET();
+}
+
+static int bdx_set_mac(struct net_device *ndev, void *p)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+	struct sockaddr *addr =3D p;
+
+	ENTER;
+	/*
+	   if (netif_running(dev))
+	   return -EBUSY
+	 */
+	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+	bdx_restore_mac(ndev, priv);
+	RET(0);
+}
+
+static int bdx_read_mac(struct bdx_priv *priv)
+{
+	u16 macAddress[3], i;
+	ENTER;
+
+	macAddress[2] =3D READ_REG(priv, regUNC_MAC0_A);
+	macAddress[2] =3D READ_REG(priv, regUNC_MAC0_A);
+	macAddress[1] =3D READ_REG(priv, regUNC_MAC1_A);
+	macAddress[1] =3D READ_REG(priv, regUNC_MAC1_A);
+	macAddress[0] =3D READ_REG(priv, regUNC_MAC2_A);
+	macAddress[0] =3D READ_REG(priv, regUNC_MAC2_A);
+	for (i =3D 0; i < 3; i++) {
+		priv->ndev->dev_addr[i * 2 + 1] =3D macAddress[i];
+		priv->ndev->dev_addr[i * 2] =3D macAddress[i] >> 8;
+	}
+	RET(0);
+}
+
+static u64 bdx_read_l2stat(struct bdx_priv *priv, int reg)
+{
+	u64 val;
+
+	val =3D READ_REG(priv, reg);
+	val |=3D ((u64) READ_REG(priv, reg + 8)) << 32;
+	return val;
+}
+
+/*Do the statistics-update work*/
+static void bdx_update_stats(struct bdx_priv *priv)
+{
+	struct bdx_stats *stats =3D &priv->hw_stats;
+	u64 *stats_vector =3D (u64 *) stats;
+	int i;
+	int addr;
+
+	/*Fill HW structure */
+	addr =3D 0x7200;
+	/*First 12 statistics - 0x7200 - 0x72B0 */
+	for (i =3D 0; i < 12; i++) {
+		stats_vector[i] =3D bdx_read_l2stat(priv, addr);
+		addr +=3D 0x10;
+	}
+	BDX_ASSERT(addr !=3D 0x72C0);
+	/* 0x72C0-0x72E0 RSRV */
+	addr =3D 0x72F0;
+	for (; i < 16; i++) {
+		stats_vector[i] =3D bdx_read_l2stat(priv, addr);
+		addr +=3D 0x10;
+	}
+	BDX_ASSERT(addr !=3D 0x7330);
+	/* 0x7330-0x7360 RSRV */
+	addr =3D 0x7370;
+	for (; i < 19; i++) {
+		stats_vector[i] =3D bdx_read_l2stat(priv, addr);
+		addr +=3D 0x10;
+	}
+	BDX_ASSERT(addr !=3D 0x73A0);
+	/* 0x73A0-0x73B0 RSRV */
+	addr =3D 0x73C0;
+	for (; i < 23; i++) {
+		stats_vector[i] =3D bdx_read_l2stat(priv, addr);
+		addr +=3D 0x10;
+	}
+	BDX_ASSERT(addr !=3D 0x7400);
+	BDX_ASSERT((sizeof(struct bdx_stats) / sizeof(u64)) !=3D i);
+}
+
+static struct net_device_stats *bdx_get_stats(struct net_device *ndev)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+	struct net_device_stats *net_stat =3D &priv->net_stats;
+	return net_stat;
+}
+
+static void print_rxdd(struct rxd_desc *rxdd, u32 rxd_val1, u16 len,
+		       u16 rxd_vlan);
+static void print_rxfd(struct rxf_desc *rxfd);
+
+/***********************************************************************=
**
+ *     Rx DB                                                            =
 *
+ =
*************************************************************************=
/
+
+static void bdx_rxdb_destroy(struct rxdb *db)
+{
+	if (db)
+		vfree(db);
+}
+
+static struct rxdb *bdx_rxdb_create(int nelem)
+{
+	struct rxdb *db;
+	int i;
+
+	db =3D vmalloc(sizeof(struct rxdb)
+		     + (nelem * sizeof(int))
+		     + (nelem * sizeof(struct rx_map)));
+	if (likely(db !=3D NULL)) {
+		db->stack =3D (int *)(db + 1);
+		db->elems =3D (void *)(db->stack + nelem);
+		db->nelem =3D nelem;
+		db->top =3D nelem;
+		for (i =3D 0; i < nelem; i++)
+			db->stack[i] =3D nelem - i - 1;	/* to make first allocs
+							   close to db struct*/
+	}
+
+	return db;
+}
+
+static inline int bdx_rxdb_alloc_elem(struct rxdb *db)
+{
+	BDX_ASSERT(db->top <=3D 0);
+	return db->stack[--(db->top)];
+}
+
+static inline void *bdx_rxdb_addr_elem(struct rxdb *db, int n)
+{
+	BDX_ASSERT((n < 0) || (n >=3D db->nelem));
+	return db->elems + n;
+}
+
+static inline int bdx_rxdb_available(struct rxdb *db)
+{
+	return db->top;
+}
+
+static inline void bdx_rxdb_free_elem(struct rxdb *db, int n)
+{
+	BDX_ASSERT((n >=3D db->nelem) || (n < 0));
+	db->stack[(db->top)++] =3D n;
+}
+
+/***********************************************************************=
**
+ *     Rx Init                                                          =
 *
+ =
*************************************************************************=
/
+
+/* bdx_rx_init - initialize RX all related HW and SW resources
+ * @priv - NIC private structure
+ *
+ * Returns 0 on success, negative value on failure
+ *
+ * It creates rxf and rxd fifos, update relevant HW registers, =
preallocate
+ * skb for rx. It assumes that Rx is desabled in HW
+ * funcs are grouped for better cache usage
+ *
+ * RxD fifo is smaller then RxF fifo by design. Upon high load, RxD =
will be
+ * filled and packets will be dropped by nic without getting into host =
or
+ * cousing interrupt. Anyway, in that condition, host has no chance to =
proccess
+ * all packets, but dropping in nic is cheaper, since it takes 0 cpu =
cycles
+ */
+
+/* TBD: ensure proper packet size */
+
+static int bdx_rx_init(struct bdx_priv *priv)
+{
+	ENTER;
+	BDX_ASSERT(priv =3D=3D 0);
+	if (bdx_fifo_init(priv, &priv->rxd_fifo0.m, priv->rxd_size,
+			  regRXD_CFG0_0, regRXD_CFG1_0,
+			  regRXD_RPTR_0, regRXD_WPTR_0))
+		goto err_mem;
+	if (bdx_fifo_init(priv, &priv->rxf_fifo0.m, priv->rxf_size,
+			  regRXF_CFG0_0, regRXF_CFG1_0,
+			  regRXF_RPTR_0, regRXF_WPTR_0))
+		goto err_mem;
+	if (!
+	    (priv->rxdb =3D
+	     bdx_rxdb_create(priv->rxf_fifo0.m.memsz /
+			     sizeof(struct rxf_desc))))
+		goto err_mem;
+
+	priv->rxf_fifo0.m.pktsz =3D priv->ndev->mtu + VLAN_ETH_HLEN;
+	return 0;
+
+err_mem:
+	ERR("%s: %s: Rx init failed\n", BDX_DRV_NAME, priv->ndev->name);
+	return -ENOMEM;
+}
+
+/* bdx_rx_free_skbs - frees and unmaps all skbs allocated for the fifo
+ * @priv - NIC private structure
+ * @f - RXF fifo
+ */
+static void bdx_rx_free_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
+{
+	struct rx_map *dm;
+	struct rxdb *db =3D priv->rxdb;
+	u16 i;
+
+	ENTER;
+	DBG("total=3D%d free=3D%d busy=3D%d\n", db->nelem, =
bdx_rxdb_available(db),
+	    db->nelem - bdx_rxdb_available(db));
+	while (bdx_rxdb_available(db) > 0) {
+		i =3D bdx_rxdb_alloc_elem(db);
+		dm =3D bdx_rxdb_addr_elem(db, i);
+		dm->dma =3D 0;
+	}
+	for (i =3D 0; i < db->nelem; i++) {
+		dm =3D bdx_rxdb_addr_elem(db, i);
+		if (dm->dma) {
+			pci_unmap_single(priv->pdev,
+					 dm->dma, f->m.pktsz,
+					 PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(dm->skb);
+		}
+	}
+}
+
+/* bdx_rx_free - release all Rx resources
+ * @priv - NIC private structure
+ * It assumes that Rx is desabled in HW
+ */
+static void bdx_rx_free(struct bdx_priv *priv)
+{
+	ENTER;
+	if (priv->rxdb) {
+		bdx_rx_free_skbs(priv, &priv->rxf_fifo0);
+		bdx_rxdb_destroy(priv->rxdb);
+		priv->rxdb =3D NULL;
+	}
+	bdx_fifo_free(priv, &priv->rxf_fifo0.m);
+	bdx_fifo_free(priv, &priv->rxd_fifo0.m);
+
+	RET();
+}
+
+/***********************************************************************=
**
+ *     Rx Engine                                                        =
 *
+ =
*************************************************************************=
/
+
+/* bdx_rx_alloc_skbs - fill rxf fifo with new skbs
+ * @priv - nic's private structure
+ * @f - RXF fifo that needs skbs
+ * It allocates skbs, build rxf descs and push it (rxf descr) into rxf =
fifo.
+ * skb's virtual and physical addresses are stored in skb db.
+ * To calculate free space, func uses cached values of RPTR and WPTR
+ * When needed, it also updates RPTR and WPTR.
+ */
+
+/* TBD: do not update WPTR if no desc were written */
+
+static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo =
*f)
+{
+	struct sk_buff *skb;
+	struct rxf_desc *rxfd;
+	struct rx_map *dm;
+	int dno, delta, idx;
+	struct rxdb *db =3D priv->rxdb;
+
+	ENTER;
+	dno =3D bdx_rxdb_available(db) - 1;
+	while (dno > 0) {
+		if (!(skb =3D dev_alloc_skb(f->m.pktsz + NET_IP_ALIGN))) {
+			ERR("NO MEM: dev_alloc_skb failed\n");
+			break;
+		}
+		skb->dev =3D priv->ndev;
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		idx =3D bdx_rxdb_alloc_elem(db);
+		dm =3D bdx_rxdb_addr_elem(db, idx);
+		dm->dma =3D pci_map_single(priv->pdev,
+					 skb->data, f->m.pktsz,
+					 PCI_DMA_FROMDEVICE);
+		dm->skb =3D skb;
+		rxfd =3D (struct rxf_desc *)(f->m.va + f->m.wptr);
+		rxfd->info =3D CPU_CHIP_SWAP32(0x10003);	/* INFO=3D1 BC=3D3 */
+		rxfd->va_lo =3D idx;
+		rxfd->pa_lo =3D CPU_CHIP_SWAP32(L32_64(dm->dma));
+		rxfd->pa_hi =3D CPU_CHIP_SWAP32(H32_64(dm->dma));
+		rxfd->len =3D CPU_CHIP_SWAP32(f->m.pktsz);
+		print_rxfd(rxfd);
+
+		f->m.wptr +=3D sizeof(struct rxf_desc);
+		delta =3D f->m.wptr - f->m.memsz;
+		if (unlikely(delta >=3D 0)) {
+			f->m.wptr =3D delta;
+			if (delta > 0) {
+				memcpy(f->m.va, f->m.va + f->m.memsz, delta);
+				DBG("wrapped descriptor\n");
+			}
+		}
+		dno--;
+	}
+	/*TBD: to do - delayed rxf wptr like in txd */
+	WRITE_REG(priv, f->m.reg_WPTR, f->m.wptr & TXF_WPTR_WR_PTR);
+	RET();
+}
+
+static inline void
+NETIF_RX_MUX(struct bdx_priv *priv, u32 rxd_val1, u16 rxd_vlan,
+	     struct sk_buff *skb)
+{
+	ENTER;
+	DBG("rxdd->flags.bits.vtag=3D%d vlgrp=3D%p\n", GET_RXD_VTAG(rxd_val1),
+	    priv->vlgrp);
+	if (priv->vlgrp && GET_RXD_VTAG(rxd_val1)) {
+		DBG("%s: vlan rcv vlan '%x' vtag '%x', device name '%s'\n",
+		    priv->ndev->name,
+		    GET_RXD_VLAN_ID(rxd_vlan),
+		    GET_RXD_VTAG(rxd_val1),
+		    vlan_group_get_device(priv->vlgrp,
+					  GET_RXD_VLAN_ID(rxd_vlan))->name);
+		/* NAPI variant of receive functions */
+		vlan_hwaccel_receive_skb(skb, priv->vlgrp,
+					 GET_RXD_VLAN_ID(rxd_vlan));
+	} else {
+		netif_receive_skb(skb);
+	}
+}
+
+static void bdx_recycle_skb(struct bdx_priv *priv, struct rxd_desc =
*rxdd)
+{
+	struct rxf_desc *rxfd;
+	struct rx_map *dm;
+	struct rxf_fifo *f;
+	struct rxdb *db;
+	struct sk_buff *skb;
+	int delta;
+
+	ENTER;
+	DBG("priv=3D%p rxdd=3D%p\n", priv, rxdd);
+	f =3D &priv->rxf_fifo0;
+	db =3D priv->rxdb;
+	DBG("db=3D%p f=3D%p\n", db, f);
+	dm =3D bdx_rxdb_addr_elem(db, rxdd->va_lo);
+	DBG("dm=3D%p\n", dm);
+	skb =3D dm->skb;
+	rxfd =3D (struct rxf_desc *)(f->m.va + f->m.wptr);
+	rxfd->info =3D CPU_CHIP_SWAP32(0x10003);	/* INFO=3D1 BC=3D3 */
+	rxfd->va_lo =3D rxdd->va_lo;
+	rxfd->pa_lo =3D CPU_CHIP_SWAP32(L32_64(dm->dma));
+	rxfd->pa_hi =3D CPU_CHIP_SWAP32(H32_64(dm->dma));
+	rxfd->len =3D CPU_CHIP_SWAP32(f->m.pktsz);
+	print_rxfd(rxfd);
+
+	f->m.wptr +=3D sizeof(struct rxf_desc);
+	delta =3D f->m.wptr - f->m.memsz;
+	if (unlikely(delta >=3D 0)) {
+		f->m.wptr =3D delta;
+		if (delta > 0) {
+			memcpy(f->m.va, f->m.va + f->m.memsz, delta);
+			DBG("wrapped descriptor\n");
+		}
+	}
+	RET();
+}
+
+/* bdx_rx_receive - recieves full packets from RXD fifo and pass them =
to OS
+ * NOTE: a special treatment is given to non-continous descriptors
+ * that start near the end, wraps around and continue at the beginning. =
a second
+ * part is copied right after the first, and then descriptor is =
interpreted as
+ * normal. fifo has an extra space to allow such operations
+ * @priv - nic's private structure
+ * @f - RXF fifo that needs skbs
+ */
+
+/* TBD: replace memcpy func call by explicite inline asm */
+
+//static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int *budget)
+static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, =
int budget)
+{
+	struct sk_buff *skb, *skb2;
+	struct rxd_desc *rxdd;
+	struct rx_map *dm;
+	struct rxf_fifo *rxf_fifo;
+	int tmp_len, size;
+	int done =3D 0;
+	struct rxdb *db =3D NULL;
+	/* Unmarshalled descriptor - copy of descriptor in host order */
+	u32 rxd_val1;
+	u16 len;
+	u16 rxd_vlan;
+
+	ENTER;
+
+	priv->ndev->last_rx =3D jiffies;
+	f->m.wptr =3D READ_REG(priv, f->m.reg_WPTR) & TXF_WPTR_WR_PTR;
+
+	size =3D f->m.wptr - f->m.rptr;
+	if (size < 0)
+		size =3D f->m.memsz + size;	/* size is negative :-) */
+
+	while (size > 0) {
+
+		rxdd =3D (struct rxd_desc *)(f->m.va + f->m.rptr);
+		rxd_val1 =3D CPU_CHIP_SWAP32(rxdd->rxd_val1);
+
+		len =3D CPU_CHIP_SWAP16(rxdd->len);
+
+		rxd_vlan =3D CPU_CHIP_SWAP16(rxdd->rxd_vlan);
+
+		print_rxdd(rxdd, rxd_val1, len, rxd_vlan);
+
+		tmp_len =3D GET_RXD_BC(rxd_val1) << 3;
+		BDX_ASSERT(tmp_len <=3D 0);
+		size -=3D tmp_len;
+		if (size < 0)	/* test for partially arrived descriptor */
+			break;
+
+		f->m.rptr +=3D tmp_len;
+
+		tmp_len =3D f->m.rptr - f->m.memsz;
+		if (unlikely(tmp_len >=3D 0)) {
+			f->m.rptr =3D tmp_len;
+			if (tmp_len > 0) {
+				DBG("wrapped desc rptr=3D%d tmp_len=3D%d\n",
+				    f->m.rptr, tmp_len);
+				memcpy(f->m.va + f->m.memsz, f->m.va, tmp_len);
+			}
+		}
+
+		if (unlikely(GET_RXD_ERR(rxd_val1))) {
+			DBG("rxd_err =3D 0x%x\n", GET_RXD_ERR(rxd_val1));
+			priv->net_stats.rx_errors++;
+			bdx_recycle_skb(priv, rxdd);
+			continue;
+		}
+
+		rxf_fifo =3D &priv->rxf_fifo0;
+		db =3D priv->rxdb;
+		dm =3D bdx_rxdb_addr_elem(db, rxdd->va_lo);
+		skb =3D dm->skb;
+
+		if (len < BDX_COPYBREAK &&
+		    (skb2 =3D dev_alloc_skb(len + NET_IP_ALIGN))) {
+			skb_reserve(skb2, NET_IP_ALIGN);
+			/*skb_put(skb2, len); */
+			pci_dma_sync_single_for_cpu(priv->pdev,
+						    dm->dma, rxf_fifo->m.pktsz,
+						    PCI_DMA_FROMDEVICE);
+			memcpy(skb2->data, skb->data, len);
+			bdx_recycle_skb(priv, rxdd);
+			skb =3D skb2;
+		} else {
+			pci_unmap_single(priv->pdev,
+					 dm->dma, rxf_fifo->m.pktsz,
+					 PCI_DMA_FROMDEVICE);
+			bdx_rxdb_free_elem(db, rxdd->va_lo);
+		}
+
+		priv->net_stats.rx_bytes +=3D len;
+
+		skb_put(skb, len);
+		skb->dev =3D priv->ndev;
+		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+		skb->protocol =3D eth_type_trans(skb, priv->ndev);
+
+		/* Non-IP packets aren't checksum-offloaded */
+		if (GET_RXD_PKT_ID(rxd_val1) =3D=3D 0)
+			skb->ip_summed =3D CHECKSUM_NONE;
+
+		NETIF_RX_MUX(priv, rxd_val1, rxd_vlan, skb);
+
+		if (++done >=3D budget)
+			break;
+	}
+
+	priv->net_stats.rx_packets +=3D done;
+
+	/* FIXME: do smth to minimize pci accesses    */
+	WRITE_REG(priv, f->m.reg_RPTR, f->m.rptr & TXF_WPTR_WR_PTR);
+
+	bdx_rx_alloc_skbs(priv, &priv->rxf_fifo0);
+
+	return done;
+}
+
+/***********************************************************************=
**
+ * Debug / Temprorary Code                                              =
 *
+ =
*************************************************************************=
/
+static void print_rxdd(struct rxd_desc *rxdd, u32 rxd_val1, u16 len,
+		       u16 rxd_vlan)
+{
+	DBG("ERROR: rxdd bc %d rxfq %d to %d type %d err %d rxp %d "
+	    "pkt_id %d vtag %d len %d vlan_id %d cfi %d prio %d "
+	    "va_lo %d va_hi %d\n",
+	    GET_RXD_BC(rxd_val1), GET_RXD_RXFQ(rxd_val1), =
GET_RXD_TO(rxd_val1),
+	    GET_RXD_TYPE(rxd_val1), GET_RXD_ERR(rxd_val1),
+	    GET_RXD_RXP(rxd_val1), GET_RXD_PKT_ID(rxd_val1),
+	    GET_RXD_VTAG(rxd_val1), len, GET_RXD_VLAN_ID(rxd_vlan),
+	    GET_RXD_CFI(rxd_vlan), GET_RXD_PRIO(rxd_vlan), rxdd->va_lo,
+	    rxdd->va_hi);
+}
+
+static void print_rxfd(struct rxf_desc *rxfd)
+{
+	DBG("=3D=3D=3D RxF desc CHIP ORDER/ENDIANESS =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n"
+	    "info 0x%x va_lo %u pa_lo 0x%x pa_hi 0x%x len 0x%x\n",
+	    rxfd->info, rxfd->va_lo, rxfd->pa_lo, rxfd->pa_hi, rxfd->len);
+}
+
+/*
+ * TX HW/SW interaction overview
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ * There are 2 types of TX communication channels betwean driver and =
NIC.
+ * 1) TX Free Fifo - TXF - holds ack descriptors for sent packets
+ * 2) TX Data Fifo - TXD - holds descriptors of full buffers.
+ *
+ * Currently NIC supports TSO, checksuming and gather DMA
+ * UFO and IP fragmentation is on the way
+ *
+ * RX SW Data Structures
+ * ~~~~~~~~~~~~~~~~~~~~~
+ * txdb - used to keep track of all skbs owned by SW and their dma =
addresses.
+ * For TX case, ownership lasts from geting packet via hard_xmit and =
until HW
+ * acknowledges sent by TXF descriptors.
+ * Implemented as cyclic buffer.
+ * fifo - keeps info about fifo's size and location, relevant HW =
registers,
+ * usage and skb db. Each RXD and RXF Fifo has its own fifo structure.
+ * Implemented as simple struct.
+ *
+ * TX SW Execution Flow
+ * ~~~~~~~~~~~~~~~~~~~~
+ * OS calls driver's hard_xmit method with packet to sent.
+ * Driver creates DMA mappings, builds TXD descriptors and kicks HW
+ * by updating TXD WPTR.
+ * When packet is sent, HW write us TXF descriptor and SW frees =
original skb.
+ * To prevent TXD fifo overflow without reading HW registers every =
time,
+ * SW deploys "tx level" technique.
+ * Upon strart up, tx level is initialized to TXD fifo length.
+ * For every sent packet, SW gets its TXD descriptor sizei
+ * (from precalculated array) and substructs it from tx level.
+ * The size is also stored in txdb. When TXF ack arrives, SW fetch size =
of
+ * original TXD descriptor from txdb and adds it to tx level.
+ * When Tx level drops under some predefined treshhold, the driver
+ * stops the TX queue. When TX level rises above that level,
+ * the tx queue is enabled again.
+ *
+ * This technique avoids eccessive reading of RPTR and WPTR registers.
+ * As our benchmarks shows, it adds 1.5 Gbit/sec to NIS's throuput.
+ */
+
+/***********************************************************************=
**
+ *     Tx DB                                                            =
 *
+ =
*************************************************************************=
/
+static inline int bdx_tx_db_size(struct txdb *db)
+{
+	int taken =3D db->wptr - db->rptr;
+	if (taken < 0)
+		taken =3D db->size + 1 + taken;	/* (size + 1) equals memsz */
+
+	return db->size - taken;
+}
+
+/* __bdx_tx_ptr_next - helper function, increment read/write pointer + =
wrap
+ * @d   - tx data base
+ * @ptr - read or write pointer
+ */
+static inline void __bdx_tx_db_ptr_next(struct txdb *db, struct tx_map =
**pptr)
+{
+	BDX_ASSERT(db =3D=3D NULL || pptr =3D=3D NULL);	/* sanity */
+
+	BDX_ASSERT(*pptr !=3D db->rptr &&	/* expect either read */
+		   *pptr !=3D db->wptr);	/* or write pointer */
+
+	BDX_ASSERT(*pptr < db->start ||	/* pointer has to be */
+		   *pptr >=3D db->end);	/* in range */
+
+	++*pptr;
+	if (unlikely(*pptr =3D=3D db->end))
+		*pptr =3D db->start;
+}
+
+/* bdx_tx_db_inc_rptr - increment read pointer
+ * @d   - tx data base
+ */
+static inline void bdx_tx_db_inc_rptr(struct txdb *db)
+{
+	BDX_ASSERT(db->rptr =3D=3D db->wptr);	/* can't read from empty db */
+	__bdx_tx_db_ptr_next(db, &db->rptr);
+}
+
+/* bdx_tx_db_inc_rptr - increment write pointer
+ * @d   - tx data base
+ */
+static inline void bdx_tx_db_inc_wptr(struct txdb *db)
+{
+	__bdx_tx_db_ptr_next(db, &db->wptr);
+	BDX_ASSERT(db->rptr =3D=3D db->wptr);	/* we can not get empty db as
+						   a result of write */
+}
+
+/* bdx_tx_db_init - creates and initializes tx db
+ * @d       - tx data base
+ * @sz_type - size of tx fifo
+ * Returns 0 on success, error code otherwise
+ */
+static int bdx_tx_db_init(struct txdb *d, int sz_type)
+{
+	int memsz =3D FIFO_SIZE * (1 << (sz_type + 1));
+
+	d->start =3D vmalloc(memsz);
+	if (!d->start)
+		return -ENOMEM;
+
+	/*
+	 * In order to differentiate between db is empty and db is full
+	 * states at least one element should always be empty in order to
+	 * avoid rptr =3D=3D wptr which means db is empty
+	 */
+	d->size =3D memsz / sizeof(struct tx_map) - 1;
+	d->end =3D d->start + d->size + 1;	/* just after last element */
+
+	/* all dbs are created equally empty */
+	d->rptr =3D d->start;
+	d->wptr =3D d->start;
+
+	return 0;
+}
+
+/* bdx_tx_db_close - closes tx db and frees all memory
+ * @d - tx data base
+ */
+static void bdx_tx_db_close(struct txdb *d)
+{
+	BDX_ASSERT(d =3D=3D NULL);
+
+	if (d->start) {
+		vfree(d->start);
+		d->start =3D NULL;
+	}
+}
+
+/***********************************************************************=
**
+ *     Tx Engine                                                        =
 *
+ =
*************************************************************************=
/
+
+/* sizes of tx desc (including padding if needed) as function
+ * of skb's frag number */
+static struct {
+	u16 bytes;
+	u16 qwords;		/* qword =3D 64 bit */
+} txd_sizes[MAX_SKB_FRAGS + 1];
+
+/* txdb_map_skb - creates and stores dma mappings for skb's data blocks
+ * @priv - NIC private structure
+ * @skb  - socket buffer to map
+ *
+ * It makes dma mappings for skb's data blocks and writes them to PBL =
of
+ * new tx descriptor. It also stores them in the tx db, so they could =
be
+ * unmaped after data was sent. It is reponsibility of a caller to make
+ * sure that there is enough space in the tx db. Last element holds =
pointer
+ * to skb itself and marked with zero length
+ */
+static inline void
+bdx_tx_map_skb(struct bdx_priv *priv, struct sk_buff *skb,
+	       struct txd_desc *txdd)
+{
+	struct txdb *db =3D &priv->txdb;
+	struct pbl *pbl =3D &txdd->pbl[0];
+	int nr_frags =3D skb_shinfo(skb)->nr_frags;
+	int i;
+
+	db->wptr->len =3D skb->len - skb->data_len;
+	db->wptr->addr.dma =3D pci_map_single(priv->pdev, skb->data,
+					    db->wptr->len, PCI_DMA_TODEVICE);
+	pbl->len =3D CPU_CHIP_SWAP32(db->wptr->len);
+	pbl->pa_lo =3D CPU_CHIP_SWAP32(L32_64(db->wptr->addr.dma));
+	pbl->pa_hi =3D CPU_CHIP_SWAP32(H32_64(db->wptr->addr.dma));
+	DBG("=3D=3D=3D pbl   len: 0x%x =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n", pbl->len);
+	DBG("=3D=3D=3D pbl pa_lo: 0x%x =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n", pbl->pa_lo);
+	DBG("=3D=3D=3D pbl pa_hi: 0x%x =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n", pbl->pa_hi);
+	bdx_tx_db_inc_wptr(db);
+
+	for (i =3D 0; i < nr_frags; i++) {
+		struct skb_frag_struct *frag;
+
+		frag =3D &skb_shinfo(skb)->frags[i];
+		db->wptr->len =3D frag->size;
+		db->wptr->addr.dma =3D
+		    pci_map_page(priv->pdev, frag->page, frag->page_offset,
+				 frag->size, PCI_DMA_TODEVICE);
+
+		pbl++;
+		pbl->len =3D CPU_CHIP_SWAP32(db->wptr->len);
+		pbl->pa_lo =3D CPU_CHIP_SWAP32(L32_64(db->wptr->addr.dma));
+		pbl->pa_hi =3D CPU_CHIP_SWAP32(H32_64(db->wptr->addr.dma));
+		bdx_tx_db_inc_wptr(db);
+	}
+
+	/* add skb clean up info. */
+	db->wptr->len =3D -txd_sizes[nr_frags].bytes;
+	db->wptr->addr.skb =3D skb;
+	bdx_tx_db_inc_wptr(db);
+}
+
+/* init_txd_sizes - precalculate sizes of descriptors for skbs up to 16 =
frags
+ * number of frags is used as index to fetch correct descriptors size,
+ * instead of calculating it each time */
+static void __init init_txd_sizes(void)
+{
+	int i, lwords;
+
+	/* 7 - is number of lwords in txd with one phys buffer
+	 * 3 - is number of lwords used for every additional phys buffer */
+	for (i =3D 0; i < MAX_SKB_FRAGS + 1; i++) {
+		lwords =3D 7 + (i * 3);
+		if (lwords & 1)
+			lwords++;	/* pad it with 1 lword */
+		txd_sizes[i].qwords =3D lwords >> 1;
+		txd_sizes[i].bytes =3D lwords << 2;
+	}
+}
+
+/* bdx_tx_init - initialize all Tx related stuff.
+ * Namely, TXD and TXF fifos, database etc */
+static int bdx_tx_init(struct bdx_priv *priv)
+{
+	if (bdx_fifo_init(priv, &priv->txd_fifo0.m, priv->txd_size,
+			  regTXD_CFG0_0,
+			  regTXD_CFG1_0, regTXD_RPTR_0, regTXD_WPTR_0))
+		goto err_mem;
+	if (bdx_fifo_init(priv, &priv->txf_fifo0.m, priv->txf_size,
+			  regTXF_CFG0_0,
+			  regTXF_CFG1_0, regTXF_RPTR_0, regTXF_WPTR_0))
+		goto err_mem;
+
+	/* The TX db has to keep mappings for all packets sent (on TxD)
+	 * and not yet reclaimed (on TxF) */
+	if (bdx_tx_db_init(&priv->txdb, max(priv->txd_size, priv->txf_size)))
+		goto err_mem;
+
+	priv->tx_level =3D BDX_MAX_TX_LEVEL;
+#ifdef BDX_DELAY_WPTR
+	priv->tx_update_mark =3D priv->tx_level - 1024;
+#endif
+	return 0;
+
+err_mem:
+	ERR("tehuti: %s: Tx init failed\n", priv->ndev->name);
+	return -ENOMEM;
+}
+
+/*
+ * bdx_tx_space - calculates avalable space in TX fifo
+ * @priv - NIC private structure
+ * Returns avaliable space in TX fifo in bytes
+ */
+static inline int bdx_tx_space(struct bdx_priv *priv)
+{
+	struct txd_fifo *f =3D &priv->txd_fifo0;
+	int fsize;
+
+	f->m.rptr =3D READ_REG(priv, f->m.reg_RPTR) & TXF_WPTR_WR_PTR;
+	fsize =3D f->m.rptr - f->m.wptr;
+	if (fsize <=3D 0)
+		fsize =3D f->m.memsz + fsize;
+	return (fsize);
+}
+
+/* bdx_tx_transmit - send packet to NIC
+ * @skb - packet to send
+ * ndev - network device assigned to NIC
+ * Return codes:
+ * o NETDEV_TX_OK everything ok.
+ * o NETDEV_TX_BUSY Cannot transmit packet, try later
+ *   Usually a bug, means queue start/stop flow control is broken in
+ *   the driver. Note: the driver must NOT put the skb in its DMA ring.
+ * o NETDEV_TX_LOCKED Locking failed, please retry quickly.
+ */
+static int bdx_tx_transmit(struct sk_buff *skb, struct net_device =
*ndev)
+{
+	struct bdx_priv *priv =3D ndev->priv;
+	struct txd_fifo *f =3D &priv->txd_fifo0;
+	int txd_checksum =3D 7;	/* full checksum */
+	int txd_lgsnd =3D 0;
+	int txd_vlan_id =3D 0;
+	int txd_vtag =3D 0;
+	int txd_mss =3D 0;
+
+	int nr_frags =3D skb_shinfo(skb)->nr_frags;
+	struct txd_desc *txdd;
+	int len;
+	unsigned long flags;
+
+	ENTER;
+	local_irq_save(flags);
+	if (!spin_trylock(&priv->tx_lock)) {
+		local_irq_restore(flags);
+		DBG("%s[%s]: TX locked, returning NETDEV_TX_LOCKED\n",
+		    BDX_DRV_NAME, ndev->name);
+		return NETDEV_TX_LOCKED;
+	}
+
+	/* build tx descriptor */
+	BDX_ASSERT(f->m.wptr >=3D f->m.memsz);	/* started with valid wptr */
+	txdd =3D (struct txd_desc *)(f->m.va + f->m.wptr);
+	if (unlikely(skb->ip_summed !=3D CHECKSUM_PARTIAL))
+		txd_checksum =3D 0;
+
+	if (skb_shinfo(skb)->gso_size) {
+		txd_mss =3D skb_shinfo(skb)->gso_size;
+		txd_lgsnd =3D 1;
+		DBG("skb %p skb len %d gso size =3D %d\n", skb, skb->len,
+		    txd_mss);
+	}
+
+	if (vlan_tx_tag_present(skb)) {
+		/*Cut VLAN ID to 12 bits */
+		txd_vlan_id =3D vlan_tx_tag_get(skb) & BITS_MASK(12);
+		txd_vtag =3D 1;
+	}
+
+	txdd->length =3D CPU_CHIP_SWAP16(skb->len);
+	txdd->mss =3D CPU_CHIP_SWAP16(txd_mss);
+	txdd->txd_val1 =3D
+	    CPU_CHIP_SWAP32(TXD_W1_VAL
+			    (txd_sizes[nr_frags].qwords, txd_checksum, txd_vtag,
+			     txd_lgsnd, txd_vlan_id));
+	DBG("=3D=3D=3D TxD desc =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
+	DBG("=3D=3D=3D w1: 0x%x =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n", txdd->txd_val1);
+	DBG("=3D=3D=3D w2: mss 0x%x len 0x%x\n", txdd->mss, txdd->length);
+
+	bdx_tx_map_skb(priv, skb, txdd);
+
+	/* increment TXD write pointer. In case of
+	   fifo wrapping copy reminder of the descriptor
+	   to the beginning */
+	f->m.wptr +=3D txd_sizes[nr_frags].bytes;
+	len =3D f->m.wptr - f->m.memsz;
+	if (unlikely(len >=3D 0)) {
+		f->m.wptr =3D len;
+		if (len > 0) {
+			BDX_ASSERT(len > f->m.memsz);
+			memcpy(f->m.va, f->m.va + f->m.memsz, len);
+		}
+	}
+	BDX_ASSERT(f->m.wptr >=3D f->m.memsz);	/* finished with valid wptr */
+
+	priv->tx_level -=3D txd_sizes[nr_frags].bytes;
+	BDX_ASSERT(priv->tx_level <=3D 0 || priv->tx_level > =
BDX_MAX_TX_LEVEL);
+#ifdef BDX_DELAY_WPTR
+	if (priv->tx_level > priv->tx_update_mark) {
+		/* Force memory writes to complete before letting h/w
+		   know there are new descriptors to fetch.
+		   (might be needed on platforms like IA64)
+		   wmb(); */
+		WRITE_REG(priv, f->m.reg_WPTR, f->m.wptr & TXF_WPTR_WR_PTR);
+	} else {
+		if (priv->tx_noupd++ > BDX_NO_UPD_PACKETS) {
+			priv->tx_noupd =3D 0;
+			WRITE_REG(priv, f->m.reg_WPTR,
+				  f->m.wptr & TXF_WPTR_WR_PTR);
+		}
+	}
+#else
+	/* Force memory writes to complete before letting h/w
+	   know there are new descriptors to fetch.
+	   (might be needed on platforms like IA64)
+	   wmb(); */
+	WRITE_REG(priv, f->m.reg_WPTR, f->m.wptr & TXF_WPTR_WR_PTR);
+
+#endif
+	ndev->trans_start =3D jiffies;
+
+	priv->net_stats.tx_packets++;
+	priv->net_stats.tx_bytes +=3D skb->len;
+
+	if (priv->tx_level < BDX_MIN_TX_LEVEL) {
+		DBG("%s: %s: TX Q STOP level %d\n",
+		    BDX_DRV_NAME, ndev->name, priv->tx_level);
+		netif_stop_queue(ndev);
+	}
+
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
+	return NETDEV_TX_OK;
+}
+
+/* bdx_tx_cleanup - clean TXF fifo, run in the context of IRQ.
+ * @priv - bdx adapter
+ * It scans TXF fifo for descriptors, frees DMA mappings and reports to =
OS
+ * that those packets were sent
+ */
+static void bdx_tx_cleanup(struct bdx_priv *priv)
+{
+	struct txf_fifo *f =3D &priv->txf_fifo0;
+	struct txdb *db =3D &priv->txdb;
+	int tx_level =3D 0;
+
+	ENTER;
+	f->m.wptr =3D READ_REG(priv, f->m.reg_WPTR) & TXF_WPTR_MASK;
+	BDX_ASSERT(f->m.rptr >=3D f->m.memsz);	/* started with valid rptr */
+
+	while (f->m.wptr !=3D f->m.rptr) {
+		f->m.rptr +=3D BDX_TXF_DESC_SZ;
+		f->m.rptr &=3D f->m.size_mask;
+
+		/* unmap all the fragments */
+		/* first has to come tx_maps containing dma */
+		BDX_ASSERT(db->rptr->len =3D=3D 0);
+		do {
+			BDX_ASSERT(db->rptr->addr.dma =3D=3D 0);
+			pci_unmap_page(priv->pdev, db->rptr->addr.dma,
+				       db->rptr->len, PCI_DMA_TODEVICE);
+			bdx_tx_db_inc_rptr(db);
+		} while (db->rptr->len > 0);
+		tx_level -=3D db->rptr->len;	/* '-' koz len is negative */
+
+		/* now should come skb pointer - free it */
+		BDX_ASSERT(db->rptr->addr.skb =3D=3D 0);
+		dev_kfree_skb_irq(db->rptr->addr.skb);
+		bdx_tx_db_inc_rptr(db);
+	}
+
+	/* let h/w know which TXF descriptors were cleaned */
+	BDX_ASSERT((f->m.wptr & TXF_WPTR_WR_PTR) >=3D f->m.memsz);
+	WRITE_REG(priv, f->m.reg_RPTR, f->m.rptr & TXF_WPTR_WR_PTR);
+
+	/* We reclaimed resources, so in case the Q is stopped by xmit =
callback,
+	 * we resume the transmition and use tx_lock to synchronize with =
xmit.*/
+	spin_lock(&priv->tx_lock);
+	priv->tx_level +=3D tx_level;
+	BDX_ASSERT(priv->tx_level <=3D 0 || priv->tx_level > =
BDX_MAX_TX_LEVEL);
+#ifdef BDX_DELAY_WPTR
+	if (priv->tx_noupd) {
+		priv->tx_noupd =3D 0;
+		WRITE_REG(priv, priv->txd_fifo0.m.reg_WPTR,
+			  priv->txd_fifo0.m.wptr & TXF_WPTR_WR_PTR);
+	}
+#endif
+
+	if (unlikely(netif_queue_stopped(priv->ndev)
+		     && netif_carrier_ok(priv->ndev)
+		     && (priv->tx_level >=3D BDX_MIN_TX_LEVEL))) {
+		DBG("%s: %s: TX Q WAKE level %d\n",
+		    BDX_DRV_NAME, priv->ndev->name, priv->tx_level);
+		netif_wake_queue(priv->ndev);
+	}
+	spin_unlock(&priv->tx_lock);
+}
+
+/* bdx_tx_free_skbs - frees all skbs from TXD fifo.
+ * It gets called when OS stops this dev, eg upon "ifconfig down" or =
rmmod
+ */
+static void bdx_tx_free_skbs(struct bdx_priv *priv)
+{
+	struct txdb *db =3D &priv->txdb;
+
+	ENTER;
+	while (db->rptr !=3D db->wptr) {
+		if (likely(db->rptr->len))
+			pci_unmap_page(priv->pdev, db->rptr->addr.dma,
+				       db->rptr->len, PCI_DMA_TODEVICE);
+		else
+			dev_kfree_skb(db->rptr->addr.skb);
+		bdx_tx_db_inc_rptr(db);
+	}
+	RET();
+}
+
+/* bdx_tx_free - frees all Tx resources */
+static void bdx_tx_free(struct bdx_priv *priv)
+{
+	ENTER;
+	bdx_tx_free_skbs(priv);
+	bdx_fifo_free(priv, &priv->txd_fifo0.m);
+	bdx_fifo_free(priv, &priv->txf_fifo0.m);
+	bdx_tx_db_close(&priv->txdb);
+}
+
+/* bdx_tx_push_desc - push descriptor to TxD fifo
+ * @priv - NIC private structure
+ * @data - desc's data
+ * @size - desc's size
+ *
+ * Pushes desc to TxD fifo and overlaps it if needed.
+ * NOTE: this func does not check for available space. this is =
responsibility
+ *    of the caller. Neither does it check that data size is smaller =
then
+ *    fifo size.
+ */
+static void bdx_tx_push_desc(struct bdx_priv *priv, void *data, int =
size)
+{
+	struct txd_fifo *f =3D &priv->txd_fifo0;
+	int i =3D f->m.memsz - f->m.wptr;
+
+	if (size =3D=3D 0)
+		return;
+
+	if (i > size) {
+		memcpy(f->m.va + f->m.wptr, data, size);
+		f->m.wptr +=3D size;
+	} else {
+		memcpy(f->m.va + f->m.wptr, data, i);
+		f->m.wptr =3D size - i;
+		memcpy(f->m.va, data + i, f->m.wptr);
+	}
+	WRITE_REG(priv, f->m.reg_WPTR, f->m.wptr & TXF_WPTR_WR_PTR);
+}
+
+/* bdx_tx_push_desc_safe - push descriptor to TxD fifo in a safe way
+ * @priv - NIC private structure
+ * @data - desc's data
+ * @size - desc's size
+ *
+ * NOTE: this func does check for available space and, if neccessary, =
waits for
+ *   NIC to read existing data before writing new one.
+ */
+static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, =
int size)
+{
+	int timer =3D 0;
+	ENTER;
+
+	while (size > 0) {
+		/* we substruct 8 because when fifo is full rptr =3D=3D wptr
+		   which also means that fifo is empty, we can understand
+		   the difference, but could hw do the same ??? :) */
+		int avail =3D bdx_tx_space(priv) - 8;
+		if (avail <=3D 0) {
+			if (timer++ > 300) {	/* prevent endless loop */
+				DBG("timeout while writing desc to TxD fifo\n");
+				break;
+			}
+			udelay(50);	/* give hw a chance to clean fifo */
+			continue;
+		}
+		avail =3D MIN(avail, size);
+		DBG("about to push  %d bytes starting %p size %d\n", avail,
+		    data, size);
+		bdx_tx_push_desc(priv, data, avail);
+		size -=3D avail;
+		data +=3D avail;
+	}
+	RET();
+}
+
+/**
+ * bdx_probe - Device Initialization Routine
+ * @pdev: PCI device information struct
+ * @ent: entry in bdx_pci_tbl
+ *
+ * Returns 0 on success, negative on failure
+ *
+ * bdx_probe initializes an adapter identified by a pci_dev structure.
+ * The OS initialization, configuring of the adapter private structure,
+ * and a hardware reset occur.
+ *
+ * functions and their order used as explained in
+ * /usr/src/linux/Documentation/DMA-{API,mapping}.txt
+ *
+ */
+
+/* TBD: netif_msg should be checked and implemented. I disable it for =
now */
+static int __devinit
+bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct net_device *ndev;
+	struct bdx_priv *priv;
+	int err, pci_using_dac, port;
+	unsigned long pciaddr;
+	u32 regionSize;
+	struct pci_nic *nic;
+
+	ENTER;
+
+	nic =3D vmalloc(sizeof(*nic));
+	if (!nic)
+		RET(-ENOMEM);
+
+    /************** pci *****************/
+	if ((err =3D pci_enable_device(pdev)))	/* it trigers interrupt, dunno =
why. */
+		RET(err);			/* it's not a problem though */
+
+	if (!(err =3D pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
+	    !(err =3D pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
+		pci_using_dac =3D 1;
+	} else {
+		if ((err =3D pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
+		    (err =3D pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
+			printk(KERN_ERR "tehuti: No usable DMA configuration"
+					", aborting\n");
+			goto err_dma;
+		}
+		pci_using_dac =3D 0;
+	}
+
+	if ((err =3D pci_request_regions(pdev, BDX_DRV_NAME)))
+		goto err_dma;
+
+	pci_set_master(pdev);
+
+	pciaddr =3D pci_resource_start(pdev, 0);
+	if (!pciaddr) {
+		err =3D -EIO;
+		ERR("tehuti: no MMIO resource\n");
+		goto err_out_res;
+	}
+	if ((regionSize =3D pci_resource_len(pdev, 0)) < BDX_REGS_SIZE) {
+		err =3D -EIO;
+		ERR("tehuti: MMIO resource (%x) too small\n", regionSize);
+		goto err_out_res;
+	}
+
+	nic->regs =3D ioremap(pciaddr, regionSize);
+	if (!nic->regs) {
+		err =3D -EIO;
+		ERR("tehuti: ioremap failed\n");
+		goto err_out_res;
+	}
+
+	if (pdev->irq < 2) {
+		err =3D -EIO;
+		ERR("tehuti: invalid irq (%d)\n", pdev->irq);
+		goto err_out_iomap;
+	}
+	pci_set_drvdata(pdev, nic);
+
+	if (pdev->device =3D=3D 0x3014)
+		nic->port_num =3D 2;
+	else
+		nic->port_num =3D 1;
+
+	print_hw_id(pdev);
+
+	bdx_hw_reset_direct(nic->regs);
+
+	nic->irq_type =3D IRQ_INTX;
+#ifdef BDX_MSI
+	if ((readl(nic->regs + FPGA_VER) & 0xFFF) >=3D 378) {
+		if ((err =3D pci_enable_msi(pdev)))
+			ERR("Tehuti: Can't eneble msi. error is %d\n", err);
+		else
+			nic->irq_type =3D IRQ_MSI;
+	} else
+		DBG("HW does not support MSI\n");
+#endif
+
+    /************** netdev **************/
+	for (port =3D 0; port < nic->port_num; port++) {
+		if (!(ndev =3D alloc_etherdev(sizeof(struct bdx_priv)))) {
+			err =3D -ENOMEM;
+			printk(KERN_ERR "tehuti: alloc_etherdev failed\n");
+			goto err_out_iomap;
+		}
+
+		ndev->open =3D bdx_open;
+		ndev->stop =3D bdx_close;
+		ndev->hard_start_xmit =3D bdx_tx_transmit;
+		ndev->do_ioctl =3D bdx_ioctl;
+		ndev->set_multicast_list =3D bdx_setmulti;
+		ndev->get_stats =3D bdx_get_stats;
+		ndev->change_mtu =3D bdx_change_mtu;
+		ndev->set_mac_address =3D bdx_set_mac;
+		ndev->tx_queue_len =3D BDX_NDEV_TXQ_LEN;
+		ndev->vlan_rx_register =3D bdx_vlan_rx_register;
+		ndev->vlan_rx_add_vid =3D bdx_vlan_rx_add_vid;
+		ndev->vlan_rx_kill_vid =3D bdx_vlan_rx_kill_vid;
+
+		bdx_ethtool_ops(ndev);	/* ethtool interface */
+
+		/* these fields are used for info purposes only
+		 * so we can have them same for all ports of the board */
+		ndev->if_port =3D port;
+		ndev->base_addr =3D pciaddr;
+		ndev->mem_start =3D pciaddr;
+		ndev->mem_end =3D pciaddr + regionSize;
+		ndev->irq =3D pdev->irq;
+		ndev->features =3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
+		    | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
+		    NETIF_F_HW_VLAN_FILTER
+		    /*| NETIF_F_FRAGLIST */
+		    ;
+
+		if (pci_using_dac)
+			ndev->features |=3D NETIF_F_HIGHDMA;
+
+	/************** priv ****************/
+		priv =3D nic->priv[port] =3D ndev->priv;
+
+		memset(priv, 0, sizeof(struct bdx_priv));
+		priv->pBdxRegs =3D nic->regs + port * 0x8000;
+		priv->port =3D port;
+		priv->pdev =3D pdev;
+		priv->ndev =3D ndev;
+		priv->nic =3D nic;
+		priv->msg_enable =3D BDX_DEF_MSG_ENABLE;
+
+		if ((readl(nic->regs + FPGA_VER) & 0xFFF) =3D=3D 308) {
+			DBG("HW statistics not supported\n");
+			priv->stats_flag =3D 0;
+		} else {
+			priv->stats_flag =3D 1;
+		}
+
+		/* Initialize fifo sizes. */
+		priv->txd_size =3D 2;
+		priv->txf_size =3D 2;
+		priv->rxd_size =3D 2;
+		priv->rxf_size =3D 3;
+
+		/* Initialize the initial coalescing registers. */
+		priv->rdintcm =3D INT_REG_VAL(0x20, 1, 4, 12);
+		priv->tdintcm =3D INT_REG_VAL(0x20, 1, 0, 12);
+
+		/* ndev->xmit_lock spinlock is not used.
+		 * Private priv->tx_lock is used for synchronization
+		 * between transmit and TX irq cleanup.  In addition
+		 * set multicast list callback has to use priv->tx_lock.
+		 */
+#ifdef BDX_LLTX
+		ndev->features |=3D NETIF_F_LLTX;
+#endif
+		spin_lock_init(&priv->tx_lock);
+
+		netif_napi_add(ndev, &priv->napi, bdx_poll, 64);
+
+		/*bdx_hw_reset(priv); */
+		if (bdx_read_mac(priv)) {
+			printk(KERN_ERR "tehuti: load MAC address failed\n");
+			goto err_out_iomap;
+		}
+	//	SET_MODULE_OWNER(ndev);
+		SET_NETDEV_DEV(ndev, &pdev->dev);
+		if ((err =3D register_netdev(ndev))) {
+			printk(KERN_ERR "tehuti: register_netdev failed\n");
+			goto err_out_free;
+		}
+		netif_carrier_off(ndev);
+		netif_stop_queue(ndev);
+
+		print_eth_id(ndev);
+	}
+	RET(0);
+
+err_out_free:
+	free_netdev(ndev);
+err_out_iomap:
+	iounmap(nic->regs);
+err_out_res:
+	pci_release_regions(pdev);
+err_dma:
+	pci_disable_device(pdev);
+	vfree(nic);
+
+	RET(err);
+}
+
+/****************** Ethtool interface *********************/
+/* get strings for tests */
+static const char
+ bdx_test_names[][ETH_GSTRING_LEN] =3D {
+	"No tests defined"
+};
+
+/* get strings for statistics counters */
+static const char
+ bdx_stat_names[][ETH_GSTRING_LEN] =3D {
+	"InUCast",		/* 0x7200 */
+	"InMCast",		/* 0x7210 */
+	"InBCast",		/* 0x7220 */
+	"InPkts",		/* 0x7230 */
+	"InErrors",		/* 0x7240 */
+	"InDropped",		/* 0x7250 */
+	"FrameTooLong",		/* 0x7260 */
+	"FrameSequenceErrors",	/* 0x7270 */
+	"InVLAN",		/* 0x7280 */
+	"InDroppedDFE",		/* 0x7290 */
+	"InDroppedIntFull",	/* 0x72A0 */
+	"InFrameAlignErrors",	/* 0x72B0 */
+
+	/* 0x72C0-0x72E0 RSRV */
+
+	"OutUCast",		/* 0x72F0 */
+	"OutMCast",		/* 0x7300 */
+	"OutBCast",		/* 0x7310 */
+	"OutPkts",		/* 0x7320 */
+
+	/* 0x7330-0x7360 RSRV */
+
+	"OutVLAN",		/* 0x7370 */
+	"InUCastOctects",	/* 0x7380 */
+	"OutUCastOctects",	/* 0x7390 */
+
+	/* 0x73A0-0x73B0 RSRV */
+
+	"InBCastOctects",	/* 0x73C0 */
+	"OutBCastOctects",	/* 0x73D0 */
+	"InOctects",		/* 0x73E0 */
+	"OutOctects",		/* 0x73F0 */
+};
+
+/*
+ * bdx_get_settings - get device-specific settings
+ * @netdev
+ * @ecmd
+ */
+static int bdx_get_settings(struct net_device *netdev, struct =
ethtool_cmd *ecmd)
+{
+	u32 rdintcm;
+	u32 tdintcm;
+	struct bdx_priv *priv =3D netdev->priv;
+
+	rdintcm =3D priv->rdintcm;
+	tdintcm =3D priv->tdintcm;
+
+	ecmd->supported =3D (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+	ecmd->advertising =3D (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
+	ecmd->speed =3D SPEED_10000;
+	ecmd->duplex =3D DUPLEX_FULL;
+	ecmd->port =3D PORT_FIBRE;
+	ecmd->transceiver =3D XCVR_EXTERNAL;	/* what does it mean? */
+	ecmd->autoneg =3D AUTONEG_DISABLE;
+
+	/* PCK_TH measures in multiples of FIFO bytes
+	   We translate to packets */
+	ecmd->maxtxpkt =3D
+	    ((GET_PCK_TH(tdintcm) * PCK_TH_MULT) / BDX_TXF_DESC_SZ);
+	ecmd->maxrxpkt =3D
+	    ((GET_PCK_TH(rdintcm) * PCK_TH_MULT) / sizeof(struct rxf_desc));
+
+	return 0;
+}
+
+/*
+ * bdx_get_drvinfo - report driver information
+ * @netdev
+ * @drvinfo
+ */
+static void
+bdx_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo =
*drvinfo)
+{
+	struct bdx_priv *priv =3D netdev->priv;
+
+	strncat(drvinfo->driver, BDX_DRV_NAME, sizeof(drvinfo->driver));
+	strncat(drvinfo->version, BDX_DRV_VERSION, sizeof(drvinfo->version));
+	strncat(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strncat(drvinfo->bus_info, pci_name(priv->pdev),
+		sizeof(drvinfo->bus_info));
+
+	drvinfo->n_stats =3D ((priv->stats_flag) ?
+			    (sizeof(bdx_stat_names) / ETH_GSTRING_LEN) : 0);
+	drvinfo->testinfo_len =3D 0;
+	drvinfo->regdump_len =3D 0;
+	drvinfo->eedump_len =3D 0;
+}
+
+/*
+ * bdx_get_rx_csum - report whether receive checksums are turned on or =
off
+ * @netdev
+ */
+static u32 bdx_get_rx_csum(struct net_device *netdev)
+{
+	return 1;		/* always on */
+}
+
+/*
+ * bdx_get_tx_csum - report whether transmit checksums are turned on or =
off
+ * @netdev
+ */
+static u32 bdx_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
+}
+
+/*
+ * bdx_get_coalesce - get interrupt coalescing parameters
+ * @netdev
+ * @ecoal
+ */
+static int
+bdx_get_coalesce(struct net_device *netdev, struct ethtool_coalesce =
*ecoal)
+{
+	u32 rdintcm;
+	u32 tdintcm;
+	struct bdx_priv *priv =3D netdev->priv;
+
+	rdintcm =3D priv->rdintcm;
+	tdintcm =3D priv->tdintcm;
+
+	/* PCK_TH measures in multiples of FIFO bytes
+	   We translate to packets */
+	ecoal->rx_coalesce_usecs =3D GET_INT_COAL(rdintcm) * INT_COAL_MULT;
+	ecoal->rx_max_coalesced_frames =3D
+	    ((GET_PCK_TH(rdintcm) * PCK_TH_MULT) / sizeof(struct rxf_desc));
+
+	ecoal->tx_coalesce_usecs =3D GET_INT_COAL(tdintcm) * INT_COAL_MULT;
+	ecoal->tx_max_coalesced_frames =3D
+	    ((GET_PCK_TH(tdintcm) * PCK_TH_MULT) / BDX_TXF_DESC_SZ);
+
+	/* adaptive parameters ignored */
+	return 0;
+}
+
+/*
+ * bdx_set_coalesce - set interrupt coalescing parameters
+ * @netdev
+ * @ecoal
+ */
+static int
+bdx_set_coalesce(struct net_device *netdev, struct ethtool_coalesce =
*ecoal)
+{
+	u32 rdintcm;
+	u32 tdintcm;
+	struct bdx_priv *priv =3D netdev->priv;
+	int rx_coal;
+	int tx_coal;
+	int rx_max_coal;
+	int tx_max_coal;
+
+	/* Check for valid input */
+	rx_coal =3D ecoal->rx_coalesce_usecs / INT_COAL_MULT;
+	tx_coal =3D ecoal->tx_coalesce_usecs / INT_COAL_MULT;
+	rx_max_coal =3D ecoal->rx_max_coalesced_frames;
+	tx_max_coal =3D ecoal->tx_max_coalesced_frames;
+
+	/* Translate from packets to multiples of FIFO bytes */
+	rx_max_coal =3D
+	    (((rx_max_coal * sizeof(struct rxf_desc)) + PCK_TH_MULT - 1)
+	     / PCK_TH_MULT);
+	tx_max_coal =3D
+	    (((tx_max_coal * BDX_TXF_DESC_SZ) + PCK_TH_MULT - 1)
+	     / PCK_TH_MULT);
+
+	if ((rx_coal > 0x7FFF) || (tx_coal > 0x7FFF)
+	    || (rx_max_coal > 0xF) || (tx_max_coal > 0xF))
+		return -EINVAL;
+
+	rdintcm =3D INT_REG_VAL(rx_coal, GET_INT_COAL_RC(priv->rdintcm),
+			      GET_RXF_TH(priv->rdintcm), rx_max_coal);
+	tdintcm =3D INT_REG_VAL(tx_coal, GET_INT_COAL_RC(priv->tdintcm), 0,
+			      tx_max_coal);
+
+	priv->rdintcm =3D rdintcm;
+	priv->tdintcm =3D tdintcm;
+
+	WRITE_REG(priv, regRDINTCM0, rdintcm);
+	WRITE_REG(priv, regTDINTCM0, tdintcm);
+
+	return 0;
+}
+
+/* Convert RX fifo size to number of pending packets */
+static inline int bdx_rx_fifo_size_to_packets(int rx_size)
+{
+	return ((FIFO_SIZE * (1 << rx_size)) / sizeof(struct rxf_desc));
+}
+
+/* Convert TX fifo size to number of pending packets */
+static inline int bdx_tx_fifo_size_to_packets(int tx_size)
+{
+	return ((FIFO_SIZE * (1 << tx_size)) / BDX_TXF_DESC_SZ);
+}
+
+/*
+ * bdx_get_ringparam - report ring sizes
+ * @netdev
+ * @ring
+ */
+static void
+bdx_get_ringparam(struct net_device *netdev, struct ethtool_ringparam =
*ring)
+{
+	struct bdx_priv *priv =3D netdev->priv;
+
+	/*max_pending - the maximum-sized FIFO we allow */
+	ring->rx_max_pending =3D bdx_rx_fifo_size_to_packets(3);
+	ring->tx_max_pending =3D bdx_tx_fifo_size_to_packets(3);
+	ring->rx_pending =3D bdx_rx_fifo_size_to_packets(priv->rxf_size);
+	ring->tx_pending =3D bdx_tx_fifo_size_to_packets(priv->txd_size);
+}
+
+/*
+ * bdx_set_ringparam - set ring sizes
+ * @netdev
+ * @ring
+ */
+static int
+bdx_set_ringparam(struct net_device *netdev, struct ethtool_ringparam =
*ring)
+{
+	struct bdx_priv *priv =3D netdev->priv;
+	int rx_size =3D 0;
+	int tx_size =3D 0;
+
+	for (; rx_size < 4; rx_size++) {
+		if (bdx_rx_fifo_size_to_packets(rx_size) >=3D ring->rx_pending)
+			break;
+	}
+	if (rx_size =3D=3D 4)
+		rx_size =3D 3;
+
+	for (; tx_size < 4; tx_size++) {
+		if (bdx_tx_fifo_size_to_packets(tx_size) >=3D ring->tx_pending)
+			break;
+	}
+	if (tx_size =3D=3D 4)
+		tx_size =3D 3;
+
+	/*Is there anything to do? */
+	if ((rx_size =3D=3D priv->rxf_size)
+	    && (tx_size =3D=3D priv->txd_size))
+		return 0;
+
+	priv->rxf_size =3D rx_size;
+	if (rx_size > 1)
+		priv->rxd_size =3D rx_size - 1;
+	else
+		priv->rxd_size =3D rx_size;
+
+	priv->txf_size =3D priv->txd_size =3D tx_size;
+
+	if (netif_running(netdev)) {
+		bdx_close(netdev);
+		bdx_open(netdev);
+	}
+	return 0;
+}
+
+/*
+ * bdx_get_strings - return a set of strings that describe the =
requested objects
+ * @netdev
+ * @data
+ */
+static void bdx_get_strings(struct net_device *netdev, u32 stringset, =
u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(data, *bdx_test_names, sizeof(bdx_test_names));
+		break;
+	case ETH_SS_STATS:
+		memcpy(data, *bdx_stat_names, sizeof(bdx_stat_names));
+		break;
+	}
+}
+
+/*
+ * bdx_get_stats_count - return number of 64bit statistics counters
+ * @netdev
+ */
+static int bdx_get_stats_count(struct net_device *netdev)
+{
+	struct bdx_priv *priv =3D netdev->priv;
+	BDX_ASSERT(sizeof(bdx_stat_names) / ETH_GSTRING_LEN
+		   !=3D sizeof(struct bdx_stats) / sizeof(u64));
+	return ((priv->stats_flag) ? (sizeof(bdx_stat_names) / =
ETH_GSTRING_LEN)
+		: 0);
+}
+
+/*
+ * bdx_get_ethtool_stats - return device's hardware L2 statistics
+ * @netdev
+ * @stats
+ * @data
+ */
+static void bdx_get_ethtool_stats(struct net_device *netdev,
+				  struct ethtool_stats *stats, u64 *data)
+{
+	struct bdx_priv *priv =3D netdev->priv;
+
+	if (priv->stats_flag) {
+
+		/* Update stats from HW */
+		bdx_update_stats(priv);
+
+		/* Copy data to user buffer */
+		memcpy(data, &priv->hw_stats, sizeof(priv->hw_stats));
+	}
+}
+
+/*
+ * bdx_ethtool_ops - ethtool interface implementation
+ * @netdev
+ */
+static void bdx_ethtool_ops(struct net_device *netdev)
+{
+	static struct ethtool_ops bdx_ethtool_ops =3D {
+		.get_settings =3D bdx_get_settings,
+		.get_drvinfo =3D bdx_get_drvinfo,
+		.get_link =3D ethtool_op_get_link,
+		.get_coalesce =3D bdx_get_coalesce,
+		.set_coalesce =3D bdx_set_coalesce,
+		.get_ringparam =3D bdx_get_ringparam,
+		.set_ringparam =3D bdx_set_ringparam,
+		.get_rx_csum =3D bdx_get_rx_csum,
+		.get_tx_csum =3D bdx_get_tx_csum,
+		.get_sg =3D ethtool_op_get_sg,
+		.get_tso =3D ethtool_op_get_tso,
+		.get_strings =3D bdx_get_strings,
+		.get_stats_count =3D bdx_get_stats_count,
+		.get_ethtool_stats =3D bdx_get_ethtool_stats,
+	};
+
+	SET_ETHTOOL_OPS(netdev, &bdx_ethtool_ops);
+}
+
+/**
+ * bdx_remove - Device Removal Routine
+ * @pdev: PCI device information struct
+ *
+ * bdx_remove is called by the PCI subsystem to alert the driver
+ * that it should release a PCI device.  The could be caused by a
+ * Hot-Plug event, or because the driver is going to be removed from
+ * memory.
+ **/
+static void __devexit bdx_remove(struct pci_dev *pdev)
+{
+	struct pci_nic *nic =3D pci_get_drvdata(pdev);
+	struct net_device *ndev;
+	int port;
+
+	for (port =3D 0; port < nic->port_num; port++) {
+		ndev =3D nic->priv[port]->ndev;
+		unregister_netdev(ndev);
+		free_netdev(ndev);
+	}
+
+	/*bdx_hw_reset_direct(nic->regs); */
+#ifdef BDX_MSI
+	if (nic->irq_type =3D=3D IRQ_MSI)
+		pci_disable_msi(pdev);
+#endif
+
+	iounmap(nic->regs);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+	vfree(nic);
+
+	RET();
+}
+
+static struct pci_driver bdx_pci_driver =3D {
+	.name =3D BDX_DRV_NAME,
+	.id_table =3D bdx_pci_tbl,
+	.probe =3D bdx_probe,
+	.remove =3D __devexit_p(bdx_remove),
+};
+
+/*
+ * print_driver_id - print parameters of the driver build
+ */
+static void __init print_driver_id(void)
+{
+	printk(KERN_INFO "%s: %s, %s\n", BDX_DRV_NAME, BDX_DRV_DESC,
+	       BDX_DRV_VERSION);
+	printk(KERN_INFO "%s: Options: hw_csum %s\n", BDX_DRV_NAME,
+	       BDX_MSI_STRING);
+}
+
+static int __init bdx_module_init(void)
+{
+	ENTER;
+	bdx_firmware_endianess();
+	init_txd_sizes();
+	print_driver_id();
+	RET(pci_register_driver(&bdx_pci_driver));
+}
+
+module_init(bdx_module_init);
+
+static void __exit bdx_module_exit(void)
+{
+	ENTER;
+	pci_unregister_driver(&bdx_pci_driver);
+	RET();
+}
+
+module_exit(bdx_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR(DRIVER_AUTHOR);
+MODULE_DESCRIPTION(BDX_DRV_DESC);
diff --git a/drivers/net/tehuti/tehuti.h b/drivers/net/tehuti/tehuti.h
new file mode 100644
index 0000000..3d68b28
--- /dev/null
+++ b/drivers/net/tehuti/tehuti.h
@@ -0,0 +1,563 @@
+/*
+ * Tehuti Networks(R) Network Driver
+ * Copyright (C) 2007 Tehuti Networks Ltd. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _TEHUTI_H
+#define _TEHUTI_H
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/crc32.h>
+#include <linux/uaccess.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/sched.h>
+#include <linux/tty.h>
+#include <linux/if_vlan.h>
+#include <linux/version.h>
+#include <linux/interrupt.h>
+#include <linux/vmalloc.h>
+#include <asm/byteorder.h>
+
+/* Compile Time Switches */
+/* start */
+#define BDX_TSO
+#define BDX_LLTX
+#define BDX_DELAY_WPTR
+/* #define BDX_MSI */
+/* end */
+
+#if !defined CONFIG_PCI_MSI
+#   undef BDX_MSI
+#endif
+
+#define BDX_DEF_MSG_ENABLE	(NETIF_MSG_DRV          | \
+				NETIF_MSG_PROBE        | \
+				NETIF_MSG_LINK)
+
+/* ioctl ops */
+#define BDX_OP_READ  1
+#define BDX_OP_WRITE 2
+
+/* RX copy break size */
+#define BDX_COPYBREAK    257
+
+#define DRIVER_AUTHOR     "Tehuti Networks(R)"
+#define BDX_DRV_DESC      "Tehuti Networks(R) Network Driver"
+#define BDX_DRV_NAME      "tehuti"
+#define BDX_NIC_NAME      "Tehuti 10 Giga TOE SmartNIC"
+#define BDX_NIC2PORT_NAME "Tehuti 2-Port 10 Giga TOE SmartNIC"
+#define BDX_DRV_VERSION   "7.29.3"
+
+#ifdef BDX_MSI
+#    define BDX_MSI_STRING "msi "
+#else
+#    define BDX_MSI_STRING ""
+#endif
+
+/* netdev tx queue len for Luxor. default value is, btw, 1000
+ * ifcontig eth1 txqueuelen 3000 - to change it at runtime */
+#define BDX_NDEV_TXQ_LEN 3000
+
+#define FIFO_SIZE  4096
+#define FIFO_EXTRA_SPACE            1024
+
+#define MIN(x, y)  ((x) < (y) ? (x) : (y))
+
+#if BITS_PER_LONG =3D=3D 64
+#    define H32_64(x)  (u32) ((u64)(x) >> 32)
+#    define L32_64(x)  (u32) ((u64)(x) & 0xffffffff)
+#elif BITS_PER_LONG =3D=3D 32
+#    define H32_64(x)  0
+#    define L32_64(x)  ((u32) (x))
+#else				/* BITS_PER_LONG =3D=3D ?? */
+#    error BITS_PER_LONG is undefined. Must be 64 or 32
+#endif				/* BITS_PER_LONG */
+
+#ifdef __BIG_ENDIAN
+#   define CPU_CHIP_SWAP32(x) swab32(x)
+#   define CPU_CHIP_SWAP16(x) swab16(x)
+#else
+#   define CPU_CHIP_SWAP32(x) (x)
+#   define CPU_CHIP_SWAP16(x) (x)
+#endif
+
+#define READ_REG(pp, reg)         readl(pp->pBdxRegs + reg)
+#define WRITE_REG(pp, reg, val)   writel(val, pp->pBdxRegs + reg)
+
+#ifndef DMA_64BIT_MASK
+#   define DMA_64BIT_MASK  0xffffffffffffffffULL
+#endif
+
+#ifndef DMA_32BIT_MASK
+#   define DMA_32BIT_MASK  0x00000000ffffffffULL
+#endif
+
+#ifndef NET_IP_ALIGN
+#   define NET_IP_ALIGN 2
+#endif
+
+#ifndef NETDEV_TX_OK
+#   define NETDEV_TX_OK 0
+#endif
+
+#define LUXOR_MAX_PORT     2
+#define BDX_MAX_RX_DONE    150
+#define BDX_TXF_DESC_SZ    16
+#define BDX_MAX_TX_LEVEL   (priv->txd_fifo0.m.memsz - 16)
+#define BDX_MIN_TX_LEVEL   256
+#define BDX_NO_UPD_PACKETS 40
+
+struct pci_nic {
+	int port_num;
+	void __iomem *regs;
+	int irq_type;
+	struct bdx_priv *priv[LUXOR_MAX_PORT];
+};
+
+enum { IRQ_INTX, IRQ_MSI, IRQ_MSIX };
+
+#define PCK_TH_MULT   128
+#define INT_COAL_MULT 2
+
+#define BITS_MASK(nbits)			((1<<nbits)-1)
+#define GET_BITS_SHIFT(x, nbits, nshift)	=
(((x)>>nshift)&BITS_MASK(nbits))
+#define BITS_SHIFT_MASK(nbits, nshift)		(BITS_MASK(nbits)<<nshift)
+#define BITS_SHIFT_VAL(x, nbits, nshift)	=
(((x)&BITS_MASK(nbits))<<nshift)
+#define BITS_SHIFT_CLEAR(x, nbits, nshift)	\
+	((x)&(~BITS_SHIFT_MASK(nbits, nshift)))
+
+#define GET_INT_COAL(x)				GET_BITS_SHIFT(x, 15, 0)
+#define GET_INT_COAL_RC(x)			GET_BITS_SHIFT(x, 1, 15)
+#define GET_RXF_TH(x)				GET_BITS_SHIFT(x, 4, 16)
+#define GET_PCK_TH(x)				GET_BITS_SHIFT(x, 4, 20)
+
+#define INT_REG_VAL(coal, coal_rc, rxf_th, pck_th)	\
+	((coal)|((coal_rc)<<15)|((rxf_th)<<16)|((pck_th)<<20))
+
+struct fifo {
+	dma_addr_t da;		/* physical address of fifo (used by HW) */
+	char *va;		/* virtual address of fifo (used by SW) */
+	u32 rptr, wptr;		/* cached values of RPTR and WPTR registers,
+				   they're 32 bits on both 32 and 64 archs */
+	u16 reg_CFG0, reg_CFG1;
+	u16 reg_RPTR, reg_WPTR;
+	u16 memsz;		/* memory size allocated for fifo */
+	u16 size_mask;
+	u16 pktsz;		/* skb packet size to allocate */
+	u16 rcvno;		/* number of buffers that come from this RXF */
+};
+
+struct txf_fifo {
+	struct fifo m;		/* minimal set of variables used by all fifos */
+};
+
+struct txd_fifo {
+	struct fifo m;		/* minimal set of variables used by all fifos */
+};
+
+struct rxf_fifo {
+	struct fifo m;		/* minimal set of variables used by all fifos */
+};
+
+struct rxd_fifo {
+	struct fifo m;		/* minimal set of variables used by all fifos */
+};
+
+struct rx_map {
+	u64 dma;
+	struct sk_buff *skb;
+};
+
+struct rxdb {
+	int *stack;
+	struct rx_map *elems;
+	int nelem;
+	int top;
+};
+
+union bdx_dma_addr {
+	dma_addr_t dma;
+	struct sk_buff *skb;
+};
+
+/* Entry in the db.
+ * if len =3D=3D 0 addr is dma
+ * if len !=3D 0 addr is skb */
+struct tx_map {
+	union bdx_dma_addr addr;
+	int len;
+};
+
+/* tx database - implemented as circular fifo buffer*/
+struct txdb {
+	struct tx_map *start;	/* points to the first element */
+	struct tx_map *end;	/* points just AFTER the last element */
+	struct tx_map *rptr;	/* points to the next element to read */
+	struct tx_map *wptr;	/* points to the next element to write */
+	int size;		/* number of elements in the db */
+};
+
+/*Internal stats structure*/
+struct bdx_stats {
+	u64 InUCast;			/* 0x7200 */
+	u64 InMCast;			/* 0x7210 */
+	u64 InBCast;			/* 0x7220 */
+	u64 InPkts;			/* 0x7230 */
+	u64 InErrors;			/* 0x7240 */
+	u64 InDropped;			/* 0x7250 */
+	u64 FrameTooLong;		/* 0x7260 */
+	u64 FrameSequenceErrors;	/* 0x7270 */
+	u64 InVLAN;			/* 0x7280 */
+	u64 InDroppedDFE;		/* 0x7290 */
+	u64 InDroppedIntFull;		/* 0x72A0 */
+	u64 InFrameAlignErrors;		/* 0x72B0 */
+
+	/* 0x72C0-0x72E0 RSRV */
+
+	u64 OutUCast;			/* 0x72F0 */
+	u64 OutMCast;			/* 0x7300 */
+	u64 OutBCast;			/* 0x7310 */
+	u64 OutPkts;			/* 0x7320 */
+
+	/* 0x7330-0x7360 RSRV */
+
+	u64 OutVLAN;			/* 0x7370 */
+	u64 InUCastOctects;		/* 0x7380 */
+	u64 OutUCastOctects;		/* 0x7390 */
+
+	/* 0x73A0-0x73B0 RSRV */
+
+	u64 InBCastOctects;		/* 0x73C0 */
+	u64 OutBCastOctects;		/* 0x73D0 */
+	u64 InOctects;			/* 0x73E0 */
+	u64 OutOctects;			/* 0x73F0 */
+};
+
+struct bdx_priv {
+	void __iomem *pBdxRegs;
+	struct net_device *ndev;
+
+	struct napi_struct		napi;
+	/* RX FIFOs: 1 for data (full) descs, and 2 for free descs */
+	struct rxd_fifo rxd_fifo0;
+	struct rxf_fifo rxf_fifo0;
+	struct rxdb *rxdb;	/* rx dbs to store skb pointers */
+	int napi_stop;
+	struct vlan_group *vlgrp;
+
+	/* Tx FIFOs: 1 for data desc, 1 for empty (acks) desc */
+	struct txd_fifo txd_fifo0;
+	struct txf_fifo txf_fifo0;
+
+	struct txdb txdb;
+	int tx_level;
+#ifdef BDX_DELAY_WPTR
+	int tx_update_mark;
+	int tx_noupd;
+#endif
+	spinlock_t tx_lock;	/* NETIF_F_LLTX mode */
+
+	/* rarely used */
+	u8 port;
+	u32 msg_enable;
+	int stats_flag;
+	struct bdx_stats hw_stats;
+	struct net_device_stats net_stats;
+	struct pci_dev *pdev;
+
+	struct pci_nic *nic;
+
+	u8 txd_size;
+	u8 txf_size;
+	u8 rxd_size;
+	u8 rxf_size;
+	u32 rdintcm;
+	u32 tdintcm;
+};
+
+/* RX FREE descriptor - 64bit*/
+struct rxf_desc {
+	u32 info;		/* Buffer Count + Info - described below */
+	u32 va_lo;		/* VAdr[31:0] */
+	u32 va_hi;		/* VAdr[63:32] */
+	u32 pa_lo;		/* PAdr[31:0] */
+	u32 pa_hi;		/* PAdr[63:32] */
+	u32 len;		/* Buffer Length */
+};
+
+#define GET_RXD_BC(x)			GET_BITS_SHIFT((x), 5, 0)
+#define GET_RXD_RXFQ(x)			GET_BITS_SHIFT((x), 2, 8)
+#define GET_RXD_TO(x)			GET_BITS_SHIFT((x), 1, 15)
+#define GET_RXD_TYPE(x)			GET_BITS_SHIFT((x), 4, 16)
+#define GET_RXD_ERR(x)			GET_BITS_SHIFT((x), 6, 21)
+#define GET_RXD_RXP(x)			GET_BITS_SHIFT((x), 1, 27)
+#define GET_RXD_PKT_ID(x)		GET_BITS_SHIFT((x), 3, 28)
+#define GET_RXD_VTAG(x)			GET_BITS_SHIFT((x), 1, 31)
+#define GET_RXD_VLAN_ID(x)		GET_BITS_SHIFT((x), 12, 0)
+#define GET_RXD_CFI(x)			GET_BITS_SHIFT((x), 1, 12)
+#define GET_RXD_PRIO(x)			GET_BITS_SHIFT((x), 3, 13)
+
+struct rxd_desc {
+	u32 rxd_val1;
+	u16 len;
+	u16 rxd_vlan;
+	u32 va_lo;
+	u32 va_hi;
+};
+
+/* PBL describes each virtual buffer to be */
+/* transmitted from the host.*/
+struct pbl {
+	u32 pa_lo;
+	u32 pa_hi;
+	u32 len;
+};
+
+/* First word for TXD descriptor. It means: type =3D 3 for regular Tx =
packet,
+ * hw_csum =3D 7 for ip+udp+tcp hw checksums */
+#define TXD_W1_VAL(bc, checksum, vtag, lgsnd, vlan_id)	\
+	((bc) | ((checksum)<<5) | ((vtag)<<8) | \
+	((lgsnd)<<9) | (0x30000) | ((vlan_id)<<20))
+
+struct txd_desc {
+	u32 txd_val1;
+	u16 mss;
+	u16 length;
+	u32 va_lo;
+	u32 va_hi;
+	struct pbl pbl[0];	/* Fragments */
+} __attribute__ ((packed));
+
+/* Register region size */
+#define BDX_REGS_SIZE	  0x1000
+
+/* Registers from 0x0000-0x00fc were remapped to 0x4000-0x40fc */
+#define regTXD_CFG1_0   0x4000
+#define regRXF_CFG1_0   0x4010
+#define regRXD_CFG1_0   0x4020
+#define regTXF_CFG1_0   0x4030
+#define regTXD_CFG0_0   0x4040
+#define regRXF_CFG0_0   0x4050
+#define regRXD_CFG0_0   0x4060
+#define regTXF_CFG0_0   0x4070
+#define regTXD_WPTR_0   0x4080
+#define regRXF_WPTR_0   0x4090
+#define regRXD_WPTR_0   0x40A0
+#define regTXF_WPTR_0   0x40B0
+#define regTXD_RPTR_0   0x40C0
+#define regRXF_RPTR_0   0x40D0
+#define regRXD_RPTR_0   0x40E0
+#define regTXF_RPTR_0   0x40F0
+#define regTXF_RPTR_3   0x40FC
+
+/* hardware versioning */
+#define  FW_VER         0x5010
+#define  SROM_VER       0x5020
+#define  FPGA_VER       0x5030
+#define  FPGA_SEED      0x5040
+
+/* Registers from 0x0100-0x0150 were remapped to 0x5100-0x5150 */
+#define regISR regISR0
+#define regISR0          0x5100
+
+#define regIMR regIMR0
+#define regIMR0          0x5110
+
+#define regRDINTCM0      0x5120
+#define regRDINTCM2      0x5128
+
+#define regTDINTCM0      0x5130
+
+#define regISR_MSK0      0x5140
+
+#define regINIT_SEMAPHORE 0x5170
+#define regINIT_STATUS    0x5180
+
+#define regMAC_LNK_STAT  0x0200
+#define MAC_LINK_STAT    0x4	/* Link state */
+
+#define regGMAC_RXF_A   0x1240
+
+#define regUNC_MAC0_A   0x1250
+#define regUNC_MAC1_A   0x1260
+#define regUNC_MAC2_A   0x1270
+
+#define regVLAN_0       0x1800
+
+#define regMAX_FRAME_A  0x12C0
+
+#define regRX_MAC_MCST0    0x1A80
+#define regRX_MAC_MCST1    0x1A84
+#define MAC_MCST_NUM       15
+#define regRX_MCST_HASH0   0x1A00
+#define MAC_MCST_HASH_NUM  8
+
+#define regVPC                  0x2300
+#define regVIC                  0x2320
+#define regVGLB                 0x2340
+
+#define regCLKPLL               0x5000
+
+/*for 10G only*/
+#define regREVISION        0x6000
+#define regSCRATCH         0x6004
+#define regCTRLST          0x6008
+#define regMAC_ADDR_0      0x600C
+#define regMAC_ADDR_1      0x6010
+#define regFRM_LENGTH      0x6014
+#define regPAUSE_QUANT     0x6018
+#define regRX_FIFO_SECTION 0x601C
+#define regTX_FIFO_SECTION 0x6020
+#define regRX_FULLNESS     0x6024
+#define regTX_FULLNESS     0x6028
+#define regHASHTABLE       0x602C
+#define regMDIO_ST         0x6030
+#define regMDIO_CTL        0x6034
+#define regMDIO_DATA       0x6038
+#define regMDIO_ADDR       0x603C
+
+#define regRST_PORT        0x7000
+#define regDIS_PORT        0x7010
+#define regRST_QU          0x7020
+#define regDIS_QU          0x7030
+
+#define regCTRLST_TX_ENA   0x0001
+#define regCTRLST_RX_ENA   0x0002
+#define regCTRLST_PRM_ENA  0x0010
+#define regCTRLST_PAD_ENA  0x0020
+
+#define regCTRLST_BASE     (regCTRLST_PAD_ENA|regCTRLST_PRM_ENA)
+
+#define regRX_FLT   0x1400
+
+/* TXD TXF RXF RXD  CONFIG 0x0000 --- 0x007c*/
+#define  TX_RX_CFG1_BASE          0xffffffff	/*0-31 */
+#define  TX_RX_CFG0_BASE          0xfffff000	/*31:12 */
+#define  TX_RX_CFG0_RSVD          0x0ffc	/*11:2 */
+#define  TX_RX_CFG0_SIZE          0x0003	/*1:0 */
+
+/*  TXD TXF RXF RXD  WRITE 0x0080 --- 0x00BC */
+#define  TXF_WPTR_WR_PTR        0x7ff8	/*14:3 */
+
+/*  TXD TXF RXF RXD  READ  0x00CO --- 0x00FC */
+#define  TXF_RPTR_RD_PTR        0x7ff8	/*14:3 */
+
+#define TXF_WPTR_MASK 0x7ff0	/* last 4 bits are dropped
+				 * size is rounded to 16 */
+
+/*  regISR 0x0100 */
+/*  regIMR 0x0110 */
+#define  IMR_INPROG   0x80000000	/*31 */
+#define  IR_LNKCHG1   0x10000000	/*28 */
+#define  IR_LNKCHG0   0x08000000	/*27 */
+#define  IR_GPIO      0x04000000	/*26 */
+#define  IR_RFRSH     0x02000000	/*25 */
+#define  IR_RSVD      0x01000000	/*24 */
+#define  IR_SWI       0x00800000	/*23 */
+#define  IR_RX_FREE_3 0x00400000	/*22 */
+#define  IR_RX_FREE_2 0x00200000	/*21 */
+#define  IR_RX_FREE_1 0x00100000	/*20 */
+#define  IR_RX_FREE_0 0x00080000	/*19 */
+#define  IR_TX_FREE_3 0x00040000	/*18 */
+#define  IR_TX_FREE_2 0x00020000	/*17 */
+#define  IR_TX_FREE_1 0x00010000	/*16 */
+#define  IR_TX_FREE_0 0x00008000	/*15 */
+#define  IR_RX_DESC_3 0x00004000	/*14 */
+#define  IR_RX_DESC_2 0x00002000	/*13 */
+#define  IR_RX_DESC_1 0x00001000	/*12 */
+#define  IR_RX_DESC_0 0x00000800	/*11 */
+#define  IR_PSE       0x00000400	/*10 */
+#define  IR_TMR3      0x00000200	/*9 */
+#define  IR_TMR2      0x00000100	/*8 */
+#define  IR_TMR1      0x00000080	/*7 */
+#define  IR_TMR0      0x00000040	/*6 */
+#define  IR_VNT       0x00000020	/*5 */
+#define  IR_RxFL      0x00000010	/*4 */
+#define  IR_SDPERR    0x00000008	/*3 */
+#define  IR_TR        0x00000004	/*2 */
+#define  IR_PCIE_LINK 0x00000002	/*1 */
+#define  IR_PCIE_TOUT 0x00000001	/*0 */
+
+#define  IR_EXTRA (IR_RX_FREE_0 | IR_LNKCHG0 | IR_PSE | \
+    IR_TMR0 | IR_PCIE_LINK | IR_PCIE_TOUT)
+#define  IR_RUN (IR_EXTRA | IR_RX_DESC_0 | IR_TX_FREE_0)
+#define  IR_ALL 0xfdfffff7
+
+#define  IR_LNKCHG0_ofst        27
+
+#define  GMAC_RX_FILTER_OSEN  0x1000	/* shared OS enable */
+#define  GMAC_RX_FILTER_TXFC  0x0400	/* Tx flow control */
+#define  GMAC_RX_FILTER_RSV0  0x0200	/* reserved */
+#define  GMAC_RX_FILTER_FDA   0x0100	/* filter out direct address */
+#define  GMAC_RX_FILTER_AOF   0x0080	/* accept over run */
+#define  GMAC_RX_FILTER_ACF   0x0040	/* accept control frames */
+#define  GMAC_RX_FILTER_ARUNT 0x0020	/* accept under run */
+#define  GMAC_RX_FILTER_ACRC  0x0010	/* accept crc error */
+#define  GMAC_RX_FILTER_AM    0x0008	/* accept multicast */
+#define  GMAC_RX_FILTER_AB    0x0004	/* accept broadcast */
+#define  GMAC_RX_FILTER_PRM   0x0001	/* [0:1] promiscous mode */
+
+#define  MAX_FRAME_AB_VAL       0x3fff	/* 13:0 */
+
+#define  CLKPLL_PLLLKD          0x0200	/*9 */
+#define  CLKPLL_RSTEND          0x0100	/*8 */
+#define  CLKPLL_SFTRST          0x0001	/*0 */
+
+#define  CLKPLL_LKD             (CLKPLL_PLLLKD|CLKPLL_RSTEND)
+
+/*
+ * PCI-E Device Control Register (Offset 0x88)
+ * Source: Luxor Data Sheet, 7.1.3.3.3
+ */
+#define PCI_DEV_CTRL_REG 0x88
+#define GET_DEV_CTRL_MAXPL(x)           GET_BITS_SHIFT(x, 3, 5)
+#define GET_DEV_CTRL_MRRS(x)            GET_BITS_SHIFT(x, 3, 12)
+
+/*
+ * PCI-E Link Status Register (Offset 0x92)
+ * Source: Luxor Data Sheet, 7.1.3.3.7
+ */
+#define PCI_LINK_STATUS_REG 0x92
+#define GET_LINK_STATUS_LANES(x)		GET_BITS_SHIFT(x, 6, 4)
+
+/* Debugging Macros */
+
+#define ERR(fmt, args...) printk(KERN_ERR fmt, ## args)
+#define DBG2(fmt, args...)	\
+	printk(KERN_ERR  "%s:%-5d: " fmt, __FUNCTION__, __LINE__, ## args)
+
+#define BDX_ASSERT(x) BUG_ON(x)
+
+#ifdef DEBUG
+
+#define ENTER          do { \
+	printk(KERN_ERR  "%s:%-5d: ENTER\n", __FUNCTION__, __LINE__); \
+} while (0)
+
+#define RET(args...)   do { \
+	printk(KERN_ERR  "%s:%-5d: RETURN\n", __FUNCTION__, __LINE__); \
+return args; } while (0)
+
+#define DBG(fmt, args...)	\
+	printk(KERN_ERR  "%s:%-5d: " fmt, __FUNCTION__, __LINE__, ## args)
+#else
+#define ENTER         do {  } while (0)
+#define RET(args...)   return args
+#define DBG(fmt, args...)   do {  } while (0)
+#endif
+
+#endif /* _BDX__H */
diff --git a/drivers/net/tehuti/tehuti_fw.h =
b/drivers/net/tehuti/tehuti_fw.h
new file mode 100644
index 0000000..2c603a8
--- /dev/null
+++ b/drivers/net/tehuti/tehuti_fw.h
@@ -0,0 +1,10712 @@
+/*
+ * Tehuti Networks(R) Network Driver
+ * Copyright (C) 2007 Tehuti Networks Ltd. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+/* Loading Firmware */
+/* INT_MEM Ver */
+static u32 s_firmLoad[] =3D {
+	0x000f0002,
+	0x40718000,
+	0x0000002d,
+	0xc0000000,
+	0x000f0002,
+	0x00718001,
+	0x0000002d,
+	0xc0800000,
+	0x000f0002,
+	0x00718002,
+	0x0000002d,
+	0xc1000000,
+	0x000f0002,
+	0x00718003,
+	0x0000002d,
+	0xc1800000,
+	0x000f0002,
+	0x00718004,
+	0x0000002d,
+	0xc2000000,
+	0x000f0002,
+	0x00718005,
+	0x0000002d,
+	0xc2800000,
+	0x000f0002,
+	0x00718006,
+	0x0000002d,
+	0xc3000000,
+	0x000f0002,
+	0x00718007,
+	0x0000002d,
+	0xc3800000,
+	0x000f0002,
+	0x00718008,
+	0x0000002d,
+	0xc4000000,
+	0x000f0002,
+	0x00718009,
+	0x0000002d,
+	0xc4800000,
+	0x000f0002,
+	0x0071800a,
+	0x0000002d,
+	0xc5000000,
+	0x000f0002,
+	0x0071800b,
+	0x0000002d,
+	0xc5800000,
+	0x000f0002,
+	0x0071800c,
+	0x0000002d,
+	0xc6000000,
+	0x000f0002,
+	0x0071800d,
+	0x0000002d,
+	0xc6800000,
+	0x000f0002,
+	0x0071800e,
+	0x0000002d,
+	0xc7000000,
+	0x000f0002,
+	0x0071800f,
+	0x0000002d,
+	0xc7800000,
+	0x000f0002,
+	0x00718010,
+	0x0000002d,
+	0xc8000000,
+	0x000f0002,
+	0x00718011,
+	0x0000002d,
+	0xc8800000,
+	0x000f0002,
+	0x00718012,
+	0x0000002d,
+	0xc9000000,
+	0x000f0002,
+	0x00718013,
+	0x0000002d,
+	0xc9800000,
+	0x000f0002,
+	0x00718014,
+	0x0000002d,
+	0xca000000,
+	0x000f0002,
+	0x00718015,
+	0x0000002d,
+	0xca800000,
+	0x000f0002,
+	0x00718016,
+	0x0000002d,
+	0xcb000000,
+	0x000f0002,
+	0x00718017,
+	0x0000002d,
+	0xcb800000,
+	0x000f0002,
+	0x00718018,
+	0x0000002d,
+	0xcc000000,
+	0x000f0002,
+	0x00718019,
+	0x0000002d,
+	0xcc800000,
+	0x000f0002,
+	0x0071801a,
+	0x0000002d,
+	0xcd000000,
+	0x000f0002,
+	0x0071801b,
+	0x0000002d,
+	0xcd800000,
+	0x000f0002,
+	0x0071801c,
+	0x0000002d,
+	0xce000000,
+	0x000f0002,
+	0x0071801d,
+	0x0000002d,
+	0xce800000,
+	0x000f0002,
+	0x0071801e,
+	0x0000002d,
+	0xcf000000,
+	0x000f0002,
+	0x0071801f,
+	0x0000002d,
+	0xcf800000,
+	0x000f0002,
+	0x00718020,
+	0x0000002d,
+	0xd0000000,
+	0x000f0002,
+	0x00718021,
+	0x0000002d,
+	0xd0800000,
+	0x000f0002,
+	0x00718022,
+	0x0000002d,
+	0xd1000000,
+	0x000f0002,
+	0x00718023,
+	0x0000002d,
+	0xd1800000,
+	0x000f0002,
+	0x00718024,
+	0x0000002d,
+	0xd2000000,
+	0x000f0002,
+	0x00718025,
+	0x0000002d,
+	0xd2800000,
+	0x000f0002,
+	0x00718026,
+	0x0000002d,
+	0xd3000000,
+	0x000f0002,
+	0x00718027,
+	0x0000002d,
+	0xd3800000,
+	0x000f0002,
+	0x00718028,
+	0x0000002d,
+	0xd4000000,
+	0x000f0002,
+	0x00718029,
+	0x0000002d,
+	0xd4800000,
+	0x000f0002,
+	0x0071802a,
+	0x0000002d,
+	0xd5000000,
+	0x000f0002,
+	0x0071802b,
+	0x0000002d,
+	0xd5800000,
+	0x000f0002,
+	0x0071802c,
+	0x0000002d,
+	0xd6000000,
+	0x000f0002,
+	0x0071802d,
+	0x0000002d,
+	0xd6800000,
+	0x000f0002,
+	0x0071802e,
+	0x0000002d,
+	0xd7000000,
+	0x000f0002,
+	0x0071802f,
+	0x0000002d,
+	0xd7800000,
+	0x000f0002,
+	0x00718030,
+	0x0000002d,
+	0xd8000000,
+	0x000f0002,
+	0x00718031,
+	0x0000002d,
+	0xd8800000,
+	0x000f0002,
+	0x00718032,
+	0x0000002d,
+	0xd9000000,
+	0x000f0002,
+	0x00718033,
+	0x0000002d,
+	0xd9800000,
+	0x000f0002,
+	0x00718034,
+	0x0000002d,
+	0xda000000,
+	0x000f0002,
+	0x00718035,
+	0x0000002d,
+	0xda800000,
+	0x000f0002,
+	0x00718036,
+	0x0000002d,
+	0xdb000000,
+	0x000f0002,
+	0x00718037,
+	0x0000002d,
+	0xdb800000,
+	0x000f0002,
+	0x00718038,
+	0x0000007b,
+	0xdd608000,
+	0x000f0002,
+	0x00718039,
+	0x0000002d,
+	0xdd000000,
+	0x000f0002,
+	0x0071803a,
+	0x0000002d,
+	0xdb800000,
+	0x000f0002,
+	0x0071803b,
+	0x0000002d,
+	0xdd000000,
+	0x000f0002,
+	0x0071803c,
+	0x0000002d,
+	0xdd000000,
+	0x000f0002,
+	0x0071803d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718040,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718041,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718042,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718043,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718044,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718045,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718046,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718047,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718048,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718049,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718050,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718051,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718052,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718053,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718054,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718055,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718056,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718057,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718058,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718059,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718060,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718061,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718062,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718063,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718064,
+	0x0000002d,
+	0xdb000000,
+	0x000f0002,
+	0x00718065,
+	0x0000003f,
+	0xdd000104,
+	0x000f0002,
+	0x00718066,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718067,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718068,
+	0x0000003f,
+	0xdd000804,
+	0x000f0002,
+	0x00718069,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071806a,
+	0x0000003f,
+	0xdd003004,
+	0x000f0002,
+	0x0071806b,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071806c,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071806d,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x0071806e,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071806f,
+	0x0000003f,
+	0xdd003d04,
+	0x000f0002,
+	0x00718070,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718071,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718072,
+	0x0000003f,
+	0xdd000704,
+	0x000f0002,
+	0x00718073,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718074,
+	0x0000003f,
+	0xdd002884,
+	0x000f0002,
+	0x00718075,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718076,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718077,
+	0x0000003f,
+	0xdd003704,
+	0x000f0002,
+	0x00718078,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718079,
+	0x0000003f,
+	0xdd002904,
+	0x000f0002,
+	0x0071807a,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071807b,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071807c,
+	0x0000003f,
+	0xdd04aa04,
+	0x000f0002,
+	0x0071807d,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071807e,
+	0x0000003f,
+	0xdd002804,
+	0x000f0002,
+	0x0071807f,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718080,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718081,
+	0x0000003f,
+	0xdd003104,
+	0x000f0002,
+	0x00718082,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718083,
+	0x0000003f,
+	0xdd002b84,
+	0x000f0002,
+	0x00718084,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718085,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718086,
+	0x0000003f,
+	0xdd01e404,
+	0x000f0002,
+	0x00718087,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718088,
+	0x0000003f,
+	0xd7800084,
+	0x000f0002,
+	0x00718089,
+	0x0000003f,
+	0xd7980001,
+	0x000f0002,
+	0x0071808a,
+	0x00000059,
+	0xd78037ef,
+	0x000f0002,
+	0x0071808b,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x0071808c,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x0071808d,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x0071808e,
+	0x0000002d,
+	0xd7d6027f,
+	0x000f0002,
+	0x0071808f,
+	0x00000018,
+	0x17ff0081,
+	0x000f0002,
+	0x00718090,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718091,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718092,
+	0x0000002d,
+	0xd7d800b8,
+	0x000f0002,
+	0x00718093,
+	0x00000018,
+	0x17eb0081,
+	0x000f0002,
+	0x00718094,
+	0x0000003f,
+	0xdd002904,
+	0x000f0002,
+	0x00718095,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718096,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718097,
+	0x0000003f,
+	0xdd04aa84,
+	0x000f0002,
+	0x00718098,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718099,
+	0x0000003f,
+	0xdd002b04,
+	0x000f0002,
+	0x0071809a,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071809b,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071809c,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x0071809d,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071809e,
+	0x0000003f,
+	0xdd002984,
+	0x000f0002,
+	0x0071809f,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180a0,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180a1,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x007180a2,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180a3,
+	0x0000003f,
+	0xdd002a04,
+	0x000f0002,
+	0x007180a4,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180a5,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180a6,
+	0x0000003f,
+	0xdd009184,
+	0x000f0002,
+	0x007180a7,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180a8,
+	0x0000003f,
+	0xd6801984,
+	0x000f0002,
+	0x007180a9,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x007180aa,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007180ab,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x007180ac,
+	0x0000003f,
+	0xdd002b04,
+	0x000f0002,
+	0x007180ad,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180ae,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180af,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x007180b0,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180b1,
+	0x0000003f,
+	0xdd002a84,
+	0x000f0002,
+	0x007180b2,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180b3,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180b4,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x007180b5,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180b6,
+	0x0000003f,
+	0xd6800c84,
+	0x000f0002,
+	0x007180b7,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x007180b8,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007180b9,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x007180ba,
+	0x0000003f,
+	0xdd002a84,
+	0x000f0002,
+	0x007180bb,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180bc,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180bd,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x007180be,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180bf,
+	0x0000003f,
+	0xd6800f84,
+	0x000f0002,
+	0x007180c0,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x007180c1,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007180c2,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x007180c3,
+	0x0000003f,
+	0xdd002a04,
+	0x000f0002,
+	0x007180c4,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180c5,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180c6,
+	0x0000003f,
+	0xdd001184,
+	0x000f0002,
+	0x007180c7,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180c8,
+	0x0000003f,
+	0xdd002884,
+	0x000f0002,
+	0x007180c9,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180ca,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180cb,
+	0x0000003f,
+	0xdd003784,
+	0x000f0002,
+	0x007180cc,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180cd,
+	0x0000002d,
+	0xd3800000,
+	0x000f0002,
+	0x007180ce,
+	0x0000003f,
+	0xd2003780,
+	0x000f0002,
+	0x007180cf,
+	0x0000003f,
+	0xd1800404,
+	0x000f0002,
+	0x007180d0,
+	0x0000003f,
+	0xd1840001,
+	0x000f0002,
+	0x007180d1,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180d2,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180d3,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180d4,
+	0x0000003f,
+	0xd17fff84,
+	0x000f0002,
+	0x007180d5,
+	0x0000003f,
+	0xd17fff81,
+	0x000f0002,
+	0x007180d6,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180d7,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180d8,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180d9,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180da,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180db,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007180dc,
+	0x0000003f,
+	0xd6800784,
+	0x000f0002,
+	0x007180dd,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x007180de,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007180df,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x007180e0,
+	0x00000049,
+	0xdd003b63,
+	0x000f0002,
+	0x007180e1,
+	0x00000059,
+	0xdd003b76,
+	0x000f0002,
+	0x007180e2,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180e3,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180e4,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180e5,
+	0x0000002d,
+	0xdd06027f,
+	0x000f0002,
+	0x007180e6,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x007180e7,
+	0x00000045,
+	0xdd003139,
+	0x000f0002,
+	0x007180e8,
+	0x00000094,
+	0x000b313b,
+	0x000f0002,
+	0x007180e9,
+	0x00000094,
+	0x0009313d,
+	0x000f0002,
+	0x007180ea,
+	0x00000094,
+	0x0007313f,
+	0x000f0002,
+	0x007180eb,
+	0x00000094,
+	0x00053b76,
+	0x000f0002,
+	0x007180ec,
+	0x00000009,
+	0xc1ed3d7a,
+	0x000f0002,
+	0x007180ed,
+	0x0000003f,
+	0xd200b780,
+	0x000f0002,
+	0x007180ee,
+	0x0000003f,
+	0xdd002884,
+	0x000f0002,
+	0x007180ef,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007180f0,
+	0x00000069,
+	0xdd003264,
+	0x000f0002,
+	0x007180f1,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007180f2,
+	0x0000003f,
+	0xd6800784,
+	0x000f0002,
+	0x007180f3,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x007180f4,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007180f5,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x007180f6,
+	0x00000049,
+	0xdd003b63,
+	0x000f0002,
+	0x007180f7,
+	0x00000059,
+	0xdd003b76,
+	0x000f0002,
+	0x007180f8,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180f9,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180fa,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180fb,
+	0x0000002d,
+	0xdd06027f,
+	0x000f0002,
+	0x007180fc,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x007180fd,
+	0x00000045,
+	0xdd00313a,
+	0x000f0002,
+	0x007180fe,
+	0x00000018,
+	0x1d2d3b76,
+	0x000f0002,
+	0x007180ff,
+	0x00000045,
+	0xdd00313c,
+	0x000f0002,
+	0x00718100,
+	0x00000018,
+	0x1d133b76,
+	0x000f0002,
+	0x00718101,
+	0x00000045,
+	0xdd00313e,
+	0x000f0002,
+	0x00718102,
+	0x00000018,
+	0x1d1b3b76,
+	0x000f0002,
+	0x00718103,
+	0x0000003f,
+	0xdd003004,
+	0x000f0002,
+	0x00718104,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718105,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718106,
+	0x0000003f,
+	0xdd000104,
+	0x000f0002,
+	0x00718107,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718108,
+	0x00000009,
+	0xc52d3d7a,
+	0x000f0002,
+	0x00718109,
+	0x00000029,
+	0xd2010064,
+	0x000f0002,
+	0x0071810a,
+	0x0000003f,
+	0xdd002884,
+	0x000f0002,
+	0x0071810b,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071810c,
+	0x00000069,
+	0xdd003264,
+	0x000f0002,
+	0x0071810d,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071810e,
+	0x00000009,
+	0xc2293d7a,
+	0x000f0002,
+	0x0071810f,
+	0x00000029,
+	0xd2000064,
+	0x000f0002,
+	0x00718110,
+	0x0000003f,
+	0xdd002884,
+	0x000f0002,
+	0x00718111,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718112,
+	0x00000069,
+	0xdd003264,
+	0x000f0002,
+	0x00718113,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718114,
+	0x00000049,
+	0xdd003b63,
+	0x000f0002,
+	0x00718115,
+	0x00000059,
+	0xdd003b76,
+	0x000f0002,
+	0x00718116,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718117,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718118,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718119,
+	0x0000002d,
+	0xdd06027f,
+	0x000f0002,
+	0x0071811a,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x0071811b,
+	0x00000045,
+	0xdd00313a,
+	0x000f0002,
+	0x0071811c,
+	0x00000018,
+	0x1d0f3b76,
+	0x000f0002,
+	0x0071811d,
+	0x0000003f,
+	0xdd003004,
+	0x000f0002,
+	0x0071811e,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071811f,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718120,
+	0x0000003f,
+	0xdd000104,
+	0x000f0002,
+	0x00718121,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718122,
+	0x00000009,
+	0xc52d3d7a,
+	0x000f0002,
+	0x00718123,
+	0x0000002d,
+	0xd1080082,
+	0x000f0002,
+	0x00718124,
+	0x00000008,
+	0x23c33d7a,
+	0x000f0002,
+	0x00718125,
+	0x00000049,
+	0xd6003b0a,
+	0x000f0002,
+	0x00718126,
+	0x0000003f,
+	0xd3000004,
+	0x000f0002,
+	0x00718127,
+	0x0000003f,
+	0xd3040001,
+	0x000f0002,
+	0x00718128,
+	0x0000002f,
+	0xd6814085,
+	0x000f0002,
+	0x00718129,
+	0x0000003f,
+	0xd4ffff84,
+	0x000f0002,
+	0x0071812a,
+	0x0000003f,
+	0xd4800781,
+	0x000f0002,
+	0x0071812b,
+	0x0000003f,
+	0xd1ffff84,
+	0x000f0002,
+	0x0071812c,
+	0x0000003f,
+	0xd1800001,
+	0x000f0002,
+	0x0071812d,
+	0x00000049,
+	0xdd003666,
+	0x000f0002,
+	0x0071812e,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x0071812f,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x00718130,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x00718131,
+	0x00000069,
+	0xdd003b69,
+	0x000f0002,
+	0x00718132,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x00718133,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x00718134,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x00718135,
+	0x00000069,
+	0xdd003b69,
+	0x000f0002,
+	0x00718136,
+	0x00000061,
+	0xf600046c,
+	0x000f0002,
+	0x00718137,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x00718138,
+	0x00000018,
+	0x3d6b0081,
+	0x000f0002,
+	0x00718139,
+	0x00000049,
+	0xd600058b,
+	0x000f0002,
+	0x0071813a,
+	0x0000002f,
+	0xd6810106,
+	0x000f0002,
+	0x0071813b,
+	0x0000002d,
+	0xd2000000,
+	0x000f0002,
+	0x0071813c,
+	0x00000021,
+	0xd20000e4,
+	0x000f0002,
+	0x0071813d,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x0071813e,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x0071813f,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x00718140,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x00718141,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x00718142,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x00718143,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x00718144,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x00718145,
+	0x0000002d,
+	0xd1000000,
+	0x000f0002,
+	0x00718146,
+	0x00000049,
+	0xd17a33e4,
+	0x000f0002,
+	0x00718147,
+	0x0000002f,
+	0xd1710162,
+	0x000f0002,
+	0x00718148,
+	0x0000002f,
+	0xd1610162,
+	0x000f0002,
+	0x00718149,
+	0x00000049,
+	0xd14033e3,
+	0x000f0002,
+	0x0071814a,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x0071814b,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x0071814c,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x0071814d,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x0071814e,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x0071814f,
+	0x00000069,
+	0xd8003162,
+	0x000f0002,
+	0x00718150,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x00718151,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x00718152,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718153,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x00718154,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x00718155,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x00718156,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x00718157,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x00718158,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x00718159,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x0071815a,
+	0x0000002d,
+	0xd1000000,
+	0x000f0002,
+	0x0071815b,
+	0x0000002d,
+	0xd16c07e4,
+	0x000f0002,
+	0x0071815c,
+	0x00000049,
+	0xd14033e3,
+	0x000f0002,
+	0x0071815d,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x0071815e,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x0071815f,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x00718160,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x00718161,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x00718162,
+	0x00000069,
+	0xd8003162,
+	0x000f0002,
+	0x00718163,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x00718164,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x00718165,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718166,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x00718167,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x00718168,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x00718169,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x0071816a,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x0071816b,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x0071816c,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x0071816d,
+	0x0000002d,
+	0xd1000000,
+	0x000f0002,
+	0x0071816e,
+	0x00000049,
+	0xd17833e4,
+	0x000f0002,
+	0x0071816f,
+	0x0000002f,
+	0xd1710162,
+	0x000f0002,
+	0x00718170,
+	0x0000002f,
+	0xd1610162,
+	0x000f0002,
+	0x00718171,
+	0x00000049,
+	0xd14033e3,
+	0x000f0002,
+	0x00718172,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718173,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x00718174,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x00718175,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x00718176,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x00718177,
+	0x00000069,
+	0xd8003162,
+	0x000f0002,
+	0x00718178,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x00718179,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x0071817a,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x0071817b,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x0071817c,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x0071817d,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x0071817e,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x0071817f,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x00718180,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x00718181,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x00718182,
+	0x0000002d,
+	0xd1000000,
+	0x000f0002,
+	0x00718183,
+	0x0000002d,
+	0xd16807e4,
+	0x000f0002,
+	0x00718184,
+	0x00000049,
+	0xd14033e3,
+	0x000f0002,
+	0x00718185,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718186,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x00718187,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x00718188,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x00718189,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x0071818a,
+	0x00000069,
+	0xd8003162,
+	0x000f0002,
+	0x0071818b,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x0071818c,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x0071818d,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x0071818e,
+	0x00000008,
+	0x22790081,
+	0x000f0002,
+	0x0071818f,
+	0x00000049,
+	0xd600060c,
+	0x000f0002,
+	0x00718190,
+	0x0000002f,
+	0xd6810106,
+	0x000f0002,
+	0x00718191,
+	0x0000003f,
+	0xd4800002,
+	0x000f0002,
+	0x00718192,
+	0x0000003f,
+	0xd4800084,
+	0x000f0002,
+	0x00718193,
+	0x0000003f,
+	0xd5000102,
+	0x000f0002,
+	0x00718194,
+	0x0000003f,
+	0xd5000184,
+	0x000f0002,
+	0x00718195,
+	0x0000003f,
+	0xd5800202,
+	0x000f0002,
+	0x00718196,
+	0x0000003f,
+	0xd5800204,
+	0x000f0002,
+	0x00718197,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718198,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x00718199,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x0071819a,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x0071819b,
+	0x00000069,
+	0xd80034e9,
+	0x000f0002,
+	0x0071819c,
+	0x00000069,
+	0xd800356a,
+	0x000f0002,
+	0x0071819d,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x0071819e,
+	0x00000031,
+	0xd600016c,
+	0x000f0002,
+	0x0071819f,
+	0x00000041,
+	0xd48034eb,
+	0x000f0002,
+	0x007181a0,
+	0x00000041,
+	0xd500356b,
+	0x000f0002,
+	0x007181a1,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007181a2,
+	0x00000018,
+	0x37eb0081,
+	0x000f0002,
+	0x007181a3,
+	0x00000049,
+	0xd6003b0d,
+	0x000f0002,
+	0x007181a4,
+	0x00000049,
+	0xd6803b07,
+	0x000f0002,
+	0x007181a5,
+	0x0000002d,
+	0xd1000000,
+	0x000f0002,
+	0x007181a6,
+	0x00000049,
+	0xdd003666,
+	0x000f0002,
+	0x007181a7,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181a8,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181a9,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181aa,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181ab,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181ac,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181ad,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181ae,
+	0x00000069,
+	0xdd003b76,
+	0x000f0002,
+	0x007181af,
+	0x00000061,
+	0xf600046c,
+	0x000f0002,
+	0x007181b0,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007181b1,
+	0x00000018,
+	0x37eb0081,
+	0x000f0002,
+	0x007181b2,
+	0x00000049,
+	0xd6003b0e,
+	0x000f0002,
+	0x007181b3,
+	0x00000049,
+	0xd6803b08,
+	0x000f0002,
+	0x007181b4,
+	0x00000049,
+	0xd5803b09,
+	0x000f0002,
+	0x007181b5,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181b6,
+	0x0000002d,
+	0xdd06017f,
+	0x000f0002,
+	0x007181b7,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x007181b8,
+	0x00000049,
+	0xd800366c,
+	0x000f0002,
+	0x007181b9,
+	0x00000069,
+	0xd80035eb,
+	0x000f0002,
+	0x007181ba,
+	0x00000069,
+	0xd80033e7,
+	0x000f0002,
+	0x007181bb,
+	0x00000069,
+	0xd80037ef,
+	0x000f0002,
+	0x007181bc,
+	0x00000041,
+	0xd60007ec,
+	0x000f0002,
+	0x007181bd,
+	0x00000041,
+	0xd580086b,
+	0x000f0002,
+	0x007181be,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007181bf,
+	0x00000018,
+	0x37ed0081,
+	0x000f0002,
+	0x007181c0,
+	0x0000003f,
+	0xd4ffff80,
+	0x000f0002,
+	0x007181c1,
+	0x0000003f,
+	0xd5020004,
+	0x000f0002,
+	0x007181c2,
+	0x0000003f,
+	0xd5180001,
+	0x000f0002,
+	0x007181c3,
+	0x00000049,
+	0xdd003b6a,
+	0x000f0002,
+	0x007181c4,
+	0x00000069,
+	0xdd003b69,
+	0x000f0002,
+	0x007181c5,
+	0x00000069,
+	0xdd003b69,
+	0x000f0002,
+	0x007181c6,
+	0x00000021,
+	0xd50000ea,
+	0x000f0002,
+	0x007181c7,
+	0x00000049,
+	0xdd0e3b6a,
+	0x000f0002,
+	0x007181c8,
+	0x00000035,
+	0xd104007a,
+	0x000f0002,
+	0x007181c9,
+	0x00000018,
+	0x37f50081,
+	0x000f0002,
+	0x007181ca,
+	0x0000003f,
+	0xd4ffff80,
+	0x000f0002,
+	0x007181cb,
+	0x0000003f,
+	0xd5040004,
+	0x000f0002,
+	0x007181cc,
+	0x0000003f,
+	0xd5180001,
+	0x000f0002,
+	0x007181cd,
+	0x00000069,
+	0xdd003b69,
+	0x000f0002,
+	0x007181ce,
+	0x00000069,
+	0xdd003b69,
+	0x000f0002,
+	0x007181cf,
+	0x00000049,
+	0xdd003b6a,
+	0x000f0002,
+	0x007181d0,
+	0x00000051,
+	0xf50000ea,
+	0x000f0002,
+	0x007181d1,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181d2,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181d3,
+	0x00000049,
+	0xdd0e3b6a,
+	0x000f0002,
+	0x007181d4,
+	0x00000035,
+	0xd104807a,
+	0x000f0002,
+	0x007181d5,
+	0x00000018,
+	0x37f50081,
+	0x000f0002,
+	0x007181d6,
+	0x0000003f,
+	0xc77f7f04,
+	0x000f0002,
+	0x007181d7,
+	0x0000003f,
+	0xc77f7f01,
+	0x000f0002,
+	0x007181d8,
+	0x0000003f,
+	0xd6804000,
+	0x000f0002,
+	0x007181d9,
+	0x0000003f,
+	0xd103c000,
+	0x000f0002,
+	0x007181da,
+	0x00000025,
+	0xde2000e2,
+	0x000f0002,
+	0x007181db,
+	0x00000049,
+	0xde80274e,
+	0x000f0002,
+	0x007181dc,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181dd,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181de,
+	0x00000035,
+	0xd10000e2,
+	0x000f0002,
+	0x007181df,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007181e0,
+	0x00000018,
+	0x37f50081,
+	0x000f0002,
+	0x007181e1,
+	0x0000003f,
+	0xdd003004,
+	0x000f0002,
+	0x007181e2,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007181e3,
+	0x00000069,
+	0xdd001d3a,
+	0x000f0002,
+	0x007181e4,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007181e5,
+	0x0000007d,
+	0xc760a713,
+	0x000f0002,
+	0x007181e6,
+	0x00000031,
+	0xc0800041,
+	0x000f0002,
+	0x007181e7,
+	0x00000031,
+	0xc4000048,
+	0x000f0002,
+	0x007181e8,
+	0x00000031,
+	0xc2800045,
+	0x000f0002,
+	0x007181e9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ea,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181eb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ec,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ed,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ee,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ef,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f4,
+	0x0000002d,
+	0xdb000000,
+	0x000f0002,
+	0x007181f5,
+	0x0000003f,
+	0xdd003004,
+	0x000f0002,
+	0x007181f6,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007181f7,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007181f8,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x007181f9,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007181fa,
+	0x0000002d,
+	0xd3800000,
+	0x000f0002,
+	0x007181fb,
+	0x0000003f,
+	0xdd000404,
+	0x000f0002,
+	0x007181fc,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007181fd,
+	0x00000069,
+	0xdd000a14,
+	0x000f0002,
+	0x007181fe,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x007181ff,
+	0x00000049,
+	0xd1043394,
+	0x000f0002,
+	0x00718200,
+	0x0000003f,
+	0xdd000484,
+	0x000f0002,
+	0x00718201,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718202,
+	0x00000069,
+	0xdd003162,
+	0x000f0002,
+	0x00718203,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718204,
+	0x0000003f,
+	0xdd000504,
+	0x000f0002,
+	0x00718205,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718206,
+	0x00000069,
+	0xdd000a95,
+	0x000f0002,
+	0x00718207,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718208,
+	0x00000049,
+	0xd1043395,
+	0x000f0002,
+	0x00718209,
+	0x0000003f,
+	0xdd000584,
+	0x000f0002,
+	0x0071820a,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071820b,
+	0x00000069,
+	0xdd003162,
+	0x000f0002,
+	0x0071820c,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071820d,
+	0x0000003f,
+	0xdd000604,
+	0x000f0002,
+	0x0071820e,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071820f,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718210,
+	0x0000003f,
+	0xdd000084,
+	0x000f0002,
+	0x00718211,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718212,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718213,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718214,
+	0x00000069,
+	0xdd000b16,
+	0x000f0002,
+	0x00718215,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718216,
+	0x0000003f,
+	0xdd001004,
+	0x000f0002,
+	0x00718217,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718218,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718219,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x0071821a,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071821b,
+	0x0000003f,
+	0xdd001084,
+	0x000f0002,
+	0x0071821c,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071821d,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071821e,
+	0x0000003f,
+	0xdd018004,
+	0x000f0002,
+	0x0071821f,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718220,
+	0x0000003f,
+	0xdd001104,
+	0x000f0002,
+	0x00718221,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718222,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718223,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718224,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718225,
+	0x0000003f,
+	0xdd001184,
+	0x000f0002,
+	0x00718226,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718227,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718228,
+	0x0000003f,
+	0xdd160004,
+	0x000f0002,
+	0x00718229,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071822a,
+	0x0000003f,
+	0xdd001204,
+	0x000f0002,
+	0x0071822b,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071822c,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071822d,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x0071822e,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071822f,
+	0x0000003f,
+	0xdd001284,
+	0x000f0002,
+	0x00718230,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718231,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718232,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718233,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718234,
+	0x0000003f,
+	0xdd001304,
+	0x000f0002,
+	0x00718235,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718236,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718237,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718238,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718239,
+	0x0000003f,
+	0xdd001384,
+	0x000f0002,
+	0x0071823a,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071823b,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071823c,
+	0x0000003f,
+	0xdd050004,
+	0x000f0002,
+	0x0071823d,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071823e,
+	0x0000003f,
+	0xdd002004,
+	0x000f0002,
+	0x0071823f,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718240,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718241,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718242,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718243,
+	0x0000003f,
+	0xdd002084,
+	0x000f0002,
+	0x00718244,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718245,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718246,
+	0x0000003f,
+	0xdd019004,
+	0x000f0002,
+	0x00718247,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718248,
+	0x0000003f,
+	0xdd002104,
+	0x000f0002,
+	0x00718249,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071824a,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071824b,
+	0x0000003f,
+	0xdd000084,
+	0x000f0002,
+	0x0071824c,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071824d,
+	0x0000003f,
+	0xdd002184,
+	0x000f0002,
+	0x0071824e,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071824f,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718250,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718251,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718252,
+	0x0000003f,
+	0xdd002204,
+	0x000f0002,
+	0x00718253,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718254,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718255,
+	0x0000003f,
+	0xdd000284,
+	0x000f0002,
+	0x00718256,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718257,
+	0x0000003f,
+	0xdd002284,
+	0x000f0002,
+	0x00718258,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718259,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071825a,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x0071825b,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071825c,
+	0x0000003f,
+	0xdd002304,
+	0x000f0002,
+	0x0071825d,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071825e,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071825f,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718260,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718261,
+	0x0000003f,
+	0xdd001804,
+	0x000f0002,
+	0x00718262,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718263,
+	0x00000069,
+	0xdd000b97,
+	0x000f0002,
+	0x00718264,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718265,
+	0x00000049,
+	0xd1043397,
+	0x000f0002,
+	0x00718266,
+	0x0000003f,
+	0xdd001884,
+	0x000f0002,
+	0x00718267,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718268,
+	0x00000069,
+	0xdd003162,
+	0x000f0002,
+	0x00718269,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071826a,
+	0x0000003f,
+	0xdd001904,
+	0x000f0002,
+	0x0071826b,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071826c,
+	0x00000069,
+	0xdd000c18,
+	0x000f0002,
+	0x0071826d,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071826e,
+	0x00000049,
+	0xd1043398,
+	0x000f0002,
+	0x0071826f,
+	0x0000003f,
+	0xdd001984,
+	0x000f0002,
+	0x00718270,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718271,
+	0x00000069,
+	0xdd003162,
+	0x000f0002,
+	0x00718272,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718273,
+	0x0000003f,
+	0xdd001a04,
+	0x000f0002,
+	0x00718274,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718275,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718276,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x00718277,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718278,
+	0x0000003f,
+	0xdd001a84,
+	0x000f0002,
+	0x00718279,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071827a,
+	0x00000069,
+	0xdd000b16,
+	0x000f0002,
+	0x0071827b,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071827c,
+	0x0000003f,
+	0xdd001c04,
+	0x000f0002,
+	0x0071827d,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071827e,
+	0x00000069,
+	0xdd000c99,
+	0x000f0002,
+	0x0071827f,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718280,
+	0x0000003f,
+	0xdd001c84,
+	0x000f0002,
+	0x00718281,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718282,
+	0x00000069,
+	0xdd000d1a,
+	0x000f0002,
+	0x00718283,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718284,
+	0x0000003f,
+	0xdd001d04,
+	0x000f0002,
+	0x00718285,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718286,
+	0x00000069,
+	0xdd000d9b,
+	0x000f0002,
+	0x00718287,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718288,
+	0x00000049,
+	0xd104339b,
+	0x000f0002,
+	0x00718289,
+	0x0000003f,
+	0xdd001d84,
+	0x000f0002,
+	0x0071828a,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071828b,
+	0x00000069,
+	0xdd003162,
+	0x000f0002,
+	0x0071828c,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x0071828d,
+	0x0000003f,
+	0xdd001e04,
+	0x000f0002,
+	0x0071828e,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071828f,
+	0x00000069,
+	0xdd000e1c,
+	0x000f0002,
+	0x00718290,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718291,
+	0x0000003f,
+	0xdd000104,
+	0x000f0002,
+	0x00718292,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x00718293,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718294,
+	0x0000003f,
+	0xdd000f04,
+	0x000f0002,
+	0x00718295,
+	0x00000069,
+	0xdd003d7a,
+	0x000f0002,
+	0x00718296,
+	0x0000007d,
+	0xc760a713,
+	0x000f0002,
+	0x00718297,
+	0x00000031,
+	0xc0800041,
+	0x000f0002,
+	0x00718298,
+	0x00000031,
+	0xc4000048,
+	0x000f0002,
+	0x00718299,
+	0x00000031,
+	0xc2800045,
+	0x000f0002,
+	0x0071829a,
+	0x00000031,
+	0xd680006d,
+/* BRDX_INIT_SDRAM */
+	0x000f000f,
+	0x00700064,
+	0x00000000,
+	0x00000000,
+	0x00000000,
+	0x00000040,
+	0x00000100,
+	0x00000400,
+	0x00000064,
+	0x00000054,
+	0x00000000,
+	0x00002400,
+	0x00002800,
+	0x00000400,
+	0x00002880,
+	0x00000180,
+	0x00000003,
+	0x00000000,
+	0x00000000,
+	0x00000000,
+	0x00000051,
+	0x0000017d,
+	0x00000008,
+	0x00000051,
+	0x0000005d,
+	0x00000000,
+	0x00000009,
+	0x00005000,
+	0x00000000,
+	0x00000000,
+/* BRDX_INIT */
+	0x000f000f,
+	0x007001f4,
+	0x00000000,
+	0x00000000,
+	0x00000000,
+	0x00000040,
+	0x00000100,
+	0x00000400,
+	0x00000064,
+	0x00000054,
+	0x00000000,
+	0x00002400,
+	0x00002800,
+	0x00000400,
+	0x00002880,
+	0x00000180,
+	0x00000003,
+	0x00000000,
+	0x00000000,
+	0x00000000,
+	0x00000051,
+	0x0000017d,
+	0x00000008,
+	0x00000051,
+	0x0000005d,
+	0x00000000,
+	0x00000009,
+	0x00005000,
+	0x00000000,
+	0x00000000,
+/* ZERO_INIT */
+	0x000f0002,
+	0x00700000,
+	0x00000001,
+	0x00000000,
+/* ZERO_INIT */
+	0x000f0002,
+	0x00700000,
+	0x00000001,
+	0x00000000,
+/* Loading operational Firmware */
+	0x000f0002,
+	0x00718000,
+	0x00000025,
+	0xdd0e0002,
+	0x000f0002,
+	0x00718001,
+	0x00000004,
+	0x01d13b76,
+	0x000f0002,
+	0x00718002,
+	0x00000025,
+	0xdd0e0082,
+	0x000f0002,
+	0x00718003,
+	0x00000004,
+	0x02893b76,
+	0x000f0002,
+	0x00718004,
+	0x00000025,
+	0xdd0e0102,
+	0x000f0002,
+	0x00718005,
+	0x00000004,
+	0x02853b76,
+	0x000f0002,
+	0x00718006,
+	0x00000025,
+	0xdd0e0182,
+	0x000f0002,
+	0x00718007,
+	0x00000004,
+	0x03fd3b76,
+	0x000f0002,
+	0x00718008,
+	0x00000009,
+	0xcf813b76,
+	0x000f0002,
+	0x00718009,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071800a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071800b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071800c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071800d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071800e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071800f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718010,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718011,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718012,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718013,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718014,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718015,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718016,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718017,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718018,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718019,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071801a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071801b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071801c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071801d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071801e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071801f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718020,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718021,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718022,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718023,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718024,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718025,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718026,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718027,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718028,
+	0x00000049,
+	0xc0003b00,
+	0x000f0002,
+	0x00718029,
+	0x00000049,
+	0xc0803b02,
+	0x000f0002,
+	0x0071802a,
+	0x00000049,
+	0xc1003b03,
+	0x000f0002,
+	0x0071802b,
+	0x00000049,
+	0xc1803b04,
+	0x000f0002,
+	0x0071802c,
+	0x00000029,
+	0xdf600076,
+	0x000f0002,
+	0x0071802d,
+	0x00000049,
+	0xdf443b7d,
+	0x000f0002,
+	0x0071802e,
+	0x00000079,
+	0xfd609076,
+	0x000f0002,
+	0x0071802f,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718030,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718031,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718032,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718033,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718034,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718035,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718036,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718037,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718038,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718039,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071803f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718040,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718041,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718042,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718043,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718044,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718045,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718046,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718047,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718048,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718049,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071804f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718050,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718051,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718052,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718053,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718054,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718055,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718056,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718057,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718058,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718059,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071805f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718060,
+	0x0000003f,
+	0xdf000003,
+	0x000f0002,
+	0x00718061,
+	0x0000002d,
+	0xdde00f81,
+	0x000f0002,
+	0x00718062,
+	0x0000003f,
+	0xdd800283,
+	0x000f0002,
+	0x00718063,
+	0x0000002d,
+	0xdd040180,
+	0x000f0002,
+	0x00718064,
+	0x0000007d,
+	0xfd150080,
+	0x000f0002,
+	0x00718065,
+	0x0000007a,
+	0x10203b76,
+	0x000f0002,
+	0x00718066,
+	0x0000007a,
+	0x30207b76,
+	0x000f0002,
+	0x00718067,
+	0x00000021,
+	0xd0240060,
+	0x000f0002,
+	0x00718068,
+	0x0000003f,
+	0xdd000104,
+	0x000f0002,
+	0x00718069,
+	0x0000003f,
+	0xdd400281,
+	0x000f0002,
+	0x0071806a,
+	0x00000079,
+	0xdd31bb03,
+	0x000f0002,
+	0x0071806b,
+	0x00000079,
+	0xdd31fb04,
+	0x000f0002,
+	0x0071806c,
+	0x00000079,
+	0xdd31bb76,
+	0x000f0002,
+	0x0071806d,
+	0x00000079,
+	0xdd31fb76,
+	0x000f0002,
+	0x0071806e,
+	0x00000079,
+	0xfd210101,
+	0x000f0002,
+	0x0071806f,
+	0x0000007d,
+	0xfd2b4081,
+	0x000f0002,
+	0x00718070,
+	0x00000040,
+	0x3d003002,
+	0x000f0002,
+	0x00718071,
+	0x00000048,
+	0x1d003b02,
+	0x000f0002,
+	0x00718072,
+	0x00000079,
+	0xdd217b76,
+	0x000f0002,
+	0x00718073,
+	0x0000002d,
+	0xdd04057f,
+	0x000f0002,
+	0x00718074,
+	0x00000018,
+	0x3d7f3b76,
+	0x000f0002,
+	0x00718075,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718076,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718077,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718078,
+	0x00000021,
+	0xe3371f76,
+	0x000f0002,
+	0x00718079,
+	0x00000049,
+	0xdd003b79,
+	0x000f0002,
+	0x0071807a,
+	0x00000079,
+	0xdd21bb76,
+	0x000f0002,
+	0x0071807b,
+	0x00000049,
+	0xdd003b79,
+	0x000f0002,
+	0x0071807c,
+	0x00000079,
+	0xdd21bb76,
+	0x000f0002,
+	0x0071807d,
+	0x00000049,
+	0xdd003b79,
+	0x000f0002,
+	0x0071807e,
+	0x00000079,
+	0xdd21bb76,
+	0x000f0002,
+	0x0071807f,
+	0x00000079,
+	0xfd609076,
+	0x000f0002,
+	0x00718080,
+	0x00000079,
+	0xdd21fb76,
+	0x000f0002,
+	0x00718081,
+	0x0000003f,
+	0xdf000083,
+	0x000f0002,
+	0x00718082,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718083,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718084,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718085,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718086,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718087,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718088,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718089,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071808a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071808b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071808c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071808d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071808e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071808f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718090,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718091,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718092,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718093,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718094,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718095,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718096,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718097,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718098,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718099,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071809a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071809b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071809c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071809d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071809e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071809f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180a0,
+	0x0000002d,
+	0xd0080803,
+	0x000f0002,
+	0x007180a1,
+	0x00000008,
+	0x21b5fb76,
+	0x000f0002,
+	0x007180a2,
+	0x00000079,
+	0xdd010081,
+	0x000f0002,
+	0x007180a3,
+	0x00000079,
+	0xdd018102,
+	0x000f0002,
+	0x007180a4,
+	0x0000007d,
+	0xfd018083,
+	0x000f0002,
+	0x007180a5,
+	0x00000079,
+	0xd0903b76,
+	0x000f0002,
+	0x007180a6,
+	0x00000049,
+	0xd0583b7a,
+	0x000f0002,
+	0x007180a7,
+	0x00000049,
+	0xd2043b00,
+	0x000f0002,
+	0x007180a8,
+	0x0000003d,
+	0xdd400003,
+	0x000f0002,
+	0x007180a9,
+	0x00000024,
+	0x32000264,
+	0x000f0002,
+	0x007180aa,
+	0x0000003d,
+	0xdd7ff803,
+	0x000f0002,
+	0x007180ab,
+	0x00000029,
+	0xd020017a,
+	0x000f0002,
+	0x007180ac,
+	0x00000049,
+	0xd0a43b0e,
+	0x000f0002,
+	0x007180ad,
+	0x0000002d,
+	0xdd0442ff,
+	0x000f0002,
+	0x007180ae,
+	0x00000018,
+	0x3d7f3b76,
+	0x000f0002,
+	0x007180af,
+	0x0000002d,
+	0xdd060082,
+	0x000f0002,
+	0x007180b0,
+	0x00000038,
+	0x300001e0,
+	0x000f0002,
+	0x007180b1,
+	0x00000039,
+	0xd0000160,
+	0x000f0002,
+	0x007180b2,
+	0x00000079,
+	0xd1b13b7c,
+	0x000f0002,
+	0x007180b3,
+	0x0000002d,
+	0xdde00fe3,
+	0x000f0002,
+	0x007180b4,
+	0x00000049,
+	0xd08030e4,
+	0x000f0002,
+	0x007180b5,
+	0x00000079,
+	0xdd317b7c,
+	0x000f0002,
+	0x007180b6,
+	0x00000079,
+	0xdd313b7c,
+	0x000f0002,
+	0x007180b7,
+	0x0000007d,
+	0xfd374082,
+	0x000f0002,
+	0x007180b8,
+	0x00000008,
+	0x017d3b76,
+	0x000f0002,
+	0x007180b9,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180ba,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180bb,
+	0x00000049,
+	0xdd000387,
+	0x000f0002,
+	0x007180bc,
+	0x00000079,
+	0xdd310408,
+	0x000f0002,
+	0x007180bd,
+	0x00000079,
+	0xdd317d7a,
+	0x000f0002,
+	0x007180be,
+	0x00000049,
+	0xd3003b7c,
+	0x000f0002,
+	0x007180bf,
+	0x00000079,
+	0xd381bb7c,
+	0x000f0002,
+	0x007180c0,
+	0x0000007f,
+	0xd101b27c,
+	0x000f0002,
+	0x007180c1,
+	0x00000048,
+	0x51003264,
+	0x000f0002,
+	0x007180c2,
+	0x0000003d,
+	0xdd400003,
+	0x000f0002,
+	0x007180c3,
+	0x00000008,
+	0x01953162,
+	0x000f0002,
+	0x007180c4,
+	0x00000021,
+	0xd3000666,
+	0x000f0002,
+	0x007180c5,
+	0x00000020,
+	0x538000e7,
+	0x000f0002,
+	0x007180c6,
+	0x0000003f,
+	0xdd000800,
+	0x000f0002,
+	0x007180c7,
+	0x00000079,
+	0xdd01b366,
+	0x000f0002,
+	0x007180c8,
+	0x00000079,
+	0xdd01b3e7,
+	0x000f0002,
+	0x007180c9,
+	0x00000075,
+	0xf1018662,
+	0x000f0002,
+	0x007180ca,
+	0x00000075,
+	0xd201b164,
+	0x000f0002,
+	0x007180cb,
+	0x00000078,
+	0x1d007b76,
+	0x000f0002,
+	0x007180cc,
+	0x00000025,
+	0xdd0001e3,
+	0x000f0002,
+	0x007180cd,
+	0x00000008,
+	0x01b13162,
+	0x000f0002,
+	0x007180ce,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180cf,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180d0,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180d1,
+	0x00000021,
+	0xe3379f63,
+	0x000f0002,
+	0x007180d2,
+	0x00000049,
+	0xd3003b7c,
+	0x000f0002,
+	0x007180d3,
+	0x00000079,
+	0xd381bb7c,
+	0x000f0002,
+	0x007180d4,
+	0x0000007f,
+	0xd101b27c,
+	0x000f0002,
+	0x007180d5,
+	0x00000048,
+	0x51003264,
+	0x000f0002,
+	0x007180d6,
+	0x00000075,
+	0xd201b164,
+	0x000f0002,
+	0x007180d7,
+	0x00000078,
+	0x1d007b76,
+	0x000f0002,
+	0x007180d8,
+	0x0000003f,
+	0xdd000004,
+	0x000f0002,
+	0x007180d9,
+	0x00000079,
+	0xdd01c081,
+	0x000f0002,
+	0x007180da,
+	0x00000079,
+	0xfd609076,
+	0x000f0002,
+	0x007180db,
+	0x0000002d,
+	0xdd080803,
+	0x000f0002,
+	0x007180dc,
+	0x00000078,
+	0x3d01c081,
+	0x000f0002,
+	0x007180dd,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007180de,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180df,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007180e8,
+	0x00000049,
+	0xd18e3b03,
+	0x000f0002,
+	0x007180e9,
+	0x0000002f,
+	0xd18100e3,
+	0x000f0002,
+	0x007180ea,
+	0x0000003f,
+	0xd1801803,
+	0x000f0002,
+	0x007180eb,
+	0x00000049,
+	0xd1043b03,
+	0x000f0002,
+	0x007180ec,
+	0x0000003f,
+	0xdd800203,
+	0x000f0002,
+	0x007180ed,
+	0x00000049,
+	0xd2043b02,
+	0x000f0002,
+	0x007180ee,
+	0x00000049,
+	0xd2843b00,
+	0x000f0002,
+	0x007180ef,
+	0x00000025,
+	0xdd0000e2,
+	0x000f0002,
+	0x007180f0,
+	0x00000094,
+	0x00134162,
+	0x000f0002,
+	0x007180f1,
+	0x00000094,
+	0x000b4362,
+	0x000f0002,
+	0x007180f2,
+	0x00000094,
+	0x001548e2,
+	0x000f0002,
+	0x007180f3,
+	0x00000094,
+	0x001b4962,
+	0x000f0002,
+	0x007180f4,
+	0x00000094,
+	0x002f4076,
+	0x000f0002,
+	0x007180f5,
+	0x00000009,
+	0xcf813d7a,
+	0x000f0002,
+	0x007180f6,
+	0x0000001d,
+	0xfd2b80e5,
+	0x000f0002,
+	0x007180f7,
+	0x00000030,
+	0x31838063,
+	0x000f0002,
+	0x007180f8,
+	0x00000030,
+	0x11828063,
+	0x000f0002,
+	0x007180f9,
+	0x0000001d,
+	0xfd2580e5,
+	0x000f0002,
+	0x007180fa,
+	0x00000030,
+	0x31830063,
+	0x000f0002,
+	0x007180fb,
+	0x00000030,
+	0x11820063,
+	0x000f0002,
+	0x007180fc,
+	0x0000002f,
+	0xd18100e3,
+	0x000f0002,
+	0x007180fd,
+	0x0000001d,
+	0xfd0980e5,
+	0x000f0002,
+	0x007180fe,
+	0x00000030,
+	0x3183d363,
+	0x000f0002,
+	0x007180ff,
+	0x00000030,
+	0x1183d263,
+	0x000f0002,
+	0x00718100,
+	0x0000002f,
+	0xd18100e3,
+	0x000f0002,
+	0x00718101,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x00718102,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x00718103,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x00718104,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x00718105,
+	0x00000025,
+	0xd2000264,
+	0x000f0002,
+	0x00718106,
+	0x00000018,
+	0x7d77fd7a,
+	0x000f0002,
+	0x00718107,
+	0x00000049,
+	0xde203b63,
+	0x000f0002,
+	0x00718108,
+	0x00000049,
+	0xde803b79,
+	0x000f0002,
+	0x00718109,
+	0x00000021,
+	0xd18000e3,
+	0x000f0002,
+	0x0071810a,
+	0x00000009,
+	0xcf813d7a,
+	0x000f0002,
+	0x0071810b,
+	0x00000049,
+	0xdd0031e3,
+	0x000f0002,
+	0x0071810c,
+	0x00000069,
+	0xdd0e3b78,
+	0x000f0002,
+	0x0071810d,
+	0x00000061,
+	0xdd003b76,
+	0x000f0002,
+	0x0071810e,
+	0x0000003f,
+	0xdd000184,
+	0x000f0002,
+	0x0071810f,
+	0x0000003f,
+	0xdd000001,
+	0x000f0002,
+	0x00718110,
+	0x00000035,
+	0xdd0000fa,
+	0x000f0002,
+	0x00718111,
+	0x00000018,
+	0x3b7f3b76,
+	0x000f0002,
+	0x00718112,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718113,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718114,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x00718115,
+	0x00000021,
+	0xd18000e3,
+	0x000f0002,
+	0x00718116,
+	0x00000069,
+	0xdd043b79,
+	0x000f0002,
+	0x00718117,
+	0x00000061,
+	0xf18000e3,
+	0x000f0002,
+	0x00718118,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x00718119,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x0071811a,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x0071811b,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x0071811c,
+	0x00000025,
+	0xd2000264,
+	0x000f0002,
+	0x0071811d,
+	0x00000098,
+	0x605dbb76,
+	0x000f0002,
+	0x0071811e,
+	0x00000009,
+	0xcf813d7a,
+	0x000f0002,
+	0x0071811f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718120,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718121,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718122,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718123,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718124,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718125,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718126,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718127,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718128,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718129,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071812a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071812b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071812c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071812d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071812e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071812f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718130,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718131,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718132,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718133,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718134,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718135,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718136,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718137,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718138,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718139,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071813a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071813b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071813c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071813d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071813e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071813f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718140,
+	0x00000049,
+	0xd4083b01,
+	0x000f0002,
+	0x00718141,
+	0x00000009,
+	0xc28b3d7a,
+	0x000f0002,
+	0x00718142,
+	0x0000003f,
+	0xd4000380,
+	0x000f0002,
+	0x00718143,
+	0x00000009,
+	0xc28b3d7a,
+	0x000f0002,
+	0x00718144,
+	0x00000049,
+	0xd40e3b03,
+	0x000f0002,
+	0x00718145,
+	0x0000003f,
+	0xd6420000,
+	0x000f0002,
+	0x00718146,
+	0x0000002f,
+	0xd2814080,
+	0x000f0002,
+	0x00718147,
+	0x0000002d,
+	0xd2840365,
+	0x000f0002,
+	0x00718148,
+	0x0000003f,
+	0xd6800080,
+	0x000f0002,
+	0x00718149,
+	0x0000003f,
+	0xdd040004,
+	0x000f0002,
+	0x0071814a,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x0071814b,
+	0x00000069,
+	0xdd003b6d,
+	0x000f0002,
+	0x0071814c,
+	0x00000069,
+	0xdd003b6d,
+	0x000f0002,
+	0x0071814d,
+	0x00000031,
+	0xd303d265,
+	0x000f0002,
+	0x0071814e,
+	0x00000049,
+	0xde403b66,
+	0x000f0002,
+	0x0071814f,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x00718150,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x00718151,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x00718152,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x00718153,
+	0x00000049,
+	0xd5803b7e,
+	0x000f0002,
+	0x00718154,
+	0x00000021,
+	0xde4000e6,
+	0x000f0002,
+	0x00718155,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x00718156,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x00718157,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x00718158,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x00718159,
+	0x00000049,
+	0xd5003b7e,
+	0x000f0002,
+	0x0071815a,
+	0x00000079,
+	0xdd013b76,
+	0x000f0002,
+	0x0071815b,
+	0x0000002d,
+	0xdd04407f,
+	0x000f0002,
+	0x0071815c,
+	0x00000018,
+	0x3d7f3b76,
+	0x000f0002,
+	0x0071815d,
+	0x00000079,
+	0xdd01bb76,
+	0x000f0002,
+	0x0071815e,
+	0x00000075,
+	0xfd0180e8,
+	0x000f0002,
+	0x0071815f,
+	0x00000094,
+	0x00154168,
+	0x000f0002,
+	0x00718160,
+	0x00000094,
+	0x002544e8,
+	0x000f0002,
+	0x00718161,
+	0x00000094,
+	0x002341e8,
+	0x000f0002,
+	0x00718162,
+	0x00000094,
+	0x00174568,
+	0x000f0002,
+	0x00718163,
+	0x00000094,
+	0x00154268,
+	0x000f0002,
+	0x00718164,
+	0x00000094,
+	0x002742e8,
+	0x000f0002,
+	0x00718165,
+	0x00000094,
+	0x002d4368,
+	0x000f0002,
+	0x00718166,
+	0x00000094,
+	0x002d4468,
+	0x000f0002,
+	0x00718167,
+	0x00000094,
+	0x003343e8,
+	0x000f0002,
+	0x00718168,
+	0x00000004,
+	0x03973b76,
+	0x000f0002,
+	0x00718169,
+	0x0000000d,
+	0xe30dc165,
+	0x000f0002,
+	0x0071816a,
+	0x00000030,
+	0x32030076,
+	0x000f0002,
+	0x0071816b,
+	0x00000030,
+	0x12020076,
+	0x000f0002,
+	0x0071816c,
+	0x0000003f,
+	0xd4800000,
+	0x000f0002,
+	0x0071816d,
+	0x0000003f,
+	0xd1808000,
+	0x000f0002,
+	0x0071816e,
+	0x0000000d,
+	0xe33fc165,
+	0x000f0002,
+	0x0071816f,
+	0x00000030,
+	0x32046076,
+	0x000f0002,
+	0x00718170,
+	0x00000030,
+	0x12044076,
+	0x000f0002,
+	0x00718171,
+	0x0000003f,
+	0xd4828000,
+	0x000f0002,
+	0x00718172,
+	0x0000003f,
+	0xd1808000,
+	0x000f0002,
+	0x00718173,
+	0x0000000d,
+	0xe33fc165,
+	0x000f0002,
+	0x00718174,
+	0x00000030,
+	0x32042076,
+	0x000f0002,
+	0x00718175,
+	0x00000030,
+	0x12040076,
+	0x000f0002,
+	0x00718176,
+	0x0000003f,
+	0xd4820000,
+	0x000f0002,
+	0x00718177,
+	0x0000000d,
+	0xe363c165,
+	0x000f0002,
+	0x00718178,
+	0x00000030,
+	0x32032076,
+	0x000f0002,
+	0x00718179,
+	0x00000030,
+	0x12030076,
+	0x000f0002,
+	0x0071817a,
+	0x0000003f,
+	0xd4830000,
+	0x000f0002,
+	0x0071817b,
+	0x00000049,
+	0xd2803b76,
+	0x000f0002,
+	0x0071817c,
+	0x0000000d,
+	0xe30dc165,
+	0x000f0002,
+	0x0071817d,
+	0x00000030,
+	0x32038076,
+	0x000f0002,
+	0x0071817e,
+	0x00000030,
+	0x12028076,
+	0x000f0002,
+	0x0071817f,
+	0x0000003f,
+	0xd4810000,
+	0x000f0002,
+	0x00718180,
+	0x0000003f,
+	0xd6020000,
+	0x000f0002,
+	0x00718181,
+	0x0000003f,
+	0xd1810000,
+	0x000f0002,
+	0x00718182,
+	0x0000000d,
+	0xe33fc165,
+	0x000f0002,
+	0x00718183,
+	0x00000030,
+	0x32042076,
+	0x000f0002,
+	0x00718184,
+	0x00000030,
+	0x12040076,
+	0x000f0002,
+	0x00718185,
+	0x0000003f,
+	0xd4820000,
+	0x000f0002,
+	0x00718186,
+	0x00000041,
+	0xd48034eb,
+	0x000f0002,
+	0x00718187,
+	0x00000079,
+	0xdd01bb6a,
+	0x000f0002,
+	0x00718188,
+	0x00000079,
+	0xdd01bb76,
+	0x000f0002,
+	0x00718189,
+	0x0000003f,
+	0xd2001803,
+	0x000f0002,
+	0x0071818a,
+	0x0000003f,
+	0xd1810000,
+	0x000f0002,
+	0x0071818b,
+	0x00000075,
+	0xfd018063,
+	0x000f0002,
+	0x0071818c,
+	0x00000098,
+	0x80693b64,
+	0x000f0002,
+	0x0071818d,
+	0x00000051,
+	0xf20000e4,
+	0x000f0002,
+	0x0071818e,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x0071818f,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x00718190,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x00718191,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x00718192,
+	0x0000002d,
+	0xdd04407f,
+	0x000f0002,
+	0x00718193,
+	0x00000018,
+	0x3d7f3b76,
+	0x000f0002,
+	0x00718194,
+	0x00000049,
+	0xd3c03b38,
+	0x000f0002,
+	0x00718195,
+	0x00000049,
+	0xdd003b64,
+	0x000f0002,
+	0x00718196,
+	0x00000051,
+	0xf20000e4,
+	0x000f0002,
+	0x00718197,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x00718198,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x00718199,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x0071819a,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x0071819b,
+	0x00000049,
+	0xd3a03b38,
+	0x000f0002,
+	0x0071819c,
+	0x00000019,
+	0xdd61bb76,
+	0x000f0002,
+	0x0071819d,
+	0x00000049,
+	0xdd003b67,
+	0x000f0002,
+	0x0071819e,
+	0x00000075,
+	0xf1818263,
+	0x000f0002,
+	0x0071819f,
+	0x00000041,
+	0xd48034eb,
+	0x000f0002,
+	0x007181a0,
+	0x00000079,
+	0xdd01bb6a,
+	0x000f0002,
+	0x007181a1,
+	0x00000079,
+	0xdd01bb76,
+	0x000f0002,
+	0x007181a2,
+	0x0000003f,
+	0xd2001803,
+	0x000f0002,
+	0x007181a3,
+	0x0000003f,
+	0xd1808000,
+	0x000f0002,
+	0x007181a4,
+	0x00000075,
+	0xfd018063,
+	0x000f0002,
+	0x007181a5,
+	0x00000098,
+	0x80373b64,
+	0x000f0002,
+	0x007181a6,
+	0x00000051,
+	0xf20000e4,
+	0x000f0002,
+	0x007181a7,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x007181a8,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x007181a9,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007181aa,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x007181ab,
+	0x0000002d,
+	0xdd04407f,
+	0x000f0002,
+	0x007181ac,
+	0x00000018,
+	0x3d7f3b76,
+	0x000f0002,
+	0x007181ad,
+	0x00000049,
+	0xd3803b38,
+	0x000f0002,
+	0x007181ae,
+	0x00000019,
+	0xdd6fbb76,
+	0x000f0002,
+	0x007181af,
+	0x00000049,
+	0xdd003b67,
+	0x000f0002,
+	0x007181b0,
+	0x00000075,
+	0xf1818263,
+	0x000f0002,
+	0x007181b1,
+	0x00000041,
+	0xd48034eb,
+	0x000f0002,
+	0x007181b2,
+	0x00000079,
+	0xdd01bb6a,
+	0x000f0002,
+	0x007181b3,
+	0x00000079,
+	0xdd01bb63,
+	0x000f0002,
+	0x007181b4,
+	0x00000075,
+	0xfd018063,
+	0x000f0002,
+	0x007181b5,
+	0x00000098,
+	0x80173b64,
+	0x000f0002,
+	0x007181b6,
+	0x00000049,
+	0xde403b64,
+	0x000f0002,
+	0x007181b7,
+	0x0000003f,
+	0xd6800184,
+	0x000f0002,
+	0x007181b8,
+	0x0000003f,
+	0xd6800001,
+	0x000f0002,
+	0x007181b9,
+	0x00000035,
+	0xd68000ed,
+	0x000f0002,
+	0x007181ba,
+	0x00000018,
+	0x37ff0081,
+	0x000f0002,
+	0x007181bb,
+	0x0000002d,
+	0xdd04407f,
+	0x000f0002,
+	0x007181bc,
+	0x00000018,
+	0x3d7f3b76,
+	0x000f0002,
+	0x007181bd,
+	0x00000021,
+	0xd20000e4,
+	0x000f0002,
+	0x007181be,
+	0x00000019,
+	0xd3ef7b7e,
+	0x000f0002,
+	0x007181bf,
+	0x00000075,
+	0xf1818263,
+	0x000f0002,
+	0x007181c0,
+	0x0000003f,
+	0xd6800000,
+	0x000f0002,
+	0x007181c1,
+	0x0000003f,
+	0xdd040004,
+	0x000f0002,
+	0x007181c2,
+	0x0000003f,
+	0xdd180001,
+	0x000f0002,
+	0x007181c3,
+	0x00000069,
+	0xdd003b6d,
+	0x000f0002,
+	0x007181c4,
+	0x00000069,
+	0xdd003b6d,
+	0x000f0002,
+	0x007181c5,
+	0x0000003f,
+	0xdd000000,
+	0x000f0002,
+	0x007181c6,
+	0x0000002d,
+	0xdd540180,
+	0x000f0002,
+	0x007181c7,
+	0x00000079,
+	0xf3e08076,
+	0x000f0002,
+	0x007181c8,
+	0x00000049,
+	0xd600367a,
+	0x000f0002,
+	0x007181c9,
+	0x00000079,
+	0xdd01fb76,
+	0x000f0002,
+	0x007181ca,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181cb,
+	0x00000049,
+	0xdd003b03,
+	0x000f0002,
+	0x007181cc,
+	0x00000059,
+	0xfd003b76,
+	0x000f0002,
+	0x007181cd,
+	0x0000003f,
+	0xdd801c03,
+	0x000f0002,
+	0x007181ce,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181cf,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181d0,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007181d1,
+	0x0000002d,
+	0xdd06027f,
+	0x000f0002,
+	0x007181d2,
+	0x00000018,
+	0x1d7f3d7a,
+	0x000f0002,
+	0x007181d3,
+	0x00000031,
+	0xd483886b,
+	0x000f0002,
+	0x007181d4,
+	0x00000079,
+	0xdd01bb6a,
+	0x000f0002,
+	0x007181d5,
+	0x00000079,
+	0xf1819076,
+	0x000f0002,
+	0x007181d6,
+	0x00000075,
+	0xfd018063,
+	0x000f0002,
+	0x007181d7,
+	0x00000098,
+	0x8053bb76,
+	0x000f0002,
+	0x007181d8,
+	0x00000019,
+	0xdd7f7b79,
+	0x000f0002,
+	0x007181d9,
+	0x00000075,
+	0xf1818263,
+	0x000f0002,
+	0x007181da,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181db,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181dc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181dd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181de,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181df,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181e9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ea,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181eb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ec,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ed,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ee,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181ef,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181f9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181fa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181fb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181fc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181fd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007181fe,
+	0x0000003f,
+	0xdd800203,
+	0x000f0002,
+	0x007181ff,
+	0x00000049,
+	0xd1843b02,
+	0x000f0002,
+	0x00718200,
+	0x00000049,
+	0xdd003b03,
+	0x000f0002,
+	0x00718201,
+	0x00000069,
+	0xdd003b7a,
+	0x000f0002,
+	0x00718202,
+	0x00000049,
+	0xdd003b79,
+	0x000f0002,
+	0x00718203,
+	0x00000065,
+	0xf1800263,
+	0x000f0002,
+	0x00718204,
+	0x00000018,
+	0x7d7d3b76,
+	0x000f0002,
+	0x00718205,
+	0x00000009,
+	0xcf813d7a,
+	0x000f0002,
+	0x00718206,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718207,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718208,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718209,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071820a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071820b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071820c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071820d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071820e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071820f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718210,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718211,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718212,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718213,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718214,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718215,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718216,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718217,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718218,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718219,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071821a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071821b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071821c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071821d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071821e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071821f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718220,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718221,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718222,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718223,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718224,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718225,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718226,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718227,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718228,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718229,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071822a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071822b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071822c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071822d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071822e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071822f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718230,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718231,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718232,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718233,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718234,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718235,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718236,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718237,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718238,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718239,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071823a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071823b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071823c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071823d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071823e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071823f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718240,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718241,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718242,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718243,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718244,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718245,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718246,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718247,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718248,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718249,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071824a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071824b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071824c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071824d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071824e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071824f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718250,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718251,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718252,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718253,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718254,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718255,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718256,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718257,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718258,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718259,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071825a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071825b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071825c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071825d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071825e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071825f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718260,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718261,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718262,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718263,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718264,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718265,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718266,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718267,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718268,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718269,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071826a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071826b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071826c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071826d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071826e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071826f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718270,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718271,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718272,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718273,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718274,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718275,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718276,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718277,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718278,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718279,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071827a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071827b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071827c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071827d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071827e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071827f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718280,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718281,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718282,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718283,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718284,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718285,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718286,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718287,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718288,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718289,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071828a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071828b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071828c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071828d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071828e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071828f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718290,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718291,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718292,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718293,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718294,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718295,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718296,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718297,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718298,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718299,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071829a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071829b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071829c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071829d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071829e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071829f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182a9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182aa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ab,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ac,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ad,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ae,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182af,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182b9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ba,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182bb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182bc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182bd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182be,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182bf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182c9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ca,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182cb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182cc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182cd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ce,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182cf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182d9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182da,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182db,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182dc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182dd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182de,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182df,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182e9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ea,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182eb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ec,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ed,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ee,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ef,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182f9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182fa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182fb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182fc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182fd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182fe,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007182ff,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718300,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718301,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718302,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718303,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718304,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718305,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718306,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718307,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718308,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718309,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071830a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071830b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071830c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071830d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071830e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071830f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718310,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718311,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718312,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718313,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718314,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718315,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718316,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718317,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718318,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718319,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071831a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071831b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071831c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071831d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071831e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071831f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718320,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718321,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718322,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718323,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718324,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718325,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718326,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718327,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718328,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718329,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071832a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071832b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071832c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071832d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071832e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071832f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718330,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718331,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718332,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718333,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718334,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718335,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718336,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718337,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718338,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718339,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071833a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071833b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071833c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071833d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071833e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071833f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718340,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718341,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718342,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718343,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718344,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718345,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718346,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718347,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718348,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718349,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071834a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071834b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071834c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071834d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071834e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071834f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718350,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718351,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718352,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718353,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718354,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718355,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718356,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718357,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718358,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718359,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071835a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071835b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071835c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071835d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071835e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071835f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718360,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718361,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718362,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718363,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718364,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718365,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718366,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718367,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718368,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718369,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071836a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071836b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071836c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071836d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071836e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071836f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718370,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718371,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718372,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718373,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718374,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718375,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718376,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718377,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718378,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718379,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071837a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071837b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071837c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071837d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071837e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071837f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718380,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718381,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718382,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718383,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718384,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718385,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718386,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718387,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718388,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718389,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071838a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071838b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071838c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071838d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071838e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071838f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718390,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718391,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718392,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718393,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718394,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718395,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718396,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718397,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718398,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718399,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071839a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071839b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071839c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071839d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071839e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071839f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183a9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183aa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ab,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ac,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ad,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ae,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183af,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183b9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ba,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183bb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183bc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183bd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183be,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183bf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183c9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ca,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183cb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183cc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183cd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ce,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183cf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183d9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183da,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183db,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183dc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183dd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183de,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183df,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183e9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ea,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183eb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ec,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ed,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ee,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ef,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183f9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183fa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183fb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183fc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183fd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183fe,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007183ff,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718400,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718401,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718402,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718403,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718404,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718405,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718406,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718407,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718408,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718409,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071840a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071840b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071840c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071840d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071840e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071840f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718410,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718411,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718412,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718413,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718414,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718415,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718416,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718417,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718418,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718419,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071841a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071841b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071841c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071841d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071841e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071841f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718420,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718421,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718422,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718423,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718424,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718425,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718426,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718427,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718428,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718429,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071842a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071842b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071842c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071842d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071842e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071842f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718430,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718431,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718432,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718433,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718434,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718435,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718436,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718437,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718438,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718439,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071843a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071843b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071843c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071843d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071843e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071843f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718440,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718441,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718442,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718443,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718444,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718445,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718446,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718447,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718448,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718449,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071844a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071844b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071844c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071844d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071844e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071844f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718450,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718451,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718452,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718453,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718454,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718455,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718456,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718457,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718458,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718459,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071845a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071845b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071845c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071845d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071845e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071845f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718460,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718461,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718462,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718463,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718464,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718465,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718466,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718467,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718468,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718469,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071846a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071846b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071846c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071846d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071846e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071846f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718470,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718471,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718472,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718473,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718474,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718475,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718476,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718477,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718478,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718479,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071847a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071847b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071847c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071847d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071847e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071847f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718480,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718481,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718482,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718483,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718484,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718485,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718486,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718487,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718488,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718489,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071848a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071848b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071848c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071848d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071848e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071848f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718490,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718491,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718492,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718493,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718494,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718495,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718496,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718497,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718498,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718499,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071849a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071849b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071849c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071849d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071849e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071849f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184a9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184aa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ab,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ac,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ad,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ae,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184af,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184b9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ba,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184bb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184bc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184bd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184be,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184bf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184c9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ca,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184cb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184cc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184cd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ce,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184cf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184d9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184da,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184db,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184dc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184dd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184de,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184df,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184e9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ea,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184eb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ec,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ed,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ee,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ef,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184f9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184fa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184fb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184fc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184fd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184fe,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007184ff,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718500,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718501,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718502,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718503,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718504,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718505,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718506,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718507,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718508,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718509,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071850a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071850b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071850c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071850d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071850e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071850f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718510,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718511,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718512,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718513,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718514,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718515,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718516,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718517,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718518,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718519,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071851a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071851b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071851c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071851d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071851e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071851f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718520,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718521,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718522,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718523,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718524,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718525,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718526,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718527,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718528,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718529,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071852a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071852b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071852c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071852d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071852e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071852f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718530,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718531,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718532,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718533,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718534,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718535,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718536,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718537,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718538,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718539,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071853a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071853b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071853c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071853d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071853e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071853f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718540,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718541,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718542,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718543,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718544,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718545,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718546,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718547,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718548,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718549,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071854a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071854b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071854c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071854d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071854e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071854f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718550,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718551,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718552,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718553,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718554,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718555,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718556,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718557,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718558,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718559,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071855a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071855b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071855c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071855d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071855e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071855f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718560,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718561,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718562,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718563,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718564,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718565,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718566,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718567,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718568,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718569,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071856a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071856b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071856c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071856d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071856e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071856f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718570,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718571,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718572,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718573,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718574,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718575,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718576,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718577,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718578,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718579,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071857a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071857b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071857c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071857d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071857e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071857f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718580,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718581,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718582,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718583,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718584,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718585,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718586,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718587,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718588,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718589,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071858a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071858b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071858c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071858d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071858e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071858f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718590,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718591,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718592,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718593,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718594,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718595,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718596,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718597,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718598,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718599,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071859a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071859b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071859c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071859d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071859e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071859f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185a9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185aa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ab,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ac,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ad,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ae,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185af,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185b9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ba,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185bb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185bc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185bd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185be,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185bf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185c9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ca,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185cb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185cc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185cd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ce,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185cf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185d9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185da,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185db,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185dc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185dd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185de,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185df,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185e9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ea,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185eb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ec,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ed,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ee,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ef,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185f9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185fa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185fb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185fc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185fd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185fe,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007185ff,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718600,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718601,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718602,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718603,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718604,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718605,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718606,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718607,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718608,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718609,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071860a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071860b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071860c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071860d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071860e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071860f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718610,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718611,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718612,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718613,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718614,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718615,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718616,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718617,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718618,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718619,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071861a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071861b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071861c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071861d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071861e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071861f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718620,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718621,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718622,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718623,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718624,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718625,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718626,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718627,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718628,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718629,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071862a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071862b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071862c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071862d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071862e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071862f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718630,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718631,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718632,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718633,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718634,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718635,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718636,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718637,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718638,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718639,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071863a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071863b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071863c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071863d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071863e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071863f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718640,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718641,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718642,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718643,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718644,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718645,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718646,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718647,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718648,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718649,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071864a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071864b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071864c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071864d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071864e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071864f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718650,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718651,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718652,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718653,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718654,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718655,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718656,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718657,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718658,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718659,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071865a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071865b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071865c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071865d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071865e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071865f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718660,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718661,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718662,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718663,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718664,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718665,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718666,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718667,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718668,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718669,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071866a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071866b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071866c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071866d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071866e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071866f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718670,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718671,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718672,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718673,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718674,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718675,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718676,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718677,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718678,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718679,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071867a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071867b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071867c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071867d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071867e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071867f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718680,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718681,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718682,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718683,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718684,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718685,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718686,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718687,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718688,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718689,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071868a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071868b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071868c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071868d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071868e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071868f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718690,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718691,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718692,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718693,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718694,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718695,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718696,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718697,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718698,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718699,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071869a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071869b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071869c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071869d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071869e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071869f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186a9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186aa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ab,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ac,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ad,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ae,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186af,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186b9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ba,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186bb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186bc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186bd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186be,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186bf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186c9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ca,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186cb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186cc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186cd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ce,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186cf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186d9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186da,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186db,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186dc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186dd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186de,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186df,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186e9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ea,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186eb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ec,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ed,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ee,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ef,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186f9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186fa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186fb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186fc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186fd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186fe,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007186ff,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718700,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718701,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718702,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718703,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718704,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718705,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718706,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718707,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718708,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718709,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071870a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071870b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071870c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071870d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071870e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071870f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718710,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718711,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718712,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718713,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718714,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718715,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718716,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718717,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718718,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718719,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071871a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071871b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071871c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071871d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071871e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071871f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718720,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718721,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718722,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718723,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718724,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718725,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718726,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718727,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718728,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718729,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071872a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071872b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071872c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071872d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071872e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071872f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718730,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718731,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718732,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718733,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718734,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718735,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718736,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718737,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718738,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718739,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071873a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071873b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071873c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071873d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071873e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071873f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718740,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718741,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718742,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718743,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718744,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718745,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718746,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718747,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718748,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718749,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071874a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071874b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071874c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071874d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071874e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071874f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718750,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718751,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718752,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718753,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718754,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718755,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718756,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718757,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718758,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718759,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071875a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071875b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071875c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071875d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071875e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071875f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718760,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718761,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718762,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718763,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718764,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718765,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718766,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718767,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718768,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718769,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071876a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071876b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071876c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071876d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071876e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071876f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718770,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718771,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718772,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718773,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718774,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718775,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718776,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718777,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718778,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718779,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071877a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071877b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071877c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071877d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071877e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071877f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718780,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718781,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718782,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718783,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718784,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718785,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718786,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718787,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718788,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718789,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071878a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071878b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071878c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071878d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071878e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071878f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718790,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718791,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718792,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718793,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718794,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718795,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718796,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718797,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718798,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x00718799,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071879a,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071879b,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071879c,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071879d,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071879e,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x0071879f,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187a9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187aa,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187ab,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187ac,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187ad,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187ae,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187af,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b0,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b1,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b2,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b3,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b4,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b5,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b6,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b7,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b8,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187b9,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187ba,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187bb,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187bc,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187bd,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187be,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187bf,
+	0x00000000,
+	0x00000000,
+	0x000f0002,
+	0x007187c0,
+	0x00000079,
+	0xfd609076,
+	0x000f0002,
+	0x007187c1,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007187c2,
+	0x0000003d,
+	0xf780006f,
+	0x000f0002,
+	0x007187c3,
+	0x0000003d,
+	0xf780006f,
+/* FINISH INIT Descriptor */
+	0x000f0002,
+	0x807187c4,
+	0x0000003d,
+	0xf780006f,
+};
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 55f307f..785c4d8 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2123,6 +2123,11 @@
 #define PCI_VENDOR_ID_TEKRAM		0x1de1
 #define PCI_DEVICE_ID_TEKRAM_DC290	0xdc29
=20
+#define PCI_VENDOR_ID_TEHUTI		0x1fc9
+#define PCI_DEVICE_ID_TEHUTI_3009	0x3009
+#define PCI_DEVICE_ID_TEHUTI_3010	0x3010
+#define PCI_DEVICE_ID_TEHUTI_3014	0x3014
+
 #define PCI_VENDOR_ID_HINT             0x3388
 #define PCI_DEVICE_ID_HINT_VXPROII_IDE 0x8013
=20

------=_NextPart_000_0028_01C7F95C.265C0220--


