From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Subject: Re: [Resend][PATCH] usb driver for intellon int51x1 based PLC like
      devolo dlan duo
Date: Sat, 18 Apr 2009 18:45:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904181834210.3691@wrl-59.cs.helsinki.fi>
References: <cb6d2886e87af66d945f1052e6eb8a85.squirrel@webmail.it-technology.at>
    <Pine.LNX.4.64.0904181311470.3600@wrl-59.cs.helsinki.fi>
 <0681089db5bdc5acc805ed52130dc9a5.squirrel@webmail.it-technology.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Holik <peter-xHLhtm3VSFg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0681089db5bdc5acc805ed52130dc9a5.squirrel-2RFepEojUI1IVnL2akGZhTp0pij5GnPV@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 18 Apr 2009, Peter Holik wrote:

> >> +static struct sk_buff *int51x1_tx_fixup(struct usbnet *dev,
> >> +		struct sk_buff *skb, gfp_t flags)
> >> +{
> >> +	int pack_len = skb->len;
> >> +	int headroom = skb_headroom(skb);
> >> +	int tailroom = skb_tailroom(skb);
> >> +	int need_tail = 0;
> >> +	__le16 *len;
> >> +
> >> +	/*
> >> +	 * usbnet would send a ZLP if packetlength mod urbsize == 0 for us,
> >> +	 * but we need to know ourself, because this would add to the length
> >> +	 * we send down to the device...
> >> +	 */
> >> +	if (!((pack_len + INT51X1_HEADER_SIZE) % dev->maxpacket))
> >> +		need_tail = 1;
> >> +
> >> +	/* if packet and our header is smaler than 64 pad to 64 (+ ZLP) */
> >> +	if ((pack_len + INT51X1_HEADER_SIZE + need_tail) < dev->maxpacket + 1)
> >> +		need_tail = dev->maxpacket + 1 - pack_len - INT51X1_HEADER_SIZE;
> >
> > This is totally crazy code fragment, first need_tail is used like a
> > boolean? But on the same some +1 scalar trick is being done? Is there some
> > reason why DIV_ROUND_UP (linux/kernel.h) won't do what you want here and
> > then you can trivally find diff = new - old ?
> >
> 
> maybe this version is not so crazy for you?
> 
>         /* if packet and our header is smaler than 64 pad to 64 (+ ZLP) */
>         if ((pack_len + INT51X1_HEADER_SIZE) < dev->maxpacket)
>                 need_tail = dev->maxpacket - pack_len - INT51X1_HEADER_SIZE + 1;
>         /*
>          * usbnet would send a ZLP if packetlength mod urbsize == 0 for us,
>          * but we need to know ourself, because this would add to the length
>          * we send down to the device...
>          */
>         else if (!((pack_len + INT51X1_HEADER_SIZE) % dev->maxpacket))
>                 need_tail = 1;

Certainly looks more obvious, having that + need_tail and the related + 1 
on the other side of the condition made the original very hard to read 
(and I failed to read it correctly which was the reason for the wrong 
DIV_ROUND_UP comment I made). This one is much better. I guess adding
a temporary var for pack_len + INT51X1_HEADER_SIZE would also make it 
somewhat nicer looking.


-- 
 i.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
