From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 17/29] sysctl: Factor out insert_header and erase_header
Date: Thu, 26 Jan 2012 20:49:58 -0800
Message-ID: <1327639810-12760-17-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 4979925..7e96a26 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -57,6 +57,17 @@ static void init_header(struct ctl_table_header *head,
 	head->parent = NULL;
 }
 
+static void erase_header(struct ctl_table_header *head)
+{
+	list_del_init(&head->ctl_entry);
+}
+
+static void insert_header(struct ctl_table_header *header)
+{
+	header->parent->count++;
+	list_add_tail(&header->ctl_entry, &header->set->list);
+}
+
 /* called under sysctl_lock */
 static int use_table(struct ctl_table_header *p)
 {
@@ -96,7 +107,7 @@ static void start_unregistering(struct ctl_table_header *p)
 	 * do not remove from the list until nobody holds it; walking the
 	 * list in do_sysctl() relies on that.
 	 */
-	list_del_init(&p->ctl_entry);
+	erase_header(p);
 }
 
 static void sysctl_head_get(struct ctl_table_header *head)
@@ -974,8 +985,7 @@ struct ctl_table_header *__register_sysctl_table(
 	}
 	if (sysctl_check_dups(namespaces, header, path, table))
 		goto fail_locked;
-	header->parent->count++;
-	list_add_tail(&header->ctl_entry, &header->set->list);
+	insert_header(header);
 	spin_unlock(&sysctl_lock);
 
 	return header;
-- 
1.7.2.5
