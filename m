From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: Add driver for esd CAN-USB/2 device
Date: Sun, 25 Apr 2010 12:53:36 +0200
Message-ID: <4BD41F30.3060201@grandegger.com>
References: <201004231015.16751.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: Matthias Fuchs <matthias.fuchs@esd.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:45724 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab0DYKzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 06:55:44 -0400
In-Reply-To: <201004231015.16751.matthias.fuchs@esd.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matthias,

Matthias Fuchs wrote:
> This patch adds a driver for esd's USB high speed
> CAN interface. The driver supports devices with
> multiple CAN interfaces.
> 
> Signed-off-by: Matthias Fuchs <matthias.fuchs@esd.eu>

Could you please add support for the recently added feature:

  commit 52c793f24054f5dc30d228e37e0e19cc8313f086
  Author: Wolfgang Grandegger <wg@grandegger.com>
  Date:   Mon Feb 22 22:21:17 2010 +0000

    can: netlink support for bus-error reporting and counters
    
    This patch makes the bus-error reporting configurable and allows to
    retrieve the CAN TX and RX bus error counters via netlink interface.
    I have added support for the SJA1000. The TX and RX bus error counters
    are also copied to the data fields 6..7 of error messages when state
    changes are reported.

Should not be a big deal. Also, please make a CC to the USB Linux
mailing list. Some minor comments below:

> ---
>  drivers/net/can/usb/Kconfig    |    6 +
>  drivers/net/can/usb/Makefile   |    1 +
>  drivers/net/can/usb/esd_usb2.c | 1107 ++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1114 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/usb/esd_usb2.c
> 
...
> diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
> new file mode 100644
> index 0000000..c714ce9
> --- /dev/null
> +++ b/drivers/net/can/usb/esd_usb2.c
...
> +struct id_filter_msg {
> +	u8 len;
> +	u8 cmd;
> +	u8 net;
> +	u8 option;
> +	__le32 mask[65];

ESD_MAX_ID_SEGMENT + 1 ?

...
> +static netdev_tx_t esd_usb2_start_xmit(struct sk_buff *skb,
> +				      struct net_device *netdev)
> +{
> +	struct esd_usb2_net_priv *priv = netdev_priv(netdev);
> +	struct esd_usb2 *dev = priv->usb2;
> +	struct esd_tx_urb_context *context = NULL;
> +	struct net_device_stats *stats = &netdev->stats;
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	struct esd_usb2_msg *msg;
> +	struct urb *urb;
> +	u8 *buf;
> +	int i, err;
> +	int ret = NETDEV_TX_OK;
> +	size_t size = sizeof(struct esd_usb2_msg);
> +
> +	if (can_dropped_invalid_skb(netdev, skb))
> +		return NETDEV_TX_OK;
> +
> +	/* create a URB, and a buffer for it, and copy the data to the URB */
> +	urb = usb_alloc_urb(0, GFP_ATOMIC);
> +	if (!urb) {
> +		dev_err(netdev->dev.parent, "No memory left for URBs\n");
> +		stats->tx_dropped++;
> +		dev_kfree_skb(skb);
> +		goto nourbmem;
> +	}
> +
> +	buf = usb_buffer_alloc(dev->udev, size, GFP_ATOMIC, &urb->transfer_dma);
> +	if (!buf) {
> +		dev_err(netdev->dev.parent, "No memory left for USB buffer\n");
> +		stats->tx_dropped++;
> +		dev_kfree_skb(skb);
> +		goto nobufmem;
> +	}
> +
> +	msg = (struct esd_usb2_msg *)buf;
> +
> +	msg->msg.hdr.len = 3; /* minimal length */
> +	msg->msg.hdr.cmd = CMD_CAN_TX;
> +	msg->msg.tx.net = priv->index;
> +	msg->msg.tx.dlc = cf->can_dlc;
> +	msg->msg.tx.id = cpu_to_le32(cf->can_id & CAN_ERR_MASK);
> +
> +	if (cf->can_id & CAN_RTR_FLAG)
> +		msg->msg.tx.dlc |= ESD_RTR;
> +
> +	if (cf->can_id & CAN_EFF_FLAG)
> +		msg->msg.tx.id |= cpu_to_le32(ESD_EXTID);
> +
> +	for (i = 0; i < cf->can_dlc; i++)
> +		msg->msg.tx.data[i] = cf->data[i];
> +
> +	msg->msg.hdr.len += (cf->can_dlc + 3) >> 2;
> +
> +	for (i = 0; i < MAX_TX_URBS; i++) {
> +		if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
> +			context = &priv->tx_contexts[i];
> +			break;
> +		}
> +	}
> +
> +	/*
> +	 * This may never happen.
> +	 */
> +	if (!context) {
> +		dev_warn(netdev->dev.parent, "couldn't find free context\n");
> +		ret = NETDEV_TX_BUSY;
> +		goto releasebuf;
> +	}
> +
> +	context->priv = priv;
> +	context->echo_index = i;
> +	context->dlc = cf->can_dlc;
> +
> +	/* hnd must not be 0 */
> +	msg->msg.tx.hnd = 0x80000000 | i; /* returned in TX done message */

ESD_USB2_UBR ?

Wolfgang.
