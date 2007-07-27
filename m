From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] Merge the Sonics Silicon Backplane subsystem
Date: Fri, 27 Jul 2007 21:30:48 +0200
Message-ID: <200707272130.48973.mb@bu3sch.de>
References: <200707271857.24162.mb@bu3sch.de> <20070727120318.54d18cfc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070727120318.54d18cfc.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 27 July 2007 21:03:18 Andrew Morton wrote:
> On Fri, 27 Jul 2007 18:57:20 +0200
> Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
> 
> > The Sonics Silicon Backplane is a mini-bus used on
> > various Broadcom chips and embedded devices.
> > Devices using the SSB include b44, bcm43xx and various
> > Broadcom based wireless routers.
> > A b44 and bcm43xx port and a SSB based OHCI driver is available.
> > 
> 
> hm, slim pickings for me here.  Nice looking code.
> 
> checkpatch finds a few coding style glitches.  Lots of 80-col violations
> which you might choose ignore (comments on #defines in headers are
> especially hard) but these guys:

I tried to fix most of the checkpatch warning, except these 80col
warnings.
I don't think it's worth the work to fix the 80col stuff, yet.
I develop kernel code in the real console, and I have no problems
with this. Though, I use a wider console than 80col.
Let's better fix the worst 80col violations over time and not now.

> ERROR: "foo * bar" should be "foo *bar"
> #4156: FILE: drivers/ssb/ssb_private.h:119:
> +extern struct ssb_bus * ssb_pci_dev_to_bus(struct pci_dev *pdev);
> 
> are worth addressing.

Well, I intentionally wrote that this way, as in my opinion
it it easier to read. I only use this additional space for
functions returning a pointer.

struct foo * function(int a, int b);

vs:

struct foo *function(int a, int b);

But I can change that, if that's really an issue and a
style violation.

> > ...
> >
> > --- /dev/null
> > +++ b/drivers/ssb/driver_pcicore.c
> > @@ -0,0 +1,564 @@
> >
> > ...
> >
> > +u32 pci_iobase = 0x100;
> > +u32 pci_membase = SSB_PCI_DMA;
> 
> These are quite poor names for global symbols.

Agreed. I will change this.

> > +static struct resource ssb_pcicore_mem_resource = {
> > +	.name	= "SSB PCIcore external memory",
> > +	.start	= SSB_PCI_DMA,
> > +	.end	= (u32)SSB_PCI_DMA + (u32)SSB_PCI_DMA_SZ - 1,
> > +	.flags	= IORESOURCE_MEM,
> > +};
> 
> start and end here are resource_size_t.  Forcing them to u32 seems
> inappropriate.

You're right. I'll fix that.

> > +void ssb_pcicore_init(struct ssb_pcicore *pc)
> 
> Please check that all newly-added global symbols do indeed need global scope.

ok.

