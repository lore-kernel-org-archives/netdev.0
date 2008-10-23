From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC v1] net: add PCINet driver
Date: Thu, 23 Oct 2008 16:13:11 -0700
Message-ID: <20081023161311.5e568972@extreme>
References: <20081023224932.GA23441@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34772 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753636AbYJWXNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 19:13:18 -0400
In-Reply-To: <20081023224932.GA23441@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Oct 2008 15:49:32 -0700
Ira Snyder <iws@ovro.caltech.edu> wrote:

> This adds support to Linux for a virtual ethernet interface which uses the
> PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> method of communication for two devices connected by a PCI interface.
> 
> I have implemented client support for the Freescale MPC8349EMDS board,
> which is capable of running in PCI Agent mode (It acts like a PCI card, but
> is a complete PowerPC computer, running Linux). It is almost certainly
> trivially ported to any MPC83xx system. It should be a relatively small
> effort to port it to any chip that can generate PCI interrupts and has at
> least one PCI accessible scratch register.
> 
> It was developed to work in a CompactPCI crate of computers, one of which
> is a relatively standard x86 system (acting as the host) and many PowerPC
> systems (acting as clients).
> 
> Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
> ---
> 
> This is my second posting of this driver. I posted it to the linux-netdev
> list a week ago, but did not get any replies. Therefore, I'll post it for a
> wider audience. :)
> 
> Hello everyone. This is my first network driver, so take it easy on me. :)
> I'm quite sure it isn't ready for inclusion into mainline yet, but I think
> it is in good enough shape for some review.
> 
> Through conversations on IRC, I have been led to believe that this has been
> done before, but no implementations have been made public. My employer has
> no problems with me making this public, so I thought it would be good to
> post it. I don't know if something like this is even desired for mainline
> inclusion, but I do know that even having an example driver to base this on
> would have saved me some effort.
> 
> The major issues I see:
> 1) The name wqt originally stood for "workqueue-test" and somewhat evolved
> into this driver. I'm looking for suggestions. I'd like to have something
> that is the same between the host and client drivers, since most of the
> code is identical. It makes copy/paste easier. The only one I can come up
> with is "bpc" for "Backplane Communications".
> 2) In the Freescale client driver, I use the whole set of IMMR (board
> control) registers. I only need a very small subset of them only during
> startup. I used them the way I did so I could use the same pcinet_hw.h file
> for both the client and server drivers.
> 3) I just ioremap()ed the IMMR registers directly. (They're at 0xe0000000).
> I just didn't know a better way to do this. I need them to set up the PCI
> memory containing the buffer descriptors.
> 4) I just hardcoded the address of the outbound PCI window into the DMA
> transfer code. It is at 0x80000000. Suggestions are welcome.
> 
> Why I made some decisions:
> 1) The PCINET_NET_REGISTERS_VALID bit: I want to be able to use this driver
> from U-Boot to copy a kernel, etc. over the PCI backplane to boot up the
> board. This meant that the memory that I used for the buffer descriptors
> disappears while the machine is booting Linux. Suggestions are welcome.
> 2) The buffer descriptors in client memory, rather than host memory: I
> thought it seemed more logical. Also, in my application, the clients will
> be transferring much more data to the host.
> 3) Use of the Freescale (client) DMA controller to transfer all data: I
> tried transferring all of the data using the CPU on each board. This turned
> out to be extremely slow, as in 2-3 MB/sec max. Using the DMA controller, I
> get ~40 MB/sec (tested with netperf).
> 4) Use of a static 1GB window to access the host's memory (to copy skbs):
> Maintaining the window while DMA's are in flight, and then changing them
> seemed to be too much trouble. A static window just seemed easier. Also,
> removing the overhead of moving the window from each skb transferred
> actually gave a reasonable speedup. (I tested it.)
> 5) The uart stuff: I needed a method to talk to the U-Boot bootloader on
> these boards without plugging in a serial cable. When my project gets
> going, I'll have 150 of them. Booting them one at a time is out of the
> question. A virtual serial port was simple to implement using the same
> hardware that I used for the network driver.
> 
> I'll post the U-Boot driver to their mailing list once this driver is
> finalized.
> 
> Thanks,
> Ira
> 
> 
>  drivers/net/Kconfig       |   34 ++
>  drivers/net/Makefile      |    3 +
>  drivers/net/pcinet.h      |   77 +++
>  drivers/net/pcinet_fsl.c  | 1360 +++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/pcinet_host.c | 1392 +++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/pcinet_hw.h   |   80 +++
>  6 files changed, 2946 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/pcinet.h
>  create mode 100644 drivers/net/pcinet_fsl.c
>  create mode 100644 drivers/net/pcinet_host.c
>  create mode 100644 drivers/net/pcinet_hw.h
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 4a11296..9185803 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2259,6 +2259,40 @@ config UGETH_TX_ON_DEMAND
>  	bool "Transmit on Demand support"
>  	depends on UCC_GETH
>  
> +config PCINET_FSL
> +	tristate "PCINet Virtual Ethernet over PCI support (Freescale)"
> +	depends on MPC834x_MDS && !PCI
> +	select DMA_ENGINE
> +	select FSL_DMA
> +	help
> +	  When running as a PCI Agent, this driver will create a virtual
> +	  ethernet link running over the PCI bus, allowing simplified
> +	  communication with the host system. The host system will need
> +	  to use the corresponding driver.
> +
> +	  If in doubt, say N.
> +
> +config PCINET_HOST
> +	tristate "PCINet Virtual Ethernet over PCI support (Host)"
> +	depends on PCI
> +	help
> +	  This driver will let you communicate with a PCINet client device
> +	  using a virtual ethernet link running over the PCI bus. This
> +	  allows simplified communication with the client system.
> +
> +	  This is inteded for use in a system that has a crate full of
> +	  computers running Linux, all connected by a PCI backplane.
> +
> +	  If in doubt, say N.
> +
> +config PCINET_DISABLE_CHECKSUM
> +	bool "Disable packet checksumming"
> +	depends on PCINET_FSL || PCINET_HOST
> +	default n
> +	help
> +	  Disable packet checksumming on packets received by the PCINet
> +	  driver. This gives a possible speed boost.
> +
>  config MV643XX_ETH
>  	tristate "Marvell Discovery (643XX) and Orion ethernet support"
>  	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 7629c90..547c9d0 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -27,6 +27,9 @@ gianfar_driver-objs := gianfar.o \
>  obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
>  ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o ucc_geth_ethtool.o
>  
> +obj-$(CONFIG_PCINET_FSL) += pcinet_fsl.o
> +obj-$(CONFIG_PCINET_HOST) += pcinet_host.o
> +
>  #
>  # link order important here
>  #
> diff --git a/drivers/net/pcinet.h b/drivers/net/pcinet.h
> new file mode 100644
> index 0000000..3738904
> --- /dev/null
> +++ b/drivers/net/pcinet.h
> @@ -0,0 +1,77 @@
> +/*
> + * Shared Definitions for the PCINet / PCISerial drivers
> + *
> + * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * Heavily inspired by the drivers/net/fs_enet driver
> + *
> + * This file is licensed under the terms of the GNU General Public License
> + * version 2. This program is licensed "as is" without any warranty of any
> + * kind, whether express or implied.
> + */
> +
> +#ifndef PCINET_H
> +#define PCINET_H
> +
> +#include <linux/kernel.h>
> +#include <linux/if_ether.h>
> +
> +/* Ring and Frame size -- these must match between the drivers */
> +#define PH_RING_SIZE	(64)
> +#define PH_MAX_FRSIZE	(64 * 1024)
> +#define PH_MAX_MTU	(PH_MAX_FRSIZE - ETH_HLEN)
> +
> +struct circ_buf_desc {
> +	__le32 sc;
> +	__le32 len;
> +	__le32 addr;
> +} __attribute__((__packed__));
> +typedef struct circ_buf_desc cbd_t;
> +
> +/* Buffer Descriptor Accessors */
> +#define CBDW_SC(_cbd, _sc) iowrite32((_sc), &(_cbd)->sc)
> +#define CBDW_LEN(_cbd, _len) iowrite32((_len), &(_cbd)->len)
> +#define CBDW_ADDR(_cbd, _addr) iowrite32((_addr), &(_cbd)->addr)
> +
> +#define CBDR_SC(_cbd) ioread32(&(_cbd)->sc)
> +#define CBDR_LEN(_cbd) ioread32(&(_cbd)->len)
> +#define CBDR_ADDR(_cbd) ioread32(&(_cbd)->addr)
> +
> +/* Buffer Descriptor Registers */
> +#define PCINET_TXBD_BASE	0x400
> +#define PCINET_RXBD_BASE	0x800
> +
> +/* Buffer Descriptor Status */
> +#define BD_MEM_READY		0x1
> +#define BD_MEM_DIRTY		0x2
> +#define BD_MEM_FREE		0x3
> +
> +/* IMMR Accessor Helpers */
> +#define IMMR_R32(_off) ioread32(priv->immr+(_off))
> +#define IMMR_W32(_off, _val) iowrite32((_val), priv->immr+(_off))
> +#define IMMR_R32BE(_off) ioread32be(priv->immr+(_off))
> +#define IMMR_W32BE(_off, _val) iowrite32be((_val), priv->immr+(_off))
> +
> +/* Status Register Bits */
> +#define PCINET_UART_RX_ENABLED		(1<<0)
> +#define PCINET_NET_STATUS_RUNNING	(1<<1)
> +#define PCINET_NET_RXINT_OFF		(1<<2)
> +#define PCINET_NET_REGISTERS_VALID	(1<<3)
> +
> +/* Driver State Bits */
> +#define NET_STATE_STOPPED	0
> +#define NET_STATE_RUNNING	1
> +
> +/* Doorbell Registers */
> +#define UART_RX_READY_DBELL	(1<<0)
> +#define UART_TX_EMPTY_DBELL	(1<<1)
> +#define NET_RX_PACKET_DBELL	(1<<2)
> +#define NET_TX_COMPLETE_DBELL	(1<<3)
> +#define NET_START_REQ_DBELL	(1<<4)
> +#define NET_START_ACK_DBELL	(1<<5)
> +#define NET_STOP_REQ_DBELL	(1<<6)
> +#define NET_STOP_ACK_DBELL	(1<<7)
> +
> +#endif /* PCINET_H */
> +
> +/* vim: set ts=8 sts=8 sw=8 noet tw=92: */

