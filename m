From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 1/3] netlink: allocate group bitmaps dynamically
Date: Wed, 04 Jul 2007 16:30:38 +0200
Message-ID: <20070704143152.655964000@sipsolutions.net>
References: <20070704143037.495786000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56601 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760420AbXGDOht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 10:37:49 -0400
Content-Disposition: inline; filename=053-netlink-groups.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow changing the number of groups for a netlink family
after it has been created, use RCU to protect the listeners
bitmap keeping netlink_has_listeners() lock-free.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 include/linux/netlink.h  |    1 
 net/netlink/af_netlink.c |   86 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 66 insertions(+), 21 deletions(-)

--- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-04 00:43:55.297749881 +0200
+++ wireless-dev/net/netlink/af_netlink.c	2007-07-04 01:12:17.046331215 +0200
@@ -62,6 +62,7 @@
 #include <net/netlink.h>
 
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
+#define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
 
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
@@ -314,10 +315,12 @@ netlink_update_listeners(struct sock *sk
 	unsigned long mask;
 	unsigned int i;
 
-	for (i = 0; i < NLGRPSZ(tbl->groups)/sizeof(unsigned long); i++) {
+	for (i = 0; i < NLGRPLONGS(tbl->groups); i++) {
 		mask = 0;
-		sk_for_each_bound(sk, node, &tbl->mc_list)
-			mask |= nlk_sk(sk)->groups[i];
+		sk_for_each_bound(sk, node, &tbl->mc_list) {
+			if (i < NLGRPLONGS(nlk_sk(sk)->ngroups))
+				mask |= nlk_sk(sk)->groups[i];
+		}
 		tbl->listeners[i] = mask;
 	}
 	/* this function is only called with the netlink table "grabbed", which
@@ -555,26 +558,37 @@ netlink_update_subscriptions(struct sock
 	nlk->subscriptions = subscriptions;
 }
 
-static int netlink_alloc_groups(struct sock *sk)
+static int netlink_realloc_groups(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 	unsigned int groups;
+	unsigned long *new_groups;
 	int err = 0;
 
 	netlink_lock_table();
 	groups = nl_table[sk->sk_protocol].groups;
 	if (!nl_table[sk->sk_protocol].registered)
 		err = -ENOENT;
-	netlink_unlock_table();
 
 	if (err)
-		return err;
+		goto out_unlock;
 
-	nlk->groups = kzalloc(NLGRPSZ(groups), GFP_KERNEL);
-	if (nlk->groups == NULL)
-		return -ENOMEM;
+	if (nlk->ngroups >= groups)
+		goto out_unlock;
+
+	new_groups = krealloc(nlk->groups, NLGRPSZ(groups), GFP_KERNEL);
+	if (new_groups == NULL) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
+	memset((char*)new_groups + NLGRPSZ(nlk->ngroups), 0,
+	       NLGRPSZ(groups) - NLGRPSZ(nlk->ngroups));
+
+	nlk->groups = new_groups;
 	nlk->ngroups = groups;
-	return 0;
+ out_unlock:
+	netlink_unlock_table();
+	return err;
 }
 
 static int netlink_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
@@ -591,11 +605,9 @@ static int netlink_bind(struct socket *s
 	if (nladdr->nl_groups) {
 		if (!netlink_capable(sock, NL_NONROOT_RECV))
 			return -EPERM;
-		if (nlk->groups == NULL) {
-			err = netlink_alloc_groups(sk);
-			if (err)
-				return err;
-		}
+		err = netlink_realloc_groups(sk);
+		if (err)
+			return err;
 	}
 
 	if (nlk->pid) {
@@ -839,10 +851,18 @@ retry:
 int netlink_has_listeners(struct sock *sk, unsigned int group)
 {
 	int res = 0;
+	unsigned long *listeners;
 
 	BUG_ON(!(nlk_sk(sk)->flags & NETLINK_KERNEL_SOCKET));
+
+	rcu_read_lock();
+	listeners = rcu_dereference(nl_table[sk->sk_protocol].listeners);
+
 	if (group - 1 < nl_table[sk->sk_protocol].groups)
-		res = test_bit(group - 1, nl_table[sk->sk_protocol].listeners);
+		res = test_bit(group - 1, listeners);
+
+	rcu_read_unlock();
+
 	return res;
 }
 EXPORT_SYMBOL_GPL(netlink_has_listeners);
@@ -1037,11 +1057,9 @@ static int netlink_setsockopt(struct soc
 
 		if (!netlink_capable(sock, NL_NONROOT_RECV))
 			return -EPERM;
-		if (nlk->groups == NULL) {
-			err = netlink_alloc_groups(sk);
-			if (err)
-				return err;
-		}
+		err = netlink_realloc_groups(sk);
+		if (err)
+			return err;
 		if (!val || val - 1 >= nlk->ngroups)
 			return -EINVAL;
 		netlink_table_grab();
@@ -1328,6 +1346,32 @@ out_sock_release:
 	return NULL;
 }
 
+int netlink_change_ngroups(int unit, unsigned int groups)
+{
+	unsigned long *listeners, old = NULL;
+	int err = 0;
+
+	netlink_table_grab();
+	if (NLGRPSZ(nl_table[unit].groups) < NLGRPSZ(groups)) {
+		listeners = kzalloc(NLGRPSZ(groups), GFP_ATOMIC);
+		if (!listeners) {
+			err = -ENOMEM;
+			goto out_ungrab;
+		}
+		old = nl_table[unit].listeners;
+		memcpy(listeners, old, NLGRPSZ(nl_table[unit].groups));
+		rcu_assign_pointer(nl_table[unit].listeners, listeners);
+	}
+	nl_table[unit].groups = groups;
+
+ out_ungrab:
+	netlink_table_ungrab();
+	synchronize_rcu();
+	kfree(old);
+	return err;
+}
+EXPORT_SYMBOL(netlink_change_ngroups);
+
 void netlink_set_nonroot(int protocol, unsigned int flags)
 {
 	if ((unsigned int)protocol < MAX_LINKS)
--- wireless-dev.orig/include/linux/netlink.h	2007-07-04 00:43:20.437749881 +0200
+++ wireless-dev/include/linux/netlink.h	2007-07-04 01:10:34.986331215 +0200
@@ -161,6 +161,7 @@ extern struct sock *netlink_kernel_creat
 					  void (*input)(struct sock *sk, int len),
 					  struct mutex *cb_mutex,
 					  struct module *module);
+extern int netlink_change_ngroups(int unit, unsigned int groups);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);

-- 

