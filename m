From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v4
Date: Tue, 13 May 2008 22:03:04 -0700
Message-ID: <20080513220304.b2f5a588.akpm@linux-foundation.org>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com>
	<m1prrqbseh.fsf@frodo.ebiederm.org>
	<4829A4BD.3020007@bull.net>
	<20080513164438.GA31563@kroah.com>
	<m18wyeay1q.fsf_-_@frodo.ebiederm.org>
	<20080513201602.GA31578@kroah.com>
	<m1od7a9bmr.fsf_-_@frodo.ebiederm.org>
	<24291087.1210713535895.JavaMail.oracle@acsmt301.oracle.com>
	<m1hcd1a48e.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <RANDY.DUNLAP@ORACLE.COM>, Greg KH <greg@kroah.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Tejun Heo <htejun@gmail.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760262AbYENFGt@vger.kernel.org>
In-Reply-To: <m1hcd1a48e.fsf_-_@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 May 2008 21:39:45 -0700 ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> When looking at kobject_rename I found two bugs with
> that exist when sysfs support is disabled in the kernel.
> 
> kobject_rename does not change the name on the kobject when
> sysfs support is not compiled in.
> 
> kobject_rename without locking attempts to check the
> validity of a rename operation, which the kobject layer
> simply does not have the infrastructure to do.
> 
> This patch documents the previously unstated requirement of
> kobject_rename that is the responsibility of the caller to
> provide mutual exclusion and to be certain that the new_name
> for the kobject is valid.
> 
> This patch modifies sysfs_rename_dir in !CONFIG_SYSFS case
> to call kobject_set_name to actually change the kobject_name.
> 
> This patch removes the bogus and misleading check in kobject_rename
> that attempts to see if a rename is valid.  The check is bogus
> because we do not have the proper locking.  The check is misleading
> because it looks like we can and do perform checking at the kobject
> level that we don't.
> 
> Changelog:
> v4:	Documentation typo fixes
> 
> v2:	Added a declaration of kboject_set_name to sysfs.h
> 	so the code actually compiles with !CONFIG_SYSFS.
> 
> 	Unscrambling the header dependencies so everything looks
> 	beautiful is a project for another day.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  Documentation/kobject.txt |    4 ++++
>  drivers/base/core.c       |    5 +++++
>  include/linux/sysfs.h     |    4 +++-
>  lib/kobject.c             |   18 +++++-------------
>  4 files changed, 17 insertions(+), 14 deletions(-)
> 
> diff --git a/Documentation/kobject.txt b/Documentation/kobject.txt
> index bf3256e..ac80d82 100644
> --- a/Documentation/kobject.txt
> +++ b/Documentation/kobject.txt
> @@ -118,6 +118,10 @@ the name of the kobject, call kobject_rename():
>  
>      int kobject_rename(struct kobject *kobj, const char *new_name);
>  
> +Note kobject_rename does not perform any locking or have a solid notion of
> +what names are valid so the caller must provide their own sanity checking
> +and serialization.
> +
>  There is a function called kobject_set_name() but that is legacy cruft and
>  is being removed.  If your code needs to call this function, it is
>  incorrect and needs to be fixed.
> diff --git a/drivers/base/core.c b/drivers/base/core.c
> index be288b5..ad68f4c 100644
> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -1171,6 +1171,11 @@ EXPORT_SYMBOL_GPL(device_destroy);
>   * device_rename - renames a device
>   * @dev: the pointer to the struct device to be renamed
>   * @new_name: the new name of the device
> + *
> + * It is the responsibility of the caller to provide mutual
> + * exclusion between two different calls of device_rename
> + * on the same device to ensure that new_name is valid and
> + * won't conflict with other devices.
>   */
>  int device_rename(struct device *dev, char *new_name)
>  {
> diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
> index 7858eac..6e61033 100644
> --- a/include/linux/sysfs.h
> +++ b/include/linux/sysfs.h
> @@ -20,6 +20,8 @@
>  struct kobject;
>  struct module;
>  
> +extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
> +			    __attribute__((format(printf, 2, 3)));

Duplicating the kobject_set_name() declaration in sysfs.h is rather a hack.

It'd be better to move it into a new header file, included by both
sysfs.h and kobject.h.  Perhaps there are other declarations which can
be moved with it.