Bah, don't add vim: cruft

> diff --git a/drivers/net/pcinet_fsl.c b/drivers/net/pcinet_fsl.c
> new file mode 100644
> index 0000000..049d1ff
> --- /dev/null
> +++ b/drivers/net/pcinet_fsl.c
> @@ -0,0 +1,1360 @@
> +/*
> + * PCINet and PCISerial Driver for Freescale MPC8349EMDS
> + *
> + * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * Heavily inspired by the drivers/net/fs_enet driver
> + *
> + * This file is licensed under the terms of the GNU General Public License
> + * version 2. This program is licensed "as is" without any warranty of any
> + * kind, whether express or implied.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/of_platform.h>
> +#include <linux/sched.h>
> +#include <linux/wait.h>
> +#include <linux/interrupt.h>
> +#include <linux/irqreturn.h>
> +#include <linux/delay.h>
> +#include <linux/io.h>
> +#include <linux/serial.h>
> +#include <linux/serial_core.h>
> +#include <linux/etherdevice.h>
> +#include <linux/mutex.h>
> +#include <linux/dmaengine.h>
> +
> +#include "pcinet.h"
> +#include "pcinet_hw.h"
> +
> +static const char driver_name[] = "wqt";
> +
> +static void wqtuart_rx_char(struct uart_port *port, const char ch);
> +static void wqtuart_stop_tx(struct uart_port *port);
> +
> +struct wqt_dev;
> +typedef void (*wqt_irqhandler_t)(struct wqt_dev *);
> +
> +struct wqt_irqhandlers {
> +	wqt_irqhandler_t net_start_req_handler;
> +	wqt_irqhandler_t net_start_ack_handler;
> +	wqt_irqhandler_t net_stop_req_handler;
> +	wqt_irqhandler_t net_stop_ack_handler;
> +	wqt_irqhandler_t net_rx_packet_handler;
> +	wqt_irqhandler_t net_tx_complete_handler;
> +	wqt_irqhandler_t uart_rx_ready_handler;
> +	wqt_irqhandler_t uart_tx_empty_handler;
> +};
> +
> +struct wqt_dev {
> +	/*--------------------------------------------------------------------*/
> +	/* OpenFirmware Infrastructure                                        */
> +	/*--------------------------------------------------------------------*/
> +	struct of_device *op;
> +	struct device *dev;
> +	int irq;
> +	void __iomem *immr;
> +
> +	struct mutex irq_mutex;
> +	int interrupt_count;
> +
> +	spinlock_t irq_lock;
> +	struct wqt_irqhandlers handlers;
> +
> +	/*--------------------------------------------------------------------*/
> +	/* UART Device Infrastructure                                         */
> +	/*--------------------------------------------------------------------*/
> +	struct uart_port port;
> +	bool uart_rx_enabled;
> +	bool uart_open;
> +
> +	struct workqueue_struct *wq;
> +	struct work_struct uart_tx_work;
> +	wait_queue_head_t uart_tx_wait; /* sleep for uart_tx_ready */
> +	bool uart_tx_ready; /* transmitter state */
> +
> +	/*--------------------------------------------------------------------*/
> +	/* Ethernet Device Infrastructure                                     */
> +	/*--------------------------------------------------------------------*/
> +	struct net_device *ndev;
> +	void __iomem *netregs;
> +	dma_addr_t netregs_addr;
> +
> +	/* Outstanding SKB */
> +	struct sk_buff *tx_skbs[PH_RING_SIZE];
> +
> +	/* Circular Buffer Descriptor base */
> +	cbd_t __iomem *rx_base;
> +	cbd_t __iomem *tx_base;
> +
> +	/* Current SKB index */
> +	cbd_t __iomem *cur_rx;
> +	cbd_t __iomem *cur_tx;
> +	cbd_t __iomem *dirty_tx;
> +	int tx_free;
> +
> +	struct tasklet_struct tx_complete_tasklet;
> +	spinlock_t net_lock;
> +
> +	struct mutex net_mutex;
> +	int net_state;
> +	struct work_struct net_start_work;
> +	struct work_struct net_stop_work;
> +	struct completion net_start_completion;
> +	struct completion net_stop_completion;
> +	struct napi_struct napi;
> +
> +	struct dma_client client;
> +	struct dma_chan *chan;
> +};
> +
> +/*----------------------------------------------------------------------------*/
> +/* Status Register Helper Operations                                          */
> +/*----------------------------------------------------------------------------*/
> +
> +static DEFINE_SPINLOCK(status_lock);
> +
> +static void wqtstatus_setbit(struct wqt_dev *priv, u32 bit)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&status_lock, flags);
> +	IMMR_W32(OMR1_OFFSET, IMMR_R32(OMR1_OFFSET) | bit);
> +	spin_unlock_irqrestore(&status_lock, flags);
> +}
> +
> +static void wqtstatus_clrbit(struct wqt_dev *priv, u32 bit)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&status_lock, flags);
> +	IMMR_W32(OMR1_OFFSET, IMMR_R32(OMR1_OFFSET) & ~bit);
> +	spin_unlock_irqrestore(&status_lock, flags);
> +}
> +
> +static int wqtstatus_remote_testbit(struct wqt_dev *priv, u32 bit)
> +{
> +	return IMMR_R32(IMR1_OFFSET) & bit;
> +}
> +
> +/*----------------------------------------------------------------------------*/
> +/* Message Sending and Processing Operations                                  */
> +/*----------------------------------------------------------------------------*/
> +
> +static irqreturn_t wqt_interrupt(int irq, void *dev_id)
> +{
> +	struct wqt_dev *priv = dev_id;
> +	u32 imisr, idr;
> +	unsigned long flags;
> +
> +	imisr = IMMR_R32(IMISR_OFFSET);
> +	idr = IMMR_R32(IDR_OFFSET);
> +
> +	if (!(imisr & 0x8))
> +		return IRQ_NONE;
> +
> +	/* Clear all of the interrupt sources, we'll handle them next */
> +	IMMR_W32(IDR_OFFSET, idr);
> +
> +	/* Lock over all of the handlers, so they cannot get called when
> +	 * the code doesn't expect them to be called */
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +
> +	if (idr & UART_RX_READY_DBELL)
> +		priv->handlers.uart_rx_ready_handler(priv);
> +
> +	if (idr & UART_TX_EMPTY_DBELL)
> +		priv->handlers.uart_tx_empty_handler(priv);
> +
> +	if (idr & NET_RX_PACKET_DBELL)
> +		priv->handlers.net_rx_packet_handler(priv);
> +
> +	if (idr & NET_TX_COMPLETE_DBELL)
> +		priv->handlers.net_tx_complete_handler(priv);
> +
> +	if (idr & NET_START_REQ_DBELL)
> +		priv->handlers.net_start_req_handler(priv);
> +
> +	if (idr & NET_START_ACK_DBELL)
> +		priv->handlers.net_start_ack_handler(priv);
> +
> +	if (idr & NET_STOP_REQ_DBELL)
> +		priv->handlers.net_stop_req_handler(priv);
> +
> +	if (idr & NET_STOP_ACK_DBELL)
> +		priv->handlers.net_stop_ack_handler(priv);
> +
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +/* Send a character through the mbox when it becomes available
> + * Blocking, must not be called with any spinlocks held */
> +static int do_send_message(struct wqt_dev *priv, const char ch)
> +{
> +	struct uart_port *port = &priv->port;
> +	bool tmp;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +	while (priv->uart_tx_ready != true) {
> +		spin_unlock_irqrestore(&priv->irq_lock, flags);
> +		wait_event_timeout(priv->uart_tx_wait, priv->uart_tx_ready, HZ);
> +
> +		spin_lock_irqsave(&port->lock, flags);
> +		tmp = priv->uart_open;
> +		spin_unlock_irqrestore(&port->lock, flags);
> +
> +		if (!tmp)
> +			return -EIO;
> +
> +		spin_lock_irqsave(&priv->irq_lock, flags);
> +	}
> +
> +	/* Now the transmitter is free, send the message */
> +	IMMR_W32(OMR0_OFFSET, ch);
> +	IMMR_W32(ODR_OFFSET, UART_RX_READY_DBELL);
> +
> +	/* Mark the transmitter busy */
> +	priv->uart_tx_ready = false;
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +	return 0;
> +}
> +
> +/* Grab a character out of the uart tx buffer and send it */
> +static void uart_tx_work_fn(struct work_struct *work)
> +{
> +	struct wqt_dev *priv = container_of(work, struct wqt_dev, uart_tx_work);
> +	struct uart_port *port = &priv->port;
> +	struct circ_buf *xmit = &port->info->xmit;
> +	char ch;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&port->lock, flags);
> +	while (true) {
> +
> +		/* Check for XON/XOFF (high priority) */
> +		if (port->x_char) {
> +			ch = port->x_char;
> +			port->x_char = 0;
> +			spin_unlock_irqrestore(&port->lock, flags);
> +
> +			if (do_send_message(priv, ch))
> +				return;
> +
> +			spin_lock_irqsave(&port->lock, flags);
> +			continue;
> +		}
> +
> +		/* If we're out of chars or the port is stopped, we're done */
> +		if (uart_circ_empty(xmit) || uart_tx_stopped(port)) {
> +			wqtuart_stop_tx(port);
> +			break;
> +		}
> +
> +		/* Grab the next char out of the buffer and send it */
> +		ch = xmit->buf[xmit->tail];
> +		xmit->tail = (xmit->tail + 1) & (UART_XMIT_SIZE - 1);
> +		spin_unlock_irqrestore(&port->lock, flags);
> +
> +		if (do_send_message(priv, ch))
> +			return;
> +
> +		spin_lock_irqsave(&port->lock, flags);
> +	}
> +
> +	if (uart_circ_chars_pending(xmit) < WAKEUP_CHARS)
> +		uart_write_wakeup(port);
> +
> +	if (uart_circ_empty(xmit))
> +		wqtuart_stop_tx(port);
> +
> +	spin_unlock_irqrestore(&port->lock, flags);
> +}
> +
> +/*----------------------------------------------------------------------------*/
> +/* Interrupt Handlers                                                         */
> +/*----------------------------------------------------------------------------*/
> +
> +/* NOTE: All handlers are called with priv->irq_lock held */
> +
> +static void empty_handler(struct wqt_dev *priv)
> +{
> +	/* Intentionally left empty */
> +}
> +
> +static void net_start_req_handler(struct wqt_dev *priv)
> +{
> +	schedule_work(&priv->net_start_work);
> +}
> +
> +static void net_start_ack_handler(struct wqt_dev *priv)
> +{
> +	complete(&priv->net_start_completion);
> +}
> +
> +static void net_stop_req_handler(struct wqt_dev *priv)
> +{
> +	schedule_work(&priv->net_stop_work);
> +}
> +
> +static void net_stop_ack_handler(struct wqt_dev *priv)
> +{
> +	complete(&priv->net_stop_completion);
> +}
> +
> +static void net_tx_complete_handler(struct wqt_dev *priv)
> +{
> +	tasklet_schedule(&priv->tx_complete_tasklet);
> +}
> +
> +static void net_rx_packet_handler(struct wqt_dev *priv)
> +{
> +	wqtstatus_setbit(priv, PCINET_NET_RXINT_OFF);
> +	netif_rx_schedule(priv->ndev, &priv->napi);
> +}
> +
> +static void uart_rx_ready_handler(struct wqt_dev *priv)
> +{
> +	wqtuart_rx_char(&priv->port, IMMR_R32(IMR0_OFFSET) & 0xff);
> +	IMMR_W32(ODR_OFFSET, UART_TX_EMPTY_DBELL);
> +}
> +
> +static void uart_tx_empty_handler(struct wqt_dev *priv)
> +{
> +	priv->uart_tx_ready = true;
> +	wake_up(&priv->uart_tx_wait);
> +}
> +
> +/*----------------------------------------------------------------------------*/
> +/* Interrupt Request / Free Helpers                                           */
> +/*----------------------------------------------------------------------------*/
> +
> +static void do_enable_net_startstop_handlers(struct wqt_dev *priv)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +	priv->handlers.net_start_req_handler = net_start_req_handler;
> +	priv->handlers.net_start_ack_handler = net_start_ack_handler;
> +	priv->handlers.net_stop_req_handler = net_stop_req_handler;
> +	priv->handlers.net_stop_ack_handler = net_stop_ack_handler;
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +
> +	wqtstatus_setbit(priv, PCINET_NET_STATUS_RUNNING);
> +}
> +
> +static void do_disable_net_startstop_handlers(struct wqt_dev *priv)
> +{
> +	unsigned long flags;
> +
> +	wqtstatus_clrbit(priv, PCINET_NET_STATUS_RUNNING);
> +
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +	priv->handlers.net_start_req_handler = empty_handler;
> +	priv->handlers.net_start_ack_handler = empty_handler;
> +	priv->handlers.net_stop_req_handler = empty_handler;
> +	priv->handlers.net_stop_ack_handler = empty_handler;
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +}
> +
> +static void do_enable_net_rxtx_handlers(struct wqt_dev *priv)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +	priv->handlers.net_rx_packet_handler = net_rx_packet_handler;
> +	priv->handlers.net_tx_complete_handler = net_tx_complete_handler;
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +}
> +
> +static void do_disable_net_rxtx_handlers(struct wqt_dev *priv)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +	priv->handlers.net_rx_packet_handler = empty_handler;
> +	priv->handlers.net_tx_complete_handler = empty_handler;
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +}
> +
> +static void do_enable_uart_handlers(struct wqt_dev *priv)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +	priv->handlers.uart_rx_ready_handler = uart_rx_ready_handler;
> +	priv->handlers.uart_tx_empty_handler = uart_tx_empty_handler;
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +}
> +
> +static void do_disable_uart_handlers(struct wqt_dev *priv)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->irq_lock, flags);
> +	priv->handlers.uart_rx_ready_handler = empty_handler;
> +	priv->handlers.uart_tx_empty_handler = empty_handler;
> +	spin_unlock_irqrestore(&priv->irq_lock, flags);
> +}
> +
> +static int wqt_request_irq(struct wqt_dev *priv)
> +{
> +	int ret = 0;
> +
> +	mutex_lock(&priv->irq_mutex);
> +
> +	if (priv->interrupt_count > 0)
> +		goto out_unlock;
> +
> +	/* Force all handlers to be disabled before attaching the handler */
> +	do_disable_net_startstop_handlers(priv);
> +	do_disable_net_rxtx_handlers(priv);
> +	do_disable_uart_handlers(priv);
> +
> +	ret = request_irq(priv->irq,
> +			  wqt_interrupt,
> +			  IRQF_SHARED,
> +			  driver_name,
> +			  priv);

If you use device name (dev->name) ie ethX, then irqbalance knows this is
a network device and shouldn't move the irq around.

> +out_unlock:
> +	priv->interrupt_count++;
> +	mutex_unlock(&priv->irq_mutex);
> +
> +	return ret;
> +}
>


