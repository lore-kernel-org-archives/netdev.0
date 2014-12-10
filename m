From: Karen Xie <kxie@chelsio.com>
Subject: RE: [PATCH net v3 1/6] cxgb4i: fix tx credit calculation
Date: Wed, 10 Dec 2014 01:38:56 +0000
Message-ID: <1442C3287A121140B690F7F20F94463D82E117@nice.asicdesigners.com>
References: <201412091732.sB9HWHRm008996@localhost6.localdomain6>
 <54875385.80708@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hariprasad S <hariprasad@chelsio.com>,
	Anish Bhatt <anish@chelsio.com>,
	"hch@infradead.org" <hch@infradead.org>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1438 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957AbaLJBkA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 20:40:00 -0500
In-Reply-To: <54875385.80708@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review comment, have sent the v4 set to incorporate your comments.

-----Original Message-----
From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com] 
Sent: Tuesday, December 09, 2014 11:55 AM
To: Karen Xie; linux-scsi@vger.kernel.org; netdev@vger.kernel.org
Cc: Hariprasad S; Anish Bhatt; hch@infradead.org; James.Bottomley@HansenPartnership.com; michaelc@cs.wisc.edu; davem@davemloft.net
Subject: Re: [PATCH net v3 1/6] cxgb4i: fix tx credit calculation

Hello.

On 12/09/2014 08:32 PM, Karen Xie wrote:

> [PATCH net v3 1/6] cxgb4i: fix tx credit calculation

> From: Karen Xie <kxie@chelsio.com>

> - Only data skbs need the wr header added while control skbs do not. Make sure they are treated differently.
> - Any credit related checking should be done before adding the wr header.

    Looks like a spearate issue deserving its own patch?

> - Fixed compiler warning resulted from added cxgbi_skb_test_flag() call in is_ofld_imm().

    Isn't it called cxgbi_skcb_test_flag()?

> Signed-off-by: Karen Xie <kxie@chelsio.com>
> ---
>   drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   26 +++++++++++++++++---------
>   drivers/scsi/cxgbi/libcxgbi.h      |    4 ++--
>   2 files changed, 19 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c 
> b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> index 1508125..5c3f15d 100644
> --- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> +++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
[...]
> @@ -544,15 +548,17 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
>   	unsigned int submode = cxgbi_skcb_ulp_mode(skb) & 3;
>   	unsigned int wr_ulp_mode = 0;
>
> -	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb, sizeof(*req));
> -

    Perhaps it makes sense to store the result of is_ofld_imm() before
__skb_push() call
instead of duplicating the same call in 2 branches?

>   	if (is_ofld_imm(skb)) {
> +		req = (struct fw_ofld_tx_data_wr *)__skb_push(skb,
> +							sizeof(*req));

    The continuation line should start right under 'skb' on the previous line.

>   		req->op_to_immdlen = htonl(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
>   					FW_WR_COMPL(1) |
>   					FW_WR_IMMDLEN(dlen));
>   		req->flowid_len16 = htonl(FW_WR_FLOWID(csk->tid) |
>   						FW_WR_LEN16(credits));
>   	} else {
> +		req = (struct fw_ofld_tx_data_wr *)__skb_push(skb,
> +							sizeof(*req));

    Likewise.

>   		req->op_to_immdlen =
>   			cpu_to_be32(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
>   					FW_WR_COMPL(1) |
> @@ -597,12 +603,14 @@ static int push_tx_frames(struct cxgbi_sock 
> *csk, int req_completion)
>
>   		skb_reset_transport_header(skb);
>   		if (is_ofld_imm(skb))
> -			credits_needed = DIV_ROUND_UP(dlen +
> -					sizeof(struct fw_ofld_tx_data_wr), 16);
> +			credits_needed = DIV_ROUND_UP(dlen, 16);
>   		else
> -			credits_needed = DIV_ROUND_UP(8*calc_tx_flits_ofld(skb)
> -					+ sizeof(struct fw_ofld_tx_data_wr),
> -					16);
> +			credits_needed = DIV_ROUND_UP(8*calc_tx_flits_ofld(skb),

    It would have been good if you added spaces around *, while at it, to keep it consistent with the general kernel coding  style...

[...]

WBR, Sergei
