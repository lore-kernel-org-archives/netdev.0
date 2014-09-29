From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe
	support
Date: Mon, 29 Sep 2014 23:22:08 +0200
Message-ID: <20140929212208.GV17349@wotan.suse.de>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com> <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com> <20140928150329.GC5023@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	dmitry.torokhov@gmail.com, tiwai@suse.de, arjan@linux.intel.com,
	teg@jklm.no, rmilasan@suse.com, werner@suse.com, oleg@redhat.com,
	hare@suse.com, bpoirier@suse.de, santosh@chelsio.com,
	pmladek@suse.cz, dbueso@suse.com, linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <har
To: Tejun Heo <tj@kernel.org>, gregkh@linuxfoundation.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140928150329.GC5023@mtj.dyndns.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 28, 2014 at 11:03:29AM -0400, Tejun Heo wrote:
> Hello,
> 
> On Fri, Sep 26, 2014 at 02:57:17PM -0700, Luis R. Rodriguez wrote:
> ...
> > Systemd should consider enabling async probe on device drivers
> > it loads through systemd-udev but probably does not want to
> > enable it for modules loaded through systemd-modules-load
> > (modules-load.d). At least on my booting enablign async probe
> > for all modules fails to boot as such in order to make this
> 
> Did you find out why boot failed with those modules?

No, it seems this was early in boot and I haven't been able to capture the logs
yet of the faults. More on this below.

> > a bit more useful we whitelist a few buses where it should be
> > at least in theory safe to try to enable async probe. This
> > way even if systemd tried to ask to enable async probe for all
> > its device drivers the kernel won't blindly do this. We also
> > have the sync_probe flag which device drivers can themselves
> > enable *iff* its known the device driver should never async
> > probe.
> > 
> > In order to help *test* things folks can use the bus.safe_mod_async_probe=1
> > kernel parameter which will work as if userspace would have
> > requested all modules to load with async probe. Daring folks can
> > also use bus.force_mod_async_probe=1 which will enable asynch probe
> > even on buses not tested in any way yet, if you use that though
> > you're on your own.
> 
> If those two knobs are meant for debugging, let's please make that
> fact immediately evident.  e.g. Make them ugly boot params like
> "__DEVEL__driver_force_mod_async_probe".  Devel/debug options ending
> up becoming stable interface are really nasty.

Sure make sense, I wasn't quite sure how to make this quite clear,
a naming convention seems good to me but I also had added at least
a print about this on the log. Ideally I think a TAIN_DEBUG would
be best and it seems it could be useful for many other cases in
the kernel, we could also just re-use TAINT_CRAP as well. Thoughts?
Greg?

> > +struct driver_attach_work {
> > +	struct work_struct work;
> > +	struct device_driver *driver;
> > +};
> > +
> >  struct driver_private {
> >  	struct kobject kobj;
> >  	struct klist klist_devices;
> >  	struct klist_node knode_bus;
> >  	struct module_kobject *mkobj;
> > +	struct driver_attach_work *attach_work;
> >  	struct device_driver *driver;
> >  };
> 
> How many bytes are we saving by allocating it separately?

This saves us 24 bytes per device driver.

>  Can't we just embed it in driver_private?

We sure can and it is my preference to do that as well but just
in case I wanted to take the alternative space saving approach
as well and let folks decide. There's also the technical aspect
of hiding that data structure from drivers, and that may be worth
to do but I personally also prefer the simplicity of stuffing
it on the public data structure, as you noted below we could then also
unconditionally flush_work() on __device_release_driver().

Greg, any preference?

> > +static void driver_attach_workfn(struct work_struct *work)
> > +{
> > +	int ret;
> > +	struct driver_attach_work *attach_work =
> > +		container_of(work, struct driver_attach_work, work);
> > +	struct device_driver *drv = attach_work->driver;
> > +	ktime_t calltime, delta, rettime;
> > +	unsigned long long duration;
> 
> This could just be a personal preference but I think it's easier to
> read if local vars w/ initializers come before the ones w/o.

We gotta standardize on *something*, I tend to declare them
in the order in which they are used, in this case I failed to
list calltime first, but yeah I'll put initialized first, I
don't care much.

> > +
> > +	calltime = ktime_get();
> > +
> > +	ret = driver_attach(drv);
> > +	if (ret != 0) {
> > +		remove_driver_private(drv);
> > +		bus_put(drv->bus);
> > +	}
> > +
> > +	rettime = ktime_get();
> > +	delta = ktime_sub(rettime, calltime);
> > +	duration = (unsigned long long) ktime_to_ns(delta) >> 10;
> > +
> > +	pr_debug("bus: '%s': add driver %s attach completed after %lld usecs\n",
> > +		 drv->bus->name, drv->name, duration);
> 
> Why do we have the above printout for async path but not sync path?
> It's kinda weird for the code path to diverge like this.  Shouldn't
> the only difference be the context probes are running from?

Yeah sure, I'll remove this, it was useful for me for testing purposes
in evaluation against kthreads / sync runs, but that certainly was mostly
for debugging.

> ...
> > +static bool drv_enable_async_probe(struct device_driver *drv,
> > +				   struct bus_type *bus)
> > +{
> > +	struct module *mod;
> > +
> > +	if (!drv->owner || drv->sync_probe)
> > +		return false;
> > +
> > +	if (force_mod_async)
> > +		return true;
> > +
> > +	mod = drv->owner;
> > +	if (!safe_mod_async && !mod->async_probe_requested)
> > +		return false;
> > +
> > +	/* For now lets avoid stupid bug reports */
> > +	if (!strcmp(bus->name, "pci") ||
> > +	    !strcmp(bus->name, "pci_express") ||
> > +	    !strcmp(bus->name, "hid") ||
> > +	    !strcmp(bus->name, "sdio") ||
> > +	    !strcmp(bus->name, "gameport") ||
> > +	    !strcmp(bus->name, "mmc") ||
> > +	    !strcmp(bus->name, "i2c") ||
> > +	    !strcmp(bus->name, "platform") ||
> > +	    !strcmp(bus->name, "usb"))
> > +		return true;
> 
> Ugh... things like this tend to become permanent.  Do we really need
> this?  And how are we gonna find out what's broken why w/o bug
> reports?

Yeah... well we have two options, one is have something like this to
at least make it generally useful or remove this and let folks who
care start fixing async for all modules. The downside to removing
this is it makes async probe pretty much useless on most systems
right now, it would mean systemd would have to probably consider
the list above if they wanted to start using this without expecting
systems to not work.

Let me know what is preferred.

> > diff --git a/drivers/base/dd.c b/drivers/base/dd.c
> > index e4ffbcf..7999aba 100644
> > --- a/drivers/base/dd.c
> > +++ b/drivers/base/dd.c
> > @@ -507,6 +507,13 @@ static void __device_release_driver(struct device *dev)
> >  
> >  	drv = dev->driver;
> >  	if (drv) {
> > +		if (drv->owner && !drv->sync_probe) {
> > +			struct module *mod = drv->owner;
> > +			struct driver_private *priv = drv->p;
> > +
> > +			if (mod->async_probe_requested)
> > +				flush_work(&priv->attach_work->work);
> 
> This can be unconditional flush_work(&priv->attach_work) if attach_work
> isn't separately allocated.

Indeed.

> >  static int unknown_module_param_cb(char *param, char *val, const char *modname,
> >  				   void *arg)
> >  {
> > +	int ret;
> > +	struct module *mod = arg;
> 
> Ditto with the order of definitions.

Amended.

> Generally looks good to me.
> 
> Thanks a lot for doing this! :)

Thanks for the review and pointers so far.

  Luis
