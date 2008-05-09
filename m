From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH next-2.6 1/3] [SCTP]: Bring SCTP_DELAYED_ACK socket option into API compliance
Date: Fri,  9 May 2008 15:16:04 -0400
Message-ID: <1210360566-16661-1-git-send-email-vladislav.yasevich@hp.com>
References: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:12862 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849AbYEITQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 15:16:13 -0400
In-Reply-To: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Brings delayed_ack socket option set/get into line with the latest ietf
socket extensions API draft, while maintaining backwards compatibility.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    4 +
 include/net/sctp/user.h    |   28 ++++--
 net/sctp/associola.c       |    3 +
 net/sctp/sm_sideeffect.c   |   17 +++-
 net/sctp/socket.c          |  242 ++++++++++++++++++++++++++++----------------
 5 files changed, 194 insertions(+), 100 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0ce0443..e111517 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -300,6 +300,7 @@ struct sctp_sock {
 
 	/* The default SACK delay timeout for new associations. */
 	__u32 sackdelay;
+	__u32 sackfreq;
 
 	/* Flags controlling Heartbeat, SACK delay, and Path MTU Discovery. */
 	__u32 param_flags;
@@ -938,6 +939,7 @@ struct sctp_transport {
 
 	/* SACK delay timeout */
 	unsigned long sackdelay;
+	__u32 sackfreq;
 
 	/* When was the last time (in jiffies) that we heard from this
 	 * transport?  We use this to pick new active and retran paths.
@@ -1542,6 +1544,7 @@ struct sctp_association {
 		 *             : SACK's are not delayed (see Section 6).
 		 */
 		__u8    sack_needed;     /* Do we need to sack the peer? */
+		__u32	sack_cnt;
 
 		/* These are capabilities which our peer advertised.  */
 		__u8	ecn_capable;	 /* Can peer do ECN? */
@@ -1651,6 +1654,7 @@ struct sctp_association {
 
 	/* SACK delay timeout */
 	unsigned long sackdelay;
+	__u32 sackfreq;
 
 
 	unsigned long timeouts[SCTP_NUM_TIMEOUT_TYPES];
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 9619b9d..31371d2 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -93,8 +93,9 @@ enum sctp_optname {
 #define SCTP_STATUS SCTP_STATUS
 	SCTP_GET_PEER_ADDR_INFO,
 #define SCTP_GET_PEER_ADDR_INFO SCTP_GET_PEER_ADDR_INFO
-	SCTP_DELAYED_ACK_TIME,
-#define SCTP_DELAYED_ACK_TIME SCTP_DELAYED_ACK_TIME
+	SCTP_DELAYED_ACK,
+#define SCTP_DELAYED_ACK_TIME SCTP_DELAYED_ACK
+#define SCTP_DELAYED_ACK SCTP_DELAYED_ACK
 	SCTP_CONTEXT,	/* Receive Context */
 #define SCTP_CONTEXT SCTP_CONTEXT
 	SCTP_FRAGMENT_INTERLEAVE,
@@ -618,13 +619,26 @@ struct sctp_authkeyid {
 };
 
 
-/* 7.1.23. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
+/*
+ * 7.1.23.  Get or set delayed ack timer (SCTP_DELAYED_SACK)
  *
- *   This options will get or set the delayed ack timer.  The time is set
- *   in milliseconds.  If the assoc_id is 0, then this sets or gets the
- *   endpoints default delayed ack timer value.  If the assoc_id field is
- *   non-zero, then the set or get effects the specified association.
+ * This option will effect the way delayed acks are performed.  This
+ * option allows you to get or set the delayed ack time, in
+ * milliseconds.  It also allows changing the delayed ack frequency.
+ * Changing the frequency to 1 disables the delayed sack algorithm.  If
+ * the assoc_id is 0, then this sets or gets the endpoints default
+ * values.  If the assoc_id field is non-zero, then the set or get
+ * effects the specified association for the one to many model (the
+ * assoc_id field is ignored by the one to one model).  Note that if
+ * sack_delay or sack_freq are 0 when setting this option, then the
+ * current values will remain unchanged.
  */
+struct sctp_sack_info {
+	sctp_assoc_t	sack_assoc_id;
+	uint32_t	sack_delay;
+	uint32_t	sack_freq;
+};
+
 struct sctp_assoc_value {
     sctp_assoc_t            assoc_id;
     uint32_t                assoc_value;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b4cd2b7..7b79d1e 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -136,6 +136,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	/* Set association default SACK delay */
 	asoc->sackdelay = msecs_to_jiffies(sp->sackdelay);
+	asoc->sackfreq = sp->sackfreq;
 
 	/* Set the association default flags controlling
 	 * Heartbeat, SACK delay, and Path MTU Discovery.
@@ -261,6 +262,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	 * already received one packet.]
 	 */
 	asoc->peer.sack_needed = 1;
+	asoc->peer.sack_cnt = 0;
 
 	/* Assume that the peer will tell us if he recognizes ASCONF
 	 * as part of INIT exchange.
@@ -615,6 +617,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	 * association configured value.
 	 */
 	peer->sackdelay = asoc->sackdelay;
+	peer->sackfreq = asoc->sackfreq;
 
 	/* Enable/disable heartbeat, SACK delay, and path MTU discovery
 	 * based on association setting.
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 23a9f1a..b083312 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -190,20 +190,28 @@ static int sctp_gen_sack(struct sctp_association *asoc, int force,
 	 * unacknowledged DATA chunk. ...
 	 */
 	if (!asoc->peer.sack_needed) {
-		/* We will need a SACK for the next packet.  */
-		asoc->peer.sack_needed = 1;
+		asoc->peer.sack_cnt++;
 
 		/* Set the SACK delay timeout based on the
 		 * SACK delay for the last transport
 		 * data was received from, or the default
 		 * for the association.
 		 */
-		if (trans)
+		if (trans) {
+			/* We will need a SACK for the next packet.  */
+			if (asoc->peer.sack_cnt >= trans->sackfreq - 1)
+				asoc->peer.sack_needed = 1;
+
 			asoc->timeouts[SCTP_EVENT_TIMEOUT_SACK] =
 				trans->sackdelay;
-		else
+		} else {
+			/* We will need a SACK for the next packet.  */
+			if (asoc->peer.sack_cnt >= asoc->sackfreq - 1)
+				asoc->peer.sack_needed = 1;
+
 			asoc->timeouts[SCTP_EVENT_TIMEOUT_SACK] =
 				asoc->sackdelay;
+		}
 
 		/* Restart the SACK timer. */
 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
@@ -216,6 +224,7 @@ static int sctp_gen_sack(struct sctp_association *asoc, int force,
 			goto nomem;
 
 		asoc->peer.sack_needed = 0;
+		asoc->peer.sack_cnt = 0;
 
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(sack));
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e7e3baf..6698587 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2305,74 +2305,98 @@ static int sctp_setsockopt_peer_addr_params(struct sock *sk,
 	return 0;
 }
 
-/* 7.1.23. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
- *
- *   This options will get or set the delayed ack timer.  The time is set
- *   in milliseconds.  If the assoc_id is 0, then this sets or gets the
- *   endpoints default delayed ack timer value.  If the assoc_id field is
- *   non-zero, then the set or get effects the specified association.
- *
- *   struct sctp_assoc_value {
- *       sctp_assoc_t            assoc_id;
- *       uint32_t                assoc_value;
- *   };
- *
- *     assoc_id    - This parameter, indicates which association the
- *                   user is preforming an action upon. Note that if
- *                   this field's value is zero then the endpoints
- *                   default value is changed (effecting future
- *                   associations only).
- *
- *     assoc_value - This parameter contains the number of milliseconds
- *                   that the user is requesting the delayed ACK timer
- *                   be set to. Note that this value is defined in
- *                   the standard to be between 200 and 500 milliseconds.
- *
- *                   Note: a value of zero will leave the value alone,
- *                   but disable SACK delay. A non-zero value will also
- *                   enable SACK delay.
+/*
+ * 7.1.23.  Get or set delayed ack timer (SCTP_DELAYED_SACK)
+ *
+ * This option will effect the way delayed acks are performed.  This
+ * option allows you to get or set the delayed ack time, in
+ * milliseconds.  It also allows changing the delayed ack frequency.
+ * Changing the frequency to 1 disables the delayed sack algorithm.  If
+ * the assoc_id is 0, then this sets or gets the endpoints default
+ * values.  If the assoc_id field is non-zero, then the set or get
+ * effects the specified association for the one to many model (the
+ * assoc_id field is ignored by the one to one model).  Note that if
+ * sack_delay or sack_freq are 0 when setting this option, then the
+ * current values will remain unchanged.
+ *
+ * struct sctp_sack_info {
+ *     sctp_assoc_t            sack_assoc_id;
+ *     uint32_t                sack_delay;
+ *     uint32_t                sack_freq;
+ * };
+ *
+ * sack_assoc_id -  This parameter, indicates which association the user
+ *    is performing an action upon.  Note that if this field's value is
+ *    zero then the endpoints default value is changed (effecting future
+ *    associations only).
+ *
+ * sack_delay -  This parameter contains the number of milliseconds that
+ *    the user is requesting the delayed ACK timer be set to.  Note that
+ *    this value is defined in the standard to be between 200 and 500
+ *    milliseconds.
+ *
+ * sack_freq -  This parameter contains the number of packets that must
+ *    be received before a sack is sent without waiting for the delay
+ *    timer to expire.  The default value for this is 2, setting this
+ *    value to 1 will disable the delayed sack algorithm.
  */
 
-static int sctp_setsockopt_delayed_ack_time(struct sock *sk,
+static int sctp_setsockopt_delayed_ack(struct sock *sk,
 					    char __user *optval, int optlen)
 {
-	struct sctp_assoc_value  params;
+	struct sctp_sack_info    params;
 	struct sctp_transport   *trans = NULL;
 	struct sctp_association *asoc = NULL;
 	struct sctp_sock        *sp = sctp_sk(sk);
 
-	if (optlen != sizeof(struct sctp_assoc_value))
-		return - EINVAL;
+	if (optlen == sizeof(struct sctp_sack_info)) {
+		if (copy_from_user(&params, optval, optlen))
+			return -EFAULT;
 
-	if (copy_from_user(&params, optval, optlen))
-		return -EFAULT;
+		if (params.sack_delay == 0 && params.sack_freq == 0)
+			return 0;
+	} else if (optlen == sizeof(struct sctp_assoc_value)) {
+		printk(KERN_WARNING "SCTP: Use of struct sctp_sack_info "
+		       "in delayed_ack socket option deprecated\n");
+		printk(KERN_WARNING "SCTP: struct sctp_sack_info instead\n");
+		if (copy_from_user(&params, optval, optlen))
+			return -EFAULT;
+
+		if (params.sack_delay == 0)
+			params.sack_freq = 1;
+		else
+			params.sack_freq = 0;
+	} else
+		return - EINVAL;
 
 	/* Validate value parameter. */
-	if (params.assoc_value > 500)
+	if (params.sack_delay > 500)
 		return -EINVAL;
 
-	/* Get association, if assoc_id != 0 and the socket is a one
+	/* Get association, if sack_assoc_id != 0 and the socket is a one
 	 * to many style socket, and an association was not found, then
 	 * the id was invalid.
 	 */
-	asoc = sctp_id2assoc(sk, params.assoc_id);
-	if (!asoc && params.assoc_id && sctp_style(sk, UDP))
+	asoc = sctp_id2assoc(sk, params.sack_assoc_id);
+	if (!asoc && params.sack_assoc_id && sctp_style(sk, UDP))
 		return -EINVAL;
 
-	if (params.assoc_value) {
+	if (params.sack_delay) {
 		if (asoc) {
 			asoc->sackdelay =
-				msecs_to_jiffies(params.assoc_value);
+				msecs_to_jiffies(params.sack_delay);
 			asoc->param_flags =
 				(asoc->param_flags & ~SPP_SACKDELAY) |
 				SPP_SACKDELAY_ENABLE;
 		} else {
-			sp->sackdelay = params.assoc_value;
+			sp->sackdelay = params.sack_delay;
 			sp->param_flags =
 				(sp->param_flags & ~SPP_SACKDELAY) |
 				SPP_SACKDELAY_ENABLE;
 		}
-	} else {
+	}
+
+	if (params.sack_freq == 1) {
 		if (asoc) {
 			asoc->param_flags =
 				(asoc->param_flags & ~SPP_SACKDELAY) |
@@ -2382,22 +2406,40 @@ static int sctp_setsockopt_delayed_ack_time(struct sock *sk,
 				(sp->param_flags & ~SPP_SACKDELAY) |
 				SPP_SACKDELAY_DISABLE;
 		}
+	} else if (params.sack_freq > 1) {
+		if (asoc) {
+			asoc->sackfreq = params.sack_freq;
+			asoc->param_flags =
+				(asoc->param_flags & ~SPP_SACKDELAY) |
+				SPP_SACKDELAY_ENABLE;
+		} else {
+			sp->sackfreq = params.sack_freq;
+			sp->param_flags =
+				(sp->param_flags & ~SPP_SACKDELAY) |
+				SPP_SACKDELAY_ENABLE;
+		}
 	}
 
 	/* If change is for association, also apply to each transport. */
 	if (asoc) {
 		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
 				transports) {
-			if (params.assoc_value) {
+			if (params.sack_delay) {
 				trans->sackdelay =
-					msecs_to_jiffies(params.assoc_value);
+					msecs_to_jiffies(params.sack_delay);
 				trans->param_flags =
 					(trans->param_flags & ~SPP_SACKDELAY) |
 					SPP_SACKDELAY_ENABLE;
-			} else {
+			}
+			if (params.sack_delay == 1) {
 				trans->param_flags =
 					(trans->param_flags & ~SPP_SACKDELAY) |
 					SPP_SACKDELAY_DISABLE;
+			} else if (params.sack_freq > 1) {
+				trans->sackfreq = params.sack_freq;
+				trans->param_flags =
+					(trans->param_flags & ~SPP_SACKDELAY) |
+					SPP_SACKDELAY_ENABLE;
 			}
 		}
 	}
@@ -3186,8 +3228,8 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_setsockopt_peer_addr_params(sk, optval, optlen);
 		break;
 
-	case SCTP_DELAYED_ACK_TIME:
-		retval = sctp_setsockopt_delayed_ack_time(sk, optval, optlen);
+	case SCTP_DELAYED_ACK:
+		retval = sctp_setsockopt_delayed_ack(sk, optval, optlen);
 		break;
 	case SCTP_PARTIAL_DELIVERY_POINT:
 		retval = sctp_setsockopt_partial_delivery_point(sk, optval, optlen);
@@ -3446,6 +3488,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->pathmaxrxt  = sctp_max_retrans_path;
 	sp->pathmtu     = 0; // allow default discovery
 	sp->sackdelay   = sctp_sack_timeout;
+	sp->sackfreq	= 3;
 	sp->param_flags = SPP_HB_ENABLE |
 			  SPP_PMTUD_ENABLE |
 			  SPP_SACKDELAY_ENABLE;
@@ -3999,70 +4042,91 @@ static int sctp_getsockopt_peer_addr_params(struct sock *sk, int len,
 	return 0;
 }
 
-/* 7.1.23. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
- *
- *   This options will get or set the delayed ack timer.  The time is set
- *   in milliseconds.  If the assoc_id is 0, then this sets or gets the
- *   endpoints default delayed ack timer value.  If the assoc_id field is
- *   non-zero, then the set or get effects the specified association.
- *
- *   struct sctp_assoc_value {
- *       sctp_assoc_t            assoc_id;
- *       uint32_t                assoc_value;
- *   };
+/*
+ * 7.1.23.  Get or set delayed ack timer (SCTP_DELAYED_SACK)
+ *
+ * This option will effect the way delayed acks are performed.  This
+ * option allows you to get or set the delayed ack time, in
+ * milliseconds.  It also allows changing the delayed ack frequency.
+ * Changing the frequency to 1 disables the delayed sack algorithm.  If
+ * the assoc_id is 0, then this sets or gets the endpoints default
+ * values.  If the assoc_id field is non-zero, then the set or get
+ * effects the specified association for the one to many model (the
+ * assoc_id field is ignored by the one to one model).  Note that if
+ * sack_delay or sack_freq are 0 when setting this option, then the
+ * current values will remain unchanged.
+ *
+ * struct sctp_sack_info {
+ *     sctp_assoc_t            sack_assoc_id;
+ *     uint32_t                sack_delay;
+ *     uint32_t                sack_freq;
+ * };
  *
- *     assoc_id    - This parameter, indicates which association the
- *                   user is preforming an action upon. Note that if
- *                   this field's value is zero then the endpoints
- *                   default value is changed (effecting future
- *                   associations only).
+ * sack_assoc_id -  This parameter, indicates which association the user
+ *    is performing an action upon.  Note that if this field's value is
+ *    zero then the endpoints default value is changed (effecting future
+ *    associations only).
  *
- *     assoc_value - This parameter contains the number of milliseconds
- *                   that the user is requesting the delayed ACK timer
- *                   be set to. Note that this value is defined in
- *                   the standard to be between 200 and 500 milliseconds.
+ * sack_delay -  This parameter contains the number of milliseconds that
+ *    the user is requesting the delayed ACK timer be set to.  Note that
+ *    this value is defined in the standard to be between 200 and 500
+ *    milliseconds.
  *
- *                   Note: a value of zero will leave the value alone,
- *                   but disable SACK delay. A non-zero value will also
- *                   enable SACK delay.
+ * sack_freq -  This parameter contains the number of packets that must
+ *    be received before a sack is sent without waiting for the delay
+ *    timer to expire.  The default value for this is 2, setting this
+ *    value to 1 will disable the delayed sack algorithm.
  */
-static int sctp_getsockopt_delayed_ack_time(struct sock *sk, int len,
+static int sctp_getsockopt_delayed_ack(struct sock *sk, int len,
 					    char __user *optval,
 					    int __user *optlen)
 {
-	struct sctp_assoc_value  params;
+	struct sctp_sack_info    params;
 	struct sctp_association *asoc = NULL;
 	struct sctp_sock        *sp = sctp_sk(sk);
 
-	if (len < sizeof(struct sctp_assoc_value))
-		return - EINVAL;
+	if (len >= sizeof(struct sctp_sack_info)) {
+		len = sizeof(struct sctp_sack_info);
 
-	len = sizeof(struct sctp_assoc_value);
-
-	if (copy_from_user(&params, optval, len))
-		return -EFAULT;
+		if (copy_from_user(&params, optval, len))
+			return -EFAULT;
+	} else if (len == sizeof(struct sctp_assoc_value)) {
+		printk(KERN_WARNING "SCTP: Use of struct sctp_sack_info "
+		       "in delayed_ack socket option deprecated\n");
+		printk(KERN_WARNING "SCTP: struct sctp_sack_info instead\n");
+		if (copy_from_user(&params, optval, len))
+			return -EFAULT;
+	} else
+		return - EINVAL;
 
-	/* Get association, if assoc_id != 0 and the socket is a one
+	/* Get association, if sack_assoc_id != 0 and the socket is a one
 	 * to many style socket, and an association was not found, then
 	 * the id was invalid.
 	 */
-	asoc = sctp_id2assoc(sk, params.assoc_id);
-	if (!asoc && params.assoc_id && sctp_style(sk, UDP))
+	asoc = sctp_id2assoc(sk, params.sack_assoc_id);
+	if (!asoc && params.sack_assoc_id && sctp_style(sk, UDP))
 		return -EINVAL;
 
 	if (asoc) {
 		/* Fetch association values. */
-		if (asoc->param_flags & SPP_SACKDELAY_ENABLE)
-			params.assoc_value = jiffies_to_msecs(
+		if (asoc->param_flags & SPP_SACKDELAY_ENABLE) {
+			params.sack_delay = jiffies_to_msecs(
 				asoc->sackdelay);
-		else
-			params.assoc_value = 0;
+			params.sack_freq = asoc->sackfreq;
+
+		} else {
+			params.sack_delay = 0;
+			params.sack_freq = 1;
+		}
 	} else {
 		/* Fetch socket values. */
-		if (sp->param_flags & SPP_SACKDELAY_ENABLE)
-			params.assoc_value  = sp->sackdelay;
-		else
-			params.assoc_value  = 0;
+		if (sp->param_flags & SPP_SACKDELAY_ENABLE) {
+			params.sack_delay  = sp->sackdelay;
+			params.sack_freq = sp->sackfreq;
+		} else {
+			params.sack_delay  = 0;
+			params.sack_freq = 1;
+		}
 	}
 
 	if (copy_to_user(optval, &params, len))
@@ -5218,8 +5282,8 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_peer_addr_params(sk, len, optval,
 							  optlen);
 		break;
-	case SCTP_DELAYED_ACK_TIME:
-		retval = sctp_getsockopt_delayed_ack_time(sk, len, optval,
+	case SCTP_DELAYED_ACK:
+		retval = sctp_getsockopt_delayed_ack(sk, len, optval,
 							  optlen);
 		break;
 	case SCTP_INITMSG:
-- 
1.5.3.5

