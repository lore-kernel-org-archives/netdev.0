From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Wed, 20 Nov 2013 08:06:05 -0800
Message-ID: <20131120160605.GB9611@xanatos>
References: <20131119225822.GA9611@xanatos>
 <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7437-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 20, 2013 at 09:36:11AM -0000, David Laight wrote:
> > From: Alan Stern [mailto:stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org]
> > On Tue, 19 Nov 2013, Sarah Sharp wrote:
> > 
> > > The xHCI driver can limit the number of sg-list entries through
> > > hcd->self.sg_tablesize.  It's currently set to ~0, which is "however
> > > many entries you want.  You could set that to the number of TRBs in a
> > > segment (minus one for the link TRB).
> > >
> > > The usb-storage and uas drivers currently use sg_tablesize.  Could the
> > > network stack be taught to use sg_tablesize as well?
> > 
> > The sg_tablesize you're talking about is a field in struct usb_bus
> > (there's a similar field in struct scsi_host_template).  It's not
> > relevant to the network stack, since network interfaces aren't USB host
> > controllers (or SCSI hosts).
> 
> Ben said the largest number of fragments from the current network
> stack will be 17, and that none of them will cross 32k boundaries.
> So the network stack won't send down long SG lists.

Ok, so the networking layer should be fine.  However, with the current
patch, if the mass storage driver sends down a scatter-gather list
that's bigger than a ring segment, or needs to be split up so it doesn't
cross 64K boundaries, then the URB submission will fail.  We don't want
that to happen.

At the very least, we should limit hcd->self.sg_tablesize in
drivers/usb/host/xhci.c to 63 (TRBS_PER_SEGMENT - 1).  But we could
still potentially run into the 64K boundary issue in one or maybe all of
those entries.  Would it be crazy to limit the number of entries to half
that (31)?  It may impact performance, but it ensures that SCSI reads
and writes don't randomly fail.  We can always increase the ring segment
size in a later patch.

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
