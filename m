From: Sergei Trofimovich <slyich@gmail.com>
Subject: Re: [PATCHv 2] tcp: properly initialize tcp memory limits part 2
 (fix nfs regression)
Date: Fri, 2 Mar 2012 20:50:00 +0300
Message-ID: <20120302205000.088bf231@sf.home>
References: <1330675173-18968-1-git-send-email-slyich@gmail.com>
	<4F509150.5060904@redhat.com>
	<20120302202421.753b36bc@sf.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/kfM1nuDy5/1jSc=OEoG88qy"; protocol="application/pgp-signature"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Glauber Costa <glommer@parallels.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120302202421.753b36bc@sf.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/kfM1nuDy5/1jSc=OEoG88qy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

> > > The change looks like a typo (division flipped to multiplication):
> > >> limit =3D nr_free_buffer_pages() / 8;
> > >> limit =3D nr_free_buffer_pages()<<  (PAGE_SHIFT - 10);
> >=20
> > Hi, thanks for the reporting. It's not a typo. It was previously:=20
> > sysctl_tcp_mem[1] << (PAGE_SHIFT -  7). Looks like we need to do the=20
> > limit check before shift the value. Please try the following patch, tha=
nks.
>=20
> Still does not help. I test it by checking sha1sum of a large file over N=
FS
> (small files seem to work simetimes):
>=20
>     $ strace sha1sum /gentoo/distfiles/gcc-4.6.2.tar.bz2=20
>     ...
>     open("/gentoo/distfiles/gcc-4.6.2.tar.bz2", O_RDONLY
>     <HUNG>
> After a certain timeout dmesg gets odd spam:
> [  314.848094] nfs: server vmhost not responding, still trying
> [  314.848134] nfs: server vmhost not responding, still trying
> [  314.848145] nfs: server vmhost not responding, still trying
> [  314.957047] nfs: server vmhost not responding, still trying
> [  314.957066] nfs: server vmhost not responding, still trying
> [  314.957075] nfs: server vmhost not responding, still trying
> [  314.957085] nfs: server vmhost not responding, still trying
> [  314.957100] nfs: server vmhost not responding, still trying
> [  314.958023] nfs: server vmhost not responding, still trying
> [  314.958035] nfs: server vmhost not responding, still trying
> [  314.958044] nfs: server vmhost not responding, still trying
> [  314.958054] nfs: server vmhost not responding, still trying
>=20
> looks like bogus messages. Might be relevant to mishandled timings
> somewhere else or a bug in nfs code.

And after 120 seconds hung tasks shows it might be an OOM issue
Likely caused by patch, as it's a 2GB RAM +4GB swap amd64 box
not running anything heavy:

[  720.798052] INFO: task sha1sum:3811 blocked for more than 120 seconds.
[  720.798056] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[  720.798059] sha1sum         D ffff88007bd11d40     0  3811      1 0x0000=
0005
[  720.798065]  ffff880073de9c08 0000000000000082 ffff880073de9af8 ffff8800=
73de9fd8
[  720.798070]  ffff880070db1620 ffff880073de9fd8 ffff880073de8000 00000000=
00004000
[  720.798075]  ffff880073de8000 ffff880073de9fd8 ffff8800790e0000 ffff8800=
70db1620
[  720.798079] Call Trace:
[  720.798089]  [<ffffffff810fdd53>] ? kfree+0x123/0x150
[  720.798094]  [<ffffffff8123227d>] ? nfs_access_free_entry+0x1d/0x30
[  720.798097]  [<ffffffff810fdd53>] ? kfree+0x123/0x150
[  720.798101]  [<ffffffff8123227d>] ? nfs_access_free_entry+0x1d/0x30
[  720.798104]  [<ffffffff81233cb8>] ? nfs_do_access+0x3a8/0x3d0
[  720.798109]  [<ffffffff8166525a>] schedule+0x3a/0x50
[  720.798112]  [<ffffffff8166390e>] __mutex_lock_slowpath+0xee/0x190
[  720.798117]  [<ffffffff81639228>] ? put_rpccred+0x48/0x130
[  720.798120]  [<ffffffff8166374e>] mutex_lock+0x1e/0x40
[  720.798125]  [<ffffffff81114927>] do_lookup+0x277/0x3a0
[  720.798128]  [<ffffffff811162b8>] do_last.clone.39+0x148/0x7e0
[  720.798132]  [<ffffffff81116a61>] path_openat+0xd1/0x3e0
[  720.798136]  [<ffffffff810604d1>] ? get_parent_ip+0x11/0x50
[  720.798140]  [<ffffffff81060675>] ? add_preempt_count+0x95/0xd0
[  720.798144]  [<ffffffff81666677>] ? _raw_spin_lock_irq+0x17/0x40
[  720.798147]  [<ffffffff81116e84>] do_filp_open+0x44/0xa0
[  720.798151]  [<ffffffff810605a5>] ? sub_preempt_count+0x95/0xd0
[  720.798154]  [<ffffffff81666371>] ? _raw_spin_unlock+0x11/0x40
[  720.798158]  [<ffffffff81123014>] ? alloc_fd+0xe4/0x130
[  720.798163]  [<ffffffff81106f7d>] do_sys_open+0xfd/0x1e0
[  720.798169]  [<ffffffff8100f290>] ? syscall_trace_enter+0xf0/0x1a0
[  720.798172]  [<ffffffff8110707c>] sys_open+0x1c/0x20
[  720.798176]  [<ffffffff81667219>] tracesys+0xd0/0xd5

--=20

  Sergei

--Sig_/kfM1nuDy5/1jSc=OEoG88qy
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk9RCEgACgkQcaHudmEf86pJQQCfY4Z/amPYoOflHA1yZnBzq9kU
FgwAn3ejqe7I1vlRZmUWLkXqq9wWbewd
=fwbX
-----END PGP SIGNATURE-----

--Sig_/kfM1nuDy5/1jSc=OEoG88qy--
