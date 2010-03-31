From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/6] sysfs: Basic support for multiple super blocks
Date: Wed, 31 Mar 2010 14:41:44 +0900
Message-ID: <4BB2E098.7030202@kernel.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org> <1269973889-25260-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269973889-25260-1-git-send-email-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Eric.

On 03/31/2010 03:31 AM, Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@xmission.com>
> 
> Add all of the necessary bioler plate to support
                           boiler :-)

> +static int sysfs_test_super(struct super_block *sb, void *data)
> +{
> +	struct sysfs_super_info *sb_info = sysfs_info(sb);
> +	struct sysfs_super_info *info = data;
> +	int found = 1;
> +	return found;
> +}

Can you please make it return bool?

>  static int sysfs_get_sb(struct file_system_type *fs_type,
>  	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
>  {
> -	return get_sb_single(fs_type, flags, data, sysfs_fill_super, mnt);
> +	struct sysfs_super_info *info;
> +	struct super_block *sb;
> +	int error;
> +
> +	error = -ENOMEM;
> +	info = kzalloc(sizeof(*info), GFP_KERNEL);
> +	if (!info)
> +		goto out;
> +	sb = sget(fs_type, sysfs_test_super, sysfs_set_super, info);
> +	if (IS_ERR(sb) || sb->s_fs_info != info)
> +		kfree(info);
> +	if (IS_ERR(sb)) {
> +		kfree(info);
> +		error = PTR_ERR(sb);
> +		goto out;
> +	}
> +	if (!sb->s_root) {
> +		sb->s_flags = flags;
> +		error = sysfs_fill_super(sb, data, flags & MS_SILENT ? 1 : 0);
> +		if (error) {
> +			deactivate_locked_super(sb);
> +			goto out;
> +		}
> +		sb->s_flags |= MS_ACTIVE;
> +	}
> +
> +	simple_set_mnt(mnt, sb);
> +	error = 0;
> +out:
> +	return error;
> +}

I haven't looked at later patches but I suppose this is gonna be
filled with more meaningful stuff later.  One (possibly silly) thing
that stands out compared to get_sb_single() is missing remount
handling.  Is it intended?

> index 30f5a44..030a39d 100644
> --- a/fs/sysfs/sysfs.h
> +++ b/fs/sysfs/sysfs.h
> @@ -114,6 +114,9 @@ struct sysfs_addrm_cxt {
>  /*
>   * mount.c
>   */
> +struct sysfs_super_info {
> +};
> +#define sysfs_info(SB) ((struct sysfs_super_info *)(SB->s_fs_info))

Another nit picking.  It would be better to wrap SB in the macro
definition.  Also, wouldn't an inline function be better?

Thanks.

-- 
tejun
