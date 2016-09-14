From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 17/22] cgroup: Add access check for cgroup_get_from_fd()
Date: Thu, 15 Sep 2016 00:06:22 +0200
Message-ID: <57D9C9DE.3090501@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-18-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="ni3ovDMADqiajngLVri2evOm0649l8hjA"
Cc: Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski
 <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        netdev@vger.kernel.org, cgroups@vger.kernel.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4635-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-18-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ni3ovDMADqiajngLVri2evOm0649l8hjA
Content-Type: multipart/mixed; boundary="dol8kb1MRdp2aKegT6vUQPDQR4VvvrPUN";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: linux-kernel@vger.kernel.org
Cc: Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski
 <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, cgroups@vger.kernel.org
Message-ID: <57D9C9DE.3090501@digikod.net>
Subject: Re: [RFC v3 17/22] cgroup: Add access check for cgroup_get_from_fd()
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-18-mic@digikod.net>
In-Reply-To: <20160914072415.26021-18-mic@digikod.net>

--dol8kb1MRdp2aKegT6vUQPDQR4VvvrPUN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 14/09/2016 09:24, Micka=C3=ABl Sala=C3=BCn wrote:
> Add security access check for cgroup backed FD. The "cgroup.procs" file=

> of the corresponding cgroup must be readable to identify the cgroup, an=
d
> writable to prove that the current process can manage this cgroup (e.g.=

> through delegation). This is similar to the check done by
> cgroup_procs_write_permission().
>=20
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Daniel Mack <daniel@zonque.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  include/linux/cgroup.h |  2 +-
>  kernel/bpf/arraymap.c  |  2 +-
>  kernel/bpf/syscall.c   |  6 +++---
>  kernel/cgroup.c        | 16 +++++++++++++++-
>  4 files changed, 20 insertions(+), 6 deletions(-)
=2E..
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 48b650a640a9..3bbaf3f02ed2 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -6241,17 +6241,20 @@ EXPORT_SYMBOL_GPL(cgroup_get_from_path);
>  /**
>   * cgroup_get_from_fd - get a cgroup pointer from a fd
>   * @fd: fd obtained by open(cgroup2_dir)
> + * @access_mask: contains the permission mask
>   *
>   * Find the cgroup from a fd which should be obtained
>   * by opening a cgroup directory.  Returns a pointer to the
>   * cgroup on success. ERR_PTR is returned if the cgroup
>   * cannot be found.
>   */
> -struct cgroup *cgroup_get_from_fd(int fd)
> +struct cgroup *cgroup_get_from_fd(int fd, int access_mask)
>  {
>  	struct cgroup_subsys_state *css;
>  	struct cgroup *cgrp;
>  	struct file *f;
> +	struct inode *inode;
> +	int ret;
> =20
>  	f =3D fget_raw(fd);
>  	if (!f)
> @@ -6268,6 +6271,17 @@ struct cgroup *cgroup_get_from_fd(int fd)
>  		return ERR_PTR(-EBADF);
>  	}
> =20
> +	ret =3D -ENOMEM;
> +	inode =3D kernfs_get_inode(f->f_path.dentry->d_sb, cgrp->procs_file.k=
n);

I forgot to properly move fput(f) after this line=E2=80=A6 This will be f=
ixed.


--dol8kb1MRdp2aKegT6vUQPDQR4VvvrPUN--

--ni3ovDMADqiajngLVri2evOm0649l8hjA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2cneAAoJECLe/t9zvWqVYcIH/ip8WsKVuRjzGIGLL4/46vzL
dbYLtHU0sG9/oMVtfe+nlZW6l0whRr3tnLAQeJBZka+qc4j1WmNF/LSeXwPnb/T6
APQKdLHnUKn6zdJ4+oXd2JpaD8feNfGoxw5jygwK4423aApcR06hvxo4H7z7m7Gq
kpZXnheUPFvX5jVeq6tXZlbrIZ422Fo7DQSYim5XvWny6OcU68XEo/Wm+Nx+cLHw
mdeoduIlY1YRZ0jb4mKnSAhpt/w5YHFeQxRnwACPmcGiMRw5PLyhhi6ov/VlloaQ
PBKYPGxEmxXUCapnFTBshJx9WDfhBy3IebqwpotNv+vUg1GyVgN3go2ouVN4k1k=
=8g0D
-----END PGP SIGNATURE-----

--ni3ovDMADqiajngLVri2evOm0649l8hjA--
