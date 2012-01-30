From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 12/16] netback: multi-page ring
 support
Date: Mon, 30 Jan 2012 16:35:33 +0000
Message-ID: <4F26D4E5020000780006FF41@nat28.tlf.novell.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
 <1327934734-8908-13-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xensource.com>,
	<konrad.wilk@oracle.com>, <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:1322 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925Ab2A3Qfi convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Mon, 30 Jan 2012 11:35:38 -0500
In-Reply-To: <1327934734-8908-13-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 30.01.12 at 15:45, Wei Liu <wei.liu2@citrix.com> wrote:
> -int xenvif_map_frontend_rings(struct xenvif *vif,
> -			      grant_ref_t tx_ring_ref,
> -			      grant_ref_t rx_ring_ref)
> +int xenvif_map_frontend_rings(struct xen_comms *comms,
> +			      int domid,
> +			      unsigned long ring_ref[],
> +			      unsigned int  ring_ref_count)
>  {
> -	void *addr;
> -	struct xen_netif_tx_sring *txs;
> -	struct xen_netif_rx_sring *rxs;
> -
> -	int err = -ENOMEM;
> +	struct gnttab_map_grant_ref op[NETBK_MAX_RING_PAGES];
> +	unsigned int i;
> +	int err = 0;
>  
> -	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> -				     tx_ring_ref, &addr);

Any reason why you don't just extend this function (in a prerequisite
patch) rather than open coding a common utility function (twice) here,
so that other backends (blkback!) can benefit later as well.

Jan

> -	if (err)
> -		goto err;
> +	comms->ring_area = alloc_vm_area(PAGE_SIZE * ring_ref_count, NULL);
> +	if (comms->ring_area == NULL)
> +		return -ENOMEM;
>  
> -	txs = (struct xen_netif_tx_sring *)addr;
> -	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
> +	for (i = 0; i < ring_ref_count; i++) {
> +		unsigned long addr = (unsigned long)comms->ring_area->addr +
> +			(i * PAGE_SIZE);
> +		gnttab_set_map_op(&op[i], addr, GNTMAP_host_map,
> +				  ring_ref[i], domid);
> +	}
>  
> -	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> -				     rx_ring_ref, &addr);
> -	if (err)
> -		goto err;
> +	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref,
> +				      &op, ring_ref_count))
> +		BUG();
>  
> -	rxs = (struct xen_netif_rx_sring *)addr;
> -	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE);
> +	comms->nr_handles = ring_ref_count;
>  
> -	vif->rx_req_cons_peek = 0;
> +	for (i = 0; i < ring_ref_count; i++) {
> +		if (op[i].status != 0) {
> +			err = op[i].status;
> +			comms->shmem_handle[i] = INVALID_GRANT_HANDLE;
> +			continue;
> +		}
> +		comms->shmem_handle[i] = op[i].handle;
> +	}
>  
> -	return 0;
> +	if (err != 0)
> +		xenvif_unmap_frontend_rings(comms);
>  
> -err:
> -	xenvif_unmap_frontend_rings(vif);
>  	return err;
>  }
>  
