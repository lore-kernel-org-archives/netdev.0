From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v4 1/9] xen-netback: Introduce TX grant map definitions
Date: Wed, 15 Jan 2014 15:16:16 +0000
Message-ID: <52D6A640.8000805@citrix.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com> <1389731995-9887-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389731995-9887-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/01/14 20:39, Zoltan Kiss wrote:
> @@ -1677,6 +1793,31 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
>   	vif->mmap_pages[pending_idx] = NULL;
>   }
>
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
> +	BUG_ON(ret);
> +	vif->grant_tx_handle[pending_idx] = NETBACK_INVALID_HANDLE;
> +}

Awkward mistake, I forgot to delete the hypercall ... Even more 
interesting, it caused troubles only very rarely ...

Zoli
