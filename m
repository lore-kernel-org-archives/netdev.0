From: mleitner@redhat.com
Subject: [PATCH v3 2/2] sctp: fix ASCONF list handling
Date: Fri,  5 Jun 2015 14:08:06 -0300
Message-ID: <b319ab74178e7f186081db90cc24c229127e42ad.1433524062.git.marcelo.leitner@gmail.com>
References: <20150604142710.GD24585@hmsreliant.think-freely.org>
Cc: linux-sctp@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbbFERIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2015 13:08:17 -0400
In-Reply-To: <20150604142710.GD24585@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

->auto_asconf_splist is per namespace and mangled by functions like
sctp_setsockopt_auto_asconf() which doesn't guarantee any serialization.

Also, the call to inet_sk_copy_descendant() was backuping
->auto_asconf_list through the copy but was not honoring
->do_auto_asconf, which could lead to list corruption if it was
different between both sockets.

This commit thus fixes the list handling by rcu-ifying it and using
->addr_wq_lock spinlock to protect against multiple writers.

Instead of taking the lock on sctp_sock_migrate() for copying and
restoring the list values, it's preferred to avoid rewritting it by
implementing sctp_copy_descendant().

Issue was found with a test application that kept flipping sysctl
default_auto_asconf on and off, but one could trigger it by issuing
simultaneous setsockopt() calls on multiple sockets or by
creating/destroying sockets fast enough. This is only triggerable
locally.

Fixes: 9f7d653b67ae ("sctp: Add Auto-ASCONF support (core).")
Reported-by: Ji Jianwen <jiji@redhat.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/netns/sctp.h   |  3 ++-
 include/net/sctp/structs.h |  4 ++++
 net/sctp/protocol.c        |  3 ++-
 net/sctp/socket.c          | 39 ++++++++++++++++++++++++++-------------
 4 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 9e53412c4ed829e8e45777a6d95406d490dbaa75..161de47076ebee2ffce2b777a61e673e576fd982 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -30,7 +30,8 @@ struct netns_sctp {
 	struct list_head local_addr_list;
 	struct list_head __rcu addr_waitq;
 	struct timer_list addr_wq_timer;
-	struct list_head auto_asconf_splist;
+	struct list_head __rcu auto_asconf_splist;
+	/* Lock that protects both addr_waitq and auto_asconf_splist */
 	spinlock_t addr_wq_lock;
 
 	/* Lock that protects the local_addr_list writers */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 2bb2fcf5b11f0387c81b860ad2d3a6607da19a7d..495c87e367b3f2e8941807f56a77d2e14469bfed 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -223,6 +223,10 @@ struct sctp_sock {
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
 	struct sk_buff_head pd_lobby;
+
+	/* These must be the last fields, as they will skipped on copies,
+	 * like on accept and peeloff operations
+	 */
 	struct list_head auto_asconf_list;
 	int do_auto_asconf;
 };
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 9954fb8c9a9455d5ad7a627e2d7f9a1fef861fc2..233df013dc7ece3efb6739f3861e70f3324d26ab 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -664,7 +664,8 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
 			}
 		}
 #endif
-		list_for_each_entry(sp, &net->sctp.auto_asconf_splist, auto_asconf_list) {
+		list_for_each_entry_rcu(sp, &net->sctp.auto_asconf_splist,
+					auto_asconf_list) {
 			struct sock *sk;
 
 			sk = sctp_opt2sk(sp);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f09de7fac2e6acddad8b2e046dbf626e329cb674..475f84f80e5448f1f33d213dd9c3eae08365610f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3580,14 +3580,16 @@ static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
 	if ((val && sp->do_auto_asconf) || (!val && !sp->do_auto_asconf))
 		return 0;
 
+	spin_lock_bh(&sock_net(sk)->sctp.addr_wq_lock);
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
+	spin_unlock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 	return 0;
 }
 
@@ -4122,9 +4124,11 @@ static int sctp_init_sock(struct sock *sk)
 	percpu_counter_inc(&sctp_sockets_allocated);
 	sock_prot_inuse_add(net, sk->sk_prot, 1);
 	if (net->sctp.default_auto_asconf) {
-		list_add_tail(&sp->auto_asconf_list,
-		    &net->sctp.auto_asconf_splist);
+		spin_lock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 		sp->do_auto_asconf = 1;
+		list_add_tail_rcu(&sp->auto_asconf_list,
+				  &net->sctp.auto_asconf_splist);
+		spin_unlock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 	} else
 		sp->do_auto_asconf = 0;
 	local_bh_enable();
@@ -4148,8 +4152,10 @@ static void sctp_destroy_sock(struct sock *sk)
 		return;
 
 	if (sp->do_auto_asconf) {
+		spin_lock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 		sp->do_auto_asconf = 0;
-		list_del(&sp->auto_asconf_list);
+		list_del_rcu(&sp->auto_asconf_list);
+		spin_unlock_bh(&sock_net(sk)->sctp.addr_wq_lock);
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
