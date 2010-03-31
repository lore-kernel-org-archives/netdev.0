From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Tue, 30 Mar 2010 21:43:46 -0500
Message-ID: <20100331024346.GB27001@us.ibm.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
 <1269973889-25260-3-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:35946 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755115Ab0CaCnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 22:43:43 -0400
Content-Disposition: inline
In-Reply-To: <1269973889-25260-3-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
>  int sysfs_rename(struct sysfs_dirent *sd,
> -	struct sysfs_dirent *new_parent_sd, const char *new_name)
> +	struct sysfs_dirent *new_parent_sd, const void *new_ns,
> +	const char *new_name)
>  {
>  	const char *dup_name = NULL;
>  	int error;
> @@ -743,12 +789,12 @@ int sysfs_rename(struct sysfs_dirent *sd,
>  	mutex_lock(&sysfs_mutex);
> 
>  	error = 0;
> -	if ((sd->s_parent == new_parent_sd) &&
> +	if ((sd->s_parent == new_parent_sd) && (sd->s_ns == new_ns) &&
>  	    (strcmp(sd->s_name, new_name) == 0))
>  		goto out;	/* nothing to rename */
> 
>  	error = -EEXIST;
> -	if (sysfs_find_dirent(new_parent_sd, new_name))
> +	if (sysfs_find_dirent(new_parent_sd, new_ns, new_name))
>  		goto out;
> 
>  	/* rename sysfs_dirent */
> @@ -770,6 +816,7 @@ int sysfs_rename(struct sysfs_dirent *sd,
>  		sd->s_parent = new_parent_sd;
>  		sysfs_link_sibling(sd);
>  	}
> +	sd->s_ns = new_ns;
> 
>  	error = 0;
>   out:

...

> +void sysfs_exit_ns(enum kobj_ns_type type, const void *ns)
> +{
> +	struct super_block *sb;
> +
> +	mutex_lock(&sysfs_mutex);
> +	spin_lock(&sb_lock);
> +	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
> +		struct sysfs_super_info *info = sysfs_info(sb);
> +		/* Ignore superblocks that are in the process of unmounting */
> +		if (sb->s_count <= S_BIAS)
> +			continue;
> +		/* Ignore superblocks with the wrong ns */
> +		if (info->ns[type] != ns)
> +			continue;
> +		info->ns[type] = NULL;
> +	}
> +	spin_unlock(&sb_lock);
> +	mutex_unlock(&sysfs_mutex);
> +}
> +

..

> @@ -136,6 +138,7 @@ int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
>  			const char *old, const char *new)
>  {
>  	struct sysfs_dirent *parent_sd, *sd = NULL;
> +	const void *old_ns = NULL, *new_ns = NULL;
>  	int result;
> 
>  	if (!kobj)
> @@ -143,8 +146,11 @@ int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
>  	else
>  		parent_sd = kobj->sd;
> 
> +	if (targ->sd)
> +		old_ns = targ->sd->s_ns;
> +
>  	result = -ENOENT;
> -	sd = sysfs_get_dirent(parent_sd, old);
> +	sd = sysfs_get_dirent(parent_sd, old_ns, old);
>  	if (!sd)
>  		goto out;
> 
> @@ -154,7 +160,10 @@ int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
>  	if (sd->s_symlink.target_sd->s_dir.kobj != targ)
>  		goto out;
> 
> -	result = sysfs_rename(sd, parent_sd, new);
> +	if (sysfs_ns_type(parent_sd))
> +		new_ns = targ->ktype->namespace(targ);
> +
> +	result = sysfs_rename(sd, parent_sd, new_ns, new);
> 
>  out:
>  	sysfs_put(sd);

This is a huge patch, and for the most part I haven't found any problems,
except potentially this one.  It looks like sysfs_rename_link() checks
old_ns and new_ns before calling sysfs_rename().  But sysfs_mutex isn't
taken until sysfs_rename().  sysfs_rename() will then proceed to do
the rename, and unconditionally set sd->ns = new_ns.

In the meantime, it seems as though new_ns might have exited, and
sysfs_exit_ns() unset new_ns on the new parent dir.  This means that
we'll end up with the namespace code having thought that it cleared
all new_ns's, but this file will have snuck by.  Meaning an action on
the renamed file might dereference a freed namespace.

Or am I way off base?

-serge
