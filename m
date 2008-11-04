From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Tue, 4 Nov 2008 09:34:14 -0800
Message-ID: <20081104173414.GB4641@ovro.caltech.edu>
References: <20081029202027.GH12879@ovro.caltech.edu> <200811041309.25869.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756925AbYKDRed@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200811041309.25869.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2008 at 01:09:25PM +0100, Arnd Bergmann wrote:
> On Wednesday 29 October 2008, Ira Snyder wrote:
> > This adds support to Linux for a virtual ethernet interface which uses the
> > PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> > method of communication for two devices connected by a PCI interface.
> 
> Very interesting. I have seen multiple such drivers, and still plan to
> have one as well for the cell/axon platform.
> 
> > This is the third posting of this driver. I got some feedback, and have
> > corrected the problems. Stephen, thanks for the review! I also got some
> > off-list feedback from a potential user, so I believe this is worth getting
> > into mainline.
> 
> Sorry for not having replied earlier, I did not see first postings.
> While I did not see any major problems with your code, I think we should
> actually do it in a different way, which I have talked about at the
> Linux plumbers conference, and will again at the UKUUG Linux conference
> this weekend. You can find my slides from the previous talk at
> http://userweb.kernel.org/%7Earnd/papers/plumbers08/plumbers-slides.pdf
>  

I'll read through these slides as soon as I'm finished replying to this
email :)

> Since you have code and I only have plans, I suppose I can't make you
> wait for me to get a driver for your platform, but I hope we can join
> forces in the future and share code in the future.
> 

I hope so too. I wrote this because I needed something working. I'm
completely happy to help write code for another implementation.

> My fundamental criticism of your code is that it is not flexible enough.
> We have a number of platforms that act as a PCI, PCIe or similar kind
> of device and want to transfer network data. At the same time, some of
> these want to use the same infrastructure for non-network data like
> MPI (ibverbs), block device or file system (9p). Even in your limited
> setup, it seems that you should be able to share more code between the
> two implementations you have posted here. When looking at the code, I
> found a lot of duplication between the drivers that you should be able
> to avoid.
> 

I completely agree. I made the host and client drivers as similar as
possible on purpose, to increase my own code sharing. In fact, if you
diff them, you'll see that they are almost identical.

I decided that it would be better to post them up for review than try to
fix every little problem.

> My suggestion is to base this on the virtio infrastructure, and some
> of my colleagues at IBM already implemented a driver that uses
> virtio-net on a PCIe connection.
> 

To be honest, I couldn't get that figured out. I looked at that code for
a couple of weeks and couldn't make a lot of sense out of it. I couldn't
find much really good documentation, either. I'd love to re-use more
code than I have.

> 	Arnd <><
> 
> Now a few comments on your code:
> 
> 
> > diff --git a/arch/powerpc/boot/dts/mpc834x_mds.dts b/arch/powerpc/boot/dts/mpc834x_mds.dts
> > index c986c54..3bc8975 100644
> > --- a/arch/powerpc/boot/dts/mpc834x_mds.dts
> > +++ b/arch/powerpc/boot/dts/mpc834x_mds.dts
> > @@ -104,6 +104,13 @@
> >  			mode = "cpu";
> >  		};
> >  
> > +		message-unit@8030 {
> > +			compatible = "fsl,mpc8349-mu";
> > +			reg = <0x8030 0xd0>;
> > +			interrupts = <69 0x8>;
> > +			interrupt-parent = <&ipic>;
> > +		};
> 
> What is a message unit? Is this the mailbox you use in the driver?
> We are facing a similar problem on Axon regarding probing of
> the virtual device because you can't easily tell from the device
> tree whether the machine is connected to something that is trying
> to communicate.
> 
> The message-unit does not seem to be network-specific, so it's not
> particularly nice to have the network unit grab that of_device.
> 

Yes, the message unit is how the Freescale reference manual describes
this hardware. It is the mailbox hardware to generate interrupts, plus a
few registers to transfer data.

The registers aren't network specific, but they are needed for this
driver. That is how the driver generates PCI interrupts to notify the
other side of the connection it has new data, etc.

