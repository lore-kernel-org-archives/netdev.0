From: Diego Giagio <diego@giagio.com>
Subject: Re: [PATCH] drivers/net/usb: Add new driver ipheth
Date: Wed, 21 Apr 2010 11:15:15 -0300
Message-ID: <x2g1b0798831004210715h37253bc5y74baf86556aea7c5@mail.gmail.com>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
	 <1271615719-14928-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dborca@yahoo.com,
	"David S. Miller" <davem@davemloft.net>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	=?ISO-8859-1?Q?Jonas_Sj=F6quist?= <jonas.sjoquist@ericsson.com>,
	Torgny Johansson <torgny.johansson@gmail.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Omar Laazimani <omar.oberthur@gmail.com>,
	=?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?=
	<remi.denis-courmont@nokia.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: =?ISO-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez@sysvalve.es>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1271615719-14928-1-git-send-email-agimenez@sysvalve.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 18, 2010 at 3:35 PM, L. Alberto Gim=E9nez
<agimenez@sysvalve.es> wrote:
> From: Diego Giagio <diego@giagio.com>
>
> Add new driver to use tethering with an iPhone device. After initial =
submission,
> apply fixes to fit the new driver into the kernel standards.
>
> There are still a couple of minor (almost cosmetic-level) issues, but=
 the driver
> is fully functional right now.
>

Signed-off-by: Diego Giagio <diego@giagio.com>
Cc: Daniel Borca <dborca@yahoo.com>

>
> =A0drivers/net/Makefile =A0 =A0 | =A0 =A01 +
> =A0drivers/net/usb/Kconfig =A0| =A0 12 +
> =A0drivers/net/usb/Makefile | =A0 =A01 +
> =A0drivers/net/usb/ipheth.c | =A0568 ++++++++++++++++++++++++++++++++=
++++++++++++++
> =A04 files changed, 582 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/net/usb/ipheth.c
>
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index a583b50..12b280a 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -273,6 +273,7 @@ obj-$(CONFIG_USB_RTL8150) =A0 =A0 =A0 +=3D usb/
> =A0obj-$(CONFIG_USB_HSO) =A0 =A0 =A0 =A0 =A0+=3D usb/
> =A0obj-$(CONFIG_USB_USBNET) =A0 =A0 =A0 =A0+=3D usb/
> =A0obj-$(CONFIG_USB_ZD1201) =A0 =A0 =A0 =A0+=3D usb/
> +obj-$(CONFIG_USB_IPHETH) =A0 =A0 =A0 =A0+=3D usb/
>
> =A0obj-y +=3D wireless/
> =A0obj-$(CONFIG_NET_TULIP) +=3D tulip/
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index ba56ce4..63be4ca 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -385,4 +385,16 @@ config USB_CDC_PHONET
> =A0 =A0 =A0 =A0 =A0cellular modem, as found on most Nokia handsets wi=
th the
> =A0 =A0 =A0 =A0 =A0"PC suite" USB profile.
>
> +config USB_IPHETH
> + =A0 =A0 =A0 tristate "Apple iPhone USB Ethernet driver"
> + =A0 =A0 =A0 default n
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Module used to share Internet connection (tethering=
) from your
> + =A0 =A0 =A0 =A0 iPhone (Original, 3G and 3GS) to your system.
> + =A0 =A0 =A0 =A0 Note that you need userspace libraries and programs=
 that are needed
