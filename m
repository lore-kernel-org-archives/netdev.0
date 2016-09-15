From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v4 09/16] IB/pvrdma: Add support for Completion Queues
Date: Thu, 15 Sep 2016 00:07:29 +0000
Message-ID: <BLUPR0501MB836640F5ECEAB3A99CD82BFC5F00@BLUPR0501MB836.namprd05.prod.outlook.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-10-git-send-email-aditr@vmware.com>
 <20160914124321.GE15800@yuval-lap.uk.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160914124321.GE15800@yuval-lap.uk.oracle.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 05:43:37 -0700, Yuval Shaia wrote:
> On Sun, Sep 11, 2016 at 09:49:19PM -0700, Adit Ranadive wrote:
> > +
> > +static int pvrdma_poll_one(struct pvrdma_cq *cq, struct pvrdma_qp
> **cur_qp,
> > +			   struct ib_wc *wc)
> > +{
> > +	struct pvrdma_dev *dev =3D to_vdev(cq->ibcq.device);
> > +	int has_data;
> > +	unsigned int head;
> > +	bool tried =3D false;
> > +	struct pvrdma_cqe *cqe;
> > +
> > +retry:
> > +	has_data =3D pvrdma_idx_ring_has_data(&cq->ring_state->rx,
> > +					    cq->ibcq.cqe, &head);
> > +	if (has_data =3D=3D 0) {
> > +		if (tried)
> > +			return -EAGAIN;
> > +
> > +		/* Pass down POLL to give physical HCA a chance to poll. */
> > +		pvrdma_write_uar_cq(dev, cq->cq_handle |
> PVRDMA_UAR_CQ_POLL);
> > +
> > +		tried =3D true;
> > +		goto retry;
> > +	} else if (has_data =3D=3D PVRDMA_INVALID_IDX) {
>=20
> I didn't went throw the entire life cycle of RX-ring's head and tail but =
you
> need to make sure that PVRDMA_INVALID_IDX error is recoverable one, i.e
> there is probability that in the next call to pvrdma_poll_one it will be =
fine.
> Otherwise it is an endless loop.

We have never run into this issue internally but I don't think we can recov=
er here=20
in the driver. The only way to recover would be to destroy and recreate the=
 CQ=20
which we shouldn't do since it could be used by multiple QPs.=20
We don't have a way yet to recover in the device. Once we add that this che=
ck
should go away.

The reason I returned an error value from poll_cq in v3 was to break the po=
ssible=20
loop so that it might give clients a chance to recover. But since poll_cq i=
s not expected
to fail I just log the device error here. I can revert to that version if y=
ou want to break
the possible loop.
