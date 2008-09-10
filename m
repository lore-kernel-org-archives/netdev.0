From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Tue, 9 Sep 2008 22:07:25 -0700
Message-ID: <20080910050725.GD2897@kroah.com>
References: <1220960196-4209-1-git-send-email-steve.glendinning@smsc.com> <1220960196-4209-2-git-send-email-steve.glendinning@smsc.com> <1220966387.2381.42.camel@achroite> <20080909140224.GA3095@kroah.com> <1220970610.2381.64.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ian Saturley <ian.saturley-sdUf+H5yV5I@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1220970610.2381.64.camel@achroite>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 09, 2008 at 03:30:10PM +0100, Ben Hutchings wrote:
> On Tue, 2008-09-09 at 07:02 -0700, Greg KH wrote:
> > On Tue, Sep 09, 2008 at 02:19:47PM +0100, Ben Hutchings wrote:
> > > On Tue, 2008-09-09 at 12:36 +0100, Steve Glendinning wrote:
> > > [...]
> > > > diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> > > > new file mode 100644
> > > > index 0000000..60ffd90
> > > > --- /dev/null
> > > > +++ b/drivers/net/usb/smsc95xx.c
> > > [...]
> > > > +static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
> > > > +{
> > > > +	u32 *buf = kmalloc(4, GFP_KERNEL);
> > > > +	int ret;
> > > > +
> > > > +	BUG_ON(!dev);
> > > > +
> > > > +	if (!buf)
> > > > +		return -ENOMEM;
> > > > +
> > > > +	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > > > +		USB_VENDOR_REQUEST_READ_REGISTER,
> > > > +		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> > > > +		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
> > > > +
> > > > +	if (unlikely(ret < 0))
> > > > +		SMSC_WARNING("Failed to read register index 0x%08x", index);
> > > > +
> > > > +	le32_to_cpus(buf);
> > > > +	*data = *buf;
> > > > +	kfree(buf);
> > > > +
> > > > +	return ret;
> > > > +}
> > > 
> > > Why are you allocating a buffer on the heap?  What's wrong with
> > 
> > USB requires data to be allocated off of the heap when you use it to
> > send or receive data.
> 
> I don't really know USB (it's not very useful for 1G/10G networking :-)
> which is why I asked.  Is this because the data may be transferred by
> DMA and the stack might not be DMA-mappable?

Exactly.

> I'd be inclined to allocate a persistent buffer for register reads and
> writes, but then that seems to introduce the need for another lock.
> Presumably the heap allocation is reckoned to add very little overhead
> compared to the inherent cost of synchronous USB requests?

Exactly.  Control messages like this are also very slow so it really
isn't a big deal at all to dynamically allocate the data.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
