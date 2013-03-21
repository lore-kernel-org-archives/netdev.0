From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 1/2] net: prepare netlink code for netlink diag
Date: Thu, 21 Mar 2013 13:21:08 +0400
Message-ID: <1363857669-19990-2-git-send-email-avagin@openvz.org>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org>
Cc: Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363857669-19990-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move a few declarations in a header.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/netlink/af_netlink.c | 59 ++++-----------------------------------------
 net/netlink/af_netlink.h | 62 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+), 54 deletions(-)
 create mode 100644 net/netlink/af_netlink.h

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1e3fd5b..a500ce2 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -61,28 +61,7 @@
 #include <net/scm.h>
 #include <net/netlink.h>
 
-#define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
-#define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
-
-struct netlink_sock {
-	/* struct sock has to be the first member of netlink_sock */
-	struct sock		sk;
-	u32			portid;
-	u32			dst_portid;
-	u32			dst_group;
-	u32			flags;
-	u32			subscriptions;
-	u32			ngroups;
-	unsigned long		*groups;
-	unsigned long		state;
-	wait_queue_head_t	wait;
-	struct netlink_callback	*cb;
-	struct mutex		*cb_mutex;
-	struct mutex		cb_def_mutex;
-	void			(*netlink_rcv)(struct sk_buff *skb);
-	void			(*netlink_bind)(int group);
-	struct module		*module;
-};
+#include "af_netlink.h"
 
 struct listeners {
 	struct rcu_head		rcu;
@@ -94,48 +73,20 @@ struct listeners {
 #define NETLINK_BROADCAST_SEND_ERROR	0x4
 #define NETLINK_RECV_NO_ENOBUFS	0x8
 
-static inline struct netlink_sock *nlk_sk(struct sock *sk)
-{
-	return container_of(sk, struct netlink_sock, sk);
-}
-
 static inline int netlink_is_kernel(struct sock *sk)
 {
 	return nlk_sk(sk)->flags & NETLINK_KERNEL_SOCKET;
 }
 
-struct nl_portid_hash {
-	struct hlist_head	*table;
-	unsigned long		rehash_time;
-
-	unsigned int		mask;
-	unsigned int		shift;
-
-	unsigned int		entries;
-	unsigned int		max_shift;
-
-	u32			rnd;
-};
-
-struct netlink_table {
-	struct nl_portid_hash	hash;
-	struct hlist_head	mc_list;
-	struct listeners __rcu	*listeners;
-	unsigned int		flags;
-	unsigned int		groups;
-	struct mutex		*cb_mutex;
-	struct module		*module;
-	void			(*bind)(int group);
-	int			registered;
-};
-
-static struct netlink_table *nl_table;
+struct netlink_table *nl_table;
+EXPORT_SYMBOL_GPL(nl_table);
 
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 
 static int netlink_dump(struct sock *sk);
 
-static DEFINE_RWLOCK(nl_table_lock);
+DEFINE_RWLOCK(nl_table_lock);
+EXPORT_SYMBOL_GPL(nl_table_lock);
 static atomic_t nl_table_users = ATOMIC_INIT(0);
 
 #define nl_deref_protected(X) rcu_dereference_protected(X, lockdep_is_held(&nl_table_lock));
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
new file mode 100644
index 0000000..d9acb2a
--- /dev/null
+++ b/net/netlink/af_netlink.h
@@ -0,0 +1,62 @@
+#ifndef _AF_NETLINK_H
+#define _AF_NETLINK_H
+
+#include <net/sock.h>
+
+#define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
+#define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
+
+struct netlink_sock {
+	/* struct sock has to be the first member of netlink_sock */
+	struct sock		sk;
+	u32			portid;
+	u32			dst_portid;
+	u32			dst_group;
+	u32			flags;
+	u32			subscriptions;
+	u32			ngroups;
+	unsigned long		*groups;
+	unsigned long		state;
+	wait_queue_head_t	wait;
+	struct netlink_callback	*cb;
+	struct mutex		*cb_mutex;
+	struct mutex		cb_def_mutex;
+	void			(*netlink_rcv)(struct sk_buff *skb);
+	void			(*netlink_bind)(int group);
+	struct module		*module;
+};
+
+static inline struct netlink_sock *nlk_sk(struct sock *sk)
+{
+	return container_of(sk, struct netlink_sock, sk);
+}
+
+struct nl_portid_hash {
+	struct hlist_head	*table;
+	unsigned long		rehash_time;
+
+	unsigned int		mask;
+	unsigned int		shift;
+
+	unsigned int		entries;
+	unsigned int		max_shift;
+
+	u32			rnd;
+};
+
+struct netlink_table {
+	struct nl_portid_hash	hash;
+	struct hlist_head	mc_list;
+	struct listeners __rcu	*listeners;
+	unsigned int		flags;
+	unsigned int		groups;
+	struct mutex		*cb_mutex;
+	struct module		*module;
+	void			(*bind)(int group);
+	int			registered;
+};
+
+extern struct netlink_table *nl_table;
+extern rwlock_t nl_table_lock;
+
+#endif
-- 
1.8.1.4
