From: Sven Eckelmann <sven@narfation.org>
Subject: Re: net, batman: lockdep circular dependency warning
Date: Tue, 04 Dec 2012 15:51:55 +0100
Message-ID: <2538946.bxqpERrOoj@bentobox>
References: <50A15E1B.1010001@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1956917.Spt0yMSqin"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: quoted-printable
Cc: Sasha Levin <sasha.levin@oracle.com>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40943 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224Ab2LDOwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 09:52:04 -0500
In-Reply-To: <50A15E1B.1010001@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart1956917.Spt0yMSqin
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

Hi,

thanks for your report. It seems nobody else wanted to give an answer..=
. so I=20
try to give a small overview.

On Monday 12 November 2012 15:37:47 Sasha Levin wrote:
> Hi all,
>=20
> While fuzzing with trinity inside a KVM tools (lkvm) guest running la=
test
> -next kernel, I've stumbled on the following:
>=20
> [ 1002.969392] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [ 1002.971639] [ INFO: possible circular locking dependency detected =
]
> [ 1002.975805] 3.7.0-rc5-next-20121112-sasha-00018-g2f4ce0e #127 Tain=
ted: G=20
>       W [ 1002.983691]
> ------------------------------------------------------- [ 1002.983691=
]
> trinity-child18/8149 is trying to acquire lock:
> [ 1002.983691]  (s_active#313){++++.+}, at: [<ffffffff812f9941>]
> sysfs_addrm_finish+0x31/0x60 [ 1002.983691]
> [ 1002.983691] but task is already holding lock:
> [ 1002.983691]  (rtnl_mutex){+.+.+.}, at: [<ffffffff834fcc62>]
> rtnl_lock+0x12/0x20 [ 1002.983691]
> [ 1002.983691] which lock already depends on the new lock.

It is known that batman-adv has a problem with the attaching/detaching =
of=20
interfaces over this sysfs. The cause of this problem is related to the=
 fact=20
that batman-adv not only creates its own net_devices, but also unregist=
ers=20
net_devices. This unregister will add a new element in the net_todo_lis=
t. This=20
will cause a rtnl_lock when it calls netdev_wait_allrefs (there are som=
e=20
condition, but we just ignore them for now). So the whole exercise of u=
sing=20
rtnl_trylock was useless.

This extra rtnl_lock can cause a deadlock as you found out because it i=
s=20
activated through a sysfs file and therefore the s_active mutex is lock=
ed (we=20
have the dependency s_active -> rtnl_mutex, but other users have rtnl_m=
utex ->=20
s_active).

So, what to do? There are different possibilities. We have to keep in m=
ind=20
that there is a patchset (not yet accepted by the batman-adv maintainer=
s)=20
which allows to use `ip link` or compatible tools to create/destroy bat=
man-adv=20
devices and attach/detach other devices.

1. Remove the sysfs interface to attach/detach net_devices (which
   destroys/creates batman-adv devices)

   This is not really backward compatible and therefore not really acce=
ptable.
   Marek Lindner and Simon Wunderlich are also against forcing users to=

   require special tools to add/configure batman-adv devices (even batc=
tl, ip
   and so on).

2. Ignore the possible deadlock

   (sry, fill in your own comment...)

3. Add workarounds in the core net code

   Simon Wunderlich already tried it... I personally think it is not th=
e right
   way because it more likely to introduce more bugs by hiding a batman=
-adv
   bug. And these bugs are a lot harder to find... trust me

   For example the usage of __rtnl_unlock will let this bug to appear i=
n
   other places which use rtnl_trylock. This is caused by the fact that=
 the
   todo item isn't processed by __rtnl_unlock (this is the whole idea b=
y
   calling it) and therefore the todo work stays in net_todo_list. Anot=
her
   user of rtnl_trylock will now call rtnl_unlock and don't expect an e=
ntry in
   net_todo_list because he never unregistered a device. So he now has =
the
   problem of batman-adv (what an unsocial l=E4derlappen).

   And moving everybody using rtnl_trylock to __rtnl_unlock has still t=
he
   problem that batman-adv don't immediatelly work on its todo and so
   maybe causes other side effects because... the notifications weren't=

   sent and therefore the refcount of the unregistered device didn't we=
nt
   to zero.

   (I'll leave other side effects as homework for the reader)

4. Don't automatically remove batman-adv devices

   The current approach is to automatically unregister batman-adv devic=
es
   when they don't have attached slave-devices (hardif called by batman=
-adv).
   Removing this will slightly change the behaviour, but the interface =
can
   still be removed using `ip link del dev bat0` or a similar tool.

5. Add a workaround solution and promote the use of the standard interf=
ace

   So, the basic problem is the s_active mutex locked by the sysfs inte=
rface.
   An idea is to postpone the part which needs the rtnl_mutex to a late=
r time.
   This has obviously the problem that we cannot return an error code t=
o the
   caller when the device creation failed in the postponed part. This p=
roblem
   can reduced slightly be moving only the unregister part, but now I'l=
l leave
   this out for simplicity of the description.

   A possible implementation would create a work_struct and add it to
   batadv_event_workqueue. This work item has to contain all informatio=
n given
   by the user (which hardif, name of the batman-adv device).

   Simon Wunderlich already disliked this workaround, but Antonio Quart=
ulli
   tried to encourage an RFC implementation. I've prefered a textual
   description rather than a patch missing explanations of the other
   alternatives.

Kind regards,
=09Sven
--nextPart1956917.Spt0yMSqin
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQvg4LAAoJEF2HCgfBJntGCpEQAMiM9DeLIDvj/ZX+cAwzJaju
JXORRJawtc8yfcxQuBxwzHntC0ker/SiFVDSN3YelWr1Ld9jEWT3ALm3qZu+TYYK
79sQeTSaGFETv1m6toJkI41D7DWnHop1d24aI133+fBTOmUVDcvVgcIfMCqELkSs
yZYj3SP5BsG/BaAA2wxkRI7aTguvIIRlN9IqDeRGx3//iYiX48ZIvy6XOm/jUhAI
rSkMMxR7KTrHEX8g0qBhPo1fJROqtlyTGU/ywpvbwWdvdpl5dbcSWd+KcBhUdbiH
2hWlwBJLwN20y9NhHWuc4HPl3NAxAVz20oX5cn3HP1PBCB6kECvx/m+uaLA/TpcV
/GIgufXGrZZFSRvnCZVEbbRYcAnHhgmIJ0HCCIMC5WPudA9EoYwBCUfRWEJeFWLc
JaIV4R2NYzyZaKfLNI3z5iohx4EMTh5x0ykOOsVJqaGgfrUiToscrtLsd1YSgCoL
uffHKE5inodMMfb2qp2McgF3CZepGXfWYg/xgot8XhKtGIjrwGEuGhgBTiUmdYNu
aBwPsDz15F989EN7vb9bWgA3P9n4a6aaGn3Fh4UlKnOnxjVqFI2RhYSpYUjnD4Kj
YbTuAs6gtMETY7lvoBF3TSkshARkdt3/QcqAN6FtqVaVKi1gTiLrwL32/GQKXFkt
pBOraxxVYyZQUxokQGUp
=VZml
-----END PGP SIGNATURE-----

--nextPart1956917.Spt0yMSqin--
