From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Fri, 2 May 2008 12:42:22 -0500
Message-ID: <20080502174222.GA16493@sergelap.austin.ibm.com>
References: <20080429171015.473938697@theryb.frec.bull.fr> <20080429173621.GA16625@suse.de> <20080429180445.GA18110@sergelap.austin.ibm.com> <20080429184151.GA19794@suse.de> <20080429193417.GA19282@sergelap.austin.ibm.com> <20080501031341.GD4911@suse.de> <20080501151051.GB16038@sergelap.austin.ibm.com> <m11w4lho08.fsf@frodo.ebiederm.org> <20080501210550.GA22534@sergelap.austin.ibm.com> <m1prs5fzzd.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Greg KH <gregkh@suse.de>,
	Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:38205 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759416AbYEBRma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 13:42:30 -0400
Content-Disposition: inline
In-Reply-To: <m1prs5fzzd.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> 
> > Quoting Eric W. Biederman (ebiederm@xmission.com):
> 
> > Ok as it turns out Benjamin Thery does in fact have a patch to fix this.
> > Benjamin, please send your renaming patch out tomorrow if you can?
> >
> > I guess this is why I didn't really see the problem Benjamin said there
> > was - it just works with SYSFS_DEPRECATED  :)
> 
> It will be nice to see that patch.  I'm curious what the problem was.
> 
> Eric

Here is the patch he had privately sent.  As the comments indicate he's
still refining it so yell at me not him...   but this on top of the
tagged dir patchset makes everything work for me.

(I'd *really* like to see network namespaces be generally usable sometime
in 2.6.26.)

thanks,
-serge


[This is a proposal to fix the issue with network devices movement 
 and sysfs not being updated correctly.
 Please comment.
 There is no locking in sysfs_tag_will_change(), this may be wrong.]


When a network device is moved between namespaces its sysfs entry isn't
updated correctly because kobject_rename() fails before sysfs_rename_dir()
is called. kobject_rename() prints a warning and returns when it detects 
a kobject in the same kset already has the same name.

When moving between namespaces the device keeps its name but the sysfs 
tag associated with its sysfs_dirent should be updated to reflect the fact 
it now belongs to another namespace. This is done in sysfs_rename_dir().


* The simplest change we can make to "fix" kobject_rename() is to allow 
  a kobject to be renamed to the same name without complaining: we allow
  dumb renaming. We only check the name is actually "owned" by it.

(lib/kobject.c: kobject_rename())
                temp_kobj = kset_find_obj(kobj->kset, new_name);
                if (temp_kobj) {
-                       printk(KERN_WARNING "kobject '%s' cannot be renamed "
-                              "to '%s' as '%s' is already in existence.\n",
-                              kobject_name(kobj), new_name, new_name);
+                       if (kobj != temp_kobj) {
+                               printk(KERN_WARNING "kobject '%s' cannot be renamed "
+                                      "to '%s' as '%s' is already in existence.\n",
+                                      kobject_name(kobj), new_name, new_name);
+                               kobject_put(temp_kobj);
+                               return -EINVAL;
+                       }
                        kobject_put(temp_kobj);
-                       return -EINVAL;
                }

* This patch goes a bit further, it allows a kobject to be renamed to
  the same name only if the sysfs tag associated with it will change.

This patch applies on 2.6.25-mm1 on top of the sysfs tagged directories
patchset.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 fs/sysfs/dir.c        |   11 +++++++++++
 include/linux/sysfs.h |    6 ++++++
 lib/kobject.c         |   16 +++++++++++-----
 3 files changed, 28 insertions(+), 5 deletions(-)

Index: linux-mm/fs/sysfs/dir.c
===================================================================
--- linux-mm.orig/fs/sysfs/dir.c
+++ linux-mm/fs/sysfs/dir.c
@@ -909,6 +909,17 @@ err_out:
 	return error;
 }

+int sysfs_tag_will_change(struct kobject * kobj)
+{
+	struct sysfs_dirent *sd = kobj->sd;
+	const void *old_tag, *tag;
+
+	old_tag = sysfs_dirent_tag(sd);
+	tag = sysfs_creation_tag(sd->s_parent, sd);
+
+	return old_tag != tag;
+}
+
 int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 {
 	struct sysfs_dirent *sd = kobj->sd;
Index: linux-mm/include/linux/sysfs.h
===================================================================
--- linux-mm.orig/include/linux/sysfs.h
+++ linux-mm/include/linux/sysfs.h
@@ -95,6 +95,7 @@ int sysfs_schedule_callback(struct kobje

 int __must_check sysfs_create_dir(struct kobject *kobj);
 void sysfs_remove_dir(struct kobject *kobj);
+int sysfs_tag_will_change(struct kobject *kobj);
 int __must_check sysfs_rename_dir(struct kobject *kobj, const char *new_name);
 int __must_check sysfs_move_dir(struct kobject *kobj,
 				struct kobject *new_parent_kobj);
@@ -152,6 +153,11 @@ static inline void sysfs_remove_dir(stru
 {
 }

+static inline int sysfs_tag_will_change(struct kobject *kobj)
+{
+	return 0;
+}
+
 static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
 {
 	return 0;
Index: linux-mm/lib/kobject.c
===================================================================
--- linux-mm.orig/lib/kobject.c
+++ linux-mm/lib/kobject.c
@@ -466,11 +466,17 @@ int kobject_rename(struct kobject *kobj,
 		struct kobject *temp_kobj;
 		temp_kobj = kset_find_obj(kobj->kset, new_name);
 		if (temp_kobj) {
-			printk(KERN_WARNING "kobject '%s' cannot be renamed "
-			       "to '%s' as '%s' is already in existence.\n",
-			       kobject_name(kobj), new_name, new_name);
-			kobject_put(temp_kobj);
-			return -EINVAL;
+			if (temp_kobj == kobj && sysfs_tag_will_change(kobj)) {
+				/* OK: Same name, but the sysfs tag will change */
+				kobject_put(temp_kobj);
+			} else {
+				/* Even sysfs tag won't change */
+				printk(KERN_WARNING "kobject '%s' cannot be renamed "
+				       "to '%s' as '%s' is already in existence.\n",
+				       kobject_name(kobj), new_name, new_name);
+				kobject_put(temp_kobj);
+				return -EINVAL;
+			}
 		}
 	}


-- 

--~--~---------~--~----~------------~-------~--~----~
You received this message because you are subscribed to the Google Groups "lxc-dev" group.
To post to this group, send email to lxc-dev@googlegroups.com
To unsubscribe from this group, send email to lxc-dev-unsubscribe@googlegroups.com
For more options, visit this group at http://groups.google.com/group/lxc-dev?hl=en
-~----------~----~----~----~------~----~------~--~---
