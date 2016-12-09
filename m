From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH V2 21/22] bnxt_re: Add QP event handling
Date: Fri, 9 Dec 2016 15:12:14 +0300
Message-ID: <b0fb09ca-da72-9157-382b-09914d5cb99a@cogentembedded.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
 <1481266096-23331-22-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481266096-23331-22-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/9/2016 9:48 AM, Selvin Xavier wrote:

> Implements callback handler for processing affiliated Async events of a QP.
> This patch also implements the control path command completion handling.
>
> Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c | 49 ++++++++++++++++++++++++++
>  1 file changed, 49 insertions(+)
>
> diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
> index 5b71acd..3e6bb3f 100644
> --- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
> +++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
> @@ -246,6 +246,46 @@ static int bnxt_qplib_process_func_event(struct bnxt_qplib_rcfw *rcfw,
>  	return 0;
>  }
>
> +static int bnxt_qplib_process_qp_event(struct bnxt_qplib_rcfw *rcfw,
> +				       struct creq_qp_event *qp_event)
> +{
> +	struct bnxt_qplib_crsq *crsq = &rcfw->crsq;
> +	struct bnxt_qplib_hwq *cmdq = &rcfw->cmdq;
> +	struct bnxt_qplib_crsqe *crsqe;
> +	u16 cbit, cookie, blocked = 0;
> +	unsigned long flags;
> +	u32 sw_cons;
> +
> +	switch (qp_event->event) {
> +	case CREQ_QP_EVENT_EVENT_QP_ERROR_NOTIFICATION:
> +		break;
> +	default:
> +	{
> +		/* Command Response */
> +		spin_lock_irqsave(&cmdq->lock, flags);
> +		sw_cons = HWQ_CMP(crsq->cons, crsq);
> +		crsqe = &crsq->crsq[sw_cons];
> +		crsq->cons++;
> +		memcpy(&crsqe->qp_event, qp_event, sizeof(crsqe->qp_event));
> +
> +		cookie = le16_to_cpu(crsqe->qp_event.cookie);
> +		blocked = cookie & RCFW_CMD_IS_BLOCKING;
> +		cookie &= RCFW_MAX_COOKIE_VALUE;
> +		cbit = cookie % RCFW_MAX_OUTSTANDING_CMD;
> +		if (!test_and_clear_bit(cbit, rcfw->cmdq_bitmap))
> +			dev_warn(&rcfw->pdev->dev,
> +				 "QPLIB: CMD bit %d was not requested", cbit);
> +
> +		cmdq->cons += crsqe->req_size;
> +		spin_unlock_irqrestore(&cmdq->lock, flags);
> +		if (!blocked)
> +			wake_up(&rcfw->waitq);
> +		break;
> +	}
> +	}

    Hum, strange indentation... Not seeing why you need {} in the *default* at 
all...

> +	return 0;
> +}
> +
>  /* SP - CREQ Completion handlers */
>  static void bnxt_qplib_service_creq(unsigned long data)
>  {
> @@ -269,6 +309,15 @@ static void bnxt_qplib_service_creq(unsigned long data)
>  		type = creqe->type & CREQ_BASE_TYPE_MASK;
>  		switch (type) {
>  		case CREQ_BASE_TYPE_QP_EVENT:
> +			if (!bnxt_qplib_process_qp_event
> +			    (rcfw, (struct creq_qp_event *)creqe))
> +				rcfw->creq_qp_event_processed++;
> +			else {

    CodingStyle: there should be {} used in all branches if it's used on at 
least branch of *if*.

> +				dev_warn(&rcfw->pdev->dev, "QPLIB: crsqe with");
> +				dev_warn(&rcfw->pdev->dev,
> +					 "QPLIB: type = 0x%x not handled",
> +					 type);
> +			}
>  			break;
>  		case CREQ_BASE_TYPE_FUNC_EVENT:
>  			if (!bnxt_qplib_process_func_event

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
