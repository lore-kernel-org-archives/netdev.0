From: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 07/11] Add support for memory registeration verbs
Date: Wed, 14 Sep 2016 08:59:19 +0000
Message-ID: <BLUPR0701MB192207820BA5CF59A835181088F10@BLUPR0701MB1922.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
 <7fa4a9b8-7cb1-0f83-d6e5-1055ae59bce4@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <7fa4a9b8-7cb1-0f83-d6e5-1055ae59bce4-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > +struct qedr_mr *__qedr_alloc_mr(struct ib_pd *ibpd, int
> > +max_page_list_len) {
> > +	struct qedr_pd *pd =3D get_qedr_pd(ibpd);
> > +	struct qedr_dev *dev =3D get_qedr_dev(ibpd->device);
> > +	struct qedr_mr *mr;
> > +	int rc =3D -ENOMEM;
> > +
> > +	DP_VERBOSE(dev, QEDR_MSG_MR,
> > +		   "qedr_alloc_frmr pd =3D %d max_page_list_len=3D %d\n", pd-
> >pd_id,
> > +		   max_page_list_len);
> > +
> > +	mr =3D kzalloc(sizeof(*mr), GFP_KERNEL);
> > +	if (!mr)
> > +		return ERR_PTR(rc);
> > +
> > +	mr->dev =3D dev;
> > +	mr->type =3D QEDR_MR_FRMR;
> > +
> > +	rc =3D init_mr_info(dev, &mr->info, max_page_list_len, 1);
> > +	if (rc)
> > +		goto err0;
> > +
> > +	rc =3D dev->ops->rdma_alloc_tid(dev->rdma_ctx, &mr->hw_mr.itid);
> > +	if (rc) {
> > +		DP_ERR(dev, "roce alloc tid returned an error %d\n", rc);
> > +		goto err0;
> > +	}
> > +
> > +	/* Index only, 18 bit long, lkey =3D itid << 8 | key */
> > +	mr->hw_mr.tid_type =3D QED_RDMA_TID_FMR;
> > +	mr->hw_mr.key =3D 0;
> > +	mr->hw_mr.pd =3D pd->pd_id;
>=20
> Do you have a real MR<->PD association in HW? If so, can you point me to =
the
> code that binds it? If not, any reason not to expose the local_dma_lkey?
>=20
Yes, we send the pd id to the FW in function qed_rdma_register_tid. In any =
case, if we didn't have the association in HW
Wouldn't the local_dma_lkey be relevant only to dma_mr ? ( code snippet abo=
ve refers to FMR)=20

> > +struct ib_mr *qedr_get_dma_mr(struct ib_pd *ibpd, int acc) {
> > +	struct qedr_dev *dev =3D get_qedr_dev(ibpd->device);
> > +	struct qedr_pd *pd =3D get_qedr_pd(ibpd);
> > +	struct qedr_mr *mr;
> > +	int rc;
> > +
> > +	if (acc & IB_ACCESS_MW_BIND) {
> > +		DP_ERR(dev, "Unsupported access flags received for dma
> mr\n");
> > +		return ERR_PTR(-EINVAL);
> > +	}
>=20
> This check looks like it really belongs in the core, it would help everyo=
ne if you
> move it...
>=20
> Although I know Christoph is trying to get rid of this API altogether...
Sure, will do.
=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in =
the body
> of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
