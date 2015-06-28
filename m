From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH] cdc_ncm: add support for moving NDP to end of
 frames
Date: Sun, 28 Jun 2015 20:52:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506282049110.1009@localhost.localdomain>
References: <1435475017-661-1-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1435475017-661-1-git-send-email-mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now the code is running all-day in a virtual machine, which unfortunately isn't able to expose the problem.
And with my braille display I am not able to read the output of the panic, when 
it happens, since execution of all the user-space processes isstopped somewhat 
immediately.
The code seems to work pretty well here, and lot of data has been processed so 
far.

On Sun, 28 Jun 2015, Enrico Mioso wrote:

> Date: Sun, 28 Jun 2015 09:03:37
> From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
>     netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Subject: [RFC PATCH] cdc_ncm: add support for moving NDP to end of frames
> 
> This patch adds support for moving the NDP (Network Data Pointer) part of
> an NCM frame to the end of it. This allows newer Huawei devices to work with upstream Linux driver.
> This functionality can be enabled by a cdc_ncm subdriver when binding to a
> device. Hence this patch updates them.
>
> This code works pretty well with an E3372 device I am testing it with.
> The problem is - I observed my patch causing system failures when severe OOM
> conditions are met. I am not sure the problem is cause by my code, but would like to hear from you.
>
> Signed-off-by: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> ---
> drivers/net/usb/cdc_mbim.c       |  2 +-
> drivers/net/usb/cdc_ncm.c        | 51 ++++++++++++++++++++++++++++++++++++----
> drivers/net/usb/huawei_cdc_ncm.c |  7 ++++--
> include/linux/usb/cdc_ncm.h      |  7 +++++-
> 4 files changed, 58 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
> index e4b7a47..efc18e0 100644
> --- a/drivers/net/usb/cdc_mbim.c
> +++ b/drivers/net/usb/cdc_mbim.c
> @@ -158,7 +158,7 @@ static int cdc_mbim_bind(struct usbnet *dev, struct usb_interface *intf)
> 	if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
> 		goto err;
>
> -	ret = cdc_ncm_bind_common(dev, intf, data_altsetting);
> +	ret = cdc_ncm_bind_common(dev, intf, data_altsetting, 0);
> 	if (ret)
> 		goto err;
>
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 8067b8f..60b147f 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -684,10 +684,12 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
> 		ctx->tx_curr_skb = NULL;
> 	}
>
> +	kfree(ctx->delayed_ndp16);
> +
> 	kfree(ctx);
> }
>
> -int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_altsetting)
> +int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_altsetting, int drvflags)
> {
> 	const struct usb_cdc_union_desc *union_desc = NULL;
> 	struct cdc_ncm_ctx *ctx;
> @@ -855,6 +857,17 @@ advance:
> 	/* finish setting up the device specific data */
> 	cdc_ncm_setup(dev);
>
> +	/* Device-specific flags */
> +	ctx->drvflags = drvflags;
> +
> +	/* Allocate the delayed NDP if needed. */
> +	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END) {
> +		ctx->delayed_ndp16 = kzalloc(ctx->max_ndp_size, GFP_ATOMIC);
> +		if (!ctx->delayed_ndp16)
> +			goto error2;
> +		dev_info(&intf->dev, "NDP will be placed at end of frame for this device.");
> +	}
> +
> 	/* override ethtool_ops */
> 	dev->net->ethtool_ops = &cdc_ncm_ethtool_ops;
>
> @@ -954,8 +967,11 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
> 	if (cdc_ncm_select_altsetting(intf) != CDC_NCM_COMM_ALTSETTING_NCM)
> 		return -ENODEV;
>
> -	/* The NCM data altsetting is fixed */
> -	ret = cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM);
> +	/* The NCM data altsetting is fixed, so we hard-coded it.
> +	 * Additionally, generic NCM devices are assumed to accept arbitrarily
> +	 * placed NDP.
> +	 */
> +	ret = cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM, 0);
>
> 	/*
> 	 * We should get an event when network connection is "connected" or
> @@ -986,6 +1002,14 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
> 	struct usb_cdc_ncm_nth16 *nth16 = (void *)skb->data;
> 	size_t ndpoffset = le16_to_cpu(nth16->wNdpIndex);
>
> +	/* If NDP should be moved to the end of the NCM package, we can't follow the
> +	* NTH16 header as we would normally do. NDP isn't written to the SKB yet, and
> +	* the wNdpIndex field in the header is actually not consistent with reality. It will be later.
> +	*/
> +	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END)
> +		if (ctx->delayed_ndp16->dwSignature == sign)
> +			return ctx->delayed_ndp16;
> +
> 	/* follow the chain of NDPs, looking for a match */
> 	while (ndpoffset) {
> 		ndp16 = (struct usb_cdc_ncm_ndp16 *)(skb->data + ndpoffset);
> @@ -995,7 +1019,8 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
> 	}
>
> 	/* align new NDP */
> -	cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
> +	if (!(ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END))
> +		cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
>
> 	/* verify that there is room for the NDP and the datagram (reserve) */
> 	if ((ctx->tx_max - skb->len - reserve) < ctx->max_ndp_size)
> @@ -1008,7 +1033,12 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
> 		nth16->wNdpIndex = cpu_to_le16(skb->len);
>
> 	/* push a new empty NDP */
> -	ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, ctx->max_ndp_size);
> +	if (!(ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END)) {
> +		ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, ctx->max_ndp_size);
> +	} else {
> +		ndp16 = ctx->delayed_ndp16;
> +	}
> +
> 	ndp16->dwSignature = sign;
> 	ndp16->wLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + sizeof(struct usb_cdc_ncm_dpe16));
> 	return ndp16;
> @@ -1150,6 +1180,17 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
> 		/* variables will be reset at next call */
> 	}
>
> +	/* If requested, put NDP at end of frame. */
> +	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END) {
> +		nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
> +		cdc_ncm_align_tail(skb_out, ctx->tx_ndp_modulus, 0, ctx->tx_max);
> +		nth16->wNdpIndex = cpu_to_le16(skb_out->len);
> +		ndp16 = memcpy(skb_put(skb_out, ctx->max_ndp_size), ctx->delayed_ndp16, ctx->max_ndp_size);
> +
> +		/* Zero out delayed NDP - signature checking will naturally fail. */
> +		memset(ctx->delayed_ndp16, 0, ctx->max_ndp_size);
> +	}
> +
> 	/* If collected data size is less or equal ctx->min_tx_pkt
> 	 * bytes, we send buffers as it is. If we get more data, it
> 	 * would be more efficient for USB HS mobile device with DMA
> diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_cdc_ncm.c
> index 735f7da..2680a65 100644
> --- a/drivers/net/usb/huawei_cdc_ncm.c
> +++ b/drivers/net/usb/huawei_cdc_ncm.c
> @@ -73,11 +73,14 @@ static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev,
> 	struct usb_driver *subdriver = ERR_PTR(-ENODEV);
> 	int ret = -ENODEV;
> 	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
> +	int drvflags = 0;
>
> 	/* altsetting should always be 1 for NCM devices - so we hard-coded
> -	 * it here
> +	 * it here. Some huawei devices will need the NDP part of the NCM package to
> +	 * be at the end of the frame.
> 	 */
> -	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1);
> +	drvflags |= CDC_NCM_FLAG_NDP_TO_END;
> +	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1, drvflags);
> 	if (ret)
> 		goto err;
>
> diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
> index 7c9b484..1f6526c 100644
> --- a/include/linux/usb/cdc_ncm.h
> +++ b/include/linux/usb/cdc_ncm.h
> @@ -80,6 +80,9 @@
> #define CDC_NCM_TIMER_INTERVAL_MIN		5UL
> #define CDC_NCM_TIMER_INTERVAL_MAX		(U32_MAX / NSEC_PER_USEC)
>
> +/* Driver flags */
> +#define CDC_NCM_FLAG_NDP_TO_END	0x02		/* NDP is placed at end of frame */
> +
> #define cdc_ncm_comm_intf_is_mbim(x)  ((x)->desc.bInterfaceSubClass == USB_CDC_SUBCLASS_MBIM && \
> 				       (x)->desc.bInterfaceProtocol == USB_CDC_PROTO_NONE)
> #define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol == USB_CDC_MBIM_PROTO_NTB)
> @@ -103,9 +106,11 @@ struct cdc_ncm_ctx {
>
> 	spinlock_t mtx;
> 	atomic_t stop;
> +	int drvflags;
>
> 	u32 timer_interval;
> 	u32 max_ndp_size;
> +	struct usb_cdc_ncm_ndp16 *delayed_ndp16;
>
> 	u32 tx_timer_pending;
> 	u32 tx_curr_frame_num;
> @@ -133,7 +138,7 @@ struct cdc_ncm_ctx {
> };
>
> u8 cdc_ncm_select_altsetting(struct usb_interface *intf);
> -int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_altsetting);
> +int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_altsetting, int drvflags);
> void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
> struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign);
> int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in);
> -- 
> 2.4.4
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