> + =A0 =A0 =A0 =A0 to pair your device with your system and that under=
stand the iPhone
> + =A0 =A0 =A0 =A0 protocol.
> +
> + =A0 =A0 =A0 =A0 For more information: http://giagio.com/wiki/moin.c=
gi/iPhoneEthernetDriver
> +
> =A0endmenu
> diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
> index 82ea629..edb09c0 100644
> --- a/drivers/net/usb/Makefile
> +++ b/drivers/net/usb/Makefile
> @@ -23,4 +23,5 @@ obj-$(CONFIG_USB_NET_MCS7830) +=3D mcs7830.o
> =A0obj-$(CONFIG_USB_USBNET) =A0 =A0 =A0 +=3D usbnet.o
> =A0obj-$(CONFIG_USB_NET_INT51X1) =A0+=3D int51x1.o
> =A0obj-$(CONFIG_USB_CDC_PHONET) =A0 +=3D cdc-phonet.o
> +obj-$(CONFIG_USB_IPHETH) =A0 =A0 =A0 +=3D ipheth.o
>
> diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
> new file mode 100644
> index 0000000..fd10331
> --- /dev/null
> +++ b/drivers/net/usb/ipheth.c
> @@ -0,0 +1,568 @@
> +/*
> + * ipheth.c - Apple iPhone USB Ethernet driver
> + *
> + * Copyright (c) 2009 Diego Giagio <diego@giagio.com>
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or withou=
t
> + * modification, are permitted provided that the following condition=
s
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + * =A0 =A0notice, this list of conditions and the following disclaim=
er.
> + * 2. Redistributions in binary form must reproduce the above copyri=
ght
> + * =A0 =A0notice, this list of conditions and the following disclaim=
er in the
> + * =A0 =A0documentation and/or other materials provided with the dis=
tribution.
> + * 3. Neither the name of GIAGIO.COM nor the names of its contributo=
rs
> + * =A0 =A0may be used to endorse or promote products derived from th=
is software
> + * =A0 =A0without specific prior written permission.
> + *
> + * Alternatively, provided that this notice is retained in full, thi=
s
> + * software may be distributed under the terms of the GNU General
> + * Public License ("GPL") version 2, in which case the provisions of=
 the
> + * GPL apply INSTEAD OF those given above.
> + *
> + * The provided data structures and external interfaces from this co=
de
> + * are not restricted to be used by modules with a GPL compatible li=
cense.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTO=
RS
> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS=
 FOR
> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRI=
GHT
> + * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDEN=
TAL,
> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF =
USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON=
 ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TO=
RT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE=
 USE
> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
> + * DAMAGE.
> + *
> + *
> + * Attention: iPhone device must be paired, otherwise it won't respo=
nd to our
> + * driver. For more info: http://giagio.com/wiki/moin.cgi/iPhoneEthe=
rnetDriver
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +#include <linux/init.h>
> +#include <linux/slab.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/usb.h>
> +#include <linux/workqueue.h>
> +
> +#define USB_VENDOR_APPLE =A0 =A0 =A0 =A00x05ac
> +#define USB_PRODUCT_IPHONE =A0 =A0 =A00x1290
> +#define USB_PRODUCT_IPHONE_3G =A0 0x1292
> +#define USB_PRODUCT_IPHONE_3GS =A00x1294
> +
> +#define IPHETH_USBINTF_CLASS =A0 =A0255
> +#define IPHETH_USBINTF_SUBCLASS 253
> +#define IPHETH_USBINTF_PROTO =A0 =A01
> +
> +#define IPHETH_BUF_SIZE =A0 =A0 =A0 =A0 1516
> +#define IPHETH_TX_TIMEOUT =A0 =A0 =A0 (5 * HZ)
> +
> +#define IPHETH_INTFNUM =A0 =A0 =A0 =A0 =A02
> +#define IPHETH_ALT_INTFNUM =A0 =A0 =A01
> +
> +#define IPHETH_CTRL_ENDP =A0 =A0 =A0 =A00x00
> +#define IPHETH_CTRL_BUF_SIZE =A0 =A00x40
> +#define IPHETH_CTRL_TIMEOUT =A0 =A0 (5 * HZ)
> +
> +#define IPHETH_CMD_GET_MACADDR =A0 0x00
> +#define IPHETH_CMD_CARRIER_CHECK 0x45
> +
> +#define IPHETH_CARRIER_CHECK_TIMEOUT round_jiffies_relative(1 * HZ)
> +#define IPHETH_CARRIER_ON =A0 =A0 =A0 0x04
> +
> +static struct usb_device_id ipheth_table[] =3D {
> + =A0 =A0 =A0 { USB_DEVICE_AND_INTERFACE_INFO(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 USB_VENDOR_APPLE, USB_PRODUCT_IPHONE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SU=
BCLASS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_USBINTF_PROTO) },
> + =A0 =A0 =A0 { USB_DEVICE_AND_INTERFACE_INFO(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_3G=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SU=
BCLASS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_USBINTF_PROTO) },
> + =A0 =A0 =A0 { USB_DEVICE_AND_INTERFACE_INFO(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_3G=
S,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SU=
BCLASS,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_USBINTF_PROTO) },
> + =A0 =A0 =A0 { }
> +};
> +MODULE_DEVICE_TABLE(usb, ipheth_table);
> +
> +struct ipheth_device {
> + =A0 =A0 =A0 struct usb_device *udev;
> + =A0 =A0 =A0 struct usb_interface *intf;
> + =A0 =A0 =A0 struct net_device *net;
> + =A0 =A0 =A0 struct sk_buff *tx_skb;
> + =A0 =A0 =A0 struct urb *tx_urb;
> + =A0 =A0 =A0 struct urb *rx_urb;
> + =A0 =A0 =A0 unsigned char *tx_buf;
> + =A0 =A0 =A0 unsigned char *rx_buf;
> + =A0 =A0 =A0 unsigned char *ctrl_buf;
> + =A0 =A0 =A0 u8 bulk_in;
> + =A0 =A0 =A0 u8 bulk_out;
> + =A0 =A0 =A0 struct delayed_work carrier_work;
> +};
> +
> +static int ipheth_rx_submit(struct ipheth_device *dev, gfp_t mem_fla=
gs);
> +
> +static int ipheth_alloc_urbs(struct ipheth_device *iphone)
> +{
> + =A0 =A0 =A0 struct urb *tx_urb =3D NULL;
> + =A0 =A0 =A0 struct urb *rx_urb =3D NULL;
> + =A0 =A0 =A0 u8 *tx_buf =3D NULL;
> + =A0 =A0 =A0 u8 *rx_buf =3D NULL;
> +
> + =A0 =A0 =A0 tx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
> + =A0 =A0 =A0 if (tx_urb =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;
> +
> + =A0 =A0 =A0 rx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
> + =A0 =A0 =A0 if (rx_urb =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;
> +
> + =A0 =A0 =A0 tx_buf =3D usb_buffer_alloc(iphone->udev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPH=
ETH_BUF_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP=
_KERNEL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &tx=
_urb->transfer_dma);
> + =A0 =A0 =A0 if (tx_buf =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;
> +
> + =A0 =A0 =A0 rx_buf =3D usb_buffer_alloc(iphone->udev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPH=
ETH_BUF_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP=
_KERNEL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &rx=
_urb->transfer_dma);
> + =A0 =A0 =A0 if (rx_buf =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;
> +
> +
> + =A0 =A0 =A0 iphone->tx_urb =3D tx_urb;
> + =A0 =A0 =A0 iphone->rx_urb =3D rx_urb;
> + =A0 =A0 =A0 iphone->tx_buf =3D tx_buf;
> + =A0 =A0 =A0 iphone->rx_buf =3D rx_buf;
> + =A0 =A0 =A0 return 0;
> +
> +error:
> + =A0 =A0 =A0 usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, rx_buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_urb->transfer_dma);
> + =A0 =A0 =A0 usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, tx_buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_urb->transfer_dma);
> + =A0 =A0 =A0 usb_free_urb(rx_urb);
> + =A0 =A0 =A0 usb_free_urb(tx_urb);
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> +static void ipheth_free_urbs(struct ipheth_device *iphone)
> +{
> + =A0 =A0 =A0 usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, iphone->=
rx_buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iphone->rx_urb->transfe=
r_dma);
> + =A0 =A0 =A0 usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, iphone->=
tx_buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iphone->tx_urb->transfe=
r_dma);
> + =A0 =A0 =A0 usb_free_urb(iphone->rx_urb);
> + =A0 =A0 =A0 usb_free_urb(iphone->tx_urb);
> +}
> +
> +static void ipheth_kill_urbs(struct ipheth_device *dev)
> +{
> + =A0 =A0 =A0 usb_kill_urb(dev->tx_urb);
> + =A0 =A0 =A0 usb_kill_urb(dev->rx_urb);
> +}
> +
> +static void ipheth_rcvbulk_callback(struct urb *urb)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev;
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 int status;
> + =A0 =A0 =A0 char *buf;
> + =A0 =A0 =A0 int len;
> +
> + =A0 =A0 =A0 dev =3D urb->context;
> + =A0 =A0 =A0 if (dev =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 status =3D urb->status;
> + =A0 =A0 =A0 switch (status) {
> + =A0 =A0 =A0 case -ENOENT:
> + =A0 =A0 =A0 case -ECONNRESET:
> + =A0 =A0 =A0 case -ESHUTDOWN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 case 0:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: urb status: %d", __func__, urb=
->status);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 len =3D urb->actual_length;
> + =A0 =A0 =A0 buf =3D urb->transfer_buffer;
> +
> + =A0 =A0 =A0 skb =3D dev_alloc_skb(NET_IP_ALIGN + len);
> + =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: dev_alloc_skb: -ENOMEM", __fun=
c__);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->net->stats.rx_dropped++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 skb_reserve(skb, NET_IP_ALIGN);
> + =A0 =A0 =A0 memcpy(skb_put(skb, len), buf + NET_IP_ALIGN, len - NET=
_IP_ALIGN);
> + =A0 =A0 =A0 skb->dev =3D dev->net;
> + =A0 =A0 =A0 skb->protocol =3D eth_type_trans(skb, dev->net);
> +
> + =A0 =A0 =A0 dev->net->stats.rx_packets++;
> + =A0 =A0 =A0 dev->net->stats.rx_bytes +=3D len;
> +
> + =A0 =A0 =A0 netif_rx(skb);
> + =A0 =A0 =A0 ipheth_rx_submit(dev, GFP_ATOMIC);
> +}
> +
> +static void ipheth_sndbulk_callback(struct urb *urb)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev;
> +
> + =A0 =A0 =A0 dev =3D urb->context;
> + =A0 =A0 =A0 if (dev =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 if (urb->status !=3D 0 &&
> + =A0 =A0 =A0 =A0 =A0 urb->status !=3D -ENOENT &&
> + =A0 =A0 =A0 =A0 =A0 urb->status !=3D -ECONNRESET &&
> + =A0 =A0 =A0 =A0 =A0 urb->status !=3D -ESHUTDOWN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: urb status: %d", __func__, urb=
->status);
> +
> + =A0 =A0 =A0 dev_kfree_skb_irq(dev->tx_skb);
> + =A0 =A0 =A0 netif_wake_queue(dev->net);
> +}
> +
> +static int ipheth_carrier_set(struct ipheth_device *dev)
> +{
> + =A0 =A0 =A0 struct usb_device *udev =3D dev->udev;
> + =A0 =A0 =A0 int retval;
> +
> + =A0 =A0 =A0 retval =3D usb_control_msg(udev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_rcvctrlpipe(udev, I=
PHETH_CTRL_ENDP),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_CMD_CARRIER_CHEC=
K, /* request */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0xc0, /* request type *=
/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x00, /* value */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x02, /* index */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->ctrl_buf, IPHETH_C=
TRL_BUF_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IPHETH_CTRL_TIMEOUT);
> + =A0 =A0 =A0 if (retval < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: usb_control_msg: %d", __func__=
, retval);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retval;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (dev->ctrl_buf[0] =3D=3D IPHETH_CARRIER_ON)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_on(dev->net);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_off(dev->net);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void ipheth_carrier_check_work(struct work_struct *work)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev =3D container_of(work, struct=
 ipheth_device,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0carrier_work.work);
