From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Fri, 12 Oct 2012 11:29:49 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210121126330.1605-100000@iolanthe.rowland.org>
References: <3535515.7NRjKhCcrL@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<jkosina-IBi9RG/b67k@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3535515.7NRjKhCcrL-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2012, Oliver Neukum wrote:

> On Thursday 11 October 2012 10:36:22 Alan Stern wrote:
> 
> > It's worse than you may realize.  When a SCSI disk is suspended, all of
> > its ancestor devices may be suspended too.  Pages can't be read in from
> > the drive until all those ancestors are resumed.  This means that all
> > runtime resume code paths for all drivers that could be bound to an
> > ancestor of a block device must avoid GFP_KERNEL.  In practice it's
> > probably easiest for the runtime PM core to use tsk_set_allowd_gfp()
> > before calling any runtime_resume method.
> > 
> > Or at least, this will be true when sd supports nontrivial autosuspend.
> 
> Up to now, I've found three driver for which tsk_set_allowd_gfp() wouldn't
> do the job. They boil down into two types of errors. That is surprisingly good.
> 
> First we have workqueues. bas-gigaset is a good example.
> The driver kills a scheduled work in pre_reset(). If this is done synchronously
> the driver may need to wait for a memory allocation inside the work.
> In principle we could provide a workqueue limited to GFP_NOIO. Is that worth
> it, or do we just check?

The work routine could set the GFP mask upon entry and exit.  Then a 
separate workqueue wouldn't be needed.

> Second there is a problem just like priority inversion with realtime tasks.
> usb-skeleton and ati_remote2
> They take mutexes which are also taken in other code paths. So the error
> handler may need to wait for a mutex to be dropped which can only happen
> if a memory allocation succeeds, which is waiting for the error handler.
> 
> usb-skeleton is even worse, as it does copy_to_user(). I guess copy_to/from_user
> must simply not be done under such a mutex.

Right.

> I am afraid there is no generic solution in the last two cases. What do you think?

The other contexts must also set the GFP mask.  Unfortunately, this has 
to be done case-by-case.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
