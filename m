From: mleitner@redhat.com
Subject: [PATCH v4] sctp: fix ASCONF list handling
Date: Thu, 11 Jun 2015 11:30:46 -0300
Message-ID: <94ae715119611f8df1baccd4f016c5d49a047a8d.1434032881.git.marcelo.leitner@gmail.com>
References: <20150610191418.GA19556@hmsreliant.think-freely.org>
Cc: linux-sctp@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: Neil Horman <nhorman@tuxdriver.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbbFKOa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 10:30:58 -0400
In-Reply-To: <20150610191418.GA19556@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

->auto_asconf_splist is per namespace and mangled by functions like
sctp_setsockopt_auto_asconf() which doesn't guarantee any serialization.

Also, the call to inet_sk_copy_descendant() was backuping
->auto_asconf_list through the copy but was not honoring
->do_auto_asconf, which could lead to list corruption if it was
different between both sockets.

This commit thus fixes the list handling by using ->addr_wq_lock
spinlock to protect the list. A special handling is done upon socket
creation and destruction for that. Error handlig on sctp_init_sock()
will never return an error after having initialized asconf, so
sctp_destroy_sock() can be called without addrq_wq_lock. The lock now
will be take on sctp_close_sock(), before locking the socket, so we
don't do it in inverse order compared to sctp_addr_wq_timeout_handler().

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
Suggested-by: Neil Horman <nhorman@tuxdriver.com>
Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

Notes:
    Attempts to circumvent this lock invertion with RCU and/or list splicing
    were unsuccessful, as they led to more and more code to handle it
    properly.
    
    Back when Hannes started reviewing the patches, he had asked if I
    couldn't take the lock earlier during the socket destruction. I had said
    no because sctp_destroy_sock() is called with socket lock already held
    on sctp_close_sock() and such would not be possible to handle on error
    handling situations like when sctp_init_sock() fails and
    sctp_destroy_sock() is called right after that.
    
    But if we take care that nothing fails after initializing asconf on
    sctp_init_sock(), this is possible, and less complicated than my RCU and
    list splicing attempts.

 include/net/netns/sctp.h   |  1 +
 include/net/sctp/structs.h |  4 ++++
 net/sctp/socket.c          | 38 ++++++++++++++++++++++++++++++--------
 3 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 3573a81815ad9e0efb6ceb721eb066d3726419f0..8ba379f9e4678d7f00209a6b2ac12d41d82f4b25 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -31,6 +31,7 @@ struct netns_sctp {
 	struct list_head addr_waitq;
 	struct timer_list addr_wq_timer;
 	struct list_head auto_asconf_splist;
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
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f09de7fac2e6acddad8b2e046dbf626e329cb674..9af02e777944552f3035ce499a929766119c0e9f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1528,7 +1528,10 @@ static void sctp_close(struct sock *sk, long timeout)
 
 	/* Supposedly, no process has access to the socket, but
 	 * the net layers still may.
+	 * Also, sctp_destroy_sock() needs to be called with addr_wq_lock
+	 * held and that should be grabbed before socket lock.
 	 */
+	spin_lock_bh(&net->sctp.addr_wq_lock);
 	local_bh_disable();
 	bh_lock_sock(sk);
 
@@ -1540,6 +1543,7 @@ static void sctp_close(struct sock *sk, long timeout)
 
 	bh_unlock_sock(sk);
 	local_bh_enable();
+	spin_unlock_bh(&net->sctp.addr_wq_lock);
 
 	sock_put(sk);
 
@@ -3580,6 +3584,7 @@ static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
 	if ((val && sp->do_auto_asconf) || (!val && !sp->do_auto_asconf))
 		return 0;
 
+	spin_lock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 	if (val == 0 && sp->do_auto_asconf) {
 		list_del(&sp->auto_asconf_list);
 		sp->do_auto_asconf = 0;
@@ -3588,6 +3593,7 @@ static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
 		    &sock_net(sk)->sctp.auto_asconf_splist);
 		sp->do_auto_asconf = 1;
 	}
+	spin_unlock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 	return 0;
 }
 
@@ -4121,18 +4127,27 @@ static int sctp_init_sock(struct sock *sk)
 	local_bh_disable();
 	percpu_counter_inc(&sctp_sockets_allocated);
 	sock_prot_inuse_add(net, sk->sk_prot, 1);
+
+	/* Nothing can fail after this block, otherwise
+	 * sctp_destroy_sock() will be called without addr_wq_lock held
+	 */
 	if (net->sctp.default_auto_asconf) {
+		spin_lock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 		list_add_tail(&sp->auto_asconf_list,
 		    &net->sctp.auto_asconf_splist);
 		sp->do_auto_asconf = 1;
+		spin_unlock_bh(&sock_net(sk)->sctp.addr_wq_lock);
 	} else
 		sp->do_auto_asconf = 0;
+
 	local_bh_enable();
 
 	return 0;
 }
 
-/* Cleanup any SCTP per socket resources.  */
+/* Cleanup any SCTP per socket resources. Must be called with
+ * sock_net(sk)->sctp.addr_wq_lock held if sp->do_auto_asconf is true
+ */
 static void sctp_destroy_sock(struct sock *sk)
 {
 	struct sctp_sock *sp;
@@ -7195,6 +7210,19 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
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
@@ -7209,7 +7237,6 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	struct sk_buff *skb, *tmp;
 	struct sctp_ulpevent *event;
 	struct sctp_bind_hashbucket *head;
-	struct list_head tmplist;
 
 	/* Migrate socket buffer sizes and all the socket level options to the
 	 * new socket.
@@ -7217,12 +7244,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
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
