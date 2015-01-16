From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v3 3/3] genetlink: synchronize socket closing and family removal
Date: Fri, 16 Jan 2015 11:37:14 +0100
Message-ID: <1421404634-8973-3-git-send-email-johannes@sipsolutions.net>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41168 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398AbbAPKh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 05:37:27 -0500
In-Reply-To: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

In addition to the problem Jeff Layton reported, I looked at the code
and reproduced the same warning by subscribing and removing the genl
family with a socket still open. This is a fairly tricky race which
originates in the fact that generic netlink allows the family to go
away while sockets are still open - unlike regular netlink which has
a module refcount for every open socket so in general this cannot be
triggered.

Trying to resolve this issue by the obvious locking isn't possible as
it will result in deadlocks between unregistration and group unbind
notification (which incidentally lockdep doesn't find due to the home
grown locking in the netlink table.)

To really resolve this, introduce a "closing socket" reference counter
(for generic netlink only, as it's the only affected family) in the
core netlink code and use that in generic netlink to wait for all the
sockets that are being closed at the same time as a generic netlink
family is removed.

This fixes the race that when a socket is closed, it will should call
the unbind, but if the family is removed at the same time the unbind
will not find it, leading to the warning. The real problem though is
that in this case the unbind could actually find a new family that is
registered to have a multicast group with the same ID, and call its
mcast_unbind() leading to confusing.

Also remove the warning since it would still trigger, but is now no
longer a problem.

This also moves the code in af_netlink.c to before unreferencing the
module to avoid having the same problem in the normal non-genl case.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/genetlink.h |  4 ++++
 include/net/genetlink.h   |  5 ++++-
 net/netlink/af_netlink.c  | 24 +++++++++++++++++-------
 net/netlink/af_netlink.h  |  1 +
 net/netlink/genetlink.c   | 16 +++++++++-------
 5 files changed, 35 insertions(+), 15 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 55b685719d52..09460d6d6682 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -11,6 +11,10 @@ extern void genl_unlock(void);
 extern int lockdep_genl_is_held(void);
 #endif
 
+/* for synchronisation between af_netlink and genetlink */
+extern atomic_t genl_sk_destructing_cnt;
+extern wait_queue_head_t genl_sk_destructing_waitq;
+
 /**
  * rcu_dereference_genl - rcu_dereference with debug checking
  * @p: The pointer to read, prior to dereferencing
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 2ea2c55bdc87..6c92415311ca 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -35,7 +35,10 @@ struct genl_info;
  *	undo operations done by pre_doit, for example release locks
  * @mcast_bind: a socket bound to the given multicast group (which
  *	is given as the offset into the groups array)
- * @mcast_unbind: a socket was unbound from the given multicast group
+ * @mcast_unbind: a socket was unbound from the given multicast group.
+ *	Note that unbind() will not be called symmetrically if the
+ *	generic netlink family is removed while there are still open
+ *	sockets.
  * @attrbuf: buffer to store parsed attributes
  * @family_list: family list
  * @mcgrps: multicast groups used by this family (private)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 01b702d63457..0a91ea36ac55 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -61,6 +61,7 @@
 #include <linux/rhashtable.h>
 #include <asm/cacheflush.h>
 #include <linux/hash.h>
+#include <linux/genetlink.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -1089,6 +1090,8 @@ static void netlink_remove(struct sock *sk)
 		__sk_del_bind_node(sk);
 		netlink_update_listeners(sk);
 	}
+	if (sk->sk_protocol == NETLINK_GENERIC)
+		atomic_inc(&genl_sk_destructing_cnt);
 	netlink_table_ungrab();
 }
 
@@ -1212,6 +1215,20 @@ static int netlink_release(struct socket *sock)
 	 * will be purged.
 	 */
 
+	/* must not acquire netlink_table_lock in any way again before unbind
+	 * and notifying genetlink is done as otherwise it might deadlock
+	 */
+	if (nlk->netlink_unbind) {
+		int i;
+
+		for (i = 0; i < nlk->ngroups; i++)
+			if (test_bit(i, nlk->groups))
+				nlk->netlink_unbind(sock_net(sk), i + 1);
+	}
+	if (sk->sk_protocol == NETLINK_GENERIC &&
+	    atomic_dec_return(&genl_sk_destructing_cnt) == 0)
+		wake_up(&genl_sk_destructing_waitq);
+
 	sock->sk = NULL;
 	wake_up_interruptible_all(&nlk->wait);
 
@@ -1247,13 +1264,6 @@ static int netlink_release(struct socket *sock)
 		netlink_table_ungrab();
 	}
 
-	if (nlk->netlink_unbind) {
-		int i;
-
-		for (i = 0; i < nlk->ngroups; i++)
-			if (test_bit(i, nlk->groups))
-				nlk->netlink_unbind(sock_net(sk), i + 1);
-	}
 	kfree(nlk->groups);
 	nlk->groups = NULL;
 
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 7518375782f5..89008405d6b4 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -2,6 +2,7 @@
 #define _AF_NETLINK_H
 
 #include <linux/rhashtable.h>
+#include <linux/atomic.h>
 #include <net/sock.h>
 
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index c18d3f5624b2..ee57459fc258 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -23,6 +23,9 @@
 static DEFINE_MUTEX(genl_mutex); /* serialization of message processing */
 static DECLARE_RWSEM(cb_lock);
 
+atomic_t genl_sk_destructing_cnt = ATOMIC_INIT(0);
+DECLARE_WAIT_QUEUE_HEAD(genl_sk_destructing_waitq);
+
 void genl_lock(void)
 {
 	mutex_lock(&genl_mutex);
@@ -435,15 +438,18 @@ int genl_unregister_family(struct genl_family *family)
 
 	genl_lock_all();
 
-	genl_unregister_mc_groups(family);
-
 	list_for_each_entry(rc, genl_family_chain(family->id), family_list) {
 		if (family->id != rc->id || strcmp(rc->name, family->name))
 			continue;
 
+		genl_unregister_mc_groups(family);
+
 		list_del(&rc->family_list);
 		family->n_ops = 0;
-		genl_unlock_all();
+		up_write(&cb_lock);
+		wait_event(genl_sk_destructing_waitq,
+			   atomic_read(&genl_sk_destructing_cnt) == 0);
+		genl_unlock();
 
 		kfree(family->attrbuf);
 		genl_ctrl_event(CTRL_CMD_DELFAMILY, family, NULL, 0);
@@ -1014,7 +1020,6 @@ static int genl_bind(struct net *net, int group)
 static void genl_unbind(struct net *net, int group)
 {
 	int i;
-	bool found = false;
 
 	down_read(&cb_lock);
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
@@ -1027,14 +1032,11 @@ static void genl_unbind(struct net *net, int group)
 
 				if (f->mcast_unbind)
 					f->mcast_unbind(net, fam_grp);
-				found = true;
 				break;
 			}
 		}
 	}
 	up_read(&cb_lock);
-
-	WARN_ON(!found);
 }
 
 static int __net_init genl_pernet_init(struct net *net)
-- 
2.1.4
