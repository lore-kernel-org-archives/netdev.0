From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 3/3] RDS: Use spinlock to protect 64b value update on 32b archs
Date: Wed,  1 Apr 2009 11:20:20 -0700
Message-ID: <1238610020-30361-4-git-send-email-andy.grover@oracle.com>
References: <1238610020-30361-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:56052 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760184AbZDASUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 14:20:44 -0400
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n31IKSTX028714
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 1 Apr 2009 18:20:30 GMT
In-Reply-To: <1238610020-30361-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a 64bit value that needs to be set atomically.
This is easy and quick on all 64bit archs, and can also be done
on x86/32 with set_64bit() (uses cmpxchg8b). However other
32b archs don't have this.

I actually changed this to the current state in preparation for
mainline because the old way (using a spinlock on 32b) resulted in
unsightly #ifdefs in the code. But obviously, being correct takes
precedence.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.h      |   14 +++++---------
 net/rds/ib_cm.c   |    9 ++++++++-
 net/rds/ib_recv.c |   37 +++++++++++++++++++++++++++++++++++--
 net/rds/iw.h      |   14 +++++---------
 net/rds/iw_cm.c   |    9 ++++++++-
 net/rds/iw_recv.c |   37 +++++++++++++++++++++++++++++++++++--
 net/rds/rds.h     |    4 ++++
 7 files changed, 100 insertions(+), 24 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index c08ffff..069206c 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -108,7 +108,12 @@ struct rds_ib_connection {
 
 	/* sending acks */
 	unsigned long		i_ack_flags;
+#ifdef KERNEL_HAS_ATOMIC64
+	atomic64_t		i_ack_next;	/* next ACK to send */
+#else
+	spinlock_t		i_ack_lock;	/* protect i_ack_next */
 	u64			i_ack_next;	/* next ACK to send */
+#endif
 	struct rds_header	*i_ack;
 	struct ib_send_wr	i_ack_wr;
 	struct ib_sge		i_ack_sge;
@@ -363,13 +368,4 @@ rds_ib_data_sge(struct rds_ib_connection *ic, struct ib_sge *sge)
 	return &sge[1];
 }
 
-static inline void rds_ib_set_64bit(u64 *ptr, u64 val)
-{
-#if BITS_PER_LONG == 64
-	*ptr = val;
-#else
-	set_64bit(ptr, val);
-#endif
-}
-
 #endif
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 889ab04..f8e40e1 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -636,7 +636,11 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 
 	/* Clear the ACK state */
 	clear_bit(IB_ACK_IN_FLIGHT, &ic->i_ack_flags);
-	rds_ib_set_64bit(&ic->i_ack_next, 0);
+#ifdef KERNEL_HAS_ATOMIC64
+	atomic64_set(&ic->i_ack_next, 0);
+#else
+	ic->i_ack_next = 0;
+#endif
 	ic->i_ack_recv = 0;
 
 	/* Clear flow control state */
@@ -669,6 +673,9 @@ int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 
 	INIT_LIST_HEAD(&ic->ib_node);
 	mutex_init(&ic->i_recv_mutex);
+#ifndef KERNEL_HAS_ATOMIC64
+	spin_lock_init(&ic->i_ack_lock);
+#endif
 
 	/*
 	 * rds_ib_conn_shutdown() waits for these to be emptied so they
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 5061b55..36d9315 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -395,10 +395,37 @@ void rds_ib_recv_init_ack(struct rds_ib_connection *ic)
  * room for it beyond the ring size.  Send completion notices its special
  * wr_id and avoids working with the ring in that case.
  */
