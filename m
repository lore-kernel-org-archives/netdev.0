From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH 10/14] SIWv2: Transmit path: siw_qp_tx.c
Date: Mon, 20 Jun 2011 14:33:00 +0200
Message-ID: <OF564FAAA3.FC8A4AB9-ONC12578B5.003C1E38-C12578B5.0044F0C1@ch.ibm.com>
References: <BANLkTimSqwBK_pEGsydCAEvO=S6WVVzDPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTimSqwBK_pEGsydCAEvO=S6WVVzDPQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote on 06/18/2011 07:47:29 PM:

> On Thu, Jun 16, 2011 at 2:42 PM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
wrote:
> > ---
> > =A0drivers/infiniband/hw/siw/siw_qp_tx.c | 1332
> +++++++++++++++++++++++++++++++++
> > =A01 files changed, 1332 insertions(+), 0 deletions(-)
> > =A0create mode 100644 drivers/infiniband/hw/siw/siw_qp_tx.c
> >
> > diff --git a/drivers/infiniband/hw/siw/siw_qp_tx.c
> b/drivers/infiniband/hw/siw/siw_qp_tx.c
> [ ... ]
> > +/*
> > + * Write out iov referencing hdr, data and trailer of current FPDU=
=2E
> > + * Update transmit state dependent on write return status
> > + */
> > +static int siw_tx_hdt(struct siw_iwarp_tx *c_tx, struct socket *s)
> > +{
> > + =A0 =A0 =A0 struct siw_wqe =A0 =A0 =A0 =A0 =A0*wqe =3D c_tx->wqe;
> > + =A0 =A0 =A0 struct siw_sge =A0 =A0 =A0 =A0 =A0*sge =3D &wqe->wr.s=
gl.sge[c_tx->sge_idx],
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *firs=
t_sge =3D sge;
> > + =A0 =A0 =A0 struct siw_mr =A0 =A0 =A0 =A0 =A0 *mr =3D NULL;
> > + =A0 =A0 =A0 struct ib_umem_chunk =A0 =A0*chunk =3D c_tx->umem_chu=
nk;
> > +
> > + =A0 =A0 =A0 struct kvec =A0 =A0 =A0 =A0 =A0 =A0 iov[MAX_ARRAY];
> > + =A0 =A0 =A0 struct page =A0 =A0 =A0 =A0 =A0 =A0 *page_array[MAX_A=
RRAY];
> > + =A0 =A0 =A0 struct msghdr =A0 =A0 =A0 =A0 =A0 msg =3D {.msg_flags=
 =3D MSG_DONTWAIT};
> > +
> > + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seg =3D 0=
, do_crc =3D c_tx->do_crc,
> is_kva =3D 0, rv;
> > + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0data_len =3D c_tx=
->bytes_unsent,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hdr_l=
en =3D 0,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trl_l=
en =3D 0,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sge_o=
ff =3D c_tx->sge_off,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sge_i=
dx =3D c_tx->sge_idx,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_id=
x =3D c_tx->pg_idx;
>
> Have you run the siw source code through sparse ? Sparse reports the
> following for the above:
>
yes, I did.

> drivers/infiniband/hw/siw/siw_qp_tx.c:694:1: warning: the frame size
> of 1120 bytes is larger than 1024 bytes
>
> I assume that you know that one should be careful with stack
> allocations in the kernel ?
>
yes. I will have to make the MAX_ARRAY parameter smaller. It
defines the maximum amount of elements in a vector to be pushed to
tcp_sendmsg() in one call.
In an older version of the code we pushed iwarp header, data pages
and iwarp trailer in several consecutive calls. While the code looked
cleaner, it induced a measureable performance penalty. A smaller
MAX_ARRAY will also restrict the maximum allowed scatter-gather-element=
s
in a work request to a smaller safe value (currently 10 SGEs),
since the code intentionally tries to pack as many SGEs
into one iwarp frame as possible.
Alternatively, the vector could be part of the queue pair
structure, but that would significantly increase per connection
memory footprint, which we wanted to avoid.

> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx_type =3D=3D RDMAP_RDMA_READ_RE=
Q) {
>
> This is what the compiler says about the above statement:
>
> drivers/infiniband/hw/siw/siw_qp_tx.c:1145:15: warning: comparison
> between enum siw_wr_opcode and enum rdma_opcode
>
> So how can that statement be correct ?
>
it will not - must be changed to 'SIW_WR_RDMA_READ_REQ'...many thanks!
I obviously used sparse in a wrong way:
building within kernel tree with 'make C=3D1 CF=3D"-Wsparse-all' does n=
ot give
me the indicated warning (neither does setting CF=3D"-Wenum-mismatch").
Can you please advice? Thank you and sorry for the newbie question.

Bernard.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
