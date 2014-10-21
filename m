From: Kevin Fenzi <kevin@scrye.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Tue, 21 Oct 2014 15:12:25 -0600
Message-ID: <20141021151225.5df96645@voldemort.scrye.com>
References: <20141020141515.0688bf33@voldemort.scrye.com>
 <20141020204326.GA25668@redhat.com>
 <20141020145359.565fe5e6@voldemort.scrye.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 boundary="Sig_/8EpoeABSFT5aSPRhbEEQiaj"; protocol="application/pgp-signature"
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141020145359.565fe5e6@voldemort.scrye.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/8EpoeABSFT5aSPRhbEEQiaj
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 20 Oct 2014 14:53:59 -0600
Kevin Fenzi <kevin@scrye.com> wrote:

> On Mon, 20 Oct 2014 16:43:26 -0400
> Dave Jones <davej@redhat.com> wrote:
>=20
> > I've seen similar soft lockup traces from the sys_unshare path when
> > running my fuzz tester.  It seems that if you create enough network
> > namespaces, it can take a huge amount of time for them to be
> > iterated. (Running trinity with '-c unshare' you can see the slow
> > down happen. In some cases, it takes so long that the watchdog
> > process kills it -- though the SIGKILL won't get delivered until
> > the unshare() completes)
> >=20
> > Any idea what this machine had been doing prior to this that may
> > have involved creating lots of namespaces ?
>=20
> That was right after boot. ;)=20
>=20
> This is my main rawhide running laptop.
>=20
> A 'ip netns list' shows nothing.

Some more information:=20

The problem started between:=20

v3.17-7872-g5ff0b9e1a1da and v3.17-8307-gf1d0d14120a8

(I can try and do a bisect, but have to head out on a trip tomorrow)

In all the kernels with the problem, there is a kworker process in D.=20

sysrq-t says:=20
                                            Showing all locks held in the s=
ystem:
Oct 21 15:06:31 voldemort.scrye.com kernel: 4 locks held by kworker/u16:0/6:
Oct 21 15:06:31 voldemort.scrye.com kernel:  #0:  ("%s""netns"){.+.+.+}, at=
: [<ffffffff810ccbff>] process_one_work+0x17f/0x850
Oct 21 15:06:31 voldemort.scrye.com kernel:  #1:  (net_cleanup_work){+.+.+.=
}, at: [<ffffffff810ccbff>] process_one_work+0x17f/0x850
Oct 21 15:06:31 voldemort.scrye.com kernel:  #2:  (net_mutex){+.+.+.}, at: =
[<ffffffff817069fc>] cleanup_net+0x8c/0x1f0
Oct 21 15:06:31 voldemort.scrye.com kernel:  #3:
(rcu_sched_state.barrier_mutex){+.+...}, at: [<ffffffff8112a395>]
_rcu_barrier+0x35/0x200

On first running any of the systemd units that use PrivateNetwork, then
run ok, but they are also set to timeout after a minute. On sucessive
runs they hang in D also.

kevin

--Sig_/8EpoeABSFT5aSPRhbEEQiaj
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJURsw8AAoJEEs3sNgP+7te26UQALzAA3CzNnsuGPbEcKl96MYi
fU/INHD/fr1WL5cHQDVfUvhCQsdTNve3fgNxrlhoBSbTEgLFvoAnc0uyM9VKloYR
TSXfVk7Uwo1BW0Y9Pi0Ezp23O2yRaUyPLpO0T/tk58E+wAb7aKENr+vRykfxJsQ8
5g1hesLMlCb7Qwd7Es1/zdk3FSnXb+9VhP7WrOdktJnM4KmtP9YSM0O13MLtVOM0
fjPDYOf2RpqLSX+UC7uOzDsACTuSBjOoilFQ34mx33Mm/3hgmyGI6LBTDt5B1Av3
tAGYDSqS7WExy1wD2r+DwZpZBs9xGb8yA7I2iLLJJcu+fjL8PBcqWuf6AL/oxFGu
XXfLFCqryM2R4yURLSvBdX07lieLs8DsMwr9Qp91yMwc48VLKuDj8o7Qz0XZ5tUn
+zJooaoIRY5IcNff9jQmwD27XfiObhkMNaoyFYHVhZeeAtNuXDx8XfUzEWfIU8eq
FWluQzcDt/HZdavrf5YbtxD07SPIOw1jPWT+2DFwU5I0jAiqQw8/SEqn835B8NhI
/d0Tqqf3dREkWoFzsrQGwd1L6DC8FH0oDT5f4wJwT9HkpWZRAzTdJpUgwPPz05t/
M236oJ+sMaXw9f264EKJN68Zyh+Tl8vbTmugExewcJwb7UjeSMJv/ta9+EP8sxLi
jw9OTAxtWJOzTrW4dV/b
=yqgX
-----END PGP SIGNATURE-----

--Sig_/8EpoeABSFT5aSPRhbEEQiaj--
