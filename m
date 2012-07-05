From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] force dentry revalidation after namespace change
Date: Thu, 05 Jul 2012 16:31:57 -0700
Message-ID: <8762a1vl76.fsf@xmission.com>
References: <1341496805-26394-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341496805-26394-1-git-send-email-glommer@parallels.com>
	(Glauber Costa's message of "Thu, 5 Jul 2012 18:00:05 +0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Glauber Costa <glommer@parallels.com> writes:

> When we change the namespace tag of a sysfs entry, the associated dentry
> is still kept around. readdir() will work correctly and not display the
> old entries, but open() will still succeed, so will reads and writes.
>
> This will no longer happen if sysfs is remounted, hinting that this is a
> cache-related problem.

Equalivalently to remounting you can do
echo 3 > /proc/sys/vm/drop_caches.

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

Overall good bug spotting, and good spotting of where the fix should
live.

Your summary should have said:
[PATCH] fail dentry revalidation after namespace change

And you have the test slightly wrong below.

> Signed-off-by: Glauber Costa <glommer@parallels.com>
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

First this check should be down below with after the other rename
checks.

Second the test should be:
	type = KOBJ_NS_TYPE_NONE;
	if (sd->s_parent)
		type = sysfs_ns_type(sd->s_parent);
	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
        	goto out_bad;

The important difference there it is the directory that the dirent is
in that the type comes from.  Not the dirent itself.

>  	/* The sysfs dirent has been deleted */
>  	if (sd->s_flags & SYSFS_FLAG_REMOVED)
>  		goto out_bad;

Glauber.  Do you think you can fix your patch and resubmit.

Eric
