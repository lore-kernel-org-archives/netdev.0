From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Mon, 24 Dec 2012 16:33:42 +0100
Message-ID: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:57979 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab2LXP7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 10:59:45 -0500
Received: by mail-ee0-f43.google.com with SMTP id e49so3695545eek.16
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2012 07:59:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCMA is a Broadcom specific bus with devices AKA cores. All recent BCMA
based SoCs have gigabit ethernet provided by the GBit MAC core. This
patch adds driver for such a cores registering itself as a netdev. It
has been tested on a BCM4706 and BCM4718 chipsets.

In the kernel tree there is already b44 driver which has some common
things with bgmac, however there are many differences that has led to
the decision or writing a new driver:
1) GBit MAC cores appear on BCMA bus (not SSB as in case of b44)
2) There is 64bit DMA engine which differs from 32bit one
3) There is no CAM (Content Addressable Memory) in GBit MAC
4) We have 4 TX queues on GBit MAC devices (instead of 1)
5) Many registers have different addresses/values
6) RX header flags are also different

The driver in it's state is functional how, however there is of course
place for improvements:
1) Supporting more net_device_ops
2) SUpporting more ethtool_ops
3) Unaligned addressing in DMA
4) Writing separated PHY driver

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
I've implemented all planned improvements since RFC, applied some
suggested changes, got rid of memory leak and filled _stop and _remove.

I've also done some testing: bringing if up, pinging and if down. After
doing 1000 iterations (and waiting nearly an hour) nothing wrong has
happened.

I didn't receive any extra comments since posting RFC (11 days ago), so
I'm posting it normally (no RFC).

I can see (according to the Documentation/development-process/2.Process=
)
that it's possible to make an special exception for drivers handling=20
previously-unsupported hardware and submit them even out of merge
window. I wonder if this can be applied in this situation? It's a new
driver providing long-awaited support for ethernet core. It finally
makes it possible to support tons of recent Broadcom routers and there
is no way it can cause a regression in bcma code (it only exports one
symbol).

David: what do you think about this? I'd love to see it still in 3.8,
it's a kernel release that brings support for a lot of Broadcom hw part=
s
(SoC itself, NAND, GPIO, watchdog). The only really missing part seems
to be ethernet driver.
---
 drivers/bcma/driver_chipcommon_pmu.c        |    3 +-
 drivers/net/ethernet/broadcom/Kconfig       |    9 +
 drivers/net/ethernet/broadcom/Makefile      |    1 +
 drivers/net/ethernet/broadcom/bgmac.c       | 1390 +++++++++++++++++++=
++++++++
 drivers/net/ethernet/broadcom/bgmac.h       |  443 +++++++++
 include/linux/bcma/bcma_driver_chipcommon.h |    2 +
 6 files changed, 1847 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bgmac.c
 create mode 100644 drivers/net/ethernet/broadcom/bgmac.h

diff --git a/drivers/bcma/driver_chipcommon_pmu.c b/drivers/bcma/driver=
_chipcommon_pmu.c
index c62c788..932b101 100644
--- a/drivers/bcma/driver_chipcommon_pmu.c
+++ b/drivers/bcma/driver_chipcommon_pmu.c
@@ -264,7 +264,7 @@ static u32 bcma_pmu_pll_clock_bcm4706(struct bcma_d=
rv_cc *cc, u32 pll0, u32 m)
 }
=20
 /* query bus clock frequency for PMU-enabled chipcommon */
-static u32 bcma_pmu_get_bus_clock(struct bcma_drv_cc *cc)
+u32 bcma_pmu_get_bus_clock(struct bcma_drv_cc *cc)
 {
 	struct bcma_bus *bus =3D cc->core->bus;
=20
@@ -293,6 +293,7 @@ static u32 bcma_pmu_get_bus_clock(struct bcma_drv_c=
c *cc)
 	}
 	return BCMA_CC_PMU_HT_CLOCK;
 }
+EXPORT_SYMBOL_GPL(bcma_pmu_get_bus_clock);
=20
 /* query cpu clock frequency for PMU-enabled chipcommon */
 u32 bcma_pmu_get_cpu_clock(struct bcma_drv_cc *cc)
diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethern=
et/broadcom/Kconfig
index f552673..42c0913 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -121,4 +121,13 @@ config BNX2X
 	  To compile this driver as a module, choose M here: the module
 	  will be called bnx2x.  This is recommended.
=20
+config BGMAC
+	tristate "BCMA bus GBit core support"
+	depends on BCMA_HOST_SOC && HAS_DMA
+	---help---
+	  This driver supports GBit MAC and BCM4706 GBit MAC cores on BCMA bu=
s.
+	  They can be found on BCM47xx SoCs and provide gigabit ethernet.
+	  In case of using this driver on BCM4706 it's also requires to enabl=
e
+	  BCMA_DRIVER_GMAC_CMN to make it work.
+
 endif # NET_VENDOR_BROADCOM
diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/ether=
net/broadcom/Makefile
index b789605..68efa1a 100644
--- a/drivers/net/ethernet/broadcom/Makefile
+++ b/drivers/net/ethernet/broadcom/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_CNIC) +=3D cnic.o
 obj-$(CONFIG_BNX2X) +=3D bnx2x/
 obj-$(CONFIG_SB1250_MAC) +=3D sb1250-mac.o
 obj-$(CONFIG_TIGON3) +=3D tg3.o
