From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4 09/16] IB/pvrdma: Add support for Completion Queues
Date: Mon, 19 Sep 2016 06:24:45 +0300
Message-ID: <20160919032445.GA3273@leon.nu>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-10-git-send-email-aditr@vmware.com>
 <20160914124321.GE15800@yuval-lap.uk.oracle.com>
 <BLUPR0501MB836640F5ECEAB3A99CD82BFC5F00@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160915073611.GA3851@yuval-lap.uk.oracle.com>
 <20160918170707.GL2923@leon.nu>
 <BLUPR0501MB83604E10410486A3F068950C5F50@BLUPR0501MB836.namprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        pv-drivers <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Jorgen S. Hansen" <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BLUPR0501MB83604E10410486A3F068950C5F50-84Rf5TRaNBMVDhIuTCx1aJLWcSx1hRipwIZJ9u9yWa8oOQlpcoRfSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 18, 2016 at 08:36:55PM +0000, Adit Ranadive wrote:
> On Sun, Sep 18, 2016 at 10:07:18 -0700, Leon Romanovsky wrote:
> > On Thu, Sep 15, 2016 at 10:36:12AM +0300, Yuval Shaia wrote:
> > > Hi Adit,
> > > Please see my comments inline.
> > >
> > > Besides that I have no more comment for this patch.
> > >
> > > Reviewed-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > >
> > > Yuval
> > >
> > > On Thu, Sep 15, 2016 at 12:07:29AM +0000, Adit Ranadive wrote:
> > > > On Wed, Sep 14, 2016 at 05:43:37 -0700, Yuval Shaia wrote:
> > > > > On Sun, Sep 11, 2016 at 09:49:19PM -0700, Adit Ranadive wrote:
> > > > > > +
> > > > > > +static int pvrdma_poll_one(struct pvrdma_cq *cq, struct pvrdma_qp
> > > > > **cur_qp,
> > > > > > +			   struct ib_wc *wc)
> > > > > > +{
> > > > > > +	struct pvrdma_dev *dev = to_vdev(cq->ibcq.device);
> > > > > > +	int has_data;
> > > > > > +	unsigned int head;
> > > > > > +	bool tried = false;
> > > > > > +	struct pvrdma_cqe *cqe;
> > > > > > +
> > > > > > +retry:
> > > > > > +	has_data = pvrdma_idx_ring_has_data(&cq->ring_state->rx,
> > > > > > +					    cq->ibcq.cqe, &head);
> > > > > > +	if (has_data == 0) {
> > > > > > +		if (tried)
> > > > > > +			return -EAGAIN;
> > > > > > +
> > > > > > +		/* Pass down POLL to give physical HCA a chance to poll. */
> > > > > > +		pvrdma_write_uar_cq(dev, cq->cq_handle |
> > > > > PVRDMA_UAR_CQ_POLL);
> > > > > > +
> > > > > > +		tried = true;
> > > > > > +		goto retry;
> > > > > > +	} else if (has_data == PVRDMA_INVALID_IDX) {
> > > > >
> > > > > I didn't went throw the entire life cycle of RX-ring's head and tail but you
> > > > > need to make sure that PVRDMA_INVALID_IDX error is recoverable one, i.e
> > > > > there is probability that in the next call to pvrdma_poll_one it will be fine.
> > > > > Otherwise it is an endless loop.
> > > >
> > > > We have never run into this issue internally but I don't think we can recover here
> > >
> > > I briefly reviewed the life cycle of RX-ring's head and tail and didn't
> > > caught any suspicious place that might corrupt it.
> > > So glad to see that you never encountered this case.
> > >
> > > > in the driver. The only way to recover would be to destroy and recreate the CQ
> > > > which we shouldn't do since it could be used by multiple QPs.
> > >
> > > Agree.
> > > But don't they hit the same problem too?
> > >
> > > > We don't have a way yet to recover in the device. Once we add that this check
> > > > should go away.
> > >
> > > To be honest i have no idea how to do that - i was expecting driver's vendors
> > > to come up with an ideas :)
> > > I once came up with an idea to force restart of the driver but it was
> > > rejected.
> > >
> > > >
> > > > The reason I returned an error value from poll_cq in v3 was to break the possible
> > > > loop so that it might give clients a chance to recover. But since poll_cq is not expected
> > > > to fail I just log the device error here. I can revert to that version if you want to break
> > > > the possible loop.
> > >
> > > Clients (ULPs) cannot recover from this case. They even do not check the
> > > reason of the error and treats any error as -EAGAIN.
> >
> > It is because poll_one is not expected to fall.
>
> Poll_one is an internal function in our driver. ULPs should still be okay I think as long as poll_cq
> does not fail, no?

Yes, I think so.

Thanks

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX31p9AAoJEORje4g2clineF0P/RYFr3Zksnc8Tmwqj+pFULl6
/dq0l5OPVnLSfxd2h7W7vsQyRwqyqfYg7EVRnYO2D3L1Tz6/rjP7IYKshBQgHvz5
eSmHgUc3TkdOVfhW9Wm7QQr1ZdCpT8lauRC9j/JTrnV1zwlaj+lEuT2Izy6xM2la
Bf3Rc9nWCGrz9lO7eYI8NAcf/iiiXRqbJQ+/gv3ijEw8rT4UtaPbgyHo7+DT05NU
p+81G2suPDEfFiFKrfMGSJPv6/xYDtV8TzFDEjWClpk4O4fmmeQGapHpv8gg25K9
I4U9pE0mXEWRuA2pcQPJsm6hZdKGrZPTlBPHBCcbktpBKmTpSsjBDXWPGdWAXU6y
umMo49r1Z5sh2tzjbnFwhTcU92ooXaxwDJbWCmdTr+nFnbYUk+FnQjnt3cHF80vi
gHgPyXvdG9tPBPObO8u/KhML4u/QjoDV5udHsU/UGuLb90mybDyNrxNr7jNmoTbe
8PMi+ztjIQv8YgKF0begECrtzNWGnm+591LK7zHOT+vv136pkxD5R+VtblfQrF4Y
e4CwCcFJuJa/HYazIstx1y2ztfguq0e/6NoFP/i9PwRvBo8rVcANAM0vgZSSKVm9
qTkvrxvtAB87hjBlsXT6kWd+HuwJnQ3OOna+2cHmv6HPX5amPI3qo7sDxLKtBqAw
EflknUpfzpSJU4i337UD
=NQH7
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
