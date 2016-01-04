From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH v4 net-next 1/4] soreuseport: define reuseport groups
Date: Mon,  4 Jan 2016 17:41:45 -0500
Message-ID: <1451947308-7867-2-git-send-email-kraigatgoog@gmail.com>
References: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34991 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbcADWlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:41:53 -0500
Received: by mail-qg0-f45.google.com with SMTP id o11so265824531qge.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:41:52 -0800 (PST)
In-Reply-To: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

struct sock_reuseport is an optional shared structure referenced by each
socket belonging to a reuseport group.  When a socket is bound to an
address/port not yet in use and the reuseport flag has been set, the
structure will be allocated and attached to the newly bound socket.
When subsequent calls to bind are made for the same address/port, the
shared structure will be updated to include the new socket and the
newly bound socket will reference the group structure.

Usually, when an incoming packet was destined for a reuseport group,
all sockets in the same group needed to be considered before a
dispatching decision was made.  With this structure, an appropriate
socket can be found after looking up just one socket in the group.

This shared structure will also allow for more complicated decisions to
be made when selecting a socket (eg a BPF filter).

This work is based off a similar implementation written by
Ying Cai <ycai@google.com> for implementing policy-based reuseport
selection.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/sock.h           |   2 +
 include/net/sock_reuseport.h |  20 +++++
 net/core/Makefile            |   2 +-
 net/core/sock_reuseport.c    | 173 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 196 insertions(+), 1 deletion(-)
 create mode 100644 include/net/sock_reuseport.h
 create mode 100644 net/core/sock_reuseport.c

diff --git a/include/net/sock.h b/include/net/sock.h
index 3794cdd..e830c10 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -318,6 +318,7 @@ struct cg_proto;
   *	@sk_error_report: callback to indicate errors (e.g. %MSG_ERRQUEUE)
   *	@sk_backlog_rcv: callback to process the backlog
   *	@sk_destruct: called at sock freeing time, i.e. when all refcnt == 0