+obj-$(CONFIG_BGMAC) +=3D bgmac.o
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
new file mode 100644
index 0000000..641823f
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -0,0 +1,1390 @@
+/*
+ * Driver for (BCM4706)? GBit MAC core on BCMA bus.
+ *
+ * Copyright (C) 2012 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#include "bgmac.h"
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/etherdevice.h>
+#include <linux/mii.h>
+#include <linux/interrupt.h>
+#include <linux/dma-mapping.h>
+#include <asm/mach-bcm47xx/nvram.h>
+
+static const struct bcma_device_id bgmac_bcma_tbl[] =3D {
+	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_4706_MAC_GBIT, BCMA_ANY_REV, BCMA=
_ANY_CLASS),
+	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_MAC_GBIT, BCMA_ANY_REV, BCMA_ANY_=
CLASS),
+	BCMA_CORETABLE_END
+};
+MODULE_DEVICE_TABLE(bcma, bgmac_bcma_tbl);
+
+static bool bgmac_wait_value(struct bcma_device *core, u16 reg, u32 ma=
sk,
+			     u32 value, int timeout)
+{
+	u32 val;
+	int i;
+
+	for (i =3D 0; i < timeout / 10; i++) {
+		val =3D bcma_read32(core, reg);
+		if ((val & mask) =3D=3D value)
+			return true;
+		udelay(10);
+	}
+	pr_err("Timeout waiting for reg 0x%X\n", reg);
+	return false;
+}
+
+/**************************************************
+ * DMA
+ **************************************************/
+
+static void bgmac_dma_tx_reset(struct bgmac *bgmac, struct bgmac_dma_r=
ing *ring)
+{
+	u32 val;
+	int i;
+
+	if (!ring->mmio_base)
+		return;
+
+	/* Susend DMA TX ring first.
+	 * bgmac_wait_value doesn't support waiting for any of few values, so
+	 * implement whole loop here.
+	 */
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL,
+		    BGMAC_DMA_TX_SUSPEND);
+	for (i =3D 0; i < 10000 / 10; i++) {
+		val =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_STATUS);
+		val &=3D BGMAC_DMA_TX_STAT;
+		if (val =3D=3D BGMAC_DMA_TX_STAT_DISABLED ||
+		    val =3D=3D BGMAC_DMA_TX_STAT_IDLEWAIT ||
+		    val =3D=3D BGMAC_DMA_TX_STAT_STOPPED) {
+			i =3D 0;
+			break;
+		}
+		udelay(10);
+	}
+	if (i)
+		bgmac_err(bgmac, "Timeout suspending DMA TX ring 0x%X (BGMAC_DMA_TX_=
STAT: 0x%08X)\n",
+			  ring->mmio_base, val);
+
+	/* Remove SUSPEND bit */
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL, 0);
+	if (!bgmac_wait_value(bgmac->core,
+			      ring->mmio_base + BGMAC_DMA_TX_STATUS,
+			      BGMAC_DMA_TX_STAT, BGMAC_DMA_TX_STAT_DISABLED,
+			      10000)) {
+		bgmac_warn(bgmac, "DMA TX ring 0x%X wasn't disabled on time, waiting=
 additional 300us\n", ring->mmio_base);
+		udelay(300);
+		val =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_STATUS);
+		if ((val & BGMAC_DMA_TX_STAT) !=3D BGMAC_DMA_TX_STAT_DISABLED)
+			bgmac_err(bgmac, "Reset of DMA TX ring 0x%X failed\n", ring->mmio_b=
ase);
+	}
+}
+
+static void bgmac_dma_tx_enable(struct bgmac *bgmac,
+				struct bgmac_dma_ring *ring)
+{
+	u32 ctl;
+
+	ctl =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL);
+	ctl |=3D BGMAC_DMA_TX_ENABLE;
+	ctl |=3D BGMAC_DMA_TX_PARITY_DISABLE;
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL, ctl);
+}
+
+static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
+				    struct bgmac_dma_ring *ring,
+				    struct sk_buff *skb)
+{
+	struct device *dma_dev =3D bgmac->core->dma_dev;
+	struct bgmac_dma_desc *dma_desc;
+	struct bgmac_slot_info *slot;
+	u32 ctl0, ctl1;
+	int free_slots;
+
+	if (skb->len > BGMAC_DESC_CTL1_LEN) {
+		bgmac_err(bgmac, "Too long skb (%d)\n", skb->len);
+		return NETDEV_TX_BUSY;
+	}
+
+	if (ring->start <=3D ring->end)
+		free_slots =3D ring->start - ring->end + BGMAC_TX_RING_SLOTS;
+	else
+		free_slots =3D ring->start - ring->end;
+	if (free_slots <=3D 1) {
+		bgmac_err(bgmac, "No free slots on ring 0x%X!\n", ring->mmio_base);
+		netif_stop_queue(bgmac->net_dev);
+		return NETDEV_TX_BUSY;
+	}
+
+	slot =3D &ring->slots[ring->end];
+	slot->skb =3D skb;
+	slot->dma_addr =3D dma_map_single(dma_dev, skb->data, skb->len, DMA_T=
O_DEVICE);
+	if (dma_mapping_error(dma_dev, slot->dma_addr)) {
+		bgmac_err(bgmac, "Mapping error of skb on ring 0x%X\n", ring->mmio_b=
ase);
+		return NETDEV_TX_BUSY;
+	}
+
+	ctl0 =3D BGMAC_DESC_CTL0_IOC | BGMAC_DESC_CTL0_SOF | BGMAC_DESC_CTL0_=
EOF;
+	if (ring->end =3D=3D ring->num_slots - 1)
+		ctl0 |=3D BGMAC_DESC_CTL0_EOT;
+	ctl1 =3D skb->len & BGMAC_DESC_CTL1_LEN;
+
+	dma_desc =3D ring->cpu_base;
+	dma_desc +=3D ring->end;
+	dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(slot->dma_addr));
+	dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(slot->dma_addr));
+	dma_desc->ctl0 =3D cpu_to_le32(ctl0);
+	dma_desc->ctl1 =3D cpu_to_le32(ctl1);
+
+	wmb();
+
+	/* Increase ring->end to point empty slot. We tell hardware the first
+	 * slot it shold *not* read.
+	 */
+	if (++ring->end >=3D BGMAC_TX_RING_SLOTS)
+		ring->end =3D 0;
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_INDEX,
+		    ring->end * sizeof(struct bgmac_dma_desc));
+
+	return NETDEV_TX_OK;
+}
+
+/* Free transmitted packets */
+static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ri=
ng *ring)
+{
+	struct device *dma_dev =3D bgmac->core->dma_dev;
+	struct bgmac_dma_desc *dma_desc;
+	struct bgmac_slot_info *slot;
+	int empty_slot;
+
+	/* The last slot that hardware didn't consume yet */
+	empty_slot =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_STATU=
S);
+	empty_slot &=3D BGMAC_DMA_TX_STATDPTR;
+	empty_slot /=3D sizeof(struct bgmac_dma_desc);
+
+	while (ring->start !=3D empty_slot) {
+		/* Set pointers */
+		dma_desc =3D ring->cpu_base;
+		dma_desc +=3D ring->start;
+		slot =3D &ring->slots[ring->start];
+
+		if (slot->skb) {
+			/* Unmap no longer used buffer */
+			dma_unmap_single(dma_dev, slot->dma_addr,
+					 slot->skb->len, DMA_TO_DEVICE);
+			slot->dma_addr =3D 0;
+
+			/* Free memory! :) */
+			dev_kfree_skb_any(slot->skb);
+			slot->skb =3D NULL;
+		} else {
+			bgmac_err(bgmac, "Hardware reported transmission for empty TX ring =
slot %d! End of ring: %d", ring->start, ring->end);
+		}
+
+		if (++ring->start >=3D BGMAC_TX_RING_SLOTS)
+			ring->start =3D 0;
+	}
+}
+
+static void bgmac_dma_rx_reset(struct bgmac *bgmac, struct bgmac_dma_r=
ing *ring)
+{
+	if (!ring->mmio_base)
+		return;
+
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_CTL, 0);
+	if (!bgmac_wait_value(bgmac->core,
+			      ring->mmio_base + BGMAC_DMA_RX_STATUS,
+			      BGMAC_DMA_RX_STAT, BGMAC_DMA_RX_STAT_DISABLED,
+			      10000))
+		bgmac_err(bgmac, "Reset of ring 0x%X RX failed\n", ring->mmio_base);
+}
+
+static void bgmac_dma_rx_enable(struct bgmac *bgmac,
+				struct bgmac_dma_ring *ring)
+{
+	u32 ctl;
+
+	ctl =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_RX_CTL);
+	ctl &=3D BGMAC_DMA_RX_ADDREXT_MASK;
+	ctl |=3D BGMAC_DMA_RX_ENABLE;
+	ctl |=3D BGMAC_DMA_RX_PARITY_DISABLE;
+	ctl |=3D BGMAC_DMA_RX_OVERFLOW_CONT;
+	ctl |=3D BGMAC_RX_FRAME_OFFSET << BGMAC_DMA_RX_FRAME_OFFSET_SHIFT;
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_CTL, ctl);
+}
+
+static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
+				     struct bgmac_slot_info *slot)
+{
+	struct device *dma_dev =3D bgmac->core->dma_dev;
+	struct bgmac_rx_header *rx;
+
+	/* Alloc skb */
+	slot->skb =3D netdev_alloc_skb(bgmac->net_dev, BGMAC_RX_BUF_SIZE);
+	if (!slot->skb) {
+		bgmac_err(bgmac, "Allocation of skb failed!\n");
+		return -ENOMEM;
+	}
+
+	/* Poison - if everything goes fine, hardware will overwrite it */
+	rx =3D (struct bgmac_rx_header *)slot->skb->data;
+	rx->len =3D cpu_to_le16(0xdead);
+	rx->flags =3D cpu_to_le16(0xbeef);
+
+	/* Map skb for the DMA */
+	slot->dma_addr =3D dma_map_single(dma_dev, slot->skb->data,
+					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+	if (dma_mapping_error(dma_dev, slot->dma_addr)) {
+		bgmac_err(bgmac, "DMA mapping error\n");
+		return -ENOMEM;
+	}
+	if (slot->dma_addr & 0xC0000000)
+		bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need =
translation trick\n");
+
+	return 0;
+}
+
+static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_rin=
g *ring,
+			     int weight)
+{
+	struct device *dma_dev =3D bgmac->core->dma_dev;
+	struct bgmac_dma_desc *dma_desc;
+	struct bgmac_slot_info *slot;
+	struct sk_buff *skb, *new_skb;
+	struct bgmac_rx_header *rx;
+	u32 end_slot;
+	u16 len, flags;
+	int handled =3D 0;
+
+	end_slot =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_RX_STATUS)=
;
+	end_slot &=3D BGMAC_DMA_RX_STATDPTR;
+	end_slot /=3D sizeof(struct bgmac_dma_desc);
+
+	ring->end =3D end_slot;
+
+	while (ring->start !=3D ring->end) {
+		/* Set pointers */
+		dma_desc =3D ring->cpu_base;
+		dma_desc +=3D ring->start;
+		slot =3D &ring->slots[ring->start];
+		skb =3D slot->skb;
+
+		/* Unmap buffer to make it accessible to the CPU */
+		dma_sync_single_for_cpu(dma_dev, slot->dma_addr,
+					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+
+		/* Get info from the header */
+		rx =3D (struct bgmac_rx_header *)skb->data;
+		len =3D le16_to_cpu(rx->len);
+		flags =3D le16_to_cpu(rx->flags);
+
+		/* Check for poison and drop or pass the packet */
+		if (len =3D=3D 0xdead && flags =3D=3D 0xbeef) {
+			bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n", =
ring->start);
+		} else {
+			new_skb =3D netdev_alloc_skb(bgmac->net_dev, len);
+			if (new_skb) {
+				skb_put(new_skb, len);
+				skb_copy_from_linear_data_offset(skb, BGMAC_RX_FRAME_OFFSET,
+								 new_skb->data, len);
+				new_skb->protocol =3D
+					eth_type_trans(new_skb, bgmac->net_dev);
+				netif_receive_skb(new_skb);
+				handled++;
+			} else {
+				bgmac_err(bgmac, "Allocation of skb for copying packet failed!\n")=
;
+			}
+
+			/* Poison the old skb */
+			rx->len =3D cpu_to_le16(0xdead);
+			rx->flags =3D cpu_to_le16(0xbeef);
+		}
+
+		/* Make it back accessible to the hardware */
+		dma_sync_single_for_device(dma_dev, slot->dma_addr,
+					   BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+
+		if (++ring->start >=3D BGMAC_RX_RING_SLOTS)
+			ring->start =3D 0;
+
+		if (handled >=3D weight) /* Should never be greater */
+			break;
+	}
+
+	return handled;
+}
+
+/* Does ring support unaligned addressing? */
+static bool bgmac_dma_unaligned(struct bgmac *bgmac,
+				struct bgmac_dma_ring *ring)
+{
+	if (ring->tx) {
+		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_RINGLO,
+			    0xff0);
+		if (bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_RINGLO))
+			return true;
+	} else {
+		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGLO,
+			    0xff0);
+		if (bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGLO))
+			return true;
+	}
+	return false;
+}
+
+static void bgmac_dma_ring_free(struct bgmac *bgmac,
+				struct bgmac_dma_ring *ring)
+{
+	struct device *dma_dev =3D bgmac->core->dma_dev;
+	struct bgmac_slot_info *slot;
+	int size;
+	int i;
+
+	for (i =3D 0; i < ring->num_slots; i++) {
+		slot =3D &ring->slots[i];
+		if (slot->skb) {
+			if (slot->dma_addr)
+				dma_unmap_single(dma_dev, slot->dma_addr,
+						 slot->skb->len, DMA_TO_DEVICE);
+			dev_kfree_skb_any(slot->skb);
+		}
+	}
+
+	if (ring->cpu_base) {
+		/* Free ring of descriptors */
+		size =3D ring->num_slots * sizeof(struct bgmac_dma_desc);
+		dma_free_coherent(dma_dev, size, ring->cpu_base,
+				  ring->dma_base);
+	}
+}
+
+static void bgmac_dma_free(struct bgmac *bgmac)
+{
+	int i;
+
+	for (i =3D 0; i < BGMAC_MAX_TX_RINGS; i++)
+		bgmac_dma_ring_free(bgmac, &bgmac->tx_ring[i]);
+	for (i =3D 0; i < BGMAC_MAX_RX_RINGS; i++)
+		bgmac_dma_ring_free(bgmac, &bgmac->rx_ring[i]);
+}
+
+static int bgmac_dma_alloc(struct bgmac *bgmac)
+{
+	struct device *dma_dev =3D bgmac->core->dma_dev;
+	struct bgmac_dma_ring *ring;
+	u16 ring_base[] =3D { BGMAC_DMA_BASE0, BGMAC_DMA_BASE1, BGMAC_DMA_BAS=
E2,
+			    BGMAC_DMA_BASE3, };
+	int size; /* ring size: different for Tx and Rx */
+	int err;
+	int i;
+
+	BUILD_BUG_ON(BGMAC_MAX_TX_RINGS > ARRAY_SIZE(ring_base));
+	BUILD_BUG_ON(BGMAC_MAX_RX_RINGS > ARRAY_SIZE(ring_base));
+
+	if (!(bcma_aread32(bgmac->core, BCMA_IOST) & BCMA_IOST_DMA64)) {
+		bgmac_err(bgmac, "Core does not report 64-bit DMA\n");
+		return -ENOTSUPP;
+	}
+
+	for (i =3D 0; i < BGMAC_MAX_TX_RINGS; i++) {
+		ring =3D &bgmac->tx_ring[i];
+		ring->tx =3D true;
+		ring->num_slots =3D BGMAC_TX_RING_SLOTS;
+		ring->mmio_base =3D ring_base[i];
+		if (bgmac_dma_unaligned(bgmac, ring))
+			bgmac_warn(bgmac, "TX on ring 0x%X supports unaligned addressing bu=
t this feature is not implemented\n", ring->mmio_base);
+
+		/* Alloc ring of descriptors */
+		size =3D ring->num_slots * sizeof(struct bgmac_dma_desc);
+		ring->cpu_base =3D dma_zalloc_coherent(dma_dev, size,
+						     &(ring->dma_base),
+						     GFP_KERNEL);
+		if (!ring->cpu_base) {
+			bgmac_err(bgmac, "Allocation of TX ring 0x%X failed\n", ring->mmio_=
base);
+			goto err_dma_free;
+		}
+		if (ring->dma_base & 0xC0000000)
+			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need=
 translation trick\n");
+
+		/* No need to alloc TX slots yet */
+	}
+
+	for (i =3D 0; i < BGMAC_MAX_RX_RINGS; i++) {
+		ring =3D &bgmac->rx_ring[i];
+		ring->tx =3D false;
+		ring->num_slots =3D BGMAC_RX_RING_SLOTS;
+		ring->mmio_base =3D ring_base[i];
+		if (bgmac_dma_unaligned(bgmac, ring))
+			bgmac_warn(bgmac, "RX on ring 0x%X supports unaligned addressing bu=
t this feature is not implemented\n", ring->mmio_base);
+
+		/* Alloc ring of descriptors */
+		size =3D ring->num_slots * sizeof(struct bgmac_dma_desc);
+		ring->cpu_base =3D dma_zalloc_coherent(dma_dev, size,
+						     &(ring->dma_base),
+						     GFP_KERNEL);
+		if (!ring->cpu_base) {
+			bgmac_err(bgmac, "Allocation of RX ring 0x%X failed\n", ring->mmio_=
base);
+			err =3D -ENOMEM;
+			goto err_dma_free;
+		}
+		if (ring->dma_base & 0xC0000000)
+			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need=
 translation trick\n");
+
+		/* Alloc RX slots */
+		for (i =3D 0; i < ring->num_slots; i++) {
+			err =3D bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[i]);
+			if (err) {
+				bgmac_err(bgmac, "Can't allocate skb for slot in RX ring\n");
+				goto err_dma_free;
+			}
+		}
+	}
+
+	return 0;
+
+err_dma_free:
+	bgmac_dma_free(bgmac);
+	return -ENOMEM;
+}
+
+static void bgmac_dma_init(struct bgmac *bgmac)
+{
+	struct bgmac_dma_ring *ring;
+	struct bgmac_dma_desc *dma_desc;
+	u32 ctl0, ctl1;
+	int i;
+
+	for (i =3D 0; i < BGMAC_MAX_TX_RINGS; i++) {
+		ring =3D &bgmac->tx_ring[i];
+
+		/* We don't implement unaligned addressing, so enable first */
+		bgmac_dma_tx_enable(bgmac, ring);
+		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_RINGLO,
+			    lower_32_bits(ring->dma_base));
+		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_RINGHI,
+			    upper_32_bits(ring->dma_base));
+
+		ring->start =3D 0;
+		ring->end =3D 0;	/* Points the slot that should *not* be read */
+	}
+
+	for (i =3D 0; i < BGMAC_MAX_RX_RINGS; i++) {
+		ring =3D &bgmac->rx_ring[i];
+
+		/* We don't implement unaligned addressing, so enable first */
+		bgmac_dma_rx_enable(bgmac, ring);
+		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGLO,
+			    lower_32_bits(ring->dma_base));
+		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGHI,
+			    upper_32_bits(ring->dma_base));
+
+		for (i =3D 0, dma_desc =3D ring->cpu_base; i < ring->num_slots;
+		     i++, dma_desc++) {
+			ctl0 =3D ctl1 =3D 0;
+
+			if (i =3D=3D ring->num_slots - 1)
+				ctl0 |=3D BGMAC_DESC_CTL0_EOT;
+			ctl1 |=3D BGMAC_RX_BUF_SIZE & BGMAC_DESC_CTL1_LEN;
+			/* Is there any BGMAC device that requires extension? */
+			/* ctl1 |=3D (addrext << B43_DMA64_DCTL1_ADDREXT_SHIFT) &
+			 * B43_DMA64_DCTL1_ADDREXT_MASK;
+			 */
+
+			dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(ring->slots[i].dma=
_addr));
+			dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(ring->slots[i].dm=
a_addr));
+			dma_desc->ctl0 =3D cpu_to_le32(ctl0);
+			dma_desc->ctl1 =3D cpu_to_le32(ctl1);
+		}
+
+		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
+			    ring->num_slots * sizeof(struct bgmac_dma_desc));
+
+		ring->start =3D 0;
+		ring->end =3D 0;
+	}
+}
+
+/**************************************************
+ * PHY ops
+ **************************************************/
+
+u16 bgmac_phy_read(struct bgmac *bgmac, u8 phyaddr, u8 reg)
+{
+	struct bcma_device *core;
+	u16 phy_access_addr;
+	u16 phy_ctl_addr;
+	u32 tmp;
+
+	BUILD_BUG_ON(BGMAC_PA_DATA_MASK !=3D BCMA_GMAC_CMN_PA_DATA_MASK);
+	BUILD_BUG_ON(BGMAC_PA_ADDR_MASK !=3D BCMA_GMAC_CMN_PA_ADDR_MASK);
+	BUILD_BUG_ON(BGMAC_PA_ADDR_SHIFT !=3D BCMA_GMAC_CMN_PA_ADDR_SHIFT);
+	BUILD_BUG_ON(BGMAC_PA_REG_MASK !=3D BCMA_GMAC_CMN_PA_REG_MASK);
+	BUILD_BUG_ON(BGMAC_PA_REG_SHIFT !=3D BCMA_GMAC_CMN_PA_REG_SHIFT);
+	BUILD_BUG_ON(BGMAC_PA_WRITE !=3D BCMA_GMAC_CMN_PA_WRITE);
+	BUILD_BUG_ON(BGMAC_PA_START !=3D BCMA_GMAC_CMN_PA_START);
+	BUILD_BUG_ON(BGMAC_PC_EPA_MASK !=3D BCMA_GMAC_CMN_PC_EPA_MASK);
+	BUILD_BUG_ON(BGMAC_PC_MCT_MASK !=3D BCMA_GMAC_CMN_PC_MCT_MASK);
+	BUILD_BUG_ON(BGMAC_PC_MCT_SHIFT !=3D BCMA_GMAC_CMN_PC_MCT_SHIFT);
+	BUILD_BUG_ON(BGMAC_PC_MTE !=3D BCMA_GMAC_CMN_PC_MTE);
+
+	if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
+		core =3D bgmac->core->bus->drv_gmac_cmn.core;
+		phy_access_addr =3D BCMA_GMAC_CMN_PHY_ACCESS;
+		phy_ctl_addr =3D BCMA_GMAC_CMN_PHY_CTL;
+	} else {
+		core =3D bgmac->core;
+		phy_access_addr =3D BGMAC_PHY_ACCESS;
+		phy_ctl_addr =3D BGMAC_PHY_CNTL;
+	}
+
+	tmp =3D bcma_read32(core, phy_ctl_addr);
+	tmp &=3D ~BGMAC_PC_EPA_MASK;
+	tmp |=3D phyaddr;
+	bcma_write32(core, phy_ctl_addr, tmp);
+
+	tmp =3D BGMAC_PA_START;
+	tmp |=3D phyaddr << BGMAC_PA_ADDR_SHIFT;
+	tmp |=3D reg << BGMAC_PA_REG_SHIFT;
+	bcma_write32(core, phy_access_addr, tmp);
+
+	if (!bgmac_wait_value(core, phy_access_addr, BGMAC_PA_START, 0, 1000)=
) {
+		bgmac_err(bgmac, "Reading PHY %d register 0x%X failed\n",
+			  phyaddr, reg);
+		return 0xffff;
+	}
+
+	return bcma_read32(core, phy_access_addr) & BGMAC_PA_DATA_MASK;
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphywr */
+void bgmac_phy_write(struct bgmac *bgmac, u8 phyaddr, u8 reg, u16 valu=
e)
+{
+	struct bcma_device *core;
+	u16 phy_access_addr;
+	u16 phy_ctl_addr;
+	u32 tmp;
+
+	if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
+		core =3D bgmac->core->bus->drv_gmac_cmn.core;
+		phy_access_addr =3D BCMA_GMAC_CMN_PHY_ACCESS;
+		phy_ctl_addr =3D BCMA_GMAC_CMN_PHY_CTL;
+	} else {
+		core =3D bgmac->core;
+		phy_access_addr =3D BGMAC_PHY_ACCESS;
+		phy_ctl_addr =3D BGMAC_PHY_CNTL;
+	}
+
+	tmp =3D bcma_read32(core, phy_ctl_addr);
+	tmp &=3D ~BGMAC_PC_EPA_MASK;
+	tmp |=3D phyaddr;
+	bcma_write32(core, phy_ctl_addr, tmp);
+
+	bgmac_write(bgmac, BGMAC_INT_STATUS, BGMAC_IS_MDIO);
+	if (bgmac_read(bgmac, BGMAC_INT_STATUS) & BGMAC_IS_MDIO)
+		bgmac_warn(bgmac, "Error setting MDIO int\n");
+
+	tmp =3D BGMAC_PA_START;
+	tmp |=3D BGMAC_PA_WRITE;
+	tmp |=3D phyaddr << BGMAC_PA_ADDR_SHIFT;
+	tmp |=3D reg << BGMAC_PA_REG_SHIFT;
+	tmp |=3D value;
+	bcma_write32(core, phy_access_addr, tmp);
+
+	if (!bgmac_wait_value(core, phy_access_addr, BGMAC_PA_START, 0, 1000)=
)
+		bgmac_err(bgmac, "Writing to PHY %d register 0x%X failed\n",
+			  phyaddr, reg);
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyforce */
+static void bgmac_phy_force(struct bgmac *bgmac)
+{
+	u16 ctl;
+	u16 mask =3D ~(BGMAC_PHY_CTL_SPEED | BGMAC_PHY_CTL_SPEED_MSB |
+		     BGMAC_PHY_CTL_ANENAB | BGMAC_PHY_CTL_DUPLEX);
+
+	if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
+		return;
+
+	if (bgmac->autoneg)
+		return;
+
+	ctl =3D bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL);
+	ctl &=3D mask;
+	if (bgmac->full_duplex)
+		ctl |=3D BGMAC_PHY_CTL_DUPLEX;
+	if (bgmac->speed =3D=3D BGMAC_SPEED_100)
+		ctl |=3D BGMAC_PHY_CTL_SPEED_100;
+	else if (bgmac->speed =3D=3D BGMAC_SPEED_1000)
+		ctl |=3D BGMAC_PHY_CTL_SPEED_1000;
+	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL, ctl);
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyadvertise */
+static void bgmac_phy_advertise(struct bgmac *bgmac)
+{
+	u16 adv;
+
+	if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
+		return;
+
+	if (!bgmac->autoneg)
+		return;
+
+	/* Adv selected 10/100 speeds */
+	adv =3D bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV);
+	adv &=3D ~(BGMAC_PHY_ADV_10HALF | BGMAC_PHY_ADV_10FULL |
+		 BGMAC_PHY_ADV_100HALF | BGMAC_PHY_ADV_100FULL);
+	if (!bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_10)
+		adv |=3D BGMAC_PHY_ADV_10HALF;
+	if (!bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_100)
+		adv |=3D BGMAC_PHY_ADV_100HALF;
+	if (bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_10)
+		adv |=3D BGMAC_PHY_ADV_10FULL;
+	if (bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_100)
+		adv |=3D BGMAC_PHY_ADV_100FULL;
+	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV, adv);
+
+	/* Adv selected 1000 speeds */
+	adv =3D bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV2);
+	adv &=3D ~(BGMAC_PHY_ADV2_1000HALF | BGMAC_PHY_ADV2_1000FULL);
+	if (!bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_1000)
+		adv |=3D BGMAC_PHY_ADV2_1000HALF;
+	if (bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_1000)
+		adv |=3D BGMAC_PHY_ADV2_1000FULL;
+	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV2, adv);
+
+	/* Restart */
+	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL,
+			bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL) |
+			BGMAC_PHY_CTL_RESTART);
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
+static void bgmac_phy_init(struct bgmac *bgmac)
+{
+	struct bcma_chipinfo *ci =3D &bgmac->core->bus->chipinfo;
+	struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
+	u8 i;
+
+	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5356) {
+		for (i =3D 0; i < 5; i++) {
+			bgmac_phy_write(bgmac, i, 0x1f, 0x008b);
+			bgmac_phy_write(bgmac, i, 0x15, 0x0100);
+			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
+			bgmac_phy_write(bgmac, i, 0x12, 0x2aaa);
+			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
+		}
+	}
+	if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg !=3D 10) ||
+	    (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg !=3D 10) ||
+	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg !=3D 9)) {
+		bcma_chipco_chipctl_maskset(cc, 2, ~0xc0000000, 0);
+		bcma_chipco_chipctl_maskset(cc, 4, ~0x80000000, 0);
+		for (i =3D 0; i < 5; i++) {
+			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
+			bgmac_phy_write(bgmac, i, 0x16, 0x5284);
+			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
+			bgmac_phy_write(bgmac, i, 0x17, 0x0010);
+			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
+			bgmac_phy_write(bgmac, i, 0x16, 0x5296);
+			bgmac_phy_write(bgmac, i, 0x17, 0x1073);
+			bgmac_phy_write(bgmac, i, 0x17, 0x9073);
+			bgmac_phy_write(bgmac, i, 0x16, 0x52b6);
+			bgmac_phy_write(bgmac, i, 0x17, 0x9273);
+			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
+		}
+	}
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyreset */
+static void bgmac_phy_reset(struct bgmac *bgmac)
+{
+	if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
+		return;
+
+	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL,
+			BGMAC_PHY_CTL_RESET);
+	udelay(100);
+	if (bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL) &
+	    BGMAC_PHY_CTL_RESET)
+		bgmac_err(bgmac, "PHY reset failed\n");
+	bgmac_phy_init(bgmac);
+}
+
+/**************************************************
+ * Chip ops
+ **************************************************/
+
+/* TODO: can we just drop @force? Can we don't reset MAC at all if the=
re is
+ * nothing to change? Try if after stabilizng driver.
+ */
+static void bgmac_cmdcfg_maskset(struct bgmac *bgmac, u32 mask, u32 se=
t,
+				 bool force)
+{
+	u32 cmdcfg =3D bgmac_read(bgmac, BGMAC_CMDCFG);
+	u32 new_val =3D (cmdcfg & mask) | set;
+
+	bgmac_set(bgmac, BGMAC_CMDCFG, BGMAC_CMDCFG_SR);
+	udelay(2);
+
+	if (new_val !=3D cmdcfg || force)
+		bgmac_write(bgmac, BGMAC_CMDCFG, new_val);
+
+	bgmac_mask(bgmac, BGMAC_CMDCFG, ~BGMAC_CMDCFG_SR);
+	udelay(2);
+}
+
+static void bgmac_chip_stats_update(struct bgmac *bgmac)
+{
+	int i;
+
+	if (bgmac->core->id.id !=3D BCMA_CORE_4706_MAC_GBIT) {
+		for (i =3D 0; i < BGMAC_NUM_MIB_TX_REGS; i++)
+			bgmac->mib_tx_regs[i] =3D
+				bgmac_read(bgmac,
+					   BGMAC_TX_GOOD_OCTETS + (i * 4));
+		for (i =3D 0; i < BGMAC_NUM_MIB_RX_REGS; i++)
+			bgmac->mib_rx_regs[i] =3D
+				bgmac_read(bgmac,
+					   BGMAC_RX_GOOD_OCTETS + (i * 4));
+	}
+
+	/* TODO: what else? how to handle BCM4706? Specs are needed */
+}
+
+static void bgmac_clear_mib(struct bgmac *bgmac)
+{
+	int i;
+
+	if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT)
+		return;
+
+	bgmac_set(bgmac, BGMAC_DEV_CTL, BGMAC_DC_MROR);
+	for (i =3D 0; i < BGMAC_NUM_MIB_TX_REGS; i++)
+		bgmac_read(bgmac, BGMAC_TX_GOOD_OCTETS + (i * 4));
+	for (i =3D 0; i < BGMAC_NUM_MIB_RX_REGS; i++)
+		bgmac_read(bgmac, BGMAC_RX_GOOD_OCTETS + (i * 4));
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_speed */
+static void bgmac_speed(struct bgmac *bgmac, int speed)
+{
+	u32 mask =3D ~(BGMAC_CMDCFG_ES_MASK | BGMAC_CMDCFG_HD);
+	u32 set =3D 0;
+
+	if (speed & BGMAC_SPEED_10)
+		set |=3D BGMAC_CMDCFG_ES_10;
+	if (speed & BGMAC_SPEED_100)
+		set |=3D BGMAC_CMDCFG_ES_100;
+	if (speed & BGMAC_SPEED_1000)
+		set |=3D BGMAC_CMDCFG_ES_1000;
+	if (!bgmac->full_duplex)
+		set |=3D BGMAC_CMDCFG_HD;
+	bgmac_cmdcfg_maskset(bgmac, mask, set, true);
+}
+
+static void bgmac_miiconfig(struct bgmac *bgmac)
+{
+	u8 imode =3D (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK)=
 >>
+			BGMAC_DS_MM_SHIFT;
+	if (imode =3D=3D 0 || imode =3D=3D 1) {
+		if (bgmac->autoneg)
+			bgmac_speed(bgmac, BGMAC_SPEED_100);
+		else
+			bgmac_speed(bgmac, bgmac->speed);
+	}
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipreset */
+static void bgmac_chip_reset(struct bgmac *bgmac)
+{
+	struct bcma_device *core =3D bgmac->core;
+	struct bcma_bus *bus =3D core->bus;
+	struct bcma_chipinfo *ci =3D &bus->chipinfo;
+	u32 flags =3D 0;
+	u32 iost;
+	int i;
+
+	if (bcma_core_is_enabled(core)) {
+		if (!bgmac->stats_grabbed) {
+			bgmac_chip_stats_update(bgmac);
+			bgmac->stats_grabbed =3D true;
+		}
+
+		for (i =3D 0; i < BGMAC_MAX_TX_RINGS; i++)
+			bgmac_dma_tx_reset(bgmac, &bgmac->tx_ring[i]);
+
+		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_ML, false);
+		udelay(1);
+
+		for (i =3D 0; i < BGMAC_MAX_RX_RINGS; i++)
+			bgmac_dma_rx_reset(bgmac, &bgmac->rx_ring[i]);
+
+		/* TODO: Clear software multicast filter list */
+	}
+
+	iost =3D bcma_aread32(core, BCMA_IOST);
+	if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg =3D=3D 10) ||
+	    (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg =3D=3D 10) ||
+	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg =3D=3D 9))
+		iost &=3D ~BGMAC_BCMA_IOST_ATTACHED;
+
+	if (iost & BGMAC_BCMA_IOST_ATTACHED) {
+		flags =3D BGMAC_BCMA_IOCTL_SW_CLKEN;
+		if (!bgmac->has_robosw)
+			flags |=3D BGMAC_BCMA_IOCTL_SW_RESET;
+	}
+
+	bcma_core_enable(core, flags);
+
+	if (core->id.rev > 2) {
+		bgmac_set(bgmac, BCMA_CLKCTLST, 1 << 8);
+		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST, 1 << 24, 1 << 24,
+				 1000);
+	}
+
+	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 || ci->id =3D=3D BCMA_CHIP_ID_=
BCM4749 ||
+	    ci->id =3D=3D BCMA_CHIP_ID_BCM53572) {
+		struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
+		u8 et_swtype =3D 0;
+		u8 sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHY |
+			     BGMAC_CHIPCTL_1_IF_TYPE_RMII;
+		char buf[2];
+		if (nvram_getenv("et_swtype", buf, 1) > 0) {
+			if (kstrtou8(buf, 0, &et_swtype))
+				bgmac_err(bgmac, "Failed to parse et_swtype (%s)\n", buf);
+			et_swtype &=3D 0x0f;
+			et_swtype <<=3D 4;
+			sw_type =3D et_swtype;
+		} else if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg =3D=3D 9) {
+			sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII;
+		} else if (0) {
+			/* TODO */
+		}
+		bcma_chipco_chipctl_maskset(cc, 1,
+					    ~(BGMAC_CHIPCTL_1_IF_TYPE_MASK |
+					      BGMAC_CHIPCTL_1_SW_TYPE_MASK),
+					    sw_type);
+	}
+
+	if (iost & BGMAC_BCMA_IOST_ATTACHED && !bgmac->has_robosw)
+		bcma_awrite32(core, BCMA_IOCTL,
+			      bcma_aread32(core, BCMA_IOCTL) &
+			      ~BGMAC_BCMA_IOCTL_SW_RESET);
+
+	/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_reset
+	 * Specs don't say about using BGMAC_CMDCFG_SR, but in this routine
+	 * BGMAC_CMDCFG is read _after_ putting chip in a reset. So it has to
+	 * be keps until taking MAC out of the reset.
+	 */
+	bgmac_cmdcfg_maskset(bgmac,
+			     ~(BGMAC_CMDCFG_TE |
+			       BGMAC_CMDCFG_RE |
+			       BGMAC_CMDCFG_RPI |
+			       BGMAC_CMDCFG_TAI |
+			       BGMAC_CMDCFG_HD |
+			       BGMAC_CMDCFG_ML |
+			       BGMAC_CMDCFG_CFE |
+			       BGMAC_CMDCFG_RL |
+			       BGMAC_CMDCFG_RED |
+			       BGMAC_CMDCFG_PE |
+			       BGMAC_CMDCFG_TPI |
+			       BGMAC_CMDCFG_PAD_EN |
+			       BGMAC_CMDCFG_PF),
+			     BGMAC_CMDCFG_PROM |
+			     BGMAC_CMDCFG_NLC |
+			     BGMAC_CMDCFG_CFE |
+			     BGMAC_CMDCFG_SR,
+			     false);
+
+	bgmac_clear_mib(bgmac);
+	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT)
+		bcma_maskset32(bgmac->cmn, BCMA_GMAC_CMN_PHY_CTL, ~0,
+			       BCMA_GMAC_CMN_PC_MTE);
+	else
+		bgmac_set(bgmac, BGMAC_PHY_CNTL, BGMAC_PC_MTE);
+	bgmac_miiconfig(bgmac);
+	bgmac_phy_init(bgmac);
+
+	bgmac->int_status =3D 0;
+}
+
+static void bgmac_chip_intrs_on(struct bgmac *bgmac)
+{
+	bgmac_write(bgmac, BGMAC_INT_MASK, bgmac->int_mask);
+}
+
+static void bgmac_chip_intrs_off(struct bgmac *bgmac)
+{
+	bgmac_write(bgmac, BGMAC_INT_MASK, 0);
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_enable */
+static void bgmac_enable(struct bgmac *bgmac)
+{
+	struct bcma_chipinfo *ci =3D &bgmac->core->bus->chipinfo;
+	u32 cmdcfg;
+	u32 mode;
+	u32 rxq_ctl;
+	u32 fl_ctl;
+	u16 bp_clk;
+	u8 mdp;
+
+	cmdcfg =3D bgmac_read(bgmac, BGMAC_CMDCFG);
+	bgmac_cmdcfg_maskset(bgmac, ~(BGMAC_CMDCFG_TE | BGMAC_CMDCFG_RE),
+			     BGMAC_CMDCFG_SR, true);
+	udelay(2);
+	cmdcfg |=3D BGMAC_CMDCFG_TE | BGMAC_CMDCFG_RE;
+	bgmac_write(bgmac, BGMAC_CMDCFG, cmdcfg);
+
+	mode =3D (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK) >>
+		BGMAC_DS_MM_SHIFT;
+	if (ci->id !=3D BCMA_CHIP_ID_BCM47162 || mode !=3D 0)
+		bgmac_set(bgmac, BCMA_CLKCTLST, BCMA_CLKCTLST_FORCEHT);
+	if (ci->id =3D=3D BCMA_CHIP_ID_BCM47162 && mode =3D=3D 2)
+		bcma_chipco_chipctl_maskset(&bgmac->core->bus->drv_cc, 1, ~0,
+					    BGMAC_CHIPCTL_1_RXC_DLL_BYPASS);
+
+	switch (ci->id) {
+	case BCMA_CHIP_ID_BCM5357:
+	case BCMA_CHIP_ID_BCM4749:
+	case BCMA_CHIP_ID_BCM53572:
+	case BCMA_CHIP_ID_BCM4716:
+	case BCMA_CHIP_ID_BCM47162:
+		fl_ctl =3D 0x03cb04cb;
+		if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 ||
+		    ci->id =3D=3D BCMA_CHIP_ID_BCM4749 ||
+		    ci->id =3D=3D BCMA_CHIP_ID_BCM53572)
+			fl_ctl =3D 0x2300e1;
+		bgmac_write(bgmac, BGMAC_FLOW_CTL_THRESH, fl_ctl);
+		bgmac_write(bgmac, BGMAC_PAUSE_CTL, 0x27fff);
+		break;
+	}
+
+	rxq_ctl =3D bgmac_read(bgmac, BGMAC_RXQ_CTL);
+	rxq_ctl &=3D ~BGMAC_RXQ_CTL_MDP_MASK;
+	bp_clk =3D bcma_pmu_get_bus_clock(&bgmac->core->bus->drv_cc) / 100000=
0;
+	mdp =3D (bp_clk * 128 / 1000) - 3;
+	rxq_ctl |=3D (mdp << BGMAC_RXQ_CTL_MDP_SHIFT);
+	bgmac_write(bgmac, BGMAC_RXQ_CTL, rxq_ctl);
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipinit */
+static void bgmac_chip_init(struct bgmac *bgmac, bool full_init)
+{
+	struct bgmac_dma_ring *ring;
+	u8 *mac =3D bgmac->net_dev->dev_addr;
+	u32 tmp;
+	int i;
+
+	/* 1 interrupt per received frame */
+	bgmac_write(bgmac, BGMAC_INT_RECV_LAZY, 1 << BGMAC_IRL_FC_SHIFT);
+
+	/* Enable 802.3x tx flow control (honor received PAUSE frames) */
+	bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_RPI, 0, true);
+
+	if (bgmac->net_dev->flags & IFF_PROMISC)
+		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, false);
+	else
+		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
+
+	/* Set MAC addr */
+	tmp =3D (mac[0] << 24) | (mac[1] << 16) | (mac[2] << 8) | mac[3];
+	bgmac_write(bgmac, BGMAC_MACADDR_HIGH, tmp);
+	tmp =3D (mac[4] << 8) | mac[5];
+	bgmac_write(bgmac, BGMAC_MACADDR_LOW, tmp);
+
+	if (bgmac->loopback)
+		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_ML, true);
+	else
+		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_ML, 0, true);
+
+	bgmac_write(bgmac, BGMAC_RXMAX_LENGTH, 32 + ETHER_MAX_LEN);
+
+	if (!bgmac->autoneg) {
+		bgmac_speed(bgmac, bgmac->speed);
+		bgmac_phy_force(bgmac);
+	} else if (bgmac->speed) { /* if there is anything to adv */
+		bgmac_phy_advertise(bgmac);
+	}
+
+	if (full_init) {
+		bgmac_dma_init(bgmac);
+		if (1) /* FIXME: is there any case we don't want IRQs? */
+			bgmac_chip_intrs_on(bgmac);
+	} else {
+		for (i =3D 0; i < BGMAC_MAX_RX_RINGS; i++) {
+			ring =3D &bgmac->rx_ring[i];
+			bgmac_dma_rx_enable(bgmac, ring);
+		}
+	}
+
+	bgmac_enable(bgmac);
+}
+
+static irqreturn_t bgmac_interrupt(int irq, void *dev_id)
+{
+	struct bgmac *bgmac =3D netdev_priv(dev_id);
+
+	u32 int_status =3D bgmac_read(bgmac, BGMAC_INT_STATUS);
+	int_status &=3D bgmac->int_mask;
+
+	if (!int_status)
+		return IRQ_NONE;
+
+	/* Ack */
+	bgmac_write(bgmac, BGMAC_INT_STATUS, int_status);
+
+	/* Disable new interrupts until handling existing ones */
+	bgmac_chip_intrs_off(bgmac);
+
+	bgmac->int_status =3D int_status;
+
+	napi_schedule(&bgmac->napi);
+
+	return IRQ_HANDLED;
+}
+
+static int bgmac_poll(struct napi_struct *napi, int weight)
+{
+	struct bgmac *bgmac =3D container_of(napi, struct bgmac, napi);
+	struct bgmac_dma_ring *ring;
+	int handled =3D 0;
+
+	if (bgmac->int_status & BGMAC_IS_TX0) {
+		ring =3D &bgmac->tx_ring[0];
+		bgmac_dma_tx_free(bgmac, ring);
+		bgmac->int_status &=3D ~BGMAC_IS_TX0;
+	}
+
+	if (bgmac->int_status & BGMAC_IS_RX) {
+		ring =3D &bgmac->rx_ring[0];
+		handled +=3D bgmac_dma_rx_read(bgmac, ring, weight);
+		bgmac->int_status &=3D ~BGMAC_IS_RX;
+	}
+
+	if (bgmac->int_status) {
+		bgmac_err(bgmac, "Unknown IRQs: 0x%08X\n", bgmac->int_status);
+		bgmac->int_status =3D 0;
+	}
+
+	if (handled < weight)
+		napi_complete(napi);
+
+	bgmac_chip_intrs_on(bgmac);
+
+	return handled;
+}
+
+/**************************************************
+ * net_device_ops
+ **************************************************/
+
+static int bgmac_open(struct net_device *net_dev)
+{
+	struct bgmac *bgmac =3D netdev_priv(net_dev);
+
+	/* Reset */
+	bgmac_chip_reset(bgmac);
+	/* Specs say about reclaiming rings here, but we do that in DMA init =
*/
+	bgmac_chip_init(bgmac, true);
+
+	/* Enable IRQs */
+	if (request_irq(bgmac->core->irq, bgmac_interrupt, IRQF_SHARED,
+			KBUILD_MODNAME, net_dev) < 0)
+		bgmac_err(bgmac, "IRQ request error!\n");
+	napi_enable(&bgmac->napi);
+
+	return 0;
+}
+
+static int bgmac_stop(struct net_device *net_dev)
+{
+	struct bgmac *bgmac =3D netdev_priv(net_dev);
+
+	/* Disable IRQs */
+	napi_disable(&bgmac->napi);
+	bgmac_chip_intrs_off(bgmac);
+
+	free_irq(bgmac->core->irq, net_dev);
+
+	bgmac_chip_reset(bgmac);
+
+	return 0;
+}
+
+static netdev_tx_t bgmac_start_xmit(struct sk_buff *skb,
+				    struct net_device *net_dev)
+{
+	struct bgmac *bgmac =3D netdev_priv(net_dev);
+	struct bgmac_dma_ring *ring;
+
+	/* No QOS support yet */
+	ring =3D &bgmac->tx_ring[0];
+	return bgmac_dma_tx_add(bgmac, ring, skb);
+}
+
+static int bgmac_ioctl(struct net_device *net_dev, struct ifreq *ifr, =
int cmd)
+{
+	struct bgmac *bgmac =3D netdev_priv(net_dev);
+	struct mii_ioctl_data *data =3D if_mii(ifr);
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		data->phy_id =3D bgmac->phyaddr;
+		/* fallthru */
+	case SIOCGMIIREG:
+		if (!netif_running(net_dev))
+			return -EAGAIN;
+		data->val_out =3D bgmac_phy_read(bgmac, bgmac->phyaddr,
+					       data->reg_num & 0x1f);
+		return 0;
+	case SIOCSMIIREG:
+		if (!netif_running(net_dev))
+			return -EAGAIN;
+		bgmac_phy_write(bgmac, bgmac->phyaddr, data->reg_num & 0x1f,
+				data->val_in);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static const struct net_device_ops bgmac_netdev_ops =3D {
+	.ndo_open		=3D bgmac_open,
+	.ndo_stop		=3D bgmac_stop,
+	.ndo_start_xmit		=3D bgmac_start_xmit,
+	.ndo_set_mac_address	=3D eth_mac_addr, /* generic, sets dev_addr */
+	.ndo_do_ioctl           =3D bgmac_ioctl,
+};
+
+/**************************************************
+ * ethtool_ops
+ **************************************************/
+
+static int bgmac_get_settings(struct net_device *net_dev,
+			      struct ethtool_cmd *cmd)
+{
+	struct bgmac *bgmac =3D netdev_priv(net_dev);
+
+	cmd->supported =3D SUPPORTED_10baseT_Half |
+			 SUPPORTED_10baseT_Full |
+			 SUPPORTED_100baseT_Half |
+			 SUPPORTED_100baseT_Full |
+			 SUPPORTED_1000baseT_Half |
+			 SUPPORTED_1000baseT_Full |
+			 SUPPORTED_Autoneg;
+
+	if (bgmac->autoneg) {
+		WARN_ON(cmd->advertising);
+		if (bgmac->full_duplex) {
+			if (bgmac->speed & BGMAC_SPEED_10)
+				cmd->advertising |=3D ADVERTISED_10baseT_Full;
+			if (bgmac->speed & BGMAC_SPEED_100)
+				cmd->advertising |=3D ADVERTISED_100baseT_Full;
+			if (bgmac->speed & BGMAC_SPEED_1000)
+				cmd->advertising |=3D ADVERTISED_1000baseT_Full;
+		} else {
+			if (bgmac->speed & BGMAC_SPEED_10)
+				cmd->advertising |=3D ADVERTISED_10baseT_Half;
+			if (bgmac->speed & BGMAC_SPEED_100)
+				cmd->advertising |=3D ADVERTISED_100baseT_Half;
+			if (bgmac->speed & BGMAC_SPEED_1000)
+				cmd->advertising |=3D ADVERTISED_1000baseT_Half;
+		}
+	} else {
+		switch (bgmac->speed) {
+		case BGMAC_SPEED_10:
+			ethtool_cmd_speed_set(cmd, SPEED_10);
+			break;
+		case BGMAC_SPEED_100:
+			ethtool_cmd_speed_set(cmd, SPEED_100);
+			break;
+		case BGMAC_SPEED_1000:
+			ethtool_cmd_speed_set(cmd, SPEED_1000);
+			break;
+		}
+	}
+
+	cmd->duplex =3D bgmac->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
+
+	cmd->autoneg =3D bgmac->autoneg;
+
+	return 0;
+}
+
+#if 0
+static int bgmac_set_settings(struct net_device *net_dev,
+			      struct ethtool_cmd *cmd)
+{
+	struct bgmac *bgmac =3D netdev_priv(net_dev);
+
+	return -1;
+}
+#endif
+
+static void bgmac_get_drvinfo(struct net_device *net_dev,
+			      struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
+	strlcpy(info->bus_info, "BCMA", sizeof(info->bus_info));
+}
+
+static const struct ethtool_ops bgmac_ethtool_ops =3D {
+	.get_settings		=3D bgmac_get_settings,
+	.get_drvinfo		=3D bgmac_get_drvinfo,
+};
+
+/**************************************************
+ * BCMA bus ops
+ **************************************************/
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipattach */
+static int bgmac_probe(struct bcma_device *core)
+{
+	struct net_device *net_dev;
+	struct bgmac *bgmac;
+	struct ssb_sprom *sprom =3D &core->bus->sprom;
+	u8 *mac =3D core->core_unit ? sprom->et1mac : sprom->et0mac;
+	int err;
+
+	/* We don't support 2nd, 3rd, ... units, SPROM has to be adjusted */
+	if (core->core_unit > 1) {
+		pr_err("Unsupported core_unit %d\n", core->core_unit);
+		return -ENOTSUPP;
+	}
+
+	/* Allocation and references */
+	net_dev =3D alloc_etherdev(sizeof(*bgmac));
+	if (!net_dev)
+		return -ENOMEM;
+	net_dev->netdev_ops =3D &bgmac_netdev_ops;
+	net_dev->irq =3D core->irq;
+	SET_ETHTOOL_OPS(net_dev, &bgmac_ethtool_ops);
+	bgmac =3D netdev_priv(net_dev);
+	bgmac->net_dev =3D net_dev;
+	bgmac->core =3D core;
+	bcma_set_drvdata(core, bgmac);
+
+	/* Defaults */
+	bgmac->autoneg =3D true;
+	bgmac->full_duplex =3D true;
+	bgmac->speed =3D BGMAC_SPEED_10 | BGMAC_SPEED_100 | BGMAC_SPEED_1000;
+	memcpy(bgmac->net_dev->dev_addr, mac, ETH_ALEN);
+
+	/* On BCM4706 we need common core to access PHY */
+	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT &&
+	    !core->bus->drv_gmac_cmn.core) {
+		bgmac_err(bgmac, "GMAC CMN core not found (required for BCM4706)\n")=
;
+		err =3D -ENODEV;
+		goto err_netdev_free;
+	}
+	bgmac->cmn =3D core->bus->drv_gmac_cmn.core;
+
+	bgmac->phyaddr =3D core->core_unit ? sprom->et1phyaddr :
+			 sprom->et0phyaddr;
+	bgmac->phyaddr &=3D BGMAC_PHY_MASK;
+	if (bgmac->phyaddr =3D=3D BGMAC_PHY_MASK) {
+		bgmac_err(bgmac, "No PHY found\n");
+		err =3D -ENODEV;
+		goto err_netdev_free;
+	}
+	bgmac_info(bgmac, "Found PHY addr: %d\n", bgmac->phyaddr);
+
+	if (core->bus->hosttype =3D=3D BCMA_HOSTTYPE_PCI) {
+		bgmac_err(bgmac, "PCI setup not implemented\n");
+		err =3D -ENOTSUPP;
+		goto err_netdev_free;
+	}
+
+	bgmac_chip_reset(bgmac);
+
+	err =3D bgmac_dma_alloc(bgmac);
+	if (err) {
+		bgmac_err(bgmac, "Unable to alloc memory for DMA\n");
+		goto err_netdev_free;
+	}
+
+	bgmac->int_mask =3D BGMAC_IS_ERRMASK | BGMAC_IS_RX | BGMAC_IS_TX_MASK=
;
+	if (nvram_getenv("et0_no_txint", NULL, 0) =3D=3D 0)
+		bgmac->int_mask &=3D ~BGMAC_IS_TX_MASK;
+
+	/* TODO: reset the external phy. Specs are needed */
+	bgmac_phy_reset(bgmac);
+
+	bgmac->has_robosw =3D !!(core->bus->sprom.boardflags_lo &
+			       BGMAC_BFL_ENETROBO);
+	if (bgmac->has_robosw)
+		bgmac_warn(bgmac, "Support for Roboswitch not implemented\n");
+
+	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
+		bgmac_warn(bgmac, "Support for ADMtek ethernet switch not implemente=
d\n");
+
+	err =3D register_netdev(bgmac->net_dev);
+	if (err) {
+		bgmac_err(bgmac, "Cannot register net device\n");
+		err =3D -ENOTSUPP;
+		goto err_dma_free;
+	}
+
+	netif_napi_add(net_dev, &bgmac->napi, bgmac_poll, BGMAC_WEIGHT);
+
+	return 0;
+
+err_dma_free:
+	bgmac_dma_free(bgmac);
+
+err_netdev_free:
+	bcma_set_drvdata(core, NULL);
+	free_netdev(net_dev);
+
+	return err;
+}
+
+static void bgmac_remove(struct bcma_device *core)
+{
+	struct bgmac *bgmac =3D bcma_get_drvdata(core);
+
+	netif_napi_del(&bgmac->napi);
+	unregister_netdev(bgmac->net_dev);
+	bgmac_dma_free(bgmac);
+	bcma_set_drvdata(core, NULL);
+	free_netdev(bgmac->net_dev);
+}
+
+static struct bcma_driver bgmac_bcma_driver =3D {
+	.name		=3D KBUILD_MODNAME,
+	.id_table	=3D bgmac_bcma_tbl,
+	.probe		=3D bgmac_probe,
+	.remove		=3D bgmac_remove,
+};
+
+static int __init bgmac_init(void)
+{
+	int err;
+
+	err =3D bcma_driver_register(&bgmac_bcma_driver);
+	if (err)
+		return err;
+	pr_info("Broadcom 47xx GBit MAC driver loaded\n");
+
+	return 0;
+}
+
+static void __exit bgmac_exit(void)
+{
+	bcma_driver_unregister(&bgmac_bcma_driver);
+}
+
+module_init(bgmac_init)
+module_exit(bgmac_exit)
+
+MODULE_AUTHOR("Rafa=C5=82 Mi=C5=82ecki");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
new file mode 100644
index 0000000..a41b61d
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -0,0 +1,443 @@
+#ifndef _BGMAC_H
+#define _BGMAC_H
+
+#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
+
+#define bgmac_err(bgmac, fmt, ...) \
+	pr_err("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
+#define bgmac_warn(bgmac, fmt, ...) \
+	pr_warn("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
+#define bgmac_info(bgmac, fmt, ...) \
+	pr_info("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
+#define bgmac_dbg(bgmac, fmt, ...) \
+	pr_debug("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
+
+#include <linux/bcma/bcma.h>
+#include <linux/netdevice.h>
+
+#define BGMAC_DEV_CTL				0x000
+#define  BGMAC_DC_TSM				0x00000002
+#define  BGMAC_DC_CFCO				0x00000004
+#define  BGMAC_DC_RLSS				0x00000008
+#define  BGMAC_DC_MROR				0x00000010
+#define  BGMAC_DC_FCM_MASK			0x00000060
+#define  BGMAC_DC_FCM_SHIFT			5
+#define  BGMAC_DC_NAE				0x00000080
+#define  BGMAC_DC_TF				0x00000100
+#define  BGMAC_DC_RDS_MASK			0x00030000
+#define  BGMAC_DC_RDS_SHIFT			16
+#define  BGMAC_DC_TDS_MASK			0x000c0000
+#define  BGMAC_DC_TDS_SHIFT			18
+#define BGMAC_DEV_STATUS			0x004		/* Configuration of the interface */
+#define  BGMAC_DS_RBF				0x00000001
+#define  BGMAC_DS_RDF				0x00000002
+#define  BGMAC_DS_RIF				0x00000004
+#define  BGMAC_DS_TBF				0x00000008
+#define  BGMAC_DS_TDF				0x00000010
+#define  BGMAC_DS_TIF				0x00000020
+#define  BGMAC_DS_PO				0x00000040
+#define  BGMAC_DS_MM_MASK			0x00000300	/* Mode of the interface */
+#define  BGMAC_DS_MM_SHIFT			8
+#define BGMAC_BIST_STATUS			0x00c
+#define BGMAC_INT_STATUS			0x020		/* Interrupt status */
+#define  BGMAC_IS_MRO				0x00000001
+#define  BGMAC_IS_MTO				0x00000002
+#define  BGMAC_IS_TFD				0x00000004
+#define  BGMAC_IS_LS				0x00000008
+#define  BGMAC_IS_MDIO				0x00000010
+#define  BGMAC_IS_MR				0x00000020
+#define  BGMAC_IS_MT				0x00000040
+#define  BGMAC_IS_TO				0x00000080
+#define  BGMAC_IS_DESC_ERR			0x00000400	/* Descriptor error */
+#define  BGMAC_IS_DATA_ERR			0x00000800	/* Data error */
+#define  BGMAC_IS_DESC_PROT_ERR			0x00001000	/* Descriptor protocol er=
ror */
+#define  BGMAC_IS_RX_DESC_UNDERF		0x00002000	/* Receive descriptor und=
erflow */
+#define  BGMAC_IS_RX_F_OVERF			0x00004000	/* Receive FIFO overflow */
+#define  BGMAC_IS_TX_F_UNDERF			0x00008000	/* Transmit FIFO underflow =
*/
+#define  BGMAC_IS_RX				0x00010000	/* Interrupt for RX queue 0 */
+#define  BGMAC_IS_TX0				0x01000000	/* Interrupt for TX queue 0 */
+#define  BGMAC_IS_TX1				0x02000000	/* Interrupt for TX queue 1 */
+#define  BGMAC_IS_TX2				0x04000000	/* Interrupt for TX queue 2 */
+#define  BGMAC_IS_TX3				0x08000000	/* Interrupt for TX queue 3 */
+#define  BGMAC_IS_TX_MASK			0x0f000000
+#define  BGMAC_IS_INTMASK			0x0f01fcff
+#define  BGMAC_IS_ERRMASK			0x0000fc00
+#define BGMAC_INT_MASK				0x024		/* Interrupt mask */
+#define BGMAC_GP_TIMER				0x028
+#define BGMAC_INT_RECV_LAZY			0x100
+#define  BGMAC_IRL_TO_MASK			0x00ffffff
+#define  BGMAC_IRL_FC_MASK			0xff000000
+#define  BGMAC_IRL_FC_SHIFT			24		/* Shift the number of interrupts tr=
iggered per received frame */
+#define BGMAC_FLOW_CTL_THRESH			0x104		/* Flow control thresholds */
+#define BGMAC_WRRTHRESH				0x108
+#define BGMAC_GMAC_IDLE_CNT_THRESH		0x10c
+#define BGMAC_PHY_ACCESS			0x180		/* PHY access address */
+#define  BGMAC_PA_DATA_MASK			0x0000ffff
+#define  BGMAC_PA_ADDR_MASK			0x001f0000
+#define  BGMAC_PA_ADDR_SHIFT			16
+#define  BGMAC_PA_REG_MASK			0x1f000000
+#define  BGMAC_PA_REG_SHIFT			24
+#define  BGMAC_PA_WRITE				0x20000000
+#define  BGMAC_PA_START				0x40000000
+#define BGMAC_PHY_CNTL				0x188		/* PHY control address */
+#define  BGMAC_PC_EPA_MASK			0x0000001f
+#define  BGMAC_PC_MCT_MASK			0x007f0000
+#define  BGMAC_PC_MCT_SHIFT			16
+#define  BGMAC_PC_MTE				0x00800000
+#define BGMAC_TXQ_CTL				0x18c
+#define  BGMAC_TXQ_CTL_DBT_MASK			0x00000fff
+#define  BGMAC_TXQ_CTL_DBT_SHIFT		0
+#define BGMAC_RXQ_CTL				0x190
+#define  BGMAC_RXQ_CTL_DBT_MASK			0x00000fff
+#define  BGMAC_RXQ_CTL_DBT_SHIFT		0
+#define  BGMAC_RXQ_CTL_PTE			0x00001000
+#define  BGMAC_RXQ_CTL_MDP_MASK			0x3f000000
+#define  BGMAC_RXQ_CTL_MDP_SHIFT		24
+#define BGMAC_GPIO_SELECT			0x194
+#define BGMAC_GPIO_OUTPUT_EN			0x198
+/* For 0x1e0 see BCMA_CLKCTLST */
+#define BGMAC_HW_WAR				0x1e4
+#define BGMAC_PWR_CTL				0x1e8
+#define BGMAC_DMA_BASE0				0x200		/* Tx and Rx controller */
+#define BGMAC_DMA_BASE1				0x240		/* Tx controller only */
+#define BGMAC_DMA_BASE2				0x280		/* Tx controller only */
+#define BGMAC_DMA_BASE3				0x2C0		/* Tx controller only */
+#define BGMAC_TX_GOOD_OCTETS			0x300
+#define BGMAC_TX_GOOD_OCTETS_HIGH		0x304
+#define BGMAC_TX_GOOD_PKTS			0x308
+#define BGMAC_TX_OCTETS				0x30c
+#define BGMAC_TX_OCTETS_HIGH			0x310
+#define BGMAC_TX_PKTS				0x314
+#define BGMAC_TX_BROADCAST_PKTS			0x318
+#define BGMAC_TX_MULTICAST_PKTS			0x31c
+#define BGMAC_TX_LEN_64				0x320
+#define BGMAC_TX_LEN_65_TO_127			0x324
+#define BGMAC_TX_LEN_128_TO_255			0x328
+#define BGMAC_TX_LEN_256_TO_511			0x32c
+#define BGMAC_TX_LEN_512_TO_1023		0x330
+#define BGMAC_TX_LEN_1024_TO_1522		0x334
+#define BGMAC_TX_LEN_1523_TO_2047		0x338
+#define BGMAC_TX_LEN_2048_TO_4095		0x33c
+#define BGMAC_TX_LEN_4095_TO_8191		0x340
+#define BGMAC_TX_LEN_8192_TO_MAX		0x344
+#define BGMAC_TX_JABBER_PKTS			0x348		/* Error */
+#define BGMAC_TX_OVERSIZE_PKTS			0x34c		/* Error */
+#define BGMAC_TX_FRAGMENT_PKTS			0x350
+#define BGMAC_TX_UNDERRUNS			0x354		/* Error */
+#define BGMAC_TX_TOTAL_COLS			0x358
+#define BGMAC_TX_SINGLE_COLS			0x35c
+#define BGMAC_TX_MULTIPLE_COLS			0x360
+#define BGMAC_TX_EXCESSIVE_COLS			0x364		/* Error */
+#define BGMAC_TX_LATE_COLS			0x368		/* Error */
+#define BGMAC_TX_DEFERED			0x36c
+#define BGMAC_TX_CARRIER_LOST			0x370
+#define BGMAC_TX_PAUSE_PKTS			0x374
+#define BGMAC_TX_UNI_PKTS			0x378
+#define BGMAC_TX_Q0_PKTS			0x37c
+#define BGMAC_TX_Q0_OCTETS			0x380
+#define BGMAC_TX_Q0_OCTETS_HIGH			0x384
+#define BGMAC_TX_Q1_PKTS			0x388
+#define BGMAC_TX_Q1_OCTETS			0x38c
+#define BGMAC_TX_Q1_OCTETS_HIGH			0x390
+#define BGMAC_TX_Q2_PKTS			0x394
+#define BGMAC_TX_Q2_OCTETS			0x398
+#define BGMAC_TX_Q2_OCTETS_HIGH			0x39c
+#define BGMAC_TX_Q3_PKTS			0x3a0
+#define BGMAC_TX_Q3_OCTETS			0x3a4
+#define BGMAC_TX_Q3_OCTETS_HIGH			0x3a8
+#define BGMAC_RX_GOOD_OCTETS			0x3b0
+#define BGMAC_RX_GOOD_OCTETS_HIGH		0x3b4
+#define BGMAC_RX_GOOD_PKTS			0x3b8
+#define BGMAC_RX_OCTETS				0x3bc
+#define BGMAC_RX_OCTETS_HIGH			0x3c0
+#define BGMAC_RX_PKTS				0x3c4
+#define BGMAC_RX_BROADCAST_PKTS			0x3c8
+#define BGMAC_RX_MULTICAST_PKTS			0x3cc
+#define BGMAC_RX_LEN_64				0x3d0
+#define BGMAC_RX_LEN_65_TO_127			0x3d4
+#define BGMAC_RX_LEN_128_TO_255			0x3d8
+#define BGMAC_RX_LEN_256_TO_511			0x3dc
+#define BGMAC_RX_LEN_512_TO_1023		0x3e0
+#define BGMAC_RX_LEN_1024_TO_1522		0x3e4
+#define BGMAC_RX_LEN_1523_TO_2047		0x3e8
+#define BGMAC_RX_LEN_2048_TO_4095		0x3ec
+#define BGMAC_RX_LEN_4095_TO_8191		0x3f0
+#define BGMAC_RX_LEN_8192_TO_MAX		0x3f4
+#define BGMAC_RX_JABBER_PKTS			0x3f8		/* Error */
+#define BGMAC_RX_OVERSIZE_PKTS			0x3fc		/* Error */
+#define BGMAC_RX_FRAGMENT_PKTS			0x400
+#define BGMAC_RX_MISSED_PKTS			0x404		/* Error */
+#define BGMAC_RX_CRC_ALIGN_ERRS			0x408		/* Error */
+#define BGMAC_RX_UNDERSIZE			0x40c		/* Error */
+#define BGMAC_RX_CRC_ERRS			0x410		/* Error */
+#define BGMAC_RX_ALIGN_ERRS			0x414		/* Error */
+#define BGMAC_RX_SYMBOL_ERRS			0x418		/* Error */
+#define BGMAC_RX_PAUSE_PKTS			0x41c
+#define BGMAC_RX_NONPAUSE_PKTS			0x420
+#define BGMAC_RX_SACHANGES			0x424
+#define BGMAC_RX_UNI_PKTS			0x428
+#define BGMAC_UNIMAC_VERSION			0x800
+#define BGMAC_HDBKP_CTL				0x804
+#define BGMAC_CMDCFG				0x808		/* Configuration */
+#define  BGMAC_CMDCFG_TE			0x00000001	/* Set to activate TX */
+#define  BGMAC_CMDCFG_RE			0x00000002	/* Set to activate RX */
+#define  BGMAC_CMDCFG_ES_MASK			0x0000000c	/* Ethernet speed see gmac_=
speed */
+#define   BGMAC_CMDCFG_ES_10			0x00000000
+#define   BGMAC_CMDCFG_ES_100			0x00000004
+#define   BGMAC_CMDCFG_ES_1000			0x00000008
+#define  BGMAC_CMDCFG_PROM			0x00000010	/* Set to activate promiscuous=
 mode */
+#define  BGMAC_CMDCFG_PAD_EN			0x00000020
+#define  BGMAC_CMDCFG_CF			0x00000040
+#define  BGMAC_CMDCFG_PF			0x00000080
+#define  BGMAC_CMDCFG_RPI			0x00000100	/* Unset to enable 802.3x tx fl=
ow control */
+#define  BGMAC_CMDCFG_TAI			0x00000200
+#define  BGMAC_CMDCFG_HD			0x00000400	/* Set if in half duplex mode */
+#define  BGMAC_CMDCFG_HD_SHIFT			10
+#define  BGMAC_CMDCFG_SR			0x00000800	/* Set to reset mode */
+#define  BGMAC_CMDCFG_ML			0x00008000	/* Set to activate mac loopback =
mode */
+#define  BGMAC_CMDCFG_AE			0x00400000
+#define  BGMAC_CMDCFG_CFE			0x00800000
+#define  BGMAC_CMDCFG_NLC			0x01000000
+#define  BGMAC_CMDCFG_RL			0x02000000
+#define  BGMAC_CMDCFG_RED			0x04000000
+#define  BGMAC_CMDCFG_PE			0x08000000
+#define  BGMAC_CMDCFG_TPI			0x10000000
+#define  BGMAC_CMDCFG_AT			0x20000000
+#define BGMAC_MACADDR_HIGH			0x80c		/* High 4 octets of own mac addres=
s */
+#define BGMAC_MACADDR_LOW			0x810		/* Low 2 octets of own mac address =
*/
+#define BGMAC_RXMAX_LENGTH			0x814		/* Max receive frame length with v=
lan tag */
+#define BGMAC_PAUSEQUANTA			0x818
+#define BGMAC_MAC_MODE				0x844
+#define BGMAC_OUTERTAG				0x848
+#define BGMAC_INNERTAG				0x84c
+#define BGMAC_TXIPG				0x85c
+#define BGMAC_PAUSE_CTL				0xb30
+#define BGMAC_TX_FLUSH				0xb34
+#define BGMAC_RX_STATUS				0xb38
+#define BGMAC_TX_STATUS				0xb3c
+
+#define BGMAC_PHY_CTL				0x00
+#define  BGMAC_PHY_CTL_SPEED_MSB		0x0040
+#define  BGMAC_PHY_CTL_DUPLEX			0x0100		/* duplex mode */
+#define  BGMAC_PHY_CTL_RESTART			0x0200		/* restart autonegotiation */
+#define  BGMAC_PHY_CTL_ANENAB			0x1000		/* enable autonegotiation */
+#define  BGMAC_PHY_CTL_SPEED			0x2000
+#define  BGMAC_PHY_CTL_LOOP			0x4000		/* loopback */
+#define  BGMAC_PHY_CTL_RESET			0x8000		/* reset */
+/* Helpers */
+#define  BGMAC_PHY_CTL_SPEED_10			0
+#define  BGMAC_PHY_CTL_SPEED_100		BGMAC_PHY_CTL_SPEED
+#define  BGMAC_PHY_CTL_SPEED_1000		BGMAC_PHY_CTL_SPEED_MSB
+#define BGMAC_PHY_ADV				0x04
+#define  BGMAC_PHY_ADV_10HALF			0x0020		/* advertise 10MBits/s half du=
plex */
+#define  BGMAC_PHY_ADV_10FULL			0x0040		/* advertise 10MBits/s full du=
plex */
+#define  BGMAC_PHY_ADV_100HALF			0x0080		/* advertise 100MBits/s half =
duplex */
+#define  BGMAC_PHY_ADV_100FULL			0x0100		/* advertise 100MBits/s full =
duplex */
+#define BGMAC_PHY_ADV2				0x09
+#define  BGMAC_PHY_ADV2_1000HALF		0x0100		/* advertise 1000MBits/s hal=
f duplex */
+#define  BGMAC_PHY_ADV2_1000FULL		0x0200		/* advertise 1000MBits/s ful=
l duplex */
+
+/* BCMA GMAC core specific IO Control (BCMA_IOCTL) flags */
+#define BGMAC_BCMA_IOCTL_SW_CLKEN		0x00000004	/* PHY Clock Enable */
+#define BGMAC_BCMA_IOCTL_SW_RESET		0x00000008	/* PHY Reset */
+
+/* BCMA GMAC core specific IO status (BCMA_IOST) flags */
+#define BGMAC_BCMA_IOST_ATTACHED		0x00000800
+
+#define BGMAC_NUM_MIB_TX_REGS	\
+		(((BGMAC_TX_Q3_OCTETS_HIGH - BGMAC_TX_GOOD_OCTETS) / 4) + 1)
+#define BGMAC_NUM_MIB_RX_REGS	\
+		(((BGMAC_RX_UNI_PKTS - BGMAC_RX_GOOD_OCTETS) / 4) + 1)
+
+#define BGMAC_DMA_TX_CTL			0x00
+#define  BGMAC_DMA_TX_ENABLE			0x00000001
+#define  BGMAC_DMA_TX_SUSPEND			0x00000002
+#define  BGMAC_DMA_TX_LOOPBACK			0x00000004
+#define  BGMAC_DMA_TX_FLUSH			0x00000010
+#define  BGMAC_DMA_TX_PARITY_DISABLE		0x00000800
+#define  BGMAC_DMA_TX_ADDREXT_MASK		0x00030000
+#define  BGMAC_DMA_TX_ADDREXT_SHIFT		16
+#define BGMAC_DMA_TX_INDEX			0x04
+#define BGMAC_DMA_TX_RINGLO			0x08
+#define BGMAC_DMA_TX_RINGHI			0x0C
+#define BGMAC_DMA_TX_STATUS			0x10
+#define  BGMAC_DMA_TX_STATDPTR			0x00001FFF
+#define  BGMAC_DMA_TX_STAT			0xF0000000
+#define   BGMAC_DMA_TX_STAT_DISABLED		0x00000000
+#define   BGMAC_DMA_TX_STAT_ACTIVE		0x10000000
+#define   BGMAC_DMA_TX_STAT_IDLEWAIT		0x20000000
+#define   BGMAC_DMA_TX_STAT_STOPPED		0x30000000
+#define   BGMAC_DMA_TX_STAT_SUSP		0x40000000
+#define BGMAC_DMA_TX_ERROR			0x14
+#define  BGMAC_DMA_TX_ERRDPTR			0x0001FFFF
+#define  BGMAC_DMA_TX_ERR			0xF0000000
+#define   BGMAC_DMA_TX_ERR_NOERR		0x00000000
+#define   BGMAC_DMA_TX_ERR_PROT			0x10000000
+#define   BGMAC_DMA_TX_ERR_UNDERRUN		0x20000000
+#define   BGMAC_DMA_TX_ERR_TRANSFER		0x30000000
+#define   BGMAC_DMA_TX_ERR_DESCREAD		0x40000000
+#define   BGMAC_DMA_TX_ERR_CORE			0x50000000
+#define BGMAC_DMA_RX_CTL			0x20
+#define  BGMAC_DMA_RX_ENABLE			0x00000001
+#define  BGMAC_DMA_RX_FRAME_OFFSET_MASK		0x000000FE
+#define  BGMAC_DMA_RX_FRAME_OFFSET_SHIFT	1
+#define  BGMAC_DMA_RX_DIRECT_FIFO		0x00000100
+#define  BGMAC_DMA_RX_OVERFLOW_CONT		0x00000400
+#define  BGMAC_DMA_RX_PARITY_DISABLE		0x00000800
+#define  BGMAC_DMA_RX_ADDREXT_MASK		0x00030000
+#define  BGMAC_DMA_RX_ADDREXT_SHIFT		16
+#define BGMAC_DMA_RX_INDEX			0x24
+#define BGMAC_DMA_RX_RINGLO			0x28
+#define BGMAC_DMA_RX_RINGHI			0x2C
+#define BGMAC_DMA_RX_STATUS			0x30
+#define  BGMAC_DMA_RX_STATDPTR			0x00001FFF
+#define  BGMAC_DMA_RX_STAT			0xF0000000
+#define   BGMAC_DMA_RX_STAT_DISABLED		0x00000000
+#define   BGMAC_DMA_RX_STAT_ACTIVE		0x10000000
+#define   BGMAC_DMA_RX_STAT_IDLEWAIT		0x20000000
+#define   BGMAC_DMA_RX_STAT_STOPPED		0x30000000
+#define   BGMAC_DMA_RX_STAT_SUSP		0x40000000
+#define BGMAC_DMA_RX_ERROR			0x34
+#define  BGMAC_DMA_RX_ERRDPTR			0x0001FFFF
+#define  BGMAC_DMA_RX_ERR			0xF0000000
+#define   BGMAC_DMA_RX_ERR_NOERR		0x00000000
+#define   BGMAC_DMA_RX_ERR_PROT			0x10000000
+#define   BGMAC_DMA_RX_ERR_UNDERRUN		0x20000000
+#define   BGMAC_DMA_RX_ERR_TRANSFER		0x30000000
+#define   BGMAC_DMA_RX_ERR_DESCREAD		0x40000000
+#define   BGMAC_DMA_RX_ERR_CORE			0x50000000
+
+#define BGMAC_DESC_CTL0_EOT			0x10000000	/* End of ring */
+#define BGMAC_DESC_CTL0_IOC			0x20000000	/* IRQ on complete */
+#define BGMAC_DESC_CTL0_SOF			0x40000000	/* Start of frame */
+#define BGMAC_DESC_CTL0_EOF			0x80000000	/* End of frame */
+#define BGMAC_DESC_CTL1_LEN			0x00001FFF
+
+#define BGMAC_PHY_NOREGS			0x1E
+#define BGMAC_PHY_MASK				0x1F
+
+#define BGMAC_MAX_TX_RINGS			4
+#define BGMAC_MAX_RX_RINGS			1
+
+#define BGMAC_TX_RING_SLOTS			128
+#define BGMAC_RX_RING_SLOTS			512 - 1		/* Why -1? Well, Broadcom does =
that... */
+
+#define BGMAC_RX_HEADER_LEN			28		/* Last 24 bytes are unused. Well...=
 */
+#define BGMAC_RX_FRAME_OFFSET			30		/* There are 2 unused bytes betwee=
n header and real data */
+#define BGMAC_RX_MAX_FRAME_SIZE			1536		/* Copied from b44/tg3 */
+#define BGMAC_RX_BUF_SIZE			(BGMAC_RX_FRAME_OFFSET + BGMAC_RX_MAX_FRAM=
E_SIZE)
+
+#define BGMAC_BFL_ENETROBO			0x0010		/* has ephy roboswitch spi */
+#define BGMAC_BFL_ENETADM			0x0080		/* has ADMtek switch */
+#define BGMAC_BFL_ENETVLAN			0x0100		/* can do vlan */
+
+#define BGMAC_CHIPCTL_1_IF_TYPE_MASK		0x00000030
+#define BGMAC_CHIPCTL_1_IF_TYPE_RMII		0x00000000
+#define BGMAC_CHIPCTL_1_IF_TYPE_MI		0x00000010
+#define BGMAC_CHIPCTL_1_IF_TYPE_RGMII		0x00000020
+#define BGMAC_CHIPCTL_1_SW_TYPE_MASK		0x000000C0
+#define BGMAC_CHIPCTL_1_SW_TYPE_EPHY		0x00000000
+#define BGMAC_CHIPCTL_1_SW_TYPE_EPHYMII		0x00000040
+#define BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII	0x00000080
+#define BGMAC_CHIPCTL_1_SW_TYPE_RGMI		0x000000C0
+#define BGMAC_CHIPCTL_1_RXC_DLL_BYPASS		0x00010000
+
+#define BGMAC_SPEED_10				0x0001
+#define BGMAC_SPEED_100				0x0002
+#define BGMAC_SPEED_1000			0x0004
+
+#define BGMAC_WEIGHT	64
+
+#define ETHER_MAX_LEN   1518
+
+struct bgmac_slot_info {
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+};
+
+struct bgmac_dma_desc {
+	__le32 ctl0;
+	__le32 ctl1;
+	__le32 addr_low;
+	__le32 addr_high;
+} __packed;
+
+struct bgmac_dma_ring {
+	bool tx;
+	u16 num_slots;
+	u16 start;
+	u16 end;
+
+	u16 mmio_base;
+	void *cpu_base;
+	dma_addr_t dma_base;
+
+	struct bgmac_slot_info slots[BGMAC_RX_RING_SLOTS];
+};
+
+struct bgmac_rx_header {
+	__le16 len;
+	__le16 flags;
+	__le16 pad[12];
+};
+
+struct bgmac {
+	struct bcma_device *core;
+	struct bcma_device *cmn; /* Reference to CMN core for BCM4706 */
+	struct net_device *net_dev;
+	struct napi_struct napi;
+
+	/* DMA */
+	struct bgmac_dma_ring tx_ring[BGMAC_MAX_TX_RINGS];
+	struct bgmac_dma_ring rx_ring[BGMAC_MAX_RX_RINGS];
+
+	/* Stats */
+	bool stats_grabbed;
+	u32 mib_tx_regs[BGMAC_NUM_MIB_TX_REGS];
+	u32 mib_rx_regs[BGMAC_NUM_MIB_RX_REGS];
+
+	/* Int */
+	u32 int_mask;
+	u32 int_status;
+
+	/* Speed-related */
+	int speed;
+	bool autoneg;
+	bool full_duplex;
+
+	u8 phyaddr;
+	bool has_robosw;
+
+	bool loopback;
+};
+
+static inline u32 bgmac_read(struct bgmac *bgmac, u16 offset)
+{
+	return bcma_read32(bgmac->core, offset);
+}
+
+static inline void bgmac_write(struct bgmac *bgmac, u16 offset, u32 va=
lue)
+{
+	bcma_write32(bgmac->core, offset, value);
+}
+
+static inline void bgmac_maskset(struct bgmac *bgmac, u16 offset, u32 =
mask,
+				   u32 set)
+{
+	bgmac_write(bgmac, offset, (bgmac_read(bgmac, offset) & mask) | set);
+}
+
+static inline void bgmac_mask(struct bgmac *bgmac, u16 offset, u32 mas=
k)
+{
+	bgmac_maskset(bgmac, offset, mask, 0);
+}
+
+static inline void bgmac_set(struct bgmac *bgmac, u16 offset, u32 set)
+{
+	bgmac_maskset(bgmac, offset, ~0, set);
+}
+
+u16 bgmac_phy_read(struct bgmac *bgmac, u8 phyaddr, u8 reg);
+void bgmac_phy_write(struct bgmac *bgmac, u8 phyaddr, u8 reg, u16 valu=
e);
+
+#endif /* _BGMAC_H */
diff --git a/include/linux/bcma/bcma_driver_chipcommon.h b/include/linu=
x/bcma/bcma_driver_chipcommon.h
index 9a0e3fa..ee332fa 100644
--- a/include/linux/bcma/bcma_driver_chipcommon.h
+++ b/include/linux/bcma/bcma_driver_chipcommon.h
@@ -634,4 +634,6 @@ extern void bcma_chipco_regctl_maskset(struct bcma_=
drv_cc *cc,
 				       u32 offset, u32 mask, u32 set);
 extern void bcma_pmu_spuravoid_pllupdate(struct bcma_drv_cc *cc, int s=
puravoid);
=20
+extern u32 bcma_pmu_get_bus_clock(struct bcma_drv_cc *cc);
+
 #endif /* LINUX_BCMA_DRIVER_CC_H_ */
--=20
1.7.7