> > +config PCINET_FSL
> > +	tristate "PCINet Virtual Ethernet over PCI support (Freescale)"
> > +	depends on MPC834x_MDS && !PCI
> > +	select DMA_ENGINE
> > +	select FSL_DMA
> > +	help
> > +	  When running as a PCI Agent, this driver will create a virtual
> > +	  ethernet link running over the PCI bus, allowing simplified
> > +	  communication with the host system. The host system will need
> > +	  to use the corresponding driver.
> > +
> > +	  If in doubt, say N.
> 
> Why 'depends on !PCI'? This means that you cannot build a kernel that
> is able to run both as host and endpoint for PCInet, right?
> 

Yes, that is correct. I did this because the Linux PCI code does some
relatively nasty things in agent mode. One thing that consistently
crashed my box was running through the quirks list and trying to
re-initialize an e100 that was in my box.

Remember, this is a PCI agent. It shouldn't be re-initializing the other
hardware on the PCI bus.

> > +config PCINET_HOST
> > +	tristate "PCINet Virtual Ethernet over PCI support (Host)"
> > +	depends on PCI
> > +	help
> > +	  This driver will let you communicate with a PCINet client device
> > +	  using a virtual ethernet link running over the PCI bus. This
> > +	  allows simplified communication with the client system.
> > +
> > +	  This is inteded for use in a system that has a crate full of
> > +	  computers running Linux, all connected by a PCI backplane.
> > +
> > +	  If in doubt, say N.
> 
> Is this meant to be portable across different hardware implementations?
> If the driver can only work with PCINET_FSL on the other side, you
> should probably mention that in the description.
> 

I had hoped other people would come along and help port it to other
hardware, like you yourself are suggesting. :) I'll add to the
description.

> > +config PCINET_DISABLE_CHECKSUM
> > +	bool "Disable packet checksumming"
> > +	depends on PCINET_FSL || PCINET_HOST
> > +	default n
> > +	help
> > +	  Disable packet checksumming on packets received by the PCINet
> > +	  driver. This gives a possible speed boost.
> 
> Why make this one optional? Is there ever a reason to enable checksumming?
> If there is, how about making it tunable with ethtool?
> 

I left it optional so I could turn it on and off easily. I have no
strong feelings on keeping it optional.

Does the PCI bus reliably transfer data? I'm not sure. I left it there
so that we could at least turn on checksumming if there was a problem.

> > +struct circ_buf_desc {
> > +	__le32 sc;
> > +	__le32 len;
> > +	__le32 addr;
> > +} __attribute__((__packed__));
> 
> It would be useful to always force aligning the desciptors to the whole
> 32 bit and avoid the packing here. Unaligned accesses are inefficient on
> many systems.
> 

I don't really know how to do that. I got a warning here from sparse
telling me something about expensive pointer subtraction. Adding a dummy
32bit padding variable got rid of the warning, but I didn't change the
driver.

> > +typedef struct circ_buf_desc cbd_t;
> 
> Also, don't pass structures by value if they don't fit into one or
> two registers.
> 

These are only used for pointers to the buffer descriptors (in RAM on
the Freescale) that hold packet information. I never copy them directly.

> > +/* Buffer Descriptor Accessors */
> > +#define CBDW_SC(_cbd, _sc) iowrite32((_sc), &(_cbd)->sc)
> > +#define CBDW_LEN(_cbd, _len) iowrite32((_len), &(_cbd)->len)
> > +#define CBDW_ADDR(_cbd, _addr) iowrite32((_addr), &(_cbd)->addr)
> > +
> > +#define CBDR_SC(_cbd) ioread32(&(_cbd)->sc)
> > +#define CBDR_LEN(_cbd) ioread32(&(_cbd)->len)
> > +#define CBDR_ADDR(_cbd) ioread32(&(_cbd)->addr)
> 
> We have found that accessing remote descriptors using mmio read is
> rather slow, and changed the code to always do local reads and
> remote writes.
> 

Interesting. I don't know how you would get network speed doing this.
X86 systems don't have a DMA conttroller. The entire purpose of making
the Freescale do all the copying was to use its DMA controller.

Using the DMA controller to transfer all of the data took my transfer
speed from ~3MB/sec to ~45MB/sec. While that is a good increase, it
could be better. I should be able to hit close to 133MB/sec (the limit
of PCI)

