From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: usbnet transmit path problems
Date: Wed, 11 Sep 2013 17:05:54 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7329@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com><1378894312.28160.15.camel@linux-fkkt.site><20130911193430.0825ac95@tom-ThinkPad-T410><AE90C24D6B3A694183C094C60CF0A2F6026B7326@saturn3.aculab.com> <CACVXFVN6ZHLesrsMVNMWrikRs1mMbk=aZD9qZybNn1gB7aFTZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Oliver Neukum" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"Network Development" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Ming Lei" <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <CACVXFVN6ZHLesrsMVNMWrikRs1mMbk=aZD9qZybNn1gB7aFTZQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Wed, Sep 11, 2013 at 8:56 PM, David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org> wrote:
> >> > > 2) If 'length % dev->maxpacket == 0' for a multi-fragment packet then
> >> > >    the extra byte isn't added correctly (the code probably falls off
> >> > >    the end of the scatter-gather list).
> >> >
> >> > Indeed. Ming Lei, should usbnet handle this in the sg case or better
> >> > leave it to the subdriver you introduced this for?
> >
> > Is the ZLP issue a problem with the host or with the target?
> 
> Sorry, what do you mean the ZLP issue here? I understand Oliver
> thinks one commit from me may break ZLP handling, are you discussing
> this problem? If not, could you explain it in a bit detail?

I was thinking of the general ZLP problem.
 
> > If it is a host problem then the necessity comes from the host,
> > but the fix needs to be target dependant.
> > If it is a common target problem then generic code can apply
> > a common fix.
> 
> All usbnet device should have sent one ZLP in case the size of
> bulk out transfer can be divided by max packet size, but the one
> byte transfer might be introduced for avoiding some target problem
> (can't deal with zlp well), as said by David, see below discussion:
> 
>    http://marc.info/?l=linux-usb&m=127067487604112&w=2

AFAICT the code avoids sending a zero length packet (that would
terminate a USB bulk transfer packet) by increasing the length
of the bulk packet by (at least) one byte.

> > AFICT there are at least 3 fixes:
> > 1) Extend the ethernet frame by one byte and hope the receiving
> >    system doesn't object to the padding.
> >    This is probably the only option if tx_fixup() doesn't
> >    add a header.
> > 2) Put the ethernet frame length in the header and have the
> >    target discard the added pad byte (ax88179_178a.c).
> > 3) Add a second zero-length frame in the same USB data block
> >    (ax88172a.c).
> 
> Why do we need the above 3 fixes? The patch in my last email can
> fix the problem which is introduced recently, can't it?

I meant there are 3 ways of avoiding the ZLP, each driver will
pick one of them.

I've just looked at all the drivers in net/usb.
It doesn't look like they all handle fragmented skb, shared skb,
or ZLP properly.

A lot of common code could be removed if usbnet knew the size of the
header and allocated it before calling tx_fixup().

None of this is helping me sort out why netperf udp rr tests with
burst 19 are losing all the packets at once :-(

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
