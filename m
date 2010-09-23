From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/8] ns proc: Add support for the uts namespace
Date: Thu, 23 Sep 2010 01:48:22 -0700
Message-ID: <m1y6asq209.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	<linux-fsdevel@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57321 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347Ab0IWIs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 04:48:27 -0400
In-Reply-To: <m1ocborgq7.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 23 Sep 2010 01:45:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/namespaces.c    |    3 +++
 include/linux/proc_fs.h |    1 +
 kernel/utsname.c        |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 31e32f3..902443e 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -19,6 +19,9 @@ static const struct proc_ns_operations *ns_entries[] = {
 #ifdef CONFIG_NET_NS
 	&netns_operations,
 #endif
+#ifdef CONFIG_UTS_NS
+	&utsns_operations,
+#endif
 };
 
 static const struct file_operations ns_file_operations = {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 9cd3fae..28b4ffd 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -263,6 +263,7 @@ struct proc_ns_operations {
 };
 #define PROC_NSNAME(NAME) { .name = (NAME), .len = (sizeof(NAME) - 1), }
 extern const struct proc_ns_operations netns_operations;
+extern const struct proc_ns_operations utsns_operations;
 extern struct file *proc_ns_fget(int fd);
 
 union proc_op {
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 8a82b4b..ff06086 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -14,6 +14,7 @@
 #include <linux/utsname.h>
 #include <linux/err.h>
 #include <linux/slab.h>
+#include <linux/proc_fs.h>
 
 static struct uts_namespace *create_uts_ns(void)
 {
@@ -73,3 +74,34 @@ void free_uts_ns(struct kref *kref)
 	ns = container_of(kref, struct uts_namespace, kref);
 	kfree(ns);
 }
+
+static void *utsns_get(struct task_struct *task)
+{
+	struct uts_namespace *ns;
+	rcu_read_lock();
+	ns = task->nsproxy->uts_ns;
+	get_uts_ns(ns);
+	rcu_read_unlock();
+	return ns;
+}
+
+static void utsns_put(void *ns)
+{
+	put_uts_ns(ns);
+}
+
+static int utsns_install(struct nsproxy *nsproxy, void *ns)
+{
+	get_uts_ns(ns);
+	put_uts_ns(nsproxy->uts_ns);
+	nsproxy->uts_ns = ns;
+	return 0;
+}
+
+const struct proc_ns_operations utsns_operations = {
+	.name		= PROC_NSNAME("uts"),
+	.get		= utsns_get,
+	.put		= utsns_put,
+	.install	= utsns_install,
+};
+
-- 
1.6.5.2.143.g8cc62

