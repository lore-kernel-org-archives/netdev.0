From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 4/6] net: core: factor out core busy polling logic to sk_busy_loop_once()
Date: Thu, 31 Mar 2016 13:50:37 +0800
Message-ID: <1459403439-6011-5-git-send-email-jasowang@redhat.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch factors out core logic of busy polling to
sk_busy_loop_once() in order to be reused by other modules.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/net/busy_poll.h |  7 ++++++
 net/core/dev.c          | 59 ++++++++++++++++++++++++++++---------------------
 2 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 2fbeb13..e765e23 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -73,6 +73,7 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 }
 
 bool sk_busy_loop(struct sock *sk, int nonblock);
+int sk_busy_loop_once(struct sock *sk, struct napi_struct *napi);
 
 /* used in the NIC receive handler to mark the skb */
 static inline void skb_mark_napi_id(struct sk_buff *skb,
@@ -117,6 +118,12 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 	return true;
 }
 
+static inline int sk_busy_loop_once(struct napi_struct *napi,
+				    int (*busy_poll)(struct napi_struct *dev))
+{
+	return 0;
+}
+
 static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 {
 	return false;
diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe7..a2f0c46 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4902,10 +4902,42 @@ static struct napi_struct *napi_by_id(unsigned int napi_id)
 
 #if defined(CONFIG_NET_RX_BUSY_POLL)
 #define BUSY_POLL_BUDGET 8
+int sk_busy_loop_once(struct sock *sk, struct napi_struct *napi)
+{
+	int (*busy_poll)(struct napi_struct *dev);
+	int rc = 0;
+
+	/* Note: ndo_busy_poll method is optional in linux-4.5 */
+	busy_poll = napi->dev->netdev_ops->ndo_busy_poll;
+
+	local_bh_disable();
+	if (busy_poll) {
+		rc = busy_poll(napi);
+	} else if (napi_schedule_prep(napi)) {
+		void *have = netpoll_poll_lock(napi);
+
+		if (test_bit(NAPI_STATE_SCHED, &napi->state)) {
+			rc = napi->poll(napi, BUSY_POLL_BUDGET);
+			trace_napi_poll(napi);
+			if (rc == BUSY_POLL_BUDGET) {
+				napi_complete_done(napi, rc);
+				napi_schedule(napi);
+			}
+		}
+		netpoll_poll_unlock(have);
+	}
+	if (rc > 0)
+		NET_ADD_STATS_BH(sock_net(sk),
+				 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
+	local_bh_enable();
+
+	return rc;
+}
+EXPORT_SYMBOL(sk_busy_loop_once);
+
 bool sk_busy_loop(struct sock *sk, int nonblock)
 {
 	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
-	int (*busy_poll)(struct napi_struct *dev);
 	struct napi_struct *napi;
 	int rc = false;
 
@@ -4915,31 +4947,8 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 	if (!napi)
 		goto out;
 
-	/* Note: ndo_busy_poll method is optional in linux-4.5 */
-	busy_poll = napi->dev->netdev_ops->ndo_busy_poll;
-
 	do {
-		rc = 0;
-		local_bh_disable();
-		if (busy_poll) {
-			rc = busy_poll(napi);
-		} else if (napi_schedule_prep(napi)) {
-			void *have = netpoll_poll_lock(napi);
-
-			if (test_bit(NAPI_STATE_SCHED, &napi->state)) {
-				rc = napi->poll(napi, BUSY_POLL_BUDGET);
-				trace_napi_poll(napi);
-				if (rc == BUSY_POLL_BUDGET) {
-					napi_complete_done(napi, rc);
-					napi_schedule(napi);
-				}
-			}
-			netpoll_poll_unlock(have);
-		}
-		if (rc > 0)
-			NET_ADD_STATS_BH(sock_net(sk),
-					 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
-		local_bh_enable();
+		rc = sk_busy_loop_once(sk, napi);
 
 		if (rc == LL_FLUSH_FAILED)
 			break; /* permanent failure */
-- 
2.5.0
