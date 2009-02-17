From: Ira Snyder <iws@ovro.caltech.edu>
Subject: [RFC v1] virtio: add virtio-over-PCI driver
Date: Tue, 17 Feb 2009 14:24:25 -0800
Message-ID: <20090217222425.GA18801@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:50106 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbZBQWY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 17:24:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support to Linux for using virtio between two computers linked by
a PCI interface. This allows the use of virtio_net to create a familiar,
fast interface for communication. It should be possible to use other virtio
devices in the future, but this has not been tested.

I have implemented guest support for the Freescale MPC8349EMDS board, which
is capable of running in PCI agent mode (It acts like a PCI card, but is a
complete computer system, running Linux). The driver is trivial to port to
any MPC83xx system.

It was developed to work in a CompactPCI crate of computers, one of which
is a standard x86 system (acting as the host) and many PowerPC systems
(acting as guests).

I have only tested this driver with a single board in my system. The host
is a 1066MHz Pentium3-M, and the guest is a 533MHz PowerPC. I am able
achieve transfer rates of about 150 mbit using standard 1500 byte packets.
Not especially fast, but ok for a first try, though I eventually need
more speed. My previous attempt, the PCINet driver, is capable of about
300 mbit, using 64K packets. Performance of PCINet with 1500 byte packets
is less than 50 mbit, so this is a definite improvement.

I have kept the implementation as simple as I found possible. I chose not
to support any of the advanced features of virtio_net, because they made
pairing up transfers between the host and guest queues much harder (if not
impossible?). Any suggestions are welcome. Code would be even better :)

I have included a short document explaining what I think is the most
complicated part of the driver: using the DMA engine to transfer data. I
hope everything else is readily obvious from the code. Questions are
welcome.

I will not be able to work on this full time for at least a few weeks, so I
would appreciate actual review of this driver.  Nitpicks are fine, I just
won't be able to respond to them quickly.

Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
---

Yes, the commit message has too much information. This is an RFC after
all. I fully expect to have to make changes. In fact, I posting this
more to "get it out there" than anything else, since I have other tasks
that need doing.

I'd appreciate a serious review of the design by the people who have
been pressuring me to use virtio. I'm very happy to answer any questions
you have.

 Documentation/virtio-over-PCI.txt     |   61 ++
 arch/powerpc/boot/dts/mpc834x_mds.dts |    7 +
 drivers/virtio/Kconfig                |   22 +
 drivers/virtio/Makefile               |    2 +
 drivers/virtio/vop.h                  |  119 ++
 drivers/virtio/vop_fsl.c              | 1911 +++++++++++++++++++++++++++++++++
 drivers/virtio/vop_host.c             | 1028 ++++++++++++++++++
 drivers/virtio/vop_hw.h               |   80 ++
 8 files changed, 3230 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/virtio-over-PCI.txt
 create mode 100644 drivers/virtio/vop.h
 create mode 100644 drivers/virtio/vop_fsl.c
 create mode 100644 drivers/virtio/vop_host.c
 create mode 100644 drivers/virtio/vop_hw.h

diff --git a/Documentation/virtio-over-PCI.txt b/Documentation/virtio-over-PCI.txt
new file mode 100644
index 0000000..aea1e7d
--- /dev/null
+++ b/Documentation/virtio-over-PCI.txt
@@ -0,0 +1,61 @@
+The implementation of virtio-over-PCI was driven with the following goals:
+* Avoid MMIO reads, try to use only MMIO writes
+* Use the onboard DMA engine, for speed
+
+The implementation also borrows many of the details from the only other
+implementation, virtio_ring.
+
+It succeeds in avoiding all MMIO reads on the critical paths. I did not
+see any reason to avoid the use of MMIO reads during device probing, since
+it is not a critical path.
+
+=== Avoiding MMIO reads ===
+To avoid MMIO reads, both the host and guest systems have a copy of the
+descriptors. Both sides need to read the descriptors after they have been
+written, but only the host system writes to them. This allows us to keep a
+local copy for later use.
+
+=== Using the DMA engine ===
+This is the only truly complicated part of the system. Since this
+implementation was designed for use with virtio_net, it may be biased
+towards virtio_net's usage of the virtio interface.
+
+The virtio_net driver provides a receive ring, which it fills with empty
+packets. The code sets up DMA transfers directly from the guest transmit
+queue to the empty packets in the host receive queue. Data transfer in the
+other direction works in a similar fashion.
+
+The guest (PowerPC) system keeps its own local set of descriptors, which are
+filled by the virtio add_buf() call. Whenever this happens, the avail ring is
+changed, and therefore we try to transfer data.
+
+The algorithm is essentially as follows:
+1) Check for an available local and remote entry
+2) For each link in the chain, set up a DMA transfer
+3) Move the entries to the used ring, do not update the used index
+4) Schedule a DMA callback to happen when the DMA finishes
+5) Start the DMA transfer
+6) When the DMA finishes, the callback updates the used indices and
+   triggers any necessary callbacks
+
+You will notice that the algorithm has no way of handling chains that are
+not exactly the same on the host and guest system. Without setting any of
+the fancier virtio_net features, this is the case.
+
+The chains currently have an entry which is 10 bytes long, for virtio_net
+metadata, and then a 1518 byte entry, for the actual packet data.
+
+=== Startup Sequence ===
+There are currently problems in the startup sequence between the host and
+guest drivers. The current scheme assumes that the guest is up and waiting
+before the host is ready. I am having a very hard time coming up with a scheme
+that is perfectly safe, where either side could win the race and be ready
+first.
+
+Even harder is a situation where you would like to use the "network device"
+from your bootloader to tftp a kernel, then boot Linux. In this case,
+Linux has no knowledge of where the device descriptors were before it booted.
+You'd need to stop and re-start the host driver to make sure it re-initializes
+the new descriptor memory after Linux has booted.
+
+This is a definite "needs work" item.
diff --git a/arch/powerpc/boot/dts/mpc834x_mds.dts b/arch/powerpc/boot/dts/mpc834x_mds.dts
index d9adba0..5c7617d 100644
--- a/arch/powerpc/boot/dts/mpc834x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc834x_mds.dts
@@ -104,6 +104,13 @@
 			mode = "cpu";
 		};
 
+		message-unit@8030 {
+			compatible = "fsl,mpc8349-mu";
+			reg = <0x8030 0xd0>;
+			interrupts = <69 0x8>;
+			interrupt-parent = <&ipic>;
+		};
+
 		dma@82a8 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
index 3dd6294..efcf56b 100644
--- a/drivers/virtio/Kconfig
+++ b/drivers/virtio/Kconfig
@@ -33,3 +33,25 @@ config VIRTIO_BALLOON
 
 	 If unsure, say M.
 
+config VIRTIO_OVER_PCI_HOST
+	tristate "Virtio-over-PCI Host support (EXPERIMENTAL)"
+	depends on PCI && EXPERIMENTAL
+	select VIRTIO
+	---help---
+	  This driver provides the host support necessary for using virtio
+	  over the PCI bus with a Freescale MPC8349EMDS evaluation board.
+
+	  If unsure, say N.
+
+config VIRTIO_OVER_PCI_FSL
+	tristate "Virtio-over-PCI Guest support (EXPERIMENTAL)"
+	depends on MPC834x_MDS && EXPERIMENTAL
+	select VIRTIO
+	select DMA_ENGINE
+	select FSL_DMA
+	---help---
+	  This driver provides the guest support necessary for using virtio
+	  over the PCI bus.
+
+	  If unsure, say N.
+
diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
index 6738c44..f31afaa 100644
--- a/drivers/virtio/Makefile
+++ b/drivers/virtio/Makefile
@@ -2,3 +2,5 @@ obj-$(CONFIG_VIRTIO) += virtio.o
 obj-$(CONFIG_VIRTIO_RING) += virtio_ring.o
 obj-$(CONFIG_VIRTIO_PCI) += virtio_pci.o
 obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
