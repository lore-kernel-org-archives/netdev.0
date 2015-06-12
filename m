From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] mlx4_en: don't wait for high order page allocation
Date: Fri, 12 Jun 2015 10:11:48 -0700
Message-ID: <20150612171148.GA3053866@devbig257.prn2.facebook.com>
References: <7ea4f87114ef1b52e49dd90b2a32a6cde834d943.1434127734.git.shli@fb.com>
 <557B1166.1050303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<Kernel-team@fb.com>, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52933 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750698AbbFLRMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 13:12:02 -0400
Content-Disposition: inline
In-Reply-To: <557B1166.1050303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2015 at 10:05:42AM -0700, Alexander Duyck wrote:
> On 06/12/2015 09:50 AM, Shaohua Li wrote:
> >High order page allocation can cause direct memory compaction and harm
> >performance. The patch makes the high order page allocation don't wait,
> >so not trigger direct memory compaction with memory pressure. More
> >details can be found in a similar patch for net core:
> >http://marc.info/?l=linux-mm&m=143406665720428&w=2
> >
> >Cc: Amir Vadai <amirv@mellanox.com>
> >Cc: Ido Shamay <idos@mellanox.com>
> >Cc: Eric Dumazet <edumazet@google.com>
> >Signed-off-by: Shaohua Li <shli@fb.com>
> >---
> >  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >index 2a77a6b..9bc4143 100644
> >--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >@@ -60,8 +60,11 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
> >  	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
> >  		gfp_t gfp = _gfp;
> >-		if (order)
> >+		if (order) {
> >+			if ((PAGE_SIZE << (order - 1)) >= frag_info->frag_size)
> >+				gfp &= ~__GFP_WAIT;
> >  			gfp |= __GFP_COMP | __GFP_NOWARN;
> >+		}
> >  		page = alloc_pages(gfp, order);
> >  		if (likely(page))
> >  			break;
> 
> Is this even really necessary?  I would thing the fact that the
> refill is done using GFP_ATOMIC would be enough to cover the
> frequently used cases.  I wouldn't think the initial allocation when
> the interface is brought up would be something that is a big enough
> deal to justify being fixed in this case.

Ok, if the allocation is always using GFP_ATOMIC at runtime, we
don't need this of course. please ignore it then.

Thanks,
Shaohua
