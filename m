From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [RFC] sysfs_rename_link() and its usage
Date: Thu, 16 Jan 2014 01:11:16 +0100
Message-ID: <20140116001116.GA27182@redhat.com>
References: <20140114171740.GB1867@redhat.com>
 <20140114182135.GA29296@kroah.com>
 <20140114191208.GA9942@redhat.com>
 <20140114193139.GA3636@kroah.com>
 <20140114210610.GC9942@redhat.com>
 <87iotmc9ic.fsf@xmission.com>
 <20140115141618.GD7950@htj.dyndns.org>
 <87fvoo25gj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fvoo25gj.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 15, 2014 at 03:25:16PM -0800, Eric W. Biederman wrote:
>Tejun Heo <tj@kernel.org> writes:
>
>> Hey, Veaceslav, Eric.

Hi Tejun, Eric,

>>
>> On Tue, Jan 14, 2014 at 05:35:23PM -0800, Eric W. Biederman wrote:
>>> >>> >>This works like a charm. However, if I want to use (obviously, with the
>>> >>> >>symlink present):
>>> >>> >>
>>> >>> >>sysfs_rename_link(&(a->dev.kobj), &(b->dev.kobj), oldname, newname);
>>> >>> >
>>> >>> >You forgot the namespace option to this call, what kernel version are
>>> >>> >you using here?
>>> >>>
>>> >>> It's git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next ,
>>> >>> 3.13-rc6 with some networking patches on top of it.
>>
>> Does this work on 3.12?  How about Greg's driver-core-next?  Do you
>> have a minimal test case that I can use to reproduce the issue?

Sorry for the latency in responses, I'll update once I'll manage to test it
on those.

...snip...
>> Veaceslav, please confirm whether the issue is reproducible w/ v3.12.
>
>Anyway since a symlink living in a different namespace from it's target
>is just nonsense this (only compile tested) patch should fix the issue,
>and make sysfs_rename_link usable for people without a masters degree in
>sysfs again.

It's still there :-(. I've used your patch and added my small addition[1] to
test the sysfs_rename_link() (on top of net-next, 3.13-rc7), however the
issue is still there:

[   79.038340] net bond0: renaming to bondbla
[   79.038380] ------------[ cut here ]------------
[   79.038411] WARNING: CPU: 1 PID: 5318 at fs/sysfs/dir.c:618
sysfs_find_dirent+0x84/0x110()
[   79.038449] sysfs: ns invalid in 'bridge0' for 'lower_bond0'
...snip...
[   79.038877]  [<ffffffff810ae826>] warn_slowpath_fmt+0x46/0x50
[   79.038903]  [<ffffffff812ba890>] ? sysfs_get_dirent_ns+0x30/0x80
[   79.038930]  [<ffffffff812b97c4>] sysfs_find_dirent+0x84/0x110
[   79.038957]  [<ffffffff812ba89e>] sysfs_get_dirent_ns+0x3e/0x80
[   79.038983]  [<ffffffff812baf87>] sysfs_rename_link+0x57/0xe0
[   79.039030]  [<ffffffff81689e72>] netdev_adjacent_rename_links+0xa2/0x160

The current scheme (sysfs_remove_link() + sysfs_add_link()) works perfectly
well without any namespaces. I'll dig into it once I have some spare time,
it's not at all critical.

[1]: the patch (I've included your patch too, just in case):

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 67b180d..0c9377a 100644
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
index 3ae3f1b..651444a 100644
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
index 6695040..093d992 100644
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
diff --git a/net/core/dev.c b/net/core/dev.c
index 9957557..5d24d8e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5005,19 +5005,20 @@ EXPORT_SYMBOL(netdev_upper_dev_unlink);
  void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
  {
  	struct netdev_adjacent *iter;
+	char old_linkname[IFNAMSIZ+7], new_linkname[IFNAMSIZ+7];
  
  	list_for_each_entry(iter, &dev->adj_list.upper, list) {
-		netdev_adjacent_sysfs_del(iter->dev, oldname,
-					  &iter->dev->adj_list.lower);
-		netdev_adjacent_sysfs_add(iter->dev, dev,
-					  &iter->dev->adj_list.lower);
+		sprintf(old_linkname, "lower_%s", oldname);
+		sprintf(new_linkname, "lower_%s", dev->name);
+		sysfs_rename_link(&(iter->dev->dev.kobj), &(dev->dev.kobj),
+				  old_linkname, new_linkname);
  	}
  
  	list_for_each_entry(iter, &dev->adj_list.lower, list) {
-		netdev_adjacent_sysfs_del(iter->dev, oldname,
-					  &iter->dev->adj_list.upper);
-		netdev_adjacent_sysfs_add(iter->dev, dev,
-					  &iter->dev->adj_list.upper);
+		sprintf(old_linkname, "upper_%s", oldname);
+		sprintf(new_linkname, "upper_%s", dev->name);
+		sysfs_rename_link(&(iter->dev->dev.kobj), &(dev->dev.kobj),
+				  old_linkname, new_linkname);
  	}
  }
  
