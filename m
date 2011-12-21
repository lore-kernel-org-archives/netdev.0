From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/4] net_prio/classid: add cgroup process ownership filter
Date: Wed, 21 Dec 2011 09:39:47 -0500
Message-ID: <1324478390-22036-2-git-send-email-nhorman@tuxdriver.com>
References: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34856 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938Ab1LUOkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:40:24 -0500
In-Reply-To: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent multiple processes that share a socket from fighting over the cgroup
instance said socket belongs to, add a sk_cgrp_owner flag so that calls to
sk_update_[classid/prioidx] only do something in the event that its the owning
process updating them.  This way only one pid is responsible for updating the
sockets cgroup information.  When that process releases the socket, set the
owner pid to zero so as to prevent a future task that reuses the same pid from
inheriting the socket erroneously

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Thomas Graf <tgraf@infradead.org>
CC: "David S. Miller" <davem@davemloft.net>
---
 include/net/sock.h |    4 ++++
 net/core/sock.c    |   15 ++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 18ecc99..cdb03c2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -327,6 +327,7 @@ struct sock {
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
 #ifdef CONFIG_CGROUPS
+	pid_t			sk_cgrp_owner;
 	__u32			sk_cgrp_prioidx;
 #endif
 	struct pid		*sk_peer_pid;
@@ -1537,6 +1538,9 @@ static inline void sock_orphan(struct sock *sk)
 	sock_set_flag(sk, SOCK_DEAD);
 	sk_set_socket(sk, NULL);
 	sk->sk_wq  = NULL;
+#ifdef CONFIG_CGROUPS
+	sk->sk_cgrp_owner = 0;
+#endif
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 5a6a906..b922fb5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1162,24 +1162,31 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 #ifdef CONFIG_CGROUPS
 void sock_update_classid(struct sock *sk)
 {
+	pid_t tpid;
 	u32 classid;
 
 	rcu_read_lock();  /* doing current task, which cannot vanish. */
 	classid = task_cls_classid(current);
+	tpid = task_pid_nr(current);
 	rcu_read_unlock();
-	if (classid && classid != sk->sk_classid)
+
+	if ((tpid == sk->sk_cgrp_owner) &&
+	    (classid && classid != sk->sk_classid))
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
 
 void sock_update_netprioidx(struct sock *sk)
 {
+	pid_t tpid;
 	struct cgroup_netprio_state *state;
 	if (in_interrupt())
 		return;
 	rcu_read_lock();
+	tpid = task_pid_nr(current);
 	state = task_netprio_state(current);
-	sk->sk_cgrp_prioidx = state ? state->prioidx : 0;
+	if (tpid == sk->sk_cgrp_owner)
+		sk->sk_cgrp_prioidx = state ? state->prioidx : 0;
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
@@ -1208,7 +1215,9 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_lock_init(sk);
 		sock_net_set(sk, get_net(net));
 		atomic_set(&sk->sk_wmem_alloc, 1);
-
+#ifdef CONFIG_CGROUPS
+		sk->sk_cgrp_owner = task_pid_nr(current);
+#endif
 		sock_update_classid(sk);
 		sock_update_netprioidx(sk);
 	}
-- 
1.7.6.4
