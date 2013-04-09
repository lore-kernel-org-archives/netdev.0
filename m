From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH 1/2] netprio_cgroup: remove task_struct parameter from sock_update_netprio()
Date: Tue, 9 Apr 2013 14:00:50 +0800
Message-ID: <5163AE92.7010302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The callers always pass current to sock_update_netprio().

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 include/net/netprio_cgroup.h | 4 ++--
 net/core/scm.c               | 2 +-
 net/core/sock.c              | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 1d04b6f..50ab8c2 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -29,7 +29,7 @@ struct cgroup_netprio_state {
 	struct cgroup_subsys_state css;
 };
 
-extern void sock_update_netprioidx(struct sock *sk, struct task_struct *task);
+extern void sock_update_netprioidx(struct sock *sk);
 
 #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
 
@@ -68,7 +68,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	return 0;
 }
 
-#define sock_update_netprioidx(sk, task)
+#define sock_update_netprioidx(sk)
 
 #endif /* CONFIG_NETPRIO_CGROUP */
 
diff --git a/net/core/scm.c b/net/core/scm.c
index cb8d98c..10153e5 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -306,7 +306,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		/* Bump the usage count and install the file. */
 		sock = sock_from_file(fp[i], &err);
 		if (sock) {
-			sock_update_netprioidx(sock->sk, current);
+			sock_update_netprioidx(sock->sk);
 			sock_update_classid(sock->sk);
 		}
 		fd_install(new_fd, get_file(fp[i]));
diff --git a/net/core/sock.c b/net/core/sock.c
index 0e1d2fe..d4f4cea 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1319,12 +1319,12 @@ EXPORT_SYMBOL(sock_update_classid);
 #endif
 
 #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
-void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
+void sock_update_netprioidx(struct sock *sk)
 {
 	if (in_interrupt())
 		return;
 
-	sk->sk_cgrp_prioidx = task_netprioidx(task);
+	sk->sk_cgrp_prioidx = task_netprioidx(current);
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
@@ -1354,7 +1354,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
-		sock_update_netprioidx(sk, current);
+		sock_update_netprioidx(sk);
 	}
 
 	return sk;
-- 
1.8.0.2
