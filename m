From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH for 2.6.24] SCTP: Rewrite of sctp buffer management code
Date: Mon, 13 Aug 2007 09:24:00 -0400
Message-ID: <11870114401993-git-send-email-vladislav.yasevich@hp.com>
References: <20070811003529.GA19807@hmsreliant.think-freely.org>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	nhorman@tuxdriver.com, Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:38507 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S973012AbXHMN1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 09:27:24 -0400
In-Reply-To: <20070811003529.GA19807@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, Neil

Sorry about that.  Not sure what happened to that patch.  Here is
the good patch with witespace cleanups.

-vlad

--

SCTP: Rewrite of sctp buffer management code

This patch introduces autotuning to the sctp buffer management code
similar to the TCP.  The buffer space can be grown if the advertised
receive window still has room.  This might happen if small message
sizes are used, which is common in telecom environmens.
New tunables are introduced that provide limits to buffer growth
and memory pressure is entered if to much buffer spaces is used.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

 include/net/sctp/sctp.h |    5 +++
 net/sctp/endpointola.c  |    1
 net/sctp/protocol.c     |   32 +++++++++++++++++++++
 net/sctp/sm_statefuns.c |   73 +++++++++++-------------------------------------
 net/sctp/socket.c       |   67 ++++++++++++++++++++++++++++++++++++--------
 net/sctp/sysctl.c       |   33 +++++++++++++++++++++
 net/sctp/ulpevent.c     |   18 +++++++++++
 net/sctp/ulpqueue.c     |    1
 8 files changed, 163 insertions(+), 67 deletions(-)
---
 include/net/sctp/sctp.h |    5 +++
 net/sctp/endpointola.c  |    1 +
 net/sctp/protocol.c     |   32 ++++++++++++++++++++
 net/sctp/sm_statefuns.c |   74 +++++++++++-----------------------------------
 net/sctp/socket.c       |   69 ++++++++++++++++++++++++++++++++++++-------
 net/sctp/sysctl.c       |   33 +++++++++++++++++++++
 net/sctp/ulpevent.c     |   18 +++++++++++
 net/sctp/ulpqueue.c     |    1 +
 8 files changed, 165 insertions(+), 68 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d529045..46d7d09 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -468,6 +468,11 @@ static inline void sctp_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	skb->sk = sk;
 	skb->destructor = sctp_sock_rfree;
 	atomic_add(event->rmem_len, &sk->sk_rmem_alloc);
+	/*
+	 * This mimics the behavior of
+	 * sk_stream_set_owner_r
+	 */
+	sk->sk_forward_alloc -= event->rmem_len;
 }
 
 /* Tests if the list has one and only one entry. */
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 1404a9e..aba9258 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -103,6 +103,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 
 	/* Use SCTP specific send buffer space queues.  */
 	ep->sndbuf_policy = sctp_sndbuf_policy;
+
 	sk->sk_write_space = sctp_write_space;
 	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index e98579b..a746ebf 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -51,6 +51,7 @@
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
 #include <linux/seq_file.h>
+#include <linux/bootmem.h>
 #include <net/protocol.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -82,6 +83,10 @@ static struct sctp_af *sctp_af_v6_specific;
 struct kmem_cache *sctp_chunk_cachep __read_mostly;
 struct kmem_cache *sctp_bucket_cachep __read_mostly;
 