+#ifndef KERNEL_HAS_ATOMIC64
 static void rds_ib_set_ack(struct rds_ib_connection *ic, u64 seq,
 				int ack_required)
 {
-	rds_ib_set_64bit(&ic->i_ack_next, seq);
+	unsigned long flags;
+
+	spin_lock_irqsave(&ic->i_ack_lock, flags);
+	ic->i_ack_next = seq;
+	if (ack_required)
+		set_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
+	spin_unlock_irqrestore(&ic->i_ack_lock, flags);
+}
+
+static u64 rds_ib_get_ack(struct rds_ib_connection *ic)
+{
+	unsigned long flags;
+	u64 seq;
+
+	clear_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
+
+	spin_lock_irqsave(&ic->i_ack_lock, flags);
+	seq = ic->i_ack_next;
+	spin_unlock_irqrestore(&ic->i_ack_lock, flags);
+
+	return seq;
+}
+#else
+static void rds_ib_set_ack(struct rds_ib_connection *ic, u64 seq,
+				int ack_required)
+{
+	atomic64_set(&ic->i_ack_next, seq);
 	if (ack_required) {
 		smp_mb__before_clear_bit();
 		set_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
@@ -410,8 +437,10 @@ static u64 rds_ib_get_ack(struct rds_ib_connection *ic)
 	clear_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
 	smp_mb__after_clear_bit();
 
-	return ic->i_ack_next;
+	return atomic64_read(&ic->i_ack_next);
 }
+#endif
+
 
 static void rds_ib_send_ack(struct rds_ib_connection *ic, unsigned int adv_credits)
 {
@@ -464,6 +493,10 @@ static void rds_ib_send_ack(struct rds_ib_connection *ic, unsigned int adv_credi
  *  -	i_ack_next, which is the last sequence number we received
  *
  * Potentially, send queue and receive queue handlers can run concurrently.
+ * It would be nice to not have to use a spinlock to synchronize things,
+ * but the one problem that rules this out is that 64bit updates are
+ * not atomic on all platforms. Things would be a lot simpler if
+ * we had atomic64 or maybe cmpxchg64 everywhere.
  *
  * Reconnecting complicates this picture just slightly. When we
  * reconnect, we may be seeing duplicate packets. The peer
diff --git a/net/rds/iw.h b/net/rds/iw.h
index 70eb948..b4fb272 100644
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -131,7 +131,12 @@ struct rds_iw_connection {
 
 	/* sending acks */
 	unsigned long		i_ack_flags;
+#ifdef KERNEL_HAS_ATOMIC64
+	atomic64_t		i_ack_next;	/* next ACK to send */
+#else
+	spinlock_t		i_ack_lock;	/* protect i_ack_next */
 	u64			i_ack_next;	/* next ACK to send */
+#endif
 	struct rds_header	*i_ack;
 	struct ib_send_wr	i_ack_wr;
 	struct ib_sge		i_ack_sge;
@@ -391,13 +396,4 @@ rds_iw_data_sge(struct rds_iw_connection *ic, struct ib_sge *sge)
 	return &sge[1];
 }
 
-static inline void rds_iw_set_64bit(u64 *ptr, u64 val)
-{
-#if BITS_PER_LONG == 64
-	*ptr = val;
-#else
-	set_64bit(ptr, val);
-#endif
-}
-
 #endif
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 0ffaa3e..a416b0d 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -659,7 +659,11 @@ void rds_iw_conn_shutdown(struct rds_connection *conn)
 
 	/* Clear the ACK state */
 	clear_bit(IB_ACK_IN_FLIGHT, &ic->i_ack_flags);
-	rds_iw_set_64bit(&ic->i_ack_next, 0);
+#ifdef KERNEL_HAS_ATOMIC64
+	atomic64_set(&ic->i_ack_next, 0);
+#else
+	ic->i_ack_next = 0;
+#endif
 	ic->i_ack_recv = 0;
 
 	/* Clear flow control state */
@@ -693,6 +697,9 @@ int rds_iw_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 
 	INIT_LIST_HEAD(&ic->iw_node);
 	mutex_init(&ic->i_recv_mutex);
+#ifndef KERNEL_HAS_ATOMIC64
+	spin_lock_init(&ic->i_ack_lock);
+#endif
 
 	/*
 	 * rds_iw_conn_shutdown() waits for these to be emptied so they
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index a1931f0..fde470f 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -395,10 +395,37 @@ void rds_iw_recv_init_ack(struct rds_iw_connection *ic)
  * room for it beyond the ring size.  Send completion notices its special
  * wr_id and avoids working with the ring in that case.
  */
+#ifndef KERNEL_HAS_ATOMIC64
 static void rds_iw_set_ack(struct rds_iw_connection *ic, u64 seq,
 				int ack_required)
 {
-	rds_iw_set_64bit(&ic->i_ack_next, seq);
+	unsigned long flags;
+
+	spin_lock_irqsave(&ic->i_ack_lock, flags);
+	ic->i_ack_next = seq;
+	if (ack_required)
+		set_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
+	spin_unlock_irqrestore(&ic->i_ack_lock, flags);
+}
+
+static u64 rds_iw_get_ack(struct rds_iw_connection *ic)
+{
+	unsigned long flags;
+	u64 seq;
+
+	clear_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
+
+	spin_lock_irqsave(&ic->i_ack_lock, flags);
+	seq = ic->i_ack_next;
+	spin_unlock_irqrestore(&ic->i_ack_lock, flags);
+
+	return seq;
+}
+#else
+static void rds_iw_set_ack(struct rds_iw_connection *ic, u64 seq,
+				int ack_required)
+{
+	atomic64_set(&ic->i_ack_next, seq);
 	if (ack_required) {
 		smp_mb__before_clear_bit();
 		set_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
@@ -410,8 +437,10 @@ static u64 rds_iw_get_ack(struct rds_iw_connection *ic)
 	clear_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
 	smp_mb__after_clear_bit();
 
-	return ic->i_ack_next;
+	return atomic64_read(&ic->i_ack_next);
 }
+#endif
+
 
 static void rds_iw_send_ack(struct rds_iw_connection *ic, unsigned int adv_credits)
 {
@@ -464,6 +493,10 @@ static void rds_iw_send_ack(struct rds_iw_connection *ic, unsigned int adv_credi
  *  -	i_ack_next, which is the last sequence number we received
  *
  * Potentially, send queue and receive queue handlers can run concurrently.
+ * It would be nice to not have to use a spinlock to synchronize things,
+ * but the one problem that rules this out is that 64bit updates are
+ * not atomic on all platforms. Things would be a lot simpler if
+ * we had atomic64 or maybe cmpxchg64 everywhere.
  *
  * Reconnecting complicates this picture just slightly. When we
  * reconnect, we may be seeing duplicate packets. The peer
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 0604007..619f0a3 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -28,6 +28,10 @@
  */
 #define RDS_PORT	18634
 
+#ifdef ATOMIC64_INIT
+#define KERNEL_HAS_ATOMIC64
+#endif
+
 #ifdef DEBUG
 #define rdsdebug(fmt, args...) pr_debug("%s(): " fmt, __func__ , ##args)
 #else
-- 
1.5.6.3

