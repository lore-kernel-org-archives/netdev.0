From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v3 1/6] cxgb4i: fix tx credit calculation
Date: Tue, 09 Dec 2014 22:54:45 +0300
Message-ID: <54875385.80708@cogentembedded.com>
References: <201412091732.sB9HWHRm008996@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, anish@chelsio.com, hch@infradead.org,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	davem@davemloft.net
To: Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <201412091732.sB9HWHRm008996@localhost6.localdomain6>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
> diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
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
> @@ -597,12 +603,14 @@ static int push_tx_frames(struct cxgbi_sock *csk, int req_completion)
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

    It would have been good if you added spaces around *, while at it, to keep
it consistent with the general kernel coding  style...

[...]

WBR, Sergei

