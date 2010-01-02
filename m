From: Samir Bellabes <sam@synack.fr>
Subject: [RFC 8/9] snet: introduce snet_verdict.c and snet_verdict.h
Date: Sat,  2 Jan 2010 14:04:15 +0100
Message-ID: <1262437456-24476-9-git-send-email-sam@synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
Cc: Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1262437456-24476-1-git-send-email-sam@synack.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the snet's subsystem responsive of managing verdicts

snet is using the word 'verdict' for the returning value of LSM hooks.
Different states exist (grant/deny/pending/none).

This patch introduces a hashtable 'verdict_hash' and operations (set/get/search..)
in order to manage verdicts. Syscalls are waiting, inside a classical waitqueue,
for theirs verdicts or for a timeout. Timeout value and the default verdict
policy are configurable at boot.
With the help of the communication's subsystem, verdicts are coming from userspace.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/include/snet_verdict.h |   33 ++++++
 security/snet/snet_verdict.c         |  210 ++++++++++++++++++++++++++++++++++
 2 files changed, 243 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/include/snet_verdict.h
 create mode 100644 security/snet/snet_verdict.c

diff --git a/security/snet/include/snet_verdict.h b/security/snet/include/snet_verdict.h
new file mode 100644
index 0000000..fd9a5e5
--- /dev/null
+++ b/security/snet/include/snet_verdict.h
@@ -0,0 +1,33 @@
+#ifndef _SNET_VERDICT_H
+#define _SNET_VERDICT_H
+
+extern unsigned int verdict_hash_size;
+extern unsigned int snet_verdict_delay;
+
+enum snet_verdict {
+	SNET_VERDICT_GRANT = 0,	/* grant the syscall */
+	SNET_VERDICT_DENY,	/* deny the syscall */
+	SNET_VERDICT_PENDING,	/* waiting for a decision */
+	SNET_VERDICT_NONE,	/* no decision can be set */
+	SNET_VERDICT_INVALID,
+};
+
+#define SNET_NR_VERDICT_TYPES SNET_VERDICT_INVALID
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
+int snet_verdict_exit(void);
+
+#endif /* _SNET_VERDICT_H */
diff --git a/security/snet/snet_verdict.c b/security/snet/snet_verdict.c
new file mode 100644
index 0000000..55dccea
--- /dev/null
+++ b/security/snet/snet_verdict.c
@@ -0,0 +1,210 @@
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/random.h>
+#include <linux/wait.h>
+#include <linux/jhash.h>
+#include <asm/atomic.h>
+
+#include "snet.h"
+#include "snet_verdict.h"
+#include "snet_utils.h"
+
+static struct list_head *verdict_hash;
+static rwlock_t verdict_hash_lock = __RW_LOCK_UNLOCKED();
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
+/* lookup for a verdict - before using this function, lock verdict_hash_lock */
+static struct snet_verdict_entry *__snet_verdict_lookup(const u32 verdict_id)
+{
+	unsigned int h = 0;
+	struct list_head *l = NULL;
+	struct snet_verdict_entry *s = NULL;
+	u32 vid = 0;
+
+	if (!verdict_hash)
+		return NULL;
+
+	vid = verdict_id;
+	/* computing its hash value */
+	h = jhash(&vid, sizeof(u32), 0) % verdict_hash_size;
+	l = &verdict_hash[h];
+
+	list_for_each_entry(s, l, list) {
+		if (s->verdict_id == vid) {
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
+	read_lock_bh(&verdict_hash_lock);
+	data = __snet_verdict_lookup(verdict_id);
+	if (data != NULL)
+		v = data->verdict;
+
+	read_unlock_bh(&verdict_hash_lock);
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
+	write_lock_bh(&verdict_hash_lock);
+	data = __snet_verdict_lookup(verdict_id);
+	if (data != NULL) {
+		/* if verdict is already set because of
+		   timeout, we won't modify it */
+		if (data->verdict == SNET_VERDICT_PENDING) {
+			data->verdict = verdict;
+			ret = 0;
+		}
+	}
+	write_unlock_bh(&verdict_hash_lock);
+	wake_up(&snet_wq);
+out:
+	return ret;
+}
+
+int snet_verdict_remove(const u32 verdict_id)
+{
+	struct snet_verdict_entry *data = NULL;
+
+	write_lock_bh(&verdict_hash_lock);
+	data = __snet_verdict_lookup(verdict_id);
+	if (data == NULL) {
+		write_unlock_bh(&verdict_hash_lock);
+		return -EINVAL;
+	}
+
+	list_del(&data->list);
+	write_unlock_bh(&verdict_hash_lock);
+	kfree(data);
+	return 0;
+}
+
+int snet_verdict_insert(void)
+{
+	struct snet_verdict_entry *data = NULL;
+	unsigned int h = 0;
+	u32 verdict_id = 0;
+
+	data = kzalloc(sizeof(struct snet_verdict_entry), GFP_KERNEL);
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
+	h = jhash(&(data->verdict_id), sizeof(u32), 0) % verdict_hash_size;
+
+	write_lock_bh(&verdict_hash_lock);
+	if (verdict_hash) {
+		list_add_tail(&data->list, &verdict_hash[h]);
+		write_unlock_bh(&verdict_hash_lock);
+	} else {
+		write_unlock_bh(&verdict_hash_lock);
+		kfree(data);
+		verdict_id = 0;
+	}
+
+	return verdict_id;
+}
+
+void __snet_verdict_flush(void)
+{
+	struct snet_verdict_entry *data = NULL;
+	unsigned int i = 0;
+
+	for (i = 0; i < verdict_hash_size; i++) {
+		while (!list_empty(&verdict_hash[i])) {
+			data = list_entry(verdict_hash[i].next,
+					  struct snet_verdict_entry, list);
+			list_del(&data->list);
+			kfree(data);
+		}
+	}
+	return;
+}
+
+void snet_verdict_flush(void)
+{
+	write_lock_bh(&verdict_hash_lock);
+	if (verdict_hash)
+		__snet_verdict_flush();
+	write_unlock_bh(&verdict_hash_lock);
+	return;
+}
+
+/* init function */
+int snet_verdict_init(void)
+{
+	int err = 0, i = 0;
+
+	verdict_hash = kzalloc(sizeof(struct list_head) * verdict_hash_size,
+			  GFP_KERNEL);
+	if (!verdict_hash) {
+		printk(KERN_WARNING
+		       "snet: can't alloc memory for verdict\n");
+		err = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < verdict_hash_size; i++)
+		INIT_LIST_HEAD(&(verdict_hash[i]));
+
+out:
+	return err;
+}
+
+/* exit function */
+int snet_verdict_exit(void)
+{
+	write_lock_bh(&verdict_hash_lock);
+	if (verdict_hash) {
+		__snet_verdict_flush();
+		kfree(verdict_hash);
+		verdict_hash = NULL;
+	}
+	write_unlock_bh(&verdict_hash_lock);
+
+	return 0;
+}
-- 
1.6.3.3

