From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 10/11] avoid kobject name conflict with different namespaces
Date: Wed, 07 May 2008 11:49:19 -0700
Message-ID: <m13aoueyq8.fsf@frodo.ebiederm.org>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	<20080506173335.922289888@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39669 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757278AbYEGSuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 14:50:06 -0400
In-Reply-To: <20080506173335.922289888@theryb.frec.bull.fr> (Benjamin Thery's
	message of "Tue, 06 May 2008 19:32:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> The renaming of a kobject will fail if there is another kobject
> with the same name belonging to another namespace.
>
> This patch makes the kobject lookup in kobject_rename to check if
> the object exists _and_ belongs to the same namespace.

Ok so we are dealing with fallout from:

commit 34358c26a2c96b2a068dc44e0ac602106a466bce
Author: Greg Kroah-Hartman <gregkh@suse.de>
Date:   Wed Oct 24 16:52:31 2007 -0700

    kobject: check for duplicate names in kobject_rename
    
    This should catch any duplicate names before we try to tell sysfs to
    rename the object.  This happens a lot with older versions of udev and
    the network rename scripts.
    
    Cc: David Miller <davem@davemloft.net>
    Cc: Kay Sievers <kay.sievers@vrfy.org>
    Cc: Rafael J. Wysocki <rjw@sisk.pl>
    Cc: Tejun Heo <htejun@gmail.com>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

Which added the check in kobject_rename to prevent problems, and
seems to be causing a few.

I believe this earlier? patch addresses the problem:

commit c8d90dca3211966ba5189e0f3d4bccd558d9ae08
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Fri Oct 26 03:53:42 2007 -0700

    [NET] dev_change_name: ignore changes to same name
    
    Prevent error/backtrace from dev_rename() when changing
    name of network device to the same name. This is a common
    situation with udev and other scripts that bind addr to device.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


And the challenge is that we are getting false positives in the check
to see if renames will fail.

	/* see if this name is already in use */
	if (kobj->kset) {
		struct kobject *temp_kobj;
		temp_kobj = kset_find_obj(kobj->kset, new_name);
		if (temp_kobj) {
			printk(KERN_WARNING "kobject '%s' can not be renamed 
				"to '%s' as '%s' is already in existance.\n",
				kobject_name(kobj), new_name, new_name);
			kobject_put(temp_kobj);
			return -EINVAL;
		}
	}

If the kobject layer wants to perform the test above how do we support
it by giving it enough information to perform the test without false
positives.

Certainly we can go to the sysfs layer but that has the problem
of being a layering violation and not working when sysfs is not
compiled in.  Ouch!


I believe what the sanity check should look like is:
	/* see if this name is already in use */
	if (kobj->kset) {
		struct kobject *temp_kobj;
*               void *tag;
*               tag = kobject_tag(kobj);
*		temp_kobj = kset_find_tagged_obj(kobj->kset, tag, new_name);
*		if (temp_kobj && (temp_kobj != kobj)) {
			printk(KERN_WARNING "kobject '%s' can not be renamed 
				"to '%s' as '%s' is already in existance.\n",
				kobject_name(kobj), new_name, new_name);
			kobject_put(temp_kobj);
			return -EINVAL;
		}
	}

The tricky part is how do we get to kobject_tag (from the
sysfs_tagged_dir_operations).

Unless there is another path I think placing an additional pointer in
kobj_type so we can find it through ktype is the simplest solution.
Although using the kset is also sane.

The easiest and most trivially correct thing to do would be to simply
remove the unnecessary check from kobject_rename.  We perform the
check at the upper levels in the network anyway.  And kobject_rename
is only used by the network stack.

....

As for the actual patch itself I have two nits to pick.

> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>
> ---
>  fs/sysfs/dir.c        |   10 ++++++++++
>  include/linux/sysfs.h |    7 +++++++
>  lib/kobject.c         |    2 +-
>  3 files changed, 18 insertions(+), 1 deletion(-)
>
> Index: linux-vanilla/fs/sysfs/dir.c
> ===================================================================
> --- linux-vanilla.orig/fs/sysfs/dir.c
> +++ linux-vanilla/fs/sysfs/dir.c
> @@ -902,6 +902,16 @@ err_out:
>  	return error;
>  }
>  
> +int sysfs_tag_cmp(struct kobject *kobj1, struct kobject *kobj2)
> +{
> +	struct sysfs_dirent *sd1 = kobj1->sd;
> +	struct sysfs_dirent *sd2 = kobj2->sd;
> +	const void *tag1 = sysfs_dirent_tag(sd1);
> +	const void *tag2 = sysfs_dirent_tag(sd2);

The new name should be compared with sysfs_creation_tag in
case we are dealing with the case of renaming across network
namespaces.    We could use sysfs_creation_tag for both as
the only time the dirent_tag and creation_tag should differ
is during a rename operation.

> +
> +	return tag1 != tag2;
> +}
> +
>  int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
>  {
>  	struct sysfs_dirent *sd = kobj->sd;
> Index: linux-vanilla/include/linux/sysfs.h
> ===================================================================
> --- linux-vanilla.orig/include/linux/sysfs.h
> +++ linux-vanilla/include/linux/sysfs.h
> @@ -95,6 +95,8 @@ int sysfs_schedule_callback(struct kobje
>  
>  int __must_check sysfs_create_dir(struct kobject *kobj);
>  void sysfs_remove_dir(struct kobject *kobj);
> +int sysfs_tag_cmp(struct kobject *kobj1, struct kobject *kobj2);
> +
>  int __must_check sysfs_rename_dir(struct kobject *kobj, const char *new_name);
>  int __must_check sysfs_move_dir(struct kobject *kobj,
>  				struct kobject *new_parent_kobj);
> @@ -154,6 +156,11 @@ static inline void sysfs_remove_dir(stru
>  {
>  }
>  
> +static inline int sysfs_tag_cmp(struct kobject *kobj1, struct kobject *kobj2)
> +{
> +	return 0;
> +}
> +

Either I am blind or this implementation breaks when we are using
kobjects and sysfs support is not compiled in.  It might be that
we don't do this work but still in principle this is a small bug.

>  static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
>  {
>  	return 0;
> Index: linux-vanilla/lib/kobject.c
> ===================================================================
> --- linux-vanilla.orig/lib/kobject.c
> +++ linux-vanilla/lib/kobject.c
> @@ -401,7 +401,7 @@ int kobject_rename(struct kobject *kobj,
>  	if (kobj->kset) {
>  		struct kobject *temp_kobj;
>  		temp_kobj = kset_find_obj(kobj->kset, new_name);
> -		if (temp_kobj) {
> +		if (temp_kobj && !sysfs_tag_cmp(temp_kobj, kobj)) {
>  			printk(KERN_WARNING "kobject '%s' cannot be renamed "
>  			       "to '%s' as '%s' is already in existence.\n",
>  			       kobject_name(kobj), new_name, new_name);
>
> -- 
