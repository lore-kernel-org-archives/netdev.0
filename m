From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: [kernel-hardening] [RFC v4 03/18] bpf,landlock: Add a new
 arraymap type to deal with (Landlock) handles
Date: Wed, 26 Oct 2016 21:01:47 +0200
Message-ID: <20161026190147.GN3334@pc.thejh.net>
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026065654.19166-4-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="K4LMwn8CgX2KMboP"
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
In-Reply-To: <20161026065654.19166-4-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--K4LMwn8CgX2KMboP
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 26, 2016 at 08:56:39AM +0200, Micka=EBl Sala=FCn wrote:
> This new arraymap looks like a set and brings new properties:
> * strong typing of entries: the eBPF functions get the array type of
>   elements instead of CONST_PTR_TO_MAP (e.g.
>   CONST_PTR_TO_LANDLOCK_HANDLE_FS);
> * force sequential filling (i.e. replace or append-only update), which
>   allow quick browsing of all entries.
>=20
> This strong typing is useful to statically check if the content of a map
> can be passed to an eBPF function. For example, Landlock use it to store
> and manage kernel objects (e.g. struct file) instead of dealing with
> userland raw data. This improve efficiency and ensure that an eBPF
> program can only call functions with the right high-level arguments.
>=20
> The enum bpf_map_handle_type list low-level types (e.g.
> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
> updating a map entry (handle). This handle types are used to infer a
> high-level arraymap type which are listed in enum bpf_map_array_type
> (e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).
>=20
> For now, this new arraymap is only used by Landlock LSM (cf. next
> commits) but it could be useful for other needs.
>=20
> Changes since v3:
> * make handle arraymap safe (RCU) and remove buggy synchronize_rcu()
> * factor out the arraymay walk
>=20
> Changes since v2:
> * add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
>   handle entries (suggested by Andy Lutomirski)
> * remove useless checks
>=20
> Changes since v1:
> * arraymap of handles replace custom checker groups
> * simpler userland API
[...]
> +	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
> +		handle_file =3D fget(handle->fd);
> +		if (IS_ERR(handle_file))
> +			return ERR_CAST(handle_file);
> +		/* check if the FD is tied to a user mount point */
> +		if (unlikely(handle_file->f_path.mnt->mnt_flags & MNT_INTERNAL)) {
> +			fput(handle_file);
> +			return ERR_PTR(-EINVAL);
> +		}
> +		path_get(&handle_file->f_path);
> +		ret =3D kmalloc(sizeof(*ret), GFP_KERNEL);
> +		ret->path =3D handle_file->f_path;
> +		fput(handle_file);

You can use fdget() and fdput() here because the reference to
handle_file is dropped before the end of the syscall.


> +		break;
> +	case BPF_MAP_HANDLE_TYPE_UNSPEC:
> +	default:
> +		return ERR_PTR(-EINVAL);
> +	}
> +	ret->type =3D handle_type;
> +	return ret;
> +}
> +
> +static void *nop_map_lookup_elem(struct bpf_map *map, void *key)
> +{
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +/* called from syscall or from eBPF program */
> +static int landlock_array_map_update_elem(struct bpf_map *map, void *key,
> +		void *value, u64 map_flags)
> +{

This being callable from eBPF context is IMO pretty surprising and should
at least be well-documented. Also: What is the usecase here?

--K4LMwn8CgX2KMboP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYEP2bAAoJED4KNFJOeCOoXs0QANR8eMzG7RvxyXZC6zHMmWfe
yrRyDtTcXPmndGQHfU6YWsdl9vM6bHcb0gWl44k40QmrPPcVd7zu6wpkghMkJLRp
h+pCrkpNx0gOpuxx0pTu6d8sHFmyh+lM+BlkbvTGvctUADLu5f+r0w/R/4cIPIB4
NVGAY7wG3QrH/2VYc+0Uz4wb6JFMVxoRAYkvUD/tvVMXfwlfl4TDxL946Caw7XPP
J2cCs1/FyZ9ahwnPLkI3tAkPkqFnR7Qh7cXks9ofTGtG1z8j2l+RCtrbZMWB2lsW
VQvkFjkCUzuUVIRRuZE2E1zmekZxlOp4MvQpE5bCyWwKVcFPnsAPdcPQ8LBJ2Aak
SSgvPc5jDp1ZzxDihwJ6Lr43k1w+MR6SF3x7uCkd5FOR+R3vBU/UUg4XUfQKqoIp
jCysAr7wEqY/tdh4BkR/bDGaoOeEq6oFKaVu+VnySS76mq0YKFR7rcbz/tMe0gCT
+lL6OkSmev/1NOiF86DUGEbRZv8ctK411/FxMz5adOrsU/jcTMwDfgu/ggZR7hoz
v/kpOnrTsul/LTITxhwvXRt21AqDcq9qfVjS83BWy1nTWU3nmfDfy0Xbn14YLCXz
hk9UNi3xndluRJ+lnPAoM9o+UpUbHoqyB1qYdObvf9FSlSxtQOX6AgPDjjJv/NkT
TS0aueHFQqZvSkwk/0V/
=LPFG
-----END PGP SIGNATURE-----

--K4LMwn8CgX2KMboP--
