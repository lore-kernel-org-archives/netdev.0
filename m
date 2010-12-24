From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Fri, 24 Dec 2010 10:14:31 +0100
Message-ID: <20101224091428.GA375@e-circ.dyndns.org>
References: <20101223093627.GA325@e-circ.dyndns.org>
	<20101223094302.GB325@e-circ.dyndns.org>
	<4D135BC3.6070707@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D135BC3.6070707-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Marc,

A lot of your remarks do make sense, without further comment.
Some however, I'm not completely sure ...


On Thu, Dec 23, 2010 at 03:25:07PM +0100, Marc Kleine-Budde wrote:
> >  
> >  obj-y				+= usb/
> > +obj-y				+= softing/
> 
> I think it will (at least marginally) speed up the Kernel build process
> only to dive into the softing subdir if Softing is enabled in Kconfig.

Due to the independant driver design, I should
(CONFIG_CAN_SOFTING || CONFIG_CAN_SOFTINGCS)
> 
> > +	ktime_t ts_ref;
> > +	ktime_t ts_overflow; /* timestamp overflow value, in ktime */
> > +
> > +	struct {
> > +		/* indication of firmware status */
> > +		int up;
> > +		/* protection of the 'up' variable */
> > +		struct mutex lock;
> > +	} fw;
> 
> what about using an atomic_t for the firmware status?
for 'up', yes, but the lock stays. It protects the startup/shutdown
sequence too, ie. only 1 process enters the shutdown sequence.
> 
> > +/* SOFTING DPRAM mappings */
> > +struct softing_rx {
> > +	u8  fifo[16][32];
> > +	u8  dummy1;
> 
> Just curious, why did they put a padding byte here, that makes the rest
> unaligned?
I did not design the DPRAM layout. It's just the way it is ...
I did prefer to use structs in virtual memory, and this is the consequence.
> 
> > +	u32 time;
> > +	u32 time_wrap;
> > +	u8  wr_start;
> > +	u8  wr_end;
> > +	u8  dummy10;
> > +	u16 dummy12;
> > +	u16 dummy12x;
> > +	u16 dummy13;
> > +	u16 reset_rcv_fifo;
> > +	u8  dummy14;
> > +	u8  reset_xmt_fifo;
> > +	u8  read_fifo_levels;
> > +	u16 rcv_fifo_level;
> > +	u16 xmt_fifo_level;
> > +} __attribute__((packed));
> 
> Can you renumber the dummy variables (there are some "x" in there), or
> does it correspond to some datasheet?
no, there's no datasheet. I started from code released by Softing.
> 
> > +
> > diff --git a/drivers/net/can/softing/softing_fw.c b/drivers/net/can/softing/softing_fw.c
> > +
[...]
> > +int softing_fct_cmd(struct softing *card, int cmd, int vector, const char *msg)
> > +{
> > +	int ret;
> > +	unsigned long stamp;
> > +	if (vector == RES_OK)
> > +		vector = RES_NONE;
> > +	card->dpram.fct->param[0] = cmd;
> 
> param[] is an array of s16 and cmd is an int.
Is this a problem? Is it usefull to define the function with s16 arguments then?
> 
> hmmm..all stuff behind dpram is __iomem, isn't it? I think it should
> only be accessed with via the ioread/iowrite operators. Please check
I did an ioremap_nocache. Since it is unaligned, ioread/iowrite would render
a lot of statements.
> your code with sparse (compile with "make C=2").
(?) 
> 
> > +		}
> > +		if ((jiffies - stamp) >= 1 * HZ)
> 
> That's not good. I don't remember the name, but there are some
> functions/defines to do this kind of things properly.
I'll do a search
> 
> > +			break;
> > +		if (in_interrupt())
> > +			/* go as fast as possible */
> 
> In the worst case this means you lock up the system for one second. Does
> the card issue an interrupt if it's finished? Another option is to write
> a threaded interrupt handler.
Yep, threaded interrupt handler is something to look at ... later.
> 
> 
> > +{
> > +	int ret;
> > +	unsigned long stamp;
> > +	card->dpram.receipt[0] = RES_NONE;
> > +	card->dpram.command[0] = command;
> > +	/* be sure to flush this to the card */
> > +	wmb();
> > +	stamp = jiffies;
> > +	/*wait for card */
> > +	do {
> > +		ret = card->dpram.receipt[0];
> > +		/* don't have any cached variables */
> > +		rmb();
> > +		if (ret == RES_OK)
> > +			return 0;
> > +		if ((jiffies - stamp) >= (3 * HZ))
> > +			break;
> > +		schedule();
> 
> same applies here, too. Although this command seems not to be called
> from interrupt context, what about using a msleep() instead of a schedule?
Not calling schedule was really annoying.
> 

Thanks for your review,

Kurt
