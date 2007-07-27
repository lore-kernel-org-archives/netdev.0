From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] Merge the Sonics Silicon Backplane subsystem
Date: Fri, 27 Jul 2007 21:43:59 +0200
Message-ID: <200707272143.59551.mb@bu3sch.de>
References: <200707271857.24162.mb@bu3sch.de> <200707272130.48973.mb@bu3sch.de> <20070727123853.d16e875c.akpm@linux-foundation.org>
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
In-Reply-To: <20070727123853.d16e875c.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 27 July 2007 21:38:53 Andrew Morton wrote:
> > > > +static ssize_t ssb_pci_attr_sprom_show(struct device *pcidev,
> > > > +				       struct device_attribute *attr,
> > > > +				       char *buf)
> > > > +{
> > > > +	struct pci_dev *pdev = container_of(pcidev, struct pci_dev, dev);
> > > > +	struct ssb_bus *bus;
> > > > +	u16 *sprom;
> > > > +	int err = -ENODEV;
> > > > +	ssize_t count = 0;
> > > > +
> > > > +	bus = ssb_pci_dev_to_bus(pdev);
> > > > +	if (!bus)
> > > > +		goto out;
> > > > +	err = -ENOMEM;
> > > > +	sprom = kcalloc(SSB_SPROMSIZE_WORDS, sizeof(u16), GFP_KERNEL);
> > > > +	if (!sprom)
> > > > +		goto out;
> > > > +
> > > > +	err = -ERESTARTSYS;
> > > > +	if (mutex_lock_interruptible(&bus->pci_sprom_mutex))
> > > > +		goto out_kfree;
> > > > +	sprom_do_read(bus, sprom);
> > > > +	mutex_unlock(&bus->pci_sprom_mutex);
> > > > +
> > > > +	count = sprom2hex(sprom, buf, PAGE_SIZE);
> > > > +	err = 0;
> > > > +
> > > > +out_kfree:
> > > > +	kfree(sprom);
> > > > +out:
> > > > +	return err ? err : count;
> > > > +}
> > > 
> > > The mutex_lock_interruptible() looks fishy.  Some commented explanation of
> > > what it's doing would be good here.  It's quite unobvious to this reader. 
> > > Cheesy deadlock avoidance?  Hope not.
> > 
> > No, it's simply to avoid writing the SPROM concurrently.
> > SPROM writing is hairy and we must make sure here that
> > we are the only one accessing the whole bus. We do that
> > by suspending all devices and taking a lock to protect
> > the SPROM from write concurrency.
> 
> Sure, but why is the locking interruptible rather than plain old
> mutex_lock()?

Hm, well. We hold this mutex for several seconds, as writing takes
this long. So I simply thought it was worth allowing the waiter
to interrupt here. If you say that's not an issue, I'll be happy
to use mutex_lock() and reduce code complexity in this area.

-- 
Greetings Michael.
