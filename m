From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
Date: Thu, 25 Jun 2015 11:49:29 +0200
Message-ID: <1435225769.28594.13.camel@suse.com>
References: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com>
	 <1435012335-6055-3-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1435012335-6055-3-git-send-email-mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-06-23 at 00:32 +0200, Enrico Mioso wrote:
> This patch introduces a new NCM tx engine, able to operate in standard-
> and huawei-style mode.
> In the first case, the NDP is disposed after the initial headers and
> before any datagram.
> 
> What works:
> - is able to communicate with compliant NCM devices:
> 	I tested this with a board running the Linux g_ncm gadget driver.
> 
> What doesn't work:
> - After some packets I start gettint LOTS of EVENT_RX_MEMORY from usbnet,
> 	which fails to allocate an RX SKB in rx_submit(). Don't understand why,
> 	any suggestion would be very welcome.
> 
> The tx_fixup function given here, even if actually working, should be
> considered as an example: the NCM manager is used here simulating the
> cdc_ncm.c behaviour.
> 
> Signed-off-by: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/usb/huawei_cdc_ncm.c | 187 ++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 185 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_cdc_ncm.c
> index 735f7da..217802a 100644
> --- a/drivers/net/usb/huawei_cdc_ncm.c
> +++ b/drivers/net/usb/huawei_cdc_ncm.c
> @@ -29,6 +29,35 @@
>  #include <linux/usb/cdc-wdm.h>
>  #include <linux/usb/cdc_ncm.h>
>  
> +/* NCM management operations: */
> +
> +/* NCM_INIT_FRAME: prepare for a new frame.
> + * NTH16 header is written to output SKB, NDP data is reset and last
> + * committed NDP pointer set to NULL.
> + * Now, data may be added to this NCM package.
> + */
> +#define NCM_INIT_FRAME		1
> +
> +/* NCM_UPDATE_NDP: adds data to an NDP structure, hence updating it.
> + * Some checks are performed to be sure data fits in, respecting device and
> + * spec constrains.
> + * Normally the NDP is kept in memory and committed to the SKB only when
> + * requested. However, calling this "method" after NCM_COMMIT_NDP, causes it to
> + * work directly on the already committed SKB copy. this allows for flexibility
> + * in frame ordering.
> + */
> +#define NCM_UPDATE_NDP		2
> +
> +/* Write NDP: commits NDP to output SKB.
> + * This method should be called only once per frame.
> + */
> +#define NCM_COMMIT_NDP		3
> +
> +/* Finalizes NTH16 header: to be called when working in
> + * update-already-committed mode.
> + */
> +#define NCM_FINALIZE_NTH	5
> +
>  /* Driver data */
>  struct huawei_cdc_ncm_state {
>  	struct cdc_ncm_ctx *ctx;
> @@ -36,6 +65,16 @@ struct huawei_cdc_ncm_state {
>  	struct usb_driver *subdriver;
>  	struct usb_interface *control;
>  	struct usb_interface *data;
> +
> +	/* Keeps track of where data starts and ends in SKBs. */
> +	int data_start;
> +	int data_len;
> +
> +	/* Last committed NDP for post-commit operations. */
> +	struct usb_cdc_ncm_ndp16 *skb_ndp;
> +
> +	/* Non-committed NDP */
> +	struct usb_cdc_ncm_ndp16 *ndp;
>  };
>  
>  static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, int on)
> @@ -53,6 +92,149 @@ static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, int on)
>  	return 0;
>  }
>  
> +/* huawei_ncm_mgmt: flexible TX NCM manager.
> + *
> + * Once a non-zero status value is rturned, current frame should be discarded
> + * and operations restarted from scratch.
> + */

Is there any advantage in keeping this in a single function?

