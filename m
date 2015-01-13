From: Kiran Raparthy <kiran.kumar@linaro.org>
Subject: [RFC 2/2] net: activity_stats: Add statistics for network transmission activity
Date: Tue, 13 Jan 2015 16:44:02 +0530
Message-ID: <1421147642-28360-2-git-send-email-kiran.kumar@linaro.org>
References: <1421147642-28360-1-git-send-email-kiran.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mike Chan <mike@android.com>, Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Android Kernel Team <kernel-team@android.com>,
	John Stultz <john.stultz@linaro.org>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	=?UTF-8?q?Arve=20Hj=F8nnev=E5g?= <arve@android.com>,
	Kiran Raparthy <kiran.kumar@linaro.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421147642-28360-1-git-send-email-kiran.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Mike Chan <mike@android.com>

net: activity_stats: Add statistics for network transmission activity

When enabled, tracks the frequency of network transmissions
(inbound and outbound) and buckets them accordingly.
Buckets are determined by time between network activity.

Each bucket represents the number of network transmisions that were
N sec or longer apart. Where N is defined as 1 << bucket index.

This network pattern tracking is particularly useful for wireless
networks (ie: 3G) where batching network activity closely together
is more power efficient than far apart.

New file: /proc/net/stat/activity

output:

Min Bucket(sec) Count
              1 7
              2 0
              4 1
              8 0
             16 0
             32 2
             64 1
            128 0

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Android Kernel Team <kernel-team@android.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Sumit Semwal <sumit.semwal@linaro.org>
Cc: Arve Hj=F8nnev=E5g <arve@android.com>
Signed-off-by: Mike Chan <mike@android.com>
[Kiran: Added context to commit message.
included build fix from Arve,continued to use uid_t
but used covnersion from kuid_t where ever necessary]
Signed-off-by: Kiran Raparthy <kiran.kumar@linaro.org>
---
 drivers/misc/uid_stat.c      |   3 ++
 include/net/activity_stats.h |  25 ++++++++++
 net/Kconfig                  |   8 +++
 net/Makefile                 |   1 +
 net/activity_stats.c         | 116 +++++++++++++++++++++++++++++++++++=
++++++++
 5 files changed, 153 insertions(+)
 create mode 100644 include/net/activity_stats.h
 create mode 100644 net/activity_stats.c

diff --git a/drivers/misc/uid_stat.c b/drivers/misc/uid_stat.c
index aaaa406..63065e2 100644
--- a/drivers/misc/uid_stat.c
+++ b/drivers/misc/uid_stat.c
@@ -24,6 +24,7 @@
 #include <linux/spinlock.h>
 #include <linux/stat.h>
 #include <linux/uid_stat.h>
+#include <net/activity_stats.h>
=20
 static DEFINE_SPINLOCK(uid_lock);
 static LIST_HEAD(uid_list);
