From: Ira Snyder <iws@ovro.caltech.edu>
Subject: [RFC v3] net: add PCINet driver
Date: Wed, 5 Nov 2008 13:22:25 -0800
Message-ID: <20081105212225.GA17821@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:54622 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbYKEVW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 16:22:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support to Linux for a virtual ethernet interface which uses the
PCI bus as its transport mechanism. It creates a simple, familiar, and fast
method of communication for two devices connected by a PCI interface.

I have implemented client support for the Freescale MPC8349EMDS board,
which is capable of running in PCI Agent mode (It acts like a PCI card, but
is a complete PowerPC computer, running Linux). It is almost certainly
trivially ported to any MPC83xx system.

It was developed to work in a CompactPCI crate of computers, one of which
is a relatively standard x86 system (acting as the host) and many PowerPC
systems (acting as clients).

RFC v2 -> RFC v3:
  * use inline functions for accessing struct circ_buf_desc
  * use pointer dereferencing on PowerPC local memory instead of ioread32()
  * move IMMR and buffer descriptor accessors inside drivers
  * update for dma_mapping_error() API changes
  * use minimal locking primitives (i.e. spin_lock() instead of _irqsave())
  * always disable checksumming, PCI is reliable
  * replace typedef cbd_t with struct circ_buf_desc
  * use get_immrbase() to get IMMR register offsets

RFC v1 -> RFC v2:
  * remove vim modelines
  * use net_device->name in request_irq(), for irqbalance
  * remove unneccesary wqt_get_stats(), use default get_stats() instead
  * use dev_printk() and friends
  * add message unit to MPC8349EMDS dts file

Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
---
This is the third RFC posting of this driver. I got some feedback, and have
corrected the problems. Thanks to everyone who has done review! I have
gotten off-list feedback from several potential users, so there are
definitely many potential users.

I'll post up a revised version about once a week as long as the changes are
minor. If they are more substantial, I'll post them as needed.

The remaining issues I see in this driver:
1) ==== Naming ====
   The name wqt originally stood for "workqueue-test" and somewhat evolved
   over time into the current driver. I'm looking for suggestions for a
   better name. It should be the same between the host and client drivers,
   to make porting the code between them easier. The drivers are /very/
   similar other than the setup code.
2) ==== IMMR Usage ====
   In the Freescale client driver, I use the whole set of board control
   registers (AKA IMMR registers). I only need a very small subset of them,
   during startup to set up the DMA window. I used the full set of
   registers so that I could share the register offsets between the drivers
   (in pcinet_hw.h)
3) ==== Hardcoded DMA Window Address ====
   In the Freescale client driver, I just hardcoded the address of the
   outbound PCI window into the DMA transfer code. It is 0x80000000.
   Suggestions on how to get this value at runtime are welcome.


Rationale behind some decisions:
1) ==== Usage of the PCINET_NET_REGISTERS_VALID bit ====
   I want to be able to use this driver from U-Boot to tftp a kernel over
   the PCI backplane, and then boot up the board. This means that the
   device descriptor memory, which lives in the client RAM, becomes invalid
   during boot.
2) ==== Buffer Descriptors in client memory ====
   I chose to put the buffer descriptors in client memory rather than host
   memory. It seemed more logical to me at the time. In my application,
   I'll have 19 boards + 1 host per cPCI chassis. The client -> host
   direction will see most of the traffic, and so I thought I would cut
   down on the number of PCI accesses needed. I'm willing to change this.
3) ==== Usage of client DMA controller for all data transfer ====
   This was done purely for speed. I tried using the CPU to transfer all
   data, and it is very slow: ~3MB/sec. Using the DMA controller gets me to
   ~40MB/sec (as tested with netperf).
4) ==== Static 1GB DMA window ====
   Maintaining a window while DMA's in flight, and then changing it seemed
   too complicated. Also, testing showed that using a static window gave me
   a ~10MB/sec speedup compared to moving the window for each skb.
5) ==== The serial driver ====
   Yes, there are two essentially separate drivers here. I needed a method
   to communicate with the U-Boot bootloader on these boards without
   plugging in a serial cable. With 19 clients + 1 host per chassis, the
   cable clutter is worth avoiding. Since everything is connected via the
   PCI bus anyway, I used that. A virtual serial port was simple to
   implement using the messaging unit hardware that I used for the network
   driver.

I'll post both U-Boot drivers to their mailing list once this driver is
finalized.

Thanks,
Ira

 arch/powerpc/boot/dts/mpc834x_mds.dts |    7 +
 drivers/net/Kconfig                   |   29 +
 drivers/net/Makefile                  |    3 +
 drivers/net/pcinet.h                  |   60 ++
 drivers/net/pcinet_fsl.c              | 1358 ++++++++++++++++++++++++++++++++
 drivers/net/pcinet_host.c             | 1388 +++++++++++++++++++++++++++++++++
 drivers/net/pcinet_hw.h               |   77 ++
 7 files changed, 2922 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/pcinet.h
 create mode 100644 drivers/net/pcinet_fsl.c
 create mode 100644 drivers/net/pcinet_host.c
 create mode 100644 drivers/net/pcinet_hw.h

diff --git a/arch/powerpc/boot/dts/mpc834x_mds.dts b/arch/powerpc/boot/dts/mpc834x_mds.dts
index c986c54..3bc8975 100644
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
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 11f143f..fb9e204 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2283,6 +2283,35 @@ config UGETH_TX_ON_DEMAND
 	bool "Transmit on Demand support"
 	depends on UCC_GETH
 
+config PCINET_FSL
+	tristate "PCINet Virtual Ethernet over PCI support (Freescale)"
+	depends on MPC834x_MDS
+	select DMA_ENGINE
+	select FSL_DMA
+	help
+	  When running as a PCI Agent, this driver will create a virtual
+	  ethernet link running over the PCI bus, allowing simplified
+	  communication with the host system. The host system will need
+	  to use the corresponding driver.
+
+	  If in doubt, say N.
+
+config PCINET_HOST
+	tristate "PCINet Virtual Ethernet over PCI support (Host)"
+	depends on PCI
+	help
+	  This driver will let you communicate with a PCINet client device
+	  using a virtual ethernet link running over the PCI bus. This
+	  allows simplified communication with the client system.
+
+	  This is inteded for use in a system that has a crate full of
+	  computers running Linux, all connected by a PCI backplane.
+
+	  The currently, the only board implementing client support is the
+	  Freescale MPC8349EMDS. Enable support with CONFIG_PCINET_FSL=y.
+
+	  If in doubt, say N.
+
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f19acf8..c6fbafc 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -30,6 +30,9 @@ gianfar_driver-objs := gianfar.o \
 obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
 ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o ucc_geth_ethtool.o
 
+obj-$(CONFIG_PCINET_FSL) += pcinet_fsl.o
+obj-$(CONFIG_PCINET_HOST) += pcinet_host.o
+
 #
 # link order important here
 #
