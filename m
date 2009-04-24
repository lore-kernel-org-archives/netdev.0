From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] : CDC EEM driver patch to be applied to 2.6.30 kernel
Date: Fri, 24 Apr 2009 13:41:35 -0700
Message-ID: <200904241341.35436.david-b@pacbell.net>
References: <3a98b4410904240831n1ad9c336x1b11b3c5239c7f66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Omar Laazimani <omar.oberthur@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:25534 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751083AbZDXUlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 16:41:37 -0400
In-Reply-To: <3a98b4410904240831n1ad9c336x1b11b3c5239c7f66@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 24 April 2009, Omar Laazimani wrote:
> This patch introduces a CDC EEM kernel module (host side only) to
> supports USB EEM devices.

Great ... v2 of the patch, delivered in-line!  And with a few
cleanups!  :)

Still needs a signed-off-by line; see Documentation/SubmittingPatches

But it's not yet ready for merge, IMO.  There are some
clear x86 dependencies here, and some bit-ordering code
that look buggy regardless.


> 
> 
> diff -ruN linux-source-2.6.30/drivers/net/usb/cdc_eem.c
> linux-source-2.6.30_new/drivers/net/usb/cdc_eem.c
> --- linux-source-2.6.30/drivers/net/usb/cdc_eem.c	1970-01-01
> 01:00:00.000000000 +0100
> +++ linux-source-2.6.30_new/drivers/net/usb/cdc_eem.c	2009-04-24
> 13:27:30.000000000 +0200
> @@ -0,0 +1,254 @@
> +/*
> + * USB CDC EEM based networking peripherals
> + * Copyright (C) 2009 Oberthur Technologies by Omar Laazimani,
> Olivier Condemine

Looks like your mailer is wrapping lines ... and that one is
kind of long anyway, I'd wrap by hand before "by".

Maybe Documentation/email-clients.txt would help.


> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/ctype.h>
> +#include <linux/ethtool.h>
> +#include <linux/workqueue.h>
> +#include <linux/mii.h>
> +#include <linux/usb.h>
> +#include <linux/crc32.h>
> +#include <linux/usb/cdc.h>
> +#include <linux/usb/usbnet.h>
> +
> +/*
> + * This module encapsulates Ethernet frames for transport
> + * across the USB bus, normally "usb0".

The bus isn't going to be "usb0" ... they're numbered
starting at 1, like ports.  Maybe you mean the network
interface will normally be "usb0"?  But that's only
going to be true if the devices you talk to aren't
using managed Ethernet addresses; you set FLAG_ETHER.


> + *
> + * This driver is a first implementation for CDC EEM specification.
> + * For more details, see www.usb.org/developers/devclass_docs/CDC_EEM10.pdf
> + *
> + * This driver implements only the USB Packet with single EEM payload case.
> + * This version has been tested with GIGAntIC WuaoW SIM Smart Card on 2.6.24,
> + * 2.6.27 and 2.6.30rc2 kernel.
> + * It has also been validated on Openmoko Om 2008.12 (based on 2.6.24 kernel).
> + * v1.0 build on 23-April-2009
> + */
> +
> +
> +#define EEM_HEAD  2       /* 2 byte header */
> +#define EEM_TAIL  4       /* 4 byte crc tail */
> +
> +#define EEM_MAX_PACKET	(ETH_FRAME_LEN + EEM_HEAD + EEM_TAIL)
> +
> +/*-------------------------------------------------------------------------*/
> +
> +static int eem_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +	int status = 0;
> +
> +	status = usbnet_get_endpoints(dev, intf);
> +	if (status < 0) {
> +		usb_set_intfdata(intf, NULL);
> +		usb_driver_release_interface(driver_of(intf), intf);
> +		return status;
> +	}
> +
> +	return 0;
> +}
> +
> +void eem_unbind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +	struct cdc_state	*info = (void *) &dev->data;
> +	struct usb_driver	*driver = driver_of(intf);
> +
> +	if (intf == info->control && info->data) {
> +		usb_set_intfdata(info->data, NULL);
> +		usb_driver_release_interface(driver, info->data);
> +		info->data = NULL;
> +	}
> +
> +	else if (intf == info->data && info->control) {

Style:  "} else if ... {"

I'd think scripts/checkpatch.pl would remind you of that.


> +		usb_set_intfdata(info->control, NULL);
> +		usb_driver_release_interface(driver, info->control);
> +		info->control = NULL;
> +	}
> +}
> +
> +
> +static struct sk_buff *eem_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
> +				       gfp_t flags)
> +{
> +	struct sk_buff	*skb2 = NULL;
> +	int		len = skb->len;
> +	u32		crc = 0;
> +
> +	/* EEM packet format:
> +	 * b0: 		bmType
> +	 * b1: 		bmCRC
> +	 * b2..b15:	length of ethernet frame
> +	 * b16..n-4: 	ethernet frame data
> +	 * bn-3..n: 	CRC
> +	 */
> +

Nit:  strike the extra blank line there.


> +	if (!skb_cloned(skb)) {
> +		int	headroom = skb_headroom(skb);
> +		int	tailroom = skb_tailroom(skb);
> +
> +		if ((tailroom >= EEM_TAIL) && (headroom >= EEM_HEAD))
> +			goto done;
> +
> +		if ((headroom + tailroom) > (EEM_TAIL + EEM_HEAD)) {
> +			skb->data = memmove(skb->head +
> +					EEM_HEAD,
> +					skb->data,
> +					skb->len);
> +			skb_set_tail_pointer(skb, len);
> +			goto done;
> +		}
> +	}
> +
> +	skb2 = skb_copy_expand(skb, EEM_HEAD, EEM_TAIL, flags);
> +	if (!skb2)
> +		return NULL;
> +
> +	dev_kfree_skb_any(skb);
> +	skb = skb2;
> +
> +done:
> +	crc = crc32_le(~0, skb->data, skb->len);
> +	crc = ~crc;
> +
> +	*skb_put(skb, 1) = crc & 0xff;
> +	*skb_put(skb, 1) = (crc >> 8) & 0xff;
> +	*skb_put(skb, 1) = (crc >> 16) & 0xff;
> +	*skb_put(skb, 1) = (crc >> 24) & 0xff;

Do you really need the masks?  I'd think just casting to u8
ought to suffice.  But

	put_unaligned_le32(crc, *skb_put(skb, 4))

would likely be more efficient.


> +
> +	len = skb->len;
> +
> +	*skb_push(skb, 1) = (len >> 8) | 0x40;
> +	*skb_push(skb, 1) = len;

Similarly, put_unaligned_le16(BIT(0) | len)

... or what ever the right thing is.  Note that your
bit numbering above doesn't match the code; you're
setting BIT(6) but documenting BIT(1) as holding the
"crc is included" flag.  I'm fairly sure there are
some problems there, which would be resolved by having
your TX and RX sides consistently write 16 or 32 bit
data values instead of unrolling that logic by hand.


> +
> +	return skb;
> +}
> +
> +static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> +{
> +	u16 	*header = NULL;
> +	u32 	*tailer = NULL;

That would normally be "trailer", but some variety is nice.  :)


