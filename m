From: <Parav.Pandit@Emulex.Com>
Subject: RE: [PATCH 1/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 11:58:31 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A63EC@EXMAIL.ad.emulex.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <3f46a051-ee2e-4e18-becf-60f6c023c3c6@exht1.ad.emulex.com>
 <CAL1RGDVFTjsF43A9ebXwtgiuY5s1yuhFg2CRajABZ=MTeT0+Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>
To: <roland@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:34634 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755806Ab2CUS6y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 14:58:54 -0400
In-Reply-To: <CAL1RGDVFTjsF43A9ebXwtgiuY5s1yuhFg2CRajABZ=MTeT0+Pg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Roland Dreier [mailto:roland@purestorage.com]
> Sent: Wednesday, March 21, 2012 9:44 PM
> To: Pandit, Parav
> Cc: linux-rdma@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH 1/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
>=20
> > +#define ocrdma_err(format, arg...) printk(KERN_ERR format, ##arg)
>=20
> I think you'd be better off using pr_err() rather than defining your =
own
> macro.
o.k. I'll change it.

>=20
>=20
> > +struct ocrdma_cq {
> > + =A0 =A0 =A0 struct ib_cq ibcq;
> > + =A0 =A0 =A0 struct ocrdma_dev *dev;
> > + =A0 =A0 =A0 struct ocrdma_cqe *va;
> > + =A0 =A0 =A0 u32 phase;
> > + =A0 =A0 =A0 u32 getp; =A0 =A0 =A0 /* pointer to pending wrs to
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* return to stack,=
 wrap arounds
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* at max_hw_cqe
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > + =A0 =A0 =A0 u32 max_hw_cqe;
> > + =A0 =A0 =A0 bool phase_change;
> > + =A0 =A0 =A0 bool armed, solicited;
> > + =A0 =A0 =A0 bool arm_needed;
> > +
> > + =A0 =A0 =A0 spinlock_t cq_lock ____cacheline_aligned; /* provide
> > + synchronization
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to cq polling
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > + =A0 =A0 =A0 /* syncronizes cq completion handler invoked from mul=
tiple
> > + context */
> > + =A0 =A0 =A0 spinlock_t comp_handler_lock ____cacheline_aligned;
>=20
> You have quite a few of these alignment directives in the middle of
> structures.
> Have you measured that leaving all these gaps gives a reall performan=
ce
> boost?
>=20
=46rom beginning its cacheline aligned. So didn't tested it without it,=
 but yes this is considered. I'll be shifting other widely used element=
s before the lock so that hole is smaller.

> > + =A0 =A0 =A0 u16 id;
> > + =A0 =A0 =A0 u16 eqn;
> > +
> > + =A0 =A0 =A0 struct ocrdma_ucontext *ucontext;
> > + =A0 =A0 =A0 dma_addr_t pa;
> > + =A0 =A0 =A0 u32 len;
> > + =A0 =A0 =A0 atomic_t use_cnt;
> > +
> > + =A0 =A0 =A0 /* head of all qp's sq and rq for which cqes need to =
be
> > +flushed
> > + =A0 =A0 =A0 =A0* by the software.
> > + =A0 =A0 =A0 =A0*/
> > + =A0 =A0 =A0 struct list_head sq_head, rq_head; };
>=20
>=20
> > +#define OCRDMA_GET_NUM_POSTED_SHIFT_VAL(qp) \
> > + =A0 =A0 =A0 (((qp->dev->nic_info.dev_family =3D=3D OCRDMA_GEN2_FA=
MILY) && \
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (qp->id < 64)) ? 24 : 16)
>=20
> In general it's better to use inline functions when possible instead =
of macros,
> which are less type-safe and harder to read.
o.k. I'll change it.
