From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 04/17] net: convert sk_buff.users from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:28:54 +0200
Message-ID: <1489678147-21404-5-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/infiniband/hw/nes/nes_cm.c |  4 ++--
 drivers/isdn/mISDN/socket.c        |  2 +-
 drivers/net/rionet.c               |  2 +-
 drivers/s390/net/ctcm_main.c       | 26 +++++++++++++-------------
 drivers/s390/net/netiucv.c         | 10 +++++-----
 drivers/s390/net/qeth_core_main.c  |  4 ++--
 drivers/scsi/cxgbi/libcxgbi.h      |  2 +-
 include/linux/skbuff.h             |  6 +++---
 net/core/datagram.c                |  8 ++++----
 net/core/dev.c                     | 10 +++++-----
 net/core/netpoll.c                 |  4 ++--
 net/core/pktgen.c                  | 16 ++++++++--------
 net/core/rtnetlink.c               |  2 +-
 net/core/skbuff.c                  | 20 ++++++++++----------
 net/dccp/ipv6.c                    |  2 +-
 net/ipv6/syncookies.c              |  2 +-
 net/ipv6/tcp_ipv6.c                |  2 +-
 net/key/af_key.c                   |  4 ++--
 net/netlink/af_netlink.c           |  6 +++---
 net/rxrpc/skbuff.c                 | 12 ++++++------
 net/sctp/outqueue.c                |  2 +-
 net/sctp/socket.c                  |  2 +-
 22 files changed, 74 insertions(+), 74 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index fb983df..08dac2e 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -743,7 +743,7 @@ int schedule_nes_timer(struct nes_cm_node *cm_node, struct sk_buff *skb,
 
 	if (type == NES_TIMER_TYPE_SEND) {
 		new_send->seq_num = ntohl(tcp_hdr(skb)->seq);
-		atomic_inc(&new_send->skb->users);
+		refcount_inc(&new_send->skb->users);
 		spin_lock_irqsave(&cm_node->retrans_list_lock, flags);
 		cm_node->send_entry = new_send;
 		add_ref_cm_node(cm_node);
@@ -925,7 +925,7 @@ static void nes_cm_timer_tick(unsigned long pass)
 						  flags);
 				break;
 			}
