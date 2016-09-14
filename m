From: Jann Horn <jann@thejh.net>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
Date: Wed, 14 Sep 2016 21:07:23 +0200
Message-ID: <20160914190723.GB5617@pc.thejh.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="eJnRUKwClWJh1Khz"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kern
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160914072415.26021-8-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--eJnRUKwClWJh1Khz
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 14, 2016 at 09:24:00AM +0200, Micka=EBl Sala=FCn wrote:
> Add eBPF functions to compare file system access with a Landlock file
> system handle:
> * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
>   This function allows to compare the dentry, inode, device or mount
>   point of the currently accessed file, with a reference handle.
> * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)
>   This function allows an eBPF program to check if the current accessed
>   file is the same or in the hierarchy of a reference handle.
[...]
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index 94256597eacd..edaab4c87292 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -603,6 +605,9 @@ static void landlock_put_handle(struct map_landlock_h=
andle *handle)
>  	enum bpf_map_handle_type handle_type =3D handle->type;
> =20
>  	switch (handle_type) {
> +	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
> +		path_put(&handle->path);
> +		break;
>  	case BPF_MAP_HANDLE_TYPE_UNSPEC:
>  	default:
>  		WARN_ON(1);
[...]
> diff --git a/security/landlock/checker_fs.c b/security/landlock/checker_f=
s.c
> new file mode 100644
> index 000000000000..39eb85dc7d18
> --- /dev/null
> +++ b/security/landlock/checker_fs.c
[...]
> +static inline u64 bpf_landlock_cmp_fs_prop_with_struct_file(u64 r1_prope=
rty,
> +		u64 r2_map, u64 r3_map_op, u64 r4_file, u64 r5)
> +{
> +	u8 property =3D (u8) r1_property;
> +	struct bpf_map *map =3D (struct bpf_map *) (unsigned long) r2_map;
> +	enum bpf_map_array_op map_op =3D r3_map_op;
> +	struct file *file =3D (struct file *) (unsigned long) r4_file;
> +	struct bpf_array *array =3D container_of(map, struct bpf_array, map);
> +	struct path *p1, *p2;
> +	struct map_landlock_handle *handle;
> +	int i;

Please don't use int when iterating over an array, use size_t.


> +	/* for now, only handle OP_OR */

Is "OP_OR" an appropriate name for something that ANDs the success of
checks?


[...]
> +	synchronize_rcu();

Can you put a comment here that explains what's going on?


> +	for (i =3D 0; i < array->n_entries; i++) {
> +		bool result_dentry =3D !(property & LANDLOCK_FLAG_FS_DENTRY);
> +		bool result_inode =3D !(property & LANDLOCK_FLAG_FS_INODE);
> +		bool result_device =3D !(property & LANDLOCK_FLAG_FS_DEVICE);
> +		bool result_mount =3D !(property & LANDLOCK_FLAG_FS_MOUNT);
> +
> +		handle =3D (struct map_landlock_handle *)
> +				(array->value + array->elem_size * i);
> +
> +		if (handle->type !=3D BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) {
> +			WARN_ON(1);
> +			return -EFAULT;
> +		}
> +		p1 =3D &handle->path;
> +
> +		if (!result_dentry && p1->dentry =3D=3D p2->dentry)
> +			result_dentry =3D true;

Why is this safe? As far as I can tell, this is not in an RCU read-side
critical section (synchronize_rcu() was just called), and no lock has been
taken. What prevents someone from removing the arraymap entry while we're
looking at it? Am I missing something?


[...]
> +static inline u64 bpf_landlock_cmp_fs_beneath_with_struct_file(u64 r1_op=
tion,
> +		u64 r2_map, u64 r3_map_op, u64 r4_file, u64 r5)
> +{
> +	u8 option =3D (u8) r1_option;
> +	struct bpf_map *map =3D (struct bpf_map *) (unsigned long) r2_map;
> +	enum bpf_map_array_op map_op =3D r3_map_op;
> +	struct file *file =3D (struct file *) (unsigned long) r4_file;
> +	struct bpf_array *array =3D container_of(map, struct bpf_array, map);
> +	struct path *p1, *p2;
> +	struct map_landlock_handle *handle;
> +	int i;

As above, please use size_t.

--eJnRUKwClWJh1Khz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2Z/rAAoJED4KNFJOeCOoWGsP/RLM9IzxJQAlajiOl519JMZY
CUShWpHkxFYp0pedSuiP/qXtt/Oo1SiB0yIUES0nLtqAjmI7uMVvMP/9ucPBXXhG
mgWDYQGxLkNNN+3VF+yq3J2IrlN51KyWCpMx1xwB97U++nrgxCFy+KMbyn52ITXI
4ZjkxuAdr6URCAVE29dw6rkpfR9vUoc4Y4qQK3pO+EvgA+GKZLah+oi25AWy14cu
Jc+Yv8vQK6OBSeXAKbRyFrvaW6/msVoFtJODYKLAn+5wlb9iLq1olpcZ70BsgsyR
eETes5lhvsKkcRU07OMakaQAPua7/lEaDSu+TotdR5EPCa5kEihU0bJtY+i+cyJC
KtGpC9s41eoBBlQV2y5E7icx9chG+Y5hdjHmbu2v77a4kVI/KjRSphf5/2EfzCKL
mMidcIC+0M3rPhI5H+kXpXoq1NyeDeGye0QkVuiq6zvCU1SjPIvtFofCrxpPftXU
XZawWJOAIA8PUTQHN25LHqXaeThfypNXZAxsup5D+qa6VQYiXI2cgOdg7ctPfy37
LFJUQFCzZpuq/eR22Xi3OaxhA3nOqc9y2CsYVj62Pgotjejh7JoSDefW2VjbbBfG
aKN5dD1im3EkyVW1csK7HluGD4e3jVoQSPqEXg99TH4ZiGNMw4GbA/6MnFYAgp0d
dLFaCec50umi2qqO6eeq
=yFuF
-----END PGP SIGNATURE-----

--eJnRUKwClWJh1Khz--
