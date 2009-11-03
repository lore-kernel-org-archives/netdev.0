From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Date: Tue, 03 Nov 2009 22:11:12 +0100
Message-ID: <4AF09C70.6090505@gmail.com>
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <4AF0708B.4020406@gmail.com> <4AF07199.2020601@gmail.com> <4AF072EE.9020202@gmail.com> <4AF07BB7.1020802@gmail.com> <20091103195841.GB6669@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Gregory Haskins <gregory.haskins@gmail.com>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org,
        akpm@linux-foundation.org, hpa@zytor.com,
        Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20091103195841.GB6669@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin a =E9crit :
>=20
> Paul, you acked this previously. Should I add you acked-by line so
> people calm down?  If you would rather I replace
> rcu_dereference/rcu_assign_pointer with rmb/wmb, I can do this.
> Or maybe patch Documentation to explain this RCU usage?
>=20

So you believe I am over-reacting to this dubious use of RCU ?

RCU documentation is already very complex, we dont need to add yet anothe=
r
subtle use, and makes it less readable.

It seems you use 'RCU api' in drivers/vhost/net.c as convenient macros :

#define rcu_dereference(p)     ({ \
                                typeof(p) _________p1 =3D ACCESS_ONCE(p);=
 \
                                smp_read_barrier_depends(); \
                                (_________p1); \
                                })

#define rcu_assign_pointer(p, v) \
        ({ \
                if (!__builtin_constant_p(v) || \
                    ((v) !=3D NULL)) \
                        smp_wmb(); \
                (p) =3D (v); \
        })


There are plenty regular uses of smp_wmb() in kernel, not related to Read=
 Copy Update,
there is nothing wrong to use barriers with appropriate comments.

(And you already use mb(), wmb(), rmb(), smp_wmb() in your patch)


BTW there is at least one locking bug in vhost_net_set_features()

Apparently, mutex_unlock() doesnt trigger a fault if mutex is not locked
by current thread... even with DEBUG_MUTEXES / DEBUG_LOCK_ALLOC


static void vhost_net_set_features(struct vhost_net *n, u64 features)
{
       size_t hdr_size =3D features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
               sizeof(struct virtio_net_hdr) : 0;
       int i;
<<!>>  mutex_unlock(&n->dev.mutex);
       n->dev.acked_features =3D features;
       smp_wmb();
       for (i =3D 0; i < VHOST_NET_VQ_MAX; ++i) {
               mutex_lock(&n->vqs[i].mutex);
               n->vqs[i].hdr_size =3D hdr_size;
               mutex_unlock(&n->vqs[i].mutex);
       }
       mutex_unlock(&n->dev.mutex);
       vhost_net_flush(n);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
