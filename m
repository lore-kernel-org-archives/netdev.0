From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 4/8] xenbus_client: Extend interface to support
 multi-page ring
Date: Tue, 5 Mar 2013 10:25:07 +0000
Message-ID: <5135C803.7030607@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com> <1360944010-15336-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Roger Pau Monne <roger.pau@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30439 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab3CEKZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 05:25:28 -0500
In-Reply-To: <1360944010-15336-5-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/02/13 16:00, Wei Liu wrote:
> Also bundle fixes for xen frontends and backends in this patch.

When changing APIs you don't need to call out required changes to
callers as "fixes".

> --- a/drivers/xen/xenbus/xenbus_client.c
> +++ b/drivers/xen/xenbus/xenbus_client.c
> @@ -357,17 +359,39 @@ static void xenbus_switch_fatal(struct xenbus_device *dev, int depth, int err,
>  /**
>   * xenbus_grant_ring
>   * @dev: xenbus device
> - * @ring_mfn: mfn of ring to grant
> -
> - * Grant access to the given @ring_mfn to the peer of the given device.  Return
> - * 0 on success, or -errno on error.  On error, the device will switch to
> + * @vaddr: starting virtual address of the ring
> + * @nr_pages: number of pages to be granted
> + * @grefs: grant reference array to be filled in
> + *
> + * Grant access to the given @vaddr to the peer of the given device.
> + * Then fill in @grefs with grant references.  Return 0 on success, or
> + * -errno on error.  On error, the device will switch to
>   * XenbusStateClosing, and the error will be saved in the store.
>   */
> -int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn)
> +int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
> +		      int nr_pages, int *grefs)

This call previously return the grant ref in an int, but grant refs are
really of (unsigned) type grant_ref_t.  Make grefs an array of
grant_ref_t's.

>  static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
> -				     int gnt_ref, void **vaddr)
> +				     int *gnt_ref, int nr_grefs, void **vaddr)
[...]
> +	/* Issue hypercall for individual entry, rollback if error occurs. */
> +	for (i = 0; i < nr_grefs; i++) {
> +		op.flags = GNTMAP_host_map | GNTMAP_contains_pte;
> +		op.ref   = gnt_ref[i];
> +		op.dom   = dev->otherend_id;
> +		op.host_addr = arbitrary_virt_to_machine(pte[i]).maddr;
> +
> +		if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
> +			BUG();

I think these hypercalls should be batches into one
GNTTABOP_map_grant_ref call.  I think this will make your 'rollback'
easier as well.

Similarly, for all the other places you have map/unmap in a loop.

> +int xenbus_map_ring(struct xenbus_device *dev, int *gnt_ref, int nr_grefs,
> +		    grant_handle_t *handle, void *vaddr, int *vma_leaked)

grant_ref_t for the array.

> @@ -195,15 +200,17 @@ int xenbus_watch_pathfmt(struct xenbus_device *dev, struct xenbus_watch *watch,
>  			 const char *pathfmt, ...);
>  
>  int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state new_state);
> -int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
> +int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
> +		      int nr_gages, int *grefs);

nr_pages?

David
