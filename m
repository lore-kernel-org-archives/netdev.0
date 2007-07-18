From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Wed, 18 Jul 2007 19:53:50 -0400
Message-ID: <20070718235350.GA9564@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49055 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761754AbXGSABG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 20:01:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Nothing highly notable.  Wireless pull, and new blackfin eth driver
(didn't get merged with rest of blackfin, since additional review was
requested).

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upst=
ream-linus

to receive the following updates:

 Documentation/powerpc/booting-without-of.txt |    6 +
 MAINTAINERS                                  |    7 +
 arch/powerpc/boot/dts/mpc8641_hpcn.dts       |    4 +
 arch/powerpc/sysdev/fsl_soc.c                |    9 +
 drivers/net/Kconfig                          |   44 ++
 drivers/net/Makefile                         |    1 +
 drivers/net/arm/ether3.c                     |    2 +-
 drivers/net/bfin_mac.c                       | 1009 ++++++++++++++++++=
++++++++
 drivers/net/bfin_mac.h                       |  132 ++++
 drivers/net/ehea/ehea.h                      |    2 +-
 drivers/net/ehea/ehea_main.c                 |   37 +-
 drivers/net/gianfar.c                        |   12 +-
 drivers/net/ni5010.c                         |    6 +-
 drivers/net/ns83820.c                        |    2 +-
 drivers/net/phy/vitesse.c                    |   46 +-
 drivers/net/saa9730.c                        |    9 +-
 drivers/net/tc35815.c                        |    2 +-
 drivers/net/wireless/ipw2100.c               |    6 +-
 drivers/net/wireless/ipw2200.c               |   18 +-
 drivers/net/wireless/zd1211rw/zd_usb.c       |    2 +
 include/linux/fsl_devices.h                  |    1 +
 net/ieee80211/ieee80211_wx.c                 |    7 +-
 22 files changed, 1308 insertions(+), 56 deletions(-)
 create mode 100644 drivers/net/bfin_mac.c
 create mode 100644 drivers/net/bfin_mac.h

Andy Fleming (4):
      Fix Vitesse 824x PHY interrupt acking
      Add phy-connection-type to gianfar nodes
      Fix Vitesse RGMII-ID support
      Fix RGMII-ID handling in gianfar

Bryan Wu (1):
      Blackfin ethernet driver: on chip ethernet MAC controller driver

Daniel Drake (1):
      zd1211rw: Add ID for Siemens Gigaset USB Stick 54

Jean Tourrilhes (1):
      softmac: Channel is listed twice in scan output

Masakazu Mokuno (1):
      zd1211rw: Add ID for Planex GW-US54GXS

Thomas Klein (1):
      eHEA: Fix bonding support

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (4):
      NS83820: Handle multicast frames.
      NI5010: Handle multicast frames.
      SAA9730: Handle multicast frames.
      ARM/ETHER3: Handle multicast frames.

Yoichi Yuasa (1):
      fix wrong argument of tc35815_read_plat_dev_addr()

Zhu Yi (4):
      ipw2100: Fix `iwpriv set_power` error
      Fix ipw2200 set wrong power parameter causing firmware error
      ipw2200: Fix ipw_isr() comments error on shared IRQ
      Update version ipw2200 stamp to 1.2.2

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentati=
on/powerpc/booting-without-of.txt
index 0c24348..76733a3 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1250,6 +1250,12 @@ platforms are moved over to use the flattened-de=
vice-tree model.
       network device.  This is used by the bootwrapper to interpret
       MAC addresses passed by the firmware when no information other
       than indices is available to associate an address with a device.
+    - phy-connection-type : a string naming the controller/PHY interfa=
ce type,
+      i.e., "mii" (default), "rmii", "gmii", "rgmii", "rgmii-id", "sgm=
ii",
+      "tbi", or "rtbi".  This property is only really needed if the co=
nnection
+      is of type "rgmii-id", as all other connection types are detecte=
d by
+      hardware.
+
=20
   Example:
=20
diff --git a/MAINTAINERS b/MAINTAINERS
index e78f62f..f6b2665 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -732,6 +732,13 @@ L:	uclinux-dist-devel@blackfin.uclinux.org (subscr=
ibers-only)
 W:	http://blackfin.uclinux.org
 S:	Supported
=20
+BLACKFIN EMAC DRIVER
+P:	Bryan Wu
+M:	bryan.wu@analog.com
+L:	uclinux-dist-devel@blackfin.uclinux.org (subscribers-only)
+W:	http://blackfin.uclinux.org
+S:	Supported
+
 BLACKFIN RTC DRIVER
 P:	Mike Frysinger
 M:	michael.frysinger@analog.com
diff --git a/arch/powerpc/boot/dts/mpc8641_hpcn.dts b/arch/powerpc/boot=
/dts/mpc8641_hpcn.dts
index db56a02..6a78a2b 100644
--- a/arch/powerpc/boot/dts/mpc8641_hpcn.dts
+++ b/arch/powerpc/boot/dts/mpc8641_hpcn.dts
@@ -131,6 +131,7 @@
 			interrupts =3D <1d 2 1e 2 22 2>;
 			interrupt-parent =3D <&mpic>;
 			phy-handle =3D <&phy0>;
+			phy-connection-type =3D "rgmii-id";
 		};
=20
 		ethernet@25000 {
@@ -150,6 +151,7 @@
 			interrupts =3D <23 2 24 2 28 2>;
 			interrupt-parent =3D <&mpic>;
 			phy-handle =3D <&phy1>;
+			phy-connection-type =3D "rgmii-id";
 		};
 	=09
 		ethernet@26000 {
@@ -169,6 +171,7 @@
 			interrupts =3D <1F 2 20 2 21 2>;
 			interrupt-parent =3D <&mpic>;
 			phy-handle =3D <&phy2>;
+			phy-connection-type =3D "rgmii-id";
 		};
