From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Date: Wed, 4 Nov 2009 14:04:14 +0200
Message-ID: <20091104120414.GE8398@redhat.com>
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <4AF0708B.4020406@gmail.com> <4AF07199.2020601@gmail.com> <4AF072EE.9020202@gmail.com> <4AF07BB7.1020802@gmail.com> <20091103195841.GB6669@redhat.com> <4AF09C70.6090505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Gregory Haskins <gregory.haskins@gmail.com>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org,
        akpm@linux-foundation.org, hpa@zytor.com,
        Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <4AF09C70.6090505@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 03, 2009 at 10:11:12PM +0100, Eric Dumazet wrote:
> Michael S. Tsirkin a =E9crit :
> >=20
> > Paul, you acked this previously. Should I add you acked-by line so
> > people calm down?  If you would rather I replace
> > rcu_dereference/rcu_assign_pointer with rmb/wmb, I can do this.
> > Or maybe patch Documentation to explain this RCU usage?
> >=20
>=20
> So you believe I am over-reacting to this dubious use of RCU ?
>=20
> RCU documentation is already very complex, we dont need to add yet anot=
her
> subtle use, and makes it less readable.
>=20
> It seems you use 'RCU api' in drivers/vhost/net.c as convenient macros =
:
>=20
> #define rcu_dereference(p)     ({ \
>                                 typeof(p) _________p1 =3D ACCESS_ONCE(p=
); \
>                                 smp_read_barrier_depends(); \
>                                 (_________p1); \
>                                 })
>=20
> #define rcu_assign_pointer(p, v) \
>         ({ \
>                 if (!__builtin_constant_p(v) || \
>                     ((v) !=3D NULL)) \
>                         smp_wmb(); \
>                 (p) =3D (v); \
>         })
>=20
>=20
> There are plenty regular uses of smp_wmb() in kernel, not related to Re=
ad Copy Update,
> there is nothing wrong to use barriers with appropriate comments.

Well, what I do has classic RCU characteristics: readers do not take
locks, writers take a lock and flush after update. This is why I believe
rcu_dereference and rcu_assign_pointer are more appropriate here than
open-coding barriers.

Before deciding whether it's a good idea to open-code barriers
instead, I would like to hear Paul's opinion.

>=20
> (And you already use mb(), wmb(), rmb(), smp_wmb() in your patch)

Yes, virtio guest pretty much forces this, there's no way to share
a lock with the guest.

> BTW there is at least one locking bug in vhost_net_set_features()
>=20
> Apparently, mutex_unlock() doesnt trigger a fault if mutex is not locke=
d
> by current thread... even with DEBUG_MUTEXES / DEBUG_LOCK_ALLOC
>=20
>=20
> static void vhost_net_set_features(struct vhost_net *n, u64 features)
> {
>        size_t hdr_size =3D features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)=
 ?
>                sizeof(struct virtio_net_hdr) : 0;
>        int i;
> <<!>>  mutex_unlock(&n->dev.mutex);
>        n->dev.acked_features =3D features;
>        smp_wmb();
>        for (i =3D 0; i < VHOST_NET_VQ_MAX; ++i) {
>                mutex_lock(&n->vqs[i].mutex);
>                n->vqs[i].hdr_size =3D hdr_size;
>                mutex_unlock(&n->vqs[i].mutex);
>        }
>        mutex_unlock(&n->dev.mutex);
>        vhost_net_flush(n);
> }

Thanks very much for spotting this! Will fix.

--=20
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
