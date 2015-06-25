From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
Date: Thu, 25 Jun 2015 15:38:46 +0200
Message-ID: <1435239526.28594.24.camel@suse.de>
References: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com>
	 <1435012335-6055-3-git-send-email-mrkiko.rs@gmail.com>
	 <1435225769.28594.13.camel@suse.com>
	 <alpine.LNX.2.20.1506251327570.25021@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.20.1506251327570.25021-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-06-25 at 13:44 +0200, Enrico Mioso wrote:

> On Thu, 25 Jun 2015, Oliver Neukum wrote:

> > Is there any advantage in keeping this in a single function?
> >
> I did this choice in the light of the fact I think the tx_fixup function will 
> become more complex than it is now, when aggregating frames.

Yes, but that is a reason to split the helpers up not the opposite.

> I answer here your other message to make it more convenient to read: my 
> intention for the tx_fixup function would be to:
> - aggregate frames
> - send them out when:
>  	- a timer expires

How would you do that in tx_fixup()? If a timer is required then you
need a separate function.

>  	OR
>  	- we have enough data in the aggregate, and cannot add more.

Yes.

You need a third case:
	- the interface is taken down.

But in general the logic for that is already there. So can you explain
what additional goals you have?

> This is something done in cdc_ncm.c for example.
> But here I have a question: by reading the comment in file 
> drivers/net/usb/rndis_host.c at line 572, there seem to be different opinions 
> in this matter.

That is a very old comment written for much slower devices.
rndis_host doesn't get much love nowadays.

> What to do ?
> 
> >> +int
> >> +huawei_ncm_mgmt(struct usbnet *dev,
> >> +		struct huawei_cdc_ncm_state *drvstate, struct sk_buff *skb_out, int mode) {
> >> +	struct usb_cdc_ncm_nth16 *nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
> >> +	struct cdc_ncm_ctx *ctx = drvstate->ctx;
> >> +	struct usb_cdc_ncm_ndp16 *ndp16 = NULL;
> >> +	int ret = -EINVAL;
> >> +	u16 ndplen, index;
> >> +
> >> +	switch (mode) {
> >> +	case NCM_INIT_FRAME:
> >> +
> >> +		/* Write a new NTH16 header */
> >> +		nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
> >> +		if (!nth16) {
> >> +			ret = -EINVAL;
> >> +			goto error;
> >> +		}
> >> +
> >> +		/* NTH16 signature and header length are known a-priori. */
> >> +		nth16->dwSignature = cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
> >> +		nth16->wHeaderLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16));
> >> +
> >> +		/* TX sequence numbering */
> >> +		nth16->wSequence = cpu_to_le16(ctx->tx_seq++);
> >> +
> >> +		/* Forget about previous SKB NDP */
> >> +		drvstate->skb_ndp = NULL;
> >
> > This is probably better done after you know you cannot fail.
> Sure. Thank you.
> >
> >> +
> >> +		/* Allocate a new NDP */
> >> +		ndp16 = kzalloc(ctx->max_ndp_size, GFP_NOIO);
> >
> > Where is this freed?
> The intention wqas to free it in the NCM_COMMIT_NDP case.
> Infact after allocating the pointer, I make a copy of it in the driver state 
> (drvstate) variable, and get back to it later.
> Is this wrong?

Well, no, but it supposes a matched commit phase. Can you guarantee
that? I was under the oppression that in that phase you want to actually
give a frame over to the hardware.



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
