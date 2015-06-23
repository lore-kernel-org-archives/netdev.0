From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: use atomic_t instead of spin_lock in busy poll
Date: Tue, 23 Jun 2015 21:47:50 +0530
Message-ID: <1435076270-14166-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:60520 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933182AbbFWQSI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 12:18:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use spinlock to access a single flag. We can achieve this by using atomic
variable and atomic_cmpxchg to set the flag (idle to poll) and a simple atomic
set to unlock (poll to idle).

Also flush gro before unlocking napi poll, to prevent ooo packets when busy poll
sockets are called.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |  4 +-
 drivers/net/ethernet/cisco/enic/vnic_rq.h   | 91 +++++++++--------------------
 2 files changed, 29 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index eadae1b..da2004e 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1208,7 +1208,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[intr]);
 	}
-	enic_poll_unlock_napi(&enic->rq[cq_rq]);
+	enic_poll_unlock_napi(&enic->rq[cq_rq], napi);
 
 	return rq_work_done;
 }
@@ -1414,7 +1414,7 @@ static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 		 */
 		enic_calc_int_moderation(enic, &enic->rq[rq]);
 
-	enic_poll_unlock_napi(&enic->rq[rq]);
+	enic_poll_unlock_napi(&enic->rq[rq], napi);
 	if (work_done < work_to_do) {
 
 		/* Some work done, but not enough to stay in polling,
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.h b/drivers/net/ethernet/cisco/enic/vnic_rq.h
index 8111d52..b9c82f1 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.h
@@ -21,6 +21,7 @@
 #define _VNIC_RQ_H_
 
 #include <linux/pci.h>
+#include <linux/netdevice.h>
 
 #include "vnic_dev.h"
 #include "vnic_cq.h"
@@ -75,6 +76,12 @@ struct vnic_rq_buf {
 	uint64_t wr_id;
 };
 
+enum enic_poll_state {
+	ENIC_POLL_STATE_IDLE,
+	ENIC_POLL_STATE_NAPI,
+	ENIC_POLL_STATE_POLL
+};
+
 struct vnic_rq {
 	unsigned int index;
 	struct vnic_dev *vdev;
@@ -86,19 +93,7 @@ struct vnic_rq {
 	void *os_buf_head;
 	unsigned int pkts_outstanding;
 #ifdef CONFIG_NET_RX_BUSY_POLL
-#define ENIC_POLL_STATE_IDLE		0
-#define ENIC_POLL_STATE_NAPI		(1 << 0) /* NAPI owns this poll */
-#define ENIC_POLL_STATE_POLL		(1 << 1) /* poll owns this poll */
-#define ENIC_POLL_STATE_NAPI_YIELD	(1 << 2) /* NAPI yielded this poll */
-#define ENIC_POLL_STATE_POLL_YIELD	(1 << 3) /* poll yielded this poll */
-#define ENIC_POLL_YIELD			(ENIC_POLL_STATE_NAPI_YIELD |	\
-					 ENIC_POLL_STATE_POLL_YIELD)
-#define ENIC_POLL_LOCKED		(ENIC_POLL_STATE_NAPI |		\
-					 ENIC_POLL_STATE_POLL)
-#define ENIC_POLL_USER_PEND		(ENIC_POLL_STATE_POLL |		\
-					 ENIC_POLL_STATE_POLL_YIELD)
-	unsigned int bpoll_state;
-	spinlock_t bpoll_lock;
+	atomic_t bpoll_state;
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 };
 