=20
 		ethernet@27000 {
@@ -188,6 +191,7 @@
 			interrupts =3D <25 2 26 2 27 2>;
 			interrupt-parent =3D <&mpic>;
 			phy-handle =3D <&phy3>;
+			phy-connection-type =3D "rgmii-id";
 		};
 		serial@4500 {
 			device_type =3D "serial";
diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_so=
c.c
index c0ddc80..3289fab 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -197,6 +197,7 @@ static int __init gfar_of_init(void)
 		struct gianfar_platform_data gfar_data;
 		const unsigned int *id;
 		const char *model;
+		const char *ctype;
 		const void *mac_addr;
 		const phandle *ph;
 		int n_res =3D 2;
@@ -254,6 +255,14 @@ static int __init gfar_of_init(void)
 			    FSL_GIANFAR_DEV_HAS_VLAN |
 			    FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
=20
+		ctype =3D of_get_property(np, "phy-connection-type", NULL);
+
+		/* We only care about rgmii-id.  The rest are autodetected */
+		if (ctype && !strcmp(ctype, "rgmii-id"))
+			gfar_data.interface =3D PHY_INTERFACE_MODE_RGMII_ID;
+		else
+			gfar_data.interface =3D PHY_INTERFACE_MODE_MII;
+
 		ph =3D of_get_property(np, "phy-handle", NULL);
 		phy =3D of_find_node_by_phandle(*ph);
=20
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5fb659f..3073f67 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -838,6 +838,50 @@ config ULTRA32
 	  <file:Documentation/networking/net-modules.txt>. The module
 	  will be called smc-ultra32.
=20
+config BFIN_MAC
+	tristate "Blackfin 536/537 on-chip mac support"
+	depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
+	select CRC32
+	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
+	help
+	  This is the driver for blackfin on-chip mac device. Say Y if you wa=
nt it
+	  compiled into the kernel. This driver is also available as a module
+	  ( =3D code which can be inserted in and removed from the running ke=
rnel
+	  whenever you want). The module will be called bfin_mac.
+
+config BFIN_MAC_USE_L1
+	bool "Use L1 memory for rx/tx packets"
+	depends on BFIN_MAC && BF537
+	default y
+	help
+	  To get maximum network performace, you should use L1 memory as rx/t=
x buffers.
+	  Say N here if you want to reserve L1 memory for other uses.
+
+config BFIN_TX_DESC_NUM
+	int "Number of transmit buffer packets"
+	depends on BFIN_MAC
+	range 6 10 if BFIN_MAC_USE_L1
+	range 10 100
+	default "10"
+	help
+	  Set the number of buffer packets used in driver.
+
+config BFIN_RX_DESC_NUM
+	int "Number of receive buffer packets"
+	depends on BFIN_MAC
+	range 20 100 if BFIN_MAC_USE_L1
+	range 20 800
+	default "20"
+	help
+	  Set the number of buffer packets used in driver.
+
+config BFIN_MAC_RMII
+	bool "RMII PHY Interface (EXPERIMENTAL)"
+	depends on BFIN_MAC && EXPERIMENTAL
+	default n
+	help
+	  Use Reduced PHY MII Interface
+
 config SMC9194
 	tristate "SMC 9194 support"
 	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0e286ab..aaaa0a0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -200,6 +200,7 @@ obj-$(CONFIG_S2IO) +=3D s2io.o
 obj-$(CONFIG_MYRI10GE) +=3D myri10ge/
 obj-$(CONFIG_SMC91X) +=3D smc91x.o
 obj-$(CONFIG_SMC911X) +=3D smc911x.o
+obj-$(CONFIG_BFIN_MAC) +=3D bfin_mac.o
 obj-$(CONFIG_DM9000) +=3D dm9000.o
 obj-$(CONFIG_FEC_8XX) +=3D fec_8xx/
 obj-$(CONFIG_PASEMI_MAC) +=3D pasemi_mac.o
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index da71350..a7cac69 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -464,7 +464,7 @@ static void ether3_setmulticastlist(struct net_devi=
ce *dev)
 	if (dev->flags & IFF_PROMISC) {
 		/* promiscuous mode */
 		priv(dev)->regs.config1 |=3D CFG1_RECVPROMISC;
-	} else if (dev->flags & IFF_ALLMULTI) {
+	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
 		priv(dev)->regs.config1 |=3D CFG1_RECVSPECBRMULTI;
 	} else
 		priv(dev)->regs.config1 |=3D CFG1_RECVSPECBROAD;
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
new file mode 100644
index 0000000..9a08d65
--- /dev/null
+++ b/drivers/net/bfin_mac.c
@@ -0,0 +1,1009 @@
+/*
+ * File:	drivers/net/bfin_mac.c
+ * Based on:
+ * Maintainer:
+ * 		Bryan Wu <bryan.wu@analog.com>
+ *
+ * Original author:
+ * 		Luke Yang <luke.yang@analog.com>
+ *
+ * Created:
+ * Description:
+ *
+ * Modified:
+ *		Copyright 2004-2006 Analog Devices Inc.
+ *
+ * Bugs:	Enter bugs at http://blackfin.uclinux.org/
+ *
+ * This program is free software ;  you can redistribute it and/or mod=
ify
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation ;  either version 2, or (at your optio=
n)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY ;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program ;  see the file COPYING.
+ * If not, write to the Free Software Foundation,
+ * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/delay.h>
+#include <linux/timer.h>
+#include <linux/errno.h>
+#include <linux/irq.h>
+#include <linux/io.h>
+#include <linux/ioport.h>
+#include <linux/crc32.h>
+#include <linux/device.h>
+#include <linux/spinlock.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+
+#include <asm/dma.h>
+#include <linux/dma-mapping.h>
+
+#include <asm/blackfin.h>
+#include <asm/cacheflush.h>
+#include <asm/portmux.h>
+
+#include "bfin_mac.h"
+
+#define DRV_NAME	"bfin_mac"
+#define DRV_VERSION	"1.1"
+#define DRV_AUTHOR	"Bryan Wu, Luke Yang"
+#define DRV_DESC	"Blackfin BF53[67] on-chip Ethernet MAC driver"
+
+MODULE_AUTHOR(DRV_AUTHOR);
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION(DRV_DESC);
+
+#if defined(CONFIG_BFIN_MAC_USE_L1)
+# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
+# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
+#else
+# define bfin_mac_alloc(dma_handle, size) \
+	dma_alloc_coherent(NULL, size, dma_handle, GFP_KERNEL)
+# define bfin_mac_free(dma_handle, ptr) \
+	dma_free_coherent(NULL, sizeof(*ptr), ptr, dma_handle)
+#endif
+
+#define PKT_BUF_SZ 1580
+
+#define MAX_TIMEOUT_CNT	500
+
+/* pointers to maintain transmit list */
+static struct net_dma_desc_tx *tx_list_head;
+static struct net_dma_desc_tx *tx_list_tail;
+static struct net_dma_desc_rx *rx_list_head;
+static struct net_dma_desc_rx *rx_list_tail;
+static struct net_dma_desc_rx *current_rx_ptr;
+static struct net_dma_desc_tx *current_tx_ptr;
+static struct net_dma_desc_tx *tx_desc;
+static struct net_dma_desc_rx *rx_desc;
+
+static void desc_list_free(void)
+{
+	struct net_dma_desc_rx *r;
+	struct net_dma_desc_tx *t;
+	int i;
+#if !defined(CONFIG_BFIN_MAC_USE_L1)
+	dma_addr_t dma_handle =3D 0;
+#endif
+
+	if (tx_desc) {
+		t =3D tx_list_head;
+		for (i =3D 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
+			if (t) {
+				if (t->skb) {
+					dev_kfree_skb(t->skb);
+					t->skb =3D NULL;
+				}
+				t =3D t->next;
+			}
+		}
+		bfin_mac_free(dma_handle, tx_desc);
+	}
+
+	if (rx_desc) {
+		r =3D rx_list_head;
+		for (i =3D 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
+			if (r) {
+				if (r->skb) {
+					dev_kfree_skb(r->skb);
+					r->skb =3D NULL;
+				}
+				r =3D r->next;
+			}
+		}
+		bfin_mac_free(dma_handle, rx_desc);
+	}
+}
+
+static int desc_list_init(void)
+{
+	int i;
+	struct sk_buff *new_skb;
+#if !defined(CONFIG_BFIN_MAC_USE_L1)
+	/*
+	 * This dma_handle is useless in Blackfin dma_alloc_coherent().
+	 * The real dma handler is the return value of dma_alloc_coherent().
+	 */
+	dma_addr_t dma_handle;
+#endif
+
+	tx_desc =3D bfin_mac_alloc(&dma_handle,
+				sizeof(struct net_dma_desc_tx) *
+				CONFIG_BFIN_TX_DESC_NUM);
+	if (tx_desc =3D=3D NULL)
+		goto init_error;
+
+	rx_desc =3D bfin_mac_alloc(&dma_handle,
+				sizeof(struct net_dma_desc_rx) *
+				CONFIG_BFIN_RX_DESC_NUM);
+	if (rx_desc =3D=3D NULL)
+		goto init_error;
+
+	/* init tx_list */
+	tx_list_head =3D tx_list_tail =3D tx_desc;
+
+	for (i =3D 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
+		struct net_dma_desc_tx *t =3D tx_desc + i;
+		struct dma_descriptor *a =3D &(t->desc_a);
+		struct dma_descriptor *b =3D &(t->desc_b);
+
+		/*
+		 * disable DMA
+		 * read from memory WNR =3D 0
+		 * wordsize is 32 bits
+		 * 6 half words is desc size
+		 * large desc flow
+		 */
+		a->config =3D WDSIZE_32 | NDSIZE_6 | DMAFLOW_LARGE;
+		a->start_addr =3D (unsigned long)t->packet;
+		a->x_count =3D 0;
+		a->next_dma_desc =3D b;
+
+		/*
+		 * enabled DMA
+		 * write to memory WNR =3D 1
+		 * wordsize is 32 bits
+		 * disable interrupt
+		 * 6 half words is desc size
+		 * large desc flow
+		 */
+		b->config =3D DMAEN | WNR | WDSIZE_32 | NDSIZE_6 | DMAFLOW_LARGE;
+		b->start_addr =3D (unsigned long)(&(t->status));
+		b->x_count =3D 0;
+
+		t->skb =3D NULL;
+		tx_list_tail->desc_b.next_dma_desc =3D a;
+		tx_list_tail->next =3D t;
+		tx_list_tail =3D t;
+	}
+	tx_list_tail->next =3D tx_list_head;	/* tx_list is a circle */
+	tx_list_tail->desc_b.next_dma_desc =3D &(tx_list_head->desc_a);
+	current_tx_ptr =3D tx_list_head;
+
+	/* init rx_list */
+	rx_list_head =3D rx_list_tail =3D rx_desc;
+
+	for (i =3D 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
+		struct net_dma_desc_rx *r =3D rx_desc + i;
+		struct dma_descriptor *a =3D &(r->desc_a);
+		struct dma_descriptor *b =3D &(r->desc_b);
+
+		/* allocate a new skb for next time receive */
+		new_skb =3D dev_alloc_skb(PKT_BUF_SZ + 2);
+		if (!new_skb) {
+			printk(KERN_NOTICE DRV_NAME
+			       ": init: low on mem - packet dropped\n");
+			goto init_error;
+		}
+		skb_reserve(new_skb, 2);
+		r->skb =3D new_skb;
+
+		/*
+		 * enabled DMA
+		 * write to memory WNR =3D 1
+		 * wordsize is 32 bits
+		 * disable interrupt
+		 * 6 half words is desc size
+		 * large desc flow
+		 */
+		a->config =3D DMAEN | WNR | WDSIZE_32 | NDSIZE_6 | DMAFLOW_LARGE;
+		/* since RXDWA is enabled */
+		a->start_addr =3D (unsigned long)new_skb->data - 2;
+		a->x_count =3D 0;
+		a->next_dma_desc =3D b;
+
+		/*
+		 * enabled DMA
+		 * write to memory WNR =3D 1
+		 * wordsize is 32 bits
+		 * enable interrupt
+		 * 6 half words is desc size
+		 * large desc flow
+		 */
+		b->config =3D DMAEN | WNR | WDSIZE_32 | DI_EN |
+				NDSIZE_6 | DMAFLOW_LARGE;
+		b->start_addr =3D (unsigned long)(&(r->status));
+		b->x_count =3D 0;
+
+		rx_list_tail->desc_b.next_dma_desc =3D a;
+		rx_list_tail->next =3D r;
+		rx_list_tail =3D r;
+	}
+	rx_list_tail->next =3D rx_list_head;	/* rx_list is a circle */
+	rx_list_tail->desc_b.next_dma_desc =3D &(rx_list_head->desc_a);
+	current_rx_ptr =3D rx_list_head;
+
+	return 0;
+
+init_error:
+	desc_list_free();
+	printk(KERN_ERR DRV_NAME ": kmalloc failed\n");
+	return -ENOMEM;
+}
+
+
+/*---PHY CONTROL AND CONFIGURATION------------------------------------=
-----*/
+
+/* Set FER regs to MUX in Ethernet pins */
+static int setup_pin_mux(int action)
+{
+#if defined(CONFIG_BFIN_MAC_RMII)
+	u16 pin_req[] =3D P_RMII0;
+#else
+	u16 pin_req[] =3D P_MII0;
+#endif
+
+	if (action) {
+		if (peripheral_request_list(pin_req, DRV_NAME)) {
+			printk(KERN_ERR DRV_NAME
+			": Requesting Peripherals failed\n");
+			return -EFAULT;
+		}
+	} else
+		peripheral_free_list(pin_req);
+
+	return 0;
+}
+
+/* Wait until the previous MDC/MDIO transaction has completed */
+static void poll_mdc_done(void)
+{
+	int timeout_cnt =3D MAX_TIMEOUT_CNT;
+
+	/* poll the STABUSY bit */
+	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
+		mdelay(10);
+		if (timeout_cnt-- < 0) {
+			printk(KERN_ERR DRV_NAME
+			": wait MDC/MDIO transaction to complete timeout\n");
+			break;
+		}
+	}
+}
+
+/* Read an off-chip register in a PHY through the MDC/MDIO port */
+static u16 read_phy_reg(u16 PHYAddr, u16 RegAddr)
+{
+	poll_mdc_done();
+	/* read mode */
+	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) |
+				SET_REGAD(RegAddr) |
+				STABUSY);
+	poll_mdc_done();
+
+	return (u16) bfin_read_EMAC_STADAT();
+}
+
+/* Write an off-chip register in a PHY through the MDC/MDIO port */
+static void raw_write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
+{
+	bfin_write_EMAC_STADAT(Data);
+
+	/* write mode */
+	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) |
+				SET_REGAD(RegAddr) |
+				STAOP |
+				STABUSY);
+
+	poll_mdc_done();
+}
+
+static void write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
+{
+	poll_mdc_done();
+	raw_write_phy_reg(PHYAddr, RegAddr, Data);
+}
+
+/* set up the phy */
+static void bf537mac_setphy(struct net_device *dev)
+{
+	u16 phydat;
+	struct bf537mac_local *lp =3D netdev_priv(dev);
+
+	/* Program PHY registers */
+	pr_debug("start setting up phy\n");
+
+	/* issue a reset */
+	raw_write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, 0x8000);
+
+	/* wait half a second */
+	msleep(500);
+
+	phydat =3D read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
+
+	/* advertise flow control supported */
+	phydat =3D read_phy_reg(lp->PhyAddr, PHYREG_ANAR);
+	phydat |=3D (1 << 10);
+	write_phy_reg(lp->PhyAddr, PHYREG_ANAR, phydat);
+
+	phydat =3D 0;
+	if (lp->Negotiate)
+		phydat |=3D 0x1000;	/* enable auto negotiation */
+	else {
+		if (lp->FullDuplex)
+			phydat |=3D (1 << 8);	/* full duplex */
+		else
+			phydat &=3D (~(1 << 8));	/* half duplex */
+
+		if (!lp->Port10)
+			phydat |=3D (1 << 13);	/* 100 Mbps */
+		else
+			phydat &=3D (~(1 << 13));	/* 10 Mbps */
+	}
+
+	if (lp->Loopback)
+		phydat |=3D (1 << 14);	/* enable TX->RX loopback */
+
+	write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, phydat);
+	msleep(500);
+
+	phydat =3D read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
+	/* check for SMSC PHY */
+	if ((read_phy_reg(lp->PhyAddr, PHYREG_PHYID1) =3D=3D 0x7) &&
+	((read_phy_reg(lp->PhyAddr, PHYREG_PHYID2) & 0xfff0) =3D=3D 0xC0A0)) =
{
+		/*
+		 * we have SMSC PHY so reqest interrupt
+		 * on link down condition
+		 */
+
+		/* enable interrupts */
+		write_phy_reg(lp->PhyAddr, 30, 0x0ff);
+	}
+}
+
+/*********************************************************************=
*****/
+void setup_system_regs(struct net_device *dev)
+{
+	int phyaddr;
+	unsigned short sysctl, phydat;
+	u32 opmode;
+	struct bf537mac_local *lp =3D netdev_priv(dev);
+	int count =3D 0;
+
+	phyaddr =3D lp->PhyAddr;
+
+	/* Enable PHY output */
+	if (!(bfin_read_VR_CTL() & PHYCLKOE))
+		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
+
+	/* MDC  =3D 2.5 MHz */
+	sysctl =3D SET_MDCDIV(24);
+	/* Odd word alignment for Receive Frame DMA word */
+	/* Configure checksum support and rcve frame word alignment */
+#if defined(BFIN_MAC_CSUM_OFFLOAD)
+	sysctl |=3D RXDWA | RXCKS;
+#else
+	sysctl |=3D RXDWA;
+#endif
+	bfin_write_EMAC_SYSCTL(sysctl);
+	/* auto negotiation on  */
+	/* full duplex          */
+	/* 100 Mbps             */
+	phydat =3D PHY_ANEG_EN | PHY_DUPLEX | PHY_SPD_SET;
+	write_phy_reg(phyaddr, PHYREG_MODECTL, phydat);
+
+	/* test if full duplex supported */
+	do {
+		msleep(100);
+		phydat =3D read_phy_reg(phyaddr, PHYREG_MODESTAT);
+		if (count > 30) {
+			printk(KERN_NOTICE DRV_NAME ": Link is down\n");
+			printk(KERN_NOTICE DRV_NAME
+				 "please check your network connection\n");
+			break;
+		}
+		count++;
+	} while (!(phydat & 0x0004));
+
+	phydat =3D read_phy_reg(phyaddr, PHYREG_ANLPAR);
+
+	if ((phydat & 0x0100) || (phydat & 0x0040)) {
+		opmode =3D FDMODE;
+	} else {
+		opmode =3D 0;
+		printk(KERN_INFO DRV_NAME
+			": Network is set to half duplex\n");
+	}
+
+#if defined(CONFIG_BFIN_MAC_RMII)
+	opmode |=3D RMII; /* For Now only 100MBit are supported */
+#endif
+
+	bfin_write_EMAC_OPMODE(opmode);
+
+	bfin_write_EMAC_MMC_CTL(RSTC | CROLL);
+
+	/* Initialize the TX DMA channel registers */
+	bfin_write_DMA2_X_COUNT(0);
+	bfin_write_DMA2_X_MODIFY(4);
+	bfin_write_DMA2_Y_COUNT(0);
+	bfin_write_DMA2_Y_MODIFY(0);
+
+	/* Initialize the RX DMA channel registers */
+	bfin_write_DMA1_X_COUNT(0);
+	bfin_write_DMA1_X_MODIFY(4);
+	bfin_write_DMA1_Y_COUNT(0);
+	bfin_write_DMA1_Y_MODIFY(0);
+}
+
+void setup_mac_addr(u8 * mac_addr)
+{
+	u32 addr_low =3D le32_to_cpu(*(__le32 *) & mac_addr[0]);
+	u16 addr_hi =3D le16_to_cpu(*(__le16 *) & mac_addr[4]);
+
+	/* this depends on a little-endian machine */
+	bfin_write_EMAC_ADDRLO(addr_low);
+	bfin_write_EMAC_ADDRHI(addr_hi);
+}
+
+static void adjust_tx_list(void)
+{
+	int timeout_cnt =3D MAX_TIMEOUT_CNT;
+
+	if (tx_list_head->status.status_word !=3D 0
+	    && current_tx_ptr !=3D tx_list_head) {
+		goto adjust_head;	/* released something, just return; */
+	}
+
+	/*
+	 * if nothing released, check wait condition
+	 * current's next can not be the head,
+	 * otherwise the dma will not stop as we want
+	 */
+	if (current_tx_ptr->next->next =3D=3D tx_list_head) {
+		while (tx_list_head->status.status_word =3D=3D 0) {
+			mdelay(10);
+			if (tx_list_head->status.status_word !=3D 0
+			    || !(bfin_read_DMA2_IRQ_STATUS() & 0x08)) {
+				goto adjust_head;
+			}
+			if (timeout_cnt-- < 0) {
+				printk(KERN_ERR DRV_NAME
+				": wait for adjust tx list head timeout\n");
+				break;
+			}
+		}
+		if (tx_list_head->status.status_word !=3D 0) {
+			goto adjust_head;
+		}
+	}
+
+	return;
+
+adjust_head:
+	do {
+		tx_list_head->desc_a.config &=3D ~DMAEN;
+		tx_list_head->status.status_word =3D 0;
+		if (tx_list_head->skb) {
+			dev_kfree_skb(tx_list_head->skb);
+			tx_list_head->skb =3D NULL;
+		} else {
+			printk(KERN_ERR DRV_NAME
+			       ": no sk_buff in a transmitted frame!\n");
+		}
+		tx_list_head =3D tx_list_head->next;
+	} while (tx_list_head->status.status_word !=3D 0
+		 && current_tx_ptr !=3D tx_list_head);
+	return;
+
+}
+
+static int bf537mac_hard_start_xmit(struct sk_buff *skb,
+				struct net_device *dev)
+{
+	struct bf537mac_local *lp =3D netdev_priv(dev);
+	unsigned int data;
+
+	current_tx_ptr->skb =3D skb;
+
+	/*
+	 * Is skb->data always 16-bit aligned?
+	 * Do we need to memcpy((char *)(tail->packet + 2), skb->data, len)?
+	 */
+	if ((((unsigned int)(skb->data)) & 0x02) =3D=3D 2) {
+		/* move skb->data to current_tx_ptr payload */
+		data =3D (unsigned int)(skb->data) - 2;
+		*((unsigned short *)data) =3D (unsigned short)(skb->len);
+		current_tx_ptr->desc_a.start_addr =3D (unsigned long)data;
+		/* this is important! */
+		blackfin_dcache_flush_range(data, (data + (skb->len)) + 2);
+
+	} else {
+		*((unsigned short *)(current_tx_ptr->packet)) =3D
+		    (unsigned short)(skb->len);
+		memcpy((char *)(current_tx_ptr->packet + 2), skb->data,
+		       (skb->len));
+		current_tx_ptr->desc_a.start_addr =3D
+		    (unsigned long)current_tx_ptr->packet;
+		if (current_tx_ptr->status.status_word !=3D 0)
+			current_tx_ptr->status.status_word =3D 0;
+		blackfin_dcache_flush_range((unsigned int)current_tx_ptr->
+					    packet,
+					    (unsigned int)(current_tx_ptr->
+							   packet + skb->len) +
+					    2);
+	}
+
+	/* enable this packet's dma */
+	current_tx_ptr->desc_a.config |=3D DMAEN;
+
+	/* tx dma is running, just return */
+	if (bfin_read_DMA2_IRQ_STATUS() & 0x08)
+		goto out;
+
+	/* tx dma is not running */
+	bfin_write_DMA2_NEXT_DESC_PTR(&(current_tx_ptr->desc_a));
+	/* dma enabled, read from memory, size is 6 */
+	bfin_write_DMA2_CONFIG(current_tx_ptr->desc_a.config);
+	/* Turn on the EMAC tx */
+	bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() | TE);
+
+out:
+	adjust_tx_list();
+	current_tx_ptr =3D current_tx_ptr->next;
+	dev->trans_start =3D jiffies;
+	lp->stats.tx_packets++;
+	lp->stats.tx_bytes +=3D (skb->len);
+	return 0;
+}
+
+static void bf537mac_rx(struct net_device *dev)
+{
+	struct sk_buff *skb, *new_skb;
+	struct bf537mac_local *lp =3D netdev_priv(dev);
+	unsigned short len;
+
+	/* allocate a new skb for next time receive */
+	skb =3D current_rx_ptr->skb;
+	new_skb =3D dev_alloc_skb(PKT_BUF_SZ + 2);
+	if (!new_skb) {
+		printk(KERN_NOTICE DRV_NAME
+		       ": rx: low on mem - packet dropped\n");
+		lp->stats.rx_dropped++;
+		goto out;
+	}
+	/* reserve 2 bytes for RXDWA padding */
+	skb_reserve(new_skb, 2);
+	current_rx_ptr->skb =3D new_skb;
+	current_rx_ptr->desc_a.start_addr =3D (unsigned long)new_skb->data - =
2;
+
+	len =3D (unsigned short)((current_rx_ptr->status.status_word) & RX_FR=
LEN);
+	skb_put(skb, len);
+	blackfin_dcache_invalidate_range((unsigned long)skb->head,
+					 (unsigned long)skb->tail);
+
+	dev->last_rx =3D jiffies;
+	skb->dev =3D dev;
+	skb->protocol =3D eth_type_trans(skb, dev);
+#if defined(BFIN_MAC_CSUM_OFFLOAD)
+	skb->csum =3D current_rx_ptr->status.ip_payload_csum;
+	skb->ip_summed =3D CHECKSUM_PARTIAL;
+#endif
+
+	netif_rx(skb);
+	lp->stats.rx_packets++;
+	lp->stats.rx_bytes +=3D len;
+	current_rx_ptr->status.status_word =3D 0x00000000;
+	current_rx_ptr =3D current_rx_ptr->next;
+
+out:
+	return;
+}
+
+/* interrupt routine to handle rx and error signal */
+static irqreturn_t bf537mac_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	int number =3D 0;
+
+get_one_packet:
+	if (current_rx_ptr->status.status_word =3D=3D 0) {
+		/* no more new packet received */
+		if (number =3D=3D 0) {
+			if (current_rx_ptr->next->status.status_word !=3D 0) {
+				current_rx_ptr =3D current_rx_ptr->next;
+				goto real_rx;
+			}
+		}
+		bfin_write_DMA1_IRQ_STATUS(bfin_read_DMA1_IRQ_STATUS() |
+					   DMA_DONE | DMA_ERR);
+		return IRQ_HANDLED;
+	}
+
+real_rx:
+	bf537mac_rx(dev);
+	number++;
+	goto get_one_packet;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bf537mac_poll(struct net_device *dev)
+{
+	disable_irq(IRQ_MAC_RX);
+	bf537mac_interrupt(IRQ_MAC_RX, dev);
+	enable_irq(IRQ_MAC_RX);
+}
+#endif				/* CONFIG_NET_POLL_CONTROLLER */
+
+static void bf537mac_reset(void)
+{
+	unsigned int opmode;
+
+	opmode =3D bfin_read_EMAC_OPMODE();
+	opmode &=3D (~RE);
+	opmode &=3D (~TE);
+	/* Turn off the EMAC */
+	bfin_write_EMAC_OPMODE(opmode);
+}
+
+/*
+ * Enable Interrupts, Receive, and Transmit
+ */
+static int bf537mac_enable(struct net_device *dev)
+{
+	u32 opmode;
+
+	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+
+	/* Set RX DMA */
+	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
+	bfin_write_DMA1_CONFIG(rx_list_head->desc_a.config);
+
+	/* Wait MII done */
+	poll_mdc_done();
+
+	/* We enable only RX here */
+	/* ASTP   : Enable Automatic Pad Stripping
+	   PR     : Promiscuous Mode for test
+	   PSF    : Receive frames with total length less than 64 bytes.
+	   FDMODE : Full Duplex Mode
+	   LB     : Internal Loopback for test
+	   RE     : Receiver Enable */
+	opmode =3D bfin_read_EMAC_OPMODE();
+	if (opmode & FDMODE)
+		opmode |=3D PSF;
+	else
+		opmode |=3D DRO | DC | PSF;
+	opmode |=3D RE;
+
+#if defined(CONFIG_BFIN_MAC_RMII)
+	opmode |=3D RMII; /* For Now only 100MBit are supported */
+#ifdef CONFIG_BF_REV_0_2
+	opmode |=3D TE;
+#endif
+#endif
+	/* Turn on the EMAC rx */
+	bfin_write_EMAC_OPMODE(opmode);
+
+	return 0;
+}
+
+/* Our watchdog timed out. Called by the networking layer */
+static void bf537mac_timeout(struct net_device *dev)
+{
+	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+
+	bf537mac_reset();
+
+	/* reset tx queue */
+	tx_list_tail =3D tx_list_head->next;
+
+	bf537mac_enable(dev);
+
+	/* We can accept TX packets again */
+	dev->trans_start =3D jiffies;
+	netif_wake_queue(dev);
+}
+
+/*
+ * Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *bf537mac_query_statistics(struct net_d=
evice
+							  *dev)
+{
+	struct bf537mac_local *lp =3D netdev_priv(dev);
+
+	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+
+	return &lp->stats;
+}
+
+/*
+ * This routine will, depending on the values passed to it,
+ * either make it accept multicast packets, go into
+ * promiscuous mode (for TCPDUMP and cousins) or accept
+ * a select set of multicast packets
+ */
+static void bf537mac_set_multicast_list(struct net_device *dev)
+{
+	u32 sysctl;
+
+	if (dev->flags & IFF_PROMISC) {
+		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
+		sysctl =3D bfin_read_EMAC_OPMODE();
+		sysctl |=3D RAF;
+		bfin_write_EMAC_OPMODE(sysctl);
+	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
+		/* accept all multicast */
+		sysctl =3D bfin_read_EMAC_OPMODE();
+		sysctl |=3D PAM;
+		bfin_write_EMAC_OPMODE(sysctl);
+	} else {
+		/* clear promisc or multicast mode */
+		sysctl =3D bfin_read_EMAC_OPMODE();
+		sysctl &=3D ~(RAF | PAM);
+		bfin_write_EMAC_OPMODE(sysctl);
+	}
+}
+
+/*
+ * this puts the device in an inactive state
+ */
+static void bf537mac_shutdown(struct net_device *dev)
+{
+	/* Turn off the EMAC */
+	bfin_write_EMAC_OPMODE(0x00000000);
+	/* Turn off the EMAC RX DMA */
+	bfin_write_DMA1_CONFIG(0x0000);
+	bfin_write_DMA2_CONFIG(0x0000);
+}
+
+/*
+ * Open and Initialize the interface
+ *
+ * Set up everything, reset the card, etc..
+ */
+static int bf537mac_open(struct net_device *dev)
+{
+	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+
+	/*
+	 * Check that the address is valid.  If its not, refuse
+	 * to bring the device up.  The user must specify an
+	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
+	 */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		printk(KERN_WARNING DRV_NAME ": no valid ethernet hw addr\n");
+		return -EINVAL;
+	}
+
+	/* initial rx and tx list */
+	desc_list_init();
+
+	bf537mac_setphy(dev);
+	setup_system_regs(dev);
+	bf537mac_reset();
+	bf537mac_enable(dev);
+
+	pr_debug("hardware init finished\n");
+	netif_start_queue(dev);
+	netif_carrier_on(dev);
+
+	return 0;
+}
+
+/*
+ *
+ * this makes the board clean up everything that it can
+ * and not talk to the outside world.   Caused by
+ * an 'ifconfig ethX down'
+ */
+static int bf537mac_close(struct net_device *dev)
+{
+	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+
+	netif_stop_queue(dev);
+	netif_carrier_off(dev);
+
+	/* clear everything */
+	bf537mac_shutdown(dev);
+
+	/* free the rx/tx buffers */
+	desc_list_free();
+
+	return 0;
+}
+
+static int __init bf537mac_probe(struct net_device *dev)
+{
+	struct bf537mac_local *lp =3D netdev_priv(dev);
+	int retval;
+
+	/* Grab the MAC address in the MAC */
+	*(__le32 *) (&(dev->dev_addr[0])) =3D cpu_to_le32(bfin_read_EMAC_ADDR=
LO());
+	*(__le16 *) (&(dev->dev_addr[4])) =3D cpu_to_le16((u16) bfin_read_EMA=
C_ADDRHI());
+
+	/* probe mac */
+	/*todo: how to proble? which is revision_register */
+	bfin_write_EMAC_ADDRLO(0x12345678);
+	if (bfin_read_EMAC_ADDRLO() !=3D 0x12345678) {
+		pr_debug("can't detect bf537 mac!\n");
+		retval =3D -ENODEV;
+		goto err_out;
+	}
+
+	/* set the GPIO pins to Ethernet mode */
+	retval =3D setup_pin_mux(1);
+
+	if (retval)
+		return retval;
+
+	/*Is it valid? (Did bootloader initialize it?) */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		/* Grab the MAC from the board somehow - this is done in the
+		   arch/blackfin/mach-bf537/boards/eth_mac.c */
+		get_bf537_ether_addr(dev->dev_addr);
+	}
+
+	/* If still not valid, get a random one */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		random_ether_addr(dev->dev_addr);
+	}
+
+	setup_mac_addr(dev->dev_addr);
+
+	/* Fill in the fields of the device structure with ethernet values. *=
/
+	ether_setup(dev);
+
+	dev->open =3D bf537mac_open;
+	dev->stop =3D bf537mac_close;
+	dev->hard_start_xmit =3D bf537mac_hard_start_xmit;
+	dev->tx_timeout =3D bf537mac_timeout;
+	dev->get_stats =3D bf537mac_query_statistics;
+	dev->set_multicast_list =3D bf537mac_set_multicast_list;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =3D bf537mac_poll;
+#endif
+
+	/* fill in some of the fields */
+	lp->version =3D 1;
+	lp->PhyAddr =3D 0x01;
+	lp->CLKIN =3D 25;
+	lp->FullDuplex =3D 0;
+	lp->Negotiate =3D 1;
+	lp->FlowControl =3D 0;
+	spin_lock_init(&lp->lock);
+
+	/* now, enable interrupts */
+	/* register irq handler */
+	if (request_irq
+	    (IRQ_MAC_RX, bf537mac_interrupt, IRQF_DISABLED | IRQF_SHARED,
+	     "BFIN537_MAC_RX", dev)) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Unable to attach BlackFin MAC RX interrupt\n");
+		return -EBUSY;
+	}
+
+	/* Enable PHY output early */
+	if (!(bfin_read_VR_CTL() & PHYCLKOE))
+		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
+
+	retval =3D register_netdev(dev);
+	if (retval =3D=3D 0) {
+		/* now, print out the card info, in a short format.. */
+		printk(KERN_INFO "%s: Version %s, %s\n",
+			 DRV_NAME, DRV_VERSION, DRV_DESC);
+	}
+
+err_out:
+	return retval;
+}
+
+static int bfin_mac_probe(struct platform_device *pdev)
+{
+	struct net_device *ndev;
+
+	ndev =3D alloc_etherdev(sizeof(struct bf537mac_local));
+	if (!ndev) {
+		printk(KERN_WARNING DRV_NAME ": could not allocate device\n");
+		return -ENOMEM;
+	}
+
+	SET_MODULE_OWNER(ndev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	platform_set_drvdata(pdev, ndev);
+
+	if (bf537mac_probe(ndev) !=3D 0) {
+		platform_set_drvdata(pdev, NULL);
+		free_netdev(ndev);
+		printk(KERN_WARNING DRV_NAME ": not found\n");
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static int bfin_mac_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev =3D platform_get_drvdata(pdev);
+
+	platform_set_drvdata(pdev, NULL);
+
+	unregister_netdev(ndev);
+
+	free_irq(IRQ_MAC_RX, ndev);
+
+	free_netdev(ndev);
+
+	setup_pin_mux(0);
+
+	return 0;
+}
+
+static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t=
 state)
+{
+	return 0;
+}
+
+static int bfin_mac_resume(struct platform_device *pdev)
+{
+	return 0;
+}
+
+static struct platform_driver bfin_mac_driver =3D {
+	.probe =3D bfin_mac_probe,
+	.remove =3D bfin_mac_remove,
+	.resume =3D bfin_mac_resume,
+	.suspend =3D bfin_mac_suspend,
+	.driver =3D {
+		   .name =3D DRV_NAME,
+		   },
+};
+
+static int __init bfin_mac_init(void)
+{
+	return platform_driver_register(&bfin_mac_driver);
+}
+
+module_init(bfin_mac_init);
+
+static void __exit bfin_mac_cleanup(void)
+{
+	platform_driver_unregister(&bfin_mac_driver);
+}
+
+module_exit(bfin_mac_cleanup);
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
new file mode 100644
index 0000000..af87189
--- /dev/null
+++ b/drivers/net/bfin_mac.h
@@ -0,0 +1,132 @@
+/*
+ * File:	drivers/net/bfin_mac.c
+ * Based on:
+ * Maintainer:
+ * 		Bryan Wu <bryan.wu@analog.com>
+ *
+ * Original author:
+ * 		Luke Yang <luke.yang@analog.com>
+ *
+ * Created:
+ * Description:
+ *
+ * Modified:
+ *		Copyright 2004-2006 Analog Devices Inc.
+ *
+ * Bugs:	Enter bugs at http://blackfin.uclinux.org/
+ *
+ * This program is free software ;  you can redistribute it and/or mod=
ify
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation ;  either version 2, or (at your optio=
n)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY ;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program ;  see the file COPYING.
+ * If not, write to the Free Software Foundation,
+ * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+ * PHY REGISTER NAMES
+ */
+#define PHYREG_MODECTL		0x0000
+#define PHYREG_MODESTAT		0x0001
+#define PHYREG_PHYID1		0x0002
+#define PHYREG_PHYID2		0x0003
+#define PHYREG_ANAR		0x0004
+#define PHYREG_ANLPAR		0x0005
+#define PHYREG_ANER		0x0006
+#define PHYREG_NSR		0x0010
+#define PHYREG_LBREMR		0x0011
+#define PHYREG_REC		0x0012
+#define PHYREG_10CFG		0x0013
+#define PHYREG_PHY1_1		0x0014
+#define PHYREG_PHY1_2		0x0015
+#define PHYREG_PHY2		0x0016
+#define PHYREG_TW_1		0x0017
+#define PHYREG_TW_2		0x0018
+#define PHYREG_TEST		0x0019
+
+#define PHY_RESET		0x8000
+#define PHY_ANEG_EN		0x1000
+#define PHY_DUPLEX		0x0100
+#define PHY_SPD_SET		0x2000
+
+#define BFIN_MAC_CSUM_OFFLOAD
+
+struct dma_descriptor {
+	struct dma_descriptor *next_dma_desc;
+	unsigned long start_addr;
+	unsigned short config;
+	unsigned short x_count;
+};
+
+struct status_area_rx {
+#if defined(BFIN_MAC_CSUM_OFFLOAD)
+	unsigned short ip_hdr_csum;	/* ip header checksum */
+	/* ip payload(udp or tcp or others) checksum */
+	unsigned short ip_payload_csum;
+#endif
+	unsigned long status_word;	/* the frame status word */
+};
+
+struct status_area_tx {
+	unsigned long status_word;	/* the frame status word */
+};
+
+/* use two descriptors for a packet */
+struct net_dma_desc_rx {
+	struct net_dma_desc_rx *next;
+	struct sk_buff *skb;
+	struct dma_descriptor desc_a;
+	struct dma_descriptor desc_b;
+	struct status_area_rx status;
+};
+
+/* use two descriptors for a packet */
+struct net_dma_desc_tx {
+	struct net_dma_desc_tx *next;
+	struct sk_buff *skb;
+	struct dma_descriptor desc_a;
+	struct dma_descriptor desc_b;
+	unsigned char packet[1560];
+	struct status_area_tx status;
+};
+
+struct bf537mac_local {
+	/*
+	 * these are things that the kernel wants me to keep, so users
+	 * can find out semi-useless statistics of how well the card is
+	 * performing
+	 */
+	struct net_device_stats stats;
+
+	int version;
+
+	int FlowEnabled;	/* record if data flow is active */
+	int EtherIntIVG;	/* IVG for the ethernet interrupt */
+	int RXIVG;		/* IVG for the RX completion */
+	int TXIVG;		/* IVG for the TX completion */
+	int PhyAddr;		/* PHY address */
+	int OpMode;		/* set these bits n the OPMODE regs */
+	int Port10;		/* set port speed to 10 Mbit/s */
+	int GenChksums;		/* IP checksums to be calculated */
+	int NoRcveLnth;		/* dont insert recv length at start of buffer */
+	int StripPads;		/* remove trailing pad bytes */
+	int FullDuplex;		/* set full duplex mode */
+	int Negotiate;		/* enable auto negotiation */
+	int Loopback;		/* loopback at the PHY */
+	int Cache;		/* Buffers may be cached */
+	int FlowControl;	/* flow control active */
+	int CLKIN;		/* clock in value in MHZ */
+	unsigned short IntMask;	/* interrupt mask */
+	unsigned char Mac[6];	/* MAC address of the board */
+	spinlock_t lock;
+};
+
+extern void get_bf537_ether_addr(char *addr);
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 6628fa6..489c8b2 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
=20
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0070"
+#define DRV_VERSION	"EHEA_0071"
=20
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index 1d1571c..4c70a93 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -466,6 +466,8 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_=
device *dev,
 							 cqe->vlan_tag);
 			else
 				netif_receive_skb(skb);
