From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH v2 6/8] net: Commonize busy polling code to focus
 on napi_id instead of socket
Date: Thu, 23 Mar 2017 14:37:49 -0700
Message-ID: <20170323213749.12615.38165.stgit@localhost.localdomain>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36814 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754335AbdCWViG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 17:38:06 -0400
In-Reply-To: <20170323211820.12615.88907.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Move the core functionality in sk_busy_loop() to napi_busy_loop() and
make it independent of sk.

This enables re-using this function in epoll busy loop implementation.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/net/busy_poll.h |   20 +++++++++++++++-----
 net/core/dev.c          |   21 ++++++++-------------
 net/core/sock.c         |   11 +++++++++++
 3 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 4626cb22f625..336a874c0fed 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -61,7 +61,11 @@ static inline bool sk_can_busy_loop(const struct sock *sk)
 	return sk->sk_ll_usec && !signal_pending(current);
 }
 
-void sk_busy_loop(struct sock *sk, int nonblock);
+bool sk_busy_loop_end(void *p, unsigned long start_time);
+
+void napi_busy_loop(unsigned int napi_id,
+		    bool (*loop_end)(void *, unsigned long),
+		    void *loop_end_arg);
 
 #else /* CONFIG_NET_RX_BUSY_POLL */
 static inline unsigned long net_busy_loop_on(void)
@@ -74,10 +78,6 @@ static inline bool sk_can_busy_loop(struct sock *sk)
 	return false;
 }
 
-static inline void sk_busy_loop(struct sock *sk, int nonblock)
-{
-}
-
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
 static inline unsigned long busy_loop_current_time(void)
@@ -121,6 +121,16 @@ static inline bool sk_busy_loop_timeout(struct sock *sk,
 	return true;
 }
 
+static inline void sk_busy_loop(struct sock *sk, int nonblock)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	unsigned int napi_id = READ_ONCE(sk->sk_napi_id);
+
+	if (napi_id >= MIN_NAPI_ID)
+		napi_busy_loop(napi_id, nonblock ? NULL : sk_busy_loop_end, sk);
+#endif
+}
+
 /* used in the NIC receive handler to mark the skb */
 static inline void skb_mark_napi_id(struct sk_buff *skb,
 				    struct napi_struct *napi)
diff --git a/net/core/dev.c b/net/core/dev.c
index 73ebf2f5600e..b082f70e50c5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5060,20 +5060,17 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 		do_softirq();
 }
 
-void sk_busy_loop(struct sock *sk, int nonblock)
+void napi_busy_loop(unsigned int napi_id,
+		    bool (*loop_end)(void *, unsigned long),
+		    void *loop_end_arg)
 {
-	unsigned long start_time = nonblock ? 0 : busy_loop_current_time();
+	unsigned long start_time = loop_end ? busy_loop_current_time() : 0;
 	int (*napi_poll)(struct napi_struct *napi, int budget);
 	void *have_poll_lock = NULL;
 	struct napi_struct *napi;
-	unsigned int napi_id;
 	int work;
 
 restart:
-	napi_id = READ_ONCE(sk->sk_napi_id);
-	if (napi_id < MIN_NAPI_ID)
-		return;
-
 	work = 0;
 	napi_poll = NULL;
 
@@ -5107,12 +5104,11 @@ void sk_busy_loop(struct sock *sk, int nonblock)
 		trace_napi_poll(napi, work, BUSY_POLL_BUDGET);
 count:
 		if (work > 0)
-			__NET_ADD_STATS(sock_net(sk),
+			__NET_ADD_STATS(dev_net(napi->dev),
 					LINUX_MIB_BUSYPOLLRXPACKETS, work);
 		local_bh_enable();
 
-		if (nonblock || !skb_queue_empty(&sk->sk_receive_queue) ||
-		    sk_busy_loop_timeout(sk, start_time))
+		if (!loop_end || loop_end(loop_end_arg, start_time))
 			break;
 
 		if (unlikely(need_resched())) {
@@ -5121,8 +5117,7 @@ void sk_busy_loop(struct sock *sk, int nonblock)
 			preempt_enable();
 			rcu_read_unlock();
 			cond_resched();
-			if (!skb_queue_empty(&sk->sk_receive_queue) ||
-			    sk_busy_loop_timeout(sk, start_time))
+			if (loop_end(loop_end_arg, start_time))
 				return;
 			goto restart;
 		}
@@ -5134,7 +5129,7 @@ void sk_busy_loop(struct sock *sk, int nonblock)
 out:
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL(sk_busy_loop);
+EXPORT_SYMBOL(napi_busy_loop);
 
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
diff --git a/net/core/sock.c b/net/core/sock.c
index f8c0373a3a74..0aa725cb3dd6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3231,3 +3231,14 @@ static int __init proto_init(void)
 subsys_initcall(proto_init);
 
 #endif /* PROC_FS */
+
+#ifdef CONFIG_NET_RX_BUSY_POLL
+bool sk_busy_loop_end(void *p, unsigned long start_time)
+{
+	struct sock *sk = p;
+
+	return !skb_queue_empty(&sk->sk_receive_queue) ||
+	       sk_busy_loop_timeout(sk, start_time);
+}
+EXPORT_SYMBOL(sk_busy_loop_end);
+#endif /* CONFIG_NET_RX_BUSY_POLL */
