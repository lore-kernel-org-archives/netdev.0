From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [RFC PATCH] cdc_ncm: support moving the NDP part of the frame
 to the end of NCM package
Date: Tue, 9 Jun 2015 09:46:54 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506090933410.2290@localhost.localdomain>
References: <1433760296-18543-1-git-send-email-mrkiko.rs@gmail.com> <1433760803.8770.16.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:33625 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbbFIHq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 03:46:58 -0400
Received: by wgez8 with SMTP id z8so6359420wge.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 00:46:56 -0700 (PDT)
In-Reply-To: <1433760803.8770.16.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all - thank you for your patience and time reading this message, 
reviewing my code.


On Mon, 8 Jun 2015, Oliver Neukum wrote:

==Date: Mon, 8 Jun 2015 12:53:23
==From: Oliver Neukum <oneukum@suse.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: netdev@vger.kernel.org
==Subject: Re: [RFC PATCH] cdc_ncm: support moving the NDP part of the frame to
==    the end of NCM package
==
==On Mon, 2015-06-08 at 12:44 +0200, Enrico Mioso wrote:
==> The NCM specification as per
==> http://www.usb.org/developers/docs/devclass_docs/NCM10_012011.zip
==> does not define a fixed position for different frame parts.
==> The NCM header is effectively the head of a list of NDPs (NCM datagram
==> pointers), each of them pointing to a set of ethernet frames.
==> In general, the NDP can be anywhere after the header.
==> Some devices however are not quite respecting the specs - as they mandate
==> the NDP pointers to be after the payload, at the end of the NCM package.
==> This patch aims to support this scenario, introducing a module parameter
==> enabling this funcitonality.
==> 
==> Is this approach acceptable?
==> 
==> What does work:
==> - the module compiles, and seems to cause no crash
==> What doesn't:
==> - the device for now will ignore our frames
==
==Why?

I will need to look trought wireshark to understand things better I think - and 
I will do so once I get che chance. However, I think I am probably misaligning 
frames and missing to set properly NDP indexes. Any suggestion on this is 
welcome / appreciated.
==
==> - I would need some guidance on flags to use with kzalloc.
==
==Probably GFP_NOIO if you run NFS over it, but that raises
==a question.
==
==> thank you for the patience, and the review.
==> 
==> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
==> ---
==>  drivers/net/usb/cdc_ncm.c   | 30 ++++++++++++++++++++++++++++--
==>  include/linux/usb/cdc_ncm.h |  1 +
==>  2 files changed, 29 insertions(+), 2 deletions(-)
==> 
==> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
==> index 8067b8f..a6d0666b 100644
==> --- a/drivers/net/usb/cdc_ncm.c
==> +++ b/drivers/net/usb/cdc_ncm.c
==> @@ -60,6 +60,10 @@ static bool prefer_mbim;
==>  module_param(prefer_mbim, bool, S_IRUGO | S_IWUSR);
==>  MODULE_PARM_DESC(prefer_mbim, "Prefer MBIM setting on dual NCM/MBIM functions");
==>  
==> +static bool move_ndp_to_end;
==> +module_param(move_ndp_to_end, bool, S_IRUGO | S_IWUSR);
==> +MODULE_PARM_DESC(move_ndp_to_end, "Move NDP block to the end of the NCM aggregate");
==
==Not another parameter please. If the alternate frames are processed as
==well as the current frames, all is well and we can generally produces
==such frames. If not, we want a black list.