+
+			dev->last_rx =3D jiffies;
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset =3D ehea_treat_poll_error(pr, rq, cqe,
@@ -1433,7 +1435,8 @@ static int ehea_broadcast_reg_helper(struct ehea_=
port *port, u32 hcallid)
 				     port->logical_port_id,
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret !=3D H_SUCCESS) {
-		ehea_error("reg_dereg_bcmc failed (tagged)");
+		ehea_error("%sregistering bc address failed (tagged)",
+                           hcallid =3D=3D H_REG_BCMC ? "" : "de");
 		ret =3D -EIO;
 		goto out_herr;
 	}
@@ -1444,7 +1447,8 @@ static int ehea_broadcast_reg_helper(struct ehea_=
port *port, u32 hcallid)
 				     port->logical_port_id,
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret !=3D H_SUCCESS) {
-		ehea_error("reg_dereg_bcmc failed (vlan)");
+		ehea_error("%sregistering bc address failed (vlan)",
+			   hcallid =3D=3D H_REG_BCMC ? "" : "de");
 		ret =3D -EIO;
 	}
 out_herr:
@@ -2170,7 +2174,6 @@ static int ehea_up(struct net_device *dev)
 {
 	int ret, i;
 	struct ehea_port *port =3D netdev_priv(dev);
-	u64 mac_addr =3D 0;
=20
 	if (port->state =3D=3D EHEA_PORT_UP)
 		return 0;
@@ -2189,18 +2192,10 @@ static int ehea_up(struct net_device *dev)
 		goto out_clean_pr;
 	}
