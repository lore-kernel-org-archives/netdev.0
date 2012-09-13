From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v5 4/8] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Thu, 13 Sep 2012 09:50:55 +0200
Message-ID: <1347522655-24158-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

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

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 68 +++++++++++++++++++++++++++++-------------=
--------
 2 files changed, 41 insertions(+), 29 deletions(-)

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
index ced292d..1b18090 100644
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
@@ -1321,7 +1321,7 @@ static int parse_cgroupfs_options(char *data, str=
uct cgroup_sb_opts *opts)
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
@@ -1337,7 +1337,7 @@ static int parse_cgroupfs_options(char *data, str=
uct cgroup_sb_opts *opts)
 		 * raced with a module_delete call, and to the user this is
 		 * essentially a "subsystem doesn't exist" case.
 		 */
-		for (i--; i >=3D CGROUP_BUILTIN_SUBSYS_COUNT; i--) {
+		for (i--; i >=3D 0; i--) {
 			/* drop refcounts only on the ones we took */
 			unsigned long bit =3D 1UL << i;
=20
@@ -1354,7 +1354,7 @@ static int parse_cgroupfs_options(char *data, str=
uct cgroup_sb_opts *opts)
 static void drop_parsed_module_refcounts(unsigned long subsys_mask)
 {
 	int i;
-	for (i =3D CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++)=
 {
+	for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit =3D 1UL << i;
=20
 		if (!(bit & subsys_mask))
@@ -4442,8 +4442,7 @@ int __init_or_module cgroup_load_subsys(struct cg=
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
@@ -4457,7 +4456,7 @@ int __init_or_module cgroup_load_subsys(struct cg=
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
@@ -4560,7 +4559,6 @@ void cgroup_unload_subsys(struct cgroup_subsys *s=
s)
=20
 	mutex_lock(&cgroup_mutex);
 	/* deassign the subsys_id */
-	BUG_ON(ss->subsys_id < CGROUP_BUILTIN_SUBSYS_COUNT);
 	subsys[ss->subsys_id] =3D NULL;
=20
 	/* remove subsystem from rootnode's list of subsystems */
@@ -4623,10 +4621,13 @@ int __init cgroup_init_early(void)
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
@@ -4659,9 +4660,12 @@ int __init cgroup_init(void)
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
@@ -4856,13 +4860,16 @@ void cgroup_fork_callbacks(struct task_struct *=
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
@@ -4967,12 +4974,13 @@ void cgroup_exit(struct task_struct *tsk, int r=
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
@@ -5158,13 +5166,17 @@ static int __init cgroup_disable(char *str)
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