> On the host side, I would argue that you should use out_le32 rather
> than iowrite32, because you are not operating on a PCI device but
> an OF device.
> 

Yeah, you're probably correct. I can't remember if I tried this and had
problems or not.

> > +/* IMMR Accessor Helpers */
> > +#define IMMR_R32(_off) ioread32(priv->immr+(_off))
> > +#define IMMR_W32(_off, _val) iowrite32((_val), priv->immr+(_off))
> > +#define IMMR_R32BE(_off) ioread32be(priv->immr+(_off))
> > +#define IMMR_W32BE(_off, _val) iowrite32be((_val), priv->immr+(_off))
> 
> IIRC, the IMMR is a platform resource, so the system should map those
> registers already and provide accessor functions for the registers
> you need. Simply allowing to pass an offset in here does not look
> clean.
> 
> 

Correct. This was done to make both sides as identical as possible. The
Freescale exports the entire 1MB block of IMMR registers at PCI BAR0. So
I have to use the offsets on the host side.

>From the client side, I could just map what I need, but that would make
the two drivers diverge. I was trying to keep them the same.

> > +static void wqtuart_rx_char(struct uart_port *port, const char ch);
> > +static void wqtuart_stop_tx(struct uart_port *port);
> 
> You should try to avoid forward declarations for static functions.
> If you order the function implementation correctly, that will
> also give you the expected reading order in the driver.
> 

Yep, I tried to do this. I couldn't figure out a sane ordering that
would work. I tried to keep the network and uart as seperate as possible
in the code.

> > +struct wqt_dev;
> > +typedef void (*wqt_irqhandler_t)(struct wqt_dev *);
> 
> Much more importantly, never do forward declarations for
> global functions!
> 
> These belong into a header that is included by both the
> user and the definition.
> 
> 

Ok.

> > +struct wqt_dev {
> > +	/*--------------------------------------------------------------------*/
> > +	/* OpenFirmware Infrastructure                                        */
> > +	/*--------------------------------------------------------------------*/
> > +	struct of_device *op;
> > +	struct device *dev;
> 
> Why the dev? You can always get that from the of_device, right?
> 

Yes. I stored it there to make it identical to the host driver. By doing
this, both drivers have code that says "dev_debug(priv->dev, ...)"
rather than:

Host:
dev_debug(&priv->pdev->dev, ...)

Freescale:
dev_debug(&priv->op->dev, ...)

> > +	int irq;
> > +	void __iomem *immr;
> 
> I don't think immr is device specific.
> 

Correct, it is not. Both the PCI subsystem and the OF subsystem will
call probe() when a new device is detected. I stored it here so I could
ioremap() them at probe() time, and to keep both drivers' code the same.

> > +	struct mutex irq_mutex;
> > +	int interrupt_count;
> > +
> > +	spinlock_t irq_lock;
> > +	struct wqt_irqhandlers handlers;
> > +
> > +	/*--------------------------------------------------------------------*/
> > +	/* UART Device Infrastructure                                         */
> > +	/*--------------------------------------------------------------------*/
> > +	struct uart_port port;
> > +	bool uart_rx_enabled;
> > +	bool uart_open;
> 
> hmm, if you need a uart, that sounds like it should be a separate driver
> altogether. What is the relation between the network interface and the UART?
> 

Yes, I agree. How do you make two Linux drivers that can be loaded for
the same hardware at the same time? :) AFAIK, you cannot.

I NEED two functions accessible at the same time, network (to transfer
data) and uart (to control my bootloader).

I use the uart to interact with the bootloader (U-Boot) and tell it
where to tftp a kernel. I use the network to transfer the kernel.

So you see, I really do need them both at the same time. If you know a
better way to do this, please let me know!

It was possible to write seperate U-Boot drivers, but only by being
careful to not conflict in my usage of the hardware.

> > +	struct workqueue_struct *wq;
> 
> A per-device pointer to a workqueue_struct is unusual. What are you doing
> this for? How about using the system work queue?
> 

Look through the code carefully, especially at uart_tx_work_fn(), which
calls do_send_message().

