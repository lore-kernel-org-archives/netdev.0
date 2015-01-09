From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 11/16] tipc: make tipc socket support net namespace
Date: Fri, 9 Jan 2015 15:27:08 +0800
Message-ID: <1420788433-17960-12-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Tero.Aho@coriant.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60303 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbbAIH2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 02:28:11 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now tipc socket table is statically allocated as a global variable.
Through it, we can look up one socket instance with port ID, insert
a new socket instance to the table, and delete a socket from the
table. But when tipc supports net namespace, each namespace must own
its specific socket table. So the global variable of socket table
must be redefined in tipc_net structure. As a concequence, a new
socket table will be allocated when a new namespace is created, and
a socket table will be deallocated when namespace is destroyed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c |    2 +-
 net/tipc/core.c   |   12 ++++--------
 net/tipc/core.h   |    4 ++++
 net/tipc/net.c    |    2 +-
 net/tipc/socket.c |   48 +++++++++++++++++++++++++++++-------------------
 net/tipc/socket.h |    8 ++++----
 6 files changed, 43 insertions(+), 33 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index ac73291..20b1c58 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -257,7 +257,7 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_media_get_names();
 		break;
 	case TIPC_CMD_SHOW_PORTS:
-		rep_tlv_buf = tipc_sk_socks_show();
+		rep_tlv_buf = tipc_sk_socks_show(net);
 		break;
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 7b84439..23ff3ca 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -55,17 +55,20 @@ int sysctl_tipc_rmem[3] __read_mostly;	/* min/default/max */
 static int __net_init tipc_init_net(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	int err;
 
 	tn->net_id = 4711;
 	INIT_LIST_HEAD(&tn->node_list);
 	spin_lock_init(&tn->node_list_lock);
 
-	return 0;
+	err = tipc_sk_rht_init(net);
+	return err;
 }
 
 static void __net_exit tipc_exit_net(struct net *net)
 {
 	tipc_net_stop(net);
+	tipc_sk_rht_destroy(net);
 }
 
 static struct pernet_operations tipc_net_ops = {
@@ -95,10 +98,6 @@ static int __init tipc_init(void)
 	if (err)
 		goto out_pernet;
 
-	err = tipc_sk_rht_init();
-	if (err)
-		goto out_reftbl;
-
 	err = tipc_nametbl_init();
 	if (err)
 		goto out_nametbl;
@@ -136,8 +135,6 @@ out_socket:
 out_netlink:
 	tipc_nametbl_stop();
 out_nametbl:
-	tipc_sk_rht_destroy();
-out_reftbl:
 	unregister_pernet_subsys(&tipc_net_ops);
 out_pernet:
 	pr_err("Unable to start in single node mode\n");
@@ -153,7 +150,6 @@ static void __exit tipc_exit(void)
 	tipc_nametbl_stop();
 	tipc_socket_stop();
 	tipc_unregister_sysctl();
-	tipc_sk_rht_destroy();
 
 	pr_info("Deactivated\n");
 }
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 3f6f9e0..1a7f816 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -58,6 +58,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/etherdevice.h>
 #include <net/netns/generic.h>
+#include <linux/rhashtable.h>
 
 #include "node.h"
 #include "bearer.h"
@@ -101,6 +102,9 @@ struct tipc_net {
 	struct tipc_bcbearer *bcbearer;
 	struct tipc_bclink *bclink;
 	struct tipc_link *bcl;
+
+	/* Socket hash table */
+	struct rhashtable sk_rht;
 };
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 7548ba8..44ccf47 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -117,7 +117,7 @@ int tipc_net_start(struct net *net, u32 addr)
 
 	tipc_own_addr = addr;
 	tipc_named_reinit();
-	tipc_sk_reinit();
+	tipc_sk_reinit(net);
 	res = tipc_bclink_init(net);
 	if (res)
 		return res;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6883145..accb02c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -115,7 +115,7 @@ static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 			   struct tipc_name_seq const *seq);
 static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 			    struct tipc_name_seq const *seq);