I would agree on this point: and I was exploring different alternatives also, 
such as having this option settable when invoking cdc_ncm_bind_common from
huawei_cdc_ncm for example. Unfortunately, I don't feel confident we could do 
that.
First of all: this driver supports more devices than Huawei ones, so I feel we 
have chances to break them modifying the frame structure.
Even more complicated is the fact that huawei NCM devices are not easily 
distinguishable one another from the driver perspective. Some heuristics may be 
put in place probably, but I don't have access to old enough NCM devices to 
know best.
The Huawei vendor driver put NDPs at end of frame - and does so for all devices 
in my opinion, but I can't be really sure about that.
Not now. Anyway I can change this as desired. Would something like a sysfs knob 
be preferable? User-space surely has a good chance to tell us what to do here.
==
==> +
==>  static void cdc_ncm_txpath_bh(unsigned long param);
==>  static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
==>  static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
==> @@ -684,6 +688,8 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
==>  		ctx->tx_curr_skb = NULL;
==>  	}
==>  
==> +	kfree(ctx->delayed_ndp);
==> +
==>  	kfree(ctx);
==>  }
==>  
==> @@ -994,6 +1000,9 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
==>  		ndpoffset = le16_to_cpu(ndp16->wNextNdpIndex);
==>  	}
==>  
==> +	if ((move_ndp_to_end) && (ctx->delayed_ndp->dwSignature == sign))
==> +		return ndp16;
==> +
==>  	/* align new NDP */
==>  	cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
==>  
==> @@ -1008,7 +1017,13 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
==>  		nth16->wNdpIndex = cpu_to_le16(skb->len);
==>  
==>  	/* push a new empty NDP */
==> -	ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, ctx->max_ndp_size);
==> +	if (!move_ndp_to_end) {
==> +		ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, ctx->max_ndp_size);
==> +	} else {
==> +		ndp16 = kzalloc(sizeof(*ndp16), GFP_KERNEL);
==> +		ctx->delayed_ndp = ndp16;
==> +	}
==> +
==>  	ndp16->dwSignature = sign;
==>  	ndp16->wLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + sizeof(struct usb_cdc_ncm_dpe16));
==>  	return ndp16;
==> @@ -1023,6 +1038,8 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
==>  	struct sk_buff *skb_out;
==>  	u16 n = 0, index, ndplen;
==>  	u8 ready2send = 0;
==> +	unsigned int skb_prev_len;
==> +	char *delayed_alloc_ptr;
==>  
==>  	/* if there is a remaining skb, it gets priority */
==>  	if (skb != NULL) {
==> @@ -1074,7 +1091,8 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
==>  		ndp16 = cdc_ncm_ndp(ctx, skb_out, sign, skb->len + ctx->tx_modulus + ctx->tx_remainder);
==>  
==>  		/* align beginning of next frame */
==> -		cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_max);
==> +		if (!move_ndp_to_end)
==> +			cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_max);
==>  
==>  		/* check if we had enough room left for both NDP and frame */
==>  		if (!ndp16 || skb_out->len + skb->len > ctx->tx_max) {
==> @@ -1111,6 +1129,14 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
==>  		dev_kfree_skb_any(skb);
==>  		skb = NULL;
==>  
==> +		if ((move_ndp_to_end) && (ctx->delayed_ndp)) {
==> +			skb_prev_len = skb_out->len;
==> +			delayed_alloc_ptr = memset(skb_put(skb_out, ctx->max_ndp_size), 0, ctx->max_ndp_size);
==> +			memcpy(ctx->delayed_ndp, delayed_alloc_ptr, sizeof(struct usb_cdc_ncm_ndp16));
==> +			kfree(ctx->delayed_ndp);
==> +			cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_max);
==> +		}
==> +
==>  		/* send now if this NDP is full */
==>  		if (index >= CDC_NCM_DPT_DATAGRAMS_MAX) {
==>  			ready2send = 1;
==> diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
==> index 7c9b484..cc02a0d 100644
==> --- a/include/linux/usb/cdc_ncm.h
==> +++ b/include/linux/usb/cdc_ncm.h
==> @@ -93,6 +93,7 @@ struct cdc_ncm_ctx {
==>  	const struct usb_cdc_mbim_desc *mbim_desc;
==>  	const struct usb_cdc_mbim_extended_desc *mbim_extended_desc;
==>  	const struct usb_cdc_ether_desc *ether_desc;
==> +	struct usb_cdc_ncm_ndp16 *delayed_ndp;
==
==What prevents you from embedding this in the structure?
==
==	Regards
==		Oliver
==
==
==
Sorry - I think I didn't understand your ocmment here. Still, I am open to any 
suggestion.