do_send_message() can sleep for a long time. If I use the shared
workqueue, I block ALL OTHER USERS of the queue for the time I am
asleep. They cannot run.

The LDD3 book says not to use the shared workqueue if you are going to
sleep for long periods. I followed their advice.

> > +	/*--------------------------------------------------------------------*/
> > +	/* Ethernet Device Infrastructure                                     */
> > +	/*--------------------------------------------------------------------*/
> > +	struct net_device *ndev;
> 
> Why make this a separate structure? If you have one of these per net_device,
> you should embed the net_device into your own structure.
> 

This structure is embedded in struct net_device! Look at how
alloc_etherdev() works. You pass it the size of your private data
structure and it allocates the space for you.

> > +	struct tasklet_struct tx_complete_tasklet;
> 
> Using a tasklet for tx processing sounds fishy because most of the
> network code already runs at softirq time. You do not gain anything
> by another softirq context.
> 

I didn't want to run the TX cleanup routine at hard irq time, because it
can potentially take some time to run. I would rather run it with hard
interrupts enabled.

This DOES NOT do TX processing, it only frees skbs that have been
transferred. I used the network stack to do as much as possible, of
course.

> > +/*----------------------------------------------------------------------------*/
> > +/* Status Register Helper Operations                                          */
> > +/*----------------------------------------------------------------------------*/
> > +
> > +static DEFINE_SPINLOCK(status_lock);
> > +
> > +static void wqtstatus_setbit(struct wqt_dev *priv, u32 bit)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&status_lock, flags);
> > +	IMMR_W32(OMR1_OFFSET, IMMR_R32(OMR1_OFFSET) | bit);
> > +	spin_unlock_irqrestore(&status_lock, flags);
> > +}
> > +
> > +static void wqtstatus_clrbit(struct wqt_dev *priv, u32 bit)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&status_lock, flags);
> > +	IMMR_W32(OMR1_OFFSET, IMMR_R32(OMR1_OFFSET) & ~bit);
> > +	spin_unlock_irqrestore(&status_lock, flags);
> > +}
> 
> This looks misplaced, as mentioned before.
> 

I used these so I could have some remote status. Remember, this has to
work for Linux -> U-Boot, not just Linux <-> Linux.

While the board is booting Linux, the RAM I used to hold buffer
descriptors disappears! I need some shared status to make sure no stray
accesses happen to random areas of memory.

The case this potentially happens is:
1) Start Freescale board, do NOT install the driver
2) Insert the driver into the host system

Now, if the host tries writing to the buffer descriptors, we've
corrupted memory on the Freescale board.

> > +static int wqtstatus_remote_testbit(struct wqt_dev *priv, u32 bit)
> > +{
> > +	return IMMR_R32(IMR1_OFFSET) & bit;
> > +}
> 
> Are you sure that do not need a spinlock here? The lock also
> prevents reordering the device access arount the code using
> the mmio data.
> 

I don't think so. Note that this is a status bit on the remote side of
the connection. My access ordering means nothing when the remote side is
setting and clearing the bit.

> > +/*----------------------------------------------------------------------------*/
> > +/* Message Sending and Processing Operations                                  */
> > +/*----------------------------------------------------------------------------*/
> > +
> > +static irqreturn_t wqt_interrupt(int irq, void *dev_id)
> > +{
> > +	struct wqt_dev *priv = dev_id;
> > +	u32 imisr, idr;
> > +	unsigned long flags;
> > +
> > +	imisr = IMMR_R32(IMISR_OFFSET);
> > +	idr = IMMR_R32(IDR_OFFSET);
> > +
> > +	if (!(imisr & 0x8))
> > +		return IRQ_NONE;
> > +
> > +	/* Clear all of the interrupt sources, we'll handle them next */
> > +	IMMR_W32(IDR_OFFSET, idr);
> > +
> > +	/* Lock over all of the handlers, so they cannot get called when
> > +	 * the code doesn't expect them to be called */
> > +	spin_lock_irqsave(&priv->irq_lock, flags);
> 
> If this is in an interrupt handler, why disable the interrupts again?
> The same comment applies to many of the other places where you
> use spin_lock_irqsave rather than spin_lock or spin_lock_irq.
> 

I tried to make the locking do only what was needed. I just couldn't get
it correct unless I used spin_lock_irqsave(). I was able to get the
system to deadlock otherwise. This is why I posted the driver for
review, I could use some help here.

It isn't critical anyway. You can always use spin_lock_irqsave(), it is
just a little slower, but it will always work :)