> +int
> +huawei_ncm_mgmt(struct usbnet *dev,
> +		struct huawei_cdc_ncm_state *drvstate, struct sk_buff *skb_out, int mode) {
> +	struct usb_cdc_ncm_nth16 *nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
> +	struct cdc_ncm_ctx *ctx = drvstate->ctx;
> +	struct usb_cdc_ncm_ndp16 *ndp16 = NULL;
> +	int ret = -EINVAL;
> +	u16 ndplen, index;
> +
> +	switch (mode) {
> +	case NCM_INIT_FRAME:
> +
> +		/* Write a new NTH16 header */
> +		nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
> +		if (!nth16) {
> +			ret = -EINVAL;
> +			goto error;
> +		}
> +
> +		/* NTH16 signature and header length are known a-priori. */
> +		nth16->dwSignature = cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
> +		nth16->wHeaderLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16));
> +
> +		/* TX sequence numbering */
> +		nth16->wSequence = cpu_to_le16(ctx->tx_seq++);
> +
> +		/* Forget about previous SKB NDP */
> +		drvstate->skb_ndp = NULL;

This is probably better done after you know you cannot fail.

> +
> +		/* Allocate a new NDP */
> +		ndp16 = kzalloc(ctx->max_ndp_size, GFP_NOIO);

Where is this freed?

> +		if (!ndp16)
> +			return ret;
> +
> +		/* Prepare a new NDP to add data on subsequent calls. */
> +		drvstate->ndp = memset(ndp16, 0, ctx->max_ndp_size);

Either kzalloc() or memset(). Using both never makes sense.

> +
> +		/* Initial NDP length */
> +		ndp16->wLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + sizeof(struct usb_cdc_ncm_dpe16));
> +
> +		/* Frame signature: to be reworked in general. */
> +			ndp16->dwSignature = cpu_to_le32(USB_CDC_NCM_NDP16_NOCRC_SIGN);
> +
> +			ret = 0;
> +			break;
> +
> +	case NCM_UPDATE_NDP:
> +
> +		if (drvstate->skb_ndp) {
> +			ndp16 = drvstate->skb_ndp;
> +		} else {
> +			ndp16 = drvstate->ndp;
> +
> +			/* Do we have enough space for the data? */
> +			if (skb_out->len + ctx->max_ndp_size > ctx->tx_max)
> +				goto error;
> +		}
> +
> +		/* Calculate frame number within this NDP */
> +		ndplen = le16_to_cpu(ndp16->wLength);
> +		index = (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struct usb_cdc_ncm_dpe16) - 1;
> +
> +		if (index >= CDC_NCM_DPT_DATAGRAMS_MAX)
> +			goto error;
> +
> +		/* tx_max shouldn't be exceeded after committing. */
> +		if (ndplen + sizeof(struct usb_cdc_ncm_dpe16) > ctx->tx_max)
> +				goto error;
> +
> +		/* Adding a DPT entry. */
> +		ndp16->dpe16[index].wDatagramLength = cpu_to_le16(drvstate->data_len);
> +		ndp16->dpe16[index].wDatagramIndex = cpu_to_le16(drvstate->data_start);
> +		ndp16->wLength = cpu_to_le16(ndplen + sizeof(struct usb_cdc_ncm_dpe16));
> +
> +		ret = 0;
> +		break;
> +
> +	case NCM_COMMIT_NDP:
> +
> +		if (drvstate->skb_ndp)
> +			goto error;	/* Call this only once please. */
> +
> +		ndp16 = drvstate->ndp;
> +
> +		nth16->wNdpIndex = cpu_to_le16(skb_out->len);
> +
> +		/* "commit" NDP */
> +		drvstate->skb_ndp = memcpy(skb_put(skb_out, ctx->max_ndp_size), ndp16, ctx->max_ndp_size);
> +
> +		kfree(ndp16);
> +		ndp16 = NULL;
> +		drvstate->ndp = NULL;
> +
> +	case NCM_FINALIZE_NTH:
> +
> +		/* Finalize NTH16 header, setting it's block length */
> +		nth16->wBlockLength = cpu_to_le16(skb_out->len);
> +
> +		ret = 0;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +error:

The purpose of a label is kind of defeated by having a conditional after
it.

> +	if (ret)
> +		kfree(drvstate->ndp);
> +	return ret;
> +}

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
