From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 02/29] sysctl: Consolidate !CONFIG_SYSCTL handling
Date: Thu, 26 Jan 2012 20:49:43 -0800
Message-ID: <1327639810-12760-2-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- In sysctl.h move functions only available if CONFIG_SYSCL
  is defined inside of #ifdef CONFIG_SYSCTL

- Move the stub function definitions for !CONFIG_SYSCTL
  into sysctl.h and make them static inlines.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sysctl.h |   95 +++++++++++++++++++++++++++++++-----------------
 kernel/sysctl.c        |   26 -------------
 2 files changed, 62 insertions(+), 59 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index bb9127d..cf3ee7f 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -937,30 +937,8 @@ enum
 struct ctl_table;
 struct nsproxy;
 struct ctl_table_root;
-
-struct ctl_table_set {
-	struct list_head list;
-	struct ctl_table_set *parent;
-	int (*is_seen)(struct ctl_table_set *);
-};
-
-extern void setup_sysctl_set(struct ctl_table_set *p,
-	struct ctl_table_set *parent,
-	int (*is_seen)(struct ctl_table_set *));
-
 struct ctl_table_header;
 
-extern void sysctl_head_get(struct ctl_table_header *);
-extern void sysctl_head_put(struct ctl_table_header *);
-extern int sysctl_is_seen(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *);
-extern struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev);
-extern struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
-						struct ctl_table_header *prev);
-extern void sysctl_head_finish(struct ctl_table_header *prev);
-extern int sysctl_perm(struct ctl_table_root *root,
-		struct ctl_table *table, int op);
-
 typedef struct ctl_table ctl_table;
 
 typedef int proc_handler (struct ctl_table *ctl, int write,
@@ -1023,8 +1001,6 @@ static inline void *proc_sys_poll_event(struct ctl_table_poll *poll)
 	return (void *)(unsigned long)atomic_read(&poll->event);
 }
 
-void proc_sys_poll_notify(struct ctl_table_poll *poll);
-
 #define __CTL_TABLE_POLL_INITIALIZER(name) {				\
 	.event = ATOMIC_INIT(0),					\
 	.wait = __WAIT_QUEUE_HEAD_INITIALIZER(name.wait) }
@@ -1047,15 +1023,6 @@ struct ctl_table
 	void *extra2;
 };
 
-struct ctl_table_root {
-	struct list_head root_list;
-	struct ctl_table_set default_set;
-	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
-					   struct nsproxy *namespaces);
-	int (*permissions)(struct ctl_table_root *root,
-			struct nsproxy *namespaces, struct ctl_table *table);
-};
-
 /* struct ctl_table_header is used to maintain dynamic lists of
    struct ctl_table trees. */
 struct ctl_table_header
@@ -1078,11 +1045,45 @@ struct ctl_table_header
 	struct ctl_table_header *parent;
 };
 
+struct ctl_table_set {
+	struct list_head list;
+	struct ctl_table_set *parent;
+	int (*is_seen)(struct ctl_table_set *);
+};
+
+struct ctl_table_root {
+	struct list_head root_list;
+	struct ctl_table_set default_set;
+	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
+					   struct nsproxy *namespaces);
+	int (*permissions)(struct ctl_table_root *root,
+			struct nsproxy *namespaces, struct ctl_table *table);
+};
+
 /* struct ctl_path describes where in the hierarchy a table is added */
 struct ctl_path {
 	const char *procname;
 };
 
+#ifdef CONFIG_SYSCTL
+
+void proc_sys_poll_notify(struct ctl_table_poll *poll);
+
+extern void setup_sysctl_set(struct ctl_table_set *p,
+	struct ctl_table_set *parent,
+	int (*is_seen)(struct ctl_table_set *));
+
+extern void sysctl_head_get(struct ctl_table_header *);
+extern void sysctl_head_put(struct ctl_table_header *);
+extern int sysctl_is_seen(struct ctl_table_header *);
+extern struct ctl_table_header *sysctl_head_grab(struct ctl_table_header *);
+extern struct ctl_table_header *sysctl_head_next(struct ctl_table_header *prev);
+extern struct ctl_table_header *__sysctl_head_next(struct nsproxy *namespaces,
+						struct ctl_table_header *prev);
+extern void sysctl_head_finish(struct ctl_table_header *prev);
+extern int sysctl_perm(struct ctl_table_root *root,
+		struct ctl_table *table, int op);
+
 void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
@@ -1094,6 +1095,34 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 void unregister_sysctl_table(struct ctl_table_header * table);
 int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table);
 
+#else /* CONFIG_SYSCTL */
+static inline struct ctl_table_header *register_sysctl_table(struct ctl_table * table)
+{
+	return NULL;
+}
+
+static inline struct ctl_table_header *register_sysctl_paths(
+			const struct ctl_path *path, struct ctl_table *table)
+{
+	return NULL;
+}
+
+static inline void unregister_sysctl_table(struct ctl_table_header * table)
+{
+}
+
+static inline void setup_sysctl_set(struct ctl_table_set *p,
+	struct ctl_table_set *parent,
+	int (*is_seen)(struct ctl_table_set *))
+{
+}
+
+static inline void sysctl_head_put(struct ctl_table_header *head)
+{
+}
+
+#endif /* CONFIG_SYSCTL */
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SYSCTL_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f487f25..d5bbddd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2017,32 +2017,6 @@ void setup_sysctl_set(struct ctl_table_set *p,
 	p->is_seen = is_seen;
 }
 
-#else /* !CONFIG_SYSCTL */
-struct ctl_table_header *register_sysctl_table(struct ctl_table * table)
-{
-	return NULL;
-}
-
-struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
-						    struct ctl_table *table)
-{
-	return NULL;
-}
-
-void unregister_sysctl_table(struct ctl_table_header * table)
-{
-}
-
-void setup_sysctl_set(struct ctl_table_set *p,
-	struct ctl_table_set *parent,
-	int (*is_seen)(struct ctl_table_set *))
-{
-}
-
-void sysctl_head_put(struct ctl_table_header *head)
-{
-}
-
 #endif /* CONFIG_SYSCTL */
 
 /*
-- 
1.7.2.5