> +
> + =A0 =A0 =A0 ipheth_carrier_set(dev);
> + =A0 =A0 =A0 schedule_delayed_work(&dev->carrier_work, IPHETH_CARRIE=
R_CHECK_TIMEOUT);
> +}
> +
> +static int ipheth_get_macaddr(struct ipheth_device *dev)
> +{
> + =A0 =A0 =A0 struct usb_device *udev =3D dev->udev;
> + =A0 =A0 =A0 struct net_device *net =3D dev->net;
> + =A0 =A0 =A0 int retval;
> +
> + =A0 =A0 =A0 retval =3D usb_control_msg(udev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0usb_=
rcvctrlpipe(udev, IPHETH_CTRL_ENDP),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IPHE=
TH_CMD_GET_MACADDR, /* request */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00xc0=
, /* request type */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x00=
, /* value */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x02=
, /* index */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev-=
>ctrl_buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IPHE=
TH_CTRL_BUF_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IPHE=
TH_CTRL_TIMEOUT);
> + =A0 =A0 =A0 if (retval < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: usb_control_msg: %d", __func__=
, retval);
> + =A0 =A0 =A0 } else if (retval < ETH_ALEN) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: usb_control_msg: short packet:=
 %d bytes",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, retval);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -EINVAL;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(net->dev_addr, dev->ctrl_buf, ET=
