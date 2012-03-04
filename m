From: Sergei Trofimovich <slyich@gmail.com>
Subject: Re: [PATCHv 2] tcp: properly initialize tcp memory limits part 2
 (fix nfs regression)
Date: Sun, 4 Mar 2012 12:14:00 +0300
Message-ID: <20120304121400.4d756e55@sf.home>
References: <1330675173-18968-1-git-send-email-slyich@gmail.com>
	<4F509150.5060904@redhat.com>
	<20120302202421.753b36bc@sf.home>
	<20120302205000.088bf231@sf.home>
	<4F5227C9.7060209@parallels.com>
	<20120303174322.7e920bc5@sf.home>
	<4F52A8D5.9090703@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/AvFhPCRpjL0hQgXXMYT/6gL"; protocol="application/pgp-signature"
Cc: Jason Wang <jasowang@redhat.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F52A8D5.9090703@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/AvFhPCRpjL0hQgXXMYT/6gL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 3 Mar 2012 20:27:17 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 03/03/2012 11:43 AM, Sergei Trofimovich wrote:
> > On Sat, 3 Mar 2012 11:16:41 -0300
> > Glauber Costa<glommer@parallels.com>  wrote:
> >
> >> On 03/02/2012 02:50 PM, Sergei Trofimovich wrote:
> >>>>>> The change looks like a typo (division flipped to multiplication):
> >>>>>>> limit =3D nr_free_buffer_pages() / 8;
> >>>>>>> limit =3D nr_free_buffer_pages()<<    (PAGE_SHIFT - 10);
> >>>>>
> >>>>> Hi, thanks for the reporting. It's not a typo. It was previously:
> >>>>> sysctl_tcp_mem[1]<<   (PAGE_SHIFT -  7). Looks like we need to do t=
he
> >>>>> limit check before shift the value. Please try the following patch,=
 thanks.
> >>>>
> >>>> Still does not help. I test it by checking sha1sum of a large file o=
ver NFS
> >>>> (small files seem to work simetimes):
> >>>>
> >>>>       $ strace sha1sum /gentoo/distfiles/gcc-4.6.2.tar.bz2
> >>>>       ...
> >>>>       open("/gentoo/distfiles/gcc-4.6.2.tar.bz2", O_RDONLY
> >>>>       <HUNG>
> >>>> After a certain timeout dmesg gets odd spam:
> >>>> [  314.848094] nfs: server vmhost not responding, still trying
> >>>> [  314.848134] nfs: server vmhost not responding, still trying
> >>>> [  314.848145] nfs: server vmhost not responding, still trying
> >>>> [  314.957047] nfs: server vmhost not responding, still trying
> >>>> [  314.957066] nfs: server vmhost not responding, still trying
> >>>> [  314.957075] nfs: server vmhost not responding, still trying
> >>>> [  314.957085] nfs: server vmhost not responding, still trying
> >>>> [  314.957100] nfs: server vmhost not responding, still trying
> >>>> [  314.958023] nfs: server vmhost not responding, still trying
> >>>> [  314.958035] nfs: server vmhost not responding, still trying
> >>>> [  314.958044] nfs: server vmhost not responding, still trying
> >>>> [  314.958054] nfs: server vmhost not responding, still trying
> >>>>
> >>>> looks like bogus messages. Might be relevant to mishandled timings
> >>>> somewhere else or a bug in nfs code.
> >>>
> >>> And after 120 seconds hung tasks shows it might be an OOM issue
> >>> Likely caused by patch, as it's a 2GB RAM +4GB swap amd64 box
> >>> not running anything heavy:
> >>
> >> That is a bit weird.
> >>
> >> First because with Jason's patch, we should end up with the very same
> >> calculation, at the same exact order, as it was in older kernels.
> >> Second, because by shifting<<  10, you should be ending up with very
> >> small numbers, effectively having tcp_rmem[1] =3D=3D tcp_rmem[2], and =
the
> >> same for wmem.
> >>
> >> Can you share which numbers you end up with at
> >> /proc/sys/net/ipv4/tcp_{r,w}mem ?
> >>
> >
> > Sure:
> >
> >      $ cat /proc/sys/net/ipv4/tcp_{r,w}mem
> >      4096    87380   1999072
> >      4096    16384   1999072
> >
> Sergei,
>=20
> Sorry for not being clearer. I was expecting you'd post those values
> both in the scenario in which you see the bug, and in the scenario you
> don't.

Ah, I see.  Sorry. Patches are on top of v3.3-rc5-166-g1f033c1. Buggy one:
> -       limit =3D nr_free_buffer_pages() << (PAGE_SHIFT - 10);
> -       limit =3D max(limit, 128UL);
> +       limit =3D nr_free_buffer_pages() / 8;
> +       limit =3D max(limit, 128UL) << (PAGE_SHIFT - 7);
>         max_share =3D min(4UL*1024*1024, limit);
> +       printk(KERN_INFO "TCP: max_share=3D%u\n", max_share);
    $ cat /proc/sys/net/ipv4/tcp_{r,w}mem
    4096    87380   1999072
    4096    16384   1999072

Working one:
> -       limit =3D nr_free_buffer_pages() << (PAGE_SHIFT - 10);
> +       limit =3D nr_free_buffer_pages() >> (PAGE_SHIFT - 10);
>         limit =3D max(limit, 128UL);
>         max_share =3D min(4UL*1024*1024, limit);
> +       printk(KERN_INFO "TCP: max_share=3D%u\n", max_share);
    $ cat /proc/sys/net/ipv4/tcp_{r,w}mem
    4096    87380   124942
    4096    16384   124942

> > Nothing special with NFS nere, so I guess it uses UDP.
> > TCP works fine on machine (I do everything via SSH).
>=20
> Can you confirm that? If you're using nfs through udp, it makes
> even less sense that the default values of tcp sock mem will harm
> you. So it might be a bug somewhere else...

Rechecked with tcpdump. It uses TCP.

--=20

  Sergei

--Sig_/AvFhPCRpjL0hQgXXMYT/6gL
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk9TMl4ACgkQcaHudmEf86pMJACdGCV1wLb2lMEeJIyhhT12eK9Q
2ZwAoIjk/gdv+ySnUBQ2wFxTjQTULsnj
=n/D2
-----END PGP SIGNATURE-----

--Sig_/AvFhPCRpjL0hQgXXMYT/6gL--
