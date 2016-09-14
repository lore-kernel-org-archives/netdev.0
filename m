From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v4 05/16] IB/pvrdma: Add functions for Verbs support
Date: Wed, 14 Sep 2016 15:28:12 +0300
Message-ID: <20160914122811.GD15800@yuval-lap.uk.oracle.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-6-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47720 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752470AbcINM2X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 08:28:23 -0400
Content-Disposition: inline
In-Reply-To: <1473655766-31628-6-git-send-email-aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2016 at 09:49:15PM -0700, Adit Ranadive wrote:
> +
> +/**
> + * pvrdma_alloc_pd - allocate protection domain
> + * @ibdev: the IB device
> + * @context: user context
> + * @udata: user data
> + *
> + * @return: the ib_pd protection domain pointer on success, otherwise errno.
> + */
> +struct ib_pd *pvrdma_alloc_pd(struct ib_device *ibdev,
> +			      struct ib_ucontext *context,
> +			      struct ib_udata *udata)
> +{
> +	struct pvrdma_pd *pd;
> +	struct pvrdma_dev *dev = to_vdev(ibdev);
> +	union pvrdma_cmd_req req;
> +	union pvrdma_cmd_resp rsp;
> +	struct pvrdma_cmd_create_pd *cmd = &req.create_pd;
> +	struct pvrdma_cmd_create_pd_resp *resp = &rsp.create_pd_resp;
> +	int ret;
> +	void *ptr;
> +
> +	/* Check allowed max pds */
> +	if (!atomic_add_unless(&dev->num_pds, 1, dev->dsr->caps.max_pd))
> +		return ERR_PTR(-EINVAL);
> +
> +	memset(cmd, 0, sizeof(*cmd));
> +	cmd->hdr.cmd = PVRDMA_CMD_CREATE_PD;
> +	cmd->ctx_handle = (context) ? to_vucontext(context)->ctx_handle : 0;
> +	ret = pvrdma_cmd_post(dev, &req, &rsp);
> +	if (ret < 0) {
> +		dev_warn(&dev->pdev->dev,
> +			 "failed to allocate protection domain, error: %d\n",
> +			 ret);
> +		ptr = ERR_PTR(ret);
> +		goto err;
> +	} else if (resp->hdr.ack != PVRDMA_CMD_CREATE_PD_RESP) {
> +		dev_warn(&dev->pdev->dev,
> +			 "unknown response for allocate protection domain\n");
> +		ptr = ERR_PTR(-EFAULT);
> +		goto err;
> +	}
> +
> +	pd = kmalloc(sizeof(*pd), GFP_KERNEL);
> +	if (!pd) {
> +		ptr = ERR_PTR(-ENOMEM);
> +		goto err;
> +	}

I know that this was my suggestion but also remember that you raised a
(correct) argument that it is preferred to first do other allocation and
free them if command fails then the other way around where failure of
memory allocation (like here) will force us to do the opposite command
(pvrdma_dealloc_pd in this case).

So either accept your way (better) or call pvrdma_dealloc_pd when kmalloc
fails.

> +
> +	pd->privileged = !context;
> +	pd->pd_handle = resp->pd_handle;
> +	pd->pdn = resp->pd_handle;
> +
> +	if (context) {
> +		if (ib_copy_to_udata(udata, &pd->pdn, sizeof(__u32))) {
> +			dev_warn(&dev->pdev->dev,
> +				 "failed to copy back protection domain\n");
> +			pvrdma_dealloc_pd(&pd->ibpd);
> +			return ERR_PTR(-EFAULT);
> +		}
> +	}
> +
> +	/* u32 pd handle */
> +	return  &pd->ibpd;
> +
> +err:
> +	atomic_dec(&dev->num_pds);
> +	return ptr;
> +}
