From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH v2 1/2] net/mlx4_core: clean up cq_res_start_move_to()
Date: Thu, 16 Jan 2014 09:46:39 +0200
Message-ID: <20140116094639.6fe72bcf@jpm-OptiPlex-GX620>
References: <1389099678.15032.19.camel@x41>
	<20140114084752.1db64b21@jpm-OptiPlex-GX620>
	<1389728736.28068.8.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:56490 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbaAPHql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 02:46:41 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1281503eei.21
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 23:46:40 -0800 (PST)
In-Reply-To: <1389728736.28068.8.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ACK.  OK.

-Jack

On Tue, 14 Jan 2014 20:45:36 +0100
Paul Bolle <pebolle@tiscali.nl> wrote:

> Building resource_tracker.o triggers a GCC warning:
>     drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In
> function 'mlx4_HW2SW_CQ_wrapper':
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3019:16:
> warning: 'cq' may be used uninitialized in this function
> [-Wmaybe-uninitialized] atomic_dec(&cq->mtt->ref_count); ^
> 
> This is a false positive. But a cleanup of cq_res_start_move_to() can
> help GCC here. The code currently uses a switch statement where an
> if/else construct would do too, since only two of the switch's four
> cases can ever occur. Dropping that switch makes the warning go away.
> 
> While we're at it, add some missing braces.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> v2: adjust to Jack's review.
> 
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 52
> ++++++++-------------- 1 file changed, 19 insertions(+), 33
> deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c index
> 2f3f2bc..15cd659 100644 ---
> a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c +++
> b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c @@ -1340,43
> +1340,29 @@ static int cq_res_start_move_to(struct mlx4_dev *dev, int
> slave, int cqn, spin_lock_irq(mlx4_tlock(dev));
>  	r = res_tracker_lookup(&tracker->res_tree[RES_CQ], cqn);
> -	if (!r)
> +	if (!r) {
>  		err = -ENOENT;
> -	else if (r->com.owner != slave)
> +	} else if (r->com.owner != slave) {
>  		err = -EPERM;
> -	else {
> -		switch (state) {
> -		case RES_CQ_BUSY:
> -			err = -EBUSY;
> -			break;
> -
> -		case RES_CQ_ALLOCATED:
> -			if (r->com.state != RES_CQ_HW)
> -				err = -EINVAL;
> -			else if (atomic_read(&r->ref_count))
> -				err = -EBUSY;
> -			else
> -				err = 0;
> -			break;
> -
> -		case RES_CQ_HW:
> -			if (r->com.state != RES_CQ_ALLOCATED)
> -				err = -EINVAL;
> -			else
> -				err = 0;
> -			break;
> -
> -		default:
> +	} else if (state == RES_CQ_ALLOCATED) {
> +		if (r->com.state != RES_CQ_HW)
>  			err = -EINVAL;
> -		}
> +		else if (atomic_read(&r->ref_count))
> +			err = -EBUSY;
> +		else
> +			err = 0;
> +	} else if (state != RES_CQ_HW || r->com.state !=
> RES_CQ_ALLOCATED) {
> +		err = -EINVAL;
> +	} else {
> +		err = 0;
> +	}
>  
> -		if (!err) {
> -			r->com.from_state = r->com.state;
> -			r->com.to_state = state;
> -			r->com.state = RES_CQ_BUSY;
> -			if (cq)
> -				*cq = r;
> -		}
> +	if (!err) {
> +		r->com.from_state = r->com.state;
> +		r->com.to_state = state;
> +		r->com.state = RES_CQ_BUSY;
> +		if (cq)
> +			*cq = r;
>  	}
>  
>  	spin_unlock_irq(mlx4_tlock(dev));
