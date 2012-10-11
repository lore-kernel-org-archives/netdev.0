From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Thu, 11 Oct 2012 10:36:22 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210111030570.1170-100000@iolanthe.rowland.org>
References: <1588459.VLxBbnNMlP@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1588459.VLxBbnNMlP-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2012, Oliver Neukum wrote:

> On Thursday 11 October 2012 11:18:22 Ming Lei wrote:
> > On Wed, Oct 10, 2012 at 1:51 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> > >
> > > No, the problem is autoresume.
> > >
> > > Suppose we have a device with two interface. Interface A be usbnet; interface B
> > > something you page on. Now consider that you can only resume both interfaces
> > > and this is (and needs to be) done synchronously.
> > >
> > > Now we can have this code path:
> > >
> > > autoresume of device -> resume() -> kmalloc(..., GFP_KERNEL) ->
> > > VM layer decides to start paging out -> IO to interface B -> autoresume of device
> > > --> DEADLOCK
> > 
> > Currently scsi disk can only be runtime suspended when the device is not
> > opened, so are you sure that the paging out above can cause IO on a suspend
> > usb mass storage disk which is not mounted or opened by utility now?
> 
> We definitely do not wish to keep it that way. People at Intel are currently working
> on better power management for sd, which would allow full autosuspend.

It's worse than you may realize.  When a SCSI disk is suspended, all of
its ancestor devices may be suspended too.  Pages can't be read in from
the drive until all those ancestors are resumed.  This means that all
runtime resume code paths for all drivers that could be bound to an
ancestor of a block device must avoid GFP_KERNEL.  In practice it's
probably easiest for the runtime PM core to use tsk_set_allowd_gfp()
before calling any runtime_resume method.

Or at least, this will be true when sd supports nontrivial autosuspend.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
