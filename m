From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Subject: Re: [Resend][PATCH] usb driver for intellon int51x1 based PLC like
      devolo dlan duo
Date: Sat, 18 Apr 2009 13:37:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904181311470.3600@wrl-59.cs.helsinki.fi>
References: <cb6d2886e87af66d945f1052e6eb8a85.squirrel@webmail.it-technology.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Holik <peter-xHLhtm3VSFg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cb6d2886e87af66d945f1052e6eb8a85.squirrel-2RFepEojUI1IVnL2akGZhTp0pij5GnPV@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 18 Apr 2009, Peter Holik wrote:

> This is a usb driver for the intellon int51x1 based PLC
> (Powerline Communications) like devolo dlan duo.
> 
> Signed-off-by: Peter Holik <peter-xHLhtm3VSFg@public.gmane.org>
> ---
>  drivers/net/usb/Kconfig   |    8 ++
>  drivers/net/usb/Makefile  |    1 +
>  drivers/net/usb/int51x1.c |  268 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 277 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/usb/int51x1.c
> 
> diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
> new file mode 100644
> index 0000000..44a8a09
> --- /dev/null
> +++ b/drivers/net/usb/int51x1.c
> @@ -0,0 +1,268 @@

> +static int int51x1_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> +{
> +	int len;
> +
> +	if (unlikely(skb->len < INT51X1_HEADER_SIZE)) {

pskb_may_pull(...)

> +		deverr(dev, "unexpected tiny rx frame");
> +		return 0;
> +	}
> +
> +	len = le16_to_cpu(*(__le16 *)&skb->data[skb->len - 2]);
> +
> +	skb_trim(skb, len);
> +
> +	return 1;
> +}
> +
> +static struct sk_buff *int51x1_tx_fixup(struct usbnet *dev,
> +		struct sk_buff *skb, gfp_t flags)
> +{
> +	int pack_len = skb->len;
> +	int headroom = skb_headroom(skb);
> +	int tailroom = skb_tailroom(skb);
> +	int need_tail = 0;
> +	__le16 *len;
> +
> +	/*
> +	 * usbnet would send a ZLP if packetlength mod urbsize == 0 for us,
> +	 * but we need to know ourself, because this would add to the length
> +	 * we send down to the device...
> +	 */
> +	if (!((pack_len + INT51X1_HEADER_SIZE) % dev->maxpacket))
> +		need_tail = 1;
> +
> +	/* if packet and our header is smaler than 64 pad to 64 (+ ZLP) */
> +	if ((pack_len + INT51X1_HEADER_SIZE + need_tail) < dev->maxpacket + 1)
> +		need_tail = dev->maxpacket + 1 - pack_len - INT51X1_HEADER_SIZE;

This is totally crazy code fragment, first need_tail is used like a 
boolean? But on the same some +1 scalar trick is being done? Is there some 
reason why DIV_ROUND_UP (linux/kernel.h) won't do what you want here and 
then you can trivally find diff = new - old ?

> +	if (!skb_cloned(skb) &&
> +			(headroom + tailroom >= need_tail + INT51X1_HEADER_SIZE)) {
> +		if (headroom < INT51X1_HEADER_SIZE || tailroom < need_tail) {
> +			skb->data = memmove(skb->head + INT51X1_HEADER_SIZE,
> +					skb->data, skb->len);
> +			skb_set_tail_pointer(skb, skb->len);
> +		}
> +	} else {
> +		struct sk_buff *skb2;
> +
> +		skb2 = skb_copy_expand(skb,
> +				INT51X1_HEADER_SIZE,
> +				need_tail,
> +				flags);
> +		dev_kfree_skb_any(skb);
> +		if (!skb2)
> +			return NULL;
> +		skb = skb2;
> +	}
> +
> +	pack_len += need_tail;
> +	pack_len &= 0x07ff;
> +
> +	len = (__le16 *) __skb_push(skb, INT51X1_HEADER_SIZE);
> +	*len = cpu_to_le16(pack_len);
> +
> +	if(need_tail)
> +		memset(__skb_put(skb, need_tail), 0, need_tail);
> +
> +	return skb;
> +}
> +
> +static void int51x1_async_cmd_callback(struct urb *urb)
> +{
> +	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
> +	int status = urb->status;
> +
> +	if (status < 0)
> +		dev_warn(&urb->dev->dev, "async callback failed with %d\n", status);
> +
> +	kfree(req);
> +	usb_free_urb(urb);
> +}
> +
> +static void int51x1_set_multicast(struct net_device *netdev)
> +{
> +	struct usb_ctrlrequest *req;
> +	int status;
> +	struct urb *urb;
> +	struct usbnet *dev = netdev_priv(netdev);
> +	u16 filter = PACKET_TYPE_DIRECTED |
> +		     PACKET_TYPE_BROADCAST;

Won't this fit on a single line?

> +
> +	if (netdev->flags & IFF_PROMISC) {
> +		/* do not expect to see traffic of other PLCs */
> +		filter |= PACKET_TYPE_PROMISCUOUS;
> +		devinfo(dev, "promiscuous mode enabled");
> +	} else if (netdev->mc_count ||
> +		  (netdev->flags & IFF_ALLMULTI)) {
> +		filter |= PACKET_TYPE_ALL_MULTICAST;
> +		devdbg(dev, "receive all multicast enabled");
> +	} else {
> +		/* ~PROMISCUOUS, ~MULTICAST */
> +		devdbg(dev, "receive own packets only");
> +	}
> +
> +	urb = usb_alloc_urb(0, GFP_ATOMIC);
> +	if (!urb) {
> +		devwarn(dev, "Error allocating URB");
> +		return;
> +	}
> +
> +	req = kmalloc(sizeof *req, GFP_ATOMIC);

sizeof(*req)

> +	if (!req) {
> +		devwarn(dev, "Error allocating control msg");
> +		usb_free_urb(urb);
> +		return;

I'd use gotos instead for error handling since you need similar call in 
the later error handling block too. Gotos make it somewhat harder to miss 
some necessary rollback actions in one of the error blocks (not that 
this case is buggy atm).

> +	}
> +
> +	req->bRequestType = USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE;
> +	req->bRequest = SET_ETHERNET_PACKET_FILTER;
> +	req->wValue = cpu_to_le16(filter);
> +	req->wIndex = 0;
> +	req->wLength = 0;
> +
> +	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
> +		(void *)req, NULL, 0,
> +		int51x1_async_cmd_callback,
> +		(void *)req);
> +
> +	status = usb_submit_urb(urb, GFP_ATOMIC);
> +	if (status < 0) {
> +		devwarn(dev, "Error submitting control msg, sts=%d", status);
> +		kfree(req);
> +		usb_free_urb(urb);

Ditto.

> +	}
> +}

-- 
 i.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
