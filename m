From: David Fries <david@fries.net>
Subject: Re: [PATCH] ne.c fix for hibernate and rmmod oops fix
Date: Mon, 8 Sep 2008 21:54:34 -0500
Message-ID: <20080909025434.GB28469@spacedout.fries.net>
References: <20080904030212.GA23493@spacedout.fries.net> <7d1d9c250809050101v9ab3907l649781ee38a5a243@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	Paul Gortmaker <p_gortmaker@yahoo.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:57246 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbYIIC40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 22:56:26 -0400
Content-Disposition: inline
In-Reply-To: <7d1d9c250809050101v9ab3907l649781ee38a5a243@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two new patches will follow,
Notable changes since the last patch:

Register all four platform devices, previously I would stop at one
with a zero io port address, but if there were multiple ISA PnP
devices or autoprobed devices on bootup, it would not look for the
second.  This way it will look for up to MAX_NE_CARDS.

Removed BAD_STR.  The platform_device structure holds id, which is
this_dev which is the index into the io, irq, and bad arrays.
ne_drv_probe can find the 0xbad flag in the bad array directly, no
need to figure out a way to pass it through the resources.

Now that the io port and irq can be looked up in the arrays the probe
code doesn't even need the resources passed by the platform device.
The ne.c driver already registers the resources it needs and there
isn't any good way to update the resources when the io port or irq are
zero and probed at runtime.

The "This is set up so that no ISA autoprobe takes place." comment was
moved up to #define NEEDS_PORTLIST, it was above the init_module
function, but there isn't any logic related to autoprobing.

On Fri, Sep 05, 2008 at 04:01:16AM -0400, Paul Gortmaker wrote:
> On Wed, Sep 3, 2008 at 11:02 PM, David Fries <david@fries.net> wrote:
>
> Generally speaking, this is an old driver for hardware that most of
> us will never see again, so the concern is that any changes may
> break some existing configurations we can't easily test.  In light
> of that, the change footprint should be minimized and/or be
> bisectable wherever possible.
> 
> For example, if I'm reading it correctly, you've changed the module
> behaviour so that on module load an autoprobe takes place, where
> that was not the case before, because the probe is invasive.

Not that I'm aware of,

#if !defined(MODULE) && (defined(CONFIG_ISA) || defined(CONFIG_M32R))
/* Do we need a portlist for the ISA auto-probe ? */
#define NEEDS_PORTLIST
#endif

static int __init do_ne_probe(struct net_device *dev)
#ifdef NEEDS_PORTLIST
        /* Last resort. The semi-risky ISA auto-probe. */

testbeeper:~# modprobe ne
ne.c: You must supply "io=0xNNN" value(s) for ISA cards.  FATAL: Error inserting ne
(/lib/modules/2.6.27-rc3/kernel/drivers/net/ne.ko): No such device

Looks to have not autoprobed to me.

Previously init_module would read the module parameter for irq, io,
and bad and stop the first probe that failed.  I would expect it to
always probe with a zero port address.

> It looks like you've got several semi-independent fixes here, plus
> some shuffling of code blocks and a couple of needless white
> space changes which all add up to a pretty big patch to an old
> legacy driver.  I think it would be good if this was broken down
> a bit and had a reduced footprint.  It would also be good to know
> if you have tested both module and non-module (build and/or boot).

The final patch was tested in the following configurations,
qemu 32bit mode, fixed io & irq, modular and built in the kernel
i486 hardware, kernel ISA PnP, modular

I've tested built in the kernel on the i486 hardware as well, along
with other configurations, just probably not with the final
configuration.  Some of the others were multiple ne2000's in qemu,
user space ISA PnP with i486 etc.

Auto detecting the irq only works once per boot, remove the module and
insert it again and it fails.  I didn't change any of that code, and I
didn't need it to work, so I didn't look into it.

Note the user space ISA PnP doesn't work for suspend to disk, because
of another kernel bug.  Boot, run isapnp to init the board, insert
module, works fine, suspend to disk, power cycle, restore, isapnp
hasn't run, so the card doesn't work (as expected).  Run isapnp, only
it fails.  /proc/interrupts has the interrupt listed, even after rmmod
ne, so it can't initialize the board.  After rmmod ne, the interrupt
has an empty driver field.

It's not related to ISA PnP, boot, insert module, suspend, resume,
rmmod, /proc/interrupts lists an empty driver for that module.  The
irq isn't claimed, as the module can be inserted and claim the irq
again.  If suspend and resume are left out the irq isn't listed 
after rmmod.

> Additional comments inline.

