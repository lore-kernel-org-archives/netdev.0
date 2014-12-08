From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 3/5] cxgb4i: handle non-pdu-aligned rx and additional
 types of negative advice
Date: Mon, 08 Dec 2014 14:36:39 +0300
Message-ID: <54858D47.3080005@cogentembedded.com>
References: <201412080958.sB89wEsj005499@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, anish@chelsio.com, hch@infradead.org,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	davem@davemloft.net
To: kxie@chelsio.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <201412080958.sB89wEsj005499@localhost6.localdomain6>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/8/2014 12:58 PM, kxie@chelsio.com wrote:

> [PATCH net v2 3/5] cxgb4i: handle non-pdu-aligned rx data and additional types of negative advice

    The patch summary shouldn't be duplicated in the change log, at least not 
like this...

> From: Karen Xie <kxie@chelsio.com>

> - abort the connection upon receiving of cpl_rx_data, which means the pdu cannot be recovered from the tcp stream. This could be due to pdu header corruption.
> - handle additional types of negative advice returned by h/w.

> Signed-off-by: Karen Xie <kxie@chelsio.com>
> ---
>   drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   34 +++++++++++++++++++++++++++++++---
>   1 files changed, 31 insertions(+), 3 deletions(-)

> diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> index b834bde..051adab 100644
> --- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> +++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> @@ -845,6 +845,13 @@ static void csk_act_open_retry_timer(unsigned long data)
>
>   }
>
> +static inline int is_neg_adv(unsigned int status)

    'bool' fits better.

> +{
> +	return status == CPL_ERR_RTX_NEG_ADVICE ||
> +		status == CPL_ERR_KEEPALV_NEG_ADVICE ||
> +		status == CPL_ERR_PERSIST_NEG_ADVICE;
> +}
> +
[...]
> @@ -1027,6 +1033,27 @@ rel_skb:
>   	__kfree_skb(skb);
>   }
>
> +static void do_rx_data(struct cxgbi_device *cdev, struct sk_buff *skb)
> +{
> +	struct cxgbi_sock *csk;
> +	struct cpl_rx_data *cpl = (struct cpl_rx_data *)skb->data;
> +	unsigned int tid = GET_TID(cpl);
> +	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
> +	struct tid_info *t = lldi->tids;
> +
> +	csk = lookup_tid(t, tid);
> +	if (!csk) {
> +		pr_err("can't find connection for tid %u.\n", tid);
> +	} else {
> +		/* not expecting this, reset the connection. */
> +		pr_err("csk 0x%p, tid %u, rcv cpl_rx_data.\n", csk, tid);

    Both situations considered an error?

> +		spin_lock_bh(&csk->lock);
> +		send_abort_req(csk);
> +		spin_unlock_bh(&csk->lock);
> +	}
> +	__kfree_skb(skb);
> +}
> +
>   static void do_rx_iscsi_hdr(struct cxgbi_device *cdev, struct sk_buff *skb)
>   {
>   	struct cxgbi_sock *csk;
[...]

WBR, Sergei