=20
-	ret =3D ehea_broadcast_reg_helper(port, H_REG_BCMC);
-	if (ret) {
-		ret =3D -EIO;
-		ehea_error("out_clean_pr");
-		goto out_clean_pr;
-	}
-	mac_addr =3D (*(u64*)dev->dev_addr) >> 16;
-
 	ret =3D ehea_reg_interrupts(dev);
 	if (ret) {
-		ehea_error("out_dereg_bc");
-		goto out_dereg_bc;
+		ehea_error("reg_interrupts failed. ret:%d", ret);
+		goto out_clean_pr;
 	}
=20
 	for(i =3D 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
@@ -2226,9 +2221,6 @@ static int ehea_up(struct net_device *dev)
 out_free_irqs:
 	ehea_free_interrupts(dev);
=20
-out_dereg_bc:
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-
 out_clean_pr:
 	ehea_clean_all_portres(port);
 out:
@@ -2273,7 +2265,6 @@ static int ehea_down(struct net_device *dev)
 				&port->port_res[i].d_netdev->state))
 			msleep(1);
=20
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	port->state =3D EHEA_PORT_DOWN;
=20
 	ret =3D ehea_clean_all_portres(port);
@@ -2655,12 +2646,18 @@ struct ehea_port *ehea_setup_single_port(struct=
 ehea_adapter *adapter,
=20
 	INIT_WORK(&port->reset_task, ehea_reset_port);
=20
+	ret =3D ehea_broadcast_reg_helper(port, H_REG_BCMC);
+	if (ret) {
+		ret =3D -EIO;
+		goto out_unreg_port;
+	}
+
 	ehea_set_ethtool_ops(dev);
=20
 	ret =3D register_netdev(dev);
 	if (ret) {
 		ehea_error("register_netdev failed. ret=3D%d", ret);
-		goto out_unreg_port;
+		goto out_dereg_bc;
 	}
=20
 	ret =3D ehea_get_jumboframe_status(port, &jumbo);
@@ -2675,6 +2672,9 @@ struct ehea_port *ehea_setup_single_port(struct e=
hea_adapter *adapter,
=20
 	return port;
=20
+out_dereg_bc:
+	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
+
 out_unreg_port:
 	ehea_unregister_port(port);
=20
@@ -2694,6 +2694,7 @@ static void ehea_shutdown_single_port(struct ehea=
_port *port)
 {
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
+	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
 	port->adapter->active_ports--;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index d7a1a58..f926905 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -420,8 +420,18 @@ static phy_interface_t gfar_get_interface(struct n=
et_device *dev)
 	if (ecntrl & ECNTRL_REDUCED_MODE) {
 		if (ecntrl & ECNTRL_REDUCED_MII_MODE)
 			return PHY_INTERFACE_MODE_RMII;
-		else
+		else {
+			phy_interface_t interface =3D priv->einfo->interface;
+
+			/*
+			 * This isn't autodetected right now, so it must
+			 * be set by the device tree or platform code.
+			 */
+			if (interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID)
+				return PHY_INTERFACE_MODE_RGMII_ID;
+
 			return PHY_INTERFACE_MODE_RGMII;
+		}
 	}
=20
 	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT)
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 3d5b423..22a3b3d 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -670,14 +670,10 @@ static void ni5010_set_multicast_list(struct net_=
device *dev)
=20
 	PRINTK2((KERN_DEBUG "%s: entering set_multicast_list\n", dev->name));
=20
-	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI) {
+	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI || dev->mc_list=
) {
 		dev->flags |=3D IFF_PROMISC;
 		outb(RMD_PROMISC, EDLC_RMODE); /* Enable promiscuous mode */
 		PRINTK((KERN_DEBUG "%s: Entering promiscuous mode\n", dev->name));
-	} else if (dev->mc_list) {
-		/* Sorry, multicast not supported */
-		PRINTK((KERN_DEBUG "%s: No multicast, entering broadcast mode\n", de=
v->name));
-		outb(RMD_BROADCAST, EDLC_RMODE);
 	} else {
 		PRINTK((KERN_DEBUG "%s: Entering broadcast mode\n", dev->name));
 		outb(RMD_BROADCAST, EDLC_RMODE);  /* Disable promiscuous mode, use n=
ormal mode */
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 104aab3..ea80e6c 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1582,7 +1582,7 @@ static void ns83820_set_multicast(struct net_devi=
ce *ndev)
 	else
 		and_mask &=3D ~(RFCR_AAU | RFCR_AAM);
=20
-	if (ndev->flags & IFF_ALLMULTI)
+	if (ndev->flags & IFF_ALLMULTI || ndev->mc_count)
 		or_mask |=3D RFCR_AAM;
 	else
 		and_mask &=3D ~RFCR_AAM;
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 596222b..6a53856 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -21,6 +21,10 @@
 /* Vitesse Extended Control Register 1 */
 #define MII_VSC8244_EXT_CON1           0x17
 #define MII_VSC8244_EXTCON1_INIT       0x0000
+#define MII_VSC8244_EXTCON1_TX_SKEW_MASK	0x0c00
+#define MII_VSC8244_EXTCON1_RX_SKEW_MASK	0x0300
+#define MII_VSC8244_EXTCON1_TX_SKEW	0x0800
+#define MII_VSC8244_EXTCON1_RX_SKEW	0x0200
=20
 /* Vitesse Interrupt Mask Register */
 #define MII_VSC8244_IMASK		0x19
@@ -39,7 +43,7 @@
=20
 /* Vitesse Auxiliary Control/Status Register */
 #define MII_VSC8244_AUX_CONSTAT        	0x1c
-#define MII_VSC8244_AUXCONSTAT_INIT    	0x0004
+#define MII_VSC8244_AUXCONSTAT_INIT    	0x0000
 #define MII_VSC8244_AUXCONSTAT_DUPLEX  	0x0020
 #define MII_VSC8244_AUXCONSTAT_SPEED   	0x0018
 #define MII_VSC8244_AUXCONSTAT_GBIT    	0x0010
@@ -51,6 +55,7 @@ MODULE_LICENSE("GPL");
=20
 static int vsc824x_config_init(struct phy_device *phydev)
 {
+	int extcon;
 	int err;
=20
 	err =3D phy_write(phydev, MII_VSC8244_AUX_CONSTAT,
@@ -58,14 +63,34 @@ static int vsc824x_config_init(struct phy_device *p=
hydev)
 	if (err < 0)
 		return err;
=20
-	err =3D phy_write(phydev, MII_VSC8244_EXT_CON1,
-			MII_VSC8244_EXTCON1_INIT);
+	extcon =3D phy_read(phydev, MII_VSC8244_EXT_CON1);
+
+	if (extcon < 0)
+		return err;
+
+	extcon &=3D ~(MII_VSC8244_EXTCON1_TX_SKEW_MASK |
+			MII_VSC8244_EXTCON1_RX_SKEW_MASK);
+
+	if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID)
+		extcon |=3D (MII_VSC8244_EXTCON1_TX_SKEW |
+				MII_VSC8244_EXTCON1_RX_SKEW);
+
+	err =3D phy_write(phydev, MII_VSC8244_EXT_CON1, extcon);
+
 	return err;
 }
=20
 static int vsc824x_ack_interrupt(struct phy_device *phydev)
 {
-	int err =3D phy_read(phydev, MII_VSC8244_ISTAT);
+	int err =3D 0;
+=09
+	/*
+	 * Don't bother to ACK the interrupts if interrupts
+	 * are disabled.  The 824x cannot clear the interrupts
+	 * if they are disabled.
+	 */
+	if (phydev->interrupts =3D=3D PHY_INTERRUPT_ENABLED)
+		err =3D phy_read(phydev, MII_VSC8244_ISTAT);
=20
 	return (err < 0) ? err : 0;
 }
@@ -77,8 +102,19 @@ static int vsc824x_config_intr(struct phy_device *p=
hydev)
 	if (phydev->interrupts =3D=3D PHY_INTERRUPT_ENABLED)
 		err =3D phy_write(phydev, MII_VSC8244_IMASK,
 				MII_VSC8244_IMASK_MASK);
-	else
+	else {
+		/*
+		 * The Vitesse PHY cannot clear the interrupt
+		 * once it has disabled them, so we clear them first
+		 */
+		err =3D phy_read(phydev, MII_VSC8244_ISTAT);
+
+		if (err)
+			return err;
+
 		err =3D phy_write(phydev, MII_VSC8244_IMASK, 0);
+	}
+
 	return err;
 }
=20
diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index 451486b..7dae4d4 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -940,15 +940,14 @@ static void lan_saa9730_set_multicast(struct net_=
device *dev)
 		       CAM_CONTROL_GROUP_ACC | CAM_CONTROL_BROAD_ACC,
 		       &lp->lan_saa9730_regs->CamCtl);
 	} else {
-		if (dev->flags & IFF_ALLMULTI) {
+		if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
 			/* accept all multicast packets */
-			writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
-			       CAM_CONTROL_BROAD_ACC,
-			       &lp->lan_saa9730_regs->CamCtl);
-		} else {
 			/*
 			 * Will handle the multicast stuff later. -carstenl
 			 */
+			writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
+			       CAM_CONTROL_BROAD_ACC,
+			       &lp->lan_saa9730_regs->CamCtl);
 		}
 	}
