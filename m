From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Tue, 4 Nov 2008 13:09:25 +0100
Message-ID: <200811041309.25869.arnd@arndb.de>
References: <20081029202027.GH12879@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, Ira Snyder <iws@ovro.caltech.edu>
To: linuxppc-dev@ozlabs.org,
 Jan-Bernd Themann <THEMANN@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20081029202027.GH12879@ovro.caltech.edu>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wednesday 29 October 2008, Ira Snyder wrote:
> This adds support to Linux for a virtual ethernet interface which uses the
> PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> method of communication for two devices connected by a PCI interface.

Very interesting. I have seen multiple such drivers, and still plan to
have one as well for the cell/axon platform.

> This is the third posting of this driver. I got some feedback, and have
> corrected the problems. Stephen, thanks for the review! I also got some
> off-list feedback from a potential user, so I believe this is worth getting
> into mainline.

Sorry for not having replied earlier, I did not see first postings.
While I did not see any major problems with your code, I think we should
actually do it in a different way, which I have talked about at the
Linux plumbers conference, and will again at the UKUUG Linux conference
this weekend. You can find my slides from the previous talk at
http://userweb.kernel.org/%7Earnd/papers/plumbers08/plumbers-slides.pdf
 
Since you have code and I only have plans, I suppose I can't make you
wait for me to get a driver for your platform, but I hope we can join
forces in the future and share code in the future.

My fundamental criticism of your code is that it is not flexible enough.
We have a number of platforms that act as a PCI, PCIe or similar kind
of device and want to transfer network data. At the same time, some of
these want to use the same infrastructure for non-network data like
MPI (ibverbs), block device or file system (9p). Even in your limited
setup, it seems that you should be able to share more code between the
two implementations you have posted here. When looking at the code, I
found a lot of duplication between the drivers that you should be able
to avoid.

My suggestion is to base this on the virtio infrastructure, and some
of my colleagues at IBM already implemented a driver that uses
virtio-net on a PCIe connection.

	Arnd <><

Now a few comments on your code:


> diff --git a/arch/powerpc/boot/dts/mpc834x_mds.dts b/arch/powerpc/boot/dts/mpc834x_mds.dts
> index c986c54..3bc8975 100644
> --- a/arch/powerpc/boot/dts/mpc834x_mds.dts
> +++ b/arch/powerpc/boot/dts/mpc834x_mds.dts
> @@ -104,6 +104,13 @@
>  			mode = "cpu";
>  		};
>  
> +		message-unit@8030 {
> +			compatible = "fsl,mpc8349-mu";
> +			reg = <0x8030 0xd0>;
> +			interrupts = <69 0x8>;
> +			interrupt-parent = <&ipic>;
> +		};

What is a message unit? Is this the mailbox you use in the driver?
We are facing a similar problem on Axon regarding probing of
the virtual device because you can't easily tell from the device
tree whether the machine is connected to something that is trying
to communicate.

The message-unit does not seem to be network-specific, so it's not
particularly nice to have the network unit grab that of_device.

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

Why 'depends on !PCI'? This means that you cannot build a kernel that
is able to run both as host and endpoint for PCInet, right?

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

Is this meant to be portable across different hardware implementations?
If the driver can only work with PCINET_FSL on the other side, you
should probably mention that in the description.

> +config PCINET_DISABLE_CHECKSUM
> +	bool "Disable packet checksumming"
> +	depends on PCINET_FSL || PCINET_HOST
> +	default n
> +	help
> +	  Disable packet checksumming on packets received by the PCINet
> +	  driver. This gives a possible speed boost.

Why make this one optional? Is there ever a reason to enable checksumming?
If there is, how about making it tunable with ethtool?

> +struct circ_buf_desc {
> +	__le32 sc;
> +	__le32 len;
> +	__le32 addr;
> +} __attribute__((__packed__));

It would be useful to always force aligning the desciptors to the whole
32 bit and avoid the packing here. Unaligned accesses are inefficient on
many systems.

> +typedef struct circ_buf_desc cbd_t;