> +	bool	bmType, bmCRC;
> +
> +	/*
> +	 * EEM packet format:
> +	 * b0: 		bmType
> +	 * b1: 		bmCRC
> +	 * b2..b15:	length of ethernet frame
> +	 * b16..n-4: 	ethernet frame data
> +	 * bn-3..n: 	CRC
> +	 */
> +	header = (u16 *) skb->data;

Hmm, this might better by "u16 header;" paired
with "header = le16_to_cpup(skb->data);" ... or
more conservatively, use get_unaligned_le16(...).

You mustn't assume the host byte order is the
same as the wire byte order.

It may be OK to assume 16-bit aligned data though;
I forget.  On x86 it won't matter, but on other
CPUs it may.


> +	skb_pull(skb, EEM_HEAD);
> +
> +	/*
> +	 * The bmType bit helps to denote when EEM
> +	 * packet is data or command :
> +	 *	bmType = 0	: EEM data payload
> +	 *	bmType = 1	: EEM command
> +	 */
> +	if (*header >> 15)

It'd be more clear if you just mask BIT(0), matching
the docs, instead of testing BIT(15) ... is this a
symptom of the invalid byte-order assumptions noted
above?


> +		bmType = true;
> +	else
> +		bmType = false;
> +
> +	/*
> +	 * The bmCRC helps to denote when the CRC
> +	 * field contains a calculated CRC :
> +	 *	bmCRC = 1	: CRC is calculated
> +	 *	bmCRC = 0	: CRC = "0xDEADBEAF"
> +	 */
> +	if ((*header >> 14) & 0x01)

