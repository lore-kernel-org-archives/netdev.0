From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH] driver core: Suppress sysfs warnings for
 device_rename().
Date: Tue, 10 Jun 2008 11:09:08 +0200
Message-ID: <20080610110908.46b2ade4@gondolin.boeblingen.de.ibm.com>
References: <20080515095246.3b6a0d1d@gondolin.boeblingen.de.ibm.com>
	<20080515.010139.219194657.davem@davemloft.net>
	<20080515113131.2cea2bce@gondolin.boeblingen.de.ibm.com>
	<20080515.030054.247673168.davem@davemloft.net>
	<20080515120619.6c867bfb@gondolin.boeblingen.de.ibm.com>
	<20080520125913.777ed67d@gondolin.boeblingen.de.ibm.com>
	<20080520225244.GG15912@kroah.com>
	<20080521100556.3352c5b7@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:26037 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbYFJJJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 05:09:26 -0400
In-Reply-To: <20080521100556.3352c5b7@gondolin.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 May 2008 10:05:56 +0200,
Cornelia Huck <cornelia.huck@de.ibm.com> wrote:

Just digging through my backlog: Is there any further interest in this
patch?

> On Tue, 20 May 2008 15:52:44 -0700,
> Greg KH <greg@kroah.com> wrote:
> 
> > On Tue, May 20, 2008 at 12:59:13PM +0200, Cornelia Huck wrote:
> > > OK, here is an actually-compiled patch with proper description and
> > > s-o-b. Comments?
> > 
> > Looks good to me, feel free to add an:
> > 	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> > 
> > to it.
> > 
> > David, are you going to take this through your tree?
> 
> Here it is again, respun against today's git:
> 
> 
> driver core: Suppress sysfs warnings for device_rename().
> 
> Renaming network devices to an already existing name is not
> something we want sysfs to print a scary warning for, since the
> callers can deal with this correctly. So let's introduce
> sysfs_create_link_nowarn() which gets rid of the common warning.
> 
> Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> 
> ---
>  drivers/base/core.c   |    9 +++++----
>  fs/sysfs/dir.c        |   37 +++++++++++++++++++++++++++++++++++--
>  fs/sysfs/symlink.c    |   41 +++++++++++++++++++++++++++++++++--------
>  fs/sysfs/sysfs.h      |    1 +
>  include/linux/sysfs.h |   10 ++++++++++
>  5 files changed, 84 insertions(+), 14 deletions(-)
> 
> --- linux-2.6.orig/drivers/base/core.c
> +++ linux-2.6/drivers/base/core.c
> @@ -1282,8 +1282,9 @@ int device_rename(struct device *dev, ch
>  	if (old_class_name) {
>  		new_class_name = make_class_name(dev->class->name, &dev->kobj);
>  		if (new_class_name) {
> -			error = sysfs_create_link(&dev->parent->kobj,
> -						  &dev->kobj, new_class_name);
> +			error = sysfs_create_link_nowarn(&dev->parent->kobj,
> +							 &dev->kobj,
> +							 new_class_name);
>  			if (error)
>  				goto out;
>  			sysfs_remove_link(&dev->parent->kobj, old_class_name);
> @@ -1291,8 +1292,8 @@ int device_rename(struct device *dev, ch
>  	}
>  #else
>  	if (dev->class) {
> -		error = sysfs_create_link(&dev->class->subsys.kobj, &dev->kobj,
> -					  dev->bus_id);
> +		error = sysfs_create_link_nowarn(&dev->class->subsys.kobj,
> +						 &dev->kobj, dev->bus_id);
>  		if (error)
>  			goto out;
>  		sysfs_remove_link(&dev->class->subsys.kobj, old_device_name);
> --- linux-2.6.orig/fs/sysfs/dir.c
> +++ linux-2.6/fs/sysfs/dir.c
> @@ -398,7 +398,7 @@ void sysfs_addrm_start(struct sysfs_addr
>  }
>  
>  /**
> - *	sysfs_add_one - add sysfs_dirent to parent
> + *	__sysfs_add_one - add sysfs_dirent to parent without warning
>   *	@acxt: addrm context to use
>   *	@sd: sysfs_dirent to be added
>   *
> @@ -417,7 +417,7 @@ void sysfs_addrm_start(struct sysfs_addr
>   *	0 on success, -EEXIST if entry with the given name already
>   *	exists.
>   */
> -int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
> +int __sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
>  {
>  	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name))
>  		return -EEXIST;
> @@ -435,6 +435,39 @@ int sysfs_add_one(struct sysfs_addrm_cxt
>  }
>  
>  /**
> + *	sysfs_add_one - add sysfs_dirent to parent
> + *	@acxt: addrm context to use
> + *	@sd: sysfs_dirent to be added
> + *
> + *	Get @acxt->parent_sd and set sd->s_parent to it and increment
> + *	nlink of parent inode if @sd is a directory and link into the
> + *	children list of the parent.
> + *
> + *	This function should be called between calls to
> + *	sysfs_addrm_start() and sysfs_addrm_finish() and should be
> + *	passed the same @acxt as passed to sysfs_addrm_start().
> + *
> + *	LOCKING:
> + *	Determined by sysfs_addrm_start().
> + *
> + *	RETURNS:
> + *	0 on success, -EEXIST if entry with the given name already
> + *	exists.
> + */
> +int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
> +{
> +	int ret;
> +
> +	ret = __sysfs_add_one(acxt, sd);
> +	if (ret == -EEXIST) {
> +		printk(KERN_WARNING "sysfs: duplicate filename '%s' "
> +		       "can not be created\n", sd->s_name);
> +		WARN_ON(1);
> +	}
> +	return ret;
> +}
> +
> +/**
>   *	sysfs_remove_one - remove sysfs_dirent from parent
>   *	@acxt: addrm context to use
>   *	@sd: sysfs_dirent to be removed
> --- linux-2.6.orig/fs/sysfs/symlink.c
> +++ linux-2.6/fs/sysfs/symlink.c
> @@ -19,13 +19,8 @@
>  
>  #include "sysfs.h"
>  
> -/**
> - *	sysfs_create_link - create symlink between two objects.
> - *	@kobj:	object whose directory we're creating the link in.
> - *	@target:	object we're pointing to.
> - *	@name:		name of the symlink.
> - */
> -int sysfs_create_link(struct kobject * kobj, struct kobject * target, const char * name)
> +static int sysfs_do_create_link(struct kobject *kobj, struct kobject *target,
> +				const char *name, int warn)
>  {
>  	struct sysfs_dirent *parent_sd = NULL;
>  	struct sysfs_dirent *target_sd = NULL;
> @@ -65,7 +60,10 @@ int sysfs_create_link(struct kobject * k
>  	target_sd = NULL;	/* reference is now owned by the symlink */
>  
>  	sysfs_addrm_start(&acxt, parent_sd);
> -	error = sysfs_add_one(&acxt, sd);
> +	if (warn)
> +		error = sysfs_add_one(&acxt, sd);
> +	else
> +		error = __sysfs_add_one(&acxt, sd);
>  	sysfs_addrm_finish(&acxt);
>  
>  	if (error)
> @@ -80,6 +78,33 @@ int sysfs_create_link(struct kobject * k
>  }
>  
>  /**
> + *	sysfs_create_link - create symlink between two objects.
> + *	@kobj:	object whose directory we're creating the link in.
> + *	@target:	object we're pointing to.
> + *	@name:		name of the symlink.
> + */
> +int sysfs_create_link(struct kobject *kobj, struct kobject *target,
> +		      const char *name)
> +{
> +	return sysfs_do_create_link(kobj, target, name, 1);
> +}
> +
> +/**
> + *	sysfs_create_link_nowarn - create symlink between two objects.
> + *	@kobj:	object whose directory we're creating the link in.
> + *	@target:	object we're pointing to.
> + *	@name:		name of the symlink.
> + *
> + *	This function does the same as sysf_create_link(), but it
> + *	doesn't warn if the link already exists.
> + */
> +int sysfs_create_link_nowarn(struct kobject *kobj, struct kobject *target,
> +			     const char *name)
> +{
> +	return sysfs_do_create_link(kobj, target, name, 0);
> +}
> +
> +/**
>   *	sysfs_remove_link - remove symlink in object's directory.
>   *	@kobj:	object we're acting for.
>   *	@name:	name of the symlink to remove.
> --- linux-2.6.orig/fs/sysfs/sysfs.h
> +++ linux-2.6/fs/sysfs/sysfs.h
> @@ -107,6 +107,7 @@ struct sysfs_dirent *sysfs_get_active_tw
>  void sysfs_put_active_two(struct sysfs_dirent *sd);
>  void sysfs_addrm_start(struct sysfs_addrm_cxt *acxt,
>  		       struct sysfs_dirent *parent_sd);
> +int __sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd);
>  int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd);
>  void sysfs_remove_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd);
>  void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt);
> --- linux-2.6.orig/include/linux/sysfs.h
> +++ linux-2.6/include/linux/sysfs.h
> @@ -101,6 +101,9 @@ void sysfs_remove_bin_file(struct kobjec
>  
>  int __must_check sysfs_create_link(struct kobject *kobj, struct kobject *target,
>  				   const char *name);
> +int __must_check sysfs_create_link_nowarn(struct kobject *kobj,
> +					  struct kobject *target,
> +					  const char *name);
>  void sysfs_remove_link(struct kobject *kobj, const char *name);
>  
>  int __must_check sysfs_create_group(struct kobject *kobj,
> @@ -180,6 +183,13 @@ static inline int sysfs_create_link(stru
>  	return 0;
>  }
>  
> +static inline int sysfs_create_link_nowarn(struct kobject *kobj,
> +					   struct kobject *target,
> +					   const char *name)
> +{
> +	return 0;
> +}
> +
>  static inline void sysfs_remove_link(struct kobject *kobj, const char *name)
>  {
>  }