@@ -126,6 +127,7 @@ int uid_stat_tcp_snd(kuid_t uid, int size)
 {
 	struct uid_stat *entry;
=20
+	activity_stats_update();
 	entry =3D find_or_create_uid_stat(uid);
 	if (!entry)
 		return -1;
@@ -137,6 +139,7 @@ int uid_stat_tcp_rcv(kuid_t uid, int size)
 {
 	struct uid_stat *entry;
=20
+	activity_stats_update();
 	entry =3D find_or_create_uid_stat(uid);
 	if (!entry)
 		return -1;
diff --git a/include/net/activity_stats.h b/include/net/activity_stats.=
h
new file mode 100644
index 0000000..10e4c15
--- /dev/null
+++ b/include/net/activity_stats.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright (C) 2010 Google, Inc.
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
+ * Author: Mike Chan (mike@android.com)
+ */
+
+#ifndef __activity_stats_h
+#define __activity_stats_h
+
+#ifdef CONFIG_NET_ACTIVITY_STATS
+void activity_stats_update(void);
+#else
+#define activity_stats_update(void) {}
+#endif
+
+#endif /* _NET_ACTIVITY_STATS_H */
diff --git a/net/Kconfig b/net/Kconfig
index ff9ffc1..3159361 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -83,6 +83,14 @@ source "net/netlabel/Kconfig"
=20
 endif # if INET
=20
+config NET_ACTIVITY_STATS
+	bool "Network activity statistics tracking"
+	default y
+	help
+	 Network activity statistics are useful for tracking wireless
+	 modem activity on 2G, 3G, 4G wireless networks. Counts number of
+	 transmissions and groups them in specified time buckets.
+
 config NETWORK_SECMARK
 	bool "Security Marking"
 	help
diff --git a/net/Makefile b/net/Makefile
index 95fc694..d81a969 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -73,6 +73,7 @@ obj-$(CONFIG_OPENVSWITCH)	+=3D openvswitch/
 obj-$(CONFIG_VSOCKETS)	+=3D vmw_vsock/
 obj-$(CONFIG_NET_MPLS_GSO)	+=3D mpls/
 obj-$(CONFIG_HSR)		+=3D hsr/
+obj-$(CONFIG_NET_ACTIVITY_STATS)		+=3D activity_stats.o
 ifneq ($(CONFIG_NET_SWITCHDEV),)
 obj-y				+=3D switchdev/
 endif
diff --git a/net/activity_stats.c b/net/activity_stats.c
new file mode 100644
index 0000000..cf0a09d
--- /dev/null
+++ b/net/activity_stats.c
@@ -0,0 +1,116 @@
+/* net/activity_stats.c
+ *
+ * Copyright (C) 2010 Google, Inc.
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
+ * Author: Mike Chan (mike@android.com)
+ */
+
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/suspend.h>
+#include <net/net_namespace.h>
+
+/* Track transmission rates in buckets (power of 2).
+ * 1,2,4,8...512 seconds.
+ *
+ * Buckets represent the count of network transmissions at least
+ * N seconds apart, where N is 1 << bucket index.
+ */
+#define BUCKET_MAX 10
+
+/* Track network activity frequency */
+static unsigned long activity_stats[BUCKET_MAX];
+static ktime_t last_transmit;
+static ktime_t suspend_time;
+static DEFINE_SPINLOCK(activity_lock);
+
+void activity_stats_update(void)
+{
+	int i;
+	unsigned long flags;
+	ktime_t now;
+	s64 delta;
+
+	spin_lock_irqsave(&activity_lock, flags);
+	now =3D ktime_get();
+	delta =3D ktime_to_ns(ktime_sub(now, last_transmit));
+
+	for (i =3D BUCKET_MAX - 1; i >=3D 0; i--) {
+		/* Check if the time delta between network activity is within
+		 * the minimum bucket range.
+		 */
+		if (delta < (1000000000ULL << i))
+			continue;
+
+		activity_stats[i]++;
+		last_transmit =3D now;
+		break;
+	}
+	spin_unlock_irqrestore(&activity_lock, flags);
+}
+
+static int activity_stats_show(struct seq_file *m, void *v)
+{
+	int i;
+	int ret;
+
+	seq_printf(m, "Min Bucket(sec) Count\n");
+
+	for (i =3D 0; i < BUCKET_MAX; i++) {
+		ret =3D seq_printf(m, "%15d %lu\n", 1 << i, activity_stats[i]);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int activity_stats_notifier(struct notifier_block *nb,
+				   unsigned long event, void *dummy)
+{
+	switch (event) {
+	case PM_SUSPEND_PREPARE:
+		suspend_time =3D ktime_get_real();
+		break;
+
+	case PM_POST_SUSPEND:
+		suspend_time =3D ktime_sub(ktime_get_real(), suspend_time);
+		last_transmit =3D ktime_sub(last_transmit, suspend_time);
+	}
+
+	return 0;
+}
+
+static int activity_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, activity_stats_show, PDE_DATA(inode));
+}
+
+static const struct file_operations activity_stats_fops =3D {
+	.open		=3D activity_stats_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D seq_release,
+};
+
+static struct notifier_block activity_stats_notifier_block =3D {
+	.notifier_call =3D activity_stats_notifier,
+};
+
+static int  __init activity_stats_init(void)
+{
+	proc_create("activity", S_IRUGO,
+		    init_net.proc_net_stat, &activity_stats_fops);
+	return register_pm_notifier(&activity_stats_notifier_block);
+}
+
+subsys_initcall(activity_stats_init);
--=20
1.8.2.1
