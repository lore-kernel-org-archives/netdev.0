From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH for-next 01/11] IB/hns: Add the interface for querying
 QP1
Date: Mon, 7 Nov 2016 11:45:03 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A7832A6@lhreml503-mbx>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
 <20161104163633.141880-2-salil.mehta@huawei.com>
 <582014FF.3070600@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Anurup m <anurup.m@huawei.com>,
        "dledford@redhat.com" <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:4117 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbcKGLpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 06:45:33 -0500
In-Reply-To: <582014FF.3070600@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Anurup m
> Sent: Monday, November 07, 2016 5:46 AM
> To: Salil Mehta; dledford@redhat.com
> Cc: linux-rdma@vger.kernel.org; netdev@vger.kernel.org;
> mehta.salil.lnk@gmail.com; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH for-next 01/11] IB/hns: Add the interface for
> querying QP1
> 
> 
> 
> On 11/4/2016 10:06 PM, Salil Mehta wrote:
> > From: Lijun Ou <oulijun@huawei.com>
> >
> > In old code, It only added the interface for querying non-specific
> > QP. This patch mainly adds an interface for querying QP1.
> >
> > Signed-off-by: Lijun Ou <oulijun@huawei.com>
> > Reviewed-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
> > Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
> > ---
> >  drivers/infiniband/hw/hns/hns_roce_hw_v1.c |   87
> +++++++++++++++++++++++++++-
> >  drivers/infiniband/hw/hns/hns_roce_hw_v1.h |    6 +-
> >  2 files changed, 90 insertions(+), 3 deletions(-)
> >
> > diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> > index 71232e5..ca8b784 100644
> > --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> > +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> > @@ -2630,8 +2630,82 @@ static int hns_roce_v1_query_qpc(struct
> hns_roce_dev *hr_dev,
> >  	return ret;
> >  }
> >
> > -int hns_roce_v1_query_qp(struct ib_qp *ibqp, struct ib_qp_attr
> *qp_attr,
> > -			 int qp_attr_mask, struct ib_qp_init_attr
> *qp_init_attr)
> > +static int hns_roce_v1_q_sqp(struct ib_qp *ibqp, struct ib_qp_attr
> *qp_attr,
> > +			     int qp_attr_mask,
> > +			     struct ib_qp_init_attr *qp_init_attr)
> > +{
> > +	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
> > +	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
> > +	struct hns_roce_sqp_context *context;
> > +	u32 addr;
> > +
> > +	context = kzalloc(sizeof(*context), GFP_KERNEL);
> > +	if (!context)
> > +		return -ENOMEM;
> > +
> Do we really need dynamic alloc here as the size is fixed and this
> memory scope is
> only inside this function. I think better to use a static allocation.
Agreed. Somehow missed this in the internal review. Will change!

Thanks
Salil
> 
> > +	mutex_lock(&hr_qp->mutex);
> > +
> > +	if (hr_qp->state == IB_QPS_RESET) {
> I think alloc can be moved after this check (if dynamic alloc is really
> needed).
> > +		qp_attr->qp_state = IB_QPS_RESET;
> > +		goto done;
> > +	}
> > +
> > +	addr = ROCEE_QP1C_CFG0_0_REG + hr_qp->port * sizeof(*context);
> > +	context->qp1c_bytes_4 = roce_read(hr_dev, addr);
> > +	context->sq_rq_bt_l = roce_read(hr_dev, addr + 1);
> > +	context->qp1c_bytes_12 = roce_read(hr_dev, addr + 2);
> > +	context->qp1c_bytes_16 = roce_read(hr_dev, addr + 3);
> > +	context->qp1c_bytes_20 = roce_read(hr_dev, addr + 4);
> > +	context->cur_rq_wqe_ba_l = roce_read(hr_dev, addr + 5);
> > +	context->qp1c_bytes_28 = roce_read(hr_dev, addr + 6);
> > +	context->qp1c_bytes_32 = roce_read(hr_dev, addr + 7);
> > +	context->cur_sq_wqe_ba_l = roce_read(hr_dev, addr + 8);
> > +	context->qp1c_bytes_40 = roce_read(hr_dev, addr + 9);
> > +
> > +	hr_qp->state = roce_get_field(context->qp1c_bytes_4,
> > +				      QP1C_BYTES_4_QP_STATE_M,
> > +				      QP1C_BYTES_4_QP_STATE_S);
> > +	qp_attr->qp_state	= hr_qp->state;
> > +	qp_attr->path_mtu	= IB_MTU_256;
> > +	qp_attr->path_mig_state	= IB_MIG_ARMED;
> > +	qp_attr->qkey		= QKEY_VAL;
> > +	qp_attr->rq_psn		= 0;
> > +	qp_attr->sq_psn		= 0;
> > +	qp_attr->dest_qp_num	= 1;
> > +	qp_attr->qp_access_flags = 6;
> > +
> > +	qp_attr->pkey_index = roce_get_field(context->qp1c_bytes_20,
> > +					     QP1C_BYTES_20_PKEY_IDX_M,
> > +					     QP1C_BYTES_20_PKEY_IDX_S);
> > +	qp_attr->port_num = hr_qp->port + 1;
> > +	qp_attr->sq_draining = 0;
> > +	qp_attr->max_rd_atomic = 0;
> > +	qp_attr->max_dest_rd_atomic = 0;
> > +	qp_attr->min_rnr_timer = 0;
> > +	qp_attr->timeout = 0;
> > +	qp_attr->retry_cnt = 0;
> > +	qp_attr->rnr_retry = 0;
> > +	qp_attr->alt_timeout = 0;
> > +
> > +done:
> > +	qp_attr->cur_qp_state = qp_attr->qp_state;
> > +	qp_attr->cap.max_recv_wr = hr_qp->rq.wqe_cnt;
> > +	qp_attr->cap.max_recv_sge = hr_qp->rq.max_gs;
> > +	qp_attr->cap.max_send_wr = hr_qp->sq.wqe_cnt;
> > +	qp_attr->cap.max_send_sge = hr_qp->sq.max_gs;
> > +	qp_attr->cap.max_inline_data = 0;
> > +	qp_init_attr->cap = qp_attr->cap;
> > +	qp_init_attr->create_flags = 0;
> > +
> > +	mutex_unlock(&hr_qp->mutex);
> > +	kfree(context);
> > +
> > +	return 0;
> > +}
> > +
> > +static int hns_roce_v1_q_qp(struct ib_qp *ibqp, struct ib_qp_attr
> *qp_attr,
> > +			    int qp_attr_mask,
> > +			    struct ib_qp_init_attr *qp_init_attr)
> >  {
> >  	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
> >  	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
> > @@ -2767,6 +2841,15 @@ int hns_roce_v1_query_qp(struct ib_qp *ibqp,
> struct ib_qp_attr *qp_attr,
> >  	return ret;
> >  }
> >
> > +int hns_roce_v1_query_qp(struct ib_qp *ibqp, struct ib_qp_attr
> *qp_attr,
> > +			 int qp_attr_mask, struct ib_qp_init_attr
> *qp_init_attr)
> > +{
> > +	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
> > +
> > +	return hr_qp->doorbell_qpn <= 1 ?
> > +		hns_roce_v1_q_sqp(ibqp, qp_attr, qp_attr_mask,
> qp_init_attr) :
> > +		hns_roce_v1_q_qp(ibqp, qp_attr, qp_attr_mask,
> qp_init_attr);
> > +}
> >  static void hns_roce_v1_destroy_qp_common(struct hns_roce_dev
> *hr_dev,
> >  					  struct hns_roce_qp *hr_qp,
> >  					  int is_user)
> > diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> > index 539b0a3b..2e1878b 100644
> > --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> > +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> > @@ -480,13 +480,17 @@ struct hns_roce_sqp_context {
> >  	u32 qp1c_bytes_12;
> >  	u32 qp1c_bytes_16;
> >  	u32 qp1c_bytes_20;
> > -	u32 qp1c_bytes_28;
> >  	u32 cur_rq_wqe_ba_l;
> > +	u32 qp1c_bytes_28;
> >  	u32 qp1c_bytes_32;
> >  	u32 cur_sq_wqe_ba_l;
> >  	u32 qp1c_bytes_40;
> >  };
> >
> > +#define QP1C_BYTES_4_QP_STATE_S 0
> > +#define QP1C_BYTES_4_QP_STATE_M   \
> > +	(((1UL << 3) - 1) << QP1C_BYTES_4_QP_STATE_S)
> > +
> >  #define QP1C_BYTES_4_SQ_WQE_SHIFT_S 8
> >  #define QP1C_BYTES_4_SQ_WQE_SHIFT_M   \
> >  	(((1UL << 4) - 1) << QP1C_BYTES_4_SQ_WQE_SHIFT_S)
> >
