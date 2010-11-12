From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 08:23:30 +0100
Message-ID: <1289546610.17691.1770.camel@edumazet-laptop>
References: <2129857903-1289528127-cardhu_decombobulator_blackberry.rim.net-1506931048-@bda083.bisx.prod.on.blackberry>
	 <20101111.182939.258124014.davem@davemloft.net>
	 <1289529269.3090.207.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	kuznet@ms2.inr.ac.ru, urs.thuermann@volkswagen.de,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jmorris@namei.org,
	remi.denis-courmont@nokia.com, pekkas@netcore.fi, sri@us.ibm.com,
	vladislav.yasevich@hp.com, tj@kernel.org, lizf@cn.fujitsu.com,
	joe@perches.com, shemminger@vyatta.com, hadi@mojatatu.com,
	ebiederm@xmission.com, adobriyan@gmail.com, jpirko@redhat.com,
	johannes.berg@intel.com, daniel.lezcano@free.fr, xemul@openvz.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, torvalds@linux-foundation.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35228 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab0KLHXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 02:23:39 -0500
In-Reply-To: <1289529269.3090.207.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 novembre 2010 =C3=A0 21:34 -0500, Dan Rosenberg a =C3=A9cri=
t :
> > I want whatever you replace it with to be equivalent for
> > object tracking purposes.
>=20
> In nearly all of the cases I fixed, the socket inode is already
> provided, which serves as a perfectly good unique identifier.  Would =
you
> prefer I include that information twice?

Oh well. Please read this answer carefuly.

Some facts to feed your next patch. I am very pleased you changed your
mind and that we keep useful information in kernel log.

1) Inode numbers are not guaranteed to be unique. Its a 32bit seq
number, and we dont check another socket inode use the same inode numbe=
r
(after 2^32 allocations it can happens)

2) /proc/net/ files can deliver same "line" of information several
times, because of their implementation.

3) Because of SLAB_DESTROY_BY_RCU, same 'kernel socket pointer' can be
seen several times in /proc/net/tcp & /proc/net/udp, but really on
different "sockets"

4) Some good applications use both the socket pointer and inode number
(tuple) to filter out the [2] problem. Dont break them, please ?
Anything that might break an application must be at the very least
tunable.

In my opinion, a good thing would be :

- Use a special printf() format , aka "secure pointer", as Thomas
suggested.

- Make sure you print different opaque values for two different kernel
pointers. This is mandatory.

- Make sure the NULL pointer stay as a NULL pointer to not let the
hostile user know your secret, and to ease debugging stuff.

- Have security experts advice to chose a nice crypto function, maybe
jenkin hash. Not too slow would be nice.


static unsigned long securize_kpointers_rnd;

At boot time, stick a random value in this variable.
(Maybe make sure the 5 low order bits are 0)

unsigned long opacify_kptr(unsigned long ptr)
{
	if (ptr =3D=3D 0)
		return ptr;
	if (capable(CAP_NET_ADMIN))
		return ptr;

	return some_crypto_hash(ptr, &securize_kpointers_rnd);
}

At least, use a central point, so that we can easily add/change the
logic if needed.

Please provide this patch in kernel/printk.c for initial review, then
once everybody is OK, you can send one patch for net tree.

No need to send 10 patches if we dont agree on the general principle.



