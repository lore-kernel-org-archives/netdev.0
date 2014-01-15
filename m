From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] sysfs_rename_link() and its usage
Date: Wed, 15 Jan 2014 15:25:16 -0800
Message-ID: <87fvoo25gj.fsf@xmission.com>
References: <20140114171740.GB1867@redhat.com>
	<20140114182135.GA29296@kroah.com> <20140114191208.GA9942@redhat.com>
	<20140114193139.GA3636@kroah.com> <20140114210610.GC9942@redhat.com>
	<87iotmc9ic.fsf@xmission.com> <20140115141618.GD7950@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140115141618.GD7950@htj.dyndns.org> (Tejun Heo's message of
	"Wed, 15 Jan 2014 09:16:18 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo <tj@kernel.org> writes:

> Hey, Veaceslav, Eric.
>
> On Tue, Jan 14, 2014 at 05:35:23PM -0800, Eric W. Biederman wrote:
>> >>> >>This works like a charm. However, if I want to use (obviously, with the
>> >>> >>symlink present):
>> >>> >>
>> >>> >>sysfs_rename_link(&(a->dev.kobj), &(b->dev.kobj), oldname, newname);
>> >>> >
>> >>> >You forgot the namespace option to this call, what kernel version are
>> >>> >you using here?
>> >>>
>> >>> It's git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next ,
>> >>> 3.13-rc6 with some networking patches on top of it.
>
> Does this work on 3.12?  How about Greg's driver-core-next?  Do you
> have a minimal test case that I can use to reproduce the issue?
>
>> sysfs_rename_link was originally written to infer figure everything out
>> based on the target device.  Because symlinks only make sense being in
>> the same namespace of their devices.  Tejun broke the inference and now
>> you are having hard time using the code.
>
> I wouldn't be surprised if I broke it but
>
>> The commit that broke things was:
>> 
>> commit 4b30ee58ee64c64f59fd876e4afa6ed82caef3a4
>> Author: Tejun Heo <tj@kernel.org>
>> Date:   Wed Sep 11 22:29:06 2013 -0400
>> 
>>     sysfs: remove ktype->namespace() invocations in symlink code
>
> I'm not so sure about the above commit.  The warning is from rename
> failing to locate the existing node while the above patch updates the
> target ns to rename to.  The old_ns part stays the same before and
> after the commit.

So passing a NULL namespace when a node already has a namespace will
cause that warning.

I'm not quite certain about the bridge code.  It should be in a network
namespace but at first glance I am not seeing that.

However what is most definitely broken is the usablitily of
sysfs_rename_link.  Renaming symlinks used to just do the right thing,
and figure out all of the namespace bits and not making the callers
worry about it.  Now there are new callers that can't figure out how to
call the function.  That is a huge usability breakage, and the commit I
singled out is definitely one of them.

> Veaceslav, please confirm whether the issue is reproducible w/ v3.12.

Anyway since a symlink living in a different namespace from it's target
is just nonsense this (only compile tested) patch should fix the issue,
and make sysfs_rename_link usable for people without a masters degree in
sysfs again.

Eric


diff --git a/drivers/base/core.c b/drivers/base/core.c
index 67b180d855b2..0c9377a5bb89 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1825,9 +1825,8 @@ int device_rename(struct device *dev, const char *new_name)
 	}
 
 	if (dev->class) {
-		error = sysfs_rename_link_ns(&dev->class->p->subsys.kobj,
-					     kobj, old_device_name,
-					     new_name, kobject_namespace(kobj));
+		error = sysfs_rename_link(&dev->class->p->subsys.kobj,
+					  kobj, old_device_name, new_name);
 		if (error)
 			goto out;
 	}
diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 3ae3f1bf1a09..651444a9d1c5 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -194,12 +194,10 @@ EXPORT_SYMBOL_GPL(sysfs_remove_link);
  *	@targ:	object we're pointing to.
  *	@old:	previous name of the symlink.
  *	@new:	new name of the symlink.
- *	@new_ns: new namespace of the symlink.
- *
  *	A helper function for the common rename symlink idiom.
  */
-int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *targ,
-			 const char *old, const char *new, const void *new_ns)
+int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
+		      const char *old, const char *new)
 {
 	struct sysfs_dirent *parent_sd, *sd = NULL;
 	const void *old_ns = NULL;
@@ -224,13 +222,13 @@ int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *targ,
 	if (sd->s_symlink.target_sd->s_dir.kobj != targ)
 		goto out;
 
-	result = sysfs_rename(sd, parent_sd, new, new_ns);
+	result = sysfs_rename(sd, parent_sd, new, kobject_namespace(targ));
 
 out:
 	sysfs_put(sd);
 	return result;
 }
-EXPORT_SYMBOL_GPL(sysfs_rename_link_ns);
+EXPORT_SYMBOL_GPL(sysfs_rename_link);
 
 static int sysfs_get_target_path(struct sysfs_dirent *parent_sd,
 				 struct sysfs_dirent *target_sd, char *path)
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 6695040a0317..093d99244290 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -213,9 +213,8 @@ int __must_check sysfs_create_link_nowarn(struct kobject *kobj,
 					  const char *name);
 void sysfs_remove_link(struct kobject *kobj, const char *name);
 
-int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *target,
-			 const char *old_name, const char *new_name,
-			 const void *new_ns);
+int sysfs_rename_link(struct kobject *kobj, struct kobject *target,
+		      const char *old_name, const char *new_name);
 
 void sysfs_delete_link(struct kobject *dir, struct kobject *targ,
 			const char *name);
@@ -341,9 +340,8 @@ static inline void sysfs_remove_link(struct kobject *kobj, const char *name)
 {
 }
 
-static inline int sysfs_rename_link_ns(struct kobject *k, struct kobject *t,
-				       const char *old_name,
-				       const char *new_name, const void *ns)
+static inline int sysfs_rename_link(struct kobject *k, struct kobject *t,
+				    const char *old_name, const char *new_name)
 {
 	return 0;
 }
@@ -455,12 +453,6 @@ static inline void sysfs_remove_file(struct kobject *kobj,
 	return sysfs_remove_file_ns(kobj, attr, NULL);
 }
 
-static inline int sysfs_rename_link(struct kobject *kobj, struct kobject *target,
-				    const char *old_name, const char *new_name)
-{
-	return sysfs_rename_link_ns(kobj, target, old_name, new_name, NULL);
-}
-
 static inline struct sysfs_dirent *
 sysfs_get_dirent(struct sysfs_dirent *parent_sd, const unsigned char *name)
 {
