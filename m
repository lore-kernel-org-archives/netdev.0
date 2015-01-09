From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 4/5] net-timestamp: tx timestamp cookies
Date: Fri,  9 Jan 2015 12:31:58 -0500
Message-ID: <1420824719-28848-5-git-send-email-willemb@google.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	eric.dumazet@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:47917 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305AbbAIRcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:32:09 -0500
Received: by mail-yk0-f173.google.com with SMTP id 19so4530703ykq.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:32:08 -0800 (PST)
In-Reply-To: <1420824719-28848-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support looping multiple timestamps on top of a single skb on the
error queue.

Tx timestamps are returned on top of an skb. TCP timestamping and
other timestamp points enabled multiple timestamps for each buffer
passed in send. Due to retransmissions, this number may be high,
using lots of SO_RCVBUF space and kernel mode switches.

When returning without payload (SOF_TIMESTAMPING_OPT_TSONLY), the
total truesize is smaller, but still O(n). Without payload, the
constraint that a timestamp belongs to a specific skb also goes
away.

Instead of queuing multiple skbs onto the error queue, queue
successive timestamps onto the skb on top of the error queue.
For this purpose, introduce a timestamp cookie and use a list
of cookies instead of skb->tstamp.

The number of batched cookies is limited by having sends fail
with EAGAIN or ENOMSG as soon as a single packet is waiting on
the receive queue. If merging this functionality, a TODO is to
add a hard cap, so that processes can estimate the maximum
msg_controllen needed to read all timestamps.

The implementation returns the same structures as before, that is,
one struct sock_extended_err and one struct scm_timestamping for
each timestamp. The list is returned in reverse chronological
order: newest first. This choice is partially determined by the
callers (e.g., ip_recv_error) generating the final sock_extended_err.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h        |  12 +++++
 include/net/sock.h            |   3 +-
 include/uapi/linux/errqueue.h |   1 +
 net/core/skbuff.c             | 104 ++++++++++++++++++++++++++++++++++++------
 net/socket.c                  |  64 ++++++++++++++++++++++++--
 5 files changed, 167 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d7..6d77b51 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -298,6 +298,13 @@ struct ubuf_info {
 	unsigned long desc;
 };
 
+struct skb_tstamp_cookie {
+	u32 tskey;
+	u32 tstype;
+	ktime_t tstamp;
+	struct skb_tstamp_cookie *next;
+};
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -442,6 +449,8 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@next: Next buffer in list
  *	@prev: Previous buffer in list
  *	@tstamp: Time we arrived/left
+ *	@skb_mstamp: tstamp variant used only within the TCP stack
+ *	@tscookies: tstamp variant used only with no-payload errqueue packets
  *	@rbnode: RB tree node, alternative to next/prev for netem/tcp
  *	@sk: Socket we are owned by
  *	@dev: Device we arrived on/are leaving by
@@ -516,6 +525,7 @@ struct sk_buff {
 			union {
 				ktime_t		tstamp;
 				struct skb_mstamp skb_mstamp;
+				struct skb_tstamp_cookie *tscookies;
 			};
 		};
 		struct rb_node	rbnode; /* used in netem & tcp stack */
@@ -2861,6 +2871,8 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 		     struct skb_shared_hwtstamps *hwtstamps,
 		     struct sock *sk, int tstype);
 
+bool skb_has_tscookies(struct sk_buff *skb);
+
 /**
  * skb_tstamp_tx - queue clone of skb with send time stamps
  * @orig_skb:	the original outgoing packet
diff --git a/include/net/sock.h b/include/net/sock.h
index 9729171..de190d8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2149,7 +2149,8 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RX_SOFTWARE) ||
-	    (kt.tv64 && sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE) ||
+	    ((kt.tv64 || skb_has_tscookies(skb)) &&
+	     sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE) ||
 	    (hwtstamps->hwtstamp.tv64 &&
 	     (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE)))
 		__sock_recv_timestamp(msg, sk, skb);
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 07bdce1..ab67bf0 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -41,6 +41,7 @@ enum {
 	SCM_TSTAMP_SND,		/* driver passed skb to NIC, or HW */
 	SCM_TSTAMP_SCHED,	/* data entered the packet scheduler */
 	SCM_TSTAMP_ACK,		/* data acknowledged by peer */
