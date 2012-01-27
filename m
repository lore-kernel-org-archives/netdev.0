From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 06/29] sysctl: Implement retire_sysctl_set
Date: Thu, 26 Jan 2012 20:49:47 -0800
Message-ID: <1327639810-12760-6-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a small helper retire_sysctl_set to remove the intimate knowledge about
the how a sysctl_set is implemented from net/sysct_net.c

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |    4 ++++
 include/linux/sysctl.h |    1 +
 net/sysctl_net.c       |    2 +-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index f6aa751..9d8223c 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -1080,6 +1080,10 @@ void setup_sysctl_set(struct ctl_table_set *p,
 	p->is_seen = is_seen;
 }
 
+void retire_sysctl_set(struct ctl_table_set *set)
+{
+	WARN_ON(!list_empty(&set->list));
+}
 
 int __init proc_sys_init(void)
 {
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 08cabbf..475ff0e 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1072,6 +1072,7 @@ void proc_sys_poll_notify(struct ctl_table_poll *poll);
 extern void setup_sysctl_set(struct ctl_table_set *p,
 	struct ctl_table_set *parent,
 	int (*is_seen)(struct ctl_table_set *));
+extern void retire_sysctl_set(struct ctl_table_set *set);
 
 void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index a6bbee2..ffd67a6 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -82,7 +82,7 @@ static int __net_init sysctl_net_init(struct net *net)
 
 static void __net_exit sysctl_net_exit(struct net *net)
 {
-	WARN_ON(!list_empty(&net->sysctls.list));
+	retire_sysctl_set(&net->sysctls);
 }
 
 static struct pernet_operations sysctl_pernet_ops = {
-- 
1.7.2.5
