From: mleitner@redhat.com
Subject: [PATCH] sctp: fix ASCONF list handling
Date: Wed, 27 May 2015 21:52:17 -0300
Message-ID: <d78e23c156981e761086f4e37517e441c84d6f90.1432769183.git.marcelo.leitner@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753530AbbE1Awc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 20:52:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

->auto_asconf_splist is per namespace and mangled by functions like
sctp_setsockopt_auto_asconf() which doesn't guarantee any serialization.

Also, the call to inet_sk_copy_descendant() was backuping
->auto_asconf_list through the copy but was not honoring
->do_auto_asconf, which could lead to list corruption if it was
different between both sockets.

This commit thus fixes the list handling by adding a spinlock to protect
against multiple writers and converts the list to be protected by RCU
too, so that we don't have a lock inverstion issue at
sctp_addr_wq_timeout_handler().

And as this list now uses RCU, we cannot do such backup and restore
while copying descendant data anymore as readers may be traversing the
list meanwhile. We fix this by simply ignoring/not copying those fields,
placed at the end of struct sctp_sock, so we can just ignore it together
with struct ipv6_pinfo data. For that we create sctp_copy_descendant()
so we don't clutter inet_sk_copy_descendant() with SCTP info.

Issue was found with a test application that kept flipping sysctl
default_auto_asconf on and off.

Fixes: 9f7d653b67ae ("sctp: Add Auto-ASCONF support (core).")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/netns/sctp.h   |  6 +++++-
 include/net/sctp/structs.h |  2 ++
 net/sctp/protocol.c        |  6 +++++-
 net/sctp/socket.c          | 39 ++++++++++++++++++++++++++-------------
 4 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 3573a81815ad9e0efb6ceb721eb066d3726419f0..e080bebb3147af39c8275261f57018eb01e917b0 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -30,12 +30,15 @@ struct netns_sctp {
 	struct list_head local_addr_list;
 	struct list_head addr_waitq;
 	struct timer_list addr_wq_timer;
-	struct list_head auto_asconf_splist;
+	struct list_head __rcu auto_asconf_splist;
 	spinlock_t addr_wq_lock;
 
 	/* Lock that protects the local_addr_list writers */
 	spinlock_t local_addr_lock;
 
+	/* Lock that protects the auto_asconf_splist writers */
+	spinlock_t auto_asconf_lock;
+
 	/* RFC2960 Section 14. Suggested SCTP Protocol Parameter Values
 	 *
 	 * The following protocol parameters are RECOMMENDED:
@@ -129,6 +132,7 @@ struct netns_sctp {
 
 	/* Threshold for autoclose timeout, in seconds. */
 	unsigned long max_autoclose;
+
 };
 
 #endif /* __NETNS_SCTP_H__ */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 2bb2fcf5b11f0387c81b860ad2d3a6607da19a7d..459d9b8193cb9193ee038a09b67d2b67fbf335f0 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -223,6 +223,8 @@ struct sctp_sock {
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
 	struct sk_buff_head pd_lobby;
+	/* These must be the last fields, as they will skipped on copies,
+	 * like on accept and peeloff operations */
 	struct list_head auto_asconf_list;
 	int do_auto_asconf;
 };
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 53b7acde9aa37bf3d4029c459421564d5270f4c0..6947feae5b27ffbc61666f27fda384d346b982ba 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -632,7 +632,9 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
 			}
 		}
 #endif
-		list_for_each_entry(sp, &net->sctp.auto_asconf_splist, auto_asconf_list) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(sp, &net->sctp.auto_asconf_splist,
+					auto_asconf_list) {
 			struct sock *sk;
 
 			sk = sctp_opt2sk(sp);
@@ -644,6 +646,7 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
 				pr_debug("%s: sctp_asconf_mgmt failed\n", __func__);
 			bh_unlock_sock(sk);
 		}
+		rcu_read_unlock();
 #if IS_ENABLED(CONFIG_IPV6)
 free_next:
 #endif
@@ -1268,6 +1271,7 @@ static int __net_init sctp_net_init(struct net *net)
 	/* Initialize the local address list. */
 	INIT_LIST_HEAD(&net->sctp.local_addr_list);
 	spin_lock_init(&net->sctp.local_addr_lock);