+	SCM_TSTAMP_HW,		/* internal use: HW generated */
 };
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e5f4c06..c41597f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3581,6 +3581,19 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 }
 EXPORT_SYMBOL_GPL(skb_cow_data);
 
+static void skb_destructor_tscookies(struct sk_buff *skb)
+{
+	struct skb_tstamp_cookie *prev, *cur = skb->tscookies;
+
+	while (cur) {
+		prev = cur;
+		cur = cur->next;
+		kfree(prev);
+	}
+	skb->tscookies = NULL;
+	skb->destructor = NULL;
+}
+
 static void sock_rmem_free(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
@@ -3588,6 +3601,12 @@ static void sock_rmem_free(struct sk_buff *skb)
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 }
 
+static void sock_rmem_free_tscookies(struct sk_buff *skb)
+{
+	skb_destructor_tscookies(skb);
+	sock_rmem_free(skb);
+}
+
 /*
  * Note: We dont mem charge error packets (no sk_forward_alloc changes)
  */
@@ -3597,9 +3616,13 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 	    (unsigned int)sk->sk_rcvbuf)
 		return -ENOMEM;
 
-	skb_orphan(skb);
+	if (skb_has_tscookies(skb)) {
+		skb->destructor = sock_rmem_free_tscookies;
+	} else {
+		skb_orphan(skb);
+		skb->destructor = sock_rmem_free;
+	}
 	skb->sk = sk;
-	skb->destructor = sock_rmem_free;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 
 	/* before exiting rcu section, make sure dst is refcounted */
@@ -3666,23 +3689,78 @@ struct sk_buff *skb_clone_sk(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_clone_sk);
 
-static void __skb_complete_tx_timestamp(struct sk_buff *skb,
-					struct sock *sk,
-					int tstype)
+bool skb_has_tscookies(struct sk_buff *skb)
+{
+	return skb->destructor == skb_destructor_tscookies ||
+	       skb->destructor == sock_rmem_free_tscookies;
+}
+EXPORT_SYMBOL(skb_has_tscookies);
+
+static bool __skb_queue_tstamp_cookie(struct sk_buff *skb, struct sock *sk,
+				      int tstype, u32 tskey, bool is_hw)
+{
+	struct sk_buff_head *q = &sk->sk_error_queue;
+	struct skb_tstamp_cookie *new;
+	struct sk_buff *qskb;
+	unsigned long flags;
+	bool queued = false;
+
+	if (skb->destructor)
+		return false;
+
+	new = kzalloc(sizeof(*new), GFP_ATOMIC);
+	if (!new)
+		return false;
+
+	new->tskey = tskey;
+	if (unlikely(is_hw)) {
+		new->tstype = SCM_TSTAMP_HW;
+		new->tstamp = skb_hwtstamps(skb)->hwtstamp;
+	} else {
+		new->tstype = tstype;
+		new->tstamp = skb->tstamp;
+	}
+
+	spin_lock_irqsave(&q->lock, flags);
+	qskb = skb_peek(&sk->sk_error_queue);
+	if (qskb && skb_has_tscookies(qskb)) {
+		new->next = qskb->tscookies;
+		qskb->tscookies = new;
+		queued = true;
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
+	if (queued) {
+		consume_skb(skb);
+		return true;
+	}
+
+	skb->tscookies = new;
+	skb->destructor = skb_destructor_tscookies;
+	return false;
+}
+
+static void __skb_complete_tx_timestamp(struct sk_buff *skb, struct sock *sk,
+					int tstype, bool is_hw)
 {
 	struct sock_exterr_skb *serr;
-	int err;
+	int err, tskey = 0;
+
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID) {
+		tskey = skb_shinfo(skb)->tskey;
+		if (sk->sk_protocol == IPPROTO_TCP)
+			tskey -= sk->sk_tskey;
+	}
+
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY &&
+	    __skb_queue_tstamp_cookie(skb, sk, tstype, tskey, is_hw))
+		return;
 
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	serr->ee.ee_info = tstype;
-	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID) {
-		serr->ee.ee_data = skb_shinfo(skb)->tskey;
-		if (sk->sk_protocol == IPPROTO_TCP)
-			serr->ee.ee_data -= sk->sk_tskey;
-	}
+	serr->ee.ee_data = tskey;
 
 	err = sock_queue_err_skb(sk, skb);
 
