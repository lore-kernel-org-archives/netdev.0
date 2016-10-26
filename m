From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: [kernel-hardening] [RFC v4 03/18] bpf,landlock: Add a new
 arraymap type to deal with (Landlock) handles
Date: Wed, 26 Oct 2016 22:16:00 +0200
Message-ID: <20161026201559.GO3334@pc.thejh.net>
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026065654.19166-4-mic@digikod.net>
 <20161026190147.GN3334@pc.thejh.net>
 <58110BFD.5090005@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Sr6hGnsCY8KeifOY"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <58110BFD.5090005-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Sr6hGnsCY8KeifOY
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 26, 2016 at 10:03:09PM +0200, Micka=EBl Sala=FCn wrote:
> On 26/10/2016 21:01, Jann Horn wrote:
> > On Wed, Oct 26, 2016 at 08:56:39AM +0200, Micka=EBl Sala=FCn wrote:
> >> This new arraymap looks like a set and brings new properties:
> >> * strong typing of entries: the eBPF functions get the array type of
> >>   elements instead of CONST_PTR_TO_MAP (e.g.
> >>   CONST_PTR_TO_LANDLOCK_HANDLE_FS);
> >> * force sequential filling (i.e. replace or append-only update), which
> >>   allow quick browsing of all entries.
> >>
> >> This strong typing is useful to statically check if the content of a m=
ap
> >> can be passed to an eBPF function. For example, Landlock use it to sto=
re
> >> and manage kernel objects (e.g. struct file) instead of dealing with
> >> userland raw data. This improve efficiency and ensure that an eBPF
> >> program can only call functions with the right high-level arguments.
> >>
> >> The enum bpf_map_handle_type list low-level types (e.g.
> >> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
> >> updating a map entry (handle). This handle types are used to infer a
> >> high-level arraymap type which are listed in enum bpf_map_array_type
> >> (e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).
> >>
> >> For now, this new arraymap is only used by Landlock LSM (cf. next
> >> commits) but it could be useful for other needs.
> >>
> >> Changes since v3:
> >> * make handle arraymap safe (RCU) and remove buggy synchronize_rcu()
> >> * factor out the arraymay walk
> >>
> >> Changes since v2:
> >> * add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
> >>   handle entries (suggested by Andy Lutomirski)
> >> * remove useless checks
> >>
> >> Changes since v1:
> >> * arraymap of handles replace custom checker groups
> >> * simpler userland API
> > [...]
> >> +	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
> >> +		handle_file =3D fget(handle->fd);
> >> +		if (IS_ERR(handle_file))
> >> +			return ERR_CAST(handle_file);
> >> +		/* check if the FD is tied to a user mount point */
> >> +		if (unlikely(handle_file->f_path.mnt->mnt_flags & MNT_INTERNAL)) {
> >> +			fput(handle_file);
> >> +			return ERR_PTR(-EINVAL);
> >> +		}
> >> +		path_get(&handle_file->f_path);
> >> +		ret =3D kmalloc(sizeof(*ret), GFP_KERNEL);
> >> +		ret->path =3D handle_file->f_path;
> >> +		fput(handle_file);
> >=20
> > You can use fdget() and fdput() here because the reference to
> > handle_file is dropped before the end of the syscall.
>=20
> The reference to handle_file is dropped but not the reference to the
> (inner) path thanks to path_get().

That's irrelevant. As long as you promise to fdput() any references
acquired using fdget() before any of the following can happen, using
fdget() is okay:
 - the syscall exits
 - the fd table is shared with a process that might write to it
 - an fd is closed by the kernel
In other words, you must be able to prove that nobody can remove the
struct file * from your fd table before you fdput().

Taking a long-term reference to an object pointed to by a struct file
that was looked up with fdget() is fine.

--Sr6hGnsCY8KeifOY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYEQ7/AAoJED4KNFJOeCOoEFsP/RfNBa0kgGar2d0Pe7pFqsb1
egAUR2bPYV/FWgrpiX0W0hTB6kjwDtSg8lw048hJA+d9Ns3HIZ2SNh+8l2hN0xrk
Nxws8Gv4J4Ikrtu2ZmiG3mwlFKMBkGCyo5UehnvA2XrUyJTA13cyzGyPIxBNbQAJ
HZFrGh9LgIIOTpeZWTdqf3DRsyzAx5CaoZZxDHR+WzTZ2rlsPe8Wt4KyIcfZkFDF
XVsLEPbryxPvC9jWm4ucWxZsooVfLsdvuXtxOddkMpBn/BrfB6gIQ/fbcM+3EpOv
NHw8fzZrvmuLiPu6sMVEMvrt2YWpBeiG1Go9dm/icuGhpeaiMXnv9ZaPGsGgERsQ
Z1xjuuz3qIYuxrOCH1E9l9Nn5OXAy9dORedDN3jafyfSVe4+vyC6SagvgKak+PHP
1j5bwv72O+FW/zQugD2t1jkPd+O6q4j7DC6hXogSreOTvD/9AC/Waa9jchs32eLR
3qbTFRBSYZwfNnGtiChC1cfubis1UcLm54qzZ40IfPN3z5RG0PEM6OhVN32YaEkm
eDiKDUATOL3rpph2vXyHd7+B1D6O1cvQEhyB/IuvjFJhjIgdxhLa1dnnEGe5mZMG
/6KOKVT1h3AymGe0mMQLLmi9ZhuSrtRTzPBUHDm9c0L5OeLvkkUvvxWH99L9Ae/+
AclBGkTlccYYtgpFot6x
=LKSv
-----END PGP SIGNATURE-----

--Sr6hGnsCY8KeifOY--
