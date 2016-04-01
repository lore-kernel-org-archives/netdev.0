From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] rds: rds-stress show all zeros after few minutes
Date: Thu, 31 Mar 2016 20:59:46 -0700
Message-ID: <56FDF232.90108@oracle.com>
References: <1459385402-28449-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: shamir rabinovitch <shamir.rabinovitch@oracle.com>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41522 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbcDAD7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 23:59:47 -0400
In-Reply-To: <1459385402-28449-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shamir,

Nice to see this one soon on the list,
Just to make $subject more relevant. How about below?

RDS: fix congestion map corruption for PAGE_SIZE > 8k

On 3/30/16 5:50 PM, shamir rabinovitch wrote:
> Issue can be seen on platforms that use 8K and above page size
> while rds fragment size is 4K. On those platforms single page is
> shared between 2 or more rds fragments. Each fragment has it's own
> offeset and rds cong map code need to take this offset to account.
> Not taking this offset to account lead to reading the data fragment
> as congestion map fragment and hang of the rds transmit due to far
> cong map corruption.
>
> Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
> Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>
>
> Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> ---
>   net/rds/ib_recv.c |    2 +-
>   net/rds/iw_recv.c |    2 +-
>   net/rds/page.c    |    5 +++--
>   3 files changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
> index 977fb86..abc8cc8 100644
> --- a/net/rds/ib_recv.c
> +++ b/net/rds/ib_recv.c
> @@ -796,7 +796,7 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
>
>   		addr = kmap_atomic(sg_page(&frag->f_sg));
>
> -		src = addr + frag_off;
> +		src = addr + frag->f_sg.offset + frag_off;
>   		dst = (void *)map->m_page_addrs[map_page] + map_off;
>   		for (k = 0; k < to_copy; k += 8) {
>   			/* Record ports that became uncongested, ie
> diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
If you refresh the patch against 4.6-rc1, you won't need to
patch iw_recv.c :-)


> diff --git a/net/rds/page.c b/net/rds/page.c
> index 5a14e6d..715cbaa 100644
> --- a/net/rds/page.c
> +++ b/net/rds/page.c
> @@ -135,8 +135,9 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
>   			if (rem->r_offset != 0)
>   				rds_stats_inc(s_page_remainder_hit);
>
> -			rem->r_offset += bytes;
> -			if (rem->r_offset == PAGE_SIZE) {
> +			/* some hw (e.g. sparc) require aligned memory */
> +			rem->r_offset += ALIGN(bytes, 8);
> +			if (rem->r_offset >= PAGE_SIZE) {
>   				__free_page(rem->r_page);
>   				rem->r_page = NULL;
>   			}
>
This hunk I missed out looks like. This doesn't belong to the
$subject patch. Could you please add this in separate patch. I
will need more than just "some hw (e.g. sparc) require aligned memory"

Once you fix these, please repost the updated version, and I will add
them to the 4.7 queue. Thanks !!

Regards,
Santosh
