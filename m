From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] Re: [PATCH] RDMA/cxgb3: test before subtraction on
	unsigned
Date: Tue, 03 Mar 2009 09:41:56 -0600
Message-ID: <49AD4FC4.2020100@opengridcomputing.com>
References: <49AD32DB.20407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	general@lists.openfabrics.org, swise@chelsio.com
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <49AD32DB.20407@gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Roel Kluin wrote:
> I think there's someting wrong in iwch_post_send():
>
> // vi drivers/infiniband/hw/cxgb3/iwch_qp.c +353
> int iwch_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
>                       struct ib_send_wr **bad_wr)
> {
> 	...
>         u32 num_wrs;
> 	...
>         num_wrs = Q_FREECNT(qhp->wq.sq_rptr, qhp->wq.sq_wptr,
>                   qhp->wq.sq_size_log2);
>         if (num_wrs <= 0) {
>                 spin_unlock_irqrestore(&qhp->lock, flag);
>                 return -ENOMEM;
>         }
>
> // vi drivers/infiniband/hw/cxgb3/cxio_wr.h +50
> #define Q_FREECNT(rptr,wptr,size_log2) ((1UL<<size_log2)-((wptr)-(rptr)))
>
> Since num_wrs is unsigned, I think the test should occur before the subtraction,
> right? please review.
> ------------------------------>8-------------8<---------------------------------
> num_wrs is unsigned so test before the subtraction.
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
> index 19661b2..1c6ebaf 100644
> --- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
> +++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
> @@ -369,12 +369,13 @@ int iwch_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
>  		spin_unlock_irqrestore(&qhp->lock, flag);
>  		return -EINVAL;
>  	}
> -	num_wrs = Q_FREECNT(qhp->wq.sq_rptr, qhp->wq.sq_wptr,
> -		  qhp->wq.sq_size_log2);
> -	if (num_wrs <= 0) {
> +	if ((1UL << qhp->wq.sq_size_log2) + qhp->wq.sq_rptr <=
> +			qhp->wq.sq_wptr) {
>  		spin_unlock_irqrestore(&qhp->lock, flag);
>  		return -ENOMEM;
>  	}
> +	num_wrs = Q_FREECNT(qhp->wq.sq_rptr, qhp->wq.sq_wptr,
> +		  qhp->wq.sq_size_log2);
>  	while (wr) {
>  		if (num_wrs == 0) {
>  			err = -ENOMEM;
>
>   

I think the test is just wrong.  It should be:

if (num_wrs == 0).

Q_FREECNT() will not return < 0.  The free count is either zero if it is 
full,  or non zero count of the number of free elements.
 
Steve.
