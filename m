From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Tue, 13 May 2014 16:47:08 +0100
Message-ID: <1399996028.21867.34.camel@kazak.uk.xensource.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21840 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaEMPtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 11:49:17 -0400
In-Reply-To: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 15:31 +0100, Zoltan Kiss wrote:
> The original series for reintroducing grant mapping for netback had a patch [1]
> to handle receiving of packets from an another VIF. Grant copy on the receiving
> side needs the grant ref of the page to set up the op.
> The original patch assumed (wrongly) that the frags array haven't changed. In
> the case reported by Sander, the sending guest sent a packet where the linear
> buffer and the first frag were under PKT_PROT_LEN (=128) bytes.
> xenvif_tx_submit() then pulled up the linear area to 128 bytes, and ditched the
> first frag. The receiving side had an off-by-one problem when gathered the grant
> refs.

The grant refs are gather here from the ubuf_info * link list stored in
skb->destructor_arg, is that right?

And the issue is that pulling up can consume a frag (e.g. and shift
everything up) without adjusting that linked list?

I think the commit message should make explicit reference to this linked
list and where it lives and make the implications of doing a pull up on
that list clear.

So the fix is when walking the list instead of assuming a 1:1
relationship between frags and list elements you need to traverse the
list looking for one which matches?

The ubuf's themselves are part of pending_tx_info -- is it the case that
the pending entries are retained until the skb completes even when the
corresponding frag is pulled up?

I suppose the network stack does pull ups itself -- so we can't fix this
by just fixing up the ubuf list as we do the initial PKT_PROT_LEN pull
up because there will be other pull ups which we don't control?

> This patch fixes that by checking whether the actual frag's page pointer is the
> same as the page in the original frag list. It can handle any kind of changes on
> the original frags array, like:
> - removing granted frags from the beginning or the end
> - adding local pages to the frags list
> To keep it optimized to the most common cases, it doesn't handle when the order
> of the original frags changed. That would require ubuf to be reseted to the
> beginning of the chain (skb_shinfo(skb)->destructor_arg), and reiterating
> through the list every time.

Do we need to keep the ubuf list around after this operation or could it
be destructive? I ask because by removing the entries from the list as
they are consumed the optimal case will then always have the next frag
in the head but it will handle reordering.

> OPEN QUESTIONS:
> - Is it a safe assumption that nothing changes the order of the original frags?
>   Removing them from the array or injecting new pages anywhere is not a problem.
> - I used UINT_MAX as a kind of INVALID_GRANT_REF, however there is no such thing
>   in the grant mapping API. Should we codify this or is it better if we just
>   find another way to distinguish whether a frag is local or not?

I think UINT_MAX is probably OK, but can't you avoid this by doing the
search in the existing loop over the frags which calls
xenvif_gop_frag_copy? If you do that then you can pass foreign_vif as
NULL in the cases where there is no ubuf entry.

> - Should this fix go to David's net tree or directly to the mainline tree? Or
>   both?

Via David as normal I think, but we need this for v3.15 final.

> [1]: 3e2234: xen-netback: Handle foreign mapped pages on the guest RX path
> 
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 7666540..e18ac23 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -278,7 +278,7 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  		copy_gop->flags = GNTCOPY_dest_gref;
>  		copy_gop->len = bytes;
>  
> -		if (foreign_vif) {
> +		if (foreign_vif && (foreign_gref != UINT_MAX)) {
>  			copy_gop->source.domid = foreign_vif->domid;
>  			copy_gop->source.u.ref = foreign_gref;
>  			copy_gop->flags |= GNTCOPY_source_gref;
> @@ -388,15 +388,22 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  
>  	if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
>  		 (ubuf->callback == &xenvif_zerocopy_callback)) {
> -		int i = 0;
>  		foreign_vif = ubuf_to_vif(ubuf);
>  
> -		do {
> -			u16 pending_idx = ubuf->desc;
> -			foreign_grefs[i++] =
> -				foreign_vif->pending_tx_info[pending_idx].req.gref;
> -			ubuf = (struct ubuf_info *) ubuf->ctx;
> -		} while (ubuf);
> +		for (i = 0; i < nr_frags; i++) {
> +			foreign_grefs[i] = UINT_MAX;
> +			do {
> +				u16 pending_idx = ubuf->desc;
> +
> +				ubuf = (struct ubuf_info *) ubuf->ctx;
> +				if (skb_shinfo(skb)->frags[i].page.p ==
> +					foreign_vif->mmap_pages[pending_idx]) {
> +					foreign_grefs[i] =
> +						foreign_vif->pending_tx_info[pending_idx].req.gref;
> +					break;
> +				}
> +			} while (ubuf);
> +		}
>  	}
>  
>  	data = skb->data;