> > Removing the module would cause a kernel oops as platform_driver_probe
> > failed to detect a device and unregistered the platform driver on
> > module init, and cleanup_module would unregister the already
> > unregistered driver.  The suspend and resume functions weren't being
> > called and the network card didn't function across a suspend to disk
> > followed by a power cycle.
> 
> The suspend/resume fix looks to be a candidate for a simple
> fix (i.e. separate patch) in its own right.
> 
> >
> > platform_driver support was added earlier, but without any
> > platform_device_register* calls I don't think it was being used.  Now
> > all devices are registered using platform_device_register_simple and
> > pointers are kept to unregister the ones that the probe failed for or
> > unregister all devices on module shutdown.  init_module no longer
> > calls ne_init to reduce confusion (and multiple unregister paths that
> > caused the rmmod oops).
> >
> > With the devices now registered they are added to the platform driver
> > and get suspend and resume events.  A call to pnp_stop_dev and
> > pnp_start_dev now shutsdown and initializes plug and play devices.
> >
> > netif_device_detach(dev) was added before unregister_netdev(dev) when
> > removing the region as occationally I would see a race condition where
> > the device was still being used in unregister_netdev.
> 
> This too sounds like it could be an independent fix on its own. I'd
> say do those 1st and then the platform patch won't be as big.

The suspend and resume fix is somewhat isolated.  I could see that
patch after the main platform patch, but it would just be dead code
that couldn't be testable if added before.  Same with
netif_device_deatch, only it would be modifying the same code, so it's
not going to help with size.

> > ---
> >  drivers/net/ne.c |  277 +++++++++++++++++++++++++++++++++--------------------
> >  1 files changed, 172 insertions(+), 105 deletions(-)
> >
> > diff --git a/drivers/net/ne.c b/drivers/net/ne.c
> > index 42443d6..7980cf0 100644
> > --- a/drivers/net/ne.c
> > +++ b/drivers/net/ne.c
> > @@ -64,6 +64,27 @@ static const char version2[] =
> >
> >  /* Do we support clones that don't adhere to 14,15 of the SAprom ? */
> >  #define SUPPORT_NE_BAD_CLONES
> > +/* 0xbad = bad sig or no reset ack */
> > +#define BAD 0xbad
> > +#define BAD_STR "0xbad"
> 
> I think your change puts the above as the human readable name in
> /proc/ioports when you have a bad clone.  As such it probably should
> be something like "ne2000(bad sig)" or similar, so it doesn't look
> like some resource management bug to an end user.

So it does.

0300-031f : 0xbad
  0300-031f : ne

vs

0300-031f : ne.0
  0300-031f : ne

Will be fixed, sigh, so much for (ab)using r[0].name.

> > +
> > +#define MAX_NE_CARDS   4       /* Max number of NE cards per module */
> > +static struct platform_device *pdev_ne[MAX_NE_CARDS];
> > +
> > +static int io[MAX_NE_CARDS];
> > +static int irq[MAX_NE_CARDS];
> > +static int bad[MAX_NE_CARDS];
> > +
> > +#ifdef MODULE
> > +module_param_array(io, int, NULL, 0);
> > +module_param_array(irq, int, NULL, 0);
> > +module_param_array(bad, int, NULL, 0);
> > +MODULE_PARM_DESC(io, "I/O base address(es),required");
> > +MODULE_PARM_DESC(irq, "IRQ number(s)");
> > +MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
> > +MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
> > +MODULE_LICENSE("GPL");
> > +#endif /* MODULE */
> 
> The relocation of all this makes it harder to read through the patch and
> see what the significant changes are.  Is it necessary?

It was previously before init_module, but now the first use of pdev_ne
is ne_loop_rm_unreg which is earlier.  ne_loop_rm_unreg could have
been moved above init_module, but then it wouldn'tbe logically be
grouped with the other ne_drv_remove function, and ne_drv_remove can't
be moved down as struct platform_driver uses it.  If you're going to
move it up, might as well move it up to the more logical top.

> >  /* Do we perform extra sanity checks on stuff ? */
> >  /* #define NE_SANITY_CHECK */
> > @@ -162,7 +183,6 @@ static void ne_block_input(struct net_device *dev, int count,
> >  static void ne_block_output(struct net_device *dev, const int count,
> >                const unsigned char *buf, const int start_page);
> >
> > -
> >  /*  Probe for various non-shared-memory ethercards.
> >
> 
> Gratuitous whitespace change.

Fixed,

> > @@ -472,7 +475,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
> >                outb_p(0x00, ioaddr + EN0_RCNTLO);
> >                outb_p(0x00, ioaddr + EN0_RCNTHI);
> >                outb_p(E8390_RREAD+E8390_START, ioaddr); /* Trigger it... */
> > -               mdelay(10);             /* wait 10ms for interrupt to propagate */
> > +               mdelay(10);     /* wait 10ms for interrupt to propagate */
> 
> Gratuitous whitespace change.

Andrew Morton says to use checkpatch, at one point it failed so I
fixed it, reverted.

> > -static int __exit ne_drv_remove(struct platform_device *pdev)
> > +static int ne_drv_remove(struct platform_device *pdev)
> 
> I guess the above is because of your addition of ne_loop_rm?
> If someone is unfortunate enough to be using an ISA ne2000, then
> they might care about saving on driver size while built-in...

ne_loop_rm_unreg yes calls ne_drv_remove which is also called at
initialization to remove the platform drivers that failed to probe.
Unless people prefer to leave those devices around.

-- 
David Fries <david@fries.net>
http://fries.net/~david/ (PGP encryption key available)
