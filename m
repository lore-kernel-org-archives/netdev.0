From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] mlx4_en: don't wait for high order page allocation
Date: Fri, 12 Jun 2015 10:05:42 -0700
Message-ID: <557B1166.1050303@gmail.com>
References: <7ea4f87114ef1b52e49dd90b2a32a6cde834d943.1434127734.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Kernel-team@fb.com,
	Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: Shaohua Li <shli@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34131 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798AbbFLRFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 13:05:44 -0400
Received: by pdbki1 with SMTP id ki1so28211268pdb.1
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 10:05:43 -0700 (PDT)
In-Reply-To: <7ea4f87114ef1b52e49dd90b2a32a6cde834d943.1434127734.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2015 09:50 AM, Shaohua Li wrote:
> High order page allocation can cause direct memory compaction and harm
> performance. The patch makes the high order page allocation don't wait,
> so not trigger direct memory compaction with memory pressure. More
> details can be found in a similar patch for net core:
> http://marc.info/?l=linux-mm&m=143406665720428&w=2
>
> Cc: Amir Vadai <amirv@mellanox.com>
> Cc: Ido Shamay <idos@mellanox.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 2a77a6b..9bc4143 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -60,8 +60,11 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
>   	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
>   		gfp_t gfp = _gfp;
>   
> -		if (order)
> +		if (order) {
> +			if ((PAGE_SIZE << (order - 1)) >= frag_info->frag_size)
> +				gfp &= ~__GFP_WAIT;
>   			gfp |= __GFP_COMP | __GFP_NOWARN;
> +		}
>   		page = alloc_pages(gfp, order);
>   		if (likely(page))
>   			break;

Is this even really necessary?  I would thing the fact that the refill 
is done using GFP_ATOMIC would be enough to cover the frequently used 
cases.  I wouldn't think the initial allocation when the interface is 
brought up would be something that is a big enough deal to justify being 
fixed in this case.

- Alex