-			atomic_inc(&send_entry->skb->users);
+			refcount_inc(&send_entry->skb->users);
 			cm_packets_retrans++;
 			nes_debug(NES_DBG_CM, "Retransmitting send_entry %p "
 				  "for node %p, jiffies = %lu, time to send = "
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 99e5f97..c5603d1 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -155,7 +155,7 @@ mISDN_sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	copied = skb->len + MISDN_HEADER_LEN;
 	if (len < copied) {
 		if (flags & MSG_PEEK)
-			atomic_dec(&skb->users);
+			refcount_dec(&skb->users);
 		else
 			skb_queue_head(&sk->sk_receive_queue, skb);
 		return -ENOSPC;
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 300bb14..e9f101c 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -201,7 +201,7 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 				rionet_queue_tx_msg(skb, ndev,
 					nets[rnet->mport->id].active[i]);
 				if (count)
-					atomic_inc(&skb->users);
+					refcount_inc(&skb->users);
 				count++;
 			}
 	} else if (RIONET_MAC_MATCH(eth->h_dest)) {
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index ac65f12..d079d02 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -483,7 +483,7 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 			spin_unlock_irqrestore(&ch->collect_lock, saveflags);
 			return -EBUSY;
 		} else {
-			atomic_inc(&skb->users);
+			refcount_inc(&skb->users);
 			header.length = l;
 			header.type = skb->protocol;
 			header.unused = 0;
@@ -500,7 +500,7 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 	 * Protect skb against beeing free'd by upper
 	 * layers.
 	 */
-	atomic_inc(&skb->users);
+	refcount_inc(&skb->users);
 	ch->prof.txlen += skb->len;
 	header.length = skb->len + LL_HEADER_LENGTH;
 	header.type = skb->protocol;
@@ -517,14 +517,14 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 	if (hi) {
 		nskb = alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!nskb) {
-			atomic_dec(&skb->users);
+			refcount_dec(&skb->users);
 			skb_pull(skb, LL_HEADER_LENGTH + 2);
 			ctcm_clear_busy(ch->netdev);
 			return -ENOMEM;
 		} else {
 			memcpy(skb_put(nskb, skb->len), skb->data, skb->len);
-			atomic_inc(&nskb->users);
-			atomic_dec(&skb->users);
+			refcount_inc(&nskb->users);
+			refcount_dec(&skb->users);
 			dev_kfree_skb_irq(skb);
 			skb = nskb;
 		}
@@ -542,7 +542,7 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 			 * Remove our header. It gets added
 			 * again on retransmit.
 			 */
-			atomic_dec(&skb->users);
+			refcount_dec(&skb->users);
 			skb_pull(skb, LL_HEADER_LENGTH + 2);
 			ctcm_clear_busy(ch->netdev);
 			return -ENOMEM;
@@ -553,7 +553,7 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 		ch->ccw[1].count = skb->len;
 		skb_copy_from_linear_data(skb,
 				skb_put(ch->trans_skb, skb->len), skb->len);
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_irq(skb);
 		ccw_idx = 0;
 	} else {
@@ -679,7 +679,7 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 
 	if ((fsm_getstate(ch->fsm) != CTC_STATE_TXIDLE) || grp->in_sweep) {
 		spin_lock_irqsave(&ch->collect_lock, saveflags);
-		atomic_inc(&skb->users);
+		refcount_inc(&skb->users);
 		p_header = kmalloc(PDU_HEADER_LENGTH, gfp_type());
 
 		if (!p_header) {
@@ -716,7 +716,7 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 	 * Protect skb against beeing free'd by upper
 	 * layers.
 	 */
-	atomic_inc(&skb->users);
+	refcount_inc(&skb->users);
 
 	/*
 	 * IDAL support in CTCM is broken, so we have to
@@ -729,8 +729,8 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 			goto nomem_exit;
 		} else {
 			memcpy(skb_put(nskb, skb->len), skb->data, skb->len);
-			atomic_inc(&nskb->users);
-			atomic_dec(&skb->users);
+			refcount_inc(&nskb->users);
+			refcount_dec(&skb->users);
 			dev_kfree_skb_irq(skb);
 			skb = nskb;
 		}
@@ -810,7 +810,7 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 		ch->trans_skb->len = 0;
 		ch->ccw[1].count = skb->len;
 		memcpy(skb_put(ch->trans_skb, skb->len), skb->data, skb->len);
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_irq(skb);
 		ccw_idx = 0;
 		CTCM_PR_DBGDATA("%s(%s): trans_skb len: %04x\n"
@@ -855,7 +855,7 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 			"%s(%s): MEMORY allocation ERROR\n",
 			CTCM_FUNTAIL, ch->id);
 	rc = -ENOMEM;
-	atomic_dec(&skb->users);
+	refcount_dec(&skb->users);
 	dev_kfree_skb_any(skb);
 	fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
 done:
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 3f85b97..44fd71c 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -743,7 +743,7 @@ static void conn_action_txdone(fsm_instance *fi, int event, void *arg)
 	conn->prof.tx_pending--;
 	if (single_flag) {
 		if ((skb = skb_dequeue(&conn->commit_queue))) {
-			atomic_dec(&skb->users);
+			refcount_dec(&skb->users);
 			if (privptr) {
 				privptr->stats.tx_packets++;
 				privptr->stats.tx_bytes +=
@@ -767,7 +767,7 @@ static void conn_action_txdone(fsm_instance *fi, int event, void *arg)
 		txbytes += skb->len;
 		txpackets++;
 		stat_maxcq++;
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_any(skb);
 	}
 	if (conn->collect_len > conn->prof.maxmulti)
@@ -959,7 +959,7 @@ static void netiucv_purge_skb_queue(struct sk_buff_head *q)
 	struct sk_buff *skb;
 
 	while ((skb = skb_dequeue(q))) {
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_any(skb);
 	}
 }
@@ -1177,7 +1177,7 @@ static int netiucv_transmit_skb(struct iucv_connection *conn,
 			IUCV_DBF_TEXT(data, 2,
 				      "EBUSY from netiucv_transmit_skb\n");
 		} else {
-			atomic_inc(&skb->users);
+			refcount_inc(&skb->users);
 			skb_queue_tail(&conn->collect_queue, skb);
 			conn->collect_len += l;
 			rc = 0;
@@ -1247,7 +1247,7 @@ static int netiucv_transmit_skb(struct iucv_connection *conn,
 		} else {
 			if (copied)
 				dev_kfree_skb(skb);
-			atomic_inc(&nskb->users);
+			refcount_inc(&nskb->users);
 			skb_queue_tail(&conn->commit_queue, nskb);
 		}
 	}
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 315d8a2..5103a02 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1239,7 +1239,7 @@ static void qeth_release_skbs(struct qeth_qdio_out_buffer *buf)
 				iucv->sk_txnotify(skb, TX_NOTIFY_GENERALERROR);
 			}
 		}
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_any(skb);
 		skb = skb_dequeue(&buf->skb_list);
 	}
@@ -3969,7 +3969,7 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 	int flush_cnt = 0, hdr_len, large_send = 0;
 
 	buffer = buf->buffer;
-	atomic_inc(&skb->users);
+	refcount_inc(&skb->users);
 	skb_queue_tail(&buf->skb_list, skb);
 
 	/*check first on TSO ....*/
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 18e0ea8..9584b062 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -378,7 +378,7 @@ static inline void cxgbi_sock_enqueue_wr(struct cxgbi_sock *csk,
 	 * just one user currently so we use atomic_set rather than skb_get
 	 * to avoid the atomic op.
 	 */
-	atomic_set(&skb->users, 2);
+	refcount_set(&skb->users, 2);
 
 	if (!csk->wr_pending_head)
 		csk->wr_pending_head = skb;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 957a2b0..0bcaec4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -815,7 +815,7 @@ struct sk_buff {
 	unsigned char		*head,
 				*data;
 	unsigned int		truesize;
-	atomic_t		users;
+	refcount_t		users;
 };
 
 #ifdef __KERNEL__
@@ -1313,7 +1313,7 @@ static inline struct sk_buff *skb_queue_prev(const struct sk_buff_head *list,
  */
 static inline struct sk_buff *skb_get(struct sk_buff *skb)
 {
-	atomic_inc(&skb->users);
+	refcount_inc(&skb->users);
 	return skb;
 }
 
@@ -1414,7 +1414,7 @@ static inline void __skb_header_release(struct sk_buff *skb)
  */
 static inline int skb_shared(const struct sk_buff *skb)
 {
-	return atomic_read(&skb->users) != 1;
+	return refcount_read(&skb->users) != 1;
 }
 
 /**
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ea63334..281e5d6 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -244,7 +244,7 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 					}
 				}
 				*peeked = 1;
-				atomic_inc(&skb->users);
+				refcount_inc(&skb->users);
 			} else {
 				__skb_unlink(skb, queue);
 				if (destructor)
@@ -313,9 +313,9 @@ void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 {
 	bool slow;
 
-	if (likely(atomic_read(&skb->users) == 1))
+	if (likely(refcount_read(&skb->users) == 1))
 		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users))) {
+	else if (likely(!refcount_dec_and_test(&skb->users))) {
 		sk_peek_offset_bwd(sk, len);
 		return;
 	}
@@ -343,7 +343,7 @@ int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		if (skb == skb_peek(&sk->sk_receive_queue)) {
 			__skb_unlink(skb, &sk->sk_receive_queue);
-			atomic_dec(&skb->users);
+			refcount_dec(&skb->users);
 			if (destructor)
 				destructor(sk, skb);
 			err = 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index d947308..eeb6338 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1830,7 +1830,7 @@ static inline int deliver_skb(struct sk_buff *skb,
 {
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		return -ENOMEM;
-	atomic_inc(&skb->users);
+	refcount_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
@@ -2449,10 +2449,10 @@ void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
 {
 	unsigned long flags;
 
-	if (likely(atomic_read(&skb->users) == 1)) {
+	if (likely(refcount_read(&skb->users) == 1)) {
 		smp_rmb();
-		atomic_set(&skb->users, 0);
-	} else if (likely(!atomic_dec_and_test(&skb->users))) {
+		refcount_set(&skb->users, 0);
+	} else if (likely(!refcount_dec_and_test(&skb->users))) {
 		return;
 	}
 	get_kfree_skb_cb(skb)->reason = reason;
@@ -3864,7 +3864,7 @@ static __latent_entropy void net_tx_action(struct softirq_action *h)
 
 			clist = clist->next;
 
-			WARN_ON(atomic_read(&skb->users));
+			WARN_ON(refcount_read(&skb->users));
 			if (likely(get_kfree_skb_cb(skb)->reason == SKB_REASON_CONSUMED))
 				trace_consume_skb(skb);
 			else
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9424673..891d88e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -271,7 +271,7 @@ static void zap_completion_queue(void)
 			struct sk_buff *skb = clist;
 			clist = clist->next;
 			if (!skb_irq_freeable(skb)) {
-				atomic_inc(&skb->users);
+				refcount_inc(&skb->users);
 				dev_kfree_skb_any(skb); /* put this one back */
 			} else {
 				__kfree_skb(skb);
@@ -303,7 +303,7 @@ static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
 		return NULL;
 	}
 
-	atomic_set(&skb->users, 1);
+	refcount_set(&skb->users, 1);
 	skb_reserve(skb, reserve);
 	return skb;
 }
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 96947f5..598355f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3361,7 +3361,7 @@ static void pktgen_wait_for_skb(struct pktgen_dev *pkt_dev)
 {
 	ktime_t idle_start = ktime_get();
 
-	while (atomic_read(&(pkt_dev->skb->users)) != 1) {
+	while (refcount_read(&(pkt_dev->skb->users)) != 1) {
 		if (signal_pending(current))
 			break;
 
@@ -3418,7 +3418,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	if (pkt_dev->xmit_mode == M_NETIF_RECEIVE) {
 		skb = pkt_dev->skb;
 		skb->protocol = eth_type_trans(skb, skb->dev);
-		atomic_add(burst, &skb->users);
+		refcount_add(burst, &skb->users);
 		local_bh_disable();
 		do {
 			ret = netif_receive_skb(skb);
@@ -3426,11 +3426,11 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 				pkt_dev->errors++;
 			pkt_dev->sofar++;
 			pkt_dev->seq_num++;
-			if (atomic_read(&skb->users) != burst) {
+			if (refcount_read(&skb->users) != burst) {
 				/* skb was queued by rps/rfs or taps,
 				 * so cannot reuse this skb
 				 */
-				atomic_sub(burst - 1, &skb->users);
+				WARN_ON(refcount_sub_and_test(burst - 1, &skb->users));
 				/* get out of the loop and wait
 				 * until skb is consumed
 				 */
@@ -3444,7 +3444,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		goto out; /* Skips xmit_mode M_START_XMIT */
 	} else if (pkt_dev->xmit_mode == M_QUEUE_XMIT) {
 		local_bh_disable();
-		atomic_inc(&pkt_dev->skb->users);
+		refcount_inc(&pkt_dev->skb->users);
 
 		ret = dev_queue_xmit(pkt_dev->skb);
 		switch (ret) {
@@ -3485,7 +3485,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_ok = 0;
 		goto unlock;
 	}
-	atomic_add(burst, &pkt_dev->skb->users);
+	refcount_add(burst, &pkt_dev->skb->users);
 
 xmit_more:
 	ret = netdev_start_xmit(pkt_dev->skb, odev, txq, --burst > 0);
@@ -3511,11 +3511,11 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		/* fallthru */
 	case NETDEV_TX_BUSY:
 		/* Retry it next time */
-		atomic_dec(&(pkt_dev->skb->users));
+		refcount_dec(&(pkt_dev->skb->users));
 		pkt_dev->last_ok = 0;
 	}
 	if (unlikely(burst))
-		atomic_sub(burst, &pkt_dev->skb->users);
+		WARN_ON(refcount_sub_and_test(burst, &pkt_dev->skb->users));
 unlock:
 	HARD_TX_UNLOCK(odev, txq);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c4e84c5..8044cf3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -647,7 +647,7 @@ int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int g
 
 	NETLINK_CB(skb).dst_group = group;
 	if (echo)
-		atomic_inc(&skb->users);
+		refcount_inc(&skb->users);
 	netlink_broadcast(rtnl, skb, pid, group, GFP_KERNEL);
 	if (echo)
 		err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 89f0d4e..94e961f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -176,7 +176,7 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->head = NULL;
 	skb->truesize = sizeof(struct sk_buff);
-	atomic_set(&skb->users, 1);
+	refcount_set(&skb->users, 1);
 
 	skb->mac_header = (typeof(skb->mac_header))~0U;
 out:
@@ -247,7 +247,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	/* Account for allocated memory : skb + skb->head */
 	skb->truesize = SKB_TRUESIZE(size);
 	skb->pfmemalloc = pfmemalloc;
-	atomic_set(&skb->users, 1);
+	refcount_set(&skb->users, 1);
 	skb->head = data;
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
@@ -314,7 +314,7 @@ struct sk_buff *__build_skb(void *data, unsigned int frag_size)
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = SKB_TRUESIZE(size);
-	atomic_set(&skb->users, 1);
+	refcount_set(&skb->users, 1);
 	skb->head = data;
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
@@ -696,9 +696,9 @@ void kfree_skb(struct sk_buff *skb)
 {
 	if (unlikely(!skb))
 		return;
-	if (likely(atomic_read(&skb->users) == 1))
+	if (likely(refcount_read(&skb->users) == 1))
 		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users)))
+	else if (likely(!refcount_dec_and_test(&skb->users)))
 		return;
 	trace_kfree_skb(skb, __builtin_return_address(0));
 	__kfree_skb(skb);
@@ -748,9 +748,9 @@ void consume_skb(struct sk_buff *skb)
 {
 	if (unlikely(!skb))
 		return;
-	if (likely(atomic_read(&skb->users) == 1))
+	if (likely(refcount_read(&skb->users) == 1))
 		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users)))
+	else if (likely(!refcount_dec_and_test(&skb->users)))
 		return;
 	trace_consume_skb(skb);
 	__kfree_skb(skb);
@@ -807,9 +807,9 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
 		return;
 	}
 
-	if (likely(atomic_read(&skb->users) == 1))
+	if (likely(refcount_read(&skb->users) == 1))
 		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users)))
+	else if (likely(!refcount_dec_and_test(&skb->users)))
 		return;
 	/* if reaching here SKB is ready to free */
 	trace_consume_skb(skb);
@@ -906,7 +906,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	C(head_frag);
 	C(data);
 	C(truesize);
-	atomic_set(&n->users, 1);
+	refcount_set(&n->users, 1);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
 	skb->cloned = 1;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index b4019a5..c734eea 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -351,7 +351,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
-		atomic_inc(&skb->users);
+		refcount_inc(&skb->users);
 		ireq->pktopts = skb;
 	}
 	ireq->ir_iif = sk->sk_bound_dev_if;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 895ff65..2626a1d 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -185,7 +185,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	if (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
-		atomic_inc(&skb->users);
+		refcount_inc(&skb->users);
 		ireq->pktopts = skb;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bdbc432..21bb2fc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -718,7 +718,7 @@ static void tcp_v6_init_req(struct request_sock *req,
 	     np->rxopt.bits.rxinfo ||
 	     np->rxopt.bits.rxoinfo || np->rxopt.bits.rxhlim ||
 	     np->rxopt.bits.rxohlim || np->repflow)) {
-		atomic_inc(&skb->users);
+		refcount_inc(&skb->users);
 		ireq->pktopts = skb;
 	}
 }
