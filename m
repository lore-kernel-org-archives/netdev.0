From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 15/29] sysctl: Initial support for auto-unregistering sysctl tables.
Date: Thu, 26 Jan 2012 20:51:51 -0800
Message-ID: <1327639925-12920-15-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add nreg to ctl_table_header.  When nreg drops to 0 the ctl_table_header
will be unregistered.

Factor out drop_sysctl_table from unregister_sysctl_table, and add
the logic for decrementing nreg.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |   28 +++++++++++++++++++---------
 include/linux/sysctl.h |    1 +
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 1544485..13faa48 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -29,8 +29,9 @@ static struct ctl_table root_table[1];
 static struct ctl_table_root sysctl_table_root;
 static struct ctl_table_header root_table_header = {
 	{{.count = 1,
-	.ctl_table = root_table,
-	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
+	  .nreg = 1,
+	  .ctl_table = root_table,
+	  .ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
 	.root = &sysctl_table_root,
 	.set = &sysctl_table_root.default_set,
 };
@@ -938,6 +939,7 @@ struct ctl_table_header *__register_sysctl_table(
 	header->unregistering = NULL;
 	header->root = root;
 	header->count = 1;
+	header->nreg = 1;
 	if (sysctl_check_table(path, table))
 		goto fail;
 
@@ -1192,6 +1194,20 @@ struct ctl_table_header *register_sysctl_table(struct ctl_table *table)
 }
 EXPORT_SYMBOL(register_sysctl_table);
 
+static void drop_sysctl_table(struct ctl_table_header *header)
+{
+	if (--header->nreg)
+		return;
+
+	start_unregistering(header);
+	if (!--header->parent->count) {
+		WARN_ON(1);
+		kfree_rcu(header->parent, rcu);
+	}
+	if (!--header->count)
+		kfree_rcu(header, rcu);
+}
+
 /**
  * unregister_sysctl_table - unregister a sysctl table hierarchy
  * @header: the header returned from register_sysctl_table
@@ -1224,13 +1240,7 @@ void unregister_sysctl_table(struct ctl_table_header * header)
 	}
 
 	spin_lock(&sysctl_lock);
-	start_unregistering(header);
-	if (!--header->parent->count) {
-		WARN_ON(1);
-		kfree_rcu(header->parent, rcu);
-	}
-	if (!--header->count)
-		kfree_rcu(header, rcu);
+	drop_sysctl_table(header);
 	spin_unlock(&sysctl_lock);
 }
 EXPORT_SYMBOL(unregister_sysctl_table);
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 094bc5c..e40b8f6 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1032,6 +1032,7 @@ struct ctl_table_header
 			struct list_head ctl_entry;
 			int used;
 			int count;
+			int nreg;
 		};
 		struct rcu_head rcu;
 	};
-- 
1.7.2.5