> +MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
> +MODULE_DESCRIPTION("PCINet/PCISerial Driver for MPC8349EMDS");
> +MODULE_LICENSE("GPL");
> +
> +module_init(wqt_init);
> +module_exit(wqt_exit);
> diff --git a/drivers/net/pcinet_host.c b/drivers/net/pcinet_host.c
> new file mode 100644
> index 0000000..dc36e0f
> --- /dev/null
> +++ b/drivers/net/pcinet_host.c
> @@ -0,0 +1,1392 @@
> +/*
> + * PCINet and PCISerial Driver for Freescale MPC8349EMDS (Host side)
> + *
> + * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * Heavily inspired by the drivers/net/fs_enet driver
> + *
> + * This file is licensed under the terms of the GNU General Public License
> + * version 2. This program is licensed "as is" without any warranty of any
> + * kind, whether express or implied.
> + */

> +static struct net_device_stats *wqt_get_stats(struct net_device *dev)
> +{
> +	return &dev->stats;
> +}

unnecessary, this is the default.


> diff --git a/drivers/net/pcinet_hw.h b/drivers/net/pcinet_hw.h
> new file mode 100644
> index 0000000..75703c7
> --- /dev/null
> +++ b/drivers/net/pcinet_hw.h
> @@ -0,0 +1,80 @@
> +/*
> + * Register offsets for the MPC8349EMDS Message Unit from the IMMR base address
> + *
> + * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * This file is licensed under the terms of the GNU General Public License
> + * version 2. This program is licensed "as is" without any warranty of any
> + * kind, whether express or implied.
> + */

> +/* vim: set ts=8 sts=8 sw=8 noet tw=92: */

NO magic editor config lines! 