Also, don't pass structures by value if they don't fit into one or
two registers.

> +/* Buffer Descriptor Accessors */
> +#define CBDW_SC(_cbd, _sc) iowrite32((_sc), &(_cbd)->sc)
> +#define CBDW_LEN(_cbd, _len) iowrite32((_len), &(_cbd)->len)
> +#define CBDW_ADDR(_cbd, _addr) iowrite32((_addr), &(_cbd)->addr)
> +
> +#define CBDR_SC(_cbd) ioread32(&(_cbd)->sc)
> +#define CBDR_LEN(_cbd) ioread32(&(_cbd)->len)
> +#define CBDR_ADDR(_cbd) ioread32(&(_cbd)->addr)

We have found that accessing remote descriptors using mmio read is
rather slow, and changed the code to always do local reads and
remote writes.

On the host side, I would argue that you should use out_le32 rather
than iowrite32, because you are not operating on a PCI device but
an OF device.

> +/* IMMR Accessor Helpers */
> +#define IMMR_R32(_off) ioread32(priv->immr+(_off))
> +#define IMMR_W32(_off, _val) iowrite32((_val), priv->immr+(_off))
> +#define IMMR_R32BE(_off) ioread32be(priv->immr+(_off))
> +#define IMMR_W32BE(_off, _val) iowrite32be((_val), priv->immr+(_off))

IIRC, the IMMR is a platform resource, so the system should map those
registers already and provide accessor functions for the registers
you need. Simply allowing to pass an offset in here does not look
clean.


> +static void wqtuart_rx_char(struct uart_port *port, const char ch);
> +static void wqtuart_stop_tx(struct uart_port *port);

You should try to avoid forward declarations for static functions.
If you order the function implementation correctly, that will
also give you the expected reading order in the driver.

> +struct wqt_dev;
> +typedef void (*wqt_irqhandler_t)(struct wqt_dev *);

Much more importantly, never do forward declarations for
global functions!

These belong into a header that is included by both the
user and the definition.


> +struct wqt_dev {
> +	/*--------------------------------------------------------------------*/
> +	/* OpenFirmware Infrastructure                                        */
> +	/*--------------------------------------------------------------------*/
> +	struct of_device *op;
> +	struct device *dev;

Why the dev? You can always get that from the of_device, right?

> +	int irq;
> +	void __iomem *immr;

I don't think immr is device specific.

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

hmm, if you need a uart, that sounds like it should be a separate driver
altogether. What is the relation between the network interface and the UART?

> +	struct workqueue_struct *wq;

A per-device pointer to a workqueue_struct is unusual. What are you doing
this for? How about using the system work queue?

> +	/*--------------------------------------------------------------------*/
> +	/* Ethernet Device Infrastructure                                     */
> +	/*--------------------------------------------------------------------*/
> +	struct net_device *ndev;

Why make this a separate structure? If you have one of these per net_device,
you should embed the net_device into your own structure.

> +	struct tasklet_struct tx_complete_tasklet;

Using a tasklet for tx processing sounds fishy because most of the
network code already runs at softirq time. You do not gain anything
by another softirq context.

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

This looks misplaced, as mentioned before.

> +static int wqtstatus_remote_testbit(struct wqt_dev *priv, u32 bit)
> +{
> +	return IMMR_R32(IMR1_OFFSET) & bit;
> +}

Are you sure that do not need a spinlock here? The lock also
prevents reordering the device access arount the code using
the mmio data.

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

If this is in an interrupt handler, why disable the interrupts again?
The same comment applies to many of the other places where you
use spin_lock_irqsave rather than spin_lock or spin_lock_irq.

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

Since these all seem to be trivial functions, why go through the
indirect function pointers at all? It seems that wqt_interrupt
could do this just as well.

> +
> +static int wqt_request_irq(struct wqt_dev *priv)
> +{
> +	int ret = 0;

no point initializing ret.

> +	mutex_lock(&priv->irq_mutex);

What data does the irq_mutex protect?

	Arnd <><
