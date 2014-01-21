From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 7/7] sctp: remove macros sctp_bh_[un]lock_sock
Date: Tue, 21 Jan 2014 15:44:12 +0800
Message-ID: <1390290252-16080-8-git-send-email-wangweidong1@huawei.com>
References: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:30579 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaAUHuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:50:24 -0500
In-Reply-To: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefined bh_[un]lock_sock to sctp_bh[un]lock_sock for user
space friendly code which we haven't use in years, so removing them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/sctp.h  |  4 ----
 net/sctp/input.c         | 18 +++++++++---------
 net/sctp/protocol.c      |  4 ++--
 net/sctp/sm_sideeffect.c | 16 ++++++++--------
 net/sctp/socket.c        |  4 ++--
 5 files changed, 21 insertions(+), 25 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ec18d30..a3353f4 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -170,10 +170,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  *  Section:  Macros, externs, and inlines
  */
 
-/* sock lock wrappers. */
-#define sctp_bh_lock_sock(sk)    bh_lock_sock(sk)
-#define sctp_bh_unlock_sock(sk)  bh_unlock_sock(sk)
-
 /* SCTP SNMP MIB stats handlers */
 #define SCTP_INC_STATS(net, field)      SNMP_INC_STATS((net)->sctp.sctp_statistics, field)
 #define SCTP_INC_STATS_BH(net, field)   SNMP_INC_STATS_BH((net)->sctp.sctp_statistics, field)
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 94f7f440..f2e2cbd 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -238,7 +238,7 @@ int sctp_rcv(struct sk_buff *skb)
 	 * bottom halves on this lock, but a user may be in the lock too,
 	 * so check if it is busy.
 	 */
-	sctp_bh_lock_sock(sk);
+	bh_lock_sock(sk);
 
 	if (sk != rcvr->sk) {
 		/* Our cached sk is different from the rcvr->sk.  This is
@@ -248,14 +248,14 @@ int sctp_rcv(struct sk_buff *skb)
 		 * be doing something with the new socket.  Switch our veiw
 		 * of the current sk.
 		 */
-		sctp_bh_unlock_sock(sk);
+		bh_unlock_sock(sk);
 		sk = rcvr->sk;
-		sctp_bh_lock_sock(sk);
+		bh_lock_sock(sk);
 	}
 
 	if (sock_owned_by_user(sk)) {
 		if (sctp_add_backlog(sk, skb)) {
-			sctp_bh_unlock_sock(sk);
+			bh_unlock_sock(sk);
 			sctp_chunk_free(chunk);
 			skb = NULL; /* sctp_chunk_free already freed the skb */
 			goto discard_release;
@@ -266,7 +266,7 @@ int sctp_rcv(struct sk_buff *skb)
 		sctp_inq_push(&chunk->rcvr->inqueue, chunk);
 	}
 
-	sctp_bh_unlock_sock(sk);
+	bh_unlock_sock(sk);
 
 	/* Release the asoc/ep ref we took in the lookup calls. */
 	if (asoc)
@@ -327,7 +327,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 		 */
 
 		sk = rcvr->sk;
-		sctp_bh_lock_sock(sk);
+		bh_lock_sock(sk);
 
 		if (sock_owned_by_user(sk)) {
 			if (sk_add_backlog(sk, skb, sk->sk_rcvbuf))
@@ -337,7 +337,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 		} else
 			sctp_inq_push(inqueue, chunk);
 
-		sctp_bh_unlock_sock(sk);
+		bh_unlock_sock(sk);
 
 		/* If the chunk was backloged again, don't drop refs */
 		if (backloged)
@@ -522,7 +522,7 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 		goto out;
 	}
 
-	sctp_bh_lock_sock(sk);
+	bh_lock_sock(sk);
 
 	/* If too many ICMPs get dropped on busy
 	 * servers this needs to be solved differently.
@@ -542,7 +542,7 @@ out:
 /* Common cleanup code for icmp/icmpv6 error handler. */
 void sctp_err_finish(struct sock *sk, struct sctp_association *asoc)
 {
-	sctp_bh_unlock_sock(sk);
+	bh_unlock_sock(sk);
 	sctp_association_put(asoc);
 }
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d6934dc..4e1d0fc 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -634,10 +634,10 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
 			/* ignore bound-specific endpoints */
 			if (!sctp_is_ep_boundall(sk))
 				continue;