+extern int sysctl_sctp_mem[3];
+extern int sysctl_sctp_rmem[3];
+extern int sysctl_sctp_wmem[3];
+
 /* Return the address of the control sock. */
 struct sock *sctp_get_ctl_sock(void)
 {
@@ -969,6 +974,8 @@ SCTP_STATIC __init int sctp_init(void)
 	int i;
 	int status = -EINVAL;
 	unsigned long goal;
+	unsigned long limit;
+	int max_share;
 	int order;
 
 	/* SCTP_DEBUG sanity check. */
@@ -1059,6 +1066,31 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Initialize handle used for association ids. */
 	idr_init(&sctp_assocs_id);
 
+	/* Set the pressure threshold to be a fraction of global memory that
+	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
+	 * memory, with a floor of 128 pages.
+	 * Note this initalizes the data in sctpv6_prot too
+	 * Unabashedly stolen from tcp_init
+	 */
+	limit = min(num_physpages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
+	limit = (limit * (num_physpages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	limit = max(limit, 128UL);
+	sysctl_sctp_mem[0] = limit / 4 * 3;
+	sysctl_sctp_mem[1] = limit;
+	sysctl_sctp_mem[2] = sysctl_sctp_mem[0] * 2;
+
+	/* Set per-socket limits to no more than 1/128 the pressure threshold*/
+	limit = (sysctl_sctp_mem[1]) << (PAGE_SHIFT - 7);
+	max_share = min(4UL*1024*1024, limit);
+
+	sysctl_sctp_rmem[0] = PAGE_SIZE; /* give each asoc 1 page min */
+	sysctl_sctp_rmem[1] = (1500 *(sizeof(struct sk_buff) + 1));
+	sysctl_sctp_rmem[2] = max(sysctl_sctp_rmem[1], max_share);
+
+	sysctl_sctp_wmem[0] = SK_STREAM_MEM_QUANTUM;
+	sysctl_sctp_wmem[1] = 16*1024;
+	sysctl_sctp_wmem[2] = max(64*1024, max_share);
+
 	/* Size and allocate the association hash table.
 	 * The methodology is similar to that of the tcp hash tables.
 	 */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 71cad56..8032789 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5262,10 +5262,8 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	sctp_verb_t deliver;
 	int tmp;
 	__u32 tsn;
-	int account_value;
 	struct sctp_tsnmap *map = (struct sctp_tsnmap *)&asoc->peer.tsn_map;
 	struct sock *sk = asoc->base.sk;
-	int rcvbuf_over = 0;
 
 	data_hdr = chunk->subh.data_hdr = (sctp_datahdr_t *)chunk->skb->data;
 	skb_pull(chunk->skb, sizeof(sctp_datahdr_t));
@@ -5275,48 +5273,6 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 
 	/* ASSERT:  Now skb->data is really the user data.  */
 
-	/*
-	 * If we are established, and we have used up our receive buffer
-	 * memory, think about droping the frame.
-	 * Note that we have an opportunity to improve performance here.
-	 * If we accept one chunk from an skbuff, we have to keep all the
-	 * memory of that skbuff around until the chunk is read into user
-	 * space. Therefore, once we accept 1 chunk we may as well accept all
-	 * remaining chunks in the skbuff. The data_accepted flag helps us do
-	 * that.
-	 */
-	if ((asoc->state == SCTP_STATE_ESTABLISHED) && (!chunk->data_accepted)) {
-		/*
-		 * If the receive buffer policy is 1, then each
-		 * association can allocate up to sk_rcvbuf bytes
-		 * otherwise, all the associations in aggregate
-		 * may allocate up to sk_rcvbuf bytes
-		 */
-		if (asoc->ep->rcvbuf_policy)
-			account_value = atomic_read(&asoc->rmem_alloc);
-		else
-			account_value = atomic_read(&sk->sk_rmem_alloc);
-		if (account_value > sk->sk_rcvbuf) {
-			/*
-			 * We need to make forward progress, even when we are
-			 * under memory pressure, so we always allow the
-			 * next tsn after the ctsn ack point to be accepted.
-			 * This lets us avoid deadlocks in which we have to
-			 * drop frames that would otherwise let us drain the
-			 * receive queue.
-			 */
-			if ((sctp_tsnmap_get_ctsn(map) + 1) != tsn)
-				return SCTP_IERROR_IGNORE_TSN;
-
-			/*
-			 * We're going to accept the frame but we should renege
-			 * to make space for it. This will send us down that
-			 * path later in this function.
-			 */
-			rcvbuf_over = 1;
-		}
-	}
-
 	/* Process ECN based congestion.
 	 *
 	 * Since the chunk structure is reused for all chunks within
@@ -5376,18 +5332,9 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 * seems a bit troublesome in that frag_point varies based on
 	 * PMTU.  In cases, such as loopback, this might be a rather
 	 * large spill over.
-	 * NOTE: If we have a full receive buffer here, we only renege if
-	 * our receiver can still make progress without the tsn being
-	 * received. We do this because in the event that the associations
-	 * receive queue is empty we are filling a leading gap, and since
-	 * reneging moves the gap to the end of the tsn stream, we are likely
-	 * to stall again very shortly. Avoiding the renege when we fill a
-	 * leading gap is a good heuristic for avoiding such steady state
-	 * stalls.
-	 */
-	if (!asoc->rwnd || asoc->rwnd_over ||
-	    (datalen > asoc->rwnd + asoc->frag_point) ||
-	    (rcvbuf_over && (!skb_queue_len(&sk->sk_receive_queue)))) {
+	 */
+	if ((!chunk->data_accepted) && (!asoc->rwnd || asoc->rwnd_over ||
+	    (datalen > asoc->rwnd + asoc->frag_point))) {
 
 		/* If this is the next TSN, consider reneging to make
 		 * room.   Note: Playing nice with a confused sender.  A
@@ -5408,6 +5355,21 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	}
 
 	/*
+	 * Also try to renege to limit our memory usage in the event that
+	 * we are under memory pressure
+	 * If we can't renege, don't worry about it, the sk_stream_rmem_schedule
+	 * in sctp_ulpevent_make_rcvmsg will drop the frame if we grow our
+	 * memory usage too much
+	 */
+	if (*sk->sk_prot_creator->memory_pressure) {
+		if (sctp_tsnmap_has_gap(map) &&
+	           (sctp_tsnmap_get_ctsn(map) + 1) == tsn) {
+			SCTP_DEBUG_PRINTK("Under Pressure! Reneging for tsn:%u\n", tsn);
+			deliver = SCTP_CMD_RENEGE;
+		 }
+	}
+
+	/*
 	 * Section 3.3.10.9 No User Data (9)
 	 *
 	 * Cause of error
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 01c6364..80de574 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -107,23 +107,42 @@ static void sctp_sock_migrate(struct sock *, struct sock *,
 			      struct sctp_association *, sctp_socket_type_t);
 static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
 
+extern struct kmem_cache *sctp_bucket_cachep;
+extern int sysctl_sctp_mem[3];
+extern int sysctl_sctp_rmem[3];
+extern int sysctl_sctp_wmem[3];
+
+int sctp_memory_pressure;
+atomic_t sctp_memory_allocated;
+atomic_t sctp_sockets_allocated;
+
+static void sctp_enter_memory_pressure(void)
+{
+	sctp_memory_pressure = 1;
+}
+
+
 /* Get the sndbuf space available at the time on the association.  */
 static inline int sctp_wspace(struct sctp_association *asoc)
 {
-	struct sock *sk = asoc->base.sk;
-	int amt = 0;
+	int amt;
 
-	if (asoc->ep->sndbuf_policy) {
-		/* make sure that no association uses more than sk_sndbuf */
-		amt = sk->sk_sndbuf - asoc->sndbuf_used;
+	if (asoc->ep->sndbuf_policy)
+		amt = asoc->sndbuf_used;
+	else
+		amt = atomic_read(&asoc->base.sk->sk_wmem_alloc);
+
+	if (amt >= asoc->base.sk->sk_sndbuf) {
+		if (asoc->base.sk->sk_userlocks & SOCK_SNDBUF_LOCK)
+			amt = 0;
+		else {
+			amt = sk_stream_wspace(asoc->base.sk);
+			if (amt < 0)
+				amt = 0;
+		}
 	} else {
-		/* do socket level accounting */
-		amt = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+		amt = asoc->base.sk->sk_sndbuf - amt;
 	}
-
-	if (amt < 0)
-		amt = 0;
-
 	return amt;
 }
 
@@ -155,6 +174,7 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 				sizeof(struct sctp_chunk);
 
 	atomic_add(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
+	sk_charge_skb(sk, chunk->skb);
 }
 
 /* Verify that this is a valid address. */
@@ -3314,6 +3334,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->hmac = NULL;
 
 	SCTP_DBG_OBJCNT_INC(sock);
+	atomic_inc(&sctp_sockets_allocated);
 	return 0;
 }
 
@@ -3327,7 +3348,7 @@ SCTP_STATIC int sctp_destroy_sock(struct sock *sk)
 	/* Release our hold on the endpoint. */
 	ep = sctp_sk(sk)->ep;
 	sctp_endpoint_free(ep);
-
+	atomic_dec(&sctp_sockets_allocated);
 	return 0;
 }
 
@@ -5747,6 +5768,12 @@ static void sctp_wfree(struct sk_buff *skb)
 
 	atomic_sub(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
 
+	/*
+	 * This undoes what is done via sk_charge_skb
+	 */
+	sk->sk_wmem_queued   -= skb->truesize;
+	sk->sk_forward_alloc += skb->truesize;
+
 	sock_wfree(skb);
 	__sctp_write_space(asoc);
 
@@ -5764,6 +5791,11 @@ void sctp_sock_rfree(struct sk_buff *skb)
 	struct sctp_ulpevent *event = sctp_skb2event(skb);
 
 	atomic_sub(event->rmem_len, &sk->sk_rmem_alloc);
+
+	/*
+	 * Mimic the behavior of sk_stream_rfree
+	 */
+	sk->sk_forward_alloc += event->rmem_len;
 }
 
 
@@ -6153,6 +6185,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	sctp_release_sock(newsk);
 }
 
+
 /* This proto struct describes the ULP interface for SCTP.  */
 struct proto sctp_prot = {
 	.name        =	"SCTP",
@@ -6175,6 +6208,12 @@ struct proto sctp_prot = {
 	.unhash      =	sctp_unhash,
 	.get_port    =	sctp_get_port,
 	.obj_size    =  sizeof(struct sctp_sock),
+	.sysctl_mem  =  sysctl_sctp_mem,
+	.sysctl_rmem =  sysctl_sctp_rmem,
+	.sysctl_wmem =  sysctl_sctp_wmem,
+	.memory_pressure = &sctp_memory_pressure,
+	.enter_memory_pressure = sctp_enter_memory_pressure,
+	.memory_allocated = &sctp_memory_allocated,
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -6199,5 +6238,11 @@ struct proto sctpv6_prot = {
 	.unhash		= sctp_unhash,
 	.get_port	= sctp_get_port,
 	.obj_size	= sizeof(struct sctp6_sock),
+	.sysctl_mem	= sysctl_sctp_mem,
+	.sysctl_rmem	= sysctl_sctp_rmem,
+	.sysctl_wmem	= sysctl_sctp_wmem,
+	.memory_pressure = &sctp_memory_pressure,
+	.enter_memory_pressure = sctp_enter_memory_pressure,
+	.memory_allocated = &sctp_memory_allocated,
 };
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index e2c679b..ba75ef4 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -52,6 +52,15 @@ static int int_max = INT_MAX;
 static long sack_timer_min = 1;
 static long sack_timer_max = 500;
 
+int sysctl_sctp_mem[3];
+int sysctl_sctp_rmem[3];
+int sysctl_sctp_wmem[3];
+
+/*
+ * per assoc memory limitationf for sends
+ */
+int sysctl_sctp_wmem[3];
+
 static ctl_table sctp_table[] = {
 	{
 		.ctl_name	= NET_SCTP_RTO_INITIAL,
@@ -226,6 +235,30 @@ static ctl_table sctp_table[] = {
 		.extra1         = &sack_timer_min,
 		.extra2         = &sack_timer_max,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "sctp_mem",
+		.data		= &sysctl_sctp_mem,
+		.maxlen		= sizeof(sysctl_sctp_mem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "sctp_rmem",
+		.data		= &sysctl_sctp_rmem,
+		.maxlen		= sizeof(sysctl_sctp_rmem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "sctp_wmem",
+		.data		= &sysctl_sctp_wmem,
+		.maxlen		= sizeof(sysctl_sctp_wmem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index bfecb35..5dc094b 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -685,6 +685,24 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
 	struct sctp_ulpevent *event = NULL;
 	struct sk_buff *skb;
 	size_t padding, len;
+	int rx_count;
+
+	/*
+	 * check to see if we need to make space for this
+	 * new skb, expand the rcvbuffer if needed, or drop
+	 * the frame
+	 */
+	if (asoc->ep->rcvbuf_policy)
+		rx_count = atomic_read(&asoc->rmem_alloc);
+	else
+		rx_count = atomic_read(&asoc->base.sk->sk_rmem_alloc);
+
+	if (rx_count >= asoc->base.sk->sk_rcvbuf) {
+
+		if ((asoc->base.sk->sk_userlocks & SOCK_RCVBUF_LOCK) ||
+		   (!sk_stream_rmem_schedule(asoc->base.sk, chunk->skb)))
+			goto fail;
+	}
 
 	/* Clone the original skb, sharing the data.  */
 	skb = skb_clone(chunk->skb, gfp);
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 34eb977..33e49b5 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -978,6 +978,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 		sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
 	}
 
+	sk_stream_mem_reclaim(asoc->base.sk);
 	return;
 }
 
-- 
1.5.2.4

