From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/6] sysfs: Basic support for multiple super blocks
Date: Tue, 30 Mar 2010 21:23:32 +0200
Message-ID: <1269977012.2048.0.camel@edumazet-laptop>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	 <1269973889-25260-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org, Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269973889-25260-1-git-send-email-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 30 mars 2010 =C3=A0 11:31 -0700, Eric W. Biederman a =C3=A9cri=
t :
> From: Eric W. Biederman <ebiederm@xmission.com>
>=20
> Add all of the necessary bioler plate to support
> multiple superblocks in sysfs.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  fs/sysfs/mount.c |   58 ++++++++++++++++++++++++++++++++++++++++++++=
++++++++-
>  fs/sysfs/sysfs.h |    3 ++
>  2 files changed, 59 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
> index 0cb1088..6a433ac 100644
> --- a/fs/sysfs/mount.c
> +++ b/fs/sysfs/mount.c
> @@ -71,16 +71,70 @@ static int sysfs_fill_super(struct super_block *s=
b, void *data, int silent)
>  	return 0;
>  }
> =20
> +static int sysfs_test_super(struct super_block *sb, void *data)
> +{
> +	struct sysfs_super_info *sb_info =3D sysfs_info(sb);
> +	struct sysfs_super_info *info =3D data;
> +	int found =3D 1;
> +	return found;
> +}
> +
> +static int sysfs_set_super(struct super_block *sb, void *data)
> +{
> +	int error;
> +	error =3D set_anon_super(sb, data);
> +	if (!error)
> +		sb->s_fs_info =3D data;
> +	return error;
> +}
> +
>  static int sysfs_get_sb(struct file_system_type *fs_type,
>  	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
>  {
> -	return get_sb_single(fs_type, flags, data, sysfs_fill_super, mnt);
> +	struct sysfs_super_info *info;
> +	struct super_block *sb;
> +	int error;
> +
> +	error =3D -ENOMEM;
> +	info =3D kzalloc(sizeof(*info), GFP_KERNEL);
> +	if (!info)
> +		goto out;
> +	sb =3D sget(fs_type, sysfs_test_super, sysfs_set_super, info);
> +	if (IS_ERR(sb) || sb->s_fs_info !=3D info)
> +		kfree(info);
> +	if (IS_ERR(sb)) {
> +		kfree(info);

double kfree(info) ?

> +		error =3D PTR_ERR(sb);
> +		goto out;
> +	}
> +