@@ -215,76 +210,43 @@ static inline int vnic_rq_fill(struct vnic_rq *rq,
 #ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void enic_busy_poll_init_lock(struct vnic_rq *rq)
 {
-	spin_lock_init(&rq->bpoll_lock);
-	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
+	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
 }
 
 static inline bool enic_poll_lock_napi(struct vnic_rq *rq)
 {
-	bool rc = true;
-
-	spin_lock(&rq->bpoll_lock);
-	if (rq->bpoll_state & ENIC_POLL_LOCKED) {
-		WARN_ON(rq->bpoll_state & ENIC_POLL_STATE_NAPI);
-		rq->bpoll_state |= ENIC_POLL_STATE_NAPI_YIELD;
-		rc = false;
-	} else {
-		rq->bpoll_state = ENIC_POLL_STATE_NAPI;
-	}
-	spin_unlock(&rq->bpoll_lock);
+	int rc = atomic_cmpxchg(&rq->bpoll_state, ENIC_POLL_STATE_IDLE,
+				ENIC_POLL_STATE_NAPI);
 
-	return rc;
+	return (rc == ENIC_POLL_STATE_IDLE);
 }
 
-static inline bool enic_poll_unlock_napi(struct vnic_rq *rq)
+static inline void enic_poll_unlock_napi(struct vnic_rq *rq,
+					 struct napi_struct *napi)
 {
-	bool rc = false;
-
-	spin_lock(&rq->bpoll_lock);
-	WARN_ON(rq->bpoll_state &
-		(ENIC_POLL_STATE_POLL | ENIC_POLL_STATE_NAPI_YIELD));
-	if (rq->bpoll_state & ENIC_POLL_STATE_POLL_YIELD)
-		rc = true;
-	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
-	spin_unlock(&rq->bpoll_lock);
-
-	return rc;
+	WARN_ON(atomic_read(&rq->bpoll_state) != ENIC_POLL_STATE_NAPI);
+	napi_gro_flush(napi, false);
+	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
 }
 
 static inline bool enic_poll_lock_poll(struct vnic_rq *rq)
 {
-	bool rc = true;
-
-	spin_lock_bh(&rq->bpoll_lock);
-	if (rq->bpoll_state & ENIC_POLL_LOCKED) {
-		rq->bpoll_state |= ENIC_POLL_STATE_POLL_YIELD;
-		rc = false;
-	} else {
-		rq->bpoll_state |= ENIC_POLL_STATE_POLL;
-	}
-	spin_unlock_bh(&rq->bpoll_lock);
+	int rc = atomic_cmpxchg(&rq->bpoll_state, ENIC_POLL_STATE_IDLE,
+				ENIC_POLL_STATE_POLL);
 
-	return rc;
+	return (rc == ENIC_POLL_STATE_IDLE);
 }
 
-static inline bool enic_poll_unlock_poll(struct vnic_rq *rq)
-{
-	bool rc = false;
 
-	spin_lock_bh(&rq->bpoll_lock);
-	WARN_ON(rq->bpoll_state & ENIC_POLL_STATE_NAPI);
-	if (rq->bpoll_state & ENIC_POLL_STATE_POLL_YIELD)
-		rc = true;
-	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
-	spin_unlock_bh(&rq->bpoll_lock);
-
-	return rc;
+static inline void enic_poll_unlock_poll(struct vnic_rq *rq)
+{
+	WARN_ON(atomic_read(&rq->bpoll_state) != ENIC_POLL_STATE_POLL);
+	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
 }
 
 static inline bool enic_poll_busy_polling(struct vnic_rq *rq)
 {
-	WARN_ON(!(rq->bpoll_state & ENIC_POLL_LOCKED));
-	return rq->bpoll_state & ENIC_POLL_USER_PEND;
+	return atomic_read(&rq->bpoll_state) & ENIC_POLL_STATE_POLL;
 }
 
 #else
@@ -298,7 +260,8 @@ static inline bool enic_poll_lock_napi(struct vnic_rq *rq)
 	return true;
 }
 
-static inline bool enic_poll_unlock_napi(struct vnic_rq *rq)
+static inline bool enic_poll_unlock_napi(struct vnic_rq *rq,
+					 struct napi_struct *napi)
 {
 	return false;
 }
-- 
2.4.4
