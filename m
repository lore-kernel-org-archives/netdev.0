From: Corey Minyard <minyard@acm.org>
Subject: [PATCH 2/3] Add RCU versions of socket hlist handling
Date: Mon, 06 Oct 2008 13:45:57 -0500
Message-ID: <20081006184557.GA10287@minyard.local>
Reply-To: minyard@acm.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms172073pub.verizon.net ([206.46.172.73]:41210 "EHLO
	vms172073pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755690AbYJFTqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 15:46:17 -0400
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add RCU version of some of the socket hlist handlers, getting ready
for changing the UDP hash lock to RCU.

Signed-off-by: Corey Minyard <cminyard@mvista.com>
---
 include/net/sock.h |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 06c5259..6cd39e5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -42,6 +42,7 @@
 
 #include <linux/kernel.h>
 #include <linux/list.h>
+#include <linux/rculist.h>
 #include <linux/timer.h>
 #include <linux/cache.h>
 #include <linux/module.h>
@@ -294,12 +295,24 @@ static inline struct sock *sk_head(const struct hlist_head *head)
 	return hlist_empty(head) ? NULL : __sk_head(head);
 }
 
+static inline struct sock *sk_head_rcu(const struct hlist_head *head)
+{
+	struct hlist_node *first = rcu_dereference(head->first);
+	return first ? hlist_entry(first, struct sock, sk_node) : NULL;
+}
+
 static inline struct sock *sk_next(const struct sock *sk)
 {
 	return sk->sk_node.next ?
 		hlist_entry(sk->sk_node.next, struct sock, sk_node) : NULL;
 }
 
+static inline struct sock *sk_next_rcu(const struct sock *sk)
+{
+	struct hlist_node *next = rcu_dereference(sk->sk_node.next);
+	return next ? hlist_entry(next, struct sock, sk_node) : NULL;
+}
+
 static inline int sk_unhashed(const struct sock *sk)
 {
 	return hlist_unhashed(&sk->sk_node);
@@ -361,6 +374,27 @@ static __inline__ int sk_del_node_init(struct sock *sk)
 	return rc;
 }
 
+static inline int __sk_del_node_init_rcu(struct sock *sk)
+{
+	if (sk_hashed(sk)) {
+		hlist_del_init_rcu(&sk->sk_node);
+		return 1;
+	}
+	return 0;
+}
+
+static inline int sk_del_node_init_rcu(struct sock *sk)
+{
+	int rc = __sk_del_node_init_rcu(sk);
+
+	if (rc) {
+		/* paranoid for a while -acme */
+		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
+		__sock_put(sk);
+	}
+	return rc;
+}
+
 static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
 {
 	hlist_add_head(&sk->sk_node, list);
@@ -372,6 +406,17 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
 	__sk_add_node(sk, list);
 }
 
+static inline void __sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+{
+	hlist_add_head_rcu(&sk->sk_node, list);
+}
+
+static inline void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+{
+	sock_hold(sk);
+	__sk_add_node_rcu(sk, list);
+}
+
 static __inline__ void __sk_del_bind_node(struct sock *sk)
 {
 	__hlist_del(&sk->sk_bind_node);
@@ -385,9 +430,14 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
 
 #define sk_for_each(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_node)
+#define sk_for_each_rcu(__sk, node, list) \
+	hlist_for_each_entry_rcu(__sk, node, list, sk_node)
 #define sk_for_each_from(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_from(__sk, node, sk_node)
+#define sk_for_each_from_rcu(__sk, node) \
+	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
+		hlist_for_each_entry_from_rcu(__sk, node, sk_node)
 #define sk_for_each_continue(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_continue(__sk, node, sk_node)
-- 
1.5.6.5

