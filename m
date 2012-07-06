From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2] fail dentry revalidation after namespace change
Date: Fri, 06 Jul 2012 02:37:00 -0700
Message-ID: <87hatli62r.fsf@xmission.com>
References: <1341565747-15374-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Thelen <gthelen@google.com>,
	Serge Hallyn <serge.hallyn@canonical.com>,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341565747-15374-1-git-send-email-glommer@parallels.com>
	(Glauber Costa's message of "Fri, 6 Jul 2012 13:09:07 +0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Glauber Costa <glommer@parallels.com> writes:

> When we change the namespace tag of a sysfs entry, the associated dentry
> is still kept around. readdir() will work correctly and not display the
> old entries, but open() will still succeed, so will reads and writes.

Note reads and writes of file handles open before the move should
continue to work.

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
> correctly return an error. Differently from a normal rename, which we
> handle fine, changing the object namespace will keep it's path intact.
> So this check seems necessary as well.
>
> [ v2: get type from parent, as suggested by Eric Biederman ]

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Tejun Heo <tj@kernel.org>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
>  fs/sysfs/dir.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
> index e6bb9b2..c0bf38a 100644
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
> @@ -326,6 +327,13 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	if (strcmp(dentry->d_name.name, sd->s_name) != 0)
>  		goto out_bad;
>  
> +	/* The sysfs dirent has been moved to a different namespace */
> +	type = KOBJ_NS_TYPE_NONE;
> +	if (sd->s_parent)
> +		type = sysfs_ns_type(sd->s_parent);
> +	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
> +		goto out_bad;
> +
>  	mutex_unlock(&sysfs_mutex);
>  out_valid:
>  	return 1;
