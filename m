From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Tue, 13 Apr 2010 08:52:27 -0700
Message-ID: <20100413155227.GC2538@linux.vnet.ibm.com>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
 <1271146112.16881.213.camel@edumazet-laptop>
 <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:41798 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573Ab0DMPwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 11:52:30 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3DFbPtX027344
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 11:37:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3DFqTjc1445946
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 11:52:29 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3DFqSib005582
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 11:52:28 -0400
Content-Disposition: inline
In-Reply-To: <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 05:50:29PM +0800, Changli Gao wrote:
> On Tue, Apr 13, 2010 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Probably not necessary.
> >
> >> + =C2=A0 =C2=A0 volatile bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 f=
lush_processing_queue;
> >
> > Use of 'volatile' is strongly discouraged, I would say, forbidden.
>=20
> volatile is used to avoid compiler optimization.

Would it be reasonable to use ACCESS_ONCE() where this variable is used=
?

						Thanx, Paul

> > Its usually a sign of 'I dont exactly what memory ordering I need, =
so I
> > throw a volatile just in case'. We live in a world full of RCU, rea=
d ,
> > write, full barriers. And these apis are well documented.
> >
>=20
> There isn't memory accessing order problem.
>=20
> >> @@ -2803,6 +2808,7 @@ static void flush_backlog(void *arg)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 __skb_unlink(skb, &queue->input_pkt_queue);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 kfree_skb(skb);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 queue->flush_processing_queue =3D true;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Probably not necessary
> >
>=20
> If flush_backlog() is called when there are still packets in
> processing_queue, there maybe some packets refer to the netdev gone,
> if we remove this line.
>=20
> >> =C2=A0 =C2=A0 =C2=A0 rps_unlock(queue);
> >> =C2=A0}
> >>
> >> @@ -3112,14 +3118,23 @@ static int process_backlog(struct napi_str=
uct *napi, int quota)
> >> =C2=A0 =C2=A0 =C2=A0 struct softnet_data *queue =3D &__get_cpu_var=
(softnet_data);
> >> =C2=A0 =C2=A0 =C2=A0 unsigned long start_time =3D jiffies;
> >>
> >> + =C2=A0 =C2=A0 if (queue->flush_processing_queue) {
> >
> > Really... this is bloat IMHO
>=20
>=20
> Any better idea?
>=20
> >
> >>
> >
> > I advise to keep it simple.
> >
> > My suggestion would be to limit this patch only to process_backlog(=
).
> >
> > Really if you touch other areas, there is too much risk.
> >
> > Perform sort of skb_queue_splice_tail_init() into a local (stack) q=
ueue,
> > but the trick is to not touch input_pkt_queue.qlen, so that we dont=
 slow
> > down enqueue_to_backlog().
> >
> > Process at most 'quota' skbs (or jiffies limit).
> >
> > relock queue.
> > input_pkt_queue.qlen -=3D number_of_handled_skbs;
> >
>=20
> Oh no, in order to let latter packets in as soon as possible, we have
> to update qlen immediately.
>=20
> --=20
> Regards=EF=BC=8C
> Changli Gao(xiaosuo@gmail.com)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
