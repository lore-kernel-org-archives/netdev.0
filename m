From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v0 3/4] cgroup: net_cls: Pass in task to sock_update_classid()
Date: Wed, 17 Oct 2012 15:04:37 +0200
Message-ID: <1350479078-29361-4-git-send-email-wagi@monom.org>
References: <1350479078-29361-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Glauber Costa <glommer@parallels.com>,
	Joe Perches <joe@perches.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislav Kinsbursky <skinsbursky@parallels.com>,
	Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:43186 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756833Ab2JQNEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 09:04:44 -0400
In-Reply-To: <1350479078-29361-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

sock_update_classid() assumes that the update operation always are
applied on the current task. sock_update_classid() needs to know on
which tasks to work on in order to be able to migrate task between
cgroups using the struct cgroup_subsys attach() callback.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Joe Perches <joe@perches.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: <netdev@vger.kernel.org>
Cc: <cgroups@vger.kernel.org>
---
 drivers/net/tun.c        | 2 +-
 include/net/cls_cgroup.h | 2 +-
 net/core/sock.c          | 6 +++---
 net/socket.c             | 8 ++++----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0873cdc..e4858b2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -587,7 +587,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 	struct sk_buff *skb;
 	int err;
 
-	sock_update_classid(sk);
+	sock_update_classid(sk, current);
 
 	/* Under a page?  Don't bother with paged skb. */
 	if (prepad + len < PAGE_SIZE || !linear)
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 0fee061..571de6e 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,7 +24,7 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
-extern void sock_update_classid(struct sock *sk);
+extern void sock_update_classid(struct sock *sk, struct task_struct *task);
 
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
diff --git a/net/core/sock.c b/net/core/sock.c
index 8a146cf..68c2f3b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1214,12 +1214,12 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 
 #ifdef CONFIG_CGROUPS
 #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
-void sock_update_classid(struct sock *sk)
+void sock_update_classid(struct sock *sk, struct task_struct *task)
 {
 	u32 classid;
 
 	rcu_read_lock();  /* doing current task, which cannot vanish. */
-	classid = task_cls_classid(current);
+	classid = task_cls_classid(task);
 	rcu_read_unlock();
 	if (classid != sk->sk_classid)
 		sk->sk_classid = classid;
@@ -1263,7 +1263,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_net_set(sk, get_net(net));
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
-		sock_update_classid(sk);
+		sock_update_classid(sk, current);
 		sock_update_netprioidx(sk, current);
 	}
 
diff --git a/net/socket.c b/net/socket.c
index 80dc7e8..b38aff9 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -625,7 +625,7 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	si->sock = sock;
 	si->scm = NULL;
@@ -789,7 +789,7 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	si->sock = sock;
 	si->scm = NULL;
@@ -901,7 +901,7 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	if (unlikely(!sock->ops->splice_read))
 		return -EINVAL;
 
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
@@ -3421,7 +3421,7 @@ EXPORT_SYMBOL(kernel_setsockopt);
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
 {
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	if (sock->ops->sendpage)
 		return sock->ops->sendpage(sock, page, offset, size, flags);
-- 
1.7.11.4