+  *	@sk_reuseport_cb: reuseport group container
  */
 struct sock {
 	/*
@@ -453,6 +454,7 @@ struct sock {
 	int			(*sk_backlog_rcv)(struct sock *sk,
 						  struct sk_buff *skb);
 	void                    (*sk_destruct)(struct sock *sk);
+	struct sock_reuseport __rcu	*sk_reuseport_cb;
 };
 
 #define __sk_user_data(sk) ((*((void __rcu **)&(sk)->sk_user_data)))
diff --git a/include/net/sock_reuseport.h b/include/net/sock_reuseport.h
new file mode 100644
index 0000000..67d1eb8
--- /dev/null
+++ b/include/net/sock_reuseport.h
@@ -0,0 +1,20 @@
+#ifndef _SOCK_REUSEPORT_H
+#define _SOCK_REUSEPORT_H
+
+#include <linux/types.h>
+#include <net/sock.h>
+
+struct sock_reuseport {
+	struct rcu_head		rcu;
+
+	u16			max_socks;	/* length of socks */
+	u16			num_socks;	/* elements in socks */
+	struct sock		*socks[0];	/* array of sock pointers */
+};
+
+extern int reuseport_alloc(struct sock *sk);
+extern int reuseport_add_sock(struct sock *sk, const struct sock *sk2);
+extern void reuseport_detach_sock(struct sock *sk);
+extern struct sock *reuseport_select_sock(struct sock *sk, u32 hash);
+
+#endif  /* _SOCK_REUSEPORT_H */
diff --git a/net/core/Makefile b/net/core/Makefile
index 086b01f..0b835de 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			sock_diag.o dev_ioctl.o tso.o
+			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
new file mode 100644
index 0000000..963c8d5
--- /dev/null
+++ b/net/core/sock_reuseport.c
@@ -0,0 +1,173 @@
+/*
+ * To speed up listener socket lookup, create an array to store all sockets
+ * listening on the same port.  This allows a decision to be made after finding
+ * the first socket.
+ */
+
+#include <net/sock_reuseport.h>
+#include <linux/rcupdate.h>
+
+#define INIT_SOCKS 128
+
+static DEFINE_SPINLOCK(reuseport_lock);
+
+static struct sock_reuseport *__reuseport_alloc(u16 max_socks)
+{
+	size_t size = sizeof(struct sock_reuseport) +
+		      sizeof(struct sock *) * max_socks;
+	struct sock_reuseport *reuse = kzalloc(size, GFP_ATOMIC);
+
+	if (!reuse)
+		return NULL;
+
+	reuse->max_socks = max_socks;
+
+	return reuse;
+}
+
+int reuseport_alloc(struct sock *sk)
+{
+	struct sock_reuseport *reuse;
+
+	/* bh lock used since this function call may precede hlist lock in
+	 * soft irq of receive path or setsockopt from process context
+	 */
+	spin_lock_bh(&reuseport_lock);
+	WARN_ONCE(rcu_dereference_protected(sk->sk_reuseport_cb,
+					    lockdep_is_held(&reuseport_lock)),
+		  "multiple allocations for the same socket");
+	reuse = __reuseport_alloc(INIT_SOCKS);
+	if (!reuse) {
+		spin_unlock_bh(&reuseport_lock);
+		return -ENOMEM;
+	}
+
+	reuse->socks[0] = sk;
+	reuse->num_socks = 1;
+	rcu_assign_pointer(sk->sk_reuseport_cb, reuse);
+
+	spin_unlock_bh(&reuseport_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(reuseport_alloc);
+
+static struct sock_reuseport *reuseport_grow(struct sock_reuseport *reuse)
+{
+	struct sock_reuseport *more_reuse;
+	u32 more_socks_size, i;
+
+	more_socks_size = reuse->max_socks * 2U;
+	if (more_socks_size > U16_MAX)
+		return NULL;
+
+	more_reuse = __reuseport_alloc(more_socks_size);
+	if (!more_reuse)
+		return NULL;
+
+	more_reuse->max_socks = more_socks_size;
+	more_reuse->num_socks = reuse->num_socks;
+
+	memcpy(more_reuse->socks, reuse->socks,
+	       reuse->num_socks * sizeof(struct sock *));
+
+	for (i = 0; i < reuse->num_socks; ++i)
+		rcu_assign_pointer(reuse->socks[i]->sk_reuseport_cb,
+				   more_reuse);
+
+	kfree_rcu(reuse, rcu);
+	return more_reuse;
+}
+
+/**
+ *  reuseport_add_sock - Add a socket to the reuseport group of another.
+ *  @sk:  New socket to add to the group.
+ *  @sk2: Socket belonging to the existing reuseport group.
+ *  May return ENOMEM and not add socket to group under memory pressure.
+ */
+int reuseport_add_sock(struct sock *sk, const struct sock *sk2)
+{
+	struct sock_reuseport *reuse;
+
+	spin_lock_bh(&reuseport_lock);
+	reuse = rcu_dereference_protected(sk2->sk_reuseport_cb,
+					  lockdep_is_held(&reuseport_lock)),
+	WARN_ONCE(rcu_dereference_protected(sk->sk_reuseport_cb,
+					    lockdep_is_held(&reuseport_lock)),
+		  "socket already in reuseport group");
+
+	if (reuse->num_socks == reuse->max_socks) {
+		reuse = reuseport_grow(reuse);
+		if (!reuse) {
+			spin_unlock_bh(&reuseport_lock);
+			return -ENOMEM;
+		}
+	}
+
+	reuse->socks[reuse->num_socks] = sk;
+	/* paired with smp_rmb() in reuseport_select_sock() */
+	smp_wmb();
+	reuse->num_socks++;
+	rcu_assign_pointer(sk->sk_reuseport_cb, reuse);
+
+	spin_unlock_bh(&reuseport_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(reuseport_add_sock);
+
+void reuseport_detach_sock(struct sock *sk)
+{
+	struct sock_reuseport *reuse;
+	int i;
+
+	spin_lock_bh(&reuseport_lock);
+	reuse = rcu_dereference_protected(sk->sk_reuseport_cb,
+					  lockdep_is_held(&reuseport_lock));
+	rcu_assign_pointer(sk->sk_reuseport_cb, NULL);
+
+	for (i = 0; i < reuse->num_socks; i++) {
+		if (reuse->socks[i] == sk) {
+			reuse->socks[i] = reuse->socks[reuse->num_socks - 1];
+			reuse->num_socks--;
+			if (reuse->num_socks == 0)
+				kfree_rcu(reuse, rcu);
+			break;
+		}
+	}
+	spin_unlock_bh(&reuseport_lock);
+}
+EXPORT_SYMBOL(reuseport_detach_sock);
+
+/**
+ *  reuseport_select_sock - Select a socket from an SO_REUSEPORT group.
+ *  @sk: First socket in the group.
+ *  @hash: Use this hash to select.
+ *  Returns a socket that should receive the packet (or NULL on error).
+ */
+struct sock *reuseport_select_sock(struct sock *sk, u32 hash)
+{
+	struct sock_reuseport *reuse;
+	struct sock *sk2 = NULL;
+	u16 socks;
+
+	rcu_read_lock();
+	reuse = rcu_dereference(sk->sk_reuseport_cb);
+
+	/* if memory allocation failed or add call is not yet complete */
+	if (!reuse)
+		goto out;
+
+	socks = READ_ONCE(reuse->num_socks);
+	if (likely(socks)) {
+		/* paired with smp_wmb() in reuseport_add_sock() */
+		smp_rmb();
+
+		sk2 = reuse->socks[reciprocal_scale(hash, socks)];
+	}
+
+out:
+	rcu_read_unlock();
+	return sk2;
+}
+EXPORT_SYMBOL(reuseport_select_sock);
-- 
2.6.0.rc2.230.g3dd15c0