> > +/* NOTE: All handlers are called with priv->irq_lock held */
> > +
> > +static void empty_handler(struct wqt_dev *priv)
> > +{
> > +	/* Intentionally left empty */
> > +}
> > +
> > +static void net_start_req_handler(struct wqt_dev *priv)
> > +{
> > +	schedule_work(&priv->net_start_work);
> > +}
> > +
> > +static void net_start_ack_handler(struct wqt_dev *priv)
> > +{
> > +	complete(&priv->net_start_completion);
> > +}
> > +
> > +static void net_stop_req_handler(struct wqt_dev *priv)
> > +{
> > +	schedule_work(&priv->net_stop_work);
> > +}
> > +
> > +static void net_stop_ack_handler(struct wqt_dev *priv)
> > +{
> > +	complete(&priv->net_stop_completion);
> > +}
> > +
> > +static void net_tx_complete_handler(struct wqt_dev *priv)
> > +{
> > +	tasklet_schedule(&priv->tx_complete_tasklet);
> > +}
> > +
> > +static void net_rx_packet_handler(struct wqt_dev *priv)
> > +{
> > +	wqtstatus_setbit(priv, PCINET_NET_RXINT_OFF);
> > +	netif_rx_schedule(priv->ndev, &priv->napi);
> > +}
> > +
> > +static void uart_rx_ready_handler(struct wqt_dev *priv)
> > +{
> > +	wqtuart_rx_char(&priv->port, IMMR_R32(IMR0_OFFSET) & 0xff);
> > +	IMMR_W32(ODR_OFFSET, UART_TX_EMPTY_DBELL);
> > +}
> > +
> > +static void uart_tx_empty_handler(struct wqt_dev *priv)
> > +{
> > +	priv->uart_tx_ready = true;
> > +	wake_up(&priv->uart_tx_wait);
> > +}
> 
> Since these all seem to be trivial functions, why go through the
> indirect function pointers at all? It seems that wqt_interrupt
> could do this just as well.
> 

I did this so they can be disabled independently. It is VERY tricky to
get the board started without the chance of corrupting memory. Write the
code, you'll see :)

You have to deal with two systems that can read/write each other's
memory, but DO NOT have any synchronization primitives.

> > +
> > +static int wqt_request_irq(struct wqt_dev *priv)
> > +{
> > +	int ret = 0;
> 
> no point initializing ret.
> 
> > +	mutex_lock(&priv->irq_mutex);
> 
> What data does the irq_mutex protect?
> 

priv->interrupt_count and the indirect handlers.

Note that I have two fundamentally seperate devices here. The network
and the uart.

What if noone has brought up the network interface? You'd still expect
the uart to work, right? In this case, I need to call request_irq() in
TWO places, the network's open() and the uart's open().

There is only a single interrupt for this hardware. When only the uart
is open, I only want the uart section of the irq handler enabled. This
is where the indirect handlers come in. On uart open(), I call
wqt_request_irq(), which will ONLY call request_irq() if it HAS NOT been
called yet.

Here are a few examples:
Ex1: uart only
1) uart open() is called
2) wqt_request_irq() is called
3) the uart irq handling functions are enabled
4) request_irq() is called, hooking up the irq
5) the uart is started

The network by itself works exactly the same.

Ex2: uart first, then network while uart is open
1) uart open() is called
2) wqt_request_irq() is called
3) the uart irq handling functions are enabled
4) request_irq() is called, hooking up the irq handler
5) the uart is started
6) time passes
7) network open() is called
8) wqt_request_irq() is called
9) request_irq() is NOT CALLED THIS TIME, because it is already enabled
10) the network irq handling functions are enabled
11) the network is started



Thanks so much for the review! I hope we can work together to get
something that can be merged into mainline Linux. I'm willing to write
code, I just need some direction from more experienced kernel
developers.

Ira
