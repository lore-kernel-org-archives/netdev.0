From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Wed, 21 Oct 2015 17:17:13 +0200
Message-ID: <5627AC79.5000704@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net>	<5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net>	<562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net>	<5623CD8D.7000500@iogearbox.net> <56240814.8020105@plumgrid.com>	<1445240171.3728424.413797809.230D716F@webmail.messagingengine.com>	<5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net>	<562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net>	<56253335.9000206@plumgrid.com>	<1445280385.602530.414418777.63627F89@webmail.messagingengine.com>	<562545AA.2080207@plumgrid.com>	<1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>	<56255714.2070800@plumgrid.com> <56256BF9.1090500@iogearbox.net>	<56258B11.9080505@plumgrid.com> <5625FF71.8020304@iogearbox.net>	<56267FAF.60206@plumgr
 id.com> <87io61fjx3.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87io61fjx3.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/2015 08:56 PM, Eric W. Biederman wrote:
...
> Just FYI:  Using a device for this kind of interface is pretty
> much a non-starter as that quickly gets you into situations where
> things do not work in containers.  If someone gets a version of device
> namespaces past GregKH it might be up for discussion to use character
> devices.

Okay, you are referring to this discussion here:

   http://thread.gmane.org/gmane.linux.kernel.containers/26760

What had been mentioned earlier in this thread was to have a namespace
pass-through facility enforced by device cgroups we have in the kernel,
which is one out of various means used to enforce policy today by
deployment systems such as docker, for example. But more below.

I think this all depends on the kind of expectations we have, where all
this is going. In the original proposal, it was agreed to have the
operation that creates a node as 'capable(CAP_SYS_ADMIN)'-only (in the
way like most of the rest of eBPF is restricted), and based on the use
case we distribute such objects to unprivileged applications. But I
understand that it seems the trend lately to lift eBPF restrictions at
some point anyway, and thus the CAP_SYS_ADMIN is suddenly irrelevant
again. Fair enough.

Don't get me wrong, I really don't mind if it will be some version of
this fs patch or whatever architecture else we find consensus on, I
think this discussion is merely trying to evaluate/discuss on what seems
to be a good fit, also in terms of future requirements and integration.

So far, during this discussion, it was proposed to modify the file system
to a single-mount one and to stick this under /sys/kernel/bpf/. This
will not have "real" namespace support either, but it was proposed to
have a following structure:

   /sys/kernel/bpf/username/<optional_dirs_mkdir_by_user>/progX

So, the file system will have kind of a user home-directory for each user
to isolate through permissions, if I understood correctly.

If we really want to go this route, then I think there are no big stones
in the way for the other model either. It should look roughly drafted like
the below.

Together with device cgroups for containers, it would allow scenarios where
you can have:

   * eBPF (map/prog) device pass-through so a map/prog could even be shared out
     from the initial namespace into individual ones/all (one could possibly
     extend such maps as read-only for these consumers).
   * eBPF device creation for unprivileged users with permissions being set
     accordingly (as in fs case).
   * Since cgroup controller can also do wildcards on major/minors, we could
     make that further fine-grained.
   * eBPF device creation can also be enforced by the cgroup controller to be
     entirely disallowed for a specific container.

(An admin can determine the dynamically created major f.e. under /proc/devices.)

