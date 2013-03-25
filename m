From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Mon, 25 Mar 2013 15:13:32 +0000
Message-ID: <5150699C.6080209@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:9560 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756832Ab3CYPNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 11:13:35 -0400
In-Reply-To: <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 11:08, Wei Liu wrote:
> This patch tries to coalesce tx requests when constructing grant copy
> structures. It enables netback to deal with situation when frontend's
> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> 
> It defines max_skb_slots, which is a estimation of the maximum number of slots
> a guest can send, anything bigger than that is considered malicious. Now it is
> set to 20, which should be enough to accommodate Linux (16 to 19).

This maximum needs to be defined as part of the protocol and added to
the interface header.

> Also change variable name from "frags" to "slots" in netbk_count_requests.

I think this renaming should have been done as a separate patch.

> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -47,11 +47,26 @@
>  #include <asm/xen/hypercall.h>
>  #include <asm/xen/page.h>
>  
> +/*
> + * This is an estimation of the maximum possible frags a SKB might
> + * have, anything larger than this is considered malicious. Typically
> + * Linux has 16 to 19.
> + */

Do you mean "max possible /slots/" a packet might have?

> @@ -968,48 +987,114 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
[...]
> +				/* Poison these fields, corresponding
> +				 * fields for head tx req will be set
> +				 * to correct values after the loop.
> +				 */
> +				netbk->mmap_pages[pending_idx] = (void *)(~0UL);
> +				pending_tx_info[pending_idx].head =
> +					INVALID_PENDING_RING_IDX;

Do you need to poison both values?

> +
> +				if (unlikely(!first)) {

This isn't unlikely is it?

> +					first = &pending_tx_info[pending_idx];
> +					start_idx = index;
> +					head_idx = pending_idx;
> +				}

Instead of setting first here why not move the code below here?

> +		first->req.offset = 0;
> +		first->req.size = dst_offset;
> +		first->head = start_idx;
> +		set_page_ext(page, netbk, head_idx);
> +		netbk->mmap_pages[head_idx] = page;
> +		frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);

> @@ -1548,13 +1649,34 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
[...]
> +		/* Setting any number other than
> +		 * INVALID_PENDING_RING_IDX indicates this slot is
> +		 * starting a new packet / ending a previous packet.
> +		 */
> +		pending_tx_info->head = 0;

This doesn't look needed.  It will be initialized again when reusing t
his pending_tx_info again, right?

> +		index = pending_index(netbk->pending_prod++);
> +		netbk->pending_ring[index] = netbk->pending_ring[info_idx];
> +
> +		xenvif_put(vif);
> +
> +		peek = netbk->pending_ring[pending_index(++head)];
> +
> +	} while (netbk->pending_tx_info[peek].head
> +		 == INVALID_PENDING_RING_IDX);
>  
>  	netbk->mmap_pages[pending_idx]->mapping = 0;
>  	put_page(netbk->mmap_pages[pending_idx]);

David
