From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Sun, 18 Oct 2015 18:49:17 +0200
Message-ID: <5623CD8D.7000500@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net> <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net> <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com> <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net> <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com> <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com> <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55037 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbbJRQtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 12:49:36 -0400
In-Reply-To: <5623B4B4.2010703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2015 05:03 PM, Daniel Borkmann wrote:
> On 10/18/2015 04:20 AM, Alexei Starovoitov wrote:
> ...
>> that indeed sounds cleaner, less lines of code, no fs, etc, but
>> I don't see how it will work yet.
>
> I'll have some code ready very soon to show the concept. Will post it here
> tonight, stay tuned. ;)

Okay, I have pushed some rough working proof of concept here:

   https://git.breakpoint.cc/cgit/dborkman/net-next.git/log/?h=ebpf-fds-final5

So the idea eventually had to be slightly modified after giving this further
thoughts and is the following:

We have 3 commands (BPF_DEV_CREATE, BPF_DEV_DESTROY, BPF_DEV_CONNECT), and
related to that a bpf_attr extension with only a single __u32 fd member in it.

Now, when we have an existing map/prog fd, we can do bpf_dev_create(fd) from
the application, and the kernel will create automatically a device, assigning
major/minor, etc.

You'll automatically have a sysfs entry under a new "bpf" class, for example:

   # ls -la /sys/class/bpf/
   lrwxrwxrwx.  1 root root 0 Oct 18 18:24 bpf_map0 -> ../../devices/virtual/bpf/bpf_map0
   lrwxrwxrwx.  1 root root 0 Oct 18 18:24 bpf_prog0 -> ../../devices/virtual/bpf/bpf_prog0

   # cat /sys/class/bpf/bpf_map0/dev
   249:0
   # cat /sys/class/bpf/bpf_prog0/dev
   248:0

And they also appear automatically under:

   # ls -la /dev/bpf/
   crw-------.  1 root root 249, 0 Oct 18 17:38 bpf_map0
   crw-------.  1 root root 248, 0 Oct 18 18:23 bpf_prog0

This means, you can create your own hierarchy somewhere and then symlink to it,
or add further mknod's, f.e.:

   # mknod ./foomap c 249 0
   # ./samples/bpf/devicex map-connect ./foomap
   dev, fd:3 (Success)
   map, fd:4 (Success)
   map, fd:4 read pair:(123,0) (Success)

The nice thing about it is that you can create/unlink as many as you want, but
when you remove the real device from an application via bpf_dev_destroy(fd),
then all links disappear with it. Just like in the case of a normal device driver.

On device creation, the kernel will return the minor number via bpf(2), so you
can access the file easily, f.e. /dev/bpf/bpf_map<minor> resp. /dev/bpf/bpf_prog<minor>,
and then move on with mknod(2) or symlink(2) from there if wished.

Last but not least, we can open the device driver, and then bpf_dev_connect(fd)
will return a new fd you can operate with the bpf(2) syscall to access maps and
stuff. Same here, the remaining device driver ops, we can then still use in future
for something useful.

The example code (top commit) does, to show the concept:

** Map:

  * Create map and place map into special device:
   # ./samples/bpf/devicex map-create /tmp/map-test
   map, fd:3 (Success)
   map, dev minor:2 (Success)
   map, /dev/bpf/bpf_map2 linked to /tmp/map-test (Success)
   map, fd:3 wrote pair:(123,456) (Success)
   map, fd:3 read pair:(123,456) (Success)

  * Retrieve map from special device:
   # ./samples/bpf/devicex map-connect /tmp/map-test
   dev, fd:3 (Success)
   map, fd:4 (Success)
   map, fd:4 read pair:(123,456) (Success)

  * Destroy special device (map is still locally available):
   # ./samples/bpf/devicex map-destroy /tmp/map-test2
   dev, fd:3 (Success)
   map, fd:4 (Success)
   map, dev destroyed:2 (Success)
   map, fd:4 read pair:(123,456) (Success)

** Prog:

  * Create prog and place prog into special device:
   # ./samples/bpf/devicex prog-create /tmp/prog-test
   prog, fd:3 (Success)
   prog, dev minor:0 (Success)
   prog, /dev/bpf/bpf_prog0 linked to /tmp/prog-test (Success)
   sock, fd:4 (Success)
   sock, prog attached:0 (Success)

  * Retrieve prog from special device, attach to sock:
   # ./samples/bpf/devicex prog-connect /tmp/prog-test
   dev, fd:3 (Success)
   prog, fd:4 (Success)
   sock, fd:3 (Success)
   sock, prog attached:0 (Success)

  * Destroy special device (prog is still locally available):
   # ./samples/bpf/devicex prog-destroy /tmp/prog-test
   dev, fd:3 (Success)
   prog, fd:4 (Success)
   prog, dev destroyed:0 (Success)