Likewise: test against BIT(1) or whatever ... and
make sure that your comments fix the problem where
the bit ordering in code and comments don't match.


> +		bmCRC = true;
> +	else
> +		bmCRC = false;
> +
> +	tailer = (u32 *) (skb->data + skb->len - sizeof(u32));

Better would be "u32 crc", and "crc = get_unaligned_le32(...)"
using the relevant skb ops to get that pointer.


> +	skb_trim(skb, skb->len - EEM_TAIL);

It's also odd that you use EEM_TAIL here but "sizeof(u32)" above..

> +
> +	if (bmCRC) {
> +		/* FIXME This version of cdc_eem is a little bit tolerant :
> +		 * this case is considered like DEADBEAF mode.
> +		 */

Fix that soonish -- before submitting for merge!

You'll need to do the byteorder conversion correctly, and
handle alignment right.  Again, get_unaligned_le32() would
be safest.


> +	} else {
> +		if (*tailer != 0xefbeadde) {

The fact that you can't test against 0xdeadbeef is strong
evidence of byteswap bugs.


> +			dbg("bad CRC");
> +			return 0;
> +		}
> +	}
> +
> +	if (bmType) {
> +		/* FIXME the EEM commands are not managed yet. */

Right, something to fix before merge.

I seem to recall that EEM didn't require USB packet
boundaries to match EEM message boundaries.  Is that
true?  If so, you'll have to cope with additional
cases here, like:

 - the RX packet includes two Ethernet frames
 - or one EEM command and an Ethernet frame
 - or two EEM commands
 - ... etc


> +		return 0;
> +	}
> +
> +	return 1;
> +}
> +
> +static const struct driver_info	eem_info = {
> +	.description =	"EEM Device",
> +	.flags =	FLAG_ETHER,
> +	.bind =		eem_bind,
> +	.unbind =	eem_unbind,
> +	.rx_fixup = 	eem_rx_fixup,
> +	.tx_fixup =	eem_tx_fixup,
> +};
> +
> +/*-------------------------------------------------------------------------*/
> +
> +
> +static const struct usb_device_id products[] = {
> +/*
> + * CDC EEM interface.
> + */

Needless comment.  That's what the USB_INTERFACE_INFO() says.  :)

> +{
> +	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_EEM,
> +			USB_CDC_PROTO_EEM),
> +	.driver_info = (unsigned long) &eem_info,
> +},
> +	{ },
> +};
> +MODULE_DEVICE_TABLE(usb, products);
> +
> +static struct usb_driver eem_driver = {
> +	.name =		"cdc_eem",
> +	.id_table =	products,
> +	.probe =	usbnet_probe,
> +	.disconnect =	usbnet_disconnect,
> +	.suspend =	usbnet_suspend,
> +	.resume =	usbnet_resume,
> +};
> +
> +
> +static int __init eem_init(void)
> +{
> +	return usb_register(&eem_driver);
> +}
> +module_init(eem_init);
> +
> +static void __exit eem_exit(void)
> +{
> +	usb_deregister(&eem_driver);
> +}
> +module_exit(eem_exit);
> +
> +MODULE_AUTHOR("Omar Laazimani <omar.oberthur at gmail.com>");
> +MODULE_DESCRIPTION("USB CDC EEM v1.0");
> +MODULE_LICENSE("GPL");
> diff -ruN linux-source-2.6.30/drivers/net/usb/Kconfig
> linux-source-2.6.30_new/drivers/net/usb/Kconfig
> --- linux-source-2.6.30/drivers/net/usb/Kconfig	2009-03-24
> 10:59:19.000000000 +0100
> +++ linux-source-2.6.30_new/drivers/net/usb/Kconfig	2009-04-23
> 16:50:08.000000000 +0200
> @@ -180,6 +180,21 @@
>  	  IEEE 802 "local assignment" bit is set in the address, a "usbX"
>  	  name is used instead.
> 
> +config USB_NET_CDCEEM
> +	tristate "CDC EEM support (smart devices such as usb smart card)"
> +	depends on USB_USBNET
> +	default m
> +	help
> +	  This option supports devices conforming to the Communication Device
> +	  Class (CDC) Ethernet Emulation Model, a specification that's easy to
> +	  implement in device firmware.  The CDC EEM specifications are available
> +	  from <http://www.usb.org/>.
> +
> +	  This driver creates an interface named "ethX", where X depends on
> +	  what other networking devices you have in use.  However, if the
> +	  IEEE 802 "local assignment" bit is set in the address, a "usbX"
> +	  name is used instead.
> +
>  config USB_NET_DM9601
>  	tristate "Davicom DM9601 based USB 1.1 10/100 ethernet devices"
>  	depends on USB_USBNET
> diff -ruN linux-source-2.6.30/drivers/net/usb/Makefile
> linux-source-2.6.30_new/drivers/net/usb/Makefile
> --- linux-source-2.6.30/drivers/net/usb/Makefile	2009-03-24
> 10:59:19.000000000 +0100
> +++ linux-source-2.6.30_new/drivers/net/usb/Makefile	2009-04-23
> 16:49:22.000000000 +0200
> @@ -9,6 +9,7 @@
>  obj-$(CONFIG_USB_HSO)		+= hso.o
>  obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
>  obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
> +obj-$(CONFIG_USB_NET_CDCEEM)	+= cdc_eem.o
>  obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
>  obj-$(CONFIG_USB_NET_SMSC95XX)	+= smsc95xx.o
>  obj-$(CONFIG_USB_NET_GL620A)	+= gl620a.o
> diff -ruN linux-source-2.6.30/include/linux/usb/cdc.h
> linux-source-2.6.30_new/include/linux/usb/cdc.h
> --- linux-source-2.6.30/include/linux/usb/cdc.h	2009-04-15
> 15:17:52.000000000 +0200
> +++ linux-source-2.6.30_new/include/linux/usb/cdc.h	2009-04-17
> 11:11:52.000000000 +0200
> @@ -17,6 +17,7 @@
>  #define USB_CDC_SUBCLASS_DMM			0x09
>  #define USB_CDC_SUBCLASS_MDLM			0x0a
>  #define USB_CDC_SUBCLASS_OBEX			0x0b
> +#define USB_CDC_SUBCLASS_EEM			0x0c
> 
>  #define USB_CDC_PROTO_NONE			0
> 
> @@ -28,6 +29,8 @@
>  #define USB_CDC_ACM_PROTO_AT_CDMA		6
>  #define USB_CDC_ACM_PROTO_VENDOR		0xff
> 
> +#define USB_CDC_PROTO_EEM			7
> +
>  /*-------------------------------------------------------------------------*/
> 
>  /*
> Signed-off-by: Omar Laazimani <omar.oberthur@gmail.com>
> 
> 


