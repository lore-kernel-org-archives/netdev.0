From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Date: Wed, 4 Nov 2009 09:25:42 -0800
Message-ID: <20091104172542.GC6736@linux.vnet.ibm.com>
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <4AF0708B.4020406@gmail.com> <4AF07199.2020601@gmail.com> <4AF072EE.9020202@gmail.com> <20091103235744.GF6726@linux.vnet.ibm.com> <20091104115729.GD8398@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org,
        akpm@linux-foundation.org, hpa@zytor.com,
        Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20091104115729.GD8398@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 04, 2009 at 01:57:29PM +0200, Michael S. Tsirkin wrote:
> On Tue, Nov 03, 2009 at 03:57:44PM -0800, Paul E. McKenney wrote:
> > On Tue, Nov 03, 2009 at 01:14:06PM -0500, Gregory Haskins wrote:
> > > Gregory Haskins wrote:
> > > > Eric Dumazet wrote:
> > > >> Michael S. Tsirkin a =E9crit :
> > > >>> +static void handle_tx(struct vhost_net *net)
> > > >>> +{
> > > >>> +	struct vhost_virtqueue *vq =3D &net->dev.vqs[VHOST_NET_VQ_TX]=
;
> > > >>> +	unsigned head, out, in, s;
> > > >>> +	struct msghdr msg =3D {
> > > >>> +		.msg_name =3D NULL,
> > > >>> +		.msg_namelen =3D 0,
> > > >>> +		.msg_control =3D NULL,
> > > >>> +		.msg_controllen =3D 0,
> > > >>> +		.msg_iov =3D vq->iov,
> > > >>> +		.msg_flags =3D MSG_DONTWAIT,
> > > >>> +	};
> > > >>> +	size_t len, total_len =3D 0;
> > > >>> +	int err, wmem;
> > > >>> +	size_t hdr_size;
> > > >>> +	struct socket *sock =3D rcu_dereference(vq->private_data);
> > > >>> +	if (!sock)
> > > >>> +		return;
> > > >>> +
> > > >>> +	wmem =3D atomic_read(&sock->sk->sk_wmem_alloc);
> > > >>> +	if (wmem >=3D sock->sk->sk_sndbuf)
> > > >>> +		return;
> > > >>> +
> > > >>> +	use_mm(net->dev.mm);
> > > >>> +	mutex_lock(&vq->mutex);
> > > >>> +	vhost_no_notify(vq);
> > > >>> +
> > > >> using rcu_dereference() and mutex_lock() at the same time seems =
wrong, I suspect
> > > >> that your use of RCU is not correct.
> > > >>
> > > >> 1) rcu_dereference() should be done inside a read_rcu_lock() sec=
tion, and
> > > >>    we are not allowed to sleep in such a section.
> > > >>    (Quoting Documentation/RCU/whatisRCU.txt :
> > > >>      It is illegal to block while in an RCU read-side critical s=
ection, )
> > > >>
> > > >> 2) mutex_lock() can sleep (ie block)
> > > >>
> > > >=20
> > > >=20
> > > > Michael,
> > > >   I warned you that this needed better documentation ;)
> > > >=20
> > > > Eric,
> > > >   I think I flagged this once before, but Michael convinced me th=
at it
> > > > was indeed "ok", if but perhaps a bit unconventional.  I will try=
 to
> > > > find the thread.
> > > >=20
> > > > Kind Regards,
> > > > -Greg
> > > >=20
> > >=20
> > > Here it is:
> > >=20
> > > http://lkml.org/lkml/2009/8/12/173
> >=20
> > What was happening in that case was that the rcu_dereference()
> > was being used in a workqueue item.  The role of rcu_read_lock()
> > was taken on be the start of execution of the workqueue item, of
> > rcu_read_unlock() by the end of execution of the workqueue item, and
> > of synchronize_rcu() by flush_workqueue().  This does work, at least
> > assuming that flush_workqueue() operates as advertised, which it appe=
ars
> > to at first glance.
> >=20
> > The above code looks somewhat different, however -- I don't see
> > handle_tx() being executed in the context of a work queue.  Instead
> > it appears to be in an interrupt handler.
> > So what is the story?  Using synchronize_irq() or some such?
> >=20
> > 							Thanx, Paul
>=20
> No, there has been no change (I won't be able to use a mutex in an
> interrupt handler, will I?).  handle_tx is still called in the context
> of a work queue: either from handle_tx_kick or from handle_tx_net which
> are work queue items.

Ah, my mistake -- I was looking at 2.6.31 rather than latest git with
your patches.

> Can you ack this usage please?

I thought I had done so in my paragraph above, but if you would like
something a bit more formal...

	I, Paul E. McKenney, maintainer of the RCU implmentation
	embodied in the Linux kernel and co-inventor of RCU, being of
	sound mind and body, notwithstanding the wear and tear inherent
	in my numerous decades sojourn on this planet, hereby declare
	that the following usage of work queues constitutes a valid
	RCU implementation:

	1.	Execution of a full workqueue item being substituted
		for a conventional RCU read-side critical section, so
		that the start of execution of the function specified to
		INIT_WORK() corresponds to rcu_read_lock(), and the end of
		this self-same function corresponds to rcu_read_unlock().

	2.	Execution of flush_workqueue() being substituted for
		the conventional synchronize_rcu().

	The kernel developer availing himself or herself of this
	declaration must observe the following caveats:

	a.	The function specified to INIT_WORK() may only be
		invoked via the workqueue mechanism.  Invoking said
		function directly renders this declaration null
		and void, as it prevents the flush_workqueue() function
		from delivering the fundamental guarantee inherent in RCU.

	b.	At some point in the future, said developer may be
		required to apply some gcc attribute or sparse annotation
		to the function passed to INIT_WORK().	Beyond that
		point, failure to comply will render this declaration
		null and void, as such failure would render inoperative
		some potential RCU-validation tools, as duly noted by
		Eric Dumazet.

	c.	This declaration in no way relieves the developer of
		the responsibility to use this and other synchronization
		mechanisms correctly, again, as duly noted by Eric
		Dumazet.

(Sorry, but, as always, I could not resist!)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
