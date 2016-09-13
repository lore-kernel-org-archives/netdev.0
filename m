From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [RFC 07/11] Add support for memory registeration verbs
Date: Tue, 13 Sep 2016 17:44:58 +0300
Message-ID: <7fa4a9b8-7cb1-0f83-d6e5-1055ae59bce4@grimberg.me>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        Michal.Kalderon@qlogic.com, rajesh.borundia@qlogic.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: Ram Amrani <Ram.Amrani@qlogic.com>, dledford@redhat.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36488 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcIMOpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:45:02 -0400
In-Reply-To: <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +struct qedr_mr *__qedr_alloc_mr(struct ib_pd *ibpd, int max_page_list_len)
> +{
> +	struct qedr_pd *pd = get_qedr_pd(ibpd);
> +	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
> +	struct qedr_mr *mr;
> +	int rc = -ENOMEM;
> +
> +	DP_VERBOSE(dev, QEDR_MSG_MR,
> +		   "qedr_alloc_frmr pd = %d max_page_list_len= %d\n", pd->pd_id,
> +		   max_page_list_len);
> +
> +	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
> +	if (!mr)
> +		return ERR_PTR(rc);
> +
> +	mr->dev = dev;
> +	mr->type = QEDR_MR_FRMR;
> +
> +	rc = init_mr_info(dev, &mr->info, max_page_list_len, 1);
> +	if (rc)
> +		goto err0;
> +
> +	rc = dev->ops->rdma_alloc_tid(dev->rdma_ctx, &mr->hw_mr.itid);
> +	if (rc) {
> +		DP_ERR(dev, "roce alloc tid returned an error %d\n", rc);
> +		goto err0;
> +	}
> +
> +	/* Index only, 18 bit long, lkey = itid << 8 | key */
> +	mr->hw_mr.tid_type = QED_RDMA_TID_FMR;
> +	mr->hw_mr.key = 0;
> +	mr->hw_mr.pd = pd->pd_id;

Do you have a real MR<->PD association in HW? If so, can you point
me to the code that binds it? If not, any reason not to expose
the local_dma_lkey?

> +struct ib_mr *qedr_get_dma_mr(struct ib_pd *ibpd, int acc)
> +{
> +	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
> +	struct qedr_pd *pd = get_qedr_pd(ibpd);
> +	struct qedr_mr *mr;
> +	int rc;
> +
> +	if (acc & IB_ACCESS_MW_BIND) {
> +		DP_ERR(dev, "Unsupported access flags received for dma mr\n");
> +		return ERR_PTR(-EINVAL);
> +	}

This check looks like it really belongs in the core, it would help
everyone if you move it...

Although I know Christoph is trying to get rid of this API altogether...
