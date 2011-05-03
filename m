From: Samir Bellabes <sam@synack.fr>
Subject: [RFC v3 07/10] snet: introduce snet_verdict
Date: Tue,  3 May 2011 16:24:20 +0200
Message-ID: <1304432663-1575-8-git-send-email-sam@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304432663-1575-1-git-send-email-sam@synack.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the snet's subsystem responsive of managing verdicts

snet is using the word 'verdict' for the returning value of LSM hooks.
Different states exist (grant/deny/pending/none).

This patch introduces a hashtable 'verdict_hash' and operations (set/get/search..)
in order to manage verdicts. Syscalls are waiting, inside a classical waitqueue,
for theirs verdicts or for a timeout. Timeout value and the default verdict
policy are configurable at boot or by the snet_netlink subsystem.
With the help of the communication's subsystem, verdicts are coming from userspace

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_verdict.c |  203 ++++++++++++++++++++++++++++++++++++++++++
 security/snet/snet_verdict.h |   23 +++++
 2 files changed, 226 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_verdict.c
 create mode 100644 security/snet/snet_verdict.h

diff --git a/security/snet/snet_verdict.c b/security/snet/snet_verdict.c
new file mode 100644
index 0000000..b0811ac
--- /dev/null
+++ b/security/snet/snet_verdict.c
@@ -0,0 +1,203 @@
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/random.h>
+#include <linux/wait.h>
+#include <asm/atomic.h>
+#include <linux/snet.h>
+#include <linux/slab.h>
+#include "snet_verdict.h"
+
+static struct list_head *snet_vdh;
+static rwlock_t snet_vdh_lock = __RW_LOCK_UNLOCKED();
+
+struct snet_verdict_entry {
+	struct list_head list;
+	u32 verdict_id;
+	enum snet_verdict verdict;
+};
+
+static atomic_t value = ATOMIC_INIT(1);
+
+/* when waiting for a verdict, process is added to this queue */
+static DECLARE_WAIT_QUEUE_HEAD(snet_wq);
+
+static struct kmem_cache *snet_verdict_entry_cachep;
+
+/* lookup for a verdict - before using this function, lock snet_vdh_lock */
+static struct snet_verdict_entry *__snet_verdict_lookup(const u32 verdict_id)
+{
+	unsigned int h = 0;
+	struct list_head *l = NULL;
+	struct snet_verdict_entry *s = NULL;
+
+	h = verdict_id % snet_vdh_size;
+	l = &snet_vdh[h];
+
+	list_for_each_entry(s, l, list) {
+		if (s->verdict_id == verdict_id) {
+			return s;
+		}
+	}
+	return NULL;
+}
+
+const enum snet_verdict snet_verdict_wait(const u32 verdict_id)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	long ret = 0;
+
+	ret = wait_event_timeout(snet_wq,
+				 (verdict = snet_verdict_get(verdict_id))
+				 != SNET_VERDICT_PENDING,
+				 snet_verdict_delay * HZ);
+	if (ret)
+		return snet_verdict_get(verdict_id);
+	else
+		return SNET_VERDICT_NONE;
+}
+
+const enum snet_verdict snet_verdict_get(const u32 verdict_id)
+{
+	enum snet_verdict v = SNET_VERDICT_NONE;
+	struct snet_verdict_entry *data = NULL;
+
+	read_lock_bh(&snet_vdh_lock);
+	data = __snet_verdict_lookup(verdict_id);
+	if (data != NULL)
+		v = data->verdict;
+
+	read_unlock_bh(&snet_vdh_lock);
+	return v;
+}
+
+int snet_verdict_set(const u32 verdict_id, const enum snet_verdict verdict)
+{
+	struct snet_verdict_entry *data = NULL;
+	int ret = -EINVAL;
+
+	if (verdict >= SNET_NR_VERDICT_TYPES)
+		goto out;
+
+	write_lock_bh(&snet_vdh_lock);
+	data = __snet_verdict_lookup(verdict_id);
+	if (data != NULL) {
+		/* if verdict is already set because of
+		   timeout, we won't modify it */
+		if (data->verdict == SNET_VERDICT_PENDING) {
+			data->verdict = verdict;
+			ret = 0;
+		}
+	}
+	write_unlock_bh(&snet_vdh_lock);
+	wake_up(&snet_wq);
+out:
+	return ret;
+}
+
+int snet_verdict_remove(const u32 verdict_id)
+{
+	struct snet_verdict_entry *data = NULL;
+
+	write_lock_bh(&snet_vdh_lock);
+	data = __snet_verdict_lookup(verdict_id);
+	if (data == NULL) {
+		write_unlock_bh(&snet_vdh_lock);
+		return -EINVAL;
+	}
+	pr_debug("(verdict_id=%u)\n", data->verdict_id);
+	list_del(&data->list);
+	write_unlock_bh(&snet_vdh_lock);
+	kmem_cache_free(snet_verdict_entry_cachep, data);
+	return 0;
+}
+
+int snet_verdict_insert(void)
+{
+	struct snet_verdict_entry *data = NULL;
+	unsigned int h = 0;
+	u32 verdict_id = 0;
+
+	data = kmem_cache_zalloc(snet_verdict_entry_cachep, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	do {
+		verdict_id = atomic_inc_return(&value);
+	} while (verdict_id == 0);
+
+	data->verdict_id = verdict_id;
+	data->verdict = SNET_VERDICT_PENDING;
+	INIT_LIST_HEAD(&(data->list));
+	h = data->verdict_id % snet_vdh_size;
+
+	write_lock_bh(&snet_vdh_lock);
+	list_add_tail(&data->list, &snet_vdh[h]);
+	pr_debug("[%u]=(verdict_id=%u)\n", h, data->verdict_id);
+	write_unlock_bh(&snet_vdh_lock);
+
+	return verdict_id;
+}
+
+void snet_verdict_flush(void)
+{
+	unsigned int i = 0;
+
+	write_lock_bh(&snet_vdh_lock);
+	for (i = 0; i < snet_vdh_size; i++) {
+		struct snet_verdict_entry *data, *tmp;
+		list_for_each_entry_safe(data, tmp, &snet_vdh[i], list) {
+			list_del(&data->list);
+			kmem_cache_free(snet_verdict_entry_cachep, data);
+		}
+	}
+	write_unlock_bh(&snet_vdh_lock);
+	return;
+}
+
+/* init function */
+int snet_verdict_init(void)
+{
+	int err = 0, i = 0;
+
+	if (snet_vdh_size == 0) {
+		printk(KERN_ERR "snet: bad snet_vdh_size value\n");
+		err = -EINVAL;
+		goto out;
+	}
+
+	if (snet_verdict_delay == 0) {
+		printk(KERN_ERR "snet: bad snet_verdict_delay value\n");
+		err = -EINVAL;
+		goto out;
+	}
+
+	snet_vdh = kzalloc(sizeof(struct list_head) * snet_vdh_size,
+			  GFP_KERNEL);
+	if (!snet_vdh) {
+		printk(KERN_WARNING
+		       "snet: can't alloc memory for verdict\n");
+		err = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < snet_vdh_size; i++)
+		INIT_LIST_HEAD(&snet_vdh[i]);
+
+	/* snet_verdict_entry_cachep is not destroyed */
+	snet_verdict_entry_cachep = kmem_cache_create("snet_verdict_entry",
+						      sizeof(struct snet_verdict_entry),
+						      0, SLAB_PANIC, NULL);
+out:
+	return err;
+}
+
+/* exit function */
+void snet_verdict_exit(void)
+{
+	if (snet_vdh) {
+		kfree(snet_vdh);
+		snet_vdh = NULL;
+	}
+
+	return;
+}
diff --git a/security/snet/snet_verdict.h b/security/snet/snet_verdict.h
new file mode 100644
index 0000000..07e8638
--- /dev/null
+++ b/security/snet/snet_verdict.h
@@ -0,0 +1,23 @@
+#ifndef _SNET_VERDICT_H
+#define _SNET_VERDICT_H
+
+extern unsigned int snet_vdh_size;
+extern unsigned int snet_verdict_delay;
+
+/* helper functions */
+const enum snet_verdict snet_verdict_wait(const u32 verdict_id);
+
+/* manipulate the verdicts hash table */
+const enum snet_verdict snet_verdict_get(const u32 verdict_id);
+int snet_verdict_set(const u32 verdict_id, const enum snet_verdict verdict);
+int snet_verdict_insert(void);
+int snet_verdict_remove(const u32 verdict_id);
+int snet_verdict_insert(void);
+void snet_verdict_flush(void);
+
+/* init function */
+int snet_verdict_init(void);
+/* exit function */
+void snet_verdict_exit(void);
+
+#endif /* _SNET_VERDICT_H */
-- 
1.7.4.1
