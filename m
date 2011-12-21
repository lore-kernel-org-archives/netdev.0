From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 4/4] net: remove no-longer needed calls to sock_update_[classid|netprioix]
Date: Wed, 21 Dec 2011 09:39:50 -0500
Message-ID: <1324478390-22036-5-git-send-email-nhorman@tuxdriver.com>
References: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34883 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab1LUOkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:40:42 -0500
In-Reply-To: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we can use cgroups to re-write individual sockets classid and priroity,
we no longer have to update them on each send/recieve

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Thomas Graf <tgraf@infradead.org>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/tun.c            |    2 --
 include/net/netprio_cgroup.h |    6 ------
 include/net/sock.h           |    8 --------
 net/core/sock.c              |    9 +++++----
 net/socket.c                 |   10 ----------
 5 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 93c5d72..cf70336 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -582,8 +582,6 @@ static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 	struct sk_buff *skb;
 	int err;
 
-	sock_update_classid(sk);
-
 	/* Under a page?  Don't bother with paged skb. */
 	if (prepad + len < PAGE_SIZE || !linear)
 		linear = len;
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index e503b87..9c794ab 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -36,8 +36,6 @@ struct cgroup_netprio_state {
 extern int net_prio_subsys_id;
 #endif
 
-extern void sock_update_netprioidx(struct sock *sk);
-
 static inline struct cgroup_netprio_state
 		*task_netprio_state(struct task_struct *p)
 {
@@ -48,10 +46,6 @@ static inline struct cgroup_netprio_state
 	return NULL;
 #endif
 }
-
-#else
-
-#define sock_update_netprioidx(sk)
 #endif
 
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index cdb03c2..df30db0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1367,14 +1367,6 @@ extern void *sock_kmalloc(struct sock *sk, int size,
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
 
-#ifdef CONFIG_CGROUPS
-extern void sock_update_classid(struct sock *sk);
-#else
-static inline void sock_update_classid(struct sock *sk)
-{
-}
-#endif
-
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
diff --git a/net/core/sock.c b/net/core/sock.c
index b922fb5..cfc2d10 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1160,7 +1160,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 }
 
 #ifdef CONFIG_CGROUPS
-void sock_update_classid(struct sock *sk)
+static void sock_update_classid(struct sock *sk)
 {
 	pid_t tpid;
 	u32 classid;
@@ -1174,9 +1174,8 @@ void sock_update_classid(struct sock *sk)
 	    (classid && classid != sk->sk_classid))
 		sk->sk_classid = classid;
 }
-EXPORT_SYMBOL(sock_update_classid);
 
-void sock_update_netprioidx(struct sock *sk)
+static void sock_update_netprioidx(struct sock *sk)
 {
 	pid_t tpid;
 	struct cgroup_netprio_state *state;
@@ -1189,7 +1188,9 @@ void sock_update_netprioidx(struct sock *sk)
 		sk->sk_cgrp_prioidx = state ? state->prioidx : 0;
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL_GPL(sock_update_netprioidx);
+#else
+#define sock_update_classid(sk)
+#define sock_update_netprioidx(sk)
 #endif
 
 /**
diff --git a/net/socket.c b/net/socket.c
index eab8db1..3c6693a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -550,10 +550,6 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
-
-	sock_update_netprioidx(sock->sk);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -716,8 +712,6 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	sock_update_classid(sock->sk);
-
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
@@ -828,8 +822,6 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	if (unlikely(!sock->ops->splice_read))
 		return -EINVAL;
 
-	sock_update_classid(sock->sk);
-
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
@@ -3376,8 +3368,6 @@ EXPORT_SYMBOL(kernel_setsockopt);
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
 {
-	sock_update_classid(sock->sk);
-
 	if (sock->ops->sendpage)
 		return sock->ops->sendpage(sock, page, offset, size, flags);
 
-- 
1.7.6.4