@@ -3708,7 +3786,7 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	sock_hold(sk);
 
 	*skb_hwtstamps(skb) = *hwtstamps;
-	__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
+	__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND, true);
 
 	sock_put(sk);
 }
@@ -3741,7 +3819,7 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	else
 		skb->tstamp = ktime_get_real();
 
-	__skb_complete_tx_timestamp(skb, sk, tstype);
+	__skb_complete_tx_timestamp(skb, sk, tstype, hwtstamps);
 }
 EXPORT_SYMBOL_GPL(__skb_tstamp_tx);
 
diff --git a/net/socket.c b/net/socket.c
index a2c33a4..6595108 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -676,9 +676,63 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(kernel_sendmsg);
 
-/*
- * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
- */
+static bool __ts_allow_report(struct sock *sk, int tstype)
+{
+	if (tstype == SCM_TSTAMP_HW)
+		return sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE;
+	else
+		return sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE;
+}
+
+static void __ts_generate_serr(struct msghdr *msg, struct sock *sk,
+			       struct skb_tstamp_cookie *cur)
+{
+	struct sock_extended_err serr;
+
+	memset(&serr, 0, sizeof(serr));
+
+	serr.ee_errno = ENOMSG;
+	serr.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
+	serr.ee_data = cur->tskey;
+	serr.ee_info = cur->tstype;
+
+	/* work around legacy interface: HW reports SND with data in tss[2] */
+	if (serr.ee_info == SCM_TSTAMP_HW)
+		serr.ee_info = SCM_TSTAMP_SND;
+
+	if (sk->sk_family == AF_INET)
+		put_cmsg(msg, SOL_IP, IP_RECVERR, sizeof(serr), &serr);
+	else if (sk->sk_family == AF_INET6)
+		put_cmsg(msg, SOL_IPV6, IPV6_RECVERR, sizeof(serr), &serr);
+	else
+		net_warn_ratelimited("tscookie: unknown proto %x",
+				     sk->sk_family);
+}
+
+static void __ts_generate_tss(struct msghdr *msg, struct skb_tstamp_cookie *cur)
+{
+	struct scm_timestamping tss;
+	bool idx = cur->tstype == SCM_TSTAMP_HW ? 2 : 0;
+
+	memset(&tss, 0, sizeof(tss));
+	tss.ts[idx] = ktime_to_timespec(cur->tstamp);
+	put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING, sizeof(tss), &tss);
+}
+
+static void __sock_recv_timestamp_cookies(struct msghdr *msg, struct sock *sk,
+					  struct skb_tstamp_cookie *cookie)
+{
+	while (cookie) {
+		if (__ts_allow_report(sk, cookie->tstype)) {
+			__ts_generate_tss(msg, cookie);
+			/* caller (e.g., ip_recv_error) generates last serr */
+			if (cookie->next)
+				__ts_generate_serr(msg, sk, cookie);
+		}
+		cookie = cookie->next;
+	}
+}
+
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
@@ -688,6 +742,10 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct skb_shared_hwtstamps *shhwtstamps =
 		skb_hwtstamps(skb);
 
+	if (skb_has_tscookies(skb)) {
+		__sock_recv_timestamp_cookies(msg, sk, skb->tscookies);
+		return;
+	}
 	/* Race occurred between timestamp enabling and packet
 	   receiving.  Fill in the current time for now. */
 	if (need_software_tstamp && skb->tstamp.tv64 == 0)
-- 
2.2.0.rc0.207.ga3a616c