=20
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 75655ad..7f94ca9 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -626,7 +626,7 @@ static int __devinit tc35815_read_plat_dev_addr(str=
uct net_device *dev)
 	return -ENODEV;
 }
 #else
-static int __devinit tc35815_read_plat_dev_addr(struct device *dev)
+static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev=
)
 {
 	return -ENODEV;
 }
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2=
100.c
index 072ede7..8990585 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -7868,10 +7868,10 @@ static int ipw2100_wx_set_powermode(struct net_=
device *dev,
 		goto done;
 	}
=20
-	if ((mode < 1) || (mode > POWER_MODES))
+	if ((mode < 0) || (mode > POWER_MODES))
 		mode =3D IPW_POWER_AUTO;
=20
-	if (priv->power_mode !=3D mode)
+	if (IPW_POWER_LEVEL(priv->power_mode) !=3D mode)
 		err =3D ipw2100_set_power_mode(priv, mode);
       done:
 	mutex_unlock(&priv->action_mutex);
@@ -7902,7 +7902,7 @@ static int ipw2100_wx_get_powermode(struct net_de=
vice *dev,
 			break;
 		case IPW_POWER_AUTO:
 			snprintf(extra, MAX_POWER_STRING,
-				 "Power save level: %d (Auto)", 0);
+				 "Power save level: %d (Auto)", level);
 			break;
 		default:
 			timeout =3D timeout_duration[level - 1] / 1000;
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2=
200.c
index aa32a97..61497c4 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -70,7 +70,7 @@
 #define VQ
 #endif