FWIW, here's a drafted diff on the idea:

  (https://git.breakpoint.cc/cgit/dborkman/net-next.git/log/?h=ebpf-fds-final6)

  drivers/base/core.c      |  38 +++-
  include/linux/bpf.h      |  39 ++++-
  include/linux/device.h   |  10 +-
  include/uapi/linux/bpf.h |  45 +----
  kernel/bpf/Makefile      |   4 +-
  kernel/bpf/core.c        |   3 +-
  kernel/bpf/device.c      | 441 +++++++++++++++++++++++++++++++++++++++++++++++
  kernel/bpf/syscall.c     |  52 +++++-
  mm/backing-dev.c         |   3 +-
  9 files changed, 567 insertions(+), 68 deletions(-)
  create mode 100644 kernel/bpf/device.c

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 334ec7e..11721c8 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1678,7 +1678,8 @@ static void device_create_release(struct device *dev)

  static struct device *
  device_create_groups_vargs(struct class *class, struct device *parent,
-			   dev_t devt, void *drvdata,
+			   dev_t devt, const struct device_type *type,
+			   void *drvdata,
  			   const struct attribute_group **groups,
  			   const char *fmt, va_list args)
  {
@@ -1697,6 +1698,7 @@ device_create_groups_vargs(struct class *class, struct device *parent,
  	device_initialize(dev);
  	dev->devt = devt;
  	dev->class = class;
+	dev->type = type;
  	dev->parent = parent;
  	dev->groups = groups;
  	dev->release = device_create_release;
@@ -1743,11 +1745,11 @@ error:
   * been created with a call to class_create().
   */
  struct device *device_create_vargs(struct class *class, struct device *parent,
-				   dev_t devt, void *drvdata, const char *fmt,
-				   va_list args)
+				   dev_t devt, const struct device_type *type,
+				   void *drvdata, const char *fmt, va_list args)
  {
-	return device_create_groups_vargs(class, parent, devt, drvdata, NULL,
-					  fmt, args);
+	return device_create_groups_vargs(class, parent, devt, type, drvdata,
+					  NULL, fmt, args);
  }
  EXPORT_SYMBOL_GPL(device_create_vargs);

@@ -1782,12 +1784,31 @@ struct device *device_create(struct class *class, struct device *parent,
  	struct device *dev;

  	va_start(vargs, fmt);
-	dev = device_create_vargs(class, parent, devt, drvdata, fmt, vargs);
+	dev = device_create_vargs(class, parent, devt, NULL, drvdata,
+				  fmt, vargs);
  	va_end(vargs);
+
  	return dev;
  }
  EXPORT_SYMBOL_GPL(device_create);

+/* XXX document */
+struct device *device_create_type(struct class *class, struct device *parent,
+				  dev_t devt, const struct device_type *type,
+				  void *drvdata, const char *fmt, ...)
+{
+	va_list vargs;
+	struct device *dev;
+
+	va_start(vargs, fmt);
+	dev = device_create_vargs(class, parent, devt, type, drvdata,
+				  fmt, vargs);
+	va_end(vargs);
+
+	return dev;
+}
+EXPORT_SYMBOL_GPL(device_create_type);
+
  /**
   * device_create_with_groups - creates a device and registers it with sysfs
   * @class: pointer to the struct class that this device should be registered to
@@ -1825,9 +1846,10 @@ struct device *device_create_with_groups(struct class *class,
  	struct device *dev;

  	va_start(vargs, fmt);
-	dev = device_create_groups_vargs(class, parent, devt, drvdata, groups,
-					 fmt, vargs);
+	dev = device_create_groups_vargs(class, parent, devt, NULL, drvdata,
+					 groups, fmt, vargs);
  	va_end(vargs);
+
  	return dev;
  }
  EXPORT_SYMBOL_GPL(device_create_with_groups);
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 0ae6f77..8476911 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -8,8 +8,13 @@
  #define _LINUX_BPF_H 1

  #include <uapi/linux/bpf.h>
+
  #include <linux/workqueue.h>
  #include <linux/file.h>
+#include <linux/cdev.h>
+
+/* BPF flags. */
+#define BPF_F_HAS_DEV	(1 << 0)

  struct bpf_map;

@@ -31,15 +36,21 @@ struct bpf_map_ops {
  };

  struct bpf_map {
-	atomic_t refcnt;
+	const struct bpf_map_ops *ops;
+	struct user_struct *user;
  	enum bpf_map_type map_type;
  	u32 key_size;
  	u32 value_size;
  	u32 max_entries;
  	u32 pages;
-	struct user_struct *user;
-	const struct bpf_map_ops *ops;
-	struct work_struct work;
+	int minor;
+	atomic_t refcnt;
+	u32 flags;
+	union {
+		struct work_struct work;
+		struct mutex m_lock;
+	};
+	struct cdev cdev;
  };

  struct bpf_map_type_list {
@@ -125,16 +136,20 @@ struct bpf_prog_type_list {
  };

  struct bpf_prog_aux {
-	atomic_t refcnt;
-	u32 used_map_cnt;
  	const struct bpf_verifier_ops *ops;
-	struct bpf_map **used_maps;
-	struct bpf_prog *prog;
  	struct user_struct *user;
+	struct bpf_prog *prog;
+	struct bpf_map **used_maps;
+	u32 used_map_cnt;
+	int minor;
+	atomic_t refcnt;
+	u32 flags;
  	union {
+		struct mutex p_lock;
  		struct work_struct work;
  		struct rcu_head	rcu;
  	};
+	struct cdev cdev;
  };

  struct bpf_array {
@@ -167,11 +182,19 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
  void bpf_prog_put(struct bpf_prog *prog);
  void bpf_prog_put_rcu(struct bpf_prog *prog);

+struct bpf_map *bpf_map_get(u32 ufd);
  struct bpf_map *__bpf_map_get(struct fd f);
  void bpf_map_put(struct bpf_map *map);

  extern int sysctl_unprivileged_bpf_disabled;

+int __bpf_dev_create(__u32 ufd);
+int __bpf_dev_destroy(__u32 ufd);
+int __bpf_dev_connect(__u32 ufd);
+
+int bpf_map_new_fd(struct bpf_map *map);
+int bpf_prog_new_fd(struct bpf_prog *prog);
+
  /* verify correctness of eBPF program */
  int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
  #else
diff --git a/include/linux/device.h b/include/linux/device.h
index 5d7bc63..a9a3360 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1038,15 +1038,19 @@ extern int __must_check device_reprobe(struct device *dev);
  /*
   * Easy functions for dynamically creating devices on the fly
   */
-extern __printf(5, 0)
+extern __printf(6, 0)
  struct device *device_create_vargs(struct class *cls, struct device *parent,
-				   dev_t devt, void *drvdata,
-				   const char *fmt, va_list vargs);
+				   dev_t devt, const struct device_type *type,
+				   void *drvdata, const char *fmt, va_list vargs);
  extern __printf(5, 6)
  struct device *device_create(struct class *cls, struct device *parent,
  			     dev_t devt, void *drvdata,
  			     const char *fmt, ...);
  extern __printf(6, 7)
+struct device *device_create_type(struct class *class, struct device *parent,
+				  dev_t devt, const struct device_type *type,
+				  void *drvdata, const char *fmt, ...);
+extern __printf(6, 7)
  struct device *device_create_with_groups(struct class *cls,
  			     struct device *parent, dev_t devt, void *drvdata,
  			     const struct attribute_group **groups,
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 564f1f0..55e5aad 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -63,50 +63,17 @@ struct bpf_insn {
  	__s32	imm;		/* signed immediate constant */
  };

-/* BPF syscall commands */
+/* BPF syscall commands, see bpf(2) man-page for details. */
  enum bpf_cmd {
-	/* create a map with given type and attributes
-	 * fd = bpf(BPF_MAP_CREATE, union bpf_attr *, u32 size)
-	 * returns fd or negative error
-	 * map is deleted when fd is closed
-	 */
  	BPF_MAP_CREATE,
-
-	/* lookup key in a given map
-	 * err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key, attr->value
-	 * returns zero and stores found elem into value
-	 * or negative error
-	 */
  	BPF_MAP_LOOKUP_ELEM,
-
-	/* create or update key/value pair in a given map
-	 * err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key, attr->value, attr->flags
-	 * returns zero or negative error
-	 */
  	BPF_MAP_UPDATE_ELEM,
-
-	/* find and delete elem by key in a given map
-	 * err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key
-	 * returns zero or negative error
-	 */
  	BPF_MAP_DELETE_ELEM,
-
-	/* lookup key in a given map and return next key
-	 * err = bpf(BPF_MAP_GET_NEXT_KEY, union bpf_attr *attr, u32 size)
-	 * Using attr->map_fd, attr->key, attr->next_key
-	 * returns zero and stores next key or negative error
-	 */
  	BPF_MAP_GET_NEXT_KEY,
-
-	/* verify and load eBPF program
-	 * prog_fd = bpf(BPF_PROG_LOAD, union bpf_attr *attr, u32 size)
-	 * Using attr->prog_type, attr->insns, attr->license
-	 * returns fd or negative error
-	 */
  	BPF_PROG_LOAD,
+	BPF_DEV_CREATE,
+	BPF_DEV_DESTROY,
+	BPF_DEV_CONNECT,
  };

  enum bpf_map_type {
@@ -160,6 +127,10 @@ union bpf_attr {
  		__aligned_u64	log_buf;	/* user supplied buffer */
  		__u32		kern_version;	/* checked when prog_type=kprobe */
  	};
+
+	struct { /* anonymous struct used by BPF_DEV_* commands */
+		__u32		fd;
+	};
  } __attribute__((aligned(8)));

  /* integer value in 'imm' field of BPF_CALL instruction selects which helper
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index e6983be..f871ca6 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,2 +1,4 @@
  obj-y := core.o
-obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o hashtab.o arraymap.o helpers.o
+
+obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o device.o helpers.o
+obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 8086471..334b1bd 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -92,6 +92,7 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)

  	fp->pages = size / PAGE_SIZE;
  	fp->aux = aux;
+	fp->aux->prog = fp;

  	return fp;
  }
@@ -116,6 +117,7 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,

  		memcpy(fp, fp_old, fp_old->pages * PAGE_SIZE);
  		fp->pages = size / PAGE_SIZE;
+		fp->aux->prog = fp;

  		/* We keep fp->aux from fp_old around in the new
  		 * reallocated structure.
@@ -726,7 +728,6 @@ void bpf_prog_free(struct bpf_prog *fp)
  	struct bpf_prog_aux *aux = fp->aux;

  	INIT_WORK(&aux->work, bpf_prog_free_deferred);
-	aux->prog = fp;
  	schedule_work(&aux->work);
  }
  EXPORT_SYMBOL_GPL(bpf_prog_free);
diff --git a/kernel/bpf/device.c b/kernel/bpf/device.c
new file mode 100644
index 0000000..711c9a4
--- /dev/null
+++ b/kernel/bpf/device.c
@@ -0,0 +1,441 @@
+/*
+ * Special file backend for persistent eBPF maps and programs, used by
+ * bpf() system call.
+ *
+ * (C) 2015 Daniel Borkmann <daniel@iogearbox.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/fs.h>
+#include <linux/filter.h>
+#include <linux/bpf.h>
+#include <linux/idr.h>
+#include <linux/mutex.h>
+#include <linux/device_cgroup.h>
+#include <linux/cdev.h>
+
+#define BPF_MAX_DEVS	(1UL << MINORBITS)
+#define BPF_MODE_DEF	(S_IRUSR | S_IWUSR)
+
+enum bpf_type {
+	BPF_TYPE_PROG,
+	BPF_TYPE_MAP,
+};
+
+static struct class *bpf_class;
+
+static dev_t bpf_map_devt;
+static DEFINE_IDR(bpf_map_idr);
+static DEFINE_MUTEX(bpf_map_idr_lock);
+
+static dev_t bpf_prog_devt;
+static DEFINE_IDR(bpf_prog_idr);
+static DEFINE_MUTEX(bpf_prog_idr_lock);
+
+static int bpf_map_get_minor(struct bpf_map *map)
+{
+	int minor;
+
+	mutex_lock(&bpf_map_idr_lock);
+	minor = idr_alloc(&bpf_map_idr, map, 0, BPF_MAX_DEVS, GFP_KERNEL);
+	mutex_unlock(&bpf_map_idr_lock);
+
+	return minor;
+}
+
+static void bpf_map_put_minor(const struct bpf_map *map)
+{
+	mutex_lock(&bpf_map_idr_lock);
+	idr_remove(&bpf_map_idr, map->minor);
+	mutex_unlock(&bpf_map_idr_lock);
+}
+
+static int bpf_prog_get_minor(struct bpf_prog *prog)
+{
+	int minor;
+
+	mutex_lock(&bpf_prog_idr_lock);
+	minor = idr_alloc(&bpf_prog_idr, prog, 0, BPF_MAX_DEVS, GFP_KERNEL);
+	mutex_unlock(&bpf_prog_idr_lock);
+
+	return minor;
+}
+
+static void bpf_prog_put_minor(const struct bpf_prog *prog)
+{
+	mutex_lock(&bpf_prog_idr_lock);
+	idr_remove(&bpf_prog_idr, prog->aux->minor);
+	mutex_unlock(&bpf_prog_idr_lock);
+}
+
+static int bpf_map_open(struct inode *inode, struct file *filep)
+{
+	filep->private_data = container_of(inode->i_cdev,
+					   struct bpf_map, cdev);
+	return 0;
+}
+
+static const struct file_operations bpf_dev_map_fops = {
+	.owner		= THIS_MODULE,
+	.open		= bpf_map_open,
+	.llseek		= noop_llseek,
+};
+
+static int bpf_prog_open(struct inode *inode, struct file *filep)
+{
+	filep->private_data = container_of(inode->i_cdev,
+					   struct bpf_prog_aux, cdev)->prog;
+	return 0;
+}
+
+static const struct file_operations bpf_dev_prog_fops = {
+	.owner		= THIS_MODULE,
+	.open		= bpf_prog_open,
+	.llseek		= noop_llseek,
+};
+
+static char *bpf_type_devnode(struct device *dev, umode_t *mode,
+			      kuid_t *uid, kgid_t *gid)
+{
+	if (mode)
+		*mode = BPF_MODE_DEF;
+	if (uid && gid)
+		current_uid_gid(uid, gid);
+
+	return kasprintf(GFP_KERNEL, "bpf/%s", dev_name(dev));
+}
+
+static const struct device_type bpf_dev_map_type = {
+	.name		= "map",
+	.devnode	= bpf_type_devnode,
+};
+
+static const struct device_type bpf_dev_prog_type = {
+	.name		= "prog",
+	.devnode	= bpf_type_devnode,
+};
+
+static int bpf_map_make_dev(struct bpf_map *map)
+{
+	struct device *dev;
+	dev_t devt;
+	int ret;
+
+	mutex_lock(&map->m_lock);
+	if (map->flags & BPF_F_HAS_DEV) {
+		ret = map->minor;
+		goto out;
+	}
+
+	cdev_init(&map->cdev, &bpf_dev_map_fops);
+	map->cdev.owner = map->cdev.ops->owner;
+
+	map->minor = bpf_map_get_minor(map);
+	if (map->minor < 0) {
+		ret = map->minor;
+		goto out;
+	}
+
+	devt = MKDEV(MAJOR(bpf_map_devt), map->minor);
+
+	ret = devcgroup_inode_mknod(S_IFCHR | BPF_MODE_DEF, devt);
+	if (ret)
+		goto unwind;
+
+	ret = cdev_add(&map->cdev, devt, 1);
+	if (ret)
+		goto unwind;
+
+	dev = device_create_type(bpf_class, NULL, devt, &bpf_dev_map_type,
+				 NULL, "bpf_map%d", map->minor);
+	if (IS_ERR(dev)) {
+		ret = PTR_ERR(dev);
+		goto unwind_cdev;
+	}
+
+	map->flags |= BPF_F_HAS_DEV;
+	ret = map->minor;
+out:
+	mutex_unlock(&map->m_lock);
+	return ret;
+unwind_cdev:
+	cdev_del(&map->cdev);
+unwind:
+	bpf_map_put_minor(map);
+	goto out;
+}
+
+static int bpf_map_destroy_dev(struct bpf_map *map)
+{
+	bool drop_ref = false;
+	dev_t devt;
+	int ret;
+
+	mutex_lock(&map->m_lock);
+	if (!(map->flags & BPF_F_HAS_DEV)) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	devt = MKDEV(MAJOR(bpf_map_devt), map->minor);
+	ret = map->minor;
+
+	cdev_del(&map->cdev);
+	device_destroy(bpf_class, devt);
+	bpf_map_put_minor(map);
+
+	map->flags &= ~BPF_F_HAS_DEV;
+	drop_ref = true;
+out:
+	mutex_unlock(&map->m_lock);
+
+	if (drop_ref)
+		bpf_map_put(map);
+	return ret;
+}
+
+static int bpf_prog_make_dev(struct bpf_prog *prog)
+{
+	struct bpf_prog_aux *aux = prog->aux;
+	struct device *dev;
+	dev_t devt;
+	int ret;
+
+	mutex_lock(&aux->p_lock);
+	if (aux->flags & BPF_F_HAS_DEV) {
+		ret = aux->minor;
+		goto out;
+	}
+
+	cdev_init(&aux->cdev, &bpf_dev_prog_fops);
+	aux->cdev.owner = aux->cdev.ops->owner;
+
+	aux->minor = bpf_prog_get_minor(prog);
+	if (aux->minor < 0) {
+		ret = aux->minor;
+		goto out;
+	}
+
+	devt = MKDEV(MAJOR(bpf_prog_devt), aux->minor);
+
+	ret = devcgroup_inode_mknod(S_IFCHR | BPF_MODE_DEF, devt);
+	if (ret)
+		goto unwind;
+
+	ret = cdev_add(&aux->cdev, devt, 1);
+	if (ret)
+		goto unwind;
+
+	dev = device_create_type(bpf_class, NULL, devt, &bpf_dev_prog_type,
+				 NULL, "bpf_prog%d", aux->minor);
+	if (IS_ERR(dev)) {
+		ret = PTR_ERR(dev);
+		goto unwind_cdev;
+	}
+
+	aux->flags |= BPF_F_HAS_DEV;
+	ret = aux->minor;
+out:
+	mutex_unlock(&aux->p_lock);
+	return ret;
+unwind_cdev:
+	cdev_del(&aux->cdev);
+unwind:
+	bpf_prog_put_minor(prog);
+	goto out;
+}
+
+static int bpf_prog_destroy_dev(struct bpf_prog *prog)
+{
+	struct bpf_prog_aux *aux = prog->aux;
+	bool drop_ref = false;
+	dev_t devt;
+	int ret;
+
+	mutex_lock(&aux->p_lock);
+	if (!(aux->flags & BPF_F_HAS_DEV)) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	devt = MKDEV(MAJOR(bpf_prog_devt), aux->minor);
+	ret = aux->minor;
+
+	cdev_del(&aux->cdev);
+	device_destroy(bpf_class, devt);
+	bpf_prog_put_minor(prog);
+
+	aux->flags &= ~BPF_F_HAS_DEV;
+	drop_ref = true;
+out:
+	mutex_unlock(&aux->p_lock);
+
+	if (drop_ref)
+		bpf_prog_put(prog);
+	return ret;
+}
+
+static void bpf_any_get(void *raw, enum bpf_type type)
+{
+	switch (type) {
+	case BPF_TYPE_PROG:
+		atomic_inc(&((struct bpf_prog *)raw)->aux->refcnt);
+		break;
+	case BPF_TYPE_MAP:
+		atomic_inc(&((struct bpf_map *)raw)->refcnt);
+		break;
+	}
+}
+
+void bpf_any_put(void *raw, enum bpf_type type)
+{
+	switch (type) {
+	case BPF_TYPE_PROG:
+		bpf_prog_put(raw);
+		break;
+	case BPF_TYPE_MAP:
+		bpf_map_put(raw);
+		break;
+	}
+}
+
+static void *__bpf_dev_get(struct fd f, enum bpf_type *type)
+{
+	if (!f.file)
+		return ERR_PTR(-EBADF);
+	if (f.file->f_op != &bpf_dev_map_fops &&
+	    f.file->f_op != &bpf_dev_prog_fops) {
+		fdput(f);
+		return ERR_PTR(-EINVAL);
+	}
+
+	*type = f.file->f_op == &bpf_dev_map_fops ?
+		BPF_TYPE_MAP : BPF_TYPE_PROG;
+	return f.file->private_data;
+}
+
+static void *bpf_dev_get(u32 ufd, enum bpf_type *type)
+{
+	struct fd f = fdget(ufd);
+	void *raw;
+
+	raw = __bpf_dev_get(f, type);
+	if (IS_ERR(raw))
+		return raw;
+
+	bpf_any_get(raw, *type);
+	fdput(f);
+
+	return raw;
+}
+
+static void *bpf_fd_probe_obj(u32 ufd, enum bpf_type *type)
+{
+	void *raw;
+
+	*type = BPF_TYPE_MAP;
+	raw = bpf_map_get(ufd);
+	if (IS_ERR(raw)) {
+		*type = BPF_TYPE_PROG;
+		raw = bpf_prog_get(ufd);
+	}
+
+	return raw;
+}
+
+int __bpf_dev_create(__u32 ufd)
+{
+	enum bpf_type type;
+	void *raw;
+	int ret;
+
+	raw = bpf_fd_probe_obj(ufd, &type);
+	if (IS_ERR(raw))
+		return PTR_ERR(raw);
+
+	switch (type) {
+	case BPF_TYPE_MAP:
+		ret = bpf_map_make_dev(raw);
+		break;
+	case BPF_TYPE_PROG:
+		ret = bpf_prog_make_dev(raw);
+		break;
+	}
+
+	if (ret < 0)
+		bpf_any_put(raw, type);
+
+	return ret;
+}
+
+int __bpf_dev_destroy(__u32 ufd)
+{
+	enum bpf_type type;
+	void *raw;
+	int ret;
+
+	raw = bpf_fd_probe_obj(ufd, &type);
+	if (IS_ERR(raw))
+		return PTR_ERR(raw);
+
+	switch (type) {
+	case BPF_TYPE_MAP:
+		ret = bpf_map_destroy_dev(raw);
+		break;
+	case BPF_TYPE_PROG:
+		ret = bpf_prog_destroy_dev(raw);
+		break;
+	}
+
+	bpf_any_put(raw, type);
+	return ret;
+}
+
+int __bpf_dev_connect(__u32 ufd)
+{
+	enum bpf_type type;
+	void *raw;
+	int ret;
+
+	raw = bpf_dev_get(ufd, &type);
+	if (IS_ERR(raw))
+		return PTR_ERR(raw);
+
+	switch (type) {
+	case BPF_TYPE_MAP:
+		ret = bpf_map_new_fd(raw);
+		break;
+	case BPF_TYPE_PROG:
+		ret = bpf_prog_new_fd(raw);
+		break;
+	}
+	if (ret < 0)
+		bpf_any_put(raw, type);
+
+	return ret;
+}
+
+static int __init bpf_dev_init(void)
+{
+	int ret;
+
+	ret = alloc_chrdev_region(&bpf_map_devt, 0, BPF_MAX_DEVS,
+				  "bpf_map");
+	if (ret)
+		return ret;
+
+	ret = alloc_chrdev_region(&bpf_prog_devt, 0, BPF_MAX_DEVS,
+				  "bpf_prog");
+	if (ret)
+		unregister_chrdev_region(bpf_map_devt, BPF_MAX_DEVS);
+
+	bpf_class = class_create(THIS_MODULE, "bpf");
+	return ret;
+}
+late_initcall(bpf_dev_init);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c629fe6..458b2f9 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -14,6 +14,7 @@
  #include <linux/slab.h>
  #include <linux/anon_inodes.h>
  #include <linux/file.h>
+#include <linux/mutex.h>
  #include <linux/license.h>
  #include <linux/filter.h>
  #include <linux/version.h>
@@ -111,7 +112,7 @@ static const struct file_operations bpf_map_fops = {
  	.release = bpf_map_release,
  };

-static int bpf_map_new_fd(struct bpf_map *map)
+int bpf_map_new_fd(struct bpf_map *map)
  {
  	return anon_inode_getfd("bpf-map", &bpf_map_fops, map,
  				O_RDWR | O_CLOEXEC);
@@ -141,6 +142,7 @@ static int map_create(union bpf_attr *attr)
  	if (IS_ERR(map))
  		return PTR_ERR(map);

+	mutex_init(&map->m_lock);
  	atomic_set(&map->refcnt, 1);

  	err = bpf_map_charge_memlock(map);
@@ -174,7 +176,7 @@ struct bpf_map *__bpf_map_get(struct fd f)
  	return f.file->private_data;
  }

-static struct bpf_map *bpf_map_get(u32 ufd)
+struct bpf_map *bpf_map_get(u32 ufd)
  {
  	struct fd f = fdget(ufd);
  	struct bpf_map *map;
@@ -525,18 +527,14 @@ static void __prog_put_common(struct rcu_head *rcu)
  /* version of bpf_prog_put() that is called after a grace period */
  void bpf_prog_put_rcu(struct bpf_prog *prog)
  {
-	if (atomic_dec_and_test(&prog->aux->refcnt)) {
-		prog->aux->prog = prog;
+	if (atomic_dec_and_test(&prog->aux->refcnt))
  		call_rcu(&prog->aux->rcu, __prog_put_common);
-	}
  }

  void bpf_prog_put(struct bpf_prog *prog)
  {
-	if (atomic_dec_and_test(&prog->aux->refcnt)) {
-		prog->aux->prog = prog;
+	if (atomic_dec_and_test(&prog->aux->refcnt))
  		__prog_put_common(&prog->aux->rcu);
-	}
  }
  EXPORT_SYMBOL_GPL(bpf_prog_put);

@@ -552,7 +550,7 @@ static const struct file_operations bpf_prog_fops = {
          .release = bpf_prog_release,
  };

-static int bpf_prog_new_fd(struct bpf_prog *prog)
+int bpf_prog_new_fd(struct bpf_prog *prog)
  {
  	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog,
  				O_RDWR | O_CLOEXEC);
@@ -641,6 +639,7 @@ static int bpf_prog_load(union bpf_attr *attr)
  	prog->orig_prog = NULL;
  	prog->jited = 0;

+	mutex_init(&prog->aux->p_lock);
  	atomic_set(&prog->aux->refcnt, 1);
  	prog->gpl_compatible = is_gpl ? 1 : 0;

@@ -678,6 +677,32 @@ free_prog_nouncharge:
  	return err;
  }

+#define BPF_DEV_LAST_FIELD fd
+
+static int bpf_dev_create(const union bpf_attr *attr)
+{
+	if (CHECK_ATTR(BPF_DEV))
+		return -EINVAL;
+
+	return __bpf_dev_create(attr->fd);
+}
+
+static int bpf_dev_destroy(const union bpf_attr *attr)
+{
+	if (CHECK_ATTR(BPF_DEV))
+		return -EINVAL;
+
+	return __bpf_dev_destroy(attr->fd);
+}
+
+static int bpf_dev_connect(const union bpf_attr *attr)
+{
+	if (CHECK_ATTR(BPF_DEV))
+		return -EINVAL;
+
+	return __bpf_dev_connect(attr->fd);
+}
+
  SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
  {
  	union bpf_attr attr = {};
@@ -738,6 +763,15 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
  	case BPF_PROG_LOAD:
  		err = bpf_prog_load(&attr);
  		break;
+	case BPF_DEV_CREATE:
+		err = bpf_dev_create(&attr);
+		break;
+	case BPF_DEV_DESTROY:
+		err = bpf_dev_destroy(&attr);
+		break;
+	case BPF_DEV_CONNECT:
+		err = bpf_dev_connect(&attr);
+		break;
  	default:
  		err = -EINVAL;
  		break;
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 2df8ddc..acf3847 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -786,7 +786,8 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
  		return 0;

  	va_start(args, fmt);
-	dev = device_create_vargs(bdi_class, parent, MKDEV(0, 0), bdi, fmt, args);
+	dev = device_create_vargs(bdi_class, parent, MKDEV(0, 0), NULL,
+				  bdi, fmt, args);
  	va_end(args);
  	if (IS_ERR(dev))
  		return PTR_ERR(dev);
-- 
1.9.3