diff --git a/drivers/net/pcinet.h b/drivers/net/pcinet.h
new file mode 100644
index 0000000..3df6471
--- /dev/null
+++ b/drivers/net/pcinet.h
@@ -0,0 +1,60 @@
+/*
+ * Shared Definitions for the PCINet / PCISerial drivers
+ *
+ * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * Heavily inspired by the drivers/net/fs_enet driver
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#ifndef PCINET_H
+#define PCINET_H
+
+#include <linux/kernel.h>
+#include <linux/if_ether.h>
+
+/* Ring and Frame size -- these must match between the drivers */
+#define PH_RING_SIZE	(64)
+#define PH_MAX_FRSIZE	(64 * 1024)
+#define PH_MAX_MTU	(PH_MAX_FRSIZE - ETH_HLEN)
+
+struct circ_buf_desc {
+	__le32 sc;
+	__le32 len;
+	__le32 addr;
+	__le32 padding; /* unused padding */
+};
+
+/* Buffer Descriptor Registers */
+#define PCINET_TXBD_BASE	0x400
+#define PCINET_RXBD_BASE	0x800
+
+/* Buffer Descriptor Status */
+#define BD_MEM_READY		0x1
+#define BD_MEM_DIRTY		0x2
+#define BD_MEM_FREE		0x3
+
+/* Status Register Bits */
+#define PCINET_UART_RX_ENABLED		(1<<0)
+#define PCINET_NET_STATUS_RUNNING	(1<<1)
+#define PCINET_NET_RXINT_OFF		(1<<2)
+#define PCINET_NET_REGISTERS_VALID	(1<<3)
+
+/* Driver State Bits */
+#define NET_STATE_STOPPED	0
+#define NET_STATE_RUNNING	1
+
+/* Doorbell Registers */
+#define UART_RX_READY_DBELL	(1<<0)
+#define UART_TX_EMPTY_DBELL	(1<<1)
+#define NET_RX_PACKET_DBELL	(1<<2)
+#define NET_TX_COMPLETE_DBELL	(1<<3)
+#define NET_START_REQ_DBELL	(1<<4)
+#define NET_START_ACK_DBELL	(1<<5)
+#define NET_STOP_REQ_DBELL	(1<<6)
+#define NET_STOP_ACK_DBELL	(1<<7)
+
+#endif /* PCINET_H */
diff --git a/drivers/net/pcinet_fsl.c b/drivers/net/pcinet_fsl.c
new file mode 100644
index 0000000..ac5efb8
--- /dev/null
+++ b/drivers/net/pcinet_fsl.c
@@ -0,0 +1,1358 @@
+/*
+ * PCINet and PCISerial Driver for Freescale MPC8349EMDS
+ *
+ * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * Heavily inspired by the drivers/net/fs_enet driver
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
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include <linux/interrupt.h>
+#include <linux/irqreturn.h>
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/serial.h>
+#include <linux/serial_core.h>
+#include <linux/etherdevice.h>
+#include <linux/mutex.h>
+#include <linux/dmaengine.h>
+
+/* MPC8349EMDS specific get_immrbase() */
+#include <sysdev/fsl_soc.h>
+
+#include "pcinet.h"
+#include "pcinet_hw.h"
+
+/* IMMR Accessor Helpers */
+#define IMMR_R32(_off) ioread32(priv->immr+(_off))
+#define IMMR_W32(_off, _val) iowrite32((_val), priv->immr+(_off))
+#define IMMR_R32BE(_off) ioread32be(priv->immr+(_off))
+#define IMMR_W32BE(_off, _val) iowrite32be((_val), priv->immr+(_off))
+
+static const char driver_name[] = "wqt";
+
+static void wqtuart_rx_char(struct uart_port *port, const char ch);
+static void wqtuart_stop_tx(struct uart_port *port);
+
+struct wqt_dev;
+typedef void (*wqt_irqhandler_t)(struct wqt_dev *);
+
+struct wqt_irqhandlers {
+	wqt_irqhandler_t net_start_req_handler;
+	wqt_irqhandler_t net_start_ack_handler;
+	wqt_irqhandler_t net_stop_req_handler;
+	wqt_irqhandler_t net_stop_ack_handler;
+	wqt_irqhandler_t net_rx_packet_handler;
+	wqt_irqhandler_t net_tx_complete_handler;
+	wqt_irqhandler_t uart_rx_ready_handler;
+	wqt_irqhandler_t uart_tx_empty_handler;
+};
+
+struct wqt_dev {
+	/*--------------------------------------------------------------------*/
+	/* OpenFirmware Infrastructure                                        */
+	/*--------------------------------------------------------------------*/
+	int irq;
+	struct device *dev;
+	void __iomem *immr;
+
+	struct mutex irq_mutex;
+	int interrupt_count;
+
+	spinlock_t irq_lock;
+	struct wqt_irqhandlers handlers;
+
+	/*--------------------------------------------------------------------*/
+	/* UART Device Infrastructure                                         */
+	/*--------------------------------------------------------------------*/
+	struct uart_port port;
+	bool uart_rx_enabled;
+	bool uart_open;
+
+	struct workqueue_struct *wq;
+	struct work_struct uart_tx_work;
+	wait_queue_head_t uart_tx_wait; /* sleep for uart_tx_ready */
+	bool uart_tx_ready; /* transmitter state */
+
+	/*--------------------------------------------------------------------*/
+	/* Ethernet Device Infrastructure                                     */
+	/*--------------------------------------------------------------------*/
+	struct net_device *ndev;
+	void *netregs;
+	dma_addr_t netregs_addr;
+
+	/* Outstanding SKB */
+	struct sk_buff *tx_skbs[PH_RING_SIZE];
+
+	/* Circular Buffer Descriptor base */
+	struct circ_buf_desc *rx_base;
+	struct circ_buf_desc *tx_base;
+
+	/* Current SKB index */
+	struct circ_buf_desc *cur_rx;
+	struct circ_buf_desc *cur_tx;
+	struct circ_buf_desc *dirty_tx;
+	int tx_free;
+
+	struct tasklet_struct tx_complete_tasklet;
+	spinlock_t net_lock;
+
+	struct mutex net_mutex;
+	int net_state;
+	struct work_struct net_start_work;
+	struct work_struct net_stop_work;
+	struct completion net_start_completion;
+	struct completion net_stop_completion;
+	struct napi_struct napi;
+
+	struct dma_client client;
+	struct dma_chan *chan;
+};
+
+/*----------------------------------------------------------------------------*/
+/* Buffer Descriptor Accessor Helpers                                         */
+/*----------------------------------------------------------------------------*/
+
+static inline void cbd_write(__le32 *addr, u32 val)
+{
+	(*addr) = cpu_to_le32(val);
+}
+
+static inline u32 cbd_read(__le32 *addr)
+{
+	return le32_to_cpu(*addr);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Status Register Helper Operations                                          */
+/*----------------------------------------------------------------------------*/
+
+static DEFINE_SPINLOCK(status_lock);
+
+static void wqtstatus_setbit(struct wqt_dev *priv, u32 bit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&status_lock, flags);
+	IMMR_W32(OMR1_OFFSET, IMMR_R32(OMR1_OFFSET) | bit);
+	spin_unlock_irqrestore(&status_lock, flags);
+}
+
+static void wqtstatus_clrbit(struct wqt_dev *priv, u32 bit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&status_lock, flags);
+	IMMR_W32(OMR1_OFFSET, IMMR_R32(OMR1_OFFSET) & ~bit);
+	spin_unlock_irqrestore(&status_lock, flags);
+}
+
+static int wqtstatus_remote_testbit(struct wqt_dev *priv, u32 bit)
+{
+	return IMMR_R32(IMR1_OFFSET) & bit;
+}
+
+/*----------------------------------------------------------------------------*/
+/* Message Sending and Processing Operations                                  */
+/*----------------------------------------------------------------------------*/
+
+static irqreturn_t wqt_interrupt(int irq, void *dev_id)
+{
+	struct wqt_dev *priv = dev_id;
+	u32 imisr, idr;
+
+	imisr = IMMR_R32(IMISR_OFFSET);
+	idr = IMMR_R32(IDR_OFFSET);
+
+	if (!(imisr & 0x8))
+		return IRQ_NONE;
+
+	/* Clear all of the interrupt sources, we'll handle them next */
+	IMMR_W32(IDR_OFFSET, idr);
+
+	/* Lock over all of the handlers, so they cannot get called when
+	 * the code doesn't expect them to be called */
+	spin_lock(&priv->irq_lock);
+
+	if (idr & UART_RX_READY_DBELL)
+		priv->handlers.uart_rx_ready_handler(priv);
+
+	if (idr & UART_TX_EMPTY_DBELL)
+		priv->handlers.uart_tx_empty_handler(priv);
+
+	if (idr & NET_RX_PACKET_DBELL)
+		priv->handlers.net_rx_packet_handler(priv);
+
+	if (idr & NET_TX_COMPLETE_DBELL)
+		priv->handlers.net_tx_complete_handler(priv);
+
+	if (idr & NET_START_REQ_DBELL)
+		priv->handlers.net_start_req_handler(priv);
+
+	if (idr & NET_START_ACK_DBELL)
+		priv->handlers.net_start_ack_handler(priv);
+
+	if (idr & NET_STOP_REQ_DBELL)
+		priv->handlers.net_stop_req_handler(priv);
+
+	if (idr & NET_STOP_ACK_DBELL)
+		priv->handlers.net_stop_ack_handler(priv);
+
+	spin_unlock(&priv->irq_lock);
+
+	return IRQ_HANDLED;
+}
+
+/* Send a character through the mbox when it becomes available
+ * Blocking, must not be called with any spinlocks held */
+static int do_send_message(struct wqt_dev *priv, const char ch)
+{
+	struct uart_port *port = &priv->port;
+	bool tmp;
+
+	spin_lock_irq(&priv->irq_lock);
+	while (priv->uart_tx_ready != true) {
+		spin_unlock_irq(&priv->irq_lock);
+		wait_event_timeout(priv->uart_tx_wait, priv->uart_tx_ready, HZ);
+
+		spin_lock_irq(&port->lock);
+		tmp = priv->uart_open;
+		spin_unlock_irq(&port->lock);
+
+		if (!tmp)
+			return -EIO;
+
+		spin_lock_irq(&priv->irq_lock);
+	}
+
+	/* Now the transmitter is free, send the message */
+	IMMR_W32(OMR0_OFFSET, ch);
+	IMMR_W32(ODR_OFFSET, UART_RX_READY_DBELL);
+
+	/* Mark the transmitter busy */
+	priv->uart_tx_ready = false;
+	spin_unlock_irq(&priv->irq_lock);
+	return 0;
+}
+
+/* Grab a character out of the uart tx buffer and send it */
+static void uart_tx_work_fn(struct work_struct *work)
+{
+	struct wqt_dev *priv = container_of(work, struct wqt_dev, uart_tx_work);
+	struct uart_port *port = &priv->port;
+	struct circ_buf *xmit = &port->info->xmit;
+	char ch;
+
+	spin_lock_irq(&port->lock);
+	while (true) {
+
+		/* Check for XON/XOFF (high priority) */
+		if (port->x_char) {
+			ch = port->x_char;
+			port->x_char = 0;
+			spin_unlock_irq(&port->lock);
+
+			if (do_send_message(priv, ch))
+				return;
+
+			spin_lock_irq(&port->lock);
+			continue;
+		}
+
+		/* If we're out of chars or the port is stopped, we're done */
+		if (uart_circ_empty(xmit) || uart_tx_stopped(port)) {
+			wqtuart_stop_tx(port);
+			break;
+		}
+
+		/* Grab the next char out of the buffer and send it */
+		ch = xmit->buf[xmit->tail];
+		xmit->tail = (xmit->tail + 1) & (UART_XMIT_SIZE - 1);
+		spin_unlock_irq(&port->lock);
+
+		if (do_send_message(priv, ch))
+			return;
+
+		spin_lock_irq(&port->lock);
+	}
+
+	if (uart_circ_chars_pending(xmit) < WAKEUP_CHARS)
+		uart_write_wakeup(port);
+
+	if (uart_circ_empty(xmit))
+		wqtuart_stop_tx(port);
+
+	spin_unlock_irq(&port->lock);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Interrupt Handlers                                                         */
+/*----------------------------------------------------------------------------*/
+
+/* NOTE: All handlers are called with priv->irq_lock held */
+
+static void empty_handler(struct wqt_dev *priv)
+{
+	/* Intentionally left empty */
+}
+
+static void net_start_req_handler(struct wqt_dev *priv)
+{
+	schedule_work(&priv->net_start_work);
+}
+
+static void net_start_ack_handler(struct wqt_dev *priv)
+{
+	complete(&priv->net_start_completion);
+}
+
+static void net_stop_req_handler(struct wqt_dev *priv)
+{
+	schedule_work(&priv->net_stop_work);
+}
+
+static void net_stop_ack_handler(struct wqt_dev *priv)
+{
+	complete(&priv->net_stop_completion);
+}
+
+static void net_tx_complete_handler(struct wqt_dev *priv)
+{
+	tasklet_schedule(&priv->tx_complete_tasklet);
+}
+
+static void net_rx_packet_handler(struct wqt_dev *priv)
+{
+	wqtstatus_setbit(priv, PCINET_NET_RXINT_OFF);
+	netif_rx_schedule(priv->ndev, &priv->napi);
+}
+
+static void uart_rx_ready_handler(struct wqt_dev *priv)
+{
+	wqtuart_rx_char(&priv->port, IMMR_R32(IMR0_OFFSET) & 0xff);
+	IMMR_W32(ODR_OFFSET, UART_TX_EMPTY_DBELL);
+}
+
+static void uart_tx_empty_handler(struct wqt_dev *priv)
+{
+	priv->uart_tx_ready = true;
+	wake_up(&priv->uart_tx_wait);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Interrupt Request / Free Helpers                                           */
+/*----------------------------------------------------------------------------*/
+
+static void do_enable_net_startstop_handlers(struct wqt_dev *priv)
+{
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_start_req_handler = net_start_req_handler;
+	priv->handlers.net_start_ack_handler = net_start_ack_handler;
+	priv->handlers.net_stop_req_handler = net_stop_req_handler;
+	priv->handlers.net_stop_ack_handler = net_stop_ack_handler;
+	spin_unlock_irq(&priv->irq_lock);
+
+	wqtstatus_setbit(priv, PCINET_NET_STATUS_RUNNING);
+}
+
+static void do_disable_net_startstop_handlers(struct wqt_dev *priv)
+{
+	wqtstatus_clrbit(priv, PCINET_NET_STATUS_RUNNING);
+
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_start_req_handler = empty_handler;
+	priv->handlers.net_start_ack_handler = empty_handler;
+	priv->handlers.net_stop_req_handler = empty_handler;
+	priv->handlers.net_stop_ack_handler = empty_handler;
+	spin_unlock_irq(&priv->irq_lock);
+}
+
+static void do_enable_net_rxtx_handlers(struct wqt_dev *priv)
+{
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_rx_packet_handler = net_rx_packet_handler;
+	priv->handlers.net_tx_complete_handler = net_tx_complete_handler;
+	spin_unlock_irq(&priv->irq_lock);
+}
+
+static void do_disable_net_rxtx_handlers(struct wqt_dev *priv)
+{
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_rx_packet_handler = empty_handler;
+	priv->handlers.net_tx_complete_handler = empty_handler;
+	spin_unlock_irq(&priv->irq_lock);
+}
+
+static void do_enable_uart_handlers(struct wqt_dev *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	priv->handlers.uart_rx_ready_handler = uart_rx_ready_handler;
+	priv->handlers.uart_tx_empty_handler = uart_tx_empty_handler;
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
+static void do_disable_uart_handlers(struct wqt_dev *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	priv->handlers.uart_rx_ready_handler = empty_handler;
+	priv->handlers.uart_tx_empty_handler = empty_handler;
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
+static int wqt_request_irq(struct wqt_dev *priv)
+{
+	int ret = 0;
+
+	mutex_lock(&priv->irq_mutex);
+
+	if (priv->interrupt_count > 0)
+		goto out_unlock;
+
+	/* Force all handlers to be disabled before attaching the handler */
+	do_disable_net_startstop_handlers(priv);
+	do_disable_net_rxtx_handlers(priv);
+	do_disable_uart_handlers(priv);
+
+	ret = request_irq(priv->irq,
+			  wqt_interrupt,
+			  IRQF_SHARED,
+			  priv->ndev->name,
+			  priv);
+
+out_unlock:
+	priv->interrupt_count++;
+	mutex_unlock(&priv->irq_mutex);
+
+	return ret;
+}
+
+static void wqt_free_irq(struct wqt_dev *priv)
+{
+	mutex_lock(&priv->irq_mutex);
+	priv->interrupt_count--;
+
+	if (priv->interrupt_count > 0)
+		goto out_unlock;
+
+	free_irq(priv->irq, priv);
+
+out_unlock:
+	mutex_unlock(&priv->irq_mutex);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Network Startup and Shutdown Helpers                                       */
+/*----------------------------------------------------------------------------*/
+
+/* NOTE: All helper functions prefixed with "do" must be called only from
+ * process context, with priv->net_mutex held. They are expected to sleep */
+
+static void do_net_start_queues(struct wqt_dev *priv)
+{
+	if (priv->net_state == NET_STATE_RUNNING)
+		return;
+
+	dev_dbg(priv->dev, "resetting buffer positions\n");
+	priv->cur_rx = priv->rx_base;
+	priv->cur_tx = priv->tx_base;
+	priv->dirty_tx = priv->tx_base;
+	priv->tx_free = PH_RING_SIZE;
+
+	dev_dbg(priv->dev, "enabling NAPI queue\n");
+	napi_enable(&priv->napi);
+
+	dev_dbg(priv->dev, "enabling tx_complete() tasklet\n");
+	tasklet_enable(&priv->tx_complete_tasklet);
+
+	dev_dbg(priv->dev, "enabling TX queue\n");
+	netif_start_queue(priv->ndev);
+
+	dev_dbg(priv->dev, "carrier on!\n");
+	netif_carrier_on(priv->ndev);
+
+	/* Enable the RX_PACKET and TX_COMPLETE interrupt handlers */
+	do_enable_net_rxtx_handlers(priv);
+
+	priv->net_state = NET_STATE_RUNNING;
+}
+
+static void do_net_stop_queues(struct wqt_dev *priv)
+{
+	if (priv->net_state == NET_STATE_STOPPED)
+		return;
+
+	/* Disable the RX_PACKET and TX_COMPLETE interrupt handlers */
+	do_disable_net_rxtx_handlers(priv);
+
+	dev_dbg(priv->dev, "disabling NAPI queue\n");
+	napi_disable(&priv->napi);
+
+	dev_dbg(priv->dev, "disabling tx_complete() tasklet\n");
+	tasklet_disable(&priv->tx_complete_tasklet);
+
+	dev_dbg(priv->dev, "disabling TX queue\n");
+	netif_tx_disable(priv->ndev);
+
+	dev_dbg(priv->dev, "carrier off!\n");
+	netif_carrier_off(priv->ndev);
+
+	priv->net_state = NET_STATE_STOPPED;
+}
+
+/* Called when we get a request to start our queues and acknowledge */
+static void wqtnet_start_work_fn(struct work_struct *work)
+{
+	struct wqt_dev *priv = container_of(work, struct wqt_dev,
+					    net_start_work);
+
+	mutex_lock(&priv->net_mutex);
+
+	do_net_start_queues(priv);
+	IMMR_W32(ODR_OFFSET, NET_START_ACK_DBELL);
+
+	mutex_unlock(&priv->net_mutex);
+}
+
+/* Called when we get a request to stop our queues and acknowledge */
+static void wqtnet_stop_work_fn(struct work_struct *work)
+{
+	struct wqt_dev *priv = container_of(work, struct wqt_dev,
+					    net_stop_work);
+
+	mutex_lock(&priv->net_mutex);
+
+	do_net_stop_queues(priv);
+	IMMR_W32(ODR_OFFSET, NET_STOP_ACK_DBELL);
+
+	mutex_unlock(&priv->net_mutex);
+}
+
+/*----------------------------------------------------------------------------*/
+/* DMA Operation Helpers                                                      */
+/*----------------------------------------------------------------------------*/
+
+/* Setup a static 1GB window starting at PCI address 0x0
+ *
+ * This means that all DMA must be within the first 1GB of the other side's
+ * memory, which shouldn't be a problem
+ */
+static int wqtdma_setup_outbound_window(struct wqt_dev *priv)
+{
+	IMMR_W32BE(LAWAR0_OFFSET, LAWAR0_ENABLE | 0x1d);
+	IMMR_W32BE(POCMR0_OFFSET, POCMR0_ENABLE | 0xc0000);
+	IMMR_W32BE(POTAR0_OFFSET, 0x0);
+
+	return 0;
+}
+
+static enum dma_state_client dmatest_event(struct dma_client *client,
+					   struct dma_chan *chan,
+					   enum dma_state state)
+{
+	struct wqt_dev *priv = container_of(client, struct wqt_dev, client);
+	enum dma_state_client ack = DMA_NAK;
+
+	switch (state) {
+	case DMA_RESOURCE_AVAILABLE:
+		if (chan == priv->chan)
+			ack = DMA_DUP;
+		else if (priv->chan)
+			ack = DMA_NAK;
+		else {
+			priv->chan = chan;
+			ack = DMA_ACK;
+		}
+
+		break;
+
+	case DMA_RESOURCE_REMOVED:
+		priv->chan = NULL;
+		ack = DMA_ACK;
+		break;
+
+	default:
+		dev_dbg(priv->dev, "unhandled DMA event %u (%s)\n",
+				state, chan->dev.bus_id);
+		break;
+	}
+
+	return ack;
+}
+
+static dma_cookie_t dma_async_memcpy_raw_to_buf(struct dma_chan *chan,
+						void *dest,
+						dma_addr_t src,
+						size_t len)
+{
+	struct dma_device *dev = chan->device;
+	struct dma_async_tx_descriptor *tx;
+	dma_addr_t dma_dest, dma_src;
+	dma_cookie_t cookie;
+	int cpu;
+
+	dma_src = src;
+	dma_dest = dma_map_single(dev->dev, dest, len, DMA_FROM_DEVICE);
+	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len,
+					 DMA_CTRL_ACK);
+
+	if (!tx) {
+		dma_unmap_single(dev->dev, dma_dest, len, DMA_FROM_DEVICE);
+		return -ENOMEM;
+	}
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
+static dma_cookie_t dma_async_memcpy_buf_to_raw(struct dma_chan *chan,
+						dma_addr_t dest,
+						void *src,
+						size_t len)
+{
+	struct dma_device *dev = chan->device;
+	struct dma_async_tx_descriptor *tx;
+	dma_addr_t dma_dest, dma_src;
+	dma_cookie_t cookie;
+	int cpu;
+
+	dma_src = dma_map_single(dev->dev, src, len, DMA_TO_DEVICE);
+	dma_dest = dest;
+	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len,
+					 DMA_CTRL_ACK);
+
+	if (!tx) {
+		dma_unmap_single(dev->dev, dma_src, len, DMA_TO_DEVICE);
+		return -ENOMEM;
+	}
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
+/*----------------------------------------------------------------------------*/
+/* Network Device Operations                                                  */
+/*----------------------------------------------------------------------------*/
+
+static int wqt_open(struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+	int ret;
+
+	/* Pretend the cable is unplugged until we are up and running */
+	netif_carrier_off(dev);
+
+	mutex_lock(&priv->net_mutex);
+
+	ret = wqt_request_irq(priv);
+
+	if (ret)
+		goto out_unlock;
+
+	/* Enable only the network start/stop interrupts */
+	do_enable_net_startstop_handlers(priv);
+
+	/* Check if the other side is running, if not, it will start us.
+	 * Without the interrupt handler installed, there's no way it can
+	 * respond to us anyway */
+	if (!wqtstatus_remote_testbit(priv, PCINET_NET_STATUS_RUNNING)) {
+		ret = 0;
+		goto out_unlock;
+	}
+
+	IMMR_W32(ODR_OFFSET, NET_START_REQ_DBELL);
+	ret = wait_for_completion_timeout(&priv->net_start_completion, 5*HZ);
+
+	if (!ret) {
+		/* Our start request timed out, therefore, the other
+		 * side will start us when it comes back up */
+		dev_dbg(priv->dev, "start timed out\n");
+	} else {
+		do_net_start_queues(priv);
+		ret = 0;
+	}
+
+out_unlock:
+	mutex_unlock(&priv->net_mutex);
+	return ret;
+}
+
+static int wqt_stop(struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+	int ret;
+
+	mutex_lock(&priv->net_mutex);
+
+	do_net_stop_queues(priv);
+
+	IMMR_W32(ODR_OFFSET, NET_STOP_REQ_DBELL);
+	ret = wait_for_completion_timeout(&priv->net_stop_completion, 5*HZ);
+
+	if (!ret)
+		dev_warn(priv->dev, "other side did not stop on time!\n");
+	else
+		ret = 0;
+
+	do_disable_net_startstop_handlers(priv);
+	wqt_free_irq(priv);
+
+	mutex_unlock(&priv->net_mutex);
+	return 0;
+}
+
+static int wqt_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > PH_MAX_MTU))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+static int wqt_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+	dma_cookie_t cookie;
+	enum dma_status status;
+	struct circ_buf_desc *bdp;
+	int dirty_idx;
+
+	spin_lock_bh(&priv->net_lock);
+
+	bdp = priv->cur_tx;
+	dirty_idx = bdp - priv->tx_base;
+
+	/* This should not happen, the queue should be stopped */
+	if (priv->tx_free == 0 || cbd_read(&bdp->sc) != BD_MEM_READY) {
+		netif_stop_queue(dev);
+		spin_unlock_bh(&priv->net_lock);
+		return NETDEV_TX_BUSY;
+	}
+
+	cookie = dma_async_memcpy_buf_to_raw(priv->chan,
+					     (dma_addr_t)(0x80000000 + cbd_read(&bdp->addr)),
+					     skb->data,
+					     skb->len);
+
+	if (dma_submit_error(cookie)) {
+		dev_warn(priv->dev, "DMA submit error\n");
+		spin_unlock_bh(&priv->net_lock);
+		return -ENOMEM;
+	}
+
+	status = dma_sync_wait(priv->chan, cookie);
+
+	if (status == DMA_ERROR) {
+		dev_warn(priv->dev, "DMA error\n");
+		spin_unlock_bh(&priv->net_lock);
+		return -EIO;
+	}
+
+	cbd_write(&bdp->len, skb->len);
+	wmb(); /* Ensure that the write to len happens first */
+	cbd_write(&bdp->sc, BD_MEM_DIRTY);
+
+	if (dirty_idx == PH_RING_SIZE - 1)
+		bdp = priv->tx_base;
+	else
+		bdp++;
+
+	priv->tx_skbs[dirty_idx] = skb;
+	priv->cur_tx = bdp;
+	priv->tx_free--;
+	dev->trans_start = jiffies;
+
+	if (priv->tx_free == 0)
+		netif_stop_queue(dev);
+
+	if (!wqtstatus_remote_testbit(priv, PCINET_NET_RXINT_OFF))
+		IMMR_W32(ODR_OFFSET, NET_RX_PACKET_DBELL);
+
+	spin_unlock_bh(&priv->net_lock);
+	return NETDEV_TX_OK;
+}
+
+static void wqt_tx_timeout(struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+
+	dev->stats.tx_errors++;
+	IMMR_W32(ODR_OFFSET, NET_RX_PACKET_DBELL);
+}
+
+static void wqt_tx_complete(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct wqt_dev *priv = netdev_priv(dev);
+	struct sk_buff *skb;
+	struct circ_buf_desc *bdp;
+	int do_wake, dirty_idx;
+
+	spin_lock_bh(&priv->net_lock);
+
+	bdp = priv->dirty_tx;
+	do_wake = 0;
+
+	while (cbd_read(&bdp->sc) == BD_MEM_FREE) {
+		dirty_idx = bdp - priv->tx_base;
+
+		skb = priv->tx_skbs[dirty_idx];
+
+		BUG_ON(skb == NULL);
+
+		dev->stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
+
+		dev_kfree_skb_irq(skb);
+
+		priv->tx_skbs[dirty_idx] = NULL;
+
+		/* Mark the BDP as ready */
+		cbd_write(&bdp->sc, BD_MEM_READY);
+		wmb();
+
+		/* Update the bdp */
+		if (dirty_idx == PH_RING_SIZE - 1)
+			bdp = priv->tx_base;
+		else
+			bdp++;
+
+		if (!priv->tx_free++)
+			do_wake = 1;
+	}
+
+	priv->dirty_tx = bdp;
+
+	spin_unlock_bh(&priv->net_lock);
+
+	if (do_wake)
+		netif_wake_queue(dev);
+}
+
+static int wqt_rx_napi(struct napi_struct *napi, int budget)
+{
+	struct wqt_dev *priv = container_of(napi, struct wqt_dev, napi);
+	struct net_device *dev = priv->ndev;
+	int received = 0;
+	struct sk_buff *skb;
+	dma_addr_t remote_addr;
+	dma_cookie_t cookie;
+	enum dma_status status;
+	int pkt_len, dirty_idx;
+	struct circ_buf_desc *bdp;
+
+	bdp = priv->cur_rx;
+
+	while (cbd_read(&bdp->sc) == BD_MEM_DIRTY) {
+		dirty_idx = bdp - priv->rx_base;
+
+		pkt_len = cbd_read(&bdp->len);
+		remote_addr = cbd_read(&bdp->addr);
+
+		/* Allocate a packet for the data */
+		skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
+
+		if (skb == NULL) {
+			dev->stats.rx_dropped++;
+			goto out_err;
+		}
+
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		cookie = dma_async_memcpy_raw_to_buf(priv->chan,
+						     skb->data,
+						     (dma_addr_t)(0x80000000 + remote_addr),
+						     pkt_len);
+
+		if (dma_submit_error(cookie)) {
+			dev_warn(priv->dev, "DMA submit error\n");
+			dev_kfree_skb_irq(skb);
+			dev->stats.rx_dropped++;
+			goto out_err;
+		}
+
+		status = dma_sync_wait(priv->chan, cookie);
+
+		if (status == DMA_ERROR) {
+			dev_warn(priv->dev, "DMA error\n");
+			dev_kfree_skb_irq(skb);
+			dev->stats.rx_dropped++;
+			goto out_err;
+		}
+
+		/* Push the packet into the network stack */
+		skb_put(skb, pkt_len);
+		skb->protocol = eth_type_trans(skb, dev);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		netif_receive_skb(skb);
+		received++;
+		dev->stats.rx_bytes += pkt_len;
+		dev->stats.rx_packets++;
+
+out_err:
+		cbd_write(&bdp->sc, BD_MEM_FREE);
+		wmb();
+
+		if (dirty_idx == PH_RING_SIZE - 1)
+			bdp = priv->rx_base;
+		else
+			bdp++;
+
+		if (received >= budget)
+			break;
+	}
+
+	priv->cur_rx = bdp;
+
+	/* We have processed all packets that the adapter had, but it
+	 * was less than our budget, stop polling */
+	if (received < budget) {
+		netif_rx_complete(dev, napi);
+		wqtstatus_clrbit(priv, PCINET_NET_RXINT_OFF);
+	}
+
+	IMMR_W32(ODR_OFFSET, NET_TX_COMPLETE_DBELL);
+
+	return received;
+}
+
+/*----------------------------------------------------------------------------*/
+/* UART Device Operations                                                     */
+/*----------------------------------------------------------------------------*/
+
+static unsigned int wqtuart_tx_empty(struct uart_port *port)
+{
+	return TIOCSER_TEMT;
+}
+
+static void wqtuart_set_mctrl(struct uart_port *port, unsigned int mctrl)
+{
+}
+
+static unsigned int wqtuart_get_mctrl(struct uart_port *port)
+{
+	return TIOCM_CAR | TIOCM_DSR | TIOCM_CTS;
+}
+
+static void wqtuart_stop_tx(struct uart_port *port)
+{
+}
+
+static void wqtuart_start_tx(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+
+	queue_work(priv->wq, &priv->uart_tx_work);
+}
+
+static void wqtuart_stop_rx(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+
+	do_disable_uart_handlers(priv);
+	priv->uart_rx_enabled = false;
+	wqtstatus_clrbit(priv, PCINET_UART_RX_ENABLED);
+}
+
+static void wqtuart_enable_ms(struct uart_port *port)
+{
+}
+
+static void wqtuart_break_ctl(struct uart_port *port, int break_state)
+{
+}
+
+static int wqtuart_startup(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+	int ret;
+
+	ret = wqt_request_irq(priv);
+
+	if (ret)
+		return ret;
+
+	do_enable_uart_handlers(priv);
+
+	/* Mark the transmitter and receiver ready */
+	priv->uart_tx_ready = true;
+	priv->uart_rx_enabled = true;
+	wqtstatus_setbit(priv, PCINET_UART_RX_ENABLED);
+
+	/* Let the other side know that we are ready to receive chars now */
+	IMMR_W32(ODR_OFFSET, UART_TX_EMPTY_DBELL);
+	priv->uart_open = true;
+	return 0;
+}
+
+static void wqtuart_shutdown(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+
+	wqt_free_irq(priv);
+
+	/* Make sure the uart_tx_work_fn() exits cleanly */
+	priv->uart_open = false;
+	wake_up(&priv->uart_tx_wait);
+}
+
+static void wqtuart_set_termios(struct uart_port *port,
+			       struct ktermios *termios,
+			       struct ktermios *old)
+{
+}
+
+static const char *wqtuart_type(struct uart_port *port)
+{
+	return "WQTUART";
+}
+
+static int wqtuart_request_port(struct uart_port *port)
+{
+	return 0;
+}
+
+static void wqtuart_config_port(struct uart_port *port, int flags)
+{
+}
+
+static void wqtuart_release_port(struct uart_port *port)
+{
+}
+
+static int wqtuart_verify_port(struct uart_port *port,
+			      struct serial_struct *ser)
+{
+	return 0;
+}
+
+/* This must only be called from interrupt context */
+static void wqtuart_rx_char(struct uart_port *port, const char ch)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+	struct tty_struct *tty;
+
+	spin_lock(&port->lock);
+
+	if (priv->uart_rx_enabled) {
+		tty = port->info->port.tty;
+		tty_insert_flip_char(tty, ch, TTY_NORMAL);
+		tty_flip_buffer_push(tty);
+	}
+
+	spin_unlock(&port->lock);
+}
+
+static struct uart_ops wqtuart_ops = {
+	.tx_empty	= wqtuart_tx_empty,
+	.set_mctrl	= wqtuart_set_mctrl,
+	.get_mctrl	= wqtuart_get_mctrl,
+	.stop_tx	= wqtuart_stop_tx,
+	.start_tx	= wqtuart_start_tx,
+	.stop_rx	= wqtuart_stop_rx,
+	.enable_ms	= wqtuart_enable_ms,
+	.break_ctl	= wqtuart_break_ctl,
+	.startup	= wqtuart_startup,
+	.shutdown	= wqtuart_shutdown,
+	.set_termios	= wqtuart_set_termios,
+	.type		= wqtuart_type,
+	.release_port	= wqtuart_release_port,
+	.request_port	= wqtuart_request_port,
+	.config_port	= wqtuart_config_port,
+	.verify_port	= wqtuart_verify_port,
+};
+
+static struct uart_driver wqtuart_driver = {
+	.owner		= THIS_MODULE,
+	.driver_name	= driver_name,
+	.dev_name	= "ttyPCI",
+	.major		= 240,
+	.minor		= 0,
+	.nr		= 1,
+};
+
+/*----------------------------------------------------------------------------*/
+/* Network Registers                                                          */
+/*----------------------------------------------------------------------------*/
+
+static void wqt_free_netregs(struct wqt_dev *priv)
+{
+	BUG_ON(priv->netregs == NULL);
+	BUG_ON(priv->netregs_addr == 0x0);
+
+	dma_free_coherent(priv->dev,
+			  PAGE_SIZE,
+			  priv->netregs,
+			  priv->netregs_addr);
+
+	priv->netregs = NULL;
+	priv->netregs_addr = 0x0;
+}
+
+static int wqt_init_netregs(struct wqt_dev *priv)
+{
+	u32 val;
+
+	BUG_ON(priv->netregs != NULL);
+	BUG_ON(priv->netregs_addr != 0x0);
+
+	/* Check the PCI Inbound Window Attributes Register 0 for a 4k window
+	 * This is PCI BAR1, and will be used as network device registers */
+	val = IMMR_R32BE(PIWAR0_OFFSET);
+	val = val & (PIWAR0_ENABLED | PIWAR0_IWS_4K);
+
+	if (val != (PIWAR0_ENABLED | PIWAR0_IWS_4K)) {
+		dev_dbg(priv->dev, "PIWAR0 set up incorrectly\n");
+		return -ENODEV;
+	}
+
+	priv->netregs = dma_alloc_coherent(priv->dev,
+					   PAGE_SIZE,
+					   &priv->netregs_addr,
+					   GFP_KERNEL);
+
+	if (!priv->netregs) {
+		dev_dbg(priv->dev, "Unable to allocate netregs\n");
+		return -ENOMEM;
+	}
+
+	/* Write the page address into the address register */
+	IMMR_W32BE(PITAR0_OFFSET, priv->netregs_addr >> 12);
+	return 0;
+}
+
+/*----------------------------------------------------------------------------*/
+/* OpenFirmware Device Subsystem                                              */
+/*----------------------------------------------------------------------------*/
+
+static int wqt_probe(struct of_device *op, const struct of_device_id *match)
+{
+	struct net_device *ndev;
+	struct wqt_dev *priv;
+	int ret;
+
+	ndev = alloc_etherdev(sizeof(*priv));
+
+	if (!ndev) {
+		ret = -ENOMEM;
+		goto out_alloc_ndev;
+	}
+
+	dev_set_drvdata(&op->dev, ndev);
+	priv = netdev_priv(ndev);
+	priv->dev = &op->dev;
+	priv->ndev = ndev;
+
+	spin_lock_init(&priv->irq_lock);
+	mutex_init(&priv->irq_mutex);
+
+	/* Hardware Initialization */
+	priv->irq = irq_of_parse_and_map(op->node, 0);
+	priv->immr = ioremap(get_immrbase(), 0x100000);
+
+	if (!priv->immr) {
+		ret = -ENOMEM;
+		goto out_ioremap_immr;
+	}
+
+	ret = wqt_init_netregs(priv);
+
+	if (ret)
+		goto out_init_netregs;
+
+	/* NOTE: Yes, this is correct. Everything was written as if this
+	 * NOTE: side *is* a network card. So the place the card is
+	 * NOTE: receiving from is the other side's TX buffers */
+	priv->rx_base = priv->netregs + PCINET_TXBD_BASE;
+	priv->tx_base = priv->netregs + PCINET_RXBD_BASE;
+	wqtstatus_setbit(priv, PCINET_NET_REGISTERS_VALID);
+
+	/* DMA Client */
+	wqtdma_setup_outbound_window(priv);
+	priv->client.event_callback = dmatest_event;
+	dma_cap_set(DMA_MEMCPY, priv->client.cap_mask);
+	dma_async_client_register(&priv->client);
+	dma_async_client_chan_request(&priv->client);
+
+	/* Initialize private data */
+	priv->wq = create_singlethread_workqueue(driver_name);
+
+	if (!priv->wq) {
+		ret = -ENOMEM;
+		goto out_create_workqueue;
+	}
+
+	INIT_WORK(&priv->uart_tx_work, uart_tx_work_fn);
+	init_waitqueue_head(&priv->uart_tx_wait);
+	priv->uart_tx_ready = true;
+
+	tasklet_init(&priv->tx_complete_tasklet, wqt_tx_complete,
+		     (unsigned long)ndev);
+	tasklet_disable(&priv->tx_complete_tasklet);
+	spin_lock_init(&priv->net_lock);
+
+	mutex_init(&priv->net_mutex);
+	priv->net_state = NET_STATE_STOPPED;
+	INIT_WORK(&priv->net_start_work, wqtnet_start_work_fn);
+	INIT_WORK(&priv->net_stop_work, wqtnet_stop_work_fn);
+	init_completion(&priv->net_start_completion);
+	init_completion(&priv->net_stop_completion);
+
+	/* Mask all of the MBOX interrupts */
+	IMMR_W32(IMIMR_OFFSET, 0x1 | 0x2);
+
+	/* Network Device */
+	random_ether_addr(ndev->dev_addr);
+
+	ndev->open              = wqt_open;
+	ndev->stop              = wqt_stop;
+	ndev->change_mtu        = wqt_change_mtu;
+	ndev->hard_start_xmit   = wqt_hard_start_xmit;
+	ndev->tx_timeout        = wqt_tx_timeout;
+	ndev->watchdog_timeo    = HZ/4;
+	ndev->flags            &= ~IFF_MULTICAST;  /* No multicast support */
+	ndev->features         |= NETIF_F_NO_CSUM; /* No checksum needed */
+	ndev->mtu               = PH_MAX_MTU;
+	netif_napi_add(ndev, &priv->napi, wqt_rx_napi, PH_RING_SIZE);
+
+	ret = register_netdev(ndev);
+
+	if (ret)
+		goto out_register_netdev;
+
+	/* UART Device */
+	priv->port.ops = &wqtuart_ops;
+	priv->port.type = PORT_16550A;
+	priv->port.dev = &op->dev;
+	priv->port.line = 0;
+	spin_lock_init(&priv->port.lock);
+
+	ret = uart_add_one_port(&wqtuart_driver, &priv->port);
+
+	if (ret)
+		goto out_add_uart_port;
+
+	dev_info(priv->dev, "using ethernet device %s\n", ndev->name);
+	dev_info(priv->dev, "using serial device %s%d\n",
+			wqtuart_driver.dev_name, priv->port.line);
+	return 0;
+
+out_add_uart_port:
+	unregister_netdev(ndev);
+out_register_netdev:
+	destroy_workqueue(priv->wq);
+out_create_workqueue:
+	wqt_free_netregs(priv);
+out_init_netregs:
+	iounmap(priv->immr);
+out_ioremap_immr:
+	free_netdev(ndev);
+out_alloc_ndev:
+	return ret;
+}
+
+static int wqt_remove(struct of_device *op)
+{
+	struct net_device *ndev = dev_get_drvdata(&op->dev);
+	struct wqt_dev *priv = netdev_priv(ndev);
+
+	uart_remove_one_port(&wqtuart_driver, &priv->port);
+	unregister_netdev(priv->ndev);
+
+	flush_workqueue(priv->wq);
+	destroy_workqueue(priv->wq);
+
+	wqtstatus_clrbit(priv, PCINET_NET_REGISTERS_VALID);
+	wqt_free_netregs(priv);
+
+	dma_async_client_unregister(&priv->client);
+
+	iounmap(priv->immr);
+
+	free_netdev(ndev);
+
+	return 0;
+}
+
+static struct of_device_id wqt_match[] = {
+	{ .compatible = "fsl,mpc8349-mu", },
+	{},
+};
+
+static struct of_platform_driver wqt_of_driver = {
+	.owner		= THIS_MODULE,
+	.name		= driver_name,
+	.match_table	= wqt_match,
+	.probe		= wqt_probe,
+	.remove		= wqt_remove,
+};
+
+/*----------------------------------------------------------------------------*/
+/* DMA Client Infrastructure                                                  */
+/*----------------------------------------------------------------------------*/
+
+/*----------------------------------------------------------------------------*/
+/* Module Init / Exit                                                         */
+/*----------------------------------------------------------------------------*/
+
+static int __init wqt_init(void)
+{
+	int ret;
+
+	ret = uart_register_driver(&wqtuart_driver);
+
+	if (ret)
+		goto out_uart_register_driver;
+
+	ret = of_register_platform_driver(&wqt_of_driver);
+
+	if (ret)
+		goto out_of_register_platform_driver;
+
+	return 0;
+
+out_of_register_platform_driver:
+	uart_unregister_driver(&wqtuart_driver);
+out_uart_register_driver:
+	return ret;
+}
+
+static void __exit wqt_exit(void)
+{
+	of_unregister_platform_driver(&wqt_of_driver);
+	uart_unregister_driver(&wqtuart_driver);
+}
+
+MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
+MODULE_DESCRIPTION("PCINet/PCISerial Driver for MPC8349EMDS");
+MODULE_LICENSE("GPL");
+
+module_init(wqt_init);
+module_exit(wqt_exit);
diff --git a/drivers/net/pcinet_host.c b/drivers/net/pcinet_host.c
new file mode 100644
index 0000000..b4e6c04
--- /dev/null
+++ b/drivers/net/pcinet_host.c
@@ -0,0 +1,1388 @@
+/*
+ * PCINet and PCISerial Driver for Freescale MPC8349EMDS (Host side)
+ *
+ * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
+ *
+ * Heavily inspired by the drivers/net/fs_enet driver
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include <linux/interrupt.h>
+#include <linux/irqreturn.h>
+#include <linux/pci.h>
+#include <linux/serial.h>
+#include <linux/serial_core.h>
+#include <linux/etherdevice.h>
+#include <linux/mutex.h>
+
+#include "pcinet.h"
+#include "pcinet_hw.h"
+
+/* IMMR Accessor Helpers */
+#define IMMR_R32(_off) ioread32(priv->immr+(_off))
+#define IMMR_W32(_off, _val) iowrite32((_val), priv->immr+(_off))
+#define IMMR_R32BE(_off) ioread32be(priv->immr+(_off))
+#define IMMR_W32BE(_off, _val) iowrite32be((_val), priv->immr+(_off))
+
+static const char driver_name[] = "wqt";
+
+static void wqtuart_rx_char(struct uart_port *port, const char ch);
+static void wqtuart_stop_tx(struct uart_port *port);
+
+struct wqt_dev;
+typedef void (*wqt_irqhandler_t)(struct wqt_dev *);
+
+struct wqt_irqhandlers {
+	wqt_irqhandler_t net_start_req_handler;
+	wqt_irqhandler_t net_start_ack_handler;
+	wqt_irqhandler_t net_stop_req_handler;
+	wqt_irqhandler_t net_stop_ack_handler;
+	wqt_irqhandler_t net_rx_packet_handler;
+	wqt_irqhandler_t net_tx_complete_handler;
+	wqt_irqhandler_t uart_rx_ready_handler;
+	wqt_irqhandler_t uart_tx_empty_handler;
+};
+
+struct wqt_dev {
+	/*--------------------------------------------------------------------*/
+	/* PCI Infrastructure                                                 */
+	/*--------------------------------------------------------------------*/
+	struct pci_dev *pdev;
+	struct device *dev;
+	void __iomem *immr;
+
+	struct mutex irq_mutex;
+	int interrupt_count;
+
+	spinlock_t irq_lock;
+	struct wqt_irqhandlers handlers;
+
+	/*--------------------------------------------------------------------*/
+	/* UART Device Infrastructure                                         */
+	/*--------------------------------------------------------------------*/
+	struct uart_port port;
+	bool uart_rx_enabled;
+	bool uart_open;
+
+	struct workqueue_struct *wq;
+	struct work_struct uart_tx_work;
+	wait_queue_head_t uart_tx_wait; /* sleep for uart_tx_ready */
+	bool uart_tx_ready; /* transmitter state */
+
+	/*--------------------------------------------------------------------*/
+	/* Ethernet Device Infrastructure                                     */
+	/*--------------------------------------------------------------------*/
+	struct net_device *ndev;
+	void __iomem *netregs;
+
+	/* Outstanding SKB */
+	struct sk_buff *rx_skbs[PH_RING_SIZE];
+	struct sk_buff *tx_skbs[PH_RING_SIZE];
+	dma_addr_t rx_skb_addrs[PH_RING_SIZE];
+	dma_addr_t tx_skb_addrs[PH_RING_SIZE];
+
+	/* Circular Buffer Descriptor base */
+	struct circ_buf_desc __iomem *rx_base;
+	struct circ_buf_desc __iomem *tx_base;
+
+	/* Current SKB index */
+	struct circ_buf_desc __iomem *cur_rx;
+	struct circ_buf_desc __iomem *cur_tx;
+	struct circ_buf_desc __iomem *dirty_tx;
+	int tx_free;
+
+	struct tasklet_struct tx_complete_tasklet;
+	spinlock_t net_lock;
+
+	struct mutex net_mutex;
+	int net_state;
+	struct work_struct net_start_work;
+	struct work_struct net_stop_work;
+	struct completion net_start_completion;
+	struct completion net_stop_completion;
+	struct napi_struct napi;
+};
+
+/*----------------------------------------------------------------------------*/
+/* Buffer Descriptor Accessor Helpers                                         */
+/*----------------------------------------------------------------------------*/
+
+static inline void cbd_write(void __iomem *addr, u32 val)
+{
+	iowrite32(val, addr);
+}
+
+static inline u32 cbd_read(void __iomem *addr)
+{
+	return ioread32(addr);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Status Register Helper Operations                                          */
+/*----------------------------------------------------------------------------*/
+
+static DEFINE_SPINLOCK(status_lock);
+
+static void wqtstatus_setbit(struct wqt_dev *priv, u32 bit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&status_lock, flags);
+	IMMR_W32(IMR1_OFFSET, IMMR_R32(IMR1_OFFSET) | bit);
+	spin_unlock_irqrestore(&status_lock, flags);
+}
+
+static void wqtstatus_clrbit(struct wqt_dev *priv, u32 bit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&status_lock, flags);
+	IMMR_W32(IMR1_OFFSET, IMMR_R32(IMR1_OFFSET) & ~bit);
+	spin_unlock_irqrestore(&status_lock, flags);
+}
+
+static int wqtstatus_remote_testbit(struct wqt_dev *priv, u32 bit)
+{
+	return IMMR_R32(OMR1_OFFSET) & bit;
+}
+
+/*----------------------------------------------------------------------------*/
+/* Message Sending and Processing Operations                                  */
+/*----------------------------------------------------------------------------*/
+
+static irqreturn_t wqt_interrupt(int irq, void *dev_id)
+{
+	struct wqt_dev *priv = dev_id;
+	u32 omisr, odr;
+
+	omisr = IMMR_R32(OMISR_OFFSET);
+	odr = IMMR_R32(ODR_OFFSET);
+
+	if (!(omisr & 0x8))
+		return IRQ_NONE;
+
+	/* Clear all of the interrupt sources, we'll handle them next */
+	IMMR_W32(ODR_OFFSET, odr);
+
+	/* Lock over all of the handlers, so they cannot get called when
+	 * the code doesn't expect them to be called */
+	spin_lock(&priv->irq_lock);
+
+	if (odr & UART_RX_READY_DBELL)
+		priv->handlers.uart_rx_ready_handler(priv);
+
+	if (odr & UART_TX_EMPTY_DBELL)
+		priv->handlers.uart_tx_empty_handler(priv);
+
+	if (odr & NET_RX_PACKET_DBELL)
+		priv->handlers.net_rx_packet_handler(priv);
+
+	if (odr & NET_TX_COMPLETE_DBELL)
+		priv->handlers.net_tx_complete_handler(priv);
+
+	if (odr & NET_START_REQ_DBELL)
+		priv->handlers.net_start_req_handler(priv);
+
+	if (odr & NET_START_ACK_DBELL)
+		priv->handlers.net_start_ack_handler(priv);
+
+	if (odr & NET_STOP_REQ_DBELL)
+		priv->handlers.net_stop_req_handler(priv);
+
+	if (odr & NET_STOP_ACK_DBELL)
+		priv->handlers.net_stop_ack_handler(priv);
+
+	spin_unlock(&priv->irq_lock);
+
+	return IRQ_HANDLED;
+}
+
+/* Send a character through the mbox when it becomes available
+ * Blocking, must not be called with any spinlocks held */
+static int do_send_message(struct wqt_dev *priv, const char ch)
+{
+	struct uart_port *port = &priv->port;
+	bool tmp;
+
+	spin_lock_irq(&priv->irq_lock);
+	while (priv->uart_tx_ready != true) {
+		spin_unlock_irq(&priv->irq_lock);
+		wait_event_timeout(priv->uart_tx_wait, priv->uart_tx_ready, HZ);
+
+		spin_lock_irq(&port->lock);
+		tmp = priv->uart_open;
+		spin_unlock_irq(&port->lock);
+
+		if (!tmp)
+			return -EIO;
+
+		spin_lock_irq(&priv->irq_lock);
+	}
+
+	/* Now the transmitter is free, send the message */
+	IMMR_W32(IMR0_OFFSET, ch);
+	IMMR_W32(IDR_OFFSET, UART_RX_READY_DBELL);
+
+	/* Mark the transmitter busy */
+	priv->uart_tx_ready = false;
+	spin_unlock_irq(&priv->irq_lock);
+	return 0;
+}
+
+/* Grab a character out of the uart tx buffer and send it */
+static void uart_tx_work_fn(struct work_struct *work)
+{
+	struct wqt_dev *priv = container_of(work, struct wqt_dev, uart_tx_work);
+	struct uart_port *port = &priv->port;
+	struct circ_buf *xmit = &port->info->xmit;
+	char ch;
+
+	spin_lock_irq(&port->lock);
+	while (true) {
+
+		/* Check for XON/XOFF (high priority) */
+		if (port->x_char) {
+			ch = port->x_char;
+			port->x_char = 0;
+			spin_unlock_irq(&port->lock);
+
+			if (do_send_message(priv, ch))
+				return;
+
+			spin_lock_irq(&port->lock);
+			continue;
+		}
+
+		/* If we're out of chars or the port is stopped, we're done */
+		if (uart_circ_empty(xmit) || uart_tx_stopped(port)) {
+			wqtuart_stop_tx(port);
+			break;
+		}
+
+		/* Grab the next char out of the buffer and send it */
+		ch = xmit->buf[xmit->tail];
+		xmit->tail = (xmit->tail + 1) & (UART_XMIT_SIZE - 1);
+		spin_unlock_irq(&port->lock);
+
+		if (do_send_message(priv, ch))
+			return;
+
+		spin_lock_irq(&port->lock);
+	}
+
+	if (uart_circ_chars_pending(xmit) < WAKEUP_CHARS)
+		uart_write_wakeup(port);
+
+	if (uart_circ_empty(xmit))
+		wqtuart_stop_tx(port);
+
+	spin_unlock_irq(&port->lock);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Interrupt Handlers                                                         */
+/*----------------------------------------------------------------------------*/
+
+/* NOTE: All handlers are called with priv->irq_lock held */
+
+static void empty_handler(struct wqt_dev *priv)
+{
+	/* Intentionally left empty */
+}
+
+static void net_start_req_handler(struct wqt_dev *priv)
+{
+	schedule_work(&priv->net_start_work);
+}
+
+static void net_start_ack_handler(struct wqt_dev *priv)
+{
+	complete(&priv->net_start_completion);
+}
+
+static void net_stop_req_handler(struct wqt_dev *priv)
+{
+	schedule_work(&priv->net_stop_work);
+}
+
+static void net_stop_ack_handler(struct wqt_dev *priv)
+{
+	complete(&priv->net_stop_completion);
+}
+
+static void net_tx_complete_handler(struct wqt_dev *priv)
+{
+	tasklet_schedule(&priv->tx_complete_tasklet);
+}
+
+static void net_rx_packet_handler(struct wqt_dev *priv)
+{
+	wqtstatus_setbit(priv, PCINET_NET_RXINT_OFF);
+	netif_rx_schedule(priv->ndev, &priv->napi);
+}
+
+static void uart_rx_ready_handler(struct wqt_dev *priv)
+{
+	wqtuart_rx_char(&priv->port, IMMR_R32(OMR0_OFFSET) & 0xff);
+	IMMR_W32(IDR_OFFSET, UART_TX_EMPTY_DBELL);
+}
+
+static void uart_tx_empty_handler(struct wqt_dev *priv)
+{
+	priv->uart_tx_ready = true;
+	wake_up(&priv->uart_tx_wait);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Interrupt Request / Free Helpers                                           */
+/*----------------------------------------------------------------------------*/
+
+static void do_enable_net_startstop_handlers(struct wqt_dev *priv)
+{
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_start_req_handler = net_start_req_handler;
+	priv->handlers.net_start_ack_handler = net_start_ack_handler;
+	priv->handlers.net_stop_req_handler = net_stop_req_handler;
+	priv->handlers.net_stop_ack_handler = net_stop_ack_handler;
+	spin_unlock_irq(&priv->irq_lock);
+
+	wqtstatus_setbit(priv, PCINET_NET_STATUS_RUNNING);
+}
+
+static void do_disable_net_startstop_handlers(struct wqt_dev *priv)
+{
+	wqtstatus_clrbit(priv, PCINET_NET_STATUS_RUNNING);
+
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_start_req_handler = empty_handler;
+	priv->handlers.net_start_ack_handler = empty_handler;
+	priv->handlers.net_stop_req_handler = empty_handler;
+	priv->handlers.net_stop_ack_handler = empty_handler;
+	spin_unlock_irq(&priv->irq_lock);
+}
+
+static void do_enable_net_rxtx_handlers(struct wqt_dev *priv)
+{
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_rx_packet_handler = net_rx_packet_handler;
+	priv->handlers.net_tx_complete_handler = net_tx_complete_handler;
+	spin_unlock_irq(&priv->irq_lock);
+}
+
+static void do_disable_net_rxtx_handlers(struct wqt_dev *priv)
+{
+	spin_lock_irq(&priv->irq_lock);
+	priv->handlers.net_rx_packet_handler = empty_handler;
+	priv->handlers.net_tx_complete_handler = empty_handler;
+	spin_unlock_irq(&priv->irq_lock);
+}
+
+static void do_enable_uart_handlers(struct wqt_dev *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	priv->handlers.uart_rx_ready_handler = uart_rx_ready_handler;
+	priv->handlers.uart_tx_empty_handler = uart_tx_empty_handler;
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
+static void do_disable_uart_handlers(struct wqt_dev *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	priv->handlers.uart_rx_ready_handler = empty_handler;
+	priv->handlers.uart_tx_empty_handler = empty_handler;
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
+static int wqt_request_irq(struct wqt_dev *priv)
+{
+	int ret = 0;
+
+	mutex_lock(&priv->irq_mutex);
+
+	if (priv->interrupt_count > 0)
+		goto out_unlock;
+
+	/* Force all handlers to be disabled before attaching the handler */
+	do_disable_net_startstop_handlers(priv);
+	do_disable_net_rxtx_handlers(priv);
+	do_disable_uart_handlers(priv);
+
+	/* NOTE: we MUST use pdev->irq here, sometimes it changes AFTER
+	 * NOTE: probe() has finished.... */
+	ret = request_irq(priv->pdev->irq,
+			  wqt_interrupt,
+			  IRQF_SHARED,
+			  priv->ndev->name,
+			  priv);
+
+out_unlock:
+	priv->interrupt_count++;
+	mutex_unlock(&priv->irq_mutex);
+
+	return ret;
+}
+
+static void wqt_free_irq(struct wqt_dev *priv)
+{
+	mutex_lock(&priv->irq_mutex);
+	priv->interrupt_count--;
+
+	if (priv->interrupt_count > 0)
+		goto out_unlock;
+
+	free_irq(priv->pdev->irq, priv);
+
+out_unlock:
+	mutex_unlock(&priv->irq_mutex);
+}
+
+/*----------------------------------------------------------------------------*/
+/* Network Startup and Shutdown Helpers                                       */
+/*----------------------------------------------------------------------------*/
+
+/* NOTE: All helper functions prefixed with "do" must be called only from
+ * process context, with priv->net_mutex held. They are expected to sleep */
+
+/* NOTE: queues must be stopped before initializing and uninitializing */
+
+static void do_net_initialize_board(struct wqt_dev *priv)
+{
+	int i;
+	struct circ_buf_desc __iomem *bdp;
+
+	BUG_ON(!wqtstatus_remote_testbit(priv, PCINET_NET_REGISTERS_VALID));
+
+	/* Fill in RX ring */
+	for (i = 0, bdp = priv->rx_base; i < PH_RING_SIZE; bdp++, i++) {
+		cbd_write(&bdp->sc, BD_MEM_READY);
+		cbd_write(&bdp->len, PH_MAX_FRSIZE);
+		cbd_write(&bdp->addr, priv->rx_skb_addrs[i]);
+	}
+
+	/* Fill in TX ring */
+	for (i = 0, bdp = priv->tx_base; i < PH_RING_SIZE; bdp++, i++) {
+		cbd_write(&bdp->sc, BD_MEM_READY);
+		cbd_write(&bdp->len, 0);
+		cbd_write(&bdp->addr, 0x0);
+	}
+}
+
+static void do_net_uninitialize_board(struct wqt_dev *priv)
+{
+	struct sk_buff *skb;
+	dma_addr_t skb_addr;
+	struct circ_buf_desc __iomem *bdp;
+	int i;
+
+	/* Reset TX ring */
+	for (i = 0, bdp = priv->tx_base; i < PH_RING_SIZE; bdp++, i++) {
+		if (priv->tx_skbs[i]) {
+			skb = priv->tx_skbs[i];
+			skb_addr = priv->tx_skb_addrs[i];
+
+			dma_unmap_single(priv->dev,
+					 skb_addr,
+					 skb->len,
+					 DMA_TO_DEVICE);
+
+			dev_kfree_skb(skb);
+
+			priv->tx_skbs[i] = NULL;
+			priv->tx_skb_addrs[i] = 0x0;
+		}
+
+		cbd_write(&bdp->sc, BD_MEM_READY);
+		cbd_write(&bdp->len, 0);
+		cbd_write(&bdp->addr, 0x0);
+	}
+}
+
+static void do_net_start_queues(struct wqt_dev *priv)
+{
+	if (priv->net_state == NET_STATE_RUNNING)
+		return;
+
+	dev_dbg(priv->dev, "resetting buffer positions\n");
+	priv->cur_rx = priv->rx_base;
+	priv->cur_tx = priv->tx_base;
+	priv->dirty_tx = priv->tx_base;
+	priv->tx_free = PH_RING_SIZE;
+
+	dev_dbg(priv->dev, "enabling NAPI queue\n");
+	napi_enable(&priv->napi);
+
+	dev_dbg(priv->dev, "enabling tx_complete() tasklet\n");
+	tasklet_enable(&priv->tx_complete_tasklet);
+
+	dev_dbg(priv->dev, "enabling TX queue\n");
+	netif_start_queue(priv->ndev);
+
+	dev_dbg(priv->dev, "carrier on!\n");
+	netif_carrier_on(priv->ndev);
+
+	/* Enable the RX_PACKET and TX_COMPLETE interrupt handlers */
+	do_enable_net_rxtx_handlers(priv);
+
+	priv->net_state = NET_STATE_RUNNING;
+}
+
+static void do_net_stop_queues(struct wqt_dev *priv)
+{
+	if (priv->net_state == NET_STATE_STOPPED)
+		return;
+
+	/* Disable the RX_PACKET and TX_COMPLETE interrupt handlers */
+	do_disable_net_rxtx_handlers(priv);
+
+	dev_dbg(priv->dev, "disabling NAPI queue\n");
+	napi_disable(&priv->napi);
+
+	dev_dbg(priv->dev, "disabling tx_complete() tasklet\n");
+	tasklet_disable(&priv->tx_complete_tasklet);
+
+	dev_dbg(priv->dev, "disabling TX queue\n");
+	netif_tx_disable(priv->ndev);
+
+	dev_dbg(priv->dev, "carrier off!\n");
+	netif_carrier_off(priv->ndev);
+
+	priv->net_state = NET_STATE_STOPPED;
+}
+
+/* Called when we get a request to start our queues and acknowledge */
+static void wqtnet_start_work_fn(struct work_struct *work)
+{
+	struct wqt_dev *priv = container_of(work, struct wqt_dev,
+					    net_start_work);
+
+	mutex_lock(&priv->net_mutex);
+
+	do_net_initialize_board(priv);
+	do_net_start_queues(priv);
+	IMMR_W32(IDR_OFFSET, NET_START_ACK_DBELL);
+
+	mutex_unlock(&priv->net_mutex);
+}
+
+/* Called when we get a request to stop our queues and acknowledge */
+static void wqtnet_stop_work_fn(struct work_struct *work)
+{
+	struct wqt_dev *priv = container_of(work, struct wqt_dev,
+					    net_stop_work);
+
+	mutex_lock(&priv->net_mutex);
+
+	do_net_stop_queues(priv);
+	do_net_uninitialize_board(priv);
+	IMMR_W32(IDR_OFFSET, NET_STOP_ACK_DBELL);
+
+	mutex_unlock(&priv->net_mutex);
+}
+
+/*----------------------------------------------------------------------------*/
+/* SKB Allocation Helpers                                                     */
+/*----------------------------------------------------------------------------*/
+
+static void wqt_cleanup_skbs(struct wqt_dev *priv)
+{
+	struct sk_buff *skb;
+	dma_addr_t skb_addr;
+	int i;
+
+	/* TX ring */
+	for (i = 0; i < PH_RING_SIZE; ++i) {
+		if (priv->tx_skbs[i]) {
+			skb = priv->tx_skbs[i];
+			skb_addr = priv->tx_skb_addrs[i];
+
+			dma_unmap_single(priv->dev,
+					 skb_addr,
+					 skb->len,
+					 DMA_TO_DEVICE);
+
+			dev_kfree_skb(skb);
+
+			priv->tx_skbs[i] = NULL;
+			priv->tx_skb_addrs[i] = 0x0;
+		}
+	}
+
+	/* RX ring */
+	for (i = 0; i < PH_RING_SIZE; ++i) {
+		if (priv->rx_skbs[i]) {
+			skb = priv->rx_skbs[i];
+			skb_addr = priv->rx_skb_addrs[i];
+
+			dma_unmap_single(priv->dev,
+					 skb_addr,
+					 PH_MAX_FRSIZE,
+					 DMA_FROM_DEVICE);
+
+			dev_kfree_skb(skb);
+
+			priv->rx_skbs[i] = NULL;
+			priv->rx_skb_addrs[i] = 0x0;
+		}
+	}
+}
+
+static int wqt_alloc_skbs(struct wqt_dev *priv)
+{
+	struct sk_buff *skb;
+	dma_addr_t skb_addr;
+	int i;
+
+	/* RX ring */
+	for (i = 0; i < PH_RING_SIZE; ++i) {
+		/* Paranoia check */
+		BUG_ON(priv->rx_skbs[i] != NULL);
+		BUG_ON(priv->rx_skb_addrs[i] != 0x0);
+
+		/* Allocate the skb */
+		skb = dev_alloc_skb(PH_MAX_FRSIZE + NET_IP_ALIGN);
+
+		if (skb == NULL)
+			goto out_err;
+
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		/* DMA map the skb */
+		skb_addr = dma_map_single(priv->dev,
+					  skb->data,
+					  PH_MAX_FRSIZE,
+					  DMA_FROM_DEVICE);
+
+		if (dma_mapping_error(priv->dev, skb_addr)) {
+			dev_kfree_skb(skb);
+			goto out_err;
+		}
+
+		priv->rx_skbs[i] = skb;
+		priv->rx_skb_addrs[i] = skb_addr;
+	}
+
+	/* TX ring */
+	for (i = 0; i < PH_RING_SIZE; ++i) {
+		/* Paranoia check */
+		BUG_ON(priv->tx_skbs[i] != NULL);
+		BUG_ON(priv->tx_skb_addrs[i] != 0x0);
+	}
+
+	/* NOTE: the actual initialization of the board happens
+	 * NOTE: in ph_initialize_board(), once the board has
+	 * NOTE: requested to be initialized */
+
+	return 0;
+
+out_err:
+	wqt_cleanup_skbs(priv);
+	return -ENOMEM;
+}
+
+/*----------------------------------------------------------------------------*/
+/* Network Device Operations                                                  */
+/*----------------------------------------------------------------------------*/
+
+static int wqt_open(struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+	int ret;
+
+	/* Check that the other side has registers */
+	if (!wqtstatus_remote_testbit(priv, PCINET_NET_REGISTERS_VALID)) {
+		dev_err(priv->dev, "no driver installed at the other end\n");
+		dev_err(priv->dev, "cowardly refusing to open\n");
+		return -ENOTCONN; /* Transport endpoint is not connected */
+	}
+
+	/* Pretend the cable is unplugged until we are up and running */
+	netif_carrier_off(dev);
+
+	mutex_lock(&priv->net_mutex);
+
+	ret = wqt_alloc_skbs(priv);
+
+	if (ret)
+		goto out_err;
+
+	do_net_initialize_board(priv);
+
+	ret = wqt_request_irq(priv);
+
+	if (ret)
+		goto out_err;
+
+	/* Enable only the network start/stop interrupts */
+	do_enable_net_startstop_handlers(priv);
+
+	/* Check if the other side is running, if not, it will start us.
+	 * Without the interrupt handler installed, there's no way it can
+	 * respond to us anyway */
+	if (!wqtstatus_remote_testbit(priv, PCINET_NET_STATUS_RUNNING))
+		goto out_unlock;
+
+	do_net_initialize_board(priv);
+
+	IMMR_W32(IDR_OFFSET, NET_START_REQ_DBELL);
+	ret = wait_for_completion_timeout(&priv->net_start_completion, 5*HZ);
+
+	if (!ret) {
+		/* Our start request timed out, therefore, the other
+		 * side will start us when it comes back up */
+		dev_dbg(priv->dev, "start timed out\n");
+	} else {
+		do_net_start_queues(priv);
+		ret = 0;
+	}
+
+out_unlock:
+	mutex_unlock(&priv->net_mutex);
+	return 0;
+
+out_err:
+	wqt_cleanup_skbs(priv);
+	mutex_unlock(&priv->net_mutex);
+	return ret;
+}
+
+static int wqt_stop(struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+	int ret;
+
+	mutex_lock(&priv->net_mutex);
+
+	do_net_stop_queues(priv);
+
+	IMMR_W32(IDR_OFFSET, NET_STOP_REQ_DBELL);
+	ret = wait_for_completion_timeout(&priv->net_stop_completion, 5*HZ);
+
+	if (!ret)
+		dev_warn(priv->dev, "other side did not stop on time!\n");
+	else
+		ret = 0;
+
+	do_disable_net_startstop_handlers(priv);
+	wqt_free_irq(priv);
+	do_net_uninitialize_board(priv);
+	wqt_cleanup_skbs(priv);
+
+	mutex_unlock(&priv->net_mutex);
+	return 0;
+}
+
+static int wqt_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > PH_MAX_MTU))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+static int wqt_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+	dma_addr_t skb_addr;
+	struct circ_buf_desc __iomem *bdp;
+	int dirty_idx;
+
+	spin_lock_bh(&priv->net_lock);
+
+	bdp = priv->cur_tx;
+	dirty_idx = bdp - priv->tx_base;
+
+	/* This should not happen, the queue should be stopped */
+	if (priv->tx_free == 0 || cbd_read(&bdp->sc) != BD_MEM_READY) {
+		netif_stop_queue(dev);
+		spin_unlock_bh(&priv->net_lock);
+		return NETDEV_TX_BUSY;
+	}
+
+	skb_addr = dma_map_single(priv->dev,
+				  skb->data,
+				  skb->len,
+				  DMA_TO_DEVICE);
+
+	if (dma_mapping_error(priv->dev, skb_addr)) {
+		dev_warn(priv->dev, "DMA mapping error\n");
+		spin_unlock_bh(&priv->net_lock);
+		return -ENOMEM;
+	}
+
+	BUG_ON(priv->tx_skbs[dirty_idx] != NULL);
+	BUG_ON(priv->tx_skb_addrs[dirty_idx] != 0x0);
+
+	priv->tx_skbs[dirty_idx] = skb;
+	priv->tx_skb_addrs[dirty_idx] = skb_addr;
+
+	cbd_write(&bdp->len, skb->len);
+	cbd_write(&bdp->addr, skb_addr);
+	cbd_write(&bdp->sc, BD_MEM_DIRTY);
+
+	if (dirty_idx == PH_RING_SIZE - 1)
+		bdp = priv->tx_base;
+	else
+		bdp++;
+
+	priv->cur_tx = bdp;
+	priv->tx_free--;
+	dev->trans_start = jiffies;
+
+	if (priv->tx_free == 0)
+		netif_stop_queue(dev);
+
+	if (!wqtstatus_remote_testbit(priv, PCINET_NET_RXINT_OFF))
+		IMMR_W32(IDR_OFFSET, NET_RX_PACKET_DBELL);
+
+	spin_unlock_bh(&priv->net_lock);
+	return NETDEV_TX_OK;
+}
+
+static void wqt_tx_timeout(struct net_device *dev)
+{
+	struct wqt_dev *priv = netdev_priv(dev);
+
+	dev->stats.tx_errors++;
+	IMMR_W32(IDR_OFFSET, NET_RX_PACKET_DBELL);
+}
+
+static void wqt_tx_complete(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct wqt_dev *priv = netdev_priv(dev);
+	struct sk_buff *skb;
+	dma_addr_t skb_addr;
+	struct circ_buf_desc __iomem *bdp;
+	int do_wake, dirty_idx;
+
+	spin_lock_bh(&priv->net_lock);
+
+	bdp = priv->dirty_tx;
+	do_wake = 0;
+
+	while (cbd_read(&bdp->sc) == BD_MEM_FREE) {
+		dirty_idx = bdp - priv->tx_base;
+
+		skb = priv->tx_skbs[dirty_idx];
+		skb_addr = priv->tx_skb_addrs[dirty_idx];
+
+		BUG_ON(skb == NULL);
+		BUG_ON(skb_addr == 0x0);
+
+		dev->stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
+
+		/* Unmap and free the transmitted skb */
+		dma_unmap_single(priv->dev,
+				 skb_addr,
+				 skb->len,
+				 DMA_TO_DEVICE);
+		dev_kfree_skb_irq(skb);
+
+		priv->tx_skbs[dirty_idx] = NULL;
+		priv->tx_skb_addrs[dirty_idx] = 0x0;
+
+		/* Invalidate the buffer descriptor */
+		cbd_write(&bdp->len, 0);
+		cbd_write(&bdp->addr, 0x0);
+		cbd_write(&bdp->sc, BD_MEM_READY);
+
+		/* Update the bdp */
+		if (dirty_idx == PH_RING_SIZE - 1)
+			bdp = priv->tx_base;
+		else
+			bdp++;
+
+		if (!priv->tx_free++)
+			do_wake = 1;
+	}
+
+	priv->dirty_tx = bdp;
+
+	spin_unlock_bh(&priv->net_lock);
+
+	if (do_wake)
+		netif_wake_queue(dev);
+}
+
+static int wqt_rx_napi(struct napi_struct *napi, int budget)
+{
+	struct wqt_dev *priv = container_of(napi, struct wqt_dev, napi);
+	struct net_device *dev = priv->ndev;
+	int received = 0;
+	struct sk_buff *skb, *skbn;
+	dma_addr_t skb_addr, skbn_addr;
+	int pkt_len, dirty_idx;
+	struct circ_buf_desc __iomem *bdp;
+
+	bdp = priv->cur_rx;
+
+	while (cbd_read(&bdp->sc) == BD_MEM_DIRTY) {
+		dirty_idx = bdp - priv->rx_base;
+
+		skb = priv->rx_skbs[dirty_idx];
+		skb_addr = priv->rx_skb_addrs[dirty_idx];
+
+		BUG_ON(skb == NULL);
+		BUG_ON(skb_addr == 0x0);
+
+		/* Allocate the next rx skb and DMA map it */
+		skbn = dev_alloc_skb(PH_MAX_FRSIZE + NET_IP_ALIGN);
+
+		if (skbn == NULL) {
+			skbn = skb;
+			skbn_addr = skb_addr;
+			dev->stats.rx_dropped++;
+			goto out_noalloc;
+		}
+
+		skb_reserve(skbn, NET_IP_ALIGN);
+
+		skbn_addr = dma_map_single(priv->dev,
+					   skbn->data,
+					   PH_MAX_FRSIZE,
+					   DMA_FROM_DEVICE);
+
+		if (dma_mapping_error(priv->dev, skbn_addr)) {
+			dev_kfree_skb_irq(skbn);
+			skbn = skb;
+			skbn_addr = skb_addr;
+			dev->stats.rx_dropped++;
+			goto out_noalloc;
+		}
+
+		/* DMA unmap the old skb and pass it up */
+		dma_unmap_single(priv->dev,
+				 skb_addr,
+				 PH_MAX_FRSIZE,
+				 DMA_FROM_DEVICE);
+
+		pkt_len = cbd_read(&bdp->len);
+		skb_put(skb, pkt_len);
+		skb->protocol = eth_type_trans(skb, dev);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		netif_receive_skb(skb);
+		received++;
+		dev->stats.rx_bytes += pkt_len;
+		dev->stats.rx_packets++;
+
+out_noalloc:
+		/* Write the new skb into the buffer descriptor */
+		cbd_write(&bdp->len, PH_MAX_FRSIZE);
+		cbd_write(&bdp->addr, skbn_addr);
+		cbd_write(&bdp->sc, BD_MEM_FREE);
+
+		priv->rx_skbs[dirty_idx] = skbn;
+		priv->rx_skb_addrs[dirty_idx] = skbn_addr;
+
+		/* Update the bdp */
+		if (dirty_idx == PH_RING_SIZE - 1)
+			bdp = priv->rx_base;
+		else
+			bdp++;
+
+		if (received >= budget)
+			break;
+	}
+
+	priv->cur_rx = bdp;
+
+	/* We have processed all packets that the adapter had, but it
+	 * was less than our budget, stop polling */
+	if (received < budget) {
+		netif_rx_complete(dev, napi);
+		wqtstatus_clrbit(priv, PCINET_NET_RXINT_OFF);
+	}
+
+	IMMR_W32(IDR_OFFSET, NET_TX_COMPLETE_DBELL);
+
+	return received;
+}
+
+/*----------------------------------------------------------------------------*/
+/* UART Device Operations                                                     */
+/*----------------------------------------------------------------------------*/
+
+static unsigned int wqtuart_tx_empty(struct uart_port *port)
+{
+	return TIOCSER_TEMT;
+}
+
+static void wqtuart_set_mctrl(struct uart_port *port, unsigned int mctrl)
+{
+}
+
+static unsigned int wqtuart_get_mctrl(struct uart_port *port)
+{
+	return TIOCM_CAR | TIOCM_DSR | TIOCM_CTS;
+}
+
+static void wqtuart_stop_tx(struct uart_port *port)
+{
+}
+
+static void wqtuart_start_tx(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+
+	queue_work(priv->wq, &priv->uart_tx_work);
+}
+
+static void wqtuart_stop_rx(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+
+	do_disable_uart_handlers(priv);
+	priv->uart_rx_enabled = false;
+	wqtstatus_clrbit(priv, PCINET_UART_RX_ENABLED);
+}
+
+static void wqtuart_enable_ms(struct uart_port *port)
+{
+}
+
+static void wqtuart_break_ctl(struct uart_port *port, int break_state)
+{
+}
+
+static int wqtuart_startup(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+	int ret;
+
+	ret = wqt_request_irq(priv);
+
+	if (ret)
+		return ret;
+
+	do_enable_uart_handlers(priv);
+
+	/* Mark the transmitter and receiver ready */
+	priv->uart_tx_ready = true;
+	priv->uart_rx_enabled = true;
+	wqtstatus_setbit(priv, PCINET_UART_RX_ENABLED);
+
+	/* Let the other side know that we are ready to receive chars now */
+	IMMR_W32(IDR_OFFSET, UART_TX_EMPTY_DBELL);
+	priv->uart_open = true;
+	return 0;
+}
+
+static void wqtuart_shutdown(struct uart_port *port)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+
+	wqt_free_irq(priv);
+
+	/* Make sure the uart_tx_work_fn() exits cleanly */
+	priv->uart_open = false;
+	wake_up(&priv->uart_tx_wait);
+}
+
+static void wqtuart_set_termios(struct uart_port *port,
+			       struct ktermios *termios,
+			       struct ktermios *old)
+{
+}
+
+static const char *wqtuart_type(struct uart_port *port)
+{
+	return "WQTUART";
+}
+
+static int wqtuart_request_port(struct uart_port *port)
+{
+	return 0;
+}
+
+static void wqtuart_config_port(struct uart_port *port, int flags)
+{
+}
+
+static void wqtuart_release_port(struct uart_port *port)
+{
+}
+
+static int wqtuart_verify_port(struct uart_port *port,
+			      struct serial_struct *ser)
+{
+	return 0;
+}
+
+/* This must only be called from interrupt context */
+static void wqtuart_rx_char(struct uart_port *port, const char ch)
+{
+	struct wqt_dev *priv = container_of(port, struct wqt_dev, port);
+	struct tty_struct *tty;
+
+	spin_lock(&port->lock);
+
+	if (priv->uart_rx_enabled) {
+		tty = port->info->port.tty;
+		tty_insert_flip_char(tty, ch, TTY_NORMAL);
+		tty_flip_buffer_push(tty);
+	}
+
+	spin_unlock(&port->lock);
+}
+
+static struct uart_ops wqtuart_ops = {
+	.tx_empty	= wqtuart_tx_empty,
+	.set_mctrl	= wqtuart_set_mctrl,
+	.get_mctrl	= wqtuart_get_mctrl,
+	.stop_tx	= wqtuart_stop_tx,
+	.start_tx	= wqtuart_start_tx,
+	.stop_rx	= wqtuart_stop_rx,
+	.enable_ms	= wqtuart_enable_ms,
+	.break_ctl	= wqtuart_break_ctl,
+	.startup	= wqtuart_startup,
+	.shutdown	= wqtuart_shutdown,
+	.set_termios	= wqtuart_set_termios,
+	.type		= wqtuart_type,
+	.release_port	= wqtuart_release_port,
+	.request_port	= wqtuart_request_port,
+	.config_port	= wqtuart_config_port,
+	.verify_port	= wqtuart_verify_port,
+};
+
+static struct uart_driver wqtuart_driver = {
+	.owner		= THIS_MODULE,
+	.driver_name	= driver_name,
+	.dev_name	= "ttyPCI",
+	.major		= 240,
+	.minor		= 0,
+	.nr		= 1,
+};
+
+/*----------------------------------------------------------------------------*/
+/* PCI Subsystem                                                              */
+/*----------------------------------------------------------------------------*/
+
+static int wqt_probe(struct pci_dev *dev, const struct pci_device_id *id)
+{
+	struct net_device *ndev;
+	struct wqt_dev *priv;
+	int ret;
+
+	ndev = alloc_etherdev(sizeof(*priv));
+
+	if (!ndev) {
+		ret = -ENOMEM;
+		goto out_alloc_ndev;
+	}
+
+	pci_set_drvdata(dev, ndev);
+	priv = netdev_priv(ndev);
+	priv->pdev = dev;
+	priv->dev = &dev->dev;
+	priv->ndev = ndev;
+
+	mutex_init(&priv->irq_mutex);
+	spin_lock_init(&priv->irq_lock);
+
+	/* Hardware Initialization */
+	ret = pci_enable_device(dev);
+
+	if (ret)
+		goto out_pci_enable_dev;
+
+	pci_set_master(dev);
+
+	ret = pci_request_regions(dev, driver_name);
+
+	if (ret)
+		goto out_pci_request_regions;
+
+	priv->immr = pci_iomap(dev, 0, 0);
+
+	if (!priv->immr) {
+		ret = -ENOMEM;
+		goto out_iomap_immr;
+	}
+
+	priv->netregs = pci_iomap(dev, 1, 0);
+
+	if (!priv->netregs) {
+		ret = -ENOMEM;
+		goto out_iomap_netregs;
+	}
+
+	priv->rx_base = priv->netregs + PCINET_RXBD_BASE;
+	priv->tx_base = priv->netregs + PCINET_TXBD_BASE;
+
+	ret = dma_set_mask(&dev->dev, 0xcfffffff);
+
+	if (ret) {
+		dev_err(&dev->dev, "Unable to set DMA mask\n");
+		ret = -ENODEV;
+		goto out_set_dma_mask;
+	}
+
+	/* Initialize private data */
+	priv->wq = create_singlethread_workqueue(driver_name);
+
+	if (!priv->wq) {
+		ret = -ENOMEM;
+		goto out_create_workqueue;
+	}
+
+	INIT_WORK(&priv->uart_tx_work, uart_tx_work_fn);
+	init_waitqueue_head(&priv->uart_tx_wait);
+	priv->uart_tx_ready = true;
+
+	tasklet_init(&priv->tx_complete_tasklet, wqt_tx_complete,
+		     (unsigned long)ndev);
+	tasklet_disable(&priv->tx_complete_tasklet);
+	spin_lock_init(&priv->net_lock);
+
+	mutex_init(&priv->net_mutex);
+	priv->net_state = NET_STATE_STOPPED;
+	INIT_WORK(&priv->net_start_work, wqtnet_start_work_fn);
+	INIT_WORK(&priv->net_stop_work, wqtnet_stop_work_fn);
+	init_completion(&priv->net_start_completion);
+	init_completion(&priv->net_stop_completion);
+
+	/* Mask all of the MBOX interrupts */
+	IMMR_W32(OMIMR_OFFSET, 0x1 | 0x2);
+
+	/* Network Device */
+	random_ether_addr(ndev->dev_addr);
+
+	ndev->open              = wqt_open;
+	ndev->stop              = wqt_stop;
+	ndev->change_mtu        = wqt_change_mtu;
+	ndev->hard_start_xmit   = wqt_hard_start_xmit;
+	ndev->tx_timeout        = wqt_tx_timeout;
+	ndev->watchdog_timeo    = HZ/4;
+	ndev->flags            &= ~IFF_MULTICAST;  /* No multicast support */
+	ndev->features         |= NETIF_F_NO_CSUM; /* No checksum needed */
+	ndev->mtu               = PH_MAX_MTU;
+	netif_napi_add(ndev, &priv->napi, wqt_rx_napi, PH_RING_SIZE);
+
+	ret = register_netdev(ndev);
+
+	if (ret)
+		goto out_register_netdev;
+
+	/* UART Device */
+	priv->port.ops = &wqtuart_ops;
+	priv->port.type = PORT_16550A;
+	priv->port.dev = &dev->dev;
+	priv->port.line = 0;
+	spin_lock_init(&priv->port.lock);
+
+	ret = uart_add_one_port(&wqtuart_driver, &priv->port);
+
+	if (ret)
+		goto out_add_uart_port;
+
+	dev_info(priv->dev, "using ethernet device %s\n", ndev->name);
+	dev_info(priv->dev, "using serial device %s%d\n",
+			wqtuart_driver.dev_name, priv->port.line);
+	return 0;
+
+out_add_uart_port:
+	unregister_netdev(ndev);
+out_register_netdev:
+	destroy_workqueue(priv->wq);
+out_create_workqueue:
+out_set_dma_mask:
+	pci_iounmap(dev, priv->netregs);
+out_iomap_netregs:
+	pci_iounmap(dev, priv->immr);
+out_iomap_immr:
+	pci_release_regions(dev);
+out_pci_request_regions:
+	pci_disable_device(dev);
+out_pci_enable_dev:
+	free_netdev(ndev);
+out_alloc_ndev:
+	return ret;
+}
+
+static void wqt_remove(struct pci_dev *dev)
+{
+	struct net_device *ndev = pci_get_drvdata(dev);
+	struct wqt_dev *priv = netdev_priv(ndev);
+
+	uart_remove_one_port(&wqtuart_driver, &priv->port);
+	unregister_netdev(priv->ndev);
+
+	flush_workqueue(priv->wq);
+	destroy_workqueue(priv->wq);
+
+	pci_iounmap(dev, priv->netregs);
+	pci_iounmap(dev, priv->immr);
+	pci_release_regions(dev);
+	pci_disable_device(dev);
+
+	free_netdev(ndev);
+}
+
+#define PCI_DEVID_FSL_MPC8349EMDS 0x0080
+
+/* The list of devices that this module will support */
+static struct pci_device_id wqt_ids[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_FREESCALE, PCI_DEVID_FSL_MPC8349EMDS), },
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, wqt_ids);
+
+static struct pci_driver wqt_pci_driver = {
+	.name     = (char *)driver_name,
+	.id_table = wqt_ids,
+	.probe    = wqt_probe,
+	.remove   = wqt_remove,
+};
+
+/*----------------------------------------------------------------------------*/
+/* Module Init / Exit                                                         */
+/*----------------------------------------------------------------------------*/
+
+static int __init wqt_init(void)
+{
+	int ret;
+
+	ret = uart_register_driver(&wqtuart_driver);
+
+	if (ret)
+		goto out_uart_register_driver;
+
+	ret = pci_register_driver(&wqt_pci_driver);
+
+	if (ret)
+		goto out_pci_register_driver;
+
+	return 0;
+
+out_pci_register_driver:
+	uart_unregister_driver(&wqtuart_driver);
+out_uart_register_driver:
+	return ret;
+}
+
+static void __exit wqt_exit(void)
+{
+	pci_unregister_driver(&wqt_pci_driver);
+	uart_unregister_driver(&wqtuart_driver);
+}
+
+MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
+MODULE_DESCRIPTION("PCINet/PCISerial Driver for MPC8349EMDS (Host side)");
+MODULE_LICENSE("GPL");
+
+module_init(wqt_init);
+module_exit(wqt_exit);
diff --git a/drivers/net/pcinet_hw.h b/drivers/net/pcinet_hw.h
new file mode 100644
index 0000000..499ba61
--- /dev/null
+++ b/drivers/net/pcinet_hw.h
@@ -0,0 +1,77 @@
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

