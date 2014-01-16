From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4 1/9] xen-netback: Introduce TX grant map
 definitions
Date: Thu, 16 Jan 2014 00:00:40 +0000
Message-ID: <20140116000040.GA5331@zion.uk.xensource.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
 <1389731995-9887-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389731995-9887-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a stray blank line change in xenvif_tx_create_gop. (I removed
that part too early and didn't bother to paste it back...)

On Tue, Jan 14, 2014 at 08:39:47PM +0000, Zoltan Kiss wrote:
[...]
> +void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
> +{
> +	int ret;
> +	struct gnttab_unmap_grant_ref tx_unmap_op;
> +
> +	if (vif->grant_tx_handle[pending_idx] == NETBACK_INVALID_HANDLE) {
> +		netdev_err(vif->dev,
> +			   "Trying to unmap invalid handle! pending_idx: %x\n",
> +			   pending_idx);
> +		return;
> +	}
> +	gnttab_set_unmap_op(&tx_unmap_op,
> +			    idx_to_kaddr(vif, pending_idx),
> +			    GNTMAP_host_map,
> +			    vif->grant_tx_handle[pending_idx]);
> +	ret = gnttab_unmap_refs(&tx_unmap_op,
> +				&vif->mmap_pages[pending_idx],
> +				1);
> +
> +	ret = HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref,
> +					&tx_unmap_op,
> +					1);

As you said in your other email, this should be removed. :-)

> +	BUG_ON(ret);
> +	vif->grant_tx_handle[pending_idx] = NETBACK_INVALID_HANDLE;
> +}
>  
>  static void make_tx_response(struct xenvif *vif,
>  			     struct xen_netif_tx_request *txp,
> @@ -1738,6 +1879,14 @@ static inline int tx_work_todo(struct xenvif *vif)
>  	return 0;
>  }
>  
> +static inline bool tx_dealloc_work_todo(struct xenvif *vif)
> +{
> +	if (vif->dealloc_cons != vif->dealloc_prod)
> +		return true;
> +
> +	return false;

This can be simplified as
  return vif->dealloc_cons != vif->dealloc_prod;

Wei.
