From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH 1/2] cls_cgroup: remove task_struct parameter from sock_update_classid()
Date: Tue, 9 Apr 2013 14:03:35 +0800
Message-ID: <5163AF37.8010605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The callers always pass current to sock_update_classid().

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 include/net/cls_cgroup.h | 4 ++--
 net/core/scm.c           | 2 +-
 net/core/sock.c          | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 2581638..0fee061 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,7 +24,7 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
-extern void sock_update_classid(struct sock *sk, struct task_struct *task);
+extern void sock_update_classid(struct sock *sk);
 
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -61,7 +61,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 }
 #endif
 #else /* !CGROUP_NET_CLS_CGROUP */
-static inline void sock_update_classid(struct sock *sk, struct task_struct *task)
+static inline void sock_update_classid(struct sock *sk)
 {
 }
 
diff --git a/net/core/scm.c b/net/core/scm.c
index 2dc6cda..cb8d98c 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -307,7 +307,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		sock = sock_from_file(fp[i], &err);
 		if (sock) {
 			sock_update_netprioidx(sock->sk, current);
-			sock_update_classid(sock->sk, current);
+			sock_update_classid(sock->sk);
 		}
 		fd_install(new_fd, get_file(fp[i]));
 	}
diff --git a/net/core/sock.c b/net/core/sock.c
index 2ff5f36..0e1d2fe 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1307,11 +1307,11 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 }
 
 #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
-void sock_update_classid(struct sock *sk, struct task_struct *task)
+void sock_update_classid(struct sock *sk)
 {
 	u32 classid;
 
-	classid = task_cls_classid(task);
+	classid = task_cls_classid(current);
 	if (classid != sk->sk_classid)
 		sk->sk_classid = classid;
 }
@@ -1353,7 +1353,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_net_set(sk, get_net(net));
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
-		sock_update_classid(sk, current);
+		sock_update_classid(sk);
 		sock_update_netprioidx(sk, current);
 	}
 
-- 
1.8.0.2
