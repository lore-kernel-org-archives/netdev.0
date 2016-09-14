From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: RE: [RFC 07/11] Add support for memory registeration verbs
Date: Wed, 14 Sep 2016 10:02:02 +0000
Message-ID: <BLUPR0701MB19225000802B5D226FB4CBBD88F10@BLUPR0701MB1922.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
 <7fa4a9b8-7cb1-0f83-d6e5-1055ae59bce4@grimberg.me>
 <BLUPR0701MB192207820BA5CF59A835181088F10@BLUPR0701MB1922.namprd07.prod.outlook.com>
 <4b392963-c14c-d793-147a-67b08e97ee06@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "Michal.Kalderon@qlogic.com" <Michal.Kalderon@qlogic.com>,
        "rajesh.borundia@qlogic.com" <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sagi Grimberg <sagi@grimberg.me>,
        Ram Amrani <Ram.Amrani@qlogic.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0074.outbound.protection.outlook.com ([104.47.38.74]:8512
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751584AbcINKSF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 06:18:05 -0400
In-Reply-To: <4b392963-c14c-d793-147a-67b08e97ee06@grimberg.me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >>> +struct qedr_mr *__qedr_alloc_mr(struct ib_pd *ibpd, int
> >>> +max_page_list_len) {
> >>> +	struct qedr_pd *pd =3D get_qedr_pd(ibpd);
> >>> +	struct qedr_dev *dev =3D get_qedr_dev(ibpd->device);
> >>> +	struct qedr_mr *mr;
> >>> +	int rc =3D -ENOMEM;
> >>> +
> >>> +	DP_VERBOSE(dev, QEDR_MSG_MR,
> >>> +		   "qedr_alloc_frmr pd =3D %d max_page_list_len=3D %d\n", pd-
> >>> pd_id,
> >>> +		   max_page_list_len);
> >>> +
> >>> +	mr =3D kzalloc(sizeof(*mr), GFP_KERNEL);
> >>> +	if (!mr)
> >>> +		return ERR_PTR(rc);
> >>> +
> >>> +	mr->dev =3D dev;
> >>> +	mr->type =3D QEDR_MR_FRMR;
> >>> +
> >>> +	rc =3D init_mr_info(dev, &mr->info, max_page_list_len, 1);
> >>> +	if (rc)
> >>> +		goto err0;
> >>> +
> >>> +	rc =3D dev->ops->rdma_alloc_tid(dev->rdma_ctx, &mr->hw_mr.itid);
> >>> +	if (rc) {
> >>> +		DP_ERR(dev, "roce alloc tid returned an error %d\n", rc);
> >>> +		goto err0;
> >>> +	}
> >>> +
> >>> +	/* Index only, 18 bit long, lkey =3D itid << 8 | key */
> >>> +	mr->hw_mr.tid_type =3D QED_RDMA_TID_FMR;
> >>> +	mr->hw_mr.key =3D 0;
> >>> +	mr->hw_mr.pd =3D pd->pd_id;
> >>
> >> Do you have a real MR<->PD association in HW? If so, can you point me
> >> to the code that binds it? If not, any reason not to expose the
> local_dma_lkey?
> >>
> > Yes, we send the pd id to the FW in function qed_rdma_register_tid.
>=20
> Right, thanks.
>=20
> > In any case, if we didn't have the association in HW Wouldn't the
> > local_dma_lkey be relevant only to dma_mr ? ( code snippet above
> > refers to FMR)
>=20
> I was just sticking to a location in the code where you associate MR<->PD=
...
>=20
> The local_dma_lkey is a special key that spans the entire memory space an=
d
> unlike the notorious dma_mr, its not associated with a PD.
>=20
> See the code in ib_alloc_pd(), if the device does not support a single de=
vice
> local dma lkey, the core allocates a dma mr associated with the pd. If yo=
ur
> device has such a key, you can save a dma mr allocation for each pd in th=
e
> system.
Managed to miss this. Our device supports such a key, we'll add support.=20
