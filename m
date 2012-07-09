From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [PATCH v2] fail dentry revalidation after namespace change
Date: Mon, 9 Jul 2012 18:43:59 -0500
Message-ID: <20120709234359.GA6800@sergelap>
References: <1341565747-15374-1-git-send-email-glommer@parallels.com>
 <20120709161336.0ec23592.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glauber Costa <glommer@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120709161336.0ec23592.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
> On Fri,  6 Jul 2012 13:09:07 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
> > When we change the namespace tag of a sysfs entry, the associated dentry
> > is still kept around. readdir() will work correctly and not display the
> > old entries, but open() will still succeed, so will reads and writes.
> > 
> > This will no longer happen if sysfs is remounted, hinting that this is a
> > cache-related problem.
> > 
> > I am using the following sequence to demonstrate that:
> > 
> > shell1:
> > ip link add type veth
> > unshare -nm
> > 
> > shell2:
> > ip link set veth1 <pid_of_shell_1>
> > cat /sys/devices/virtual/net/veth1/ifindex
> > 
> > Before that patch, this will succeed (fail to fail). After it, it will
> > correctly return an error. Differently from a normal rename, which we
> > handle fine, changing the object namespace will keep it's path intact.
> > So this check seems necessary as well.
> > 
> > ...
> >
> > --- a/fs/sysfs/dir.c
> > +++ b/fs/sysfs/dir.c
> > @@ -307,6 +307,7 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
> >  {
> >  	struct sysfs_dirent *sd;
> >  	int is_dir;
> > +	int type;
> >  
> >  	if (nd->flags & LOOKUP_RCU)
> >  		return -ECHILD;
> > @@ -326,6 +327,13 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
> >  	if (strcmp(dentry->d_name.name, sd->s_name) != 0)
> >  		goto out_bad;
> >  
> > +	/* The sysfs dirent has been moved to a different namespace */
> > +	type = KOBJ_NS_TYPE_NONE;
> > +	if (sd->s_parent)
> > +		type = sysfs_ns_type(sd->s_parent);
> > +	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
> 
> eww, the code is assuming that KOBJ_NS_TYPE_NONE has a value of zero. 
> Don't do that; it smells bad.
> 
> I renamed my version of this patch to "sysfs: fail dentry revalidation
> after namespace change", as carefully explained in section 15 of the
> excellent Documentation/SubmittingPatches, then queued this:
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: sysfs-fail-dentry-revalidation-after-namespace-change-fix
> 
> don't assume that KOBJ_NS_TYPE_NONE==0.  Also save a test-n-branch.
> 
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Glauber Costa <glommer@parallels.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>

> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/sysfs/dir.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff -puN fs/sysfs/dir.c~sysfs-fail-dentry-revalidation-after-namespace-change-fix fs/sysfs/dir.c
> --- a/fs/sysfs/dir.c~sysfs-fail-dentry-revalidation-after-namespace-change-fix
> +++ a/fs/sysfs/dir.c
> @@ -329,10 +329,12 @@ static int sysfs_dentry_revalidate(struc
>  
>  	/* The sysfs dirent has been moved to a different namespace */
>  	type = KOBJ_NS_TYPE_NONE;
> -	if (sd->s_parent)
> +	if (sd->s_parent) {
>  		type = sysfs_ns_type(sd->s_parent);
> -	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
> -		goto out_bad;
> +		if (type != KOBJ_NS_TYPE_NONE &&
> +				sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns)
> +			goto out_bad;
> +	}
>  
>  	mutex_unlock(&sysfs_mutex);
>  out_valid:
> _
> 
> 
