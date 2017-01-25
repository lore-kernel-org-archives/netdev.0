From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net 1/3] qed: Release CQ resource under lock on failure
Date: Wed, 25 Jan 2017 09:24:27 +0200
Message-ID: <20170125072426.GA4973@yuval-lap>
References: <1485292523-8821-1-git-send-email-Yuval.Mintz@cavium.com>
 <1485292523-8821-2-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1485292523-8821-2-git-send-email-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 11:15:21PM +0200, Yuval Mintz wrote:
> From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> 
> The CQ resource pool is protected by a spin lock. When a CQ creation
> fails it now deallocates under that lock as well.
> 
> Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_roce.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
> index bd4cad2..7ab6d4e 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
> @@ -948,7 +948,9 @@ static int qed_rdma_create_cq(void *rdma_cxt,
>  
>  err:
>  	/* release allocated icid */
> +	spin_lock_bh(&p_info->lock);
>  	qed_bmap_release_id(p_hwfn, &p_info->cq_map, returned_id);
> +	spin_unlock_bh(&p_info->lock);
>  	DP_NOTICE(p_hwfn, "Create CQ failed, rc = %d\n", rc);

Minor suggestion.
Can you consider embedding the lock and unlock inside qed_bmap_release_id?
There are two places where this is bad idea as driver needs to release two
IDs but still one is in error flow and second is when destroying QP so for
most cases code may look a bit better.

>  
>  	return rc;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
