From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Subject: Re: [B.A.T.M.A.N.] net, batman: lockdep circular dependency warning
Date: Wed, 5 Dec 2012 16:33:08 +0100
Message-ID: <20121205153307.GA30466@pandem0nium>
References: <50A15E1B.1010001@oracle.com>
 <2538946.bxqpERrOoj@bentobox>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
Cc: netdev@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nick.hrz.tu-chemnitz.de ([134.109.228.11]:48132 "EHLO
	nick.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab2LEPdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 10:33:16 -0500
Content-Disposition: inline
In-Reply-To: <2538946.bxqpERrOoj@bentobox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey Sven,

thanks for showing these approaches! Comments inline ...

On Tue, Dec 04, 2012 at 03:51:55PM +0100, Sven Eckelmann wrote:
> Hi,
>=20
> thanks for your report. It seems nobody else wanted to give an answer... =
so I=20
> try to give a small overview.
>=20
> On Monday 12 November 2012 15:37:47 Sasha Levin wrote:
> > Hi all,
> >=20
> > While fuzzing with trinity inside a KVM tools (lkvm) guest running late=
st
> > -next kernel, I've stumbled on the following:
> >=20
> > [ 1002.969392] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [ 1002.971639] [ INFO: possible circular locking dependency detected ]
> > [ 1002.975805] 3.7.0-rc5-next-20121112-sasha-00018-g2f4ce0e #127 Tainte=
d: G=20
> >       W [ 1002.983691]
> > ------------------------------------------------------- [ 1002.983691]
> > trinity-child18/8149 is trying to acquire lock:
> > [ 1002.983691]  (s_active#313){++++.+}, at: [<ffffffff812f9941>]
> > sysfs_addrm_finish+0x31/0x60 [ 1002.983691]
> > [ 1002.983691] but task is already holding lock:
> > [ 1002.983691]  (rtnl_mutex){+.+.+.}, at: [<ffffffff834fcc62>]
> > rtnl_lock+0x12/0x20 [ 1002.983691]
> > [ 1002.983691] which lock already depends on the new lock.
>=20
> It is known that batman-adv has a problem with the attaching/detaching of=
=20
> interfaces over this sysfs. The cause of this problem is related to the f=
act=20
> that batman-adv not only creates its own net_devices, but also unregister=
s=20
> net_devices. This unregister will add a new element in the net_todo_list.=
 This=20
> will cause a rtnl_lock when it calls netdev_wait_allrefs (there are some=
=20
> condition, but we just ignore them for now). So the whole exercise of usi=
ng=20
> rtnl_trylock was useless.
>=20
> This extra rtnl_lock can cause a deadlock as you found out because it is=
=20
> activated through a sysfs file and therefore the s_active mutex is locked=
 (we=20
> have the dependency s_active -> rtnl_mutex, but other users have rtnl_mut=
ex ->=20
> s_active).
>=20
> So, what to do? There are different possibilities. We have to keep in min=
d=20
> that there is a patchset (not yet accepted by the batman-adv maintainers)=
=20
> which allows to use `ip link` or compatible tools to create/destroy batma=
n-adv=20
> devices and attach/detach other devices.
>=20
> 1. Remove the sysfs interface to attach/detach net_devices (which
>    destroys/creates batman-adv devices)
>=20
>    This is not really backward compatible and therefore not really accept=
able.
>    Marek Lindner and Simon Wunderlich are also against forcing users to
>    require special tools to add/configure batman-adv devices (even batctl=
, ip
>    and so on).
>=20

Yeah, at least I think we should keep what we have for now and fix it before
moving to the next interface. It has its merits I would like to keep, having
text output is one of them. :)

> 2. Ignore the possible deadlock
>=20
>    (sry, fill in your own comment...)
>=20

That probably won't help. :)

> 3. Add workarounds in the core net code
>=20
>    Simon Wunderlich already tried it... I personally think it is not the =
right
>    way because it more likely to introduce more bugs by hiding a batman-a=
dv
>    bug. And these bugs are a lot harder to find... trust me
>=20
>    For example the usage of __rtnl_unlock will let this bug to appear in
>    other places which use rtnl_trylock. This is caused by the fact that t=
he
>    todo item isn't processed by __rtnl_unlock (this is the whole idea by
>    calling it) and therefore the todo work stays in net_todo_list. Another
>    user of rtnl_trylock will now call rtnl_unlock and don't expect an ent=
ry in
>    net_todo_list because he never unregistered a device. So he now has the
>    problem of batman-adv (what an unsocial l=C3=A4derlappen).
>=20
>    And moving everybody using rtnl_trylock to __rtnl_unlock has still the
>    problem that batman-adv don't immediatelly work on its todo and so
>    maybe causes other side effects because... the notifications weren't
>    sent and therefore the refcount of the unregistered device didn't went
>    to zero.
>=20
>    (I'll leave other side effects as homework for the reader)
>=20

You are right, it can probably not solved as easily as I thought before. Al=
so,
it seems the bridge code is not concerned as I thought at first. Although
I still don't like the rtnl_unlock() concept in general, but I can't provide
an alternative here so I should't moan about that. :)

> 4. Don't automatically remove batman-adv devices
>=20
>    The current approach is to automatically unregister batman-adv devices
>    when they don't have attached slave-devices (hardif called by batman-a=
dv).
>    Removing this will slightly change the behaviour, but the interface can
>    still be removed using `ip link del dev bat0` or a similar tool.
>=20

That would be possible, but we must at least make sure that the initializat=
ion
is done for all internal tables (tt, bla, ...), counters, seqnos, etc when =
the
first device is added. Otherwise old users might assume that the device is
resetted correctly when removing all hard interfaces of one soft interface
and add it again under the same soft interface name.

> 5. Add a workaround solution and promote the use of the standard interface
>=20
>    So, the basic problem is the s_active mutex locked by the sysfs interf=
ace.
>    An idea is to postpone the part which needs the rtnl_mutex to a later =
time.
>    This has obviously the problem that we cannot return an error code to =
the
>    caller when the device creation failed in the postponed part. This pro=
blem
>    can reduced slightly be moving only the unregister part, but now I'll =
leave
>    this out for simplicity of the description.

We probably won't need the return code anyway - usually it should never fai=
l,
and if it does we don't handle it now too.=20

>=20
>    A possible implementation would create a work_struct and add it to
>    batadv_event_workqueue. This work item has to contain all information =
given
>    by the user (which hardif, name of the batman-adv device).

Sounds good.

>=20
>    Simon Wunderlich already disliked this workaround, but Antonio Quartul=
li
>    tried to encourage an RFC implementation. I've prefered a textual
>    description rather than a patch missing explanations of the other
>    alternatives.

Well, actually that doesn't sound so bad - I currently don't have an overvi=
ew
of how "big" this change would be - this one was one concern, the return co=
de was
another but it appears that this isn't a problem. If we don't add too much =
bloat
this one would probably the best alternative. At least as long as rtnl_unlo=
ck()
behaves like this. :)

What do others think?

Cheers,
	Simon

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlC/aTMACgkQrzg/fFk7axbKlACgnjjNH1uJrOhqx24KbU0O9z9z
GM4AoO+YXnlmkY173Vob2a3B5Q4lXcSy
=Axjf
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--
