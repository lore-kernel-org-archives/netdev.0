From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] af_unix: Fix splice-bind deadlock
Date: Tue, 29 Dec 2015 11:58:28 +0100
Message-ID: <56826754.2060003@stressinduktion.org>
References: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rainer,

On 27.12.2015 21:13, Rainer Weikusat wrote:
> -static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
> +static int unix_mknod(struct dentry *dentry, struct path *path, umode_t mode,
> +		      struct path *res)
>   {
> -	struct dentry *dentry;
> -	struct path path;
> -	int err = 0;
> -	/*
> -	 * Get the parent directory, calculate the hash for last
> -	 * component.
> -	 */
> -	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
> -	err = PTR_ERR(dentry);
> -	if (IS_ERR(dentry))
> -		return err;
> +	int err;
>
> -	/*
> -	 * All right, let's create it.
> -	 */
> -	err = security_path_mknod(&path, dentry, mode, 0);
> +	err = security_path_mknod(path, dentry, mode, 0);
>   	if (!err) {
> -		err = vfs_mknod(d_inode(path.dentry), dentry, mode, 0);
> +		err = vfs_mknod(d_inode(path->dentry), dentry, mode, 0);
>   		if (!err) {
> -			res->mnt = mntget(path.mnt);
> +			res->mnt = mntget(path->mnt);
>   			res->dentry = dget(dentry);
>   		}
>   	}
> -	done_path_create(&path, dentry);
> +

The reordered call to done_path_create will change the locking ordering 
between the i_mutexes and the unix readlock. Can you comment on this? On 
a first sight this looks like a much more dangerous change than the 
original deadlock report. Can't this also conflict with splice code deep 
down in vfs layer?

Thanks,
   Hannes
