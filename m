From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH net-next 08/12] r8152: support TSO
Date: Tue, 4 Mar 2014 14:35:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D0284@AcuExch.aculab.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CFFE0@AcuExch.aculab.com>
 <CF9EF717568D49DB858D5363B1099FC0@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org" <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'hayeswang' <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CF9EF717568D49DB858D5363B1099FC0-Rasf1IRRPZGoECsaD+WFmw@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: hayeswang 
>  David Laight [mailto:David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org]
> > Sent: Tuesday, March 04, 2014 8:12 PM
> > To: 'Hayes Wang'; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: RE: [PATCH net-next 08/12] r8152: support TSO
> >
> > From: Hayes Wang
> > > Support scatter gather and TSO.
> > >
> > > Adjust the tx checksum function and set the max gso size to fix the
> > > size of the tx aggregation buffer.
> >
> > There is little point supporting TSO unless the usb host controller
> > supports arbitrary aligned scatter-gather.
> > All you do is require that a large skb be allocated (that may well
> > fail), and add it another data copy.
> 
> I think I have done it. For also working for EHCI usb host controller,
> I allocate 16 KB continuous buffer and copy the fragmented packets to
> it and bulk out the buffer.

Does that mean you are splitting the 64k 'ethernet packet' from TCP
is software? I've looked at the ax88179 where the hardware can do it.

Is there really a gain doing segmentation here if you have to do the
extra data copy?

It might be worth packing multiple short packets into a single USB bulk
data packet, but that might require a CBU (crystal ball unit).

I did measure a maximum transmit ethernet frame rate of (IIRC) 250000
frames/sec for the ax88179 - probably limited by the USB3 frame rate.
Exceeding that would probably require putting multiple tx packets into
a single URB. OTOH that limit probably doesn't matter

What might be more useful is to set the rx side up to receive into
page-aligned 2k (or 4k) buffers and then separate out the ethernet
frames into the required skb - probably as page list fragments
(I'm not entirely sure how such skb can be created).

I don't know what the r8152 does, but the usbnet code encourages it to
allocate long skb, pass them to the usb stack to fill, and then clone
them if they contain multiple frames.

This isn't really good use of memory or cpu cycles.
The ax88179 driver also lies badly about the skb's truesize.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
