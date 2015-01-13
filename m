From: Kiran Raparthy <kiran.kumar@linaro.org>
Subject: [RFC 1/2] misc: uidstat: Add uid stat driver to collect network statistics.
Date: Tue, 13 Jan 2015 16:44:01 +0530
Message-ID: <1421147642-28360-1-git-send-email-kiran.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mike Chan <mike@android.com>, Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Android Kernel Team <kernel-team@android.com>,
	John Stultz <john.stultz@linaro.org>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	JP Abgrall <jpa@google.com>,
	=?UTF-8?q?Arve=20Hj=F8nnev=E5g?= <arve@android.com>,
	Kiran Raparthy <kiran.kumar@linaro.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Mike Chan <mike@android.com>

misc: uidstat: Add uid stat driver to collect network statistics.

To analyze application's network statistics, we need a mechanism to exp=
ort
the UID based statistics to userspace so that userspace tools can use t=
he
exported numbers and generate the report against the UID.

This patch allows the user to explore the UID based network statistics
exported to /proc/uid_stat.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
cc: Mike Chan <mike@android.com>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Android Kernel Team <kernel-team@android.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Sumit Semwal <sumit.semwal@linaro.org>
Cc: JP Abgrall <jpa@google.com>
Cc: Arve Hj=F8nnev=E5g <arve@android.com>
Signed-off-by: Mike Chan <mike@android.com>
[Kiran: Added context to commit message.
included build fixes from JP Abgrall and Arve.
Used single_release instead of seq_release.
internally continued to use uid_t but used covnersion
from kuid_t where ever necessary]
Signed-off-by: Kiran Raparthy <kiran.kumar@linaro.org>
---
 drivers/misc/Kconfig     |   7 +++
 drivers/misc/Makefile    |   1 +
 drivers/misc/uid_stat.c  | 157 +++++++++++++++++++++++++++++++++++++++=
++++++++
 include/linux/uid_stat.h |  33 ++++++++++
 net/ipv4/tcp.c           |  10 +++
 5 files changed, 208 insertions(+)
 create mode 100644 drivers/misc/uid_stat.c
 create mode 100644 include/linux/uid_stat.h

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 006242c..1c79b94 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -402,6 +402,13 @@ config TI_DAC7512
 	  This driver can also be built as a module. If so, the module
 	  will be called ti_dac7512.
=20
+config UID_STAT
+	bool "UID based statistics tracking"
+	default n
+	help
+	  This option allows to enable UID based network statistics tracking.
+	  statistics are exported to /proc/uid_stat.
+
 config VMWARE_BALLOON
 	tristate "VMware Balloon Driver"
 	depends on X86 && HYPERVISOR_GUEST
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 7d5c4cd..3754347 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_ISL29020)		+=3D isl29020.o
 obj-$(CONFIG_SENSORS_TSL2550)	+=3D tsl2550.o
 obj-$(CONFIG_DS1682)		+=3D ds1682.o
 obj-$(CONFIG_TI_DAC7512)	+=3D ti_dac7512.o
+obj-$(CONFIG_UID_STAT)		+=3D uid_stat.o
 obj-$(CONFIG_C2PORT)		+=3D c2port/
 obj-$(CONFIG_HMC6352)		+=3D hmc6352.o
 obj-y				+=3D eeprom/