=20
-#define IPW2200_VERSION "1.2.0" VK VD VM VP VR VQ
+#define IPW2200_VERSION "1.2.2" VK VD VM VP VR VQ
 #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2200/2915 Network Drive=
r"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
 #define DRV_VERSION     IPW2200_VERSION
@@ -2506,7 +2506,7 @@ static int ipw_send_power_mode(struct ipw_priv *p=
riv, u32 mode)
 		break;
 	}
=20
-	param =3D cpu_to_le32(mode);
+	param =3D cpu_to_le32(param);
 	return ipw_send_cmd_pdu(priv, IPW_CMD_POWER_MODE, sizeof(param),
 				&param);
 }
@@ -9568,6 +9568,7 @@ static int ipw_wx_set_power(struct net_device *de=
v,
 		priv->power_mode =3D IPW_POWER_ENABLED | IPW_POWER_BATTERY;
 	else
 		priv->power_mode =3D IPW_POWER_ENABLED | priv->power_mode;
+
 	err =3D ipw_send_power_mode(priv, IPW_POWER_LEVEL(priv->power_mode));
 	if (err) {
 		IPW_DEBUG_WX("failed setting power mode.\n");
@@ -9604,22 +9605,19 @@ static int ipw_wx_set_powermode(struct net_devi=
ce *dev,
 	struct ipw_priv *priv =3D ieee80211_priv(dev);
 	int mode =3D *(int *)extra;
 	int err;
+
 	mutex_lock(&priv->mutex);
-	if ((mode < 1) || (mode > IPW_POWER_LIMIT)) {
+	if ((mode < 1) || (mode > IPW_POWER_LIMIT))
 		mode =3D IPW_POWER_AC;
-		priv->power_mode =3D mode;
-	} else {
-		priv->power_mode =3D IPW_POWER_ENABLED | mode;
-	}
=20
-	if (priv->power_mode !=3D mode) {
+	if (IPW_POWER_LEVEL(priv->power_mode) !=3D mode) {
 		err =3D ipw_send_power_mode(priv, mode);
-
 		if (err) {
 			IPW_DEBUG_WX("failed setting power mode.\n");
 			mutex_unlock(&priv->mutex);
 			return err;
 		}
+		priv->power_mode =3D IPW_POWER_ENABLED | mode;
 	}
 	mutex_unlock(&priv->mutex);
 	return 0;
@@ -10555,7 +10553,7 @@ static irqreturn_t ipw_isr(int irq, void *data)
 	spin_lock(&priv->irq_lock);
=20
 	if (!(priv->status & STATUS_INT_ENABLED)) {
-		/* Shared IRQ */
+		/* IRQ is disabled */
 		goto none;
 	}
=20
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wirel=
ess/zd1211rw/zd_usb.c
index 28d41a2..a9c339e 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -72,6 +72,8 @@ static struct usb_device_id usb_ids[] =3D {
 	{ USB_DEVICE(0x0586, 0x3413), .driver_info =3D DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info =3D DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0411, 0x00da), .driver_info =3D DEVICE_ZD1211B },
+	{ USB_DEVICE(0x2019, 0x5303), .driver_info =3D DEVICE_ZD1211B },
+	{ USB_DEVICE(0x129b, 0x1667), .driver_info =3D DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info =3D DEVICE_INSTALLER },
 	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info =3D DEVICE_INSTALLER },
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 695741b..1831b19 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -53,6 +53,7 @@ struct gianfar_platform_data {
 	u32	bus_id;
 	u32	phy_id;
 	u8	mac_addr[6];
+	phy_interface_t interface;
 };
=20
 struct gianfar_mdio_data {
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.=
c
index 523a137..465b73d 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -90,14 +90,11 @@ static char *ieee80211_translate_scan(struct ieee80=
211_device *ieee,
 	}
=20
 	/* Add channel and frequency */
+	/* Note : userspace automatically computes channel using iwrange */
 	iwe.cmd =3D SIOCGIWFREQ;
-	iwe.u.freq.m =3D network->channel;
-	iwe.u.freq.e =3D 0;
-	iwe.u.freq.i =3D 0;
-	start =3D iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
-
 	iwe.u.freq.m =3D ieee80211_channel_to_freq(ieee, network->channel);
 	iwe.u.freq.e =3D 6;
+	iwe.u.freq.i =3D 0;
 	start =3D iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
=20
 	/* Add encryption capability */