+	spin_lock_init(&net->sctp.auto_asconf_lock);
 	sctp_get_local_addr_list(net);
 
 	/* Initialize the address event list */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f09de7fac2e6acddad8b2e046dbf626e329cb674..acc0fb0deed0e801bbb8460af0a965aedfdd0348 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3580,14 +3580,16 @@ static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
 	if ((val && sp->do_auto_asconf) || (!val && !sp->do_auto_asconf))
 		return 0;
 
+	spin_lock(&sock_net(sk)->sctp.auto_asconf_lock);
 	if (val == 0 && sp->do_auto_asconf) {
-		list_del(&sp->auto_asconf_list);
 		sp->do_auto_asconf = 0;
+		list_del_rcu(&sp->auto_asconf_list);
 	} else if (val && !sp->do_auto_asconf) {
-		list_add_tail(&sp->auto_asconf_list,
-		    &sock_net(sk)->sctp.auto_asconf_splist);
 		sp->do_auto_asconf = 1;
+		list_add_tail_rcu(&sp->auto_asconf_list,
+				  &sock_net(sk)->sctp.auto_asconf_splist);
 	}
+	spin_unlock(&sock_net(sk)->sctp.auto_asconf_lock);
 	return 0;
 }
 
@@ -4122,9 +4124,11 @@ static int sctp_init_sock(struct sock *sk)
 	percpu_counter_inc(&sctp_sockets_allocated);
 	sock_prot_inuse_add(net, sk->sk_prot, 1);
 	if (net->sctp.default_auto_asconf) {
-		list_add_tail(&sp->auto_asconf_list,
-		    &net->sctp.auto_asconf_splist);
+		spin_lock(&net->sctp.auto_asconf_lock);
 		sp->do_auto_asconf = 1;
+		list_add_tail_rcu(&sp->auto_asconf_list,
+				  &net->sctp.auto_asconf_splist);
+		spin_unlock(&net->sctp.auto_asconf_lock);
 	} else
 		sp->do_auto_asconf = 0;
 	local_bh_enable();
@@ -4148,8 +4152,10 @@ static void sctp_destroy_sock(struct sock *sk)
 		return;
 
 	if (sp->do_auto_asconf) {
+		spin_lock(&sock_net(sk)->sctp.auto_asconf_lock);
 		sp->do_auto_asconf = 0;
-		list_del(&sp->auto_asconf_list);
+		list_del_rcu(&sp->auto_asconf_list);
+		spin_unlock(&sock_net(sk)->sctp.auto_asconf_lock);
 	}
 	sctp_endpoint_free(sp->ep);
 	local_bh_disable();
@@ -7195,6 +7201,19 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 	newinet->mc_list = NULL;
 }
 
+static inline void sctp_copy_descendant(struct sock *sk_to,
+					const struct sock *sk_from)
+{
+	int ancestor_size = sizeof(struct inet_sock) +
+			    sizeof(struct sctp_sock) -
+			    offsetof(struct sctp_sock, auto_asconf_list);
+
+	if (sk_from->sk_family == PF_INET6)
+		ancestor_size += sizeof(struct ipv6_pinfo);
+
+	__inet_sk_copy_descendant(sk_to, sk_from, ancestor_size);
+}
+
 /* Populate the fields of the newsk from the oldsk and migrate the assoc
  * and its messages to the newsk.
  */
@@ -7209,7 +7228,6 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	struct sk_buff *skb, *tmp;
 	struct sctp_ulpevent *event;
 	struct sctp_bind_hashbucket *head;
-	struct list_head tmplist;
 
 	/* Migrate socket buffer sizes and all the socket level options to the
 	 * new socket.
@@ -7217,12 +7235,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	newsk->sk_sndbuf = oldsk->sk_sndbuf;
 	newsk->sk_rcvbuf = oldsk->sk_rcvbuf;
 	/* Brute force copy old sctp opt. */
-	if (oldsp->do_auto_asconf) {
-		memcpy(&tmplist, &newsp->auto_asconf_list, sizeof(tmplist));
-		inet_sk_copy_descendant(newsk, oldsk);
-		memcpy(&newsp->auto_asconf_list, &tmplist, sizeof(tmplist));
-	} else
-		inet_sk_copy_descendant(newsk, oldsk);
+	sctp_copy_descendant(newsk, oldsk);
 
 	/* Restore the ep value that was overwritten with the above structure
 	 * copy.
-- 
2.4.1