diff --git a/drivers/misc/uid_stat.c b/drivers/misc/uid_stat.c
new file mode 100644
index 0000000..aaaa406
--- /dev/null
+++ b/drivers/misc/uid_stat.c
@@ -0,0 +1,157 @@
+/* drivers/misc/uid_stat.c
+ *
+ * Copyright (C) 2008 - 2009 Google, Inc.
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, an=
d
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#include <linux/atomic.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stat.h>
+#include <linux/uid_stat.h>
+
+static DEFINE_SPINLOCK(uid_lock);
+static LIST_HEAD(uid_list);
+static struct proc_dir_entry *parent;
+
+struct uid_stat {
+	struct list_head link;
+	uid_t uid;
+	atomic_t tcp_rcv;
+	atomic_t tcp_snd;
+};
+
+static struct uid_stat *find_uid_stat(uid_t uid)
+{
+	struct uid_stat *entry;
+
+	list_for_each_entry(entry, &uid_list, link) {
+		if (entry->uid =3D=3D uid)
+			return entry;
+	}
+	return NULL;
+}
+
+static int uid_stat_atomic_int_show(struct seq_file *m, void *v)
+{
+	unsigned int bytes;
+	atomic_t *counter =3D m->private;
+
+	bytes =3D (unsigned int) (atomic_read(counter) + INT_MIN);
+	return seq_printf(m, "%u\n", bytes);
+}
+
+static int uid_stat_read_atomic_int_open(struct inode *inode, struct f=
ile *file)
+{
+	return single_open(file, uid_stat_atomic_int_show, PDE_DATA(inode));
+}
+
+static const struct file_operations uid_stat_read_atomic_int_fops =3D =
{
+	.open		=3D uid_stat_read_atomic_int_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D single_release,
+};
+
+/* Create a new entry for tracking the specified uid. */
+static struct uid_stat *create_stat(uid_t uid)
+{
+	struct uid_stat *new_uid;
+	/* Create the uid stat struct and append it to the list. */
+	new_uid =3D kmalloc(sizeof(struct uid_stat), GFP_ATOMIC);
+	if (!new_uid)
+		return NULL;
+
+	new_uid->uid =3D uid;
+	/* Counters start at INT_MIN, so we can track 4GB of network traffic.=
 */
+	atomic_set(&new_uid->tcp_rcv, INT_MIN);
+	atomic_set(&new_uid->tcp_snd, INT_MIN);
+
+	list_add_tail(&new_uid->link, &uid_list);
+	return new_uid;
+}
+
+static void create_stat_proc(struct uid_stat *new_uid)
+{
+	char uid_s[32];
+	struct proc_dir_entry *entry;
+
+	sprintf(uid_s, "%d", new_uid->uid);
+	entry =3D proc_mkdir(uid_s, parent);
+
+	/* Keep reference to uid_stat so we know what uid to read stats from.=
 */
+	proc_create_data("tcp_snd", S_IRUGO, entry,
+			 &uid_stat_read_atomic_int_fops, &new_uid->tcp_snd);
+
+	proc_create_data("tcp_rcv", S_IRUGO, entry,
+			 &uid_stat_read_atomic_int_fops, &new_uid->tcp_rcv);
+}
+
+static struct uid_stat *find_or_create_uid_stat(kuid_t uid)
+{
+	struct uid_stat *entry;
+	unsigned long flags;
+	uid_t proc_uid;
+
+	proc_uid =3D from_kuid(&init_user_ns, uid);
+	spin_lock_irqsave(&uid_lock, flags);
+	entry =3D find_uid_stat(proc_uid);
+	if (entry) {
+		spin_unlock_irqrestore(&uid_lock, flags);
+		return entry;
+	}
+	entry =3D create_stat(proc_uid);
+	spin_unlock_irqrestore(&uid_lock, flags);
+	if (entry)
+		create_stat_proc(entry);
+	return entry;
+}
+
+int uid_stat_tcp_snd(kuid_t uid, int size)
+{
+	struct uid_stat *entry;
+
+	entry =3D find_or_create_uid_stat(uid);
+	if (!entry)
+		return -1;
+	atomic_add(size, &entry->tcp_snd);
+	return 0;
+}
+
+int uid_stat_tcp_rcv(kuid_t uid, int size)
+{
+	struct uid_stat *entry;
+
+	entry =3D find_or_create_uid_stat(uid);
+	if (!entry)
+		return -1;
+	atomic_add(size, &entry->tcp_rcv);
+	return 0;
+}
+
+static int __init uid_stat_init(void)
+{
+	parent =3D proc_mkdir("uid_stat", NULL);
+	if (!parent) {
+		pr_err("uid_stat: failed to create proc entry\n");
+		return -1;
+	}
+	return 0;
+}
+
+device_initcall(uid_stat_init);
diff --git a/include/linux/uid_stat.h b/include/linux/uid_stat.h
new file mode 100644
index 0000000..68823d3
--- /dev/null
+++ b/include/linux/uid_stat.h
@@ -0,0 +1,33 @@
+/* include/linux/uid_stat.h
+ *
+ * Copyright (C) 2008-2009 Google, Inc.
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, an=
d
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#ifndef __uid_stat_h
+#define __uid_stat_h
+
+/* Contains definitions for resource tracking per uid. */
+
+#ifdef CONFIG_UID_STAT
+int uid_stat_tcp_snd(kuid_t uid, int size);
+int uid_stat_tcp_rcv(kuid_t uid, int size);
+#else
+static inline int uid_stat_tcp_snd(kuid_t uid, int size)
+{
+}
+static inline int uid_stat_tcp_rcv(kuid_t uid, int size)
+{
+}
+#endif
+
+#endif /* _LINUX_UID_STAT_H */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3075723..00eb156 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -268,6 +268,7 @@
 #include <linux/crypto.h>
 #include <linux/time.h>
 #include <linux/slab.h>
+#include <linux/uid_stat.h>
=20
 #include <net/icmp.h>
 #include <net/inet_common.h>
@@ -1280,6 +1281,9 @@ out:
 		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 out_nopush:
 	release_sock(sk);
+
+	if (copied + copied_syn)
+		uid_stat_tcp_snd(current_uid(), copied + copied_syn);
 	return copied + copied_syn;
=20
 do_fault:
@@ -1551,6 +1555,7 @@ int tcp_read_sock(struct sock *sk, read_descripto=
r_t *desc,
 	if (copied > 0) {
 		tcp_recv_skb(sk, seq, &offset);
 		tcp_cleanup_rbuf(sk, copied);
+		uid_stat_tcp_rcv(current_uid(), copied);
 	}
 	return copied;
 }
@@ -1879,6 +1884,9 @@ skip_copy:
 	tcp_cleanup_rbuf(sk, copied);
=20
 	release_sock(sk);
+
+	if (copied > 0)
+		uid_stat_tcp_rcv(current_uid(), copied);
 	return copied;
=20
 out:
@@ -1887,6 +1895,8 @@ out:
=20
 recv_urg:
 	err =3D tcp_recv_urg(sk, msg, len, flags);
+	if (err > 0)
+		uid_stat_tcp_rcv(current_uid(), err);
 	goto out;
=20
 recv_sndq:
--=20
1.8.2.1
