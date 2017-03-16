From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 4/5] net: Commonize busy polling code to focus on
 napi_id instead of socket
Date: Thu, 16 Mar 2017 11:32:56 -0700
Message-ID: <20170316183256.15806.38680.stgit@localhost.localdomain>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316183142.15806.38824.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Move the core functionality in sk_busy_loop() to napi_busy_loop() and
make it independent of sk.

This enables re-using this function in epoll busy loop implementation.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/net/busy_poll.h |    9 +++++++++
 net/core/dev.c          |   16 ++++++++--------
 net/core/sock.c         |   18 ++++++++++++++++++
 3 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 67991635953e..24bc10d56b49 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -71,6 +71,9 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 
 bool sk_busy_loop(struct sock *sk, int nonblock);
 
+bool napi_busy_loop(unsigned int napi_id, unsigned long end_time, int nonblock,
+		    bool (*loop_end)(void *), void *loop_end_arg);
+
 /* used in the NIC receive handler to mark the skb */
 static inline void skb_mark_napi_id(struct sk_buff *skb,
 				    struct napi_struct *napi)
@@ -110,6 +113,12 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 	return false;
 }
 
+static inline bool napi_busy_loop(unsigned int napi_id, unsigned long end_time,
+				  int nonblock, bool (*loop_end)(void *),
+				  void *loop_end_arg)
+{
+	return false;
+}
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
 /* used in the protocol hanlder to propagate the napi_id to the socket */
diff --git a/net/core/dev.c b/net/core/dev.c
index 7869ae3837ca..4e55765c6998 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5060,9 +5060,9 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 		do_softirq();
 }
 
-bool sk_busy_loop(struct sock *sk, int nonblock)
+bool napi_busy_loop(unsigned int napi_id, unsigned long end_time, int nonblock,
+		    bool (*loop_end)(void *), void *loop_end_arg)
 {
-	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
 	int (*napi_poll)(struct napi_struct *napi, int budget);
 	void *have_poll_lock = NULL;
 	struct napi_struct *napi;
@@ -5074,7 +5074,7 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 
 	rcu_read_lock();
 
-	napi = napi_by_id(sk->sk_napi_id);
+	napi = napi_by_id(napi_id);
 	if (!napi)
 		goto out;
 
@@ -5102,11 +5102,11 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 		trace_napi_poll(napi, rc, BUSY_POLL_BUDGET);
 count:
 		if (rc > 0)
-			__NET_ADD_STATS(sock_net(sk),
+			__NET_ADD_STATS(dev_net(napi->dev),
 					LINUX_MIB_BUSYPOLLRXPACKETS, rc);
 		local_bh_enable();
 
-		if (nonblock || !skb_queue_empty(&sk->sk_receive_queue) ||
+		if (nonblock || loop_end(loop_end_arg) ||
 		    busy_loop_timeout(end_time))
 			break;
 
@@ -5116,7 +5116,7 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 			preempt_enable();
 			rcu_read_unlock();
 			cond_resched();
-			rc = !skb_queue_empty(&sk->sk_receive_queue);
+			rc = loop_end(loop_end_arg);
 			if (rc || busy_loop_timeout(end_time))
 				return rc;
 			goto restart;
@@ -5126,12 +5126,12 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 	if (napi_poll)
 		busy_poll_stop(napi, have_poll_lock);
 	preempt_enable();
-	rc = !skb_queue_empty(&sk->sk_receive_queue);
+	rc = loop_end(loop_end_arg);
 out:
 	rcu_read_unlock();
 	return rc;
 }
-EXPORT_SYMBOL(sk_busy_loop);
+EXPORT_SYMBOL(napi_busy_loop);
 
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 74288b2d4b3d..f606d89f044a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3205,3 +3205,21 @@ static int __init proto_init(void)
 subsys_initcall(proto_init);
 
 #endif /* PROC_FS */
+
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static bool sk_napi_busy_loop_end(void *p)
+{
+	struct sock *sk = p;
+
+	return !skb_queue_empty(&sk->sk_receive_queue);
+}
+
+bool sk_busy_loop(struct sock *sk, int nonblock)
+{
+	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
+
+	return napi_busy_loop(sk->sk_napi_id, end_time, nonblock,
+			      sk_napi_busy_loop_end, sk);
+}
+EXPORT_SYMBOL(sk_busy_loop);
+#endif /* CONFIG_NET_RX_BUSY_POLL */
