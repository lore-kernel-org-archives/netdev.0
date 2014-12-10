From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] cxgb4vf: Fix sparse warnings
Date: Wed, 10 Dec 2014 16:47:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0A4C2@AcuExch.aculab.com>
References: <1418230039-13219-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"leedom@chelsio.com" <leedom@chelsio.com>,
	"anish@chelsio.com" <anish@chelsio.com>,
	"nirranjan@chelsio.com" <nirranjan@chelsio.com>,
	"kumaras@chelsio.com" <kumaras@chelsio.com>
To: 'Hariprasad Shenai' <hariprasad@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59738 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754895AbaLJQsl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 11:48:41 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20089-02 for <netdev@vger.kernel.org>;
 Wed, 10 Dec 2014 16:48:32 +0000 (GMT)
In-Reply-To: <1418230039-13219-1-git-send-email-hariprasad@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai
> Fixes sparse warnings introduced in commit e85c9a7abfa407ed ("cxgb4/cxgb4vf: Add
> code to calculate T5 BAR2 Offsets for SGE Queue Registers") and
> df64e4d38c904dd3 ("cxgb4/cxgb4vf: Use new interfaces to calculate BAR2 SGE Queue
> Register addresses") and few old ones
> 
...
> diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
> b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
> index 02e8833..62bd251 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
> @@ -209,10 +209,10 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
> 
>  			if (rpl) {
>  				/* request bit in high-order BE word */
> -				WARN_ON((be32_to_cpu(*(const u32 *)cmd)
> +				WARN_ON((be32_to_cpu(*(const __be32 *)cmd)
>  					 & FW_CMD_REQUEST_F) == 0);
>  				get_mbox_rpl(adapter, rpl, size, mbox_data);
> -				WARN_ON((be32_to_cpu(*(u32 *)rpl)
> +				WARN_ON((be32_to_cpu(*(__be32 *)rpl)
>  					 & FW_CMD_REQUEST_F) != 0);

Better to byteswap the constant.
Also, it looks like the types of 'rpl' and 'cmd' should be fixed
so that the casts themselves aren't needed.

>  			}
>  			t4_write_reg(adapter, mbox_ctl,
> @@ -486,7 +486,7 @@ int t4_bar2_sge_qregs(struct adapter *adapter,
>  	 *  o The BAR2 Queue ID.
>  	 *  o The BAR2 Queue ID Offset into the BAR2 page.
>  	 */
> -	bar2_page_offset = ((qid >> qpp_shift) << page_shift);
> +	bar2_page_offset = (u64)((qid >> qpp_shift) << page_shift);

That doesn't look like the right place for a cast to u64.
Not that it is at all clear why you've added it.

	David

>  	bar2_qid = qid & qpp_mask;
>  	bar2_qid_offset = bar2_qid * SGE_UDB_SIZE;
> 
> --
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
