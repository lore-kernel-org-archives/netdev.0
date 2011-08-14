From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 4/7] tuntap: multiqueue support
Date: Sun, 14 Aug 2011 02:05:25 -0400 (EDT)
Message-ID: <1465655104.165911.1313301925197.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
References: <1313159376.2354.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	mirq-linux@rere.qmqm.pl, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <1313159376.2354.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> Le vendredi 12 ao=C3=BBt 2011 =C3=A0 09:55 +0800, Jason Wang a =C3=A9crit=
 :
>=20
> >+ rxq =3D skb_get_rxhash(skb);
> >+ if (rxq) {
> >+ tfile =3D rcu_dereference(tun->tfiles[rxq % numqueues]);
> >+ if (tfile)
> >+ goto out;
> >+ }
>=20
> You can avoid an expensive divide with following trick :
>=20
> u32 idx =3D ((u64)rxq * numqueues) >> 32;
>=20

Sure.

>=20
>=20
> > -static struct tun_struct *tun_get(struct file *file)
> > +static void tun_detach_all(struct net_device *dev)
> >  {
> > - return __tun_get(file->private_data);
> > + struct tun_struct *tun =3D netdev_priv(dev);
> > + struct tun_file *tfile, *tfile_list[MAX_TAP_QUEUES];
> > + int i, j =3D 0;
> > +
> > + spin_lock(&tun_lock);
> > +
> > + for (i =3D 0; i < MAX_TAP_QUEUES && tun->numqueues; i++) {
> > + tfile =3D rcu_dereference_protected(tun->tfiles[i],
> > + lockdep_is_held(&tun_lock));
> > + if (tfile) {
> > + wake_up_all(&tfile->wq.wait);
> > + tfile_list[i++] =3D tfile;
>=20
> typo here, you want tfile_list[j++] =3D tfile;
>=20

Yes, thanks for catching this.

> > + rcu_assign_pointer(tun->tfiles[i], NULL);
> > + rcu_assign_pointer(tfile->tun, NULL);
> > + --tun->numqueues;
> > + }
> > + }
> > + BUG_ON(tun->numqueues !=3D 0);
> > + spin_unlock(&tun_lock);
> > +
> > + synchronize_rcu();
> > + for(--j; j >=3D 0; j--)
> > + sock_put(&tfile_list[j]->sk);
> >  }
> >
>=20
> Could you take a look at net/packet/af_packet.c, to check how David
> did
> the whole fanout thing ?
>=20
> __fanout_unlink()
>=20
> Trick is to not leave NULL entries in the tun->tfiles[] array.
>=20
> It makes things easier in hot path.

Sure I would go to take a look at this.

>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
