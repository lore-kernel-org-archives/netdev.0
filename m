From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v1 4/5] cgroup: net_cls: Pass in task to sock_update_classid()
Date: Thu, 25 Oct 2012 16:16:58 +0200
Message-ID: <1351174619-5096-5-git-send-email-wagi@monom.org>
References: <1351174619-5096-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351174619-5096-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

sock_update_classid() assumes that the update operation always are
applied on the current task. sock_update_classid() needs to know on
which tasks to work on in order to be able to migrate task between
cgroups using the struct cgroup_subsys attach() callback.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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
index 9fedbbf..0a023b8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1217,11 +1217,11 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 
 #ifdef CONFIG_CGROUPS
 #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
-void sock_update_classid(struct sock *sk)
+void sock_update_classid(struct sock *sk, struct task_struct *task)
 {
 	u32 classid;
 
-	classid = task_cls_classid(current);
+	classid = task_cls_classid(task);
 	if (classid != sk->sk_classid)
 		sk->sk_classid = classid;
 }
@@ -1264,7 +1264,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_net_set(sk, get_net(net));
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
-		sock_update_classid(sk);
+		sock_update_classid(sk, current);
 		sock_update_netprioidx(sk, current);
 	}
 
diff --git a/net/socket.c b/net/socket.c
index d92c490..f1a481a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -620,7 +620,7 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	si->sock = sock;
 	si->scm = NULL;
@@ -784,7 +784,7 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	si->sock = sock;
 	si->scm = NULL;
@@ -896,7 +896,7 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	if (unlikely(!sock->ops->splice_read))
 		return -EINVAL;
 
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
@@ -3437,7 +3437,7 @@ EXPORT_SYMBOL(kernel_setsockopt);
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
 {
-	sock_update_classid(sock->sk);
+	sock_update_classid(sock->sk, current);
 
 	if (sock->ops->sendpage)
 		return sock->ops->sendpage(sock, page, offset, size, flags);
-- 
1.8.0.rc0