-static struct tipc_sock *tipc_sk_lookup(u32 portid);
+static struct tipc_sock *tipc_sk_lookup(struct net *net, u32 portid);
 static int tipc_sk_insert(struct tipc_sock *tsk);
 static void tipc_sk_remove(struct tipc_sock *tsk);
 
@@ -179,9 +179,6 @@ static const struct nla_policy tipc_nl_sock_policy[TIPC_NLA_SOCK_MAX + 1] = {
  *   - port reference
  */
 
-/* Protects tipc socket hash table mutations */
-static struct rhashtable tipc_sk_rht;
-
 static u32 tsk_peer_node(struct tipc_sock *tsk)
 {
 	return msg_destnode(&tsk->phdr);
@@ -1766,7 +1763,7 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	u32 dnode;
 
 	/* Validate destination and message */
-	tsk = tipc_sk_lookup(dport);
+	tsk = tipc_sk_lookup(net, dport);
 	if (unlikely(!tsk)) {
 		rc = tipc_msg_eval(skb, &dnode);
 		goto exit;
@@ -2245,8 +2242,9 @@ static int tipc_sk_show(struct tipc_sock *tsk, char *buf,
 	return ret;
 }
 
-struct sk_buff *tipc_sk_socks_show(void)
+struct sk_buff *tipc_sk_socks_show(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	const struct bucket_table *tbl;
 	struct rhash_head *pos;
 	struct sk_buff *buf;
@@ -2265,7 +2263,7 @@ struct sk_buff *tipc_sk_socks_show(void)
 	pb_len = ULTRA_STRING_MAX_LEN;
 
 	rcu_read_lock();
-	tbl = rht_dereference_rcu((&tipc_sk_rht)->tbl, &tipc_sk_rht);
+	tbl = rht_dereference_rcu((&tn->sk_rht)->tbl, &tn->sk_rht);
 	for (i = 0; i < tbl->size; i++) {
 		rht_for_each_entry_rcu(tsk, pos, tbl, i, node) {
 			spin_lock_bh(&tsk->sk.sk_lock.slock);
@@ -2286,8 +2284,9 @@ struct sk_buff *tipc_sk_socks_show(void)
 /* tipc_sk_reinit: set non-zero address in all existing sockets
  *                 when we go from standalone to network mode.
  */
-void tipc_sk_reinit(void)
+void tipc_sk_reinit(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	const struct bucket_table *tbl;
 	struct rhash_head *pos;
 	struct tipc_sock *tsk;
@@ -2295,7 +2294,7 @@ void tipc_sk_reinit(void)
 	int i;
 
 	rcu_read_lock();
-	tbl = rht_dereference_rcu((&tipc_sk_rht)->tbl, &tipc_sk_rht);
+	tbl = rht_dereference_rcu((&tn->sk_rht)->tbl, &tn->sk_rht);
 	for (i = 0; i < tbl->size; i++) {
 		rht_for_each_entry_rcu(tsk, pos, tbl, i, node) {
 			spin_lock_bh(&tsk->sk.sk_lock.slock);
@@ -2308,12 +2307,13 @@ void tipc_sk_reinit(void)
 	rcu_read_unlock();
 }
 
-static struct tipc_sock *tipc_sk_lookup(u32 portid)
+static struct tipc_sock *tipc_sk_lookup(struct net *net, u32 portid)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_sock *tsk;
 
 	rcu_read_lock();
-	tsk = rhashtable_lookup(&tipc_sk_rht, &portid);
+	tsk = rhashtable_lookup(&tn->sk_rht, &portid);
 	if (tsk)
 		sock_hold(&tsk->sk);
 	rcu_read_unlock();
@@ -2323,6 +2323,9 @@ static struct tipc_sock *tipc_sk_lookup(u32 portid)
 
 static int tipc_sk_insert(struct tipc_sock *tsk)
 {
+	struct sock *sk = &tsk->sk;
+	struct net *net = sock_net(sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 remaining = (TIPC_MAX_PORT - TIPC_MIN_PORT) + 1;
 	u32 portid = prandom_u32() % remaining + TIPC_MIN_PORT;
 
@@ -2332,7 +2335,7 @@ static int tipc_sk_insert(struct tipc_sock *tsk)
 			portid = TIPC_MIN_PORT;
 		tsk->portid = portid;
 		sock_hold(&tsk->sk);
-		if (rhashtable_lookup_insert(&tipc_sk_rht, &tsk->node))
+		if (rhashtable_lookup_insert(&tn->sk_rht, &tsk->node))
 			return 0;
 		sock_put(&tsk->sk);
 	}
@@ -2343,15 +2346,17 @@ static int tipc_sk_insert(struct tipc_sock *tsk)
 static void tipc_sk_remove(struct tipc_sock *tsk)
 {
 	struct sock *sk = &tsk->sk;
+	struct tipc_net *tn = net_generic(sock_net(sk), tipc_net_id);
 
-	if (rhashtable_remove(&tipc_sk_rht, &tsk->node)) {
+	if (rhashtable_remove(&tn->sk_rht, &tsk->node)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
 }
 
-int tipc_sk_rht_init(void)
+int tipc_sk_rht_init(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct rhashtable_params rht_params = {
 		.nelem_hint = 192,
 		.head_offset = offsetof(struct tipc_sock, node),
@@ -2364,15 +2369,17 @@ int tipc_sk_rht_init(void)
 		.shrink_decision = rht_shrink_below_30,
 	};
 
-	return rhashtable_init(&tipc_sk_rht, &rht_params);
+	return rhashtable_init(&tn->sk_rht, &rht_params);
 }
 
-void tipc_sk_rht_destroy(void)
+void tipc_sk_rht_destroy(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
 	/* Wait for socket readers to complete */
 	synchronize_net();
 
-	rhashtable_destroy(&tipc_sk_rht);
+	rhashtable_destroy(&tn->sk_rht);
 }
 
 /**
@@ -2730,10 +2737,12 @@ int tipc_nl_sk_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct rhash_head *pos;
 	u32 prev_portid = cb->args[0];
 	u32 portid = prev_portid;
+	struct net *net = sock_net(skb->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	int i;
 
 	rcu_read_lock();
-	tbl = rht_dereference_rcu((&tipc_sk_rht)->tbl, &tipc_sk_rht);
+	tbl = rht_dereference_rcu((&tn->sk_rht)->tbl, &tn->sk_rht);
 	for (i = 0; i < tbl->size; i++) {
 		rht_for_each_entry_rcu(tsk, pos, tbl, i, node) {
 			spin_lock_bh(&tsk->sk.sk_lock.slock);
@@ -2839,6 +2848,7 @@ int tipc_nl_publ_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	u32 tsk_portid = cb->args[0];
 	u32 last_publ = cb->args[1];
 	u32 done = cb->args[2];
+	struct net *net = sock_net(skb->sk);
 	struct tipc_sock *tsk;
 
 	if (!tsk_portid) {
@@ -2864,7 +2874,7 @@ int tipc_nl_publ_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	if (done)
 		return 0;
 
-	tsk = tipc_sk_lookup(tsk_portid);
+	tsk = tipc_sk_lookup(net, tsk_portid);
 	if (!tsk)
 		return -EINVAL;
 
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index eb15c31..c15c4e1 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -50,11 +50,11 @@ void tipc_sock_release_local(struct socket *sock);
 int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
 			   int flags);
 int tipc_sk_rcv(struct net *net, struct sk_buff *buf);
-struct sk_buff *tipc_sk_socks_show(void);
+struct sk_buff *tipc_sk_socks_show(struct net *net);
 void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf);
-void tipc_sk_reinit(void);
-int tipc_sk_rht_init(void);
-void tipc_sk_rht_destroy(void);
+void tipc_sk_reinit(struct net *net);
+int tipc_sk_rht_init(struct net *net);
+void tipc_sk_rht_destroy(struct net *net);
 int tipc_nl_sk_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_publ_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
-- 
1.7.9.5
