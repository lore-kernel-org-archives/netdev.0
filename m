From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] pegasus usb-net: Fix endianness bugs
Date: Thu, 18 Jun 2009 20:02:42 +0200
Message-ID: <200906182002.42629.mb@bu3sch.de>
References: <200906181903.47541.mb@bu3sch.de> <20090618174621.GA3416@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090618174621.GA3416-YzwxZg+R7evSU73v1vjTzyO4YDw3rz4rAInAS/Ez/D0@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 18 June 2009 19:46:22 Jiri Pirko wrote:
> >--- linux-2.6.30.orig/drivers/net/usb/pegasus.c
> >+++ linux-2.6.30/drivers/net/usb/pegasus.c
> >@@ -297,7 +297,7 @@ static int update_eth_regs_async(pegasus
> > 
> > 	pegasus->dr.bRequestType = PEGASUS_REQT_WRITE;
> > 	pegasus->dr.bRequest = PEGASUS_REQ_SET_REGS;
> >-	pegasus->dr.wValue = 0;
> >+	pegasus->dr.wValue = cpu_to_le16(0);
> Is this necessary? I mean zero is still zero :-)

Well, yes. However wValue is a little endian variable and 0 is CPU endian.
The fact that 0 is represented with the same bits in LE and BE doesn't really
matter. It documents the fact that we really require this to be a LE value.
GCC will recognize it and optimize it away, so it's not a runtime issue.
And  wValue = cpu_to_le16(0)  is used in the rest of the driver, too. This is the
only place that doesn't use it. So let's fix it. If only for consistency.

> >+	u8 interval;
> > 
> >-	read_eprom_word(pegasus, 4, (__u16 *) data);
> >+	read_eprom_word(pegasus, 4, &data);
> >+	interval = data >> 8;
> > 	if (pegasus->usb->speed != USB_SPEED_HIGH) {
> >-		if (data[1] < 0x80) {
> >+		if (interval < 0x80) {
> > 			if (netif_msg_timer(pegasus))
> > 				dev_info(&pegasus->intf->dev, "intr interval "
> > 					"changed from %ums to %ums\n",
> >-					data[1], 0x80);
> >-			data[1] = 0x80;
> >+					interval, 0x80);
> >+			interval = 0x80;
> >+			data = (data & 0x00FF) | ((u16)interval << 8);
>                                                   ^^^^^ you do not need this
> 							  typecast

Hm, well. The cast is there because "interval" is an 8bit variable.
I think the behavior of C is machine dependent in such a situation.
But as Linux doesn't run on anything with less than 32bit registers, it probably
doesn't matter.

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