diff --git a/net/key/af_key.c b/net/key/af_key.c
index c6252ed..9d96b82 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -194,11 +194,11 @@ static int pfkey_broadcast_one(struct sk_buff *skb, struct sk_buff **skb2,
 
 	sock_hold(sk);
 	if (*skb2 == NULL) {
-		if (atomic_read(&skb->users) != 1) {
+		if (refcount_read(&skb->users) != 1) {
 			*skb2 = skb_clone(skb, allocation);
 		} else {
 			*skb2 = skb;
-			atomic_inc(&skb->users);
+			refcount_inc(&skb->users);
 		}
 	}
 	if (*skb2 != NULL) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7b73c7c..7dac4a9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1797,7 +1797,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	if (dst_group) {
-		atomic_inc(&skb->users);
+		refcount_inc(&skb->users);
 		netlink_broadcast(sk, skb, dst_portid, dst_group, GFP_KERNEL);
 	}
 	err = netlink_unicast(sk, skb, dst_portid, msg->msg_flags&MSG_DONTWAIT);
@@ -2175,7 +2175,7 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	struct netlink_sock *nlk;
 	int ret;
 
-	atomic_inc(&skb->users);
+	refcount_inc(&skb->users);
 
 	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).portid);
 	if (sk == NULL) {
@@ -2332,7 +2332,7 @@ int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 		int exclude_portid = 0;
 
 		if (report) {
-			atomic_inc(&skb->users);
+			refcount_inc(&skb->users);
 			exclude_portid = portid;
 		}
 
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index 67b02c4..b8985d0 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -27,7 +27,7 @@ void rxrpc_new_skb(struct sk_buff *skb, enum rxrpc_skb_trace op)
 {
 	const void *here = __builtin_return_address(0);
 	int n = atomic_inc_return(select_skb_count(op));
-	trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
+	trace_rxrpc_skb(skb, op, refcount_read(&skb->users), n, here);
 }
 
 /*
@@ -38,7 +38,7 @@ void rxrpc_see_skb(struct sk_buff *skb, enum rxrpc_skb_trace op)
 	const void *here = __builtin_return_address(0);
 	if (skb) {
 		int n = atomic_read(select_skb_count(op));
-		trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
+		trace_rxrpc_skb(skb, op, refcount_read(&skb->users), n, here);
 	}
 }
 
@@ -49,7 +49,7 @@ void rxrpc_get_skb(struct sk_buff *skb, enum rxrpc_skb_trace op)
 {
 	const void *here = __builtin_return_address(0);
 	int n = atomic_inc_return(select_skb_count(op));
-	trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
+	trace_rxrpc_skb(skb, op, refcount_read(&skb->users), n, here);
 	skb_get(skb);
 }
 
@@ -63,7 +63,7 @@ void rxrpc_free_skb(struct sk_buff *skb, enum rxrpc_skb_trace op)
 		int n;
 		CHECK_SLAB_OKAY(&skb->users);
 		n = atomic_dec_return(select_skb_count(op));
-		trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
+		trace_rxrpc_skb(skb, op, refcount_read(&skb->users), n, here);
 		kfree_skb(skb);
 	}
 }
@@ -78,7 +78,7 @@ void rxrpc_lose_skb(struct sk_buff *skb, enum rxrpc_skb_trace op)
 		int n;
 		CHECK_SLAB_OKAY(&skb->users);
 		n = atomic_dec_return(select_skb_count(op));
-		trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
+		trace_rxrpc_skb(skb, op, refcount_read(&skb->users), n, here);
 		kfree_skb(skb);
 	}
 }
@@ -93,7 +93,7 @@ void rxrpc_purge_queue(struct sk_buff_head *list)
 	while ((skb = skb_dequeue((list))) != NULL) {
 		int n = atomic_dec_return(select_skb_count(rxrpc_skb_rx_purged));
 		trace_rxrpc_skb(skb, rxrpc_skb_rx_purged,
-				atomic_read(&skb->users), n, here);
+				refcount_read(&skb->users), n, here);
 		kfree_skb(skb);
 	}
 }
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index db352e5..1d6dae9 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1094,7 +1094,7 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 				 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
 				 "illegal chunk", ntohl(chunk->subh.data_hdr->tsn),
 				 chunk->skb ? chunk->skb->head : NULL, chunk->skb ?
-				 atomic_read(&chunk->skb->users) : -1);
+				 refcount_read(&chunk->skb->users) : -1);
 
 			/* Add the chunk to the packet.  */
 			status = sctp_packet_transmit_chunk(packet, chunk, 0, gfp);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6f0a9be..c1120d5 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7421,7 +7421,7 @@ struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
 		if (flags & MSG_PEEK) {
 			skb = skb_peek(&sk->sk_receive_queue);
 			if (skb)
-				atomic_inc(&skb->users);
+				refcount_inc(&skb->users);
 		} else {
 			skb = __skb_dequeue(&sk->sk_receive_queue);
 		}
-- 
2.7.4