+obj-$(CONFIG_VIRTIO_OVER_PCI_HOST) += vop_host.o
+obj-$(CONFIG_VIRTIO_OVER_PCI_FSL) += vop_fsl.o
diff --git a/drivers/virtio/vop.h b/drivers/virtio/vop.h
new file mode 100644
index 0000000..dd2c022
--- /dev/null
+++ b/drivers/virtio/vop.h
@@ -0,0 +1,119 @@
+/*
+ * Virtio-over-PCI definitions
+ *
+ * Copyright (c) 2009 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#ifndef VOP_H
+#define VOP_H
+
+#include <linux/types.h>
+
+/* The number of entries per ring (MUST be a power of two) */
+#define VOP_RING_SIZE		64
+
+/* Marks a buffer as continuing via the next field */
+#define VOP_DESC_F_NEXT		1
+/* Marks a buffer as write-only (otherwise read-only) */
+#define VOP_DESC_F_WRITE	2
+
+/* Interrupts should not be generated when adding to avail or used */
+#define VOP_F_NO_INTERRUPT	1
+
+/* Virtio-over-PCI descriptors: 12 bytes. These can chain together via "next" */
+struct vop_desc {
+	/* Address (host physical) */
+	__le32 addr;
+	/* Length (bytes) */
+	__le32 len;
+	/* Flags */
+	__le16 flags;
+	/* Chaining for descriptors */
+	__le16 next;
+} __attribute__((packed));
+
+/* Virtio-over-PCI used descriptor chains: 8 bytes */
+struct vop_used_elem {
+	/* Start index of used descriptor chain */
+	__le32 id;
+	/* Total length of the descriptor chain which was used (written to) */
+	__le32 len;
+} __attribute__((packed));
+
+/* The ring in host memory, only written by the guest */
+/* NOTE: with VOP_RING_SIZE == 64, this is 520 bytes */
+struct vop_host_ring {
+	/* The flags, so the guest can indicate that it doesn't want
+	 * interrupts when things are added to the avail ring */
+	__le16 flags;
+
+	/* The index, which points at the next slot where a chain index
+	 * will be added to the used ring */
+	__le16 used_idx;
+
+	/* The used ring */
+	struct vop_used_elem used[VOP_RING_SIZE];
+} __attribute__((packed));
+
+/* The ring in guest memory, only written by the host */
+/* NOTE: with VOP_RING_SIZE == 64, this is 904 bytes! */
+struct vop_guest_ring {
+	/* The descriptors */
+	struct vop_desc desc[VOP_RING_SIZE];
+
+	/* The flags, so the host can indicate that it doesn't want
+	 * interrupts when things are added to the used ring */
+	__le16 flags;
+
+	/* The index, which points at the next slot where a chain index
+	 * will be added to the avail ring */
+	__le16 avail_idx;
+
+	/* The avail ring */
+	__le16 avail[VOP_RING_SIZE];
+} __attribute__((packed));
+
+/*
+ * This is the status structure holding the virtio_device status
+ * as well as the feature bits for this device and the configuration
+ * space.
+ *
+ * NOTE: it is for the LOCAL device. This is the slow path, so
+ * NOTE: the mmio reads won't cause any speed problems
+ */
+struct vop_status {
+	/* Status bits for the device */
+	__le32 status;
+
+	/* Feature bits for the device */
+	__le32 features;
+
+	/* Configuration space (different for each device type) */
+	u8 config[1016];
+
+} __attribute__((packed));
+
+/*
+ * Layout in memory
+ *
+ * |--------------------------|
+ * | 0: local device status   |
+ * |--------------------------|
+ * | 1024: host/guest ring 1  |
+ * |--------------------------|
+ * | 2048: host/guest ring 2  |
+ * |--------------------------|
+ * | 3072: host/guest ring 3  |
+ * |--------------------------|
+ *
+ * Now, you have one of these for each virtio device, and
+ * then you're pretty much set. You can expose 16K of memory
+ * out on the bus (on each side) and have 4 virtio devices,
+ * each with a different type, and 3 virtqueues
+ */
+
+#endif /* VOP_H */
diff --git a/drivers/virtio/vop_fsl.c b/drivers/virtio/vop_fsl.c
new file mode 100644
index 0000000..52e7e16
--- /dev/null
+++ b/drivers/virtio/vop_fsl.c
@@ -0,0 +1,1911 @@
+/*
+ * Virtio-over-PCI MPC8349EMDS Guest Driver
+ *
+ * Copyright (c) 2009 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/of_platform.h>
+#include <linux/io.h>
+#include <linux/dma-mapping.h>
+#include <linux/virtio.h>
+#include <linux/virtio_config.h>
+#include <linux/interrupt.h>
+#include <linux/virtio_net.h>
+#include <linux/dmaengine.h>
+#include <linux/workqueue.h>
+#include <linux/etherdevice.h>
+
+/* MPC8349EMDS specific get_immrbase() */
+#include <sysdev/fsl_soc.h>
+
+#include "vop_hw.h"
+#include "vop.h"
+
+/*
+ * These are internal use only versions of the structures that
+ * are exported over PCI by this driver
+ *
+ * They are used internally to keep track of the PowerPC queues so that
+ * we don't have to keep flipping endianness all the time
+ */
+struct vop_loc_desc {
+	u32 addr;
+	u32 len;
+	u16 flags;
+	u16 next;
+};
+
+struct vop_loc_avail {
+	u16 index;
+	u16 ring[VOP_RING_SIZE];
+};
+
+struct vop_loc_used_elem {
+	u32 id;
+	u32 len;
+};
+
+struct vop_loc_used {
+	u16 index;
+	struct vop_loc_used_elem ring[VOP_RING_SIZE];
+};
+
+/*
+ * DMA Resolver state information
+ */
+struct vop_dma_info {
+	struct dma_chan *chan;
+
+	/* The currently processing avail entry */
+	u16 loc_avail;
+	u16 rem_avail;
+
+	/* The currently processing used entries */
+	u16 loc_used;
+	u16 rem_used;
+};
+
+struct vop_vq {
+
+	/* The actual virtqueue itself */
+	struct virtqueue vq;
+	struct device *dev;
+
+	/* The host ring address */
+	struct vop_host_ring __iomem *host;
+
+	/* The guest ring address */
+	struct vop_guest_ring *guest;
+
+	/* Our own memory descriptors */
+	struct vop_loc_desc desc[VOP_RING_SIZE];
+	struct vop_loc_avail avail;
+	struct vop_loc_used used;
+	unsigned int flags;
+
+	/* Data tokens from add_buf() */
+	void *data[VOP_RING_SIZE];
+
+	unsigned int num_free;	/* number of free descriptors in desc */
+	unsigned int free_head;	/* start of the free descriptors in desc */
+	unsigned int num_added;	/* number of entries added to desc */
+
+	u16 loc_last_used;	/* the last local used entry processed */
+	u16 rem_last_used;	/* the current value of remote used_idx */
+
+	/* DMA resolver state */
+	struct vop_dma_info dma;
+	struct work_struct work;
+	int (*resolve)(struct vop_vq *vq);
+
+	void __iomem *immr;
+	int kick_val;
+};
+
+/* Convert from a struct virtqueue to a struct vop_vq */
+#define to_vop_vq(X) container_of(X, struct vop_vq, vq)
+
+/*
+ * This represents a virtio_device for our driver. It follows the memory
+ * layout shown above. It has pointers to all of the host and guest memory
+ * areas that we need to access
+ */
+struct vop_vdev {
+
+	/* The specific virtio device (console, net, blk) */
+	struct virtio_device vdev;
+
+	#define VOP_DEVICE_REGISTERED 1
+	int status;
+
+	/* Start address of local and remote memory */
+	void *loc;
+	void __iomem *rem;
+
+	/*
+	 * These are the status, feature, and configuration information
+	 * for this virtio device. They are exposed in our memory block
+	 * starting at offset 0.
+	 */
+	struct vop_status __iomem *host_status;
+
+	/*
+	 * These are the status, feature, and configuration information
+	 * for the guest virtio device. They are exposed in the guest
+	 * memory block starting at offset 0.
+	 */
+	struct vop_status *guest_status;
+
+	/*
+	 * These are the virtqueues for the virtio driver running this
+	 * device to use. The host portions are exposed in our memory block
+	 * starting at offset 1024. The exposed areas are aligned to 1024 byte
+	 * boundaries, so they appear at offets 1024, 2048, and 3072
+	 * respectively.
+	 */
+	struct vop_vq virtqueues[3];
+};
+
+#define to_vop_vdev(X) container_of(X, struct vop_vdev, vdev)
+
+struct vop_dev {
+
+	struct of_device *op;
+	struct device *dev;
+
+	/* Reset and start */
+	struct mutex mutex;
+	struct work_struct reset_work;
+	struct work_struct start_work;
+
+	int irq;
+
+	/* Our board control registers */
+	void __iomem *immr;
+
+	/* The guest memory, exposed at PCI BAR1 */
+	#define VOP_GUEST_MEM_SIZE 16384
+	void *guest_mem;
+	dma_addr_t guest_mem_addr;
+
+	/* Host memory, given to us by host in OMR0 */
+	#define VOP_HOST_MEM_SIZE 16384
+	void __iomem *host_mem;
+
+	/* The virtio devices */
+	struct vop_vdev devices[4];
+	struct dma_chan *chan;
+};
+
+static const char driver_name[] = "vdev";
+
+/*----------------------------------------------------------------------------*/
+/* Whole-descriptor access helpers                                            */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * Return a copy of a local descriptor in native format for easy use
+ * of all fields
+ *
+ * @vq the virtqueue
+ * @idx the descriptor index
+ * @desc pointer to the structure to copy into
+ */
+static void vop_loc_desc(struct vop_vq *vq, unsigned int idx,
+			 struct vop_loc_desc *desc)
+{
+	BUG_ON(idx >= VOP_RING_SIZE);
+	BUG_ON(!desc);
+
+	desc->addr  = vq->desc[idx].addr;
+	desc->len   = vq->desc[idx].len;
+	desc->flags = vq->desc[idx].flags;
+	desc->next  = vq->desc[idx].next;
+}
+
+/*
+ * Return a copy of a remote descriptor in native format for easy use
+ * of all fields
+ *
+ * @vq the virtqueue
+ * @idx the descriptor index
+ * @desc pointer to the structure to copy into
+ */
+static void vop_rem_desc(struct vop_vq *vq, unsigned int idx,
+			 struct vop_loc_desc *desc)
+{
+	BUG_ON(idx >= VOP_RING_SIZE);
+	BUG_ON(!desc);
+
+	desc->addr  = le32_to_cpu(vq->guest->desc[idx].addr);
+	desc->len   = le32_to_cpu(vq->guest->desc[idx].len);
+	desc->flags = le16_to_cpu(vq->guest->desc[idx].flags);
+	desc->next  = le16_to_cpu(vq->guest->desc[idx].next);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Local descriptor ring access helpers                                       */
+/*----------------------------------------------------------------------------*/
+
+static void vop_set_desc_addr(struct vop_vq *vq, unsigned int idx, u32 addr)
+{
+	vq->desc[idx].addr = addr;
+}
+
+static void vop_set_desc_len(struct vop_vq *vq, unsigned int idx, u32 len)
+{
+	vq->desc[idx].len = len;
+}
+
+static void vop_set_desc_flags(struct vop_vq *vq, unsigned int idx, u16 flags)
+{
+	vq->desc[idx].flags = flags;
+}
+
+static void vop_set_desc_next(struct vop_vq *vq, unsigned int idx, u16 next)
+{
+	vq->desc[idx].next = next;
+}
+
+static u16 vop_get_desc_flags(struct vop_vq *vq, unsigned int idx)
+{
+	return vq->desc[idx].flags;
+}
+
+static u16 vop_get_desc_next(struct vop_vq *vq, unsigned int idx)
+{
+	return vq->desc[idx].next;
+}
+
+/*----------------------------------------------------------------------------*/
+/* Status Helpers                                                             */
+/*----------------------------------------------------------------------------*/
+
+static u32 vop_get_host_status(struct vop_vdev *vdev)
+{
+	return ioread32(&vdev->host_status->status);
+}
+
+static u32 vop_get_host_features(struct vop_vdev *vdev)
+{
+	return ioread32(&vdev->host_status->features);
+}
+
+static u16 vop_get_host_flags(struct vop_vq *vq)
+{
+	return le16_to_cpu(vq->guest->flags);
+}
+
+/*
+ * Set the guest's flags variable (lives in host memory)
+ */
+static void vop_set_guest_flags(struct vop_vq *vq, u16 flags)
+{
+	iowrite16(flags, &vq->host->flags);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Remote Ring Debugging Helpers                                              */
+/*----------------------------------------------------------------------------*/
+
+#ifdef DEBUG_DUMP_RINGS
+static void dump_rem_desc(struct vop_vq *vq)
+{
+	struct vop_loc_desc desc;
+	int i;
+
+	dev_dbg(vq->dev, "REM DESC 0xADDRESSX LENGTH 0xFLAG NEXT\n");
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		vop_rem_desc(vq, i, &desc);
+		dev_dbg(vq->dev, "DESC %.2d: 0x%.8x %.6d 0x%.4x %.2d\n",
+				i, desc.addr, desc.len, desc.flags, desc.next);
+	}
+}
+
+static void dump_rem_avail(struct vop_vq *vq)
+{
+	int i;
+
+	dev_dbg(vq->dev, "REM AVAIL IDX %.2d\n", le16_to_cpu(vq->guest->avail_idx));
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		dev_dbg(vq->dev, "REM AVAIL %.2d: %.2d\n",
+				i, le16_to_cpu(vq->guest->avail[i]));
+	}
+}
+
+static void dump_rem_used(struct vop_vq *vq)
+{
+	int i;
+
+	dev_dbg(vq->dev, "REM USED IDX %.2d\n", ioread16(&vq->host->used_idx));
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		dev_dbg(vq->dev, "REM USED %.2d: %.2d %.6d\n", i,
+				ioread32(&vq->host->used[i].id),
+				ioread32(&vq->host->used[i].len));
+	}
+}
+
+static void dump_rem_rings(struct vop_vq *vq)
+{
+	dump_rem_desc(vq);
+	dump_rem_avail(vq);
+	dump_rem_used(vq);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Local Ring Debugging Helpers                                               */
+/*----------------------------------------------------------------------------*/
+
+static void dump_loc_desc(struct vop_vq *vq)
+{
+	struct vop_loc_desc desc;
+	int i;
+
+	dev_dbg(vq->dev, "LOC DESC 0xADDRESSX LENGTH 0xFLAG NEXT\n");
+	for (i = 0 ; i < VOP_RING_SIZE; i++) {
+		vop_loc_desc(vq, i, &desc);
+		dev_dbg(vq->dev, "DESC %.2d: 0x%.8x %.6d 0x%.4x %.2d\n",
+				i, desc.addr, desc.len, desc.flags, desc.next);
+	}
+}
+
+static void dump_loc_avail(struct vop_vq *vq)
+{
+	int i;
+
+	dev_dbg(vq->dev, "LOC AVAIL IDX %.2d\n", vq->avail.index);
+	for (i = 0; i < VOP_RING_SIZE; i++)
+		dev_dbg(vq->dev, "LOC AVAIL %.2d: %.2d\n", i, vq->avail.ring[i]);
+}
+
+static void dump_loc_used(struct vop_vq *vq)
+{
+	int i;
+
+	dev_dbg(vq->dev, "LOC USED IDX %.2hu\n", vq->used.index);
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		dev_dbg(vq->dev, "LOC USED %.2d: %.2d %.6d\n", i,
+				vq->used.ring[i].id, vq->used.ring[i].len);
+	}
+}
+
+static void dump_loc_rings(struct vop_vq *vq)
+{
+	dump_loc_desc(vq);
+	dump_loc_avail(vq);
+	dump_loc_used(vq);
+}
+
+static void debug_dump_rings(struct vop_vq *vq, const char *msg)
+{
+	dev_dbg(vq->dev, "\n");
+	dev_dbg(vq->dev, "%s\n", msg);
+	dump_loc_rings(vq);
+	dump_rem_rings(vq);
+	dev_dbg(vq->dev, "\n");
+}
+#else
+static void debug_dump_rings(struct vop_vq *vq, const char *msg)
+{
+	/* Nothing */
+}
+#endif
+
+/*----------------------------------------------------------------------------*/
+/* Scatterlist DMA helpers                                                    */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * This function abuses some of the scatterlist code and implements
+ * dma_map_sg() in such a way that we don't need to keep the scatterlist
+ * around in order to unmap it.
+ *
+ * It is also designed to never merge scatterlist entries, which is
+ * never what we want for virtio.
+ *
+ * When it is time to unmap the buffer, you can use dma_unmap_single() to
+ * unmap each entry in the chain. Get the address, length, and direction
+ * from the descriptors! (keep a local copy for speed)
+ */
+static int vop_dma_map_sg(struct device *dev, struct scatterlist sg[],
+			  unsigned int out, unsigned int in)
+{
+	dma_addr_t addr;
+	enum dma_data_direction dir;
+	struct scatterlist *start;
+	unsigned int i, failure;
+
+	start = sg;
+
+	for (i = 0; i < out + in; i++) {
+
+		/* Check for scatterlist chaining abuse */
+		BUG_ON(sg == NULL);
+
+		dir = (i < out) ? DMA_TO_DEVICE : DMA_FROM_DEVICE;
+		addr = dma_map_single(dev, sg_virt(sg), sg->length, dir);
+
+		if (dma_mapping_error(dev, addr))
+			goto unwind;
+
+		sg_dma_address(sg) = addr;
+		sg = sg_next(sg);
+	}
+
+	return 0;
+
+unwind:
+	failure = i;
+	sg = start;
+
+	for (i = 0; i < failure; i++) {
+		dir = (i < out) ? DMA_TO_DEVICE : DMA_FROM_DEVICE;
+		addr = sg_dma_address(sg);
+
+		dma_unmap_single(dev, addr, sg->length, dir);
+		sg = sg_next(sg);
+	}
+
+	return -ENOMEM;
+}
+
+/*----------------------------------------------------------------------------*/
+/* DMA Helpers                                                                */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * Transfer data between two physical addresses with DMA
+ *
+ * NOTE: does not automatically unmap the src and dst addresses
+ *
+ * @chan the channel to use
+ * @dst the physical destination address
+ * @src the physical source address
+ * @len the length to transfer (in bytes)
+ * @return a valid cookie, or -ERRNO
+ */
+static dma_cookie_t dma_async_memcpy_raw_to_raw(struct dma_chan *chan,
+					       dma_addr_t dst,
+					       dma_addr_t src,
+					       size_t len)
+{
+	struct dma_device *dev = chan->device;
+	struct dma_async_tx_descriptor *tx;
+	enum dma_ctrl_flags flags;
+	dma_cookie_t cookie;
+	int cpu;
+
+	flags = DMA_COMPL_SKIP_SRC_UNMAP | DMA_COMPL_SKIP_DEST_UNMAP;
+	tx = dev->device_prep_dma_memcpy(chan, dst, src, len, flags);
+	if (!tx)
+		return -ENOMEM;
+
+	tx->callback = NULL;
+	cookie = tx->tx_submit(tx);
+
+	cpu = get_cpu();
+	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
+	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
+	put_cpu();
+
+	return cookie;
+}
+
+/*
+ * Trigger an interrupt after all DMA issued up to this point
+ * have been processed
+ *
+ * @chan the channel to use
+ * @callback the function to call (must not sleep)
+ * @data the data to send to the callback
+ *
+ * @return a valid cookie, or -ERRNO
+ */
+static dma_cookie_t dma_async_interrupt(struct dma_chan *chan,
+					dma_async_tx_callback callback,
+					void *data)
+{
+	struct dma_device *dev = chan->device;
+	struct dma_async_tx_descriptor *tx;
+
+	/* Set up the DMA */
+	tx = dev->device_prep_dma_interrupt(chan, DMA_PREP_INTERRUPT);
+	if (!tx)
+		return -ENOMEM;
+
+	tx->callback = callback;
+	tx->callback_param = data;
+
+	return tx->tx_submit(tx);
+}
+
+/*----------------------------------------------------------------------------*/
+/* DMA Resolver                                                               */
+/*----------------------------------------------------------------------------*/
+
+static void vop_remote_used_changed(struct vop_vq *vq)
+{
+	dev_dbg(vq->dev, "%s\n", __func__);
+
+	if (!(vop_get_host_flags(vq) & VOP_F_NO_INTERRUPT)) {
+		dev_dbg(vq->dev, "notifying the host (new buffers in used)\n");
+		iowrite32(vq->kick_val, vq->immr + ODR_OFFSET);
+	}
+}
+
+static void vop_local_used_changed(struct vop_vq *vq)
+{
+	dev_dbg(vq->dev, "%s\n", __func__);
+
+	if (!(vq->flags & VOP_F_NO_INTERRUPT)) {
+		dev_dbg(vq->dev, "notifying self (new buffers in used)\n");
+		vq->vq.callback(&vq->vq);
+	}
+}
+
+/*
+ * DMA callback function
+ *
+ * This is called every time a DMA transfer completes, and will increment the
+ * indices in the local and remote used rings, then notify both sides that
+ * their used ring has changed
+ *
+ * You must be sure that the data was actually written to the used rings before
+ * this function is called
+ *
+ * Since exactly one descriptor is used from each avail ring per DMA transfer,
+ * the indices only need to be incremented once.
+ */
+static void dma_callback(void *data)
+{
+	struct vop_vq *vq = data;
+
+	/* Write the local used index */
+	vq->used.index++;
+
+	/* Write the remote used index */
+	vq->rem_last_used++;
+	iowrite16(vq->rem_last_used, &vq->host->used_idx);
+
+	/* Make sure the indices are written before triggering callbacks */
+	wmb();
+
+	/* Trigger the local used callback */
+	dev_dbg(vq->dev, "local used changed, running callback\n");
+	vop_local_used_changed(vq);
+
+	/* Trigger the remote used callback */
+	dev_dbg(vq->dev, "remote used changed, running callback\n");
+	vop_remote_used_changed(vq);
+}
+
+/*
+ * Take an entry from the local avail ring and add it to the local
+ * used ring with the given length
+ *
+ * NOTE: does not update the used index
+ *
+ * @vq the virtqueue
+ * @avail_idx the index in the avail ring to take the entry from
+ * @used_idx the index in the used ring to put the entry
+ * @used_len the length used
+ */
+static void vop_loc_avail_to_used(struct vop_vq *vq, unsigned int avail_idx,
+				  unsigned int used_idx, u32 used_len)
+{
+	u16 id;
+
+	/* Make sure the indices are inside the rings */
+	avail_idx &= (VOP_RING_SIZE - 1);
+	used_idx  &= (VOP_RING_SIZE - 1);
+
+	/* Get the index stored in the avail ring */
+	id = vq->avail.ring[avail_idx];
+
+	/* Copy the index and length to the used ring */
+	vq->used.ring[used_idx].id = id;
+	vq->used.ring[used_idx].len = used_len;
+}
+
+/*
+ * Take an entry from the remote avail ring and add it to the remote
+ * used ring with the given length
+ *
+ * NOTE: does not update the used index
+ *
+ * @vq the virtqueue
+ * @avail_idx the index in the avail ring to take the entry from
+ * @used_idx the index in the used ring to put the entry
+ * @used_len the length used
+ */
+static void vop_rem_avail_to_used(struct vop_vq *vq, unsigned int avail_idx,
+				  unsigned int used_idx, u32 used_len)
+{
+	u16 id;
+
+	/* Make sure the indices are inside the rings */
+	avail_idx &= (VOP_RING_SIZE - 1);
+	used_idx  &= (VOP_RING_SIZE - 1);
+
+	/* Get the index stored in the avail ring */
+	id = le16_to_cpu(vq->guest->avail[avail_idx]);
+
+	/* Copy the index and length to the used ring */
+	iowrite32(id, &vq->host->used[used_idx].id);
+	iowrite32(used_len, &vq->host->used[used_idx].len);
+}
+
+/*
+ * Return the number of entries available in the local avail ring
+ */
+static unsigned int loc_num_avail(struct vop_vq *vq)
+{
+	return vq->avail.index - vq->dma.loc_avail;
+}
+
+/*
+ * Return the number of entries available in the remote avail ring
+ */
+static unsigned int rem_num_avail(struct vop_vq *vq)
+{
+	return le16_to_cpu(vq->guest->avail_idx) - vq->dma.rem_avail;
+}
+
+/*
+ * Return the length of a descriptor chain, in entries (not bytes)
+ *
+ * @vq the virtqueue
+ * @idx the start descriptor in the chain
+ */
+static unsigned int loc_chain_len(struct vop_vq *vq, unsigned int idx)
+{
+	struct vop_loc_desc desc;
+	unsigned int ret = 0;
+
+	/* Make sure the index is inside the ring */
+	idx &= (VOP_RING_SIZE - 1);
+
+	while (true) {
+		vop_loc_desc(vq, idx, &desc);
+		ret++;
+
+		if (desc.flags & VOP_DESC_F_NEXT)
+			idx = desc.next;
+		else
+			break;
+	}
+
+	return ret;
+}
+
+/*
+ * Return the length of a descriptor chain, in entries (not bytes)
+ *
+ * @vq the virtqueue
+ * @idx the start descriptor in the chain
+ */
+static unsigned int rem_chain_len(struct vop_vq *vq, unsigned int idx)
+{
+	struct vop_loc_desc desc;
+	unsigned int ret = 0;
+
+	/* Make sure the index is inside the ring */
+	idx &= (VOP_RING_SIZE - 1);
+
+	while (true) {
+		vop_rem_desc(vq, idx, &desc);
+		ret++;
+
+		if (desc.flags & VOP_DESC_F_NEXT)
+			idx = desc.next;
+		else
+			break;
+	}
+
+	return ret;
+}
+
+/*
+ * Return a descriptor id from the local avail ring
+ *
+ * @vq the virtqueue
+ * @idx the index to return the id from
+ */
+static u16 vop_loc_avail_id(struct vop_vq *vq, unsigned int idx)
+{
+	idx &= (VOP_RING_SIZE - 1);
+	return vq->avail.ring[idx];
+}
+
+/*
+ * Return a descriptor id from the remote avail ring
+ *
+ * @vq the virtqueue
+ * @idx the index to return the id from
+ */
+static u16 vop_rem_avail_id(struct vop_vq *vq, unsigned int idx)
+{
+	idx &= (VOP_RING_SIZE - 1);
+	return le16_to_cpu(vq->guest->avail[idx]);
+}
+
+/*
+ * Transmit the next local available entry to the next remote available entry
+ *
+ * If an error occurs while setting up the transfer, no state will be changed,
+ * and you can just call this function again to retry the transfer
+ */
+static int vop_dma_xmit(struct vop_vq *vq)
+{
+	struct vop_dma_info *dma = &vq->dma;
+	struct dma_chan *chan = dma->chan;
+	dma_cookie_t cookie;
+
+	/* Current local and remote descriptor indices */
+	unsigned int loc_idx, rem_idx;
+
+	/* Current local and remote descriptors */
+	struct vop_loc_desc loc, rem;
+
+	/* DMA source, destination, and length */
+	dma_addr_t src, dst;
+	size_t len;
+
+	/* Total number of bytes used for this transfer */
+	size_t total = 0;
+
+	/* Check that there is a local descriptor available */
+	if (!loc_num_avail(vq)) {
+		dev_dbg(vq->dev, "No local descriptors available\n");
+		return -ENOSPC;
+	}
+
+	/* Check that there is a remote descriptor available */
+	if (!rem_num_avail(vq)) {
+		dev_dbg(vq->dev, "No remote descriptors available\n");
+		return -ENOSPC;
+	}
+
+	/*
+	 * Transfer the local chain to the remote side
+	 *
+	 * 1) Get the next available local and remote descriptors
+	 * 2) For each link in the chain, set up the DMA
+	 * 3) Add the descriptors to the used rings
+	 * 4) Set up DMA interrupt to update used indices
+	 * 5) Start the DMA
+	 *
+	 * If at any point an error happens, we leave the routine
+	 * immediately. Next time it is called, we will start at
+	 * the same place and re-try the transfer
+	 */
+
+	/* Get the starting entry from each available ring */
+	loc_idx = vop_loc_avail_id(vq, dma->loc_avail);
+	rem_idx = vop_rem_avail_id(vq, dma->rem_avail);
+
+	/* We currently don't handle the case where the number of buffers
+	 * in the local chain is less than the number in the remote chain */
+	BUG_ON(loc_chain_len(vq, loc_idx) < rem_chain_len(vq, rem_idx));
+
+	while (true) {
+		/* Get the current descriptor */
+		vop_loc_desc(vq, loc_idx, &loc);
+		vop_rem_desc(vq, rem_idx, &rem);
+
+		/* The virtio drivers don't expect to have more entries than
+		 * they gave you initially. virtio_net stores the number of
+		 * expected entries in the custom header, so we can't increase
+		 * the number actually used */
+		BUG_ON(loc.len > rem.len);
+
+		dst = rem.addr + 0x80000000;
+		src = loc.addr;
+		len = loc.len;
+		total += loc.len;
+
+		dev_dbg(vq->dev, "DMA xmit dst %.8x src %.8x len %d\n", dst, src, len);
+		cookie = dma_async_memcpy_raw_to_raw(chan, dst, src, len);
+		if (dma_submit_error(cookie)) {
+			dev_err(vq->dev, "DMA submit error\n");
+			return -ENOMEM;
+		}
+
+		/* Check if there are more entries, otherwise we're done */
+		if (loc.flags & VOP_DESC_F_NEXT) {
+			BUG_ON(!(rem.flags & VOP_DESC_F_NEXT));
+
+			loc_idx = loc.next;
+			rem_idx = rem.next;
+		} else {
+			break;
+		}
+	}
+
+	/* Add the descriptors to the local and remote used rings */
+	vop_loc_avail_to_used(vq, dma->loc_avail, dma->loc_used, total);
+	vop_rem_avail_to_used(vq, dma->rem_avail, dma->rem_used, total);
+
+	/* Make very sure that everything written to the rings actually happened
+	 * before the DMA callback can be triggered */
+	wmb();
+
+	/* Trigger an interrupt when the DMA completes to update the used
+	 * indices and trigger the necessary callbacks */
+	cookie = dma_async_interrupt(chan, dma_callback, vq);
+	if (dma_submit_error(cookie)) {
+		dev_err(vq->dev, "DMA interrupt submit error\n");
+		return -ENOMEM;
+	}
+
+	/* Everything was successful, so update the DMA resolver's state */
+	dma->loc_avail++;
+	dma->rem_avail++;
+	dma->loc_used++;
+	dma->rem_used++;
+
+	/* Start the DMA */
+	dev_dbg(vq->dev, "DMA xmit setup successful, starting\n");
+	dma_async_memcpy_issue_pending(chan);
+
+	return 0;
+}
+
+/*
+ * Receive the next remote available entry to the next local available entry
+ *
+ * If an error occurs while setting up the transfer, no state will be changed,
+ * and you can just call this function again to retry the transfer
+ */
+static int vop_dma_recv(struct vop_vq *vq)
+{
+	struct vop_dma_info *dma = &vq->dma;
+	struct dma_chan *chan = dma->chan;
+	dma_cookie_t cookie;
+
+	/* Current local and remote descriptor indices */
+	unsigned int loc_idx, rem_idx;
+
+	/* Current local and remote descriptors */
+	struct vop_loc_desc loc, rem;
+
+	/* DMA source, destination, and length */
+	dma_addr_t src, dst;
+	size_t len;
+
+	/* Total number of bytes used in this transfer */
+	size_t total = 0;
+
+	/* Check that there is a local descriptor available */
+	if (!loc_num_avail(vq)) {
+		dev_dbg(vq->dev, "No local descriptors available\n");
+		return -ENOSPC;
+	}
+
+	/* Check that there is a remote descriptor available */
+	if (!rem_num_avail(vq)) {
+		dev_dbg(vq->dev, "No remote descriptors available\n");
+		return -ENOSPC;
+	}
+
+	/*
+	 * Transfer the remote chain to the local side
+	 *
+	 * 1) Get the next available remote and local descriptors
+	 * 2) For each link in the chain, set up DMA
+	 * 3) Add the descriptors to the used rings
+	 * 4) Set up DMA interrupt to update used indices
+	 * 5) Start the DMA
+	 *
+	 * If at any point an error happens, we leave the routine
+	 * immediately. Next time it is called, we will start at
+	 * the same place and re-try the transfer
+	 */
+
+	/* Get the starting entry from each available ring */
+	loc_idx = vop_loc_avail_id(vq, dma->loc_avail);
+	rem_idx = vop_rem_avail_id(vq, dma->rem_avail);
+
+	/* We currently don't handle the case where the number of buffers
+	 * in the remote chain is less than the number in the local chain */
+	BUG_ON(rem_chain_len(vq, rem_idx) < loc_chain_len(vq, loc_idx));
+
+	while (true) {
+		/* Get the current descriptors */
+		vop_loc_desc(vq, loc_idx, &loc);
+		vop_rem_desc(vq, rem_idx, &rem);
+
+		/* The virtio drivers don't expect to have more entries than
+		 * they gave you initially. virtio_net stores the number of
+		 * expected entries in the custom header, so we can't increase
+		 * the number actually used */
+		BUG_ON(rem.len > loc.len);
+
+		dst = loc.addr;
+		src = rem.addr + 0x80000000;
+		len = rem.len;
+		total += rem.len;
+
+		dev_dbg(vq->dev, "DMA recv dst %.8x src %.8x len %d\n", dst, src, len);
+		cookie = dma_async_memcpy_raw_to_raw(chan, dst, src, len);
+		if (dma_submit_error(cookie)) {
+			dev_err(vq->dev, "DMA submit error\n");
+			return -ENOMEM;
+		}
+
+		/* Check if there are more entries, otherwise we're done */
+		if (rem.flags & VOP_DESC_F_NEXT) {
+			BUG_ON(!(loc.flags & VOP_DESC_F_NEXT));
+
+			loc_idx = loc.next;
+			rem_idx = rem.next;
+		} else {
+			break;
+		}
+	}
+
+	/* Add the descriptors to the local and remote used rings */
+	vop_loc_avail_to_used(vq, dma->loc_avail, dma->loc_used, total);
+	vop_rem_avail_to_used(vq, dma->rem_avail, dma->rem_used, total);
+
+	/* Make very sure that everything written to the rings actually happened
+	 * before the DMA callback can be triggered */
+	wmb();
+
+	/* Trigger an interrupt when the DMA completes to update the used
+	 * indices and trigger the necessary callbacks */
+	cookie = dma_async_interrupt(chan, dma_callback, vq);
+	if (dma_submit_error(cookie)) {
+		dev_err(vq->dev, "DMA interrupt submit error\n");
+		return -ENOMEM;
+	}
+
+	/* Everything was successful, so update the DMA resolver's state */
+	dma->loc_avail++;
+	dma->rem_avail++;
+	dma->loc_used++;
+	dma->rem_used++;
+
+	/* Start the DMA */
+	dev_dbg(vq->dev, "DMA recv setup successful, starting\n");
+	dma_async_memcpy_issue_pending(chan);
+
+	return 0;
+}
+
+/*----------------------------------------------------------------------------*/
+/* Virtqueue Ops Infrastructure                                               */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * Add a buffer to our local descriptors and the local avail ring
+ *
+ * NOTE: there hasn't been any transfer yet, just adding to local
+ * NOTE: rings. The kick() will process any DMA that needs to happen
+ *
+ * @return 0 on success, -ERRNO otherwise
+ */
+static int vop_add_buf(struct virtqueue *_vq, struct scatterlist sg[],
+		       unsigned int out, unsigned int in, void *data)
+{
+	/* For now, we'll just add the buffers to our local descriptors and
+	 * avail ring */
+	struct vop_vq *vq = to_vop_vq(_vq);
+	unsigned int i, avail, head, uninitialized_var(prev);
+
+	BUG_ON(data == NULL);
+	BUG_ON(out + in == 0);
+
+	/* Make sure we have space for this to succeed */
+	if (vq->num_free < out + in) {
+		dev_dbg(vq->dev, "No free space left: len=%d free=%d\n",
+				out + in, vq->num_free);
+		return -ENOSPC;
+	}
+
+	head = vq->free_head;
+
+	/* DMA map the scatterlist */
+	if (vop_dma_map_sg(vq->dev, sg, out, in)) {
+		dev_err(vq->dev, "Failed to DMA map scatterlist\n");
+		return -ENOMEM;
+	}
+
+	/* We're about to use some buffers from the free list */
+	vq->num_free -= out + in;
+
+	for (i = vq->free_head; out; i = vop_get_desc_next(vq, i), out--) {
+		vop_set_desc_flags(vq, i, VOP_DESC_F_NEXT);
+		vop_set_desc_addr(vq, i, sg_dma_address(sg));
+		vop_set_desc_len(vq, i, sg->length);
+
+		prev = i;
+		sg = sg_next(sg);
+	}
+
+	for (/* none */; in; i = vop_get_desc_next(vq, i), in--) {
+		vop_set_desc_flags(vq, i, VOP_DESC_F_NEXT | VOP_DESC_F_WRITE);
+		vop_set_desc_addr(vq, i, sg_dma_address(sg));
+		vop_set_desc_len(vq, i, sg->length);
+
+		prev = i;
+		sg = sg_next(sg);
+	}
+
+	/* Last one doesn't continue */
+	vop_set_desc_flags(vq, prev, vop_get_desc_flags(vq, prev) & ~VOP_DESC_F_NEXT);
+
+	/* Update the free pointer */
+	vq->free_head = i;
+
+	/* Set token */
+	vq->data[head] = data;
+
+	/* Add an entry for the head of the chain into the avail array, but
+	 * don't update avail->idx until kick() */
+	avail = (vq->avail.index + vq->num_added++) & (VOP_RING_SIZE - 1);
+	vq->avail.ring[avail] = head;
+
+	dev_dbg(vq->dev, "Added buffer head %i to %p\n", head, vq);
+	debug_dump_rings(vq, "Added buffer(s), dumping rings");
+
+	return 0;
+}
+
+static inline bool loc_more_used(const struct vop_vq *vq)
+{
+	return vq->loc_last_used != vq->used.index;
+}
+
+static void detach_buf(struct vop_vq *vq, unsigned int head)
+{
+	dma_addr_t addr;
+	unsigned int idx, len;
+	enum dma_data_direction dir;
+	struct vop_loc_desc desc;
+
+	/* Clear data pointer */
+	vq->data[head] = NULL;
+
+	/* Put the chain back on the free list, unmapping as we go */
+	idx = head;
+	while (true) {
+		vop_loc_desc(vq, idx, &desc);
+
+		addr = desc.addr;
+		len  = desc.len;
+		dir  = (desc.flags & VOP_DESC_F_WRITE) ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
+
+		/* Unmap the entry */
+		dma_unmap_single(vq->dev, addr, len, dir);
+		vq->num_free++;
+
+		/* If there is no next descriptor, we're done */
+		if (!(desc.flags & VOP_DESC_F_NEXT))
+			break;
+
+		idx = desc.next;
+	}
+
+	vop_set_desc_next(vq, idx, vq->free_head);
+	vq->free_head = head;
+}
+
+/*
+ * Get a buffer from the used ring
+ *
+ * @return the data token given to add_buf(), or NULL if there
+ *         are no remaining buffers
+ */
+static void *vop_get_buf(struct virtqueue *_vq, unsigned int *len)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+	unsigned int head, used;
+	void *ret;
+
+	if (!loc_more_used(vq)) {
+		dev_dbg(vq->dev, "No more buffers in queue\n");
+		return NULL;
+	}
+
+	used = vq->loc_last_used & (VOP_RING_SIZE - 1);
+	head = vq->used.ring[used].id;
+	*len = vq->used.ring[used].len;
+
+	BUG_ON(head >= VOP_RING_SIZE);
+	BUG_ON(!vq->data[head]);
+
+	/* detach_buf() clears data, save it now */
+	ret = vq->data[head];
+	detach_buf(vq, head);
+
+	/* Update the last local used_idx */
+	vq->loc_last_used++;
+
+	return ret;
+}
+
+/*
+ * The avail ring changed, so we need to start as much DMA as we can
+ */
+static void vop_kick(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+
+	dev_dbg(vq->dev, "kick: making %d new buffers available\n", vq->num_added);
+	vq->avail.index += vq->num_added;
+	vq->num_added = 0;
+
+	/* Run the DMA resolver */
+	dev_dbg(vq->dev, "kick: using resolver %pS\n", vq->resolve);
+	schedule_work(&vq->work);
+}
+
+/*
+ * Try to disable callbacks on the used ring (unreliable)
+ */
+static void vop_disable_cb(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+	struct virtio_device *vdev = _vq->vdev;
+
+	dev_dbg(&vdev->dev, "disable callbacks\n");
+	vq->flags |= VOP_F_NO_INTERRUPT;
+#if 0
+	/* I don't know why, but this can make the host have problems.
+	 * Transfer speed gets cut to 1/10th the normal rate */
+	vop_set_guest_flags(vq, VOP_F_NO_INTERRUPT);
+#endif
+}
+
+/*
+ * Enable callbacks on changes to the used ring
+ *
+ * @return false if there are more pending buffers
+ *         true otherwise
+ */
+static bool vop_enable_cb(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+
+	/* We optimistically enable interrupts, then check if there
+	 * was more work to do */
+	dev_dbg(vq->dev, "enable callbacks\n");
+	vq->flags &= ~VOP_F_NO_INTERRUPT;
+#if 0
+	/* I don't know why, but this can make the host have problems.
+	 * Transfer speed gets cut to 1/10th the normal rate */
+	vop_set_guest_flags(vq, 0);
+#endif
+
+	if (unlikely(loc_more_used(vq)))
+		return false;
+
+	return true;
+}
+
+static struct virtqueue_ops vop_vq_ops = {
+	.add_buf	= vop_add_buf,
+	.get_buf	= vop_get_buf,
+	.kick		= vop_kick,
+	.disable_cb	= vop_disable_cb,
+	.enable_cb	= vop_enable_cb,
+};
+
+/*----------------------------------------------------------------------------*/
+/* Virtio Device Infrastructure                                               */
+/*----------------------------------------------------------------------------*/
+
+/* Read some bytes from the host's configuration area */
+static void vopc_get(struct virtio_device *_vdev, unsigned offset, void *buf,
+		     unsigned len)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	void __iomem *config = vdev->host_status->config;
+
+	memcpy_fromio(buf, config + offset, len);
+}
+
+/* Write some bytes to the host's configuration area */
+static void vopc_set(struct virtio_device *_vdev, unsigned offset,
+		     const void *buf, unsigned len)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	void __iomem *config = vdev->host_status->config;
+
+	memcpy_toio(config + offset, buf, len);
+}
+
+/* Read your own status bits */
+static u8 vopc_get_status(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	u32 status;
+
+	status = le32_to_cpu(vdev->guest_status->status);
+	dev_dbg(&vdev->vdev.dev, "%s(): -> 0x%.2x\n", __func__, (u8)status);
+
+	return (u8)status;
+}
+
+static void vopc_set_status(struct virtio_device *_vdev, u8 status)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	u32 old_status;
+
+	old_status = le32_to_cpu(vdev->guest_status->status);
+	vdev->guest_status->status = cpu_to_le32(status);
+
+	dev_dbg(&vdev->vdev.dev, "%s(): <- 0x%.2x (was 0x%.2x)\n",
+			__func__, status, old_status);
+
+	/*
+	 * FIXME: we really need to notify the other side when status changes
+	 * FIXME: happen, so that they can take some action
+	 */
+}
+
+static void vopc_reset(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+
+	dev_dbg(&vdev->vdev.dev, "%s(): status reset\n", __func__);
+	vdev->guest_status->status = cpu_to_le32(0);
+}
+
+/* Find the given virtqueue */
+static struct virtqueue *vopc_find_vq(struct virtio_device *_vdev,
+					     unsigned index,
+					     void (*cb)(struct virtqueue *vq))
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	struct vop_vq *vq = &vdev->virtqueues[index];
+	int i;
+
+	/* Check that we support the virtqueue at this index */
+	if (index >= ARRAY_SIZE(vdev->virtqueues)) {
+		dev_err(&vdev->vdev.dev, "no virtqueue for index %d\n", index);
+		return ERR_PTR(-ENODEV);
+	}
+
+	/* HACK: we only support virtio_net for now */
+	if (vdev->vdev.id.device != VIRTIO_ID_NET) {
+		dev_err(&vdev->vdev.dev, "only virtio_net is supported\n");
+		return ERR_PTR(-ENODEV);
+	}
+
+	/* Initialize the virtqueue to a clean state */
+	vq->num_free = VOP_RING_SIZE;
+	vq->dev = &vdev->vdev.dev;
+	vq->vq.vq_ops = &vop_vq_ops;
+
+	/* Hook up the local virtqueues to the corresponding remote virtqueues */
+	/* TODO: maybe move this to the setup_virtio_net() function */
+	switch (index) {
+	case 0: /* x86 xmit virtqueue, hook to ppc recv virtqueue */
+		vq->guest = vdev->loc + 2048;
+		vq->host  = vdev->rem + 2048;
+		vq->resolve = vop_dma_recv;
+		vq->kick_val = 0x8;
+		break;
+	case 1: /* x86 recv virtqueue, hook to ppc xmit virtqueue */
+		vq->guest = vdev->loc + 1024;
+		vq->host  = vdev->rem + 1024;
+		vq->resolve = vop_dma_xmit;
+		vq->kick_val = 0x4;
+		break;
+	case 2: /* x86 ctrl virtqueue -- ppc ctrl virtqueue */
+	default:
+		dev_err(vq->dev, "Unsupported virtqueue\n");
+		return ERR_PTR(-ENODEV);
+	}
+
+	dev_dbg(vq->dev, "vq %d guest %p host %p\n", index, vq->guest, vq->host);
+
+	/* Initialize the descriptor, avail, and used rings */
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		vop_set_desc_addr(vq, i, 0x0);
+		vop_set_desc_len(vq, i, 0);
+		vop_set_desc_flags(vq, i, 0);
+		vop_set_desc_next(vq, i, (i + 1) & (VOP_RING_SIZE - 1));
+
+		vq->avail.ring[i] = 0;
+		vq->used.ring[i].id = 0;
+		vq->used.ring[i].len = 0;
+	}
+
+	vq->avail.index = 0;
+	vop_set_guest_flags(vq, 0);
+
+	/* This is the guest, the host has already initialized the rings for us */
+	debug_dump_rings(vq, "found a virtqueue, dumping rings");
+
+	vq->vq.callback = cb;
+	vq->vq.vdev = &vdev->vdev;
+
+	return &vq->vq;
+}
+
+static void vopc_del_vq(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+	int i;
+
+	/* FIXME: make sure that DMA has stopped by this point */
+
+	/* Unmap and remove all outstanding descriptors from the ring */
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		if (vq->data[i]) {
+			dev_dbg(vq->dev, "cleanup detach buffer at index %d\n", i);
+			detach_buf(vq, i);
+		}
+	}
+
+	debug_dump_rings(vq, "virtqueue destroyed, dumping rings");
+}
+
+/* Read the host's advertised features */
+static u32 vopc_get_features(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	u32 ret;
+
+	ret = vop_get_host_features(vdev);
+	dev_dbg(&vdev->vdev.dev, "%s(): host features 0x%.8x\n", __func__, ret);
+
+	return ret;
+}
+
+/* At this point, we've chosen whichever features we can use and
+ * put them into the vdev->features array. We should probably notify
+ * the host at this point, but how will virtio react? */
+static void vopc_finalize_features(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	struct device *dev = &vdev->vdev.dev;
+
+	/*
+	 * TODO: notify the other side at this point
+	 */
+
+	vdev->guest_status->features = cpu_to_le32(vdev->vdev.features[0]);
+	dev_dbg(dev, "%s(): final features 0x%.8lx\n", __func__, vdev->vdev.features[0]);
+}
+
+static struct virtio_config_ops vop_config_ops = {
+	.get			= vopc_get,
+	.set			= vopc_set,
+	.get_status		= vopc_get_status,
+	.set_status		= vopc_set_status,
+	.reset			= vopc_reset,
+	.find_vq		= vopc_find_vq,
+	.del_vq			= vopc_del_vq,
+	.get_features		= vopc_get_features,
+	.finalize_features	= vopc_finalize_features,
+};
+
+/*----------------------------------------------------------------------------*/
+/* Last-minute device setup code                                              */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * Do the last minute setup for virtio_net, now that the host memory is
+ * valid. This includes setting up pointers to the correct queues so that
+ * we can just start the virtqueues when the driver registers
+ */
+static void setup_virtio_net(struct vop_vdev *vdev)
+{
+	/* TODO: move some of the setup code from find_vq() here */
+}
+
+/*
+ * Do any last minute setup for a device just before starting it
+ *
+ * The host memory is now valid, so you should be setting up any pointers
+ * the device needs to the host memory
+ */
+static int vop_setup_device(struct vop_dev *priv, int devnum)
+{
+	struct vop_vdev *vdev = &priv->devices[devnum];
+	struct device *dev = priv->dev;
+
+	if (devnum >= ARRAY_SIZE(priv->devices)) {
+		dev_err(dev, "Unknown virtio_device %d\n", devnum);
+		return -ENODEV;
+	}
+
+	/* Setup the device's pointers to host memory */
+	vdev->rem = priv->host_mem  + (devnum * 4096);
+	vdev->host_status = vdev->rem;
+
+	switch (devnum) {
+	case 0: /* virtio_net */
+		setup_virtio_net(vdev);
+		break;
+	default:
+		dev_err(dev, "Device %d not implemented\n", devnum);
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+/*
+ * Initialize and attempt to register a virtio_device
+ *
+ * @priv the driver data
+ * @devnum the virtio_device number (index into priv->devices)
+ */
+static int vop_start_device(struct vop_dev *priv, int devnum)
+{
+	struct vop_vdev *vdev = &priv->devices[devnum];
+	struct device *dev = priv->dev;
+	int ret;
+
+	/* Check that we know about the device */
+	if (devnum >= ARRAY_SIZE(priv->devices)) {
+		dev_err(dev, "Unknown virtio_device %d\n", devnum);
+		return -ENODEV;
+	}
+
+	vdev->status = 0;
+
+	/* Do any last minute device-specific setup now that the
+	 * host memory is valid */
+	ret = vop_setup_device(priv, devnum);
+	if (ret) {
+		dev_err(dev, "Unable to setup device %d\n", devnum);
+		return ret;
+	}
+
+	/* Register the device with the virtio subsystem */
+	ret = register_virtio_device(&vdev->vdev);
+	if (ret) {
+		dev_err(dev, "Unable to register device %d\n", devnum);
+		return ret;
+	}
+
+	vdev->status = VOP_DEVICE_REGISTERED;
+	return 0;
+}
+
+/*----------------------------------------------------------------------------*/
+/* Work Functions                                                             */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * Start as much DMA as we can on the given virtqueue
+ *
+ * This is put on the system shared queue, and will start us much DMA as is
+ * available when it is called. This should be triggered when the host adds
+ * things to the avail rings, and when the guest adds things to the internal
+ * avail rings
+ *
+ * Make sure it doesn't sleep for too long, you're on the shared queue
+ */
+static void vop_dma_work(struct work_struct *work)
+{
+	struct vop_vq *vq = container_of(work, struct vop_vq, work);
+	int ret;
+
+	/* Start as many DMA transactions as we can, immediately */
+	while (true) {
+		ret = vq->resolve(vq);
+		if (ret)
+			break;
+	}
+}
+
+/*
+ * Remove all virtio devices immediately
+ *
+ * This will be called by the host to make sure that we are in a stopped
+ * state. It should be callable when everything is already stopped.
+ *
+ * Make sure it doesn't sleep for too long, you're on the shared queue
+ */
+static void vop_reset_work(struct work_struct *work)
+{
+	struct vop_dev *priv = container_of(work, struct vop_dev, reset_work);
+	struct device *dev = priv->dev;
+	struct vop_vdev *vdev;
+	int i;
+
+	dev_dbg(dev, "Resetting all virtio devices\n");
+	mutex_lock(&priv->mutex);
+
+	for (i = 0; i < ARRAY_SIZE(priv->devices); i++) {
+		vdev = &priv->devices[i];
+
+		if (vdev->status & VOP_DEVICE_REGISTERED) {
+			dev_dbg(dev, "Unregistering virtio_device #%d\n", i);
+			unregister_virtio_device(&vdev->vdev);
+		}
+
+		vdev->status &= ~VOP_DEVICE_REGISTERED;
+	}
+
+	if (priv->host_mem) {
+		iounmap(priv->host_mem);
+		priv->host_mem = NULL;
+	}
+
+	mutex_unlock(&priv->mutex);
+}
+
+/*
+ * This will map the host's memory, as well as start the devices that the host
+ * requested
+ *
+ * Mailbox registers contents:
+ * IMR0 - the host memory physical address (must be <1GB)
+ * IMR1 - the devices the host wants started
+ */
+static void vop_start_work(struct work_struct *work)
+{
+	struct vop_dev *priv = container_of(work, struct vop_dev, start_work);
+	struct device *dev = priv->dev;
+	struct vop_vdev *vdev;
+	u32 address, devices;
+	int i;
+
+	dev_dbg(dev, "Starting requested virtio devices\n");
+	mutex_lock(&priv->mutex);
+
+	/* Read the requested address and devices from the mailbox registers */
+	address = ioread32(priv->immr + IMR0_OFFSET);
+	devices = ioread32(priv->immr + IMR1_OFFSET);
+
+	dev_dbg(dev, "address 0x%.8x\n", address);
+	dev_dbg(dev, "devices 0x%.8x\n", devices);
+
+	/* Remap the host's registers */
+	priv->host_mem = ioremap(address + 0x80000000, VOP_HOST_MEM_SIZE);
+	if (!priv->host_mem) {
+		dev_err(dev, "Unable to ioremap host memory\n");
+		goto out_unlock;
+	}
+
+	/* Start the requested devices */
+	for (i = 0; i < ARRAY_SIZE(priv->devices); i++) {
+		vdev = &priv->devices[i];
+
+		if (devices & (1 << i)) {
+			dev_dbg(dev, "Starting virtio_device #%d\n", i);
+			vop_start_device(priv, i);
+		}
+	}
+
+out_unlock:
+	mutex_unlock(&priv->mutex);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Interrupt Handling                                                         */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * Schedule the work function for a given virtqueue only if the associated
+ * device is up and running. Otherwise, ignore the request
+ *
+ * @priv the private driver data
+ * @dev the virtio_device number in priv->devices[]
+ * @queue the virtqueue in vdev->virtqueues[]
+ */
+static void schedule_work_if_ready(struct vop_dev *priv, int dev, int queue)
+{
+	struct vop_vdev *vdev = &priv->devices[dev];
+	struct vop_vq *vq = &vdev->virtqueues[queue];
+
+	if (vdev->status & VOP_DEVICE_REGISTERED)
+		schedule_work(&vq->work);
+}
+
+static irqreturn_t vdev_interrupt(int irq, void *dev_id)
+{
+	struct vop_dev *priv = dev_id;
+	struct device *dev = priv->dev;
+	u32 imisr, idr;
+
+	imisr = ioread32(priv->immr + IMISR_OFFSET);
+	idr   = ioread32(priv->immr + IDR_OFFSET);
+
+	dev_dbg(dev, "INTERRUPT idr 0x%.8x\n", idr);
+
+	/* Check the status register for doorbell interrupts */
+	if (!(imisr & 0x8))
+		return IRQ_NONE;
+
+	/* Clear all doorbell interrupts */
+	iowrite32(idr, priv->immr + IDR_OFFSET);
+
+	/* Reset */
+	if (idr & 0x1)
+		schedule_work(&priv->reset_work);
+
+	/* Start */
+	if (idr & 0x2)
+		schedule_work(&priv->start_work);
+
+	/* vdev 0 vq 1 kick */
+	if (idr & 0x4)
+		schedule_work_if_ready(priv, 0, 1);
+
+	/* vdev 0 vq 0 kick */
+	if (idr & 0x8)
+		schedule_work_if_ready(priv, 0, 0);
+
+	if (idr & 0xfffffff0)
+		dev_dbg(dev, "INTERRUPT unhandled 0x%.8x\n", idr & 0xfffffff0);
+
+	return IRQ_HANDLED;
+}
+
+/*----------------------------------------------------------------------------*/
+/* Driver insertion time virtio device initialization                         */
+/*----------------------------------------------------------------------------*/
+
+static void vdev_release(struct device *dev)
+{
+	/* TODO: this should probably do something useful */
+	dev_dbg(dev, "%s: called\n", __func__);
+}
+
+/*
+ * Do any device-specific setup for a virtio device
+ *
+ * This would include things like setting the feature bits for the
+ * device, as well as the device type.
+ *
+ * There is no access to host memory at this point, so don't access it
+ */
+static void vop_setup_virtio_device(struct vop_dev *priv, int devnum)
+{
+	struct vop_vdev *vdev = &priv->devices[devnum];
+	struct virtio_net_config *config;
+	unsigned long features = 0;
+
+	/* HACK: we only support device #0 (virtio_net) right now */
+	if (devnum != 0)
+		return;
+
+	/* Generate a random ethernet address for the host to have
+	 *
+	 * This way, we could do something board-specific and get an
+	 * ethernet address that is consistent per-slot
+	 */
+	config = (struct virtio_net_config *)vdev->guest_status->config;
+	random_ether_addr(config->mac);
+	dev_info(priv->dev, "Generated MAC %pM\n", config->mac);
+
+	set_bit(VIRTIO_NET_F_MAC,  &features);
+#if 0
+	/* Set the feature bits for the device */
+	set_bit(VIRTIO_NET_F_CSUM,        &features);
+	set_bit(VIRTIO_NET_F_GSO,         &features);
+	set_bit(VIRTIO_NET_F_HOST_TSO4,   &features);
+	set_bit(VIRTIO_NET_F_HOST_TSO6,   &features);
+	set_bit(VIRTIO_NET_F_HOST_ECN,    &features);
+#endif
+
+	vdev->guest_status->features = cpu_to_le32(features);
+	vdev->vdev.id.device = VIRTIO_ID_NET;
+}
+
+/*
+ * Do all of the initialization of all of the virtqueues for a given virtio
+ * device. There is no access to host memory at this point, so don't access it
+ *
+ * @devnum the device number in the priv->devices[] array
+ */
+static void vop_initialize_virtqueues(struct vop_dev *priv, int devnum)
+{
+	struct vop_vdev *vdev = &priv->devices[devnum];
+	struct vop_vq *vq;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(vdev->virtqueues); i++) {
+		vq = &vdev->virtqueues[i];
+
+		memset(vq, 0, sizeof(struct vop_vq));
+		vq->immr = priv->immr;
+		vq->dma.chan = priv->chan;
+		INIT_WORK(&vq->work, vop_dma_work);
+	}
+}
+
+/*
+ * Do all of the initialization for the virtio devices that is possible without
+ * access to the host memory
+ *
+ * This includes setting up the pointers that you can and setting the feature
+ * bits so that the host can read them before he starts us
+ */
+static void vop_initialize_devices(struct vop_dev *priv)
+{
+	struct device *parent = priv->dev;
+	struct vop_vdev *vdev;
+	struct device *vdev_dev;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(priv->devices); i++) {
+		vdev = &priv->devices[i];
+		vdev_dev = &vdev->vdev.dev;
+
+		/* Set up access to the guest memory, host memory isn't valid
+		 * yet, and will have to be set up just before we start */
+		vdev->loc = priv->guest_mem + (i * 4096);
+		vdev->guest_status = vdev->loc;
+
+		/* Initialize all of the device's virtqueues */
+		vop_initialize_virtqueues(priv, i);
+
+		/* Zero the configuration space */
+		memset(vdev->guest_status, 0, 1024);
+
+		/* Copy parent DMA parameters to this device */
+		vdev_dev->dma_mask = parent->dma_mask;
+		vdev_dev->dma_parms = parent->dma_parms;
+		vdev_dev->coherent_dma_mask = parent->coherent_dma_mask;
+
+		vdev_dev->release = &vdev_release;
+		vdev_dev->parent  = parent;
+		vdev->vdev.config = &vop_config_ops;
+
+		/* Do any device-specific setup */
+		vop_setup_virtio_device(priv, i);
+	}
+}
+
+/*----------------------------------------------------------------------------*/
+/* OpenFirmware Device Subsystem                                              */
+/*----------------------------------------------------------------------------*/
+
+static int vdev_of_probe(struct of_device *op, const struct of_device_id *match)
+{
+	struct vop_dev *priv;
+	dma_cap_mask_t mask;
+	int ret;
+
+	/* Allocate private data */
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		dev_err(&op->dev, "Unable to allocate device private data\n");
+		ret = -ENOMEM;
+		goto out_return;
+	}
+
+	dev_set_drvdata(&op->dev, priv);
+	priv->dev = &op->dev;
+	mutex_init(&priv->mutex);
+	INIT_WORK(&priv->reset_work, vop_reset_work);
+	INIT_WORK(&priv->start_work, vop_start_work);
+
+	/* Get a DMA channel */
+	dma_cap_zero(mask);
+	dma_cap_set(DMA_MEMCPY, mask);
+	dma_cap_set(DMA_INTERRUPT, mask);
+	priv->chan = dma_request_channel(mask, NULL, NULL);
+	if (!priv->chan) {
+		dev_err(&op->dev, "Unable to get DMA channel\n");
+		ret = -ENODEV;
+		goto out_free_priv;
+	}
+
+	/* Remap IMMR */
+	priv->immr = ioremap(get_immrbase(), 0x100000);
+	if (!priv->immr) {
+		dev_err(&op->dev, "Unable to remap IMMR registers\n");
+		ret = -ENOMEM;
+		goto out_dma_release_channel;
+	}
+
+	/* Set up a static 1GB window into host memory */
+	iowrite32be(LAWAR0_ENABLE | 0x1D, priv->immr + LAWAR0_OFFSET);
+	iowrite32be(POCMR0_ENABLE | 0xC0000, priv->immr + POCMR0_OFFSET);
+	iowrite32be(0x0, priv->immr + POTAR0_OFFSET);
+
+	/* Allocate guest memory */
+	priv->guest_mem = dma_alloc_coherent(&op->dev, VOP_GUEST_MEM_SIZE,
+					     &priv->guest_mem_addr, GFP_KERNEL);
+	if (!priv->guest_mem) {
+		dev_err(&op->dev, "Unable to allocate guest memory\n");
+		ret = -ENOMEM;
+		goto out_iounmap_immr;
+	}
+
+	memset(priv->guest_mem, 0, VOP_GUEST_MEM_SIZE);
+
+	/* Program BAR1 so that it will hit the guest memory */
+	iowrite32be(priv->guest_mem_addr >> 12, priv->immr + PITAR0_OFFSET);
+
+	/* Initialize all of the virtio devices with their features, etc */
+	vop_initialize_devices(priv);
+
+	/* Disable mailbox interrupts */
+	iowrite32(0x2 | 0x1, priv->immr + IMIMR_OFFSET);
+
+	/* Hook up the irq handler */
+	priv->irq = irq_of_parse_and_map(op->node, 0);
+	ret = request_irq(priv->irq, vdev_interrupt, IRQF_SHARED, driver_name, priv);
+	if (ret)
+		goto out_free_guest_mem;
+
+	dev_info(&op->dev, "Virtio-over-PCI guest driver installed\n");
+	dev_info(&op->dev, "Physical memory @ 0x%.8x\n", priv->guest_mem_addr);
+	dev_info(&op->dev, "Descriptor ring size: %d entries\n", VOP_RING_SIZE);
+	return 0;
+
+out_free_guest_mem:
+	dma_free_coherent(&op->dev, VOP_GUEST_MEM_SIZE, priv->guest_mem,
+			  priv->guest_mem_addr);
+out_iounmap_immr:
+	iounmap(priv->immr);
+out_dma_release_channel:
+	dma_release_channel(priv->chan);
+out_free_priv:
+	kfree(priv);
+out_return:
+	return ret;
+}
+
+static int vdev_of_remove(struct of_device *op)
+{
+	struct vop_dev *priv = dev_get_drvdata(&op->dev);
+
+	/* Stop the irq handler */
+	free_irq(priv->irq, priv);
+
+	/* Unregister and reset all of the devices */
+	schedule_work(&priv->reset_work);
+	flush_scheduled_work();
+
+	dma_free_coherent(&op->dev, VOP_GUEST_MEM_SIZE, priv->guest_mem,
+			  priv->guest_mem_addr);
+	iounmap(priv->immr);
+	dma_release_channel(priv->chan);
+	kfree(priv);
+
+	return 0;
+}
+
+static struct of_device_id vdev_of_match[] = {
+	{ .compatible = "fsl,mpc8349-mu", },
+	{},
+};
+
+static struct of_platform_driver vdev_of_driver = {
+	.owner		= THIS_MODULE,
+	.name		= driver_name,
+	.match_table	= vdev_of_match,
+	.probe		= vdev_of_probe,
+	.remove		= vdev_of_remove,
+};
+
+/*----------------------------------------------------------------------------*/
+/* Module Init / Exit                                                         */
+/*----------------------------------------------------------------------------*/
+
+static int __init vdev_init(void)
+{
+	return of_register_platform_driver(&vdev_of_driver);
+}
+
+static void __exit vdev_exit(void)
+{
+	of_unregister_platform_driver(&vdev_of_driver);
+}
+
+MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
+MODULE_DESCRIPTION("Freescale Virtio-over-PCI Test Driver");
+MODULE_LICENSE("GPL");
+
+module_init(vdev_init);
+module_exit(vdev_exit);
diff --git a/drivers/virtio/vop_host.c b/drivers/virtio/vop_host.c
new file mode 100644
index 0000000..fab26c7
--- /dev/null
+++ b/drivers/virtio/vop_host.c
@@ -0,0 +1,1028 @@
+/*
+ * Virtio-over-PCI Host Driver for MPC8349EMDS Guest
+ *
+ * Copyright (c) 2009 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/virtio.h>
+#include <linux/virtio_config.h>
+#include <linux/virtio_net.h>
+#include <linux/workqueue.h>
+#include <linux/interrupt.h>
+
+#include <linux/etherdevice.h>
+
+#include "vop_hw.h"
+#include "vop.h"
+
+static const char driver_name[] = "vdev";
+
+struct vop_loc_desc {
+	u32 addr;
+	u32 len;
+	u16 flags;
+	u16 next;
+};
+
+struct vop_vq {
+
+	/* The actual virtqueue itself */
+	struct virtqueue vq;
+
+	struct device *dev;
+
+	/* The host ring address */
+	struct vop_host_ring *host;
+
+	/* The guest ring address */
+	struct vop_guest_ring __iomem *guest;
+
+	/* Local copy of the descriptors for fast access */
+	struct vop_loc_desc desc[VOP_RING_SIZE];
+
+	/* The data token from add_buf() */
+	void *data[VOP_RING_SIZE];
+
+	unsigned int num_free;
+	unsigned int free_head;
+	unsigned int num_added;
+
+	u16 avail_idx;
+	u16 last_used_idx;
+
+	/* The doorbell to kick() */
+	unsigned int kick_val;
+	void __iomem *immr;
+};
+
+/* Convert from a struct virtqueue to a struct vop_vq */
+#define to_vop_vq(X) container_of(X, struct vop_vq, vq)
+
+/*
+ * This represents a virtio_device for our driver. It follows the memory
+ * layout shown above. It has pointers to all of the host and guest memory
+ * areas that we need to access
+ */
+struct vop_vdev {
+
+	/* The specific virtio device (console, net, blk) */
+	struct virtio_device vdev;
+
+	/* Local and remote memory */
+	void *loc;
+	void __iomem *rem;
+
+	/*
+	 * These are the status, feature, and configuration information
+	 * for this virtio device. They are exposed in our memory block
+	 * starting at offset 0.
+	 */
+	struct vop_status *host_status;
+
+	/*
+	 * These are the status, feature, and configuration information
+	 * for the guest virtio device. They are exposed in the guest
+	 * memory block starting at offset 0.
+	 */
+	struct vop_status __iomem *guest_status;
+
+	/*
+	 * These are the virtqueues for the virtio driver running this
+	 * device to use. The host portions are exposed in our memory block
+	 * starting at offset 1024. The exposed areas are aligned to 1024 byte
+	 * boundaries, so they appear at offets 1024, 2048, and 3072
+	 * respectively.
+	 */
+	struct vop_vq virtqueues[3];
+};
+
+#define to_vop_vdev(X) container_of(X, struct vop_vdev, vdev)
+
+/*
+ * This is information from the PCI subsystem about each MPC8349EMDS board
+ *
+ * It holds information for all of the possible virtio_devices that are
+ * attached to this board.
+ */
+struct vop_dev {
+
+	struct pci_dev *pdev;
+	struct device *dev;
+
+	/* PowerPC memory (PCI BAR0 and BAR1, respectively) */
+	#define VOP_GUEST_MEM_SIZE 16384
+	void __iomem *immr;
+	void __iomem *netregs;
+
+	/* Host memory, visible to the PowerPC */
+	#define VOP_HOST_MEM_SIZE 16384
+	void *host_mem;
+	dma_addr_t host_mem_addr;
+
+	/* The virtio devices */
+	struct vop_vdev devices[4];
+};
+
+/*----------------------------------------------------------------------------*/
+/* Ring Debugging Helpers                                                     */
+/*----------------------------------------------------------------------------*/
+
+#ifdef DEBUG_DUMP_RINGS
+static void dump_guest_descriptors(struct vop_vq *vq)
+{
+	int i;
+	struct vop_desc __iomem *desc;
+
+	pr_debug("DESC BG: 0xADDRESSX LENGTH 0xFLAG 0xNEXT\n");
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		desc = &vq->guest->desc[i];
+		pr_debug("DESC %.2d: 0x%.8x %.6d 0x%.4x 0x%.4x\n", i,
+				ioread32(&desc->addr), ioread32(&desc->len),
+				ioread16(&desc->flags), ioread16(&desc->next));
+	}
+	pr_debug("DESC ED\n");
+}
+
+static void dump_guest_avail(struct vop_vq *vq)
+{
+	int i;
+
+	pr_debug("BEGIN AVAIL DUMP\n");
+	for (i = 0; i < VOP_RING_SIZE; i++)
+		pr_debug("AVAIL %.2d: 0x%.4x\n", i, ioread16(&vq->guest->avail[i]));
+	pr_debug("END AVAIL DUMP\n");
+}
+
+static void dump_guest_ring(struct vop_vq *vq)
+{
+	pr_debug("BEGIN GUEST RING DUMP\n");
+	dump_guest_descriptors(vq);
+	pr_debug("GUEST FLAGS: 0x%.4x\n", ioread16(&vq->guest->flags));
+	pr_debug("GUEST AVAIL_IDX: %d\n", ioread16(&vq->guest->avail_idx));
+	dump_guest_avail(vq);
+	pr_debug("END GUEST RING DUMP\n");
+}
+
+static void dump_host_used(struct vop_vq *vq)
+{
+	int i;
+	struct vop_used_elem *used;
+
+	pr_debug("USED BG: 0xIDID LENGTH\n");
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		used = &vq->host->used[i];
+		pr_debug("USED %.2d: 0x%.4x %.6d\n", i, used->id, used->len);
+	}
+	pr_debug("USED ED\n");
+}
+
+static void dump_host_ring(struct vop_vq *vq)
+{
+	pr_debug("BEGIN HOST RING DUMP\n");
+	pr_debug("HOST FLAGS: 0x%.4x\n", vq->host->flags);
+	pr_debug("HOST USED_IDX: 0x%.2d\n", vq->host->used_idx);
+	dump_host_used(vq);
+	pr_debug("END HOST RING DUMP\n");
+}
+
+static void debug_dump_rings(struct vop_vq *vq, const char *msg)
+{
+	dev_dbg(vq->dev, "%s\n", msg);
+	dump_guest_ring(vq);
+	dump_host_ring(vq);
+	pr_debug("\n");
+}
+#else
+static void debug_dump_rings(struct vop_vq *vq, const char *msg)
+{
+	/* Nothing */
+}
+#endif /* DEBUG_DUMP_RINGS */
+
+/*----------------------------------------------------------------------------*/
+/* Ring Access Helpers                                                        */
+/*----------------------------------------------------------------------------*/
+
+static void vop_set_desc_addr(struct vop_vq *vq, unsigned int idx, u32 addr)
+{
+	vq->desc[idx].addr = addr;
+	iowrite32(addr, &vq->guest->desc[idx].addr);
+}
+
+static void vop_set_desc_len(struct vop_vq *vq, unsigned int idx, u32 len)
+{
+	vq->desc[idx].len = len;
+	iowrite32(len, &vq->guest->desc[idx].len);
+}
+
+static void vop_set_desc_flags(struct vop_vq *vq, unsigned int idx, u16 flags)
+{
+	vq->desc[idx].flags = flags;
+	iowrite16(flags, &vq->guest->desc[idx].flags);
+}
+
+static void vop_set_desc_next(struct vop_vq *vq, unsigned int idx, u16 next)
+{
+	vq->desc[idx].next = next;
+	iowrite16(next, &vq->guest->desc[idx].next);
+}
+
+static u32 vop_get_desc_addr(struct vop_vq *vq, unsigned int idx)
+{
+	return vq->desc[idx].addr;
+}
+
+static u32 vop_get_desc_len(struct vop_vq *vq, unsigned int idx)
+{
+	return vq->desc[idx].len;
+}
+
+static u16 vop_get_desc_flags(struct vop_vq *vq, unsigned int idx)
+{
+	return vq->desc[idx].flags;
+}
+
+static u16 vop_get_desc_next(struct vop_vq *vq, unsigned int idx)
+{
+	return vq->desc[idx].next;
+}
+
+/*
+ * Add an entry to the available ring at avail_idx pointing to the descriptor
+ * chain at index head
+ *
+ * @vq the virtqueue
+ * @idx the index in the avail ring
+ * @val the value to write
+ */
+static void vop_set_avail_entry(struct vop_vq *vq, u16 idx, u16 val)
+{
+	iowrite16(val, &vq->guest->avail[idx]);
+}
+
+/*
+ * Set the available index so the guest knows about buffers that were added
+ * with vop_set_avail_entry()
+ *
+ * @vq the virtqueue
+ * @idx the new avail_idx that the guest sees
+ */
+static void vop_set_avail_idx(struct vop_vq *vq, u16 idx)
+{
+	iowrite16(idx, &vq->guest->avail_idx);
+}
+
+/*
+ * Set the host's flags (in the guest memory)
+ *
+ * @vq the virtqueue
+ * @flags the new flags that the guest will see
+ */
+static void vop_set_host_flags(struct vop_vq *vq, u16 flags)
+{
+	iowrite16(flags, &vq->guest->flags);
+}
+
+/*
+ * Read the guests flags (in local memory)
+ *
+ * @vq the virtqueue
+ * @return the guest's flags
+ */
+static u16 vop_get_guest_flags(struct vop_vq *vq)
+{
+	return le16_to_cpu(vq->host->flags);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Remote status helpers                                                      */
+/*----------------------------------------------------------------------------*/
+
+static u32 vop_get_guest_status(struct vop_vdev *vdev)
+{
+	return ioread32(&vdev->guest_status->status);
+}
+
+static u32 vop_get_guest_features(struct vop_vdev *vdev)
+{
+	return ioread32(&vdev->guest_status->features);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Scatterlist DMA helpers                                                    */
+/*----------------------------------------------------------------------------*/
+
+/*
+ * This function abuses some of the scatterlist code and implements
+ * dma_map_sg() in such a way that we don't need to keep the scatterlist
+ * around in order to unmap it.
+ *
+ * It is also designed to never merge scatterlist entries, which is
+ * never what we want for virtio.
+ *
+ * When it is time to unmap the buffer, you can use dma_unmap_single() to
+ * unmap each entry in the chain. Get the address, length, and direction
+ * from the descriptors! (keep a local copy for speed)
+ */
+static int vop_dma_map_sg(struct device *dev, struct scatterlist sg[],
+			  unsigned int out, unsigned int in)
+{
+	dma_addr_t addr;
+	enum dma_data_direction dir;
+	struct scatterlist *start;
+	unsigned int i, failure;
+
+	start = sg;
+
+	for (i = 0; i < out + in; i++) {
+
+		/* Check for scatterlist chaining abuse */
+		BUG_ON(sg == NULL);
+
+		dir = (i < out) ? DMA_TO_DEVICE : DMA_FROM_DEVICE;
+		addr = dma_map_single(dev, sg_virt(sg), sg->length, dir);
+
+		if (dma_mapping_error(dev, addr))
+			goto unwind;
+
+		sg_dma_address(sg) = addr;
+		sg = sg_next(sg);
+	}
+
+	return 0;
+
+unwind:
+	failure = i;
+	sg = start;
+
+	for (i = 0; i < failure; i++) {
+		dir = (i < out) ? DMA_TO_DEVICE : DMA_FROM_DEVICE;
+		addr = sg_dma_address(sg);
+
+		dma_unmap_single(dev, addr, sg->length, dir);
+		sg = sg_next(sg);
+	}
+
+	return -ENOMEM;
+}
+
+/*----------------------------------------------------------------------------*/
+/* struct virtqueue_ops infrastructure                                        */
+/*----------------------------------------------------------------------------*/
+
+static int vop_add_buf(struct virtqueue *_vq, struct scatterlist sg[],
+				unsigned int out, unsigned int in, void *data)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+	unsigned int i, avail, head, uninitialized_var(prev);
+
+	BUG_ON(data == NULL);
+	BUG_ON(out + in == 0);
+
+	/* Make sure we have space for this to succeed */
+	if (vq->num_free < out + in) {
+		dev_dbg(vq->dev, "No free space left: len=%d free=%d\n",
+				out + in, vq->num_free);
+		return -ENOSPC;
+	}
+
+	head = vq->free_head;
+
+	/* DMA map the scatterlist */
+	if (vop_dma_map_sg(vq->dev, sg, out, in)) {
+		dev_err(vq->dev, "Failed to DMA map scatterlist\n");
+		return -ENOMEM;
+	}
+
+	/* We're about to use some buffers from the free list */
+	vq->num_free -= out + in;
+
+	for (i = vq->free_head; out; i = vop_get_desc_next(vq, i), out--) {
+		vop_set_desc_flags(vq, i, VOP_DESC_F_NEXT);
+		vop_set_desc_addr(vq, i, sg_dma_address(sg));
+		vop_set_desc_len(vq, i, sg->length);
+
+		prev = i;
+		sg = sg_next(sg);
+	}
+
+	for (/* none */; in; i = vop_get_desc_next(vq, i), in--) {
+		vop_set_desc_flags(vq, i, VOP_DESC_F_NEXT | VOP_DESC_F_WRITE);
+		vop_set_desc_addr(vq, i, sg_dma_address(sg));
+		vop_set_desc_len(vq, i, sg->length);
+
+		prev = i;
+		sg = sg_next(sg);
+	}
+
+	/* Last one doesn't continue */
+	vop_set_desc_flags(vq, prev, vop_get_desc_flags(vq, prev) & ~VOP_DESC_F_NEXT);
+
+	/* Update the free pointer */
+	vq->free_head = i;
+
+	/* Set token */
+	vq->data[head] = data;
+
+	/* Add an entry for the head of the chain into the avail array, but
+	 * don't update avail->idx until kick() */
+	avail = (vq->avail_idx + vq->num_added++) & (VOP_RING_SIZE - 1);
+	vop_set_avail_entry(vq, avail, head);
+
+	dev_dbg(vq->dev, "Added buffer head %i to %p\n", head, vq);
+	debug_dump_rings(vq, "Added buffer(s), dumping rings");
+
+	return 0;
+}
+
+static inline bool more_used(const struct vop_vq *vq)
+{
+	return vq->last_used_idx != le16_to_cpu(vq->host->used_idx);
+}
+
+static void detach_buf(struct vop_vq *vq, unsigned int head)
+{
+	unsigned int i, len;
+	dma_addr_t addr;
+	enum dma_data_direction dir;
+
+	/* Clear data pointer */
+	vq->data[head] = NULL;
+
+	/* Put the chain back on the free list, unmapping as we go */
+	i = head;
+	do {
+		addr = vop_get_desc_addr(vq, i);
+		len = vop_get_desc_len(vq, i);
+		dir = (vop_get_desc_flags(vq, i) & VOP_DESC_F_WRITE) ?
+				DMA_FROM_DEVICE : DMA_TO_DEVICE;
+
+		/* Unmap the entry */
+		dma_unmap_single(vq->dev, addr, len, dir);
+
+		i = vop_get_desc_next(vq, i);
+		vq->num_free++;
+	} while (vop_get_desc_flags(vq, i) & VOP_DESC_F_NEXT);
+
+	vop_set_desc_next(vq, i, vq->free_head);
+	vq->free_head = head;
+
+	/* Plus final descriptor */
+	vq->num_free++;
+}
+
+static void *vop_get_buf(struct virtqueue *_vq, unsigned int *len)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+	unsigned int head, used_idx;
+	void *ret;
+
+	if (!more_used(vq)) {
+		dev_dbg(vq->dev, "No more buffers in queue\n");
+		return NULL;
+	}
+
+	used_idx = vq->last_used_idx & (VOP_RING_SIZE - 1);
+	head = le32_to_cpu(vq->host->used[used_idx].id);
+	*len = le32_to_cpu(vq->host->used[used_idx].len);
+
+	dev_dbg(vq->dev, "REMOVE buffer head %i from %p\n", head, vq);
+
+	BUG_ON(head >= VOP_RING_SIZE);
+	BUG_ON(!vq->data[head]);
+
+	/* detach_buf() clears data, save it now */
+	ret = vq->data[head];
+	detach_buf(vq, head);
+
+	/* Update the last used_idx we've consumed */
+	vq->last_used_idx++;
+	return ret;
+}
+
+static void vop_kick(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+
+	dev_dbg(vq->dev, "making %d new buffers available to guest\n", vq->num_added);
+	vq->avail_idx += vq->num_added;
+	vq->num_added = 0;
+	vop_set_avail_idx(vq, vq->avail_idx);
+
+	if (!(vop_get_guest_flags(vq) & VOP_F_NO_INTERRUPT)) {
+		dev_dbg(vq->dev, "kicking the guest (new buffers in avail)\n");
+		iowrite32(vq->kick_val, vq->immr + IDR_OFFSET);
+		debug_dump_rings(vq, "ran a kick, dumping rings");
+	}
+}
+
+/* Write to the guest's flags register to disable interrupts */
+static void vop_disable_cb(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+
+	vop_set_host_flags(vq, VOP_F_NO_INTERRUPT);
+}
+
+static bool vop_enable_cb(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+
+	/* We optimistically enable interrupts, then check if
+	 * there was more to do */
+	vop_set_host_flags(vq, 0);
+
+	if (unlikely(more_used(vq)))
+		return false;
+
+	return true;
+}
+
+static struct virtqueue_ops vop_vq_ops = {
+	.add_buf	= vop_add_buf,
+	.get_buf	= vop_get_buf,
+	.kick		= vop_kick,
+	.disable_cb	= vop_disable_cb,
+	.enable_cb	= vop_enable_cb,
+};
+
+/*----------------------------------------------------------------------------*/
+/* struct virtio_device infrastructure                                        */
+/*----------------------------------------------------------------------------*/
+
+/* Get something that the other side wants you to have, from configuration
+ * space. This is used to transfer the MAC address from the guest to the host,
+ * for example. It should be reading something from the guest, in this case */
+static void vopc_get(struct virtio_device *_vdev, unsigned offset, void *buf,
+		     unsigned len)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	void __iomem *config = vdev->guest_status->config;
+
+	memcpy_fromio(buf, config + offset, len);
+}
+
+/* Set something in the configuration space (currently unused) */
+static void vopc_set(struct virtio_device *_vdev, unsigned offset,
+		     const void *buf, unsigned len)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	void __iomem *config = vdev->guest_status->config;
+
+	memcpy_toio(config + offset, buf, len);
+}
+
+/* Get your own status */
+static u8 vopc_get_status(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	u32 status;
+
+	status = le32_to_cpu(vdev->host_status->status);
+	dev_dbg(&vdev->vdev.dev, "%s(): -> 0x%.2x\n", __func__, (u8)status);
+
+	return (u8)status;
+}
+
+/* Set your own status */
+static void vopc_set_status(struct virtio_device *_vdev, u8 status)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	u32 old_status;
+
+	old_status = le32_to_cpu(vdev->host_status->status);
+	vdev->host_status->status = cpu_to_le32(status);
+
+	dev_dbg(&vdev->vdev.dev, "%s(): <- 0x%.2x (was 0x%.2x)\n",
+			__func__, status, old_status);
+
+	/*
+	 * FIXME: we really need to notify the other side when status changes
+	 * FIXME: happen, so that they can take some action
+	 */
+}
+
+/* Reset your own status */
+static void vopc_reset(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+
+	dev_dbg(&vdev->vdev.dev, "%s(): status reset\n", __func__);
+	vdev->host_status->status = cpu_to_le32(0);
+}
+
+static struct virtqueue *vopc_find_vq(struct virtio_device *_vdev,
+					     unsigned index,
+					     void (*cb)(struct virtqueue *vq))
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	struct vop_vq *vq = &vdev->virtqueues[index];
+	int i;
+
+	/* Check that we support the virtqueue at this index */
+	if (index >= ARRAY_SIZE(vdev->virtqueues)) {
+		dev_err(&vdev->vdev.dev, "no virtqueue for index %d\n", index);
+		return ERR_PTR(-ENODEV);
+	}
+
+	/* HACK: we only support virtio_net for now */
+	if (vdev->vdev.id.device != VIRTIO_ID_NET) {
+		dev_err(&vdev->vdev.dev, "only virtio_net is supported\n");
+		return ERR_PTR(-ENODEV);
+	}
+
+	/* Initialize the virtqueue to a clean state */
+	vq->num_free = VOP_RING_SIZE;
+	vq->dev = &vdev->vdev.dev;
+
+	switch (index) {
+	case 0: /* x86 recv virtqueue -- ppc xmit virtqueue */
+		vq->guest = vdev->rem + 1024;
+		vq->host  = vdev->loc + 1024;
+		break;
+	case 1: /* x86 xmit virtqueue -- ppc recv virtqueue */
+		vq->guest = vdev->rem + 2048;
+		vq->host  = vdev->loc + 2048;
+		break;
+	default:
+		dev_err(vq->dev, "unknown virtqueue %d\n", index);
+		return ERR_PTR(-ENODEV);
+	}
+
+	/* Initialize the descriptor, avail, and used rings */
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		vop_set_desc_addr(vq, i, 0x0);
+		vop_set_desc_len(vq, i, 0);
+		vop_set_desc_flags(vq, i, 0);
+		vop_set_desc_next(vq, i, (i + 1) & (VOP_RING_SIZE - 1));
+
+		vop_set_avail_entry(vq, i, 0);
+		vq->host->used[i].id = cpu_to_le32(0);
+		vq->host->used[i].len = cpu_to_le32(0);
+	}
+
+	vq->avail_idx = 0;
+	vop_set_avail_idx(vq, 0);
+	vop_set_host_flags(vq, 0);
+
+	debug_dump_rings(vq, "found a virtqueue, dumping rings");
+
+	vq->vq.callback = cb;
+	vq->vq.vdev = &vdev->vdev;
+	vq->vq.vq_ops = &vop_vq_ops;
+
+	return &vq->vq;
+}
+
+static void vopc_del_vq(struct virtqueue *_vq)
+{
+	struct vop_vq *vq = to_vop_vq(_vq);
+	int i;
+
+	/* FIXME: make sure that DMA has stopped by this point */
+
+	/* Unmap and remove all outstanding descriptors from the ring */
+	for (i = 0; i < VOP_RING_SIZE; i++) {
+		if (vq->data[i]) {
+			dev_dbg(vq->dev, "cleanup detach buffer at index %d\n", i);
+			detach_buf(vq, i);
+		}
+	}
+
+	debug_dump_rings(vq, "virtqueue destroyed, dumping rings");
+}
+
+static u32 vopc_get_features(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+	u32 ret;
+
+	ret = vop_get_guest_features(vdev);
+	dev_info(&vdev->vdev.dev, "%s(): guest features 0x%.8x\n", __func__, ret);
+
+	return ret;
+}
+
+static void vopc_finalize_features(struct virtio_device *_vdev)
+{
+	struct vop_vdev *vdev = to_vop_vdev(_vdev);
+
+	/*
+	 * TODO: notify the other side at this point
+	 */
+
+	vdev->host_status->features = cpu_to_le32(vdev->vdev.features[0]);
+	dev_info(&vdev->vdev.dev, "%s(): final features 0x%.8lx\n", __func__, vdev->vdev.features[0]);
+}
+
+static struct virtio_config_ops vop_config_ops = {
+	.get			= vopc_get,
+	.set			= vopc_set,
+	.get_status		= vopc_get_status,
+	.set_status		= vopc_set_status,
+	.reset			= vopc_reset,
+	.find_vq		= vopc_find_vq,
+	.del_vq			= vopc_del_vq,
+	.get_features		= vopc_get_features,
+	.finalize_features	= vopc_finalize_features,
+};
+
+/*----------------------------------------------------------------------------*/
+/* Setup code for virtio devices                                              */
+/*----------------------------------------------------------------------------*/
+
+static void vop_release(struct device *dev)
+{
+	dev_dbg(dev, "calling device release\n");
+}
+
+static int setup_virtio_device(struct vop_dev *priv, int devnum)
+{
+	struct vop_vdev *vdev = &priv->devices[devnum];
+	struct device *dev = priv->dev;
+	int i;
+
+	/* Set up the pointers to the guest and host memory areas */
+	vdev->loc = priv->host_mem + (devnum * 4096);
+	vdev->rem = priv->netregs  + (devnum * 4096);
+	dev_dbg(dev, "memory guest 0x%p host 0x%p\n", vdev->rem, vdev->loc);
+
+	/* Set up the pointers to the guest and host status areas */
+	vdev->guest_status = vdev->rem;
+	vdev->host_status  = vdev->loc;
+	dev_dbg(dev, "status guest 0x%p host 0x%p\n", vdev->rem, vdev->loc);
+
+	/* The find_vq() must set up the correct mappings to virtqueues itself,
+	 * so we cannot do it here */
+	for (i = 0; i < ARRAY_SIZE(vdev->virtqueues); i++) {
+		memset(&vdev->virtqueues[i], 0, sizeof(struct vop_vq));
+		vdev->virtqueues[i].immr = priv->immr;
+		vdev->virtqueues[i].kick_val = 1 << ((devnum * 4) + i + 2);
+		dev_dbg(dev, "vq %d cleared, kick %d\n", i, (devnum * 4) + i + 2);
+	}
+
+	/* Zero out the configuration space completely */
+	memset(vdev->host_status, 0, 1024);
+
+	/* Copy the parent DMA parameters to this virtio_device */
+	vdev->vdev.dev.dma_mask = dev->dma_mask;
+	vdev->vdev.dev.dma_parms = dev->dma_parms;
+	vdev->vdev.dev.coherent_dma_mask = dev->coherent_dma_mask;
+
+	/* Setup everything except the device type */
+	vdev->vdev.dev.release = &vop_release;
+	vdev->vdev.dev.parent  = dev;
+	vdev->vdev.config      = &vop_config_ops;
+
+	return 0;
+}
+
+static int register_virtio_net(struct vop_dev *priv)
+{
+	struct vop_vdev *vdev = &priv->devices[0];
+	struct virtio_net_config *config;
+	unsigned long features = 0;
+	int ret;
+
+	/* Run the common setup routine */
+	ret = setup_virtio_device(priv, 0);
+	if (ret) {
+		dev_err(priv->dev, "unable to setup virtio_net\n");
+		return ret;
+	}
+
+	/* Generate a random ethernet address for the other side
+	 *
+	 * This is necessary so we can allow it to give us a consistent
+	 * MAC address for itself, using something board-specific
+	 *
+	 * The feature bits must match for it to work correctly
+	 */
+	config = (struct virtio_net_config *)vdev->host_status->config;
+	random_ether_addr(config->mac);
+	dev_info(priv->dev, "Generated MAC %pM\n", config->mac);
+
+	set_bit(VIRTIO_NET_F_MAC,  &features);
+#if 0
+	/* Set the feature bits for the device */
+	set_bit(VIRTIO_NET_F_CSUM,        &features);
+	set_bit(VIRTIO_NET_F_GSO,         &features);
+	set_bit(VIRTIO_NET_F_HOST_TSO4,   &features);
+	set_bit(VIRTIO_NET_F_HOST_TSO6,   &features);
+	set_bit(VIRTIO_NET_F_HOST_ECN,    &features);
+#endif
+
+	vdev->host_status->features = cpu_to_le32(features);
+	vdev->vdev.id.device = VIRTIO_ID_NET;
+
+	/* Register the virtio device */
+	return register_virtio_device(&vdev->vdev);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Interrupt Handling                                                         */
+/*----------------------------------------------------------------------------*/
+
+static irqreturn_t vdev_interrupt(int irq, void *dev_id)
+{
+	struct vop_dev *priv = dev_id;
+	struct virtqueue *vq;
+	u32 omisr, odr;
+
+	omisr = ioread32(priv->immr + OMISR_OFFSET);
+	odr   = ioread32(priv->immr + ODR_OFFSET);
+
+	/* Check the status register for doorbell interrupts */
+	if (!(omisr & 0x8))
+		return IRQ_NONE;
+
+	/* Clear all doorbell interrupts */
+	iowrite32(odr, priv->immr + ODR_OFFSET);
+
+	if (odr & 0x4) {
+		vq = &priv->devices[0].virtqueues[0].vq;
+		vq->callback(vq);
+	}
+
+	if (odr & 0x8) {
+		vq = &priv->devices[0].virtqueues[1].vq;
+		vq->callback(vq);
+	}
+
+	return IRQ_HANDLED;
+}
+
+/*----------------------------------------------------------------------------*/
+/* PCI Subsystem                                                              */
+/*----------------------------------------------------------------------------*/
+
+static int vop_probe(struct pci_dev *dev, const struct pci_device_id *id)
+{
+	struct vop_dev *priv;
+	int ret;
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		ret = -ENOMEM;
+		goto out_return;
+	}
+
+	pci_set_drvdata(dev, priv);
+	priv->dev = &dev->dev;
+
+	/* Hardware Initialization */
+	ret = pci_enable_device(dev);
+	if (ret)
+		goto out_kfree_priv;
+
+	pci_set_master(dev);
+	ret = pci_request_regions(dev, driver_name);
+	if (ret)
+		goto out_pci_disable_device;
+
+	priv->immr = pci_ioremap_bar(dev, 0);
+	if (!priv->immr) {
+		ret = -ENOMEM;
+		goto out_pci_release_regions;
+	}
+
+	priv->netregs = pci_ioremap_bar(dev, 1);
+	if (!priv->netregs) {
+		ret = -ENOMEM;
+		goto out_iounmap_immr;
+	}
+
+	/* The device can only see the lowest 1GB of memory over the bus */
+	dev->dev.coherent_dma_mask = DMA_BIT_MASK(30);
+	ret = dma_set_mask(&dev->dev, DMA_BIT_MASK(30));
+	if (ret) {
+		dev_err(&dev->dev, "Unable to set DMA mask\n");
+		goto out_iounmap_netregs;
+	}
+
+	/* Allocate the host memory, for writing by the guest */
+	priv->host_mem = dma_alloc_coherent(&dev->dev, VOP_HOST_MEM_SIZE,
+			&priv->host_mem_addr, GFP_KERNEL);
+	if (!priv->host_mem) {
+		dev_err(&dev->dev, "Unable to allocate host memory\n");
+		ret = -ENOMEM;
+		goto out_iounmap_netregs;
+	}
+
+	/* We use the guest's mailbox 0 to hold the host memory address */
+	iowrite32(priv->host_mem_addr, priv->immr + IMR0_OFFSET);
+
+	/* Reset all of the devices */
+	iowrite32(0x1, priv->immr + IDR_OFFSET);
+
+	/* Mask all of the MBOX interrupts */
+	iowrite32(0x1 | 0x2, priv->immr + OMIMR_OFFSET);
+
+	/* Setup the virtio_net instance */
+	ret = register_virtio_net(priv);
+	if (ret) {
+		dev_err(&dev->dev, "Unable to register virtio_net\n");
+		goto out_free_host_mem;
+	}
+
+	/* Hook up the interrupt handler */
+	ret = request_irq(dev->irq, vdev_interrupt, IRQF_SHARED, driver_name, priv);
+	if (ret) {
+		dev_err(&dev->dev, "Unable to register interrupt handler\n");
+		goto out_unregister_virtio_net;
+	}
+
+	/* Start virtio_net */
+	iowrite32(0x1, priv->immr + IMR1_OFFSET);
+	iowrite32(0x2, priv->immr + IDR_OFFSET);
+
+	return 0;
+
+out_unregister_virtio_net:
+	unregister_virtio_device(&priv->devices[0].vdev);
+out_free_host_mem:
+	dma_free_coherent(&dev->dev, VOP_HOST_MEM_SIZE, priv->host_mem,
+			priv->host_mem_addr);
+out_iounmap_netregs:
+	iounmap(priv->netregs);
+out_iounmap_immr:
+	iounmap(priv->immr);
+out_pci_release_regions:
+	pci_release_regions(dev);
+out_pci_disable_device:
+	pci_disable_device(dev);
+out_kfree_priv:
+	kfree(priv);
+out_return:
+	return ret;
+}
+
+static void vop_remove(struct pci_dev *dev)
+{
+	struct vop_dev *priv = pci_get_drvdata(dev);
+
+	free_irq(dev->irq, priv);
+
+	/* Reset everything */
+	iowrite32(0x1, priv->immr + IDR_OFFSET);
+
+	/* Unregister virtio_net */
+	unregister_virtio_device(&priv->devices[0].vdev);
+
+	/* Clear the host memory address from the guest's mailbox 0 */
+	iowrite32(0x0, priv->immr + IMR0_OFFSET);
+	iowrite32(0x0, priv->immr + IMR1_OFFSET);
+
+	dma_free_coherent(&dev->dev, VOP_HOST_MEM_SIZE, priv->host_mem,
+			priv->host_mem_addr);
+	iounmap(priv->netregs);
+	iounmap(priv->immr);
+	pci_release_regions(dev);
+	pci_disable_device(dev);
+	kfree(priv);
+}
+
+#define PCI_DEVID_FSL_MPC8349EMDS 0x0080
+
+/* The list of devices that this module will support */
+static struct pci_device_id vop_ids[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_FREESCALE, PCI_DEVID_FSL_MPC8349EMDS), },
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, vop_ids);
+
+static struct pci_driver vop_pci_driver = {
+	.name     = (char *)driver_name,
+	.id_table = vop_ids,
+	.probe    = vop_probe,
+	.remove   = vop_remove,
+};
+
+/*----------------------------------------------------------------------------*/
+/* Module Init / Exit                                                         */
+/*----------------------------------------------------------------------------*/
+
+static int __init vop_init(void)
+{
+	return pci_register_driver(&vop_pci_driver);
+}
+
+static void __exit vop_exit(void)
+{
+	pci_unregister_driver(&vop_pci_driver);
+}
+
+MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
+MODULE_DESCRIPTION("Virtio-PCI-Host Test Driver");
+MODULE_LICENSE("GPL");
+
+module_init(vop_init);
+module_exit(vop_exit);
diff --git a/drivers/virtio/vop_hw.h b/drivers/virtio/vop_hw.h
new file mode 100644
index 0000000..8a19d3f
--- /dev/null
+++ b/drivers/virtio/vop_hw.h
@@ -0,0 +1,80 @@
+/*
+ * Register offsets for the MPC8349EMDS Message Unit from the IMMR base address
+ *
+ * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#ifndef PCINET_HW_H
+#define PCINET_HW_H
+
+#define SGPRL_OFFSET		0x0100
+#define SGPRH_OFFSET		0x0104
+
+/* mpc8349emds message unit register offsets */
+#define OMISR_OFFSET		0x8030
+#define OMIMR_OFFSET		0x8034
+#define IMR0_OFFSET		0x8050
+#define IMR1_OFFSET		0x8054
+#define OMR0_OFFSET		0x8058
+#define OMR1_OFFSET		0x805C
+#define ODR_OFFSET		0x8060
+#define IDR_OFFSET		0x8068
+#define IMISR_OFFSET		0x8080
+#define IMIMR_OFFSET		0x8084
+
+
+/* mpc8349emds pci and local access window register offsets */
+#define LAWAR0_OFFSET		0x0064
+#define LAWAR0_ENABLE		(1<<31)
+
+#define POCMR0_OFFSET		0x8410
+#define POCMR0_ENABLE		(1<<31)
+
+#define POTAR0_OFFSET		0x8400
+
+#define LAWAR1_OFFSET		0x006c
+#define LAWAR1_ENABLE		(1<<31)
+
+#define POCMR1_OFFSET		0x8428
+#define POCMR1_ENABLE		(1<<31)
+
+#define POTAR1_OFFSET		0x8418
+
+
+/* mpc8349emds dma controller register offsets */
+#define DMAMR0_OFFSET		0x8100
+#define DMASR0_OFFSET		0x8104
+#define DMASAR0_OFFSET		0x8110
+#define DMADAR0_OFFSET		0x8118
+#define DMABCR0_OFFSET		0x8120
+
+#define DMA_CHANNEL_BUSY	(1<<2)
+
+#define DMA_DIRECT_MODE_SNOOP	(1<<20)
+#define DMA_CHANNEL_MODE_DIRECT	(1<<2)
+#define DMA_CHANNEL_START	(1<<0)
+
+
+/* mpc8349emds pci and local access window register offsets */
+#define LAWAR0_OFFSET		0x0064
+#define LAWAR0_ENABLE		(1<<31)
+
+#define POCMR0_OFFSET		0x8410
+#define POCMR0_ENABLE		(1<<31)
+
+#define POTAR0_OFFSET		0x8400
+
+
+/* mpc8349emds pci and inbound window register offsets */
+#define PITAR0_OFFSET		0x8568
+#define PIWAR0_OFFSET		0x8578
+
+#define PIWAR0_ENABLED		(1<<31)
+#define PIWAR0_PREFETCH		(1<<29)
+#define PIWAR0_IWS_4K		0xb
+
+#endif /* PCINET_HW_H */
-- 
1.5.4.3

