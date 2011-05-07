From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 14:22:06 +0200
Message-ID: <1304770926.2821.1157.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55753 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361Ab1EGMWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 08:22:10 -0400
Received: by wwa36 with SMTP id 36so4334003wwa.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 05:22:09 -0700 (PDT)
In-Reply-To: <891B02256A0667292521A4BF@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 12:08 +0100, Alex Bligh a =C3=A9crit :
> I am trying to track down why interface creation slows down badly wit=
h
> large numbers of interfaces (~1,000 interfaces) and why deletion is s=
o
> slow. Use case: restarting routers needs to be fast; some failover me=
thods
> require interface up/down; some routers need lots of interfaces.
>=20
> I have written a small shell script to create and delete a number of
> interfaces supplied on the command line (script appended below). It
> is important to run this with udev, udev-bridge etc. disabled. In
> my environment
> (Ubuntu 2.6.32-28-generic, Lucid). I did this by
>  * service upstart-udev-bridge stop
>  * service udev stop
>  * unshare -n bash
> If you don't do this, you are simply timing your distro's interface
> scripts.
>=20
> Note the "-n" parameter creates the supplied number of veth pair
> interfaces. As these are pairs, there are twice as many interfaces ac=
tually
> created.
>=20
> So, the results which are pretty repeatable are as follows:
>=20
>                             100 pairs      500 pairs
> Interface creation               14ms          110ms
> Interface deletion              160ms          148ms
>=20
> Now I don't think interface deletion has in fact got faster: simply
> the overhead of loading the script is spread over more processes.
> But there are two obvious conclusions:
>=20
> 1. Interface creation slows down hugely with more interfaces

sysfs is the problem, a very well known one.
(sysfs_refresh_inode(),=20

try :

$ time ls /sys/class/net >/dev/null

real	0m0.002s
user	0m0.000s
sys	0m0.001s
$ modprobe dummy numdummies=3D1000
$ time ls /sys/class/net >/dev/null

real	0m0.041s
user	0m0.003s
sys	0m0.002s


> 2. Interface deletion is normally much slower than interface creation
>=20
> strace -T -ttt on the "ip" command used to do this does not show the =
delay
> where I thought it would be - cataloguing the existing interfaces. In=
stead,
> it's the final send() to the netlink socket which does the relevant a=
ction
> which appears to be slow, for both addition and detion. Adding the la=
st
> interface takes 200ms in that syscall, the first is quick (symptomati=
c of a
> slowdown); for deletion the last send syscall is quick.
>=20
> Poking about in net/core/dev.c, I see that interface names are hashed=
 using
> a hash with a maximum of 256 entries. However, these seem to be hash
> buckets supporting multiple entries so I can't imagine a chain of 4 e=
ntries
> is problematic.

Its not.

>=20
> I am having difficulty seeing what might be the issue in interface
> creation. Any ideas?
>=20

Actually a lot, just make

git log net/core/dev.c

and you'll see many commits to make this faster.

> In interface deletion, my attention is drawn to netdev_wait_allrefs,
> which does this:
>         refcnt =3D netdev_refcnt_read(dev);
>=20

Here refcnt is 0, or there is a bug somewhere.
(It happens, we fix bugs once in a while)

>         while (refcnt !=3D 0) {
>                 ...
>                 msleep(250);
>=20
>                 refcnt =3D netdev_refcnt_read(dev);
> 		....
>         }
>=20
> I am guessing that this is going to do the msleep 50% of the time,
> explaining 125ms of the observed time. How would people react to
> exponential backoff instead (untested):
>=20
> 	int backoff =3D 10;
>         refcnt =3D netdev_refcnt_read(dev);
>=20
>         while (refcnt !=3D 0) {
>                 ...
>                 msleep(backoff);
>                 if ((backoff *=3D 2) > 250)
>                   backoff =3D 250;
> 	=09
>                 refcnt =3D netdev_refcnt_read(dev);
> 		....
>         }
>=20
>=20

Welcome to the club. This is what is discussed on netdev since many
years. Lot of work had been done to make it better.

Interface deletion needs several rcu synch calls, they are very
expensive. This is the price to pay to have lockless network stack in
fast paths.



