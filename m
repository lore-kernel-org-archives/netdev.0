From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v4 2/6] PM / Runtime: introduce
 pm_runtime_set_memalloc_noio()
Date: Tue, 6 Nov 2012 15:24:19 -0800
Message-ID: <20121106152419.9155a366.akpm@linux-foundation.org>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Minchan Kim <minchan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351931714-11689-3-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat,  3 Nov 2012 16:35:10 +0800
Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:

> The patch introduces the flag of memalloc_noio in 'struct dev_pm_info'
> to help PM core to teach mm not allocating memory with GFP_KERNEL
> flag for avoiding probable deadlock.
> 
> As explained in the comment, any GFP_KERNEL allocation inside
> runtime_resume() or runtime_suspend() on any one of device in
> the path from one block or network device to the root device
> in the device tree may cause deadlock, the introduced
> pm_runtime_set_memalloc_noio() sets or clears the flag on
> device in the path recursively.
> 

checkpatch finds a number of problems with this patch, all of which
should be fixed.  Please always use checkpatch.

> index 3148b10..d477924 100644
> --- a/drivers/base/power/runtime.c
> +++ b/drivers/base/power/runtime.c
> @@ -124,6 +124,63 @@ unsigned long pm_runtime_autosuspend_expiration(struct device *dev)
>  }
>  EXPORT_SYMBOL_GPL(pm_runtime_autosuspend_expiration);
>  
> +static int dev_memalloc_noio(struct device *dev, void *data)
> +{
> +	return dev->power.memalloc_noio;
> +}
> +
> +/*
> + * pm_runtime_set_memalloc_noio - Set a device's memalloc_noio flag.
> + * @dev: Device to handle.
> + * @enable: True for setting the flag and False for clearing the flag.
> + *
> + * Set the flag for all devices in the path from the device to the
> + * root device in the device tree if @enable is true, otherwise clear
> + * the flag for devices in the path whose siblings don't set the flag.
> + *
> + * The function should only be called by block device, or network
> + * device driver for solving the deadlock problem during runtime
> + * resume/suspend:
> + * 	if memory allocation with GFP_KERNEL is called inside runtime
> + * 	resume/suspend callback of any one of its ancestors(or the
> + * 	block device itself), the deadlock may be triggered inside the
> + * 	memory allocation since it might not complete until the block
> + * 	device becomes active and the involed page I/O finishes. The
> + * 	situation is pointed out first by Alan Stern. Network device
> + * 	are involved in iSCSI kind of situation.
> + *
> + * The lock of dev_hotplug_mutex is held in the function for handling
> + * hotplug race because pm_runtime_set_memalloc_noio() may be called
> + * in async probe().
> + *
> + * The function should be called between device_add() and device_del()
> + * on the affected device(block/network device).
> + */
> +void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
> +{
> +	static DEFINE_MUTEX(dev_hotplug_mutex);
> +
> +	mutex_lock(&dev_hotplug_mutex);
> +	for(;;) {
> +		/* hold power lock since bitfield is not SMP-safe. */
> +		spin_lock_irq(&dev->power.lock);
> +		dev->power.memalloc_noio = enable;
> +		spin_unlock_irq(&dev->power.lock);
> +
> +		dev = dev->parent;
> +
> +		/* only clear the flag for one device if all
> +		 * children of the device don't set the flag.
> +		 */

Such a comment is usually laid out as

		/*
		 * Only ...

More significantly, the comment describes what the code is doing but
not why the code is doing it.  The former is (usually) obvious from
reading the C, and the latter is what good code comments address.

And it's needed in this case.  Why does the code do this?

Also, can a device have more than one child?  If so, the code doesn't
do what the comment says it does.

> +		if (!dev || (!enable &&
> +			     device_for_each_child(dev, NULL,
> +						   dev_memalloc_noio)))
> +			break;
> +	}
> +	mutex_unlock(&dev_hotplug_mutex);
> +}
> +EXPORT_SYMBOL_GPL(pm_runtime_set_memalloc_noio);
>
> ...
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
