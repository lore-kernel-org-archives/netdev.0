From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][ATM]: [ambassador] eliminate pci_find_device()
Date: Thu, 21 Oct 2004 12:38:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021113841.GA3720@infradead.org>
References: <200410211126.i9LBQbFT008844@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200410211126.i9LBQbFT008844@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>    // Did one of our cards generate the interrupt?
> -  while (dev) {
> +  list_for_each(p, &amb_devs) {
> +    dev = list_entry(p, struct amb_dev, entry);
>      if (dev == dev_id)
>        break;
> -    dev = dev->prev;
> +    dev = NULL;
>    }
>    // impossible - unless we add the device to our list after both
>    // registering the IRQ handler for it and enabling interrupts, AND

this debug check is superflous.

>    
> @@ -1554,19 +1556,19 @@
>  
>  /********** housekeeping **********/
>  static void do_housekeeping (unsigned long arg) {
> -  amb_dev * dev = amb_devs;
> +  amb_dev * dev;
> +  struct list_head *p;
>    // data is set to zero at module unload
>    (void) arg;
>    
>    if (housekeeping.data) {
> -    while (dev) {
> +    list_for_each(p, &amb_devs) {
> +      dev = list_entry(p, struct amb_dev, entry);

this really should be a per-device timer - or even better using
schedule_delayed_work()

With these two changes you could get rid of amb_devs easily.  If you still
want to keep it for some reason at least use list_for_each_entry.

> +	list_del(&dev->entry);
> +    
> +	PRINTD(DBG_INFO|DBG_INIT, "closing %p (atm_dev = %p)", dev, dev->atm_dev);
> +	// the drain should not be necessary
> +	drain_rx_pools(dev);
> +	interrupts_off(dev);
> +	amb_reset(dev, 0);
> +	free_irq(dev->irq, dev);
> +	pci_disable_device(pci_dev);
> +	destroy_queues(dev);
> +	atm_dev_deregister(dev->atm_dev);
> +	kfree(dev);
> +	pci_release_region(pci_dev, 1);

this doesn't look correct (without knowing the atm subsystem in detail), in
general you need to unregister from the subsystem first so you don't get
new work, and then you can start tearing the hardware down.

Also disabling the device before releasing the regions doesn't make too much
sense to me, even if it may be valid.
