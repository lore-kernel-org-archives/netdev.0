From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Wed, 18 Sep 2013 15:59:09 +0200
Message-ID: <878uyu6xjm.fsf@nemi.mork.no>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54062 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671Ab3IRN71 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 09:59:27 -0400
In-Reply-To: <1379409002-7698-1-git-send-email-ming.lei@canonical.com> (Ming
	Lei's message of "Tue, 17 Sep 2013 17:10:02 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:

> Commit 638c5115a7949(USBNET: support DMA SG) introduces DMA SG
> if the usb host controller is capable of building packet from
> discontinuous buffers, but missed handling padding packet when
> building DMA SG.
>
> This patch attachs the pre-allocated padding packet at the
> end of the sg list, so padding packet can be sent to device
> if drivers require that.
>
> Reported-by: David Laight <David.Laight@aculab.com>
> Cc: Oliver Neukum <oliver@neukum.org>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/net/usb/usbnet.c   |   27 +++++++++++++++++++++------
>  include/linux/usb/usbnet.h |    1 +
>  2 files changed, 22 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 7b331e6..4a9bed3 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1241,7 +1241,9 @@ static int build_dma_sg(const struct sk_buff *s=
kb, struct urb *urb)
>  	if (num_sgs =3D=3D 1)
>  		return 0;
> =20
> -	urb->sg =3D kmalloc(num_sgs * sizeof(struct scatterlist), GFP_ATOMI=
C);
> +	/* reserve one for zero packet */
> +	urb->sg =3D kmalloc((num_sgs + 1) * sizeof(struct scatterlist),
> +			  GFP_ATOMIC);
>  	if (!urb->sg)
>  		return -ENOMEM;
> =20
> @@ -1305,7 +1307,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *=
skb,
>  		if (build_dma_sg(skb, urb) < 0)
>  			goto drop;
>  	}
> -	entry->length =3D length =3D urb->transfer_buffer_length;
> +	length =3D urb->transfer_buffer_length;
> =20
>  	/* don't assume the hardware handles USB_ZERO_PACKET
>  	 * NOTE:  strictly conforming cdc-ether devices should expect
> @@ -1317,15 +1319,18 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff=
 *skb,
>  	if (length % dev->maxpacket =3D=3D 0) {
>  		if (!(info->flags & FLAG_SEND_ZLP)) {
>  			if (!(info->flags & FLAG_MULTI_PACKET)) {
> -				urb->transfer_buffer_length++;
> -				if (skb_tailroom(skb)) {
> +				length++;
> +				if (skb_tailroom(skb) && !dev->can_dma_sg) {
>  					skb->data[skb->len] =3D 0;
>  					__skb_put(skb, 1);
> -				}
> +				} else if (dev->can_dma_sg)
> +					sg_set_buf(&urb->sg[urb->num_sgs++],
> +							dev->padding_pkt, 1);
>  			}
>  		} else
>  			urb->transfer_flags |=3D URB_ZERO_PACKET;
>  	}
> +	entry->length =3D urb->transfer_buffer_length =3D length;
> =20
>  	spin_lock_irqsave(&dev->txq.lock, flags);
>  	retval =3D usb_autopm_get_interface_async(dev->intf);
> @@ -1509,6 +1514,7 @@ void usbnet_disconnect (struct usb_interface *i=
ntf)
> =20
>  	usb_kill_urb(dev->interrupt);
>  	usb_free_urb(dev->interrupt);
> +	kfree(dev->padding_pkt);
> =20
>  	free_netdev(net);
>  }
> @@ -1679,9 +1685,16 @@ usbnet_probe (struct usb_interface *udev, cons=
t struct usb_device_id *prod)
>  	/* initialize max rx_qlen and tx_qlen */
>  	usbnet_update_max_qlen(dev);
> =20
> +	if (dev->can_dma_sg && !(info->flags & FLAG_SEND_ZLP) &&
> +		!(info->flags & FLAG_MULTI_PACKET)) {
> +		dev->padding_pkt =3D kzalloc(1, GFP_KERNEL);
> +		if (!dev->padding_pkt)
> +			goto out4;
> +	}
> +
>  	status =3D register_netdev (net);
>  	if (status)
> -		goto out4;
> +		goto out5;
>  	netif_info(dev, probe, dev->net,
>  		   "register '%s' at usb-%s-%s, %s, %pM\n",
>  		   udev->dev.driver->name,
> @@ -1699,6 +1712,8 @@ usbnet_probe (struct usb_interface *udev, const=
 struct usb_device_id *prod)
> =20
>  	return 0;
> =20
> +out5:
> +	kfree(dev->padding_pkt);
>  out4:
>  	usb_free_urb(dev->interrupt);
>  out3:
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index 9cb2fe8..e303eef 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -42,6 +42,7 @@ struct usbnet {
>  	struct usb_host_endpoint *status;
>  	unsigned		maxpacket;
>  	struct timer_list	delay;
> +	const char		*padding_pkt;
> =20
>  	/* protocol/interface state */
>  	struct net_device	*net;


The code handling the frame padding was already unecessarily complex
IMHO, and this does not improve it...

Are you really sure that the one driver/device using this really need
the padding byte?  If you could just make FLAG_SEND_ZLP part of the
condition for enabling can_dma_sg, then all this extra complexity would
be unnecessary.  As the comment in front of the padding code says:

  "strictly conforming cdc-ether devices should expect the ZLP here"

There shouldn't be any problems requiring this conformance as a
precondition for allowing SG.  The requirements are already strict.


I also believe it would be nice to move the initialisation of can_dma_s=
g
away from the minidriver and into usbnet_probe.  It's confusing that
this field is used "uninitialized" (well, defaulting to zero) in all bu=
t
one minidriver.  It would much nicer if the logic was more like

usbnet_probe:
 if (...)
    dev->can_dma_sg =3D 1;

minidriver_bind:
  if (dev->can_dma_sg) {
     dev->net->features |=3D NETIF_F_SG | NETIF_F_TSO;
     dev->net->hw_features |=3D NETIF_F_SG | NETIF_F_TSO;
  }

usbnet_start_xmit:
 if (skb_shinfo(skb)->nr_frags) {
    ...
 }

This would create a natural flow of events, where probing sets the
capability, minidriver enables features based on capability, and xmit
just does what it has to do based on the skb it was given.

Or maybe even better: factor out common parts of usbnet_start_xmit and
create two versions of it - one using SG and one linear.  The per packe=
t
testing seems unnecessary expensive and complex given that the choice i=
s
made during device initialization anyway.  You could easily replace the
whole can_dma_sg stuff with a simple=20

 if (...)
	net->netdev_ops =3D &usbnet_sg_netdev_ops;
 else
	net->netdev_ops =3D &usbnet_netdev_ops;


in usbnet_probe.  But I guess the same can be said about the info->flag=
s
testing in usbnet_start_xmit...

Just a few random thougths.  I don't really feel strongly about any of
this, except that I would prefer usbnet becoming *more* readable instea=
d
of less...


Bj=C3=B8rn
