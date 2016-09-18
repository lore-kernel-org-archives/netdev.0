From: Adit Ranadive <aditr@vmware.com>
Subject: RE: [PATCH v4 09/16] IB/pvrdma: Add support for Completion Queues
Date: Sun, 18 Sep 2016 20:36:55 +0000
Message-ID: <BLUPR0501MB83604E10410486A3F068950C5F50@BLUPR0501MB836.namprd05.prod.outlook.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-10-git-send-email-aditr@vmware.com>
 <20160914124321.GE15800@yuval-lap.uk.oracle.com>
 <BLUPR0501MB836640F5ECEAB3A99CD82BFC5F00@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160915073611.GA3851@yuval-lap.uk.oracle.com>
 <20160918170707.GL2923@leon.nu>
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
To: Leon Romanovsky <leonro@leon.nu>,
        Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160918170707.GL2923@leon.nu>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 18, 2016 at 10:07:18 -0700, Leon Romanovsky wrote:=20
> On Thu, Sep 15, 2016 at 10:36:12AM +0300, Yuval Shaia wrote:
> > Hi Adit,
> > Please see my comments inline.
> >
> > Besides that I have no more comment for this patch.
> >
> > Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>
> >
> > Yuval
> >
> > On Thu, Sep 15, 2016 at 12:07:29AM +0000, Adit Ranadive wrote:
> > > On Wed, Sep 14, 2016 at 05:43:37 -0700, Yuval Shaia wrote:
> > > > On Sun, Sep 11, 2016 at 09:49:19PM -0700, Adit Ranadive wrote:
> > > > > +
> > > > > +static int pvrdma_poll_one(struct pvrdma_cq *cq, struct pvrdma_q=
p
> > > > **cur_qp,
> > > > > +			   struct ib_wc *wc)
> > > > > +{
> > > > > +	struct pvrdma_dev *dev =3D to_vdev(cq->ibcq.device);
> > > > > +	int has_data;
> > > > > +	unsigned int head;
> > > > > +	bool tried =3D false;
> > > > > +	struct pvrdma_cqe *cqe;
> > > > > +
> > > > > +retry:
> > > > > +	has_data =3D pvrdma_idx_ring_has_data(&cq->ring_state->rx,
> > > > > +					    cq->ibcq.cqe, &head);
> > > > > +	if (has_data =3D=3D 0) {
> > > > > +		if (tried)
> > > > > +			return -EAGAIN;
> > > > > +
> > > > > +		/* Pass down POLL to give physical HCA a chance to poll. */
> > > > > +		pvrdma_write_uar_cq(dev, cq->cq_handle |
> > > > PVRDMA_UAR_CQ_POLL);
> > > > > +
> > > > > +		tried =3D true;
> > > > > +		goto retry;
> > > > > +	} else if (has_data =3D=3D PVRDMA_INVALID_IDX) {
> > > >
> > > > I didn't went throw the entire life cycle of RX-ring's head and tai=
l but you
> > > > need to make sure that PVRDMA_INVALID_IDX error is recoverable one,=
 i.e
> > > > there is probability that in the next call to pvrdma_poll_one it wi=
ll be fine.
> > > > Otherwise it is an endless loop.
> > >
> > > We have never run into this issue internally but I don't think we can=
 recover here
> >
> > I briefly reviewed the life cycle of RX-ring's head and tail and didn't
> > caught any suspicious place that might corrupt it.
> > So glad to see that you never encountered this case.
> >
> > > in the driver. The only way to recover would be to destroy and recrea=
te the CQ
> > > which we shouldn't do since it could be used by multiple QPs.
> >
> > Agree.
> > But don't they hit the same problem too?
> >
> > > We don't have a way yet to recover in the device. Once we add that th=
is check
> > > should go away.
> >
> > To be honest i have no idea how to do that - i was expecting driver's v=
endors
> > to come up with an ideas :)
> > I once came up with an idea to force restart of the driver but it was
> > rejected.
> >
> > >
> > > The reason I returned an error value from poll_cq in v3 was to break =
the possible
> > > loop so that it might give clients a chance to recover. But since pol=
l_cq is not expected
> > > to fail I just log the device error here. I can revert to that versio=
n if you want to break
> > > the possible loop.
> >
> > Clients (ULPs) cannot recover from this case. They even do not check th=
e
> > reason of the error and treats any error as -EAGAIN.
>=20
> It is because poll_one is not expected to fall.

Poll_one is an internal function in our driver. ULPs should still be okay I=
 think as long as poll_cq
does not fail, no?
