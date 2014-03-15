From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 2/3] bridge: trigger a bridge calculation upon port
	changes
Date: Sat, 15 Mar 2014 02:39:40 +0100
Message-ID: <20140315013940.GA28801@wotan.suse.de>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com> <1394680527-28970-3-git-send-email-mcgrof@do-not-panic.com> <CAHA+R7Pf6rM5h1uGiqrru5LkN9C7Nm7V42cucHSOV1s7_+F7Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7Pf6rM5h1uGiqrru5LkN9C7Nm7V42cucHSOV1s7_+F7Gw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 13, 2014 at 11:26:25AM -0700, Cong Wang wrote:
> On Wed, Mar 12, 2014 at 8:15 PM, Luis R. Rodriguez
> <mcgrof@do-not-panic.com> wrote:
> >                         spin_lock_bh(&p->br->lock);
> >                         err =3D br_setport(p, tb);
> > +                       changed =3D br_stp_recalculate_bridge_id(p->br);
>=20
> Looks like you only want to check if the mac addr gets changed here,

Nope, the reason why we want a full thorough check is that br_setport()
may change currently any of these:
                                                                           =
    =20
  * IFLA_BRPORT_MODE
  * IFLA_BRPORT_GUARD
  * IFLA_BRPORT_FAST_LEAVE
  * IFLA_BRPORT_PROTECT
  * IFLA_BRPORT_LEARNING,
  * IFLA_BRPORT_UNICAST_FLOOD
  * IFLA_BRPORT_COST
  * IFLA_BRPORT_PRIORITY
  * IFLA_BRPORT_STATE

That's good reason to trigger a good inspection. Having the MAC address
change would be simply collateral and its just something we need to do
some additional work for outside of the locking context.

> but br_stp_recalculate_bridge_id() does more than just checking it,
> are you sure the side-effects are all what you want here?

Yeap.

> >                         spin_unlock_bh(&p->br->lock);
> > +                       if (changed)
> > +                               call_netdevice_notifiers(NETDEV_CHANGEA=
DDR,
> > +                                                        p->br->dev);
> > +                       netdev_update_features(p->br->dev);
>=20
> I think this is supposed to be in netdev event handler of br->dev
> instead of here.

Do you mean netdev_update_features() ? I mimic'd what was being done on
br_del_if() given that root blocking is doing something similar. If
we need to change something for the above then I suppose it means we need
to change br_del_if() too. Let me know if you see any reason for something
else.

  Luis

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iQIcBAEBAgAGBQJTI69cAAoJEPep4JnvMe6zBXUQALlx2cRo/BS6YgXGAzVf38zU
s0A6ea1zlvQneip/PAmLrmL+qCKEq+aEHPpM/tjKHzftDOk82CSgNH9aa2nSB6DT
WeJSlskszW9Otb0Fu0HodioN4+ViNE7ZPYJ5Sm9lCtiM1CV5jDSSrFWjFX5s43LU
EqRWkE7QuMcvPTNzDvwPgr2FECpoqbSybTTKIHlKRCpnZlAA5jwnzkHt7iC8VLo3
7MvWgayax/JGJCE3TmwXPzAgLhemYnBE7ltAt5b+na2Exkil0sje1vZouNkjC1Qx
lT60/vDmo/w+BgLshG6tY87yJx87CvB9dc7VzK2bDfcny9mjJIfcv7BjatOD5UCF
XpR1M/onnBG2nMYQpWwRKzcu4bHJP1EmLxgl89aWFQBpllHb3gx61EJ0ZZTFDiWw
kAGEnbN5d4+Wl9WythLKEZMrC0UBewtCRyXtMmOpoz1A6zE1ST5VKXGsLPH6ALQ3
vfWZsxWZrkAvHWD/zudyXQsl99zj0KYUxGzguqiQQNW+dpYBB0xH2Q+ew0S/MuXo
/HPgiTcm/Pkv21lAiaV9f8pqNcpqfKfK21AZvWita4QmJGUf6X2uOEUMOWFyEIJJ
EtExV0WbZIDhv9sqQewopbUEmBjTOygq/H9r2UE9Qi6DQk5AxSChLsFk9svwEIvj
Zo8NtXCbpYQlkqsAvSz7
=wjkU
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--