H_ALEN);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return retval;
> +}
> +
> +static int ipheth_rx_submit(struct ipheth_device *dev, gfp_t mem_fla=
gs)
> +{
> + =A0 =A0 =A0 struct usb_device *udev =3D dev->udev;
> + =A0 =A0 =A0 int retval;
> +
> + =A0 =A0 =A0 usb_fill_bulk_urb(dev->rx_urb, udev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_rcvbulkpipe(ude=
v, dev->bulk_in),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->rx_buf, IPHETH=
_BUF_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipheth_rcvbulk_call=
back,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev);
> + =A0 =A0 =A0 dev->rx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MA=
P;
> +
> + =A0 =A0 =A0 retval =3D usb_submit_urb(dev->rx_urb, mem_flags);
> + =A0 =A0 =A0 if (retval)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: usb_submit_urb: %d", __func__,=
 retval);
> + =A0 =A0 =A0 return retval;
> +}
> +
> +static int ipheth_open(struct net_device *net)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev =3D netdev_priv(net);
> + =A0 =A0 =A0 struct usb_device *udev =3D dev->udev;
> + =A0 =A0 =A0 int retval =3D 0;
> +
> + =A0 =A0 =A0 usb_set_interface(udev, IPHETH_INTFNUM, IPHETH_ALT_INTF=
NUM);
> +
> + =A0 =A0 =A0 retval =3D ipheth_carrier_set(dev);
> + =A0 =A0 =A0 if (retval)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retval;
> +
> + =A0 =A0 =A0 retval =3D ipheth_rx_submit(dev, GFP_KERNEL);
> + =A0 =A0 =A0 if (retval)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retval;
> +
> + =A0 =A0 =A0 schedule_delayed_work(&dev->carrier_work, IPHETH_CARRIE=
R_CHECK_TIMEOUT);
> + =A0 =A0 =A0 netif_start_queue(net);
> + =A0 =A0 =A0 return retval;
> +}
> +
> +static int ipheth_close(struct net_device *net)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev =3D netdev_priv(net);
> +
> + =A0 =A0 =A0 cancel_delayed_work_sync(&dev->carrier_work);
> + =A0 =A0 =A0 netif_stop_queue(net);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ipheth_tx(struct sk_buff *skb, struct net_device *net)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev =3D netdev_priv(net);
> + =A0 =A0 =A0 struct usb_device *udev =3D dev->udev;
> + =A0 =A0 =A0 int retval;
> +
> + =A0 =A0 =A0 /* Paranoid */
> + =A0 =A0 =A0 if (skb->len > IPHETH_BUF_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN(1, "%s: skb too large: %d bytes", =
__func__, skb->len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->net->stats.tx_dropped++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb_irq(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_OK;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 memcpy(dev->tx_buf, skb->data, skb->len);
> + =A0 =A0 =A0 if (skb->len < IPHETH_BUF_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(dev->tx_buf + skb->len, 0, IPHET=
H_BUF_SIZE - skb->len);
> +
> + =A0 =A0 =A0 usb_fill_bulk_urb(dev->tx_urb, udev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_sndbulkpipe(ude=
v, dev->bulk_out),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->tx_buf, IPHETH=
_BUF_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipheth_sndbulk_call=
back,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev);
> + =A0 =A0 =A0 dev->tx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MA=
P;
> +
> + =A0 =A0 =A0 retval =3D usb_submit_urb(dev->tx_urb, GFP_ATOMIC);
> + =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("%s: usb_submit_urb: %d", __func__,=
 retval);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->net->stats.tx_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb_irq(skb);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->tx_skb =3D skb;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->net->stats.tx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->net->stats.tx_bytes +=3D skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(net);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NETDEV_TX_OK;
> +}
> +
> +static void ipheth_tx_timeout(struct net_device *net)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev =3D netdev_priv(net);
> +
> + =A0 =A0 =A0 err("%s: TX timeout", __func__);
> + =A0 =A0 =A0 dev->net->stats.tx_errors++;
> + =A0 =A0 =A0 usb_unlink_urb(dev->tx_urb);
> +}
> +
> +static struct net_device_stats *ipheth_stats(struct net_device *net)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev =3D netdev_priv(net);
> + =A0 =A0 =A0 return &dev->net->stats;
> +}
> +
> +static u32 ipheth_ethtool_op_get_link(struct net_device *net)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev =3D netdev_priv(net);
> + =A0 =A0 =A0 return netif_carrier_ok(dev->net);
> +}
> +
> +static struct ethtool_ops ops =3D {
> + =A0 =A0 =A0 .get_link =3D ipheth_ethtool_op_get_link
> +};
> +
> +static const struct net_device_ops ipheth_netdev_ops =3D {
> + =A0 =A0 =A0 .ndo_open =3D &ipheth_open,
> + =A0 =A0 =A0 .ndo_stop =3D &ipheth_close,
> + =A0 =A0 =A0 .ndo_start_xmit =3D &ipheth_tx,
> + =A0 =A0 =A0 .ndo_tx_timeout =3D &ipheth_tx_timeout,
> + =A0 =A0 =A0 .ndo_get_stats =3D &ipheth_stats,
> +};
> +
> +static struct device_type ipheth_type =3D {
> + =A0 =A0 =A0 .name =A0 =3D "wwan",
> +};
> +
> +static int ipheth_probe(struct usb_interface *intf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct usb_device=
_id *id)
> +{
> + =A0 =A0 =A0 struct usb_device *udev =3D interface_to_usbdev(intf);
> + =A0 =A0 =A0 struct usb_host_interface *hintf;
> + =A0 =A0 =A0 struct usb_endpoint_descriptor *endp;
> + =A0 =A0 =A0 struct ipheth_device *dev;
> + =A0 =A0 =A0 struct net_device *netdev;
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 int retval;
> +
> + =A0 =A0 =A0 netdev =3D alloc_etherdev(sizeof(struct ipheth_device))=
;
> + =A0 =A0 =A0 if (!netdev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 netdev->netdev_ops =3D &ipheth_netdev_ops;
> + =A0 =A0 =A0 netdev->watchdog_timeo =3D IPHETH_TX_TIMEOUT;
> + =A0 =A0 =A0 strcpy(netdev->name, "wwan%d");
> +
> + =A0 =A0 =A0 dev =3D netdev_priv(netdev);
> + =A0 =A0 =A0 dev->udev =3D udev;
> + =A0 =A0 =A0 dev->net =3D netdev;
> + =A0 =A0 =A0 dev->intf =3D intf;
> +
> + =A0 =A0 =A0 /* Set up endpoints */
> + =A0 =A0 =A0 hintf =3D usb_altnum_to_altsetting(intf, IPHETH_ALT_INT=
=46NUM);
> + =A0 =A0 =A0 if (hintf =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("Unable to find alternate settings =
interface");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_endpoints;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (i =3D 0; i < hintf->desc.bNumEndpoints; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 endp =3D &hintf->endpoint[i].desc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (usb_endpoint_is_bulk_in(endp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->bulk_in =3D endp->=
bEndpointAddress;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (usb_endpoint_is_bulk_out(endp)=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->bulk_out =3D endp-=
>bEndpointAddress;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (!(dev->bulk_in && dev->bulk_out)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("Unable to find endpoints");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_endpoints;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev->ctrl_buf =3D kmalloc(IPHETH_CTRL_BUF_SIZE, GFP_KER=
NEL);
> + =A0 =A0 =A0 if (dev->ctrl_buf =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_alloc_ctrl_buf;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 retval =3D ipheth_get_macaddr(dev);
> + =A0 =A0 =A0 if (retval)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_get_macaddr;
> +
> + =A0 =A0 =A0 INIT_DELAYED_WORK(&dev->carrier_work, ipheth_carrier_ch=
eck_work);
> +
> + =A0 =A0 =A0 retval =3D ipheth_alloc_urbs(dev);
> + =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("error allocating urbs: %d", retval=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_alloc_urbs;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 usb_set_intfdata(intf, dev);
> +
> + =A0 =A0 =A0 SET_NETDEV_DEV(netdev, &intf->dev);
> + =A0 =A0 =A0 SET_ETHTOOL_OPS(netdev, &ops);
> + =A0 =A0 =A0 SET_NETDEV_DEVTYPE(netdev, &ipheth_type);
> +
> + =A0 =A0 =A0 retval =3D register_netdev(netdev);
> + =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("error registering netdev: %d", ret=
val);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -EIO;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_register_netdev;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev_info(&intf->dev, "Apple iPhone USB Ethernet device =
attached\n");
> + =A0 =A0 =A0 return 0;
> +
> +err_register_netdev:
> + =A0 =A0 =A0 ipheth_free_urbs(dev);
> +err_alloc_urbs:
> +err_get_macaddr:
> +err_alloc_ctrl_buf:
> + =A0 =A0 =A0 kfree(dev->ctrl_buf);
> +err_endpoints:
> + =A0 =A0 =A0 free_netdev(netdev);
> + =A0 =A0 =A0 return retval;
> +}
> +
> +static void ipheth_disconnect(struct usb_interface *intf)
> +{
> + =A0 =A0 =A0 struct ipheth_device *dev;
> +
> + =A0 =A0 =A0 dev =3D usb_get_intfdata(intf);
> + =A0 =A0 =A0 if (dev !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unregister_netdev(dev->net);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipheth_kill_urbs(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipheth_free_urbs(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(dev->ctrl_buf);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_netdev(dev->net);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 usb_set_intfdata(intf, NULL);
> + =A0 =A0 =A0 dev_info(&intf->dev, "Apple iPhone USB Ethernet now dis=
connected\n");
> +}
> +
> +static struct usb_driver ipheth_driver =3D {
> + =A0 =A0 =A0 .name =3D =A0 =A0 =A0 =A0 "ipheth",
> + =A0 =A0 =A0 .probe =3D =A0 =A0 =A0 =A0ipheth_probe,
> + =A0 =A0 =A0 .disconnect =3D =A0 ipheth_disconnect,
> + =A0 =A0 =A0 .id_table =3D =A0 =A0 ipheth_table,
> +};
> +
> +static int __init ipheth_init(void)
> +{
> + =A0 =A0 =A0 int retval;
> +
> + =A0 =A0 =A0 retval =3D usb_register(&ipheth_driver);
> + =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err("usb_register failed: %d", retval);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retval;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void __exit ipheth_exit(void)
> +{
> + =A0 =A0 =A0 usb_deregister(&ipheth_driver);
> +}
> +
> +module_init(ipheth_init);
> +module_exit(ipheth_exit);
> +
> +MODULE_AUTHOR("Diego Giagio <diego@giagio.com>");
> +MODULE_DESCRIPTION("Apple iPhone USB Ethernet driver");
> +MODULE_LICENSE("Dual BSD/GPL");
> --
> 1.7.0
>
>



--=20
Diego Giagio
diego@giagio.com / diego@FreeBSD.org