> > +static void ssb_pcie_mdio_write(struct ssb_pcicore *pc, u8 device,
> > +				u8 address, u16 data)
> > +{
> > +	const u16 mdio_control = 0x128;
> > +	const u16 mdio_data = 0x12C;
> > +	u32 v;
> > +	int i;
> > +
> > +	v = 0x80; /* Enable Preamble Sequence */
> > +	v |= 0x2; /* MDIO Clock Divisor */
> > +	pcicore_write32(pc, mdio_control, v);
> > +
> > +	v = (1 << 30); /* Start of Transaction */
> > +	v |= (1 << 28); /* Write Transaction */
> > +	v |= (1 << 17); /* Turnaround */
> > +	v |= (u32)device << 22;
> > +	v |= (u32)address << 18;
> > +	v |= data;
> > +	pcicore_write32(pc, mdio_data, v);
> > +	udelay(10);
> 
> mystery udelays are usually worth a comment.

Sure.

> > +static void ssb_buses_lock(void)
> > +{
> > +	if (!ssb_is_early_boot)
> > +		mutex_lock(&buses_mutex);
> > +}
> > +
> > +static void ssb_buses_unlock(void)
> > +{
> > +	if (!ssb_is_early_boot)
> > +		mutex_unlock(&buses_mutex);
> > +}
> 
> Some comments are neeeded here to explain why we're jumping through this
> hoop.

I added a comment at the declaration of ssb_is_early_boot,
which tries to explain this in detail.

> It's normally OK to take a mutex early in boot, so one wonders 
> what's happening.

Hm, I tried that. There were problems. I don't remember this in detail, though.
This is called _really_ early in boot.

> > +EXPORT_SYMBOL(ssb_clockspeed);
> 
> Please check that all newly-added exports really need to be exported (I'm
> sure they do, but..)
> 
> > +static int ssb_wait_bit(struct ssb_device *dev, u16 reg, u32 bitmask,
> > +			int timeout, int set)
> > +{
> > +	int i;
> > +	u32 val;
> > +
> > +	for (i = 0; i < timeout; i++) {
> > +		val = ssb_read32(dev, reg);
> > +		if (set) {
> > +			if (val & bitmask)
> > +				return 0;
> > +		} else {
> > +			if (!(val & bitmask))
> > +				return 0;
> > +		}
> > +		udelay(10);
> > +	}
> > +	printk(KERN_ERR PFX "Timeout waiting for bitmask %08X on "
> > +			    "register %04X to %s.\n",
> > +	       bitmask, reg, (set ? "set" : "clear"));
> > +
> > +	return -ETIMEDOUT;
> > +}
> 
> So `timeout' is in units of ten-microseconds.  Unusual.
> 
> > +void ssb_device_disable(struct ssb_device *dev, u32 core_specific_flags)
> > +{
> > +	u32 reject;
> > +
> > +	if (ssb_read32(dev, SSB_TMSLOW) & SSB_TMSLOW_RESET)
> > +		return;
> > +
> > +	reject = ssb_tmslow_reject_bitmask(dev);
> > +	ssb_write32(dev, SSB_TMSLOW, reject | SSB_TMSLOW_CLOCK);
> > +	ssb_wait_bit(dev, SSB_TMSLOW, reject, 1000, 1);
> > +	ssb_wait_bit(dev, SSB_TMSHIGH, SSB_TMSHIGH_BUSY, 1000, 0);
> > +	ssb_write32(dev, SSB_TMSLOW,
> > +		    SSB_TMSLOW_FGC | SSB_TMSLOW_CLOCK |
> > +		    reject | SSB_TMSLOW_RESET |
> > +		    core_specific_flags);
> > +	/* flush */
> > +	ssb_read32(dev, SSB_TMSLOW);
> > +	udelay(1);
> > +
> > +	ssb_write32(dev, SSB_TMSLOW,
> > +		    reject | SSB_TMSLOW_RESET |
> > +		    core_specific_flags);
> > +	/* flush */
> > +	ssb_read32(dev, SSB_TMSLOW);
> > +	udelay(1);
> 
> mystery udelay.

Well, /* flush */ :)
It simply waits and makes really sure the device is done.
This is a really critical place and we must make 100% sure
or we risk running into a machine check exception.

> > +}
> > +EXPORT_SYMBOL(ssb_device_disable);
> >
> > ...
> >
> > +const struct ssb_bus_ops ssb_pci_ops = {
> > +	.read16		= ssb_pci_read16,
> > +	.read32		= ssb_pci_read32,
> > +	.write16	= ssb_pci_write16,
> > +	.write32	= ssb_pci_write32,
> > +};
> 
> static?

Yeah, think so. Good catch.

> > +static ssize_t ssb_pci_attr_sprom_show(struct device *pcidev,
> > +				       struct device_attribute *attr,
> > +				       char *buf)
> > +{
> > +	struct pci_dev *pdev = container_of(pcidev, struct pci_dev, dev);
> > +	struct ssb_bus *bus;
> > +	u16 *sprom;
> > +	int err = -ENODEV;
> > +	ssize_t count = 0;
> > +
> > +	bus = ssb_pci_dev_to_bus(pdev);
> > +	if (!bus)
> > +		goto out;
> > +	err = -ENOMEM;
> > +	sprom = kcalloc(SSB_SPROMSIZE_WORDS, sizeof(u16), GFP_KERNEL);
> > +	if (!sprom)
> > +		goto out;
> > +
> > +	err = -ERESTARTSYS;
> > +	if (mutex_lock_interruptible(&bus->pci_sprom_mutex))
> > +		goto out_kfree;
> > +	sprom_do_read(bus, sprom);
> > +	mutex_unlock(&bus->pci_sprom_mutex);
> > +
> > +	count = sprom2hex(sprom, buf, PAGE_SIZE);
> > +	err = 0;
> > +
> > +out_kfree:
> > +	kfree(sprom);
> > +out:
> > +	return err ? err : count;
> > +}
> 
> The mutex_lock_interruptible() looks fishy.  Some commented explanation of
> what it's doing would be good here.  It's quite unobvious to this reader. 
> Cheesy deadlock avoidance?  Hope not.

No, it's simply to avoid writing the SPROM concurrently.
SPROM writing is hairy and we must make sure here that
we are the only one accessing the whole bus. We do that
by suspending all devices and taking a lock to protect
the SPROM from write concurrency.

> > +
> > +/* These are the main device register access functions.
> > + * do_select_core is inline to have the likely hotpath inline.
> > + * All unlikely codepaths are out-of-line. */
> > +static inline int do_select_core(struct ssb_bus *bus,
> > +				 struct ssb_device *dev,
> > +				 u16 *offset)
> > +{
> > +	int err;
> > +	u8 need_seg = (*offset >= 0x800) ? 1 : 0;
> > +
> > +	if (unlikely(dev != bus->mapped_device)) {
> > +		err = ssb_pcmcia_switch_core(bus, dev);
> > +		if (unlikely(err))
> > +			return err;
> > +	}
> > +	if (unlikely(need_seg != bus->mapped_pcmcia_seg)) {
> > +		err = ssb_pcmcia_switch_segment(bus, need_seg);
> > +		if (unlikely(err))
> > +			return err;
> > +	}
> > +	if (need_seg == 1)
> > +		*offset -= 0x800;
> > +
> > +	return 0;
> > +}
> 
> Looks too large for inlining.

Well, as I already explained in a previous submission,
this is the hottest path in the SSB code. It's called with
every MMIO access. I intentionally did this inline to have
the likely path inline and all the unlikely paths out of
line. See the unlikely() branches, which are out of line.

> > +const struct ssb_bus_ops ssb_pcmcia_ops = {
> > +	.read16		= ssb_pcmcia_read16,
> > +	.read32		= ssb_pcmcia_read32,
> > +	.write16	= ssb_pcmcia_write16,
> > +	.write32	= ssb_pcmcia_write32,
> > +};
> 
> static?

Yep.


-- 
Greetings Michael.
