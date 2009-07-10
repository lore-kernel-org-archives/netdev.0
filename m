From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/4] netlink: use call_rcu for netlink_change_ngroups
Date: Fri, 10 Jul 2009 21:51:32 +0200
Message-ID: <20090710195536.193846183@sipsolutions.net>
References: <20090710195131.504091075@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, tgraf@suug.ch,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46290 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756675AbZGJT50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 15:57:26 -0400
Content-Disposition: inline; filename=027-netlink-groups-realloc-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the network namespace work in generic netlink I need
to be able to call this function under rcu_read_lock(),
otherwise the locking becomes a nightmare and more locks
would be needed. Instead, just embed a struct rcu_head
(actually a struct listeners_rcu_head that also carries
the pointer to the memory block) into the listeners
memory so we can use call_rcu() instead of synchronising
and then freeing. No rcu_barrier() is needed since this
code cannot be modular.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 net/netlink/af_netlink.c |   34 ++++++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

--- wireless-testing.orig/net/netlink/af_netlink.c	2009-07-10 20:36:53.000000000 +0200
+++ wireless-testing/net/netlink/af_netlink.c	2009-07-10 20:51:40.000000000 +0200
@@ -83,6 +83,11 @@ struct netlink_sock {
 	struct module		*module;
 };
 
+struct listeners_rcu_head {
+	struct rcu_head rcu_head;
+	void *ptr;
+};
+
 #define NETLINK_KERNEL_SOCKET	0x1
 #define NETLINK_RECV_PKTINFO	0x2
 #define NETLINK_BROADCAST_SEND_ERROR	0x4
@@ -1487,7 +1492,8 @@ netlink_kernel_create(struct net *net, i
 	if (groups < 32)
 		groups = 32;
 
-	listeners = kzalloc(NLGRPSZ(groups), GFP_KERNEL);
+	listeners = kzalloc(NLGRPSZ(groups) + sizeof(struct listeners_rcu_head),
+			    GFP_KERNEL);
 	if (!listeners)
 		goto out_sock_release;
 
@@ -1535,6 +1541,14 @@ netlink_kernel_release(struct sock *sk)
 EXPORT_SYMBOL(netlink_kernel_release);
 
 
+static void netlink_free_old_listeners(struct rcu_head *rcu_head)
+{
+	struct listeners_rcu_head *lrh;
+
+	lrh = container_of(rcu_head, struct listeners_rcu_head, rcu_head);
+	kfree(lrh->ptr);
+}
+
 /**
  * netlink_change_ngroups - change number of multicast groups
  *
@@ -1550,6 +1564,7 @@ EXPORT_SYMBOL(netlink_kernel_release);
 int netlink_change_ngroups(struct sock *sk, unsigned int groups)
 {
 	unsigned long *listeners, *old = NULL;
+	struct listeners_rcu_head *old_rcu_head;
 	struct netlink_table *tbl = &nl_table[sk->sk_protocol];
 	int err = 0;
 
@@ -1558,7 +1573,9 @@ int netlink_change_ngroups(struct sock *
 
 	netlink_table_grab();
 	if (NLGRPSZ(tbl->groups) < NLGRPSZ(groups)) {
-		listeners = kzalloc(NLGRPSZ(groups), GFP_ATOMIC);
+		listeners = kzalloc(NLGRPSZ(groups) +
+				    sizeof(struct listeners_rcu_head),
+				    GFP_ATOMIC);
 		if (!listeners) {
 			err = -ENOMEM;
 			goto out_ungrab;
@@ -1566,13 +1583,22 @@ int netlink_change_ngroups(struct sock *
 		old = tbl->listeners;
 		memcpy(listeners, old, NLGRPSZ(tbl->groups));
 		rcu_assign_pointer(tbl->listeners, listeners);
+		/*
+		 * Free the old memory after an RCU grace period so we
+		 * don't leak it. We use call_rcu() here in order to be
+		 * able to call this function from atomic contexts. The
+		 * allocation of this memory will have reserved enough
+		 * space for struct listeners_rcu_head at the end.
+		 */
+		old_rcu_head = (void *)(tbl->listeners +
+					NLGRPLONGS(tbl->groups));
+		old_rcu_head->ptr = old;
+		call_rcu(&old_rcu_head->rcu_head, netlink_free_old_listeners);
 	}
 	tbl->groups = groups;
 
  out_ungrab:
 	netlink_table_ungrab();
-	synchronize_rcu();
-	kfree(old);
 	return err;
 }
 

-- 

