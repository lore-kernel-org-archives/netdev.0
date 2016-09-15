From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v4 09/16] IB/pvrdma: Add support for Completion Queues
Date: Thu, 15 Sep 2016 10:36:12 +0300
Message-ID: <20160915073611.GA3851@yuval-lap.uk.oracle.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-10-git-send-email-aditr@vmware.com>
 <20160914124321.GE15800@yuval-lap.uk.oracle.com>
 <BLUPR0501MB836640F5ECEAB3A99CD82BFC5F00@BLUPR0501MB836.namprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29807 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933287AbcIOHgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 03:36:24 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR0501MB836640F5ECEAB3A99CD82BFC5F00@BLUPR0501MB836.namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Adit,
Please see my comments inline.

Besides that I have no more comment for this patch.

Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>

Yuval

On Thu, Sep 15, 2016 at 12:07:29AM +0000, Adit Ranadive wrote:
> On Wed, Sep 14, 2016 at 05:43:37 -0700, Yuval Shaia wrote:
> > On Sun, Sep 11, 2016 at 09:49:19PM -0700, Adit Ranadive wrote:
> > > +
> > > +static int pvrdma_poll_one(struct pvrdma_cq *cq, struct pvrdma_qp
> > **cur_qp,
> > > +			   struct ib_wc *wc)
> > > +{
> > > +	struct pvrdma_dev *dev = to_vdev(cq->ibcq.device);
> > > +	int has_data;
> > > +	unsigned int head;
> > > +	bool tried = false;
> > > +	struct pvrdma_cqe *cqe;
> > > +
> > > +retry:
> > > +	has_data = pvrdma_idx_ring_has_data(&cq->ring_state->rx,
> > > +					    cq->ibcq.cqe, &head);
> > > +	if (has_data == 0) {
> > > +		if (tried)
> > > +			return -EAGAIN;
> > > +
> > > +		/* Pass down POLL to give physical HCA a chance to poll. */
> > > +		pvrdma_write_uar_cq(dev, cq->cq_handle |
> > PVRDMA_UAR_CQ_POLL);
> > > +
> > > +		tried = true;
> > > +		goto retry;
> > > +	} else if (has_data == PVRDMA_INVALID_IDX) {
> > 
> > I didn't went throw the entire life cycle of RX-ring's head and tail but you
> > need to make sure that PVRDMA_INVALID_IDX error is recoverable one, i.e
> > there is probability that in the next call to pvrdma_poll_one it will be fine.
> > Otherwise it is an endless loop.
> 
> We have never run into this issue internally but I don't think we can recover here 

I briefly reviewed the life cycle of RX-ring's head and tail and didn't
caught any suspicious place that might corrupt it.
So glad to see that you never encountered this case.

> in the driver. The only way to recover would be to destroy and recreate the CQ 
> which we shouldn't do since it could be used by multiple QPs. 

Agree.
But don't they hit the same problem too?

> We don't have a way yet to recover in the device. Once we add that this check
> should go away.

To be honest i have no idea how to do that - i was expecting driver's vendors
to come up with an ideas :)
I once came up with an idea to force restart of the driver but it was
rejected.

> 
> The reason I returned an error value from poll_cq in v3 was to break the possible 
> loop so that it might give clients a chance to recover. But since poll_cq is not expected
> to fail I just log the device error here. I can revert to that version if you want to break
> the possible loop.

Clients (ULPs) cannot recover from this case. They even do not check the
reason of the error and treats any error as -EAGAIN.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
