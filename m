From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v4 4/8] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Wed, 12 Sep 2012 16:12:04 +0200
Message-ID: <1347459128-32236-5-git-send-email-wagi@monom.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:33132 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758847Ab2ILOMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 10:12:13 -0400
In-Reply-To: <1347459128-32236-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Wagner <daniel.wagner@bmw-carit.de>

CGROUP_BUILTIN_SUBSYS_COUNT is used as start index or stop index when
looping over the subsys array looking either at the builtin or the
module subsystems. Since all the builtin subsystems have an id which
is lower then CGROUP_BUILTIN_SUBSYS_COUNT we know that any module will
have an id larger than CGROUP_BUILTIN_SUBSYS_COUNT. In short the ids
are sorted.

We are about to change id assignment to happen only at compile time
later in this series. That means we can't rely on the above trick
since all ids will always be defined at compile time. Furthermore,
ordering the builtin subsystems and the module subsystems is not
really necessary.

So we need a different way to know which subsystem is a builtin or a
module one. We can use the subsys[]->module pointer for this. Any
place where we need to know if a subsys is module we just check for
the pointer. If it is NULL then the subsystem is a builtin one.

With this we are able to drop the CGROUP_BUILTIN_SUBSYS_COUNT
enum. Though we need to introduce a temporary placeholder so that we
don't get a compilation error when only CONFIG_CGROUP is selected and
no single controller. An empty enum definition is not valid. Later in
this series we are able to remove the placeholder again.

And with this change we get a fix for this:

kernel/cgroup.c: In function =E2=80=98cgroup_load_subsys=E2=80=99:
kernel/cgroup.c:4326:38: warning: array subscript is below array bounds=
 [-Warray-bounds]

when CONFIG_CGROUP=3Dy and no built in controller was enabled.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Acked-by: Tejun Heo <tj@kernel.org>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 75 +++++++++++++++++++++++++++++++-----------=
--------
 2 files changed, 48 insertions(+), 29 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 145901f..1916cdb 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -48,7 +48,7 @@ extern const struct file_operations proc_cgroup_opera=
tions;
 #define SUBSYS(_x) _x ## _subsys_id,
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
-	CGROUP_BUILTIN_SUBSYS_COUNT
+	__CGROUP_TEMPORARY_PLACEHOLDER
 };
 #undef SUBSYS
 /*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ced292d..2726d82 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -88,7 +88,7 @@ static DEFINE_MUTEX(cgroup_root_mutex);
=20
 /*
  * Generate an array of cgroup subsystem pointers. At boot time, this =
is
- * populated up to CGROUP_BUILTIN_SUBSYS_COUNT, and modular subsystems=
 are
+ * populated with the built in subsystems, and modular subsystems are
  * registered after that. The mutable section of this array is protect=
ed by
  * cgroup_mutex.
  */
@@ -1321,11 +1321,13 @@ static int parse_cgroupfs_options(char *data, s=
truct cgroup_sb_opts *opts)
 	 * take duplicate reference counts on a subsystem that's already used=
,
 	 * but rebind_subsystems handles this case.
 	 */