-			sctp_bh_lock_sock(sk);
+			bh_lock_sock(sk);
 			if (sctp_asconf_mgmt(sp, addrw) < 0)
 				pr_debug("%s: sctp_asconf_mgmt failed\n", __func__);
-			sctp_bh_unlock_sock(sk);
+			bh_unlock_sock(sk);
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 free_next:
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index ded6db6..bd85915 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -248,7 +248,7 @@ void sctp_generate_t3_rtx_event(unsigned long peer)
 
 	/* Check whether a task is in the sock.  */
 
-	sctp_bh_lock_sock(asoc->base.sk);
+	bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
 		pr_debug("%s: sock is busy\n", __func__);
 
@@ -275,7 +275,7 @@ void sctp_generate_t3_rtx_event(unsigned long peer)
 		asoc->base.sk->sk_err = -error;
 
 out_unlock:
-	sctp_bh_unlock_sock(asoc->base.sk);
+	bh_unlock_sock(asoc->base.sk);
 	sctp_transport_put(transport);
 }
 
@@ -288,7 +288,7 @@ static void sctp_generate_timeout_event(struct sctp_association *asoc,
 	struct net *net = sock_net(asoc->base.sk);
 	int error = 0;
 
-	sctp_bh_lock_sock(asoc->base.sk);
+	bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
 		pr_debug("%s: sock is busy: timer %d\n", __func__,
 			 timeout_type);
@@ -315,7 +315,7 @@ static void sctp_generate_timeout_event(struct sctp_association *asoc,
 		asoc->base.sk->sk_err = -error;
 
 out_unlock:
-	sctp_bh_unlock_sock(asoc->base.sk);
+	bh_unlock_sock(asoc->base.sk);
 	sctp_association_put(asoc);
 }
 
@@ -367,7 +367,7 @@ void sctp_generate_heartbeat_event(unsigned long data)
 	struct sctp_association *asoc = transport->asoc;
 	struct net *net = sock_net(asoc->base.sk);
 
-	sctp_bh_lock_sock(asoc->base.sk);
+	bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
 		pr_debug("%s: sock is busy\n", __func__);
 
@@ -392,7 +392,7 @@ void sctp_generate_heartbeat_event(unsigned long data)
 		 asoc->base.sk->sk_err = -error;
 
 out_unlock:
-	sctp_bh_unlock_sock(asoc->base.sk);
+	bh_unlock_sock(asoc->base.sk);
 	sctp_transport_put(transport);
 }
 
@@ -405,7 +405,7 @@ void sctp_generate_proto_unreach_event(unsigned long data)
 	struct sctp_association *asoc = transport->asoc;
 	struct net *net = sock_net(asoc->base.sk);
 
-	sctp_bh_lock_sock(asoc->base.sk);
+	bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
 		pr_debug("%s: sock is busy\n", __func__);
 
@@ -427,7 +427,7 @@ void sctp_generate_proto_unreach_event(unsigned long data)
 		   asoc->state, asoc->ep, asoc, transport, GFP_ATOMIC);
 
 out_unlock:
-	sctp_bh_unlock_sock(asoc->base.sk);
+	bh_unlock_sock(asoc->base.sk);
 	sctp_association_put(asoc);
 }
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 893aa56..9e91d6e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1511,7 +1511,7 @@ static void sctp_close(struct sock *sk, long timeout)
 	 * the net layers still may.
 	 */
 	local_bh_disable();
-	sctp_bh_lock_sock(sk);
+	bh_lock_sock(sk);
 
 	/* Hold the sock, since sk_common_release() will put sock_put()
 	 * and we have just a little more cleanup.
@@ -1519,7 +1519,7 @@ static void sctp_close(struct sock *sk, long timeout)
 	sock_hold(sk);
 	sk_common_release(sk);
 
-	sctp_bh_unlock_sock(sk);
+	bh_unlock_sock(sk);
 	local_bh_enable();
 
 	sock_put(sk);
-- 
1.7.12
