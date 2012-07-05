From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH] force dentry revalidation after namespace change
Date: Thu, 5 Jul 2012 22:17:01 +0000
Message-ID: <20120705221701.GC11255@mail.hallyn.com>
References: <1341496805-26394-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341496805-26394-1-git-send-email-glommer@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Glauber Costa (glommer@parallels.com):
> When we change the namespace tag of a sysfs entry, the associated dentry
> is still kept around. readdir() will work correctly and not display the
> old entries, but open() will still succeed, so will reads and writes.
> 
> This will no longer happen if sysfs is remounted, hinting that this is a
> cache-related problem.
> 
> I am using the following sequence to demonstrate that:
> 
> shell1:
> ip link add type veth
> unshare -nm
> 
> shell2:
> ip link set veth1 <pid_of_shell_1>
> cat /sys/devices/virtual/net/veth1/ifindex
> 
> Before that patch, this will succeed (fail to fail). After it, it will

Confirmed that it currently fails to fail :)

> correctly return an error. Differently from a normal rename, which we
> handle fine, changing the object namespace will keep it's path intact.
> So this check seems necessary as well.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Haven't run it, but the patch looks good.  Thanks, Glauber.

Acked-by: Serge Hallyn <serge.hallyn@canonical.com>

> CC: Tejun Heo <tj@kernel.org>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
>  fs/sysfs/dir.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
> index e6bb9b2..c24bdd9 100644
> --- a/fs/sysfs/dir.c
> +++ b/fs/sysfs/dir.c
> @@ -307,6 +307,7 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
>  {
>  	struct sysfs_dirent *sd;
>  	int is_dir;
> +	int type;
>  
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> @@ -314,6 +315,10 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	sd = dentry->d_fsdata;
>  	mutex_lock(&sysfs_mutex);
>  
> +	type = sysfs_ns_type(sd);
> +	if (sd->s_ns && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
> +		goto out_bad;
> +
>  	/* The sysfs dirent has been deleted */
>  	if (sd->s_flags & SYSFS_FLAG_REMOVED)
>  		goto out_bad;
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