-	for (i =3D CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++)=
 {
+	for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit =3D 1UL << i;
=20
 		if (!(bit & opts->subsys_mask))
 			continue;
+		if (!subsys[i]->module)
+			continue;
 		if (!try_module_get(subsys[i]->module)) {
 			module_pin_failed =3D true;
 			break;
@@ -1337,12 +1339,14 @@ static int parse_cgroupfs_options(char *data, s=
truct cgroup_sb_opts *opts)
 		 * raced with a module_delete call, and to the user this is
 		 * essentially a "subsystem doesn't exist" case.
 		 */
-		for (i--; i >=3D CGROUP_BUILTIN_SUBSYS_COUNT; i--) {
+		for (i--; i >=3D 0; i--) {
 			/* drop refcounts only on the ones we took */
 			unsigned long bit =3D 1UL << i;
=20
 			if (!(bit & opts->subsys_mask))
 				continue;
+			if (!subsys[i]->module)
+				continue;
 			module_put(subsys[i]->module);
 		}
 		return -ENOENT;
@@ -1354,11 +1358,13 @@ static int parse_cgroupfs_options(char *data, s=
truct cgroup_sb_opts *opts)
 static void drop_parsed_module_refcounts(unsigned long subsys_mask)
 {
 	int i;
-	for (i =3D CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++)=
 {
+	for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit =3D 1UL << i;
=20
 		if (!(bit & subsys_mask))
 			continue;
+		if (!subsys[i]->module)
+			continue;
 		module_put(subsys[i]->module);
 	}
 }
@@ -1437,6 +1443,7 @@ static void init_cgroup_housekeeping(struct cgrou=
p *cgrp)
 	INIT_LIST_HEAD(&cgrp->event_list);
 	spin_lock_init(&cgrp->event_list_lock);
 	simple_xattrs_init(&cgrp->xattrs);
+	memset(cgrp->subsys, 0, sizeof(cgrp->subsys));
 }
=20
 static void init_cgroup_root(struct cgroupfs_root *root)
@@ -4442,8 +4449,7 @@ int __init_or_module cgroup_load_subsys(struct cg=
roup_subsys *ss)
 	 * since cgroup_init_subsys will have already taken care of it.
 	 */
 	if (ss->module =3D=3D NULL) {
-		/* a few sanity checks */
-		BUG_ON(ss->subsys_id >=3D CGROUP_BUILTIN_SUBSYS_COUNT);
+		/* a sanity check */
 		BUG_ON(subsys[ss->subsys_id] !=3D ss);
 		return 0;
 	}
@@ -4457,7 +4463,7 @@ int __init_or_module cgroup_load_subsys(struct cg=
roup_subsys *ss)
 	 */
 	mutex_lock(&cgroup_mutex);
 	/* find the first empty slot in the array */
-	for (i =3D CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++)=
 {
+	for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		if (subsys[i] =3D=3D NULL)
 			break;
 	}
@@ -4560,7 +4566,6 @@ void cgroup_unload_subsys(struct cgroup_subsys *s=
s)
=20
 	mutex_lock(&cgroup_mutex);
 	/* deassign the subsys_id */
-	BUG_ON(ss->subsys_id < CGROUP_BUILTIN_SUBSYS_COUNT);
 	subsys[ss->subsys_id] =3D NULL;
=20
 	/* remove subsystem from rootnode's list of subsystems */
@@ -4623,10 +4628,13 @@ int __init cgroup_init_early(void)
 	for (i =3D 0; i < CSS_SET_TABLE_SIZE; i++)
 		INIT_HLIST_HEAD(&css_set_table[i]);
=20
-	/* at bootup time, we don't worry about modular subsystems */
-	for (i =3D 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+	for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss =3D subsys[i];
=20
+		/* at bootup time, we don't worry about modular subsystems */
+		if (!ss || ss->module)
+			continue;
+
 		BUG_ON(!ss->name);
 		BUG_ON(strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN);
 		BUG_ON(!ss->create);
@@ -4659,9 +4667,12 @@ int __init cgroup_init(void)
 	if (err)
 		return err;
=20
-	/* at bootup time, we don't worry about modular subsystems */
-	for (i =3D 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+	for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss =3D subsys[i];
+
+		/* at bootup time, we don't worry about modular subsystems */
+		if (!ss || ss->module)
+			continue;
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
 		if (ss->use_id)
@@ -4856,13 +4867,16 @@ void cgroup_fork_callbacks(struct task_struct *=
child)
 {
 	if (need_forkexit_callback) {
 		int i;
-		/*
-		 * forkexit callbacks are only supported for builtin
-		 * subsystems, and the builtin section of the subsys array is
-		 * immutable, so we don't need to lock the subsys array here.
-		 */
-		for (i =3D 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+		for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss =3D subsys[i];
+
+			/*
+			 * forkexit callbacks are only supported for
+			 * builtin subsystems.
+			 */
+			if (!ss || ss->module)
+				continue;
+
 			if (ss->fork)
 				ss->fork(child);
 		}
@@ -4967,12 +4981,13 @@ void cgroup_exit(struct task_struct *tsk, int r=
un_callbacks)
 	tsk->cgroups =3D &init_css_set;
=20
 	if (run_callbacks && need_forkexit_callback) {
-		/*
-		 * modular subsystems can't use callbacks, so no need to lock
-		 * the subsys array
-		 */
-		for (i =3D 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+		for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss =3D subsys[i];
+
+			/* modular subsystems can't use callbacks */
+			if (!ss || ss->module)
+				continue;
+
 			if (ss->exit) {
 				struct cgroup *old_cgrp =3D
 					rcu_dereference_raw(cg->subsys[i])->cgroup;
@@ -5158,13 +5173,17 @@ static int __init cgroup_disable(char *str)
 	while ((token =3D strsep(&str, ",")) !=3D NULL) {
 		if (!*token)
 			continue;
-		/*
-		 * cgroup_disable, being at boot time, can't know about module
-		 * subsystems, so we don't worry about them.
-		 */
-		for (i =3D 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+		for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss =3D subsys[i];
=20
+			/*
+			 * cgroup_disable, being at boot time, can't
+			 * know about module subsystems, so we don't
+			 * worry about them.
+			 */
+			if (!ss || ss->module)
+				continue;
+
 			if (!strcmp(token, ss->name)) {
 				ss->disabled =3D 1;
 				printk(KERN_INFO "Disabling %s control group"
--=20
1.7.12.315.g682ce8b