The actual code needed (2nd commit from above link), would be roughly along the
lines of what is shown below ... the code is overall a bit smaller than the fs.

This model seems much cleaner and more flexible to me than the file system. So,
I could polish this stuff further up a bit and do further tests/reviews on Monday
for a real submission. Does that sound like a plan?

Thanks,
Daniel

Code:

  include/linux/bpf.h      |  20 +++
  include/uapi/linux/bpf.h |  45 +-----
  kernel/bpf/Makefile      |   4 +-
  kernel/bpf/core.c        |   2 +-
  kernel/bpf/device.c      | 407 +++++++++++++++++++++++++++++++++++++++++++++++
  kernel/bpf/syscall.c     |  52 ++++--
  6 files changed, 482 insertions(+), 48 deletions(-)
  create mode 100644 kernel/bpf/device.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 0ae6f77..52d57ed 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -8,8 +8,12 @@
  #define _LINUX_BPF_H 1

  #include <uapi/linux/bpf.h>
+
  #include <linux/workqueue.h>
  #include <linux/file.h>
+#include <linux/cdev.h>
+
+#define BPF_F_HAS_DEV	(1 << 0)

  struct bpf_map;

@@ -37,7 +41,11 @@ struct bpf_map {
  	u32 value_size;
  	u32 max_entries;
  	u32 pages;
+	int minor;
+	unsigned long flags;
+	struct mutex m_lock;
  	struct user_struct *user;
+	struct cdev cdev;
  	const struct bpf_map_ops *ops;
  	struct work_struct work;
  };
@@ -127,10 +135,14 @@ struct bpf_prog_type_list {
  struct bpf_prog_aux {
  	atomic_t refcnt;
  	u32 used_map_cnt;
+	int minor;
+	unsigned long flags;
+	struct mutex p_lock;
  	const struct bpf_verifier_ops *ops;
  	struct bpf_map **used_maps;
  	struct bpf_prog *prog;
  	struct user_struct *user;
+	struct cdev cdev;
  	union {
  		struct work_struct work;
  		struct rcu_head	rcu;
@@ -167,11 +179,19 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
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
index 8086471..260058d 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -92,6 +92,7 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)

  	fp->pages = size / PAGE_SIZE;
  	fp->aux = aux;
+	aux->prog = fp;

  	return fp;
  }
@@ -726,7 +727,6 @@ void bpf_prog_free(struct bpf_prog *fp)
  	struct bpf_prog_aux *aux = fp->aux;

  	INIT_WORK(&aux->work, bpf_prog_free_deferred);
-	aux->prog = fp;
  	schedule_work(&aux->work);
  }
  EXPORT_SYMBOL_GPL(bpf_prog_free);
diff --git a/kernel/bpf/device.c b/kernel/bpf/device.c
new file mode 100644
index 0000000..e99fc82
--- /dev/null
+++ b/kernel/bpf/device.c
@@ -0,0 +1,407 @@
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
+#include <linux/cdev.h>
+
+#define BPF_MAX_DEVS	(1UL << MINORBITS)
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
+static char *bpf_devnode(struct device *dev, umode_t *mode)
+{
+	return kasprintf(GFP_KERNEL, "bpf/%s", dev_name(dev));
+}
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
+	map->minor = bpf_map_get_minor(map);
+
+	devt = MKDEV(MAJOR(bpf_map_devt), map->minor);
+	ret = cdev_add(&map->cdev, devt, 1);
+	if (ret)
+		goto unwind;
+
+	dev = device_create(bpf_class, NULL, devt, NULL, "bpf_map%d",
+			    map->minor);
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
+	aux->minor = bpf_prog_get_minor(prog);
+
+	devt = MKDEV(MAJOR(bpf_prog_devt), aux->minor);
+	ret = cdev_add(&aux->cdev, devt, 1);
+	if (ret)
+		goto unwind;
+
+	dev = device_create(bpf_class, NULL, devt, NULL, "bpf_prog%d",
+			    aux->minor);
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
+int __bpf_dev_create(__u32 ufd)
+{
+	enum bpf_type type;
+	void *raw;
+	int ret;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	type = BPF_TYPE_MAP;
+	raw = bpf_map_get(ufd);
+	if (IS_ERR(raw)) {
+		type = BPF_TYPE_PROG;
+		raw = bpf_prog_get(ufd);
+		if (IS_ERR(raw))
+			return PTR_ERR(raw);
+	}
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
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	type = BPF_TYPE_MAP;
+	raw = bpf_map_get(ufd);
+	if (IS_ERR(raw)) {
+		type = BPF_TYPE_PROG;
+		raw = bpf_prog_get(ufd);
+		if (IS_ERR(raw))
+			return PTR_ERR(raw);
+	}
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
+	bpf_class->devnode = bpf_devnode;
+
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
-- 
cgit
