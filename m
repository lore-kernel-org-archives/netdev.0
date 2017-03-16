From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 06/17] net: convert sock.sk_wmem_alloc from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:28:56 +0200
Message-ID: <1489678147-21404-7-git-send-email-elena.reshetova@intel.com>
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
 drivers/atm/fore200e.c   | 12 +-----------
 drivers/atm/he.c         |  2 +-
 drivers/atm/idt77252.c   |  4 ++--
 include/linux/atmdev.h   |  2 +-
 include/net/sock.h       |  8 ++++----
 net/atm/br2684.c         |  2 +-
 net/atm/clip.c           |  2 +-
 net/atm/common.c         | 10 +++++-----
 net/atm/lec.c            |  4 ++--
 net/atm/mpc.c            |  4 ++--
 net/atm/pppoatm.c        |  2 +-
 net/atm/raw.c            |  2 +-
 net/atm/signaling.c      |  2 +-
 net/caif/caif_socket.c   |  2 +-
 net/core/datagram.c      |  2 +-
 net/core/skbuff.c        |  2 +-
 net/core/sock.c          | 26 +++++++++++++-------------
 net/ipv4/af_inet.c       |  2 +-
 net/ipv4/esp4.c          |  2 +-
 net/ipv4/ip_output.c     |  6 +++---
 net/ipv4/tcp.c           |  4 ++--
 net/ipv4/tcp_offload.c   |  2 +-
 net/ipv4/tcp_output.c    | 13 ++++++-------
 net/ipv6/esp6.c          |  2 +-
 net/ipv6/ip6_output.c    |  4 ++--
 net/kcm/kcmproc.c        |  2 +-
 net/key/af_key.c         |  2 +-
 net/netlink/af_netlink.c |  2 +-
 net/packet/af_packet.c   |  4 ++--
 net/phonet/socket.c      |  2 +-
 net/rds/tcp_send.c       |  2 +-
 net/rxrpc/af_rxrpc.c     |  4 ++--
 net/sched/sch_atm.c      |  2 +-
 net/sctp/output.c        |  2 +-
 net/sctp/proc.c          |  2 +-
 net/sctp/socket.c        |  4 ++--
 net/unix/af_unix.c       |  6 +++---
 37 files changed, 73 insertions(+), 84 deletions(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 637c3e6..b770d18 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -924,12 +924,7 @@ fore200e_tx_irq(struct fore200e* fore200e)
 		else {
 		    dev_kfree_skb_any(entry->skb);
 		}
-#if 1
-		/* race fixed by the above incarnation mechanism, but... */
-		if (atomic_read(&sk_atm(vcc)->sk_wmem_alloc) < 0) {
-		    atomic_set(&sk_atm(vcc)->sk_wmem_alloc, 0);
-		}
-#endif
+
 		/* check error condition */
 		if (*entry->status & STATUS_ERROR)
 		    atomic_inc(&vcc->stats->tx_err);
@@ -1130,13 +1125,9 @@ fore200e_push_rpd(struct fore200e* fore200e, struct atm_vcc* vcc, struct rpd* rp
 	return -ENOMEM;
     }
 
-    ASSERT(atomic_read(&sk_atm(vcc)->sk_wmem_alloc) >= 0);
-
     vcc->push(vcc, skb);
     atomic_inc(&vcc->stats->rx);
 
-    ASSERT(atomic_read(&sk_atm(vcc)->sk_wmem_alloc) >= 0);
-
     return 0;
 }
 
@@ -1572,7 +1563,6 @@ fore200e_send(struct atm_vcc *vcc, struct sk_buff *skb)
     unsigned long           flags;
 
     ASSERT(vcc);
-    ASSERT(atomic_read(&sk_atm(vcc)->sk_wmem_alloc) >= 0);
     ASSERT(fore200e);
     ASSERT(fore200e_vcc);
 
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 3617659..fc1bbdb 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2395,7 +2395,7 @@ he_close(struct atm_vcc *vcc)
 		 * TBRQ, the host issues the close command to the adapter.
 		 */
 
-		while (((tx_inuse = atomic_read(&sk_atm(vcc)->sk_wmem_alloc)) > 1) &&
+		while (((tx_inuse = refcount_read(&sk_atm(vcc)->sk_wmem_alloc)) > 1) &&
 		       (retry < MAX_RETRY)) {
 			msleep(sleep);
 			if (sleep < 250)
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 5ec1095..20eda87 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -724,7 +724,7 @@ push_on_scq(struct idt77252_dev *card, struct vc_map *vc, struct sk_buff *skb)
 		struct sock *sk = sk_atm(vcc);
 
 		vc->estimator->cells += (skb->len + 47) / 48;
-		if (atomic_read(&sk->sk_wmem_alloc) >
+		if (refcount_read(&sk->sk_wmem_alloc) >
 		    (sk->sk_sndbuf >> 1)) {
 			u32 cps = vc->estimator->maxcps;
 
@@ -2012,7 +2012,7 @@ idt77252_send_oam(struct atm_vcc *vcc, void *cell, int flags)
 		atomic_inc(&vcc->stats->tx_err);
 		return -ENOMEM;
 	}
-	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 
 	memcpy(skb_put(skb, 52), cell, 52);
 
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index c1da539..4d97a89 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -254,7 +254,7 @@ static inline void atm_return(struct atm_vcc *vcc,int truesize)
 
 static inline int atm_may_send(struct atm_vcc *vcc,unsigned int size)
 {
-	return (size + atomic_read(&sk_atm(vcc)->sk_wmem_alloc)) <
+	return (size + refcount_read(&sk_atm(vcc)->sk_wmem_alloc)) <
 	       sk_atm(vcc)->sk_sndbuf;
 }
 
diff --git a/include/net/sock.h b/include/net/sock.h
index c519de7..24dcdba 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -388,7 +388,7 @@ struct sock {
 
 	/* ===== cache line for TX ===== */
 	int			sk_wmem_queued;
-	atomic_t		sk_wmem_alloc;
+	refcount_t		sk_wmem_alloc;
 	unsigned long		sk_tsq_flags;
 	struct sk_buff		*sk_send_head;
 	struct sk_buff_head	sk_write_queue;
@@ -1916,7 +1916,7 @@ static inline int skb_copy_to_page_nocache(struct sock *sk, struct iov_iter *fro
  */
 static inline int sk_wmem_alloc_get(const struct sock *sk)
 {
-	return atomic_read(&sk->sk_wmem_alloc) - 1;
+	return refcount_read(&sk->sk_wmem_alloc) - 1;
 }
 
 /**
@@ -2060,7 +2060,7 @@ static inline unsigned long sock_wspace(struct sock *sk)
 	int amt = 0;
 
 	if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
-		amt = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+		amt = sk->sk_sndbuf - refcount_read(&sk->sk_wmem_alloc);
 		if (amt < 0)
 			amt = 0;
 	}
@@ -2141,7 +2141,7 @@ bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag);
  */
 static inline bool sock_writeable(const struct sock *sk)
 {
-	return atomic_read(&sk->sk_wmem_alloc) < (sk->sk_sndbuf >> 1);
+	return refcount_read(&sk->sk_wmem_alloc) < (sk->sk_sndbuf >> 1);
 }
 
 static inline gfp_t gfp_any(void)
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index fca84e1..4e11119 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -252,7 +252,7 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
-	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 33e0940..e2e1318 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -381,7 +381,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 		memcpy(here, llc_oui, sizeof(llc_oui));
 		((__be16 *) here)[3] = skb->protocol;
 	}
-	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	entry->vccs->last_use = jiffies;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, vcc, vcc->dev);
diff --git a/net/atm/common.c b/net/atm/common.c
index 9613381..e58d938 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -75,7 +75,7 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
 	while (!(skb = alloc_skb(size, GFP_KERNEL)))
 		schedule();
 	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk->sk_wmem_alloc);
 	return skb;
 }
 
@@ -85,9 +85,9 @@ static void vcc_sock_destruct(struct sock *sk)
 		printk(KERN_DEBUG "%s: rmem leakage (%d bytes) detected.\n",
 		       __func__, atomic_read(&sk->sk_rmem_alloc));
 
-	if (atomic_read(&sk->sk_wmem_alloc))
+	if (refcount_read(&sk->sk_wmem_alloc))
 		printk(KERN_DEBUG "%s: wmem leakage (%d bytes) detected.\n",
-		       __func__, atomic_read(&sk->sk_wmem_alloc));
+		       __func__, refcount_read(&sk->sk_wmem_alloc));
 }
 
 static void vcc_def_wakeup(struct sock *sk)
@@ -106,7 +106,7 @@ static inline int vcc_writable(struct sock *sk)
 	struct atm_vcc *vcc = atm_sk(sk);
 
 	return (vcc->qos.txtp.max_sdu +
-		atomic_read(&sk->sk_wmem_alloc)) <= sk->sk_sndbuf;
+		refcount_read(&sk->sk_wmem_alloc)) <= sk->sk_sndbuf;
 }
 
 static void vcc_write_space(struct sock *sk)
@@ -161,7 +161,7 @@ int vcc_create(struct net *net, struct socket *sock, int protocol, int family, i
 	memset(&vcc->local, 0, sizeof(struct sockaddr_atmsvc));
 	memset(&vcc->remote, 0, sizeof(struct sockaddr_atmsvc));
 	vcc->qos.txtp.max_sdu = 1 << 16; /* for meta VCs */
-	atomic_set(&sk->sk_wmem_alloc, 1);
+	refcount_set(&sk->sk_wmem_alloc, 1);
 	atomic_set(&sk->sk_rmem_alloc, 0);
 	vcc->push = NULL;
 	vcc->pop = NULL;
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 09cfe87..7554571 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -181,7 +181,7 @@ lec_send(struct atm_vcc *vcc, struct sk_buff *skb)
 	ATM_SKB(skb)->vcc = vcc;
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 
-	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	if (vcc->send(vcc, skb) < 0) {
 		dev->stats.tx_dropped++;
 		return;
@@ -345,7 +345,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 	int i;
 	char *tmp;		/* FIXME */
 
-	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
+	WARN_ON(refcount_sub_and_test(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc));
 	mesg = (struct atmlec_msg *)skb->data;
 	tmp = skb->data;
 	tmp += sizeof(struct atmlec_msg);
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index a190800..680a4b9 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -555,7 +555,7 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 					sizeof(struct llc_snap_hdr));
 	}
 
-	atomic_add(skb->truesize, &sk_atm(entry->shortcut)->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk_atm(entry->shortcut)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = entry->shortcut->atm_options;
 	entry->shortcut->send(entry->shortcut, skb);
 	entry->packets_fwded++;
@@ -911,7 +911,7 @@ static int msg_from_mpoad(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	struct mpoa_client *mpc = find_mpc_by_vcc(vcc);
 	struct k_message *mesg = (struct k_message *)skb->data;
-	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
+	WARN_ON(refcount_sub_and_test(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc));
 
 	if (mpc == NULL) {
 		pr_info("no mpc found\n");
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index c4e0984..21d9d34 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -350,7 +350,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 		return 1;
 	}
 
-	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
 		 skb, ATM_SKB(skb)->vcc, ATM_SKB(skb)->vcc->dev);
diff --git a/net/atm/raw.c b/net/atm/raw.c
index 2e17e97..821c079 100644
--- a/net/atm/raw.c
+++ b/net/atm/raw.c
@@ -35,7 +35,7 @@ static void atm_pop_raw(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	pr_debug("(%d) %d -= %d\n",
 		 vcc->vci, sk_wmem_alloc_get(sk), skb->truesize);
-	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
+	WARN_ON(refcount_sub_and_test(skb->truesize, &sk->sk_wmem_alloc));
 	dev_kfree_skb_any(skb);
 	sk->sk_write_space(sk);
 }
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index adb6e3d..ca59496 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -67,7 +67,7 @@ static int sigd_send(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct sock *sk;
 
 	msg = (struct atmsvc_msg *) skb->data;
-	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
+	WARN_ON(refcount_sub_and_test(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc));
 	vcc = *(struct atm_vcc **) &msg->vcc;
 	pr_debug("%d (0x%lx)\n", (int)msg->type, (unsigned long)vcc);
 	sk = sk_atm(vcc);
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index adcad34..0ea2616 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1009,7 +1009,7 @@ static const struct proto_ops caif_stream_ops = {
 static void caif_sock_destructor(struct sock *sk)
 {
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
-	caif_assert(!atomic_read(&sk->sk_wmem_alloc));
+	caif_assert(!refcount_read(&sk->sk_wmem_alloc));
 	caif_assert(sk_unhashed(sk));
 	caif_assert(!sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 281e5d6..d0702d0 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -595,7 +595,7 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
 		skb->data_len += copied;
 		skb->len += copied;
 		skb->truesize += truesize;
-		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
+		refcount_add(truesize, &skb->sk->sk_wmem_alloc);
 		while (copied) {
 			int size = min_t(int, copied, PAGE_SIZE - start);
 			skb_fill_page_desc(skb, frag++, pages[n], start, size);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6911269..e81a27f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2985,7 +2985,7 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 		get_page(pfrag->page);
 
 		skb->truesize += copy;
-		atomic_add(copy, &sk->sk_wmem_alloc);
+		refcount_add(copy, &sk->sk_wmem_alloc);
 		skb->len += copy;
 		skb->data_len += copy;
 		offset += copy;
diff --git a/net/core/sock.c b/net/core/sock.c
index f6fd79f..e830ddc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1404,7 +1404,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		if (likely(sk->sk_net_refcnt))
 			get_net(net);
 		sock_net_set(sk, net);
-		atomic_set(&sk->sk_wmem_alloc, 1);
+		refcount_set(&sk->sk_wmem_alloc, 1);
 
 		mem_cgroup_sk_alloc(sk);
 		cgroup_sk_alloc(&sk->sk_cgrp_data);
@@ -1428,7 +1428,7 @@ static void __sk_destruct(struct rcu_head *head)
 		sk->sk_destruct(sk);
 
 	filter = rcu_dereference_check(sk->sk_filter,
-				       atomic_read(&sk->sk_wmem_alloc) == 0);
+				       refcount_read(&sk->sk_wmem_alloc) == 0);
 	if (filter) {
 		sk_filter_uncharge(sk, filter);
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
@@ -1473,7 +1473,7 @@ void sk_free(struct sock *sk)
 	 * some packets are still in some tx queue.
 	 * If not null, sock_wfree() will call __sk_free(sk) later
 	 */
-	if (atomic_dec_and_test(&sk->sk_wmem_alloc))
+	if (refcount_dec_and_test(&sk->sk_wmem_alloc))
 		__sk_free(sk);
 }
 EXPORT_SYMBOL(sk_free);
@@ -1509,7 +1509,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		/*
 		 * sk_wmem_alloc set to one (see sk_free() and sock_wfree())
 		 */
-		atomic_set(&newsk->sk_wmem_alloc, 1);
+		refcount_set(&newsk->sk_wmem_alloc, 1);
 		atomic_set(&newsk->sk_omem_alloc, 0);
 		skb_queue_head_init(&newsk->sk_receive_queue);
 		skb_queue_head_init(&newsk->sk_write_queue);
@@ -1638,7 +1638,7 @@ void sock_wfree(struct sk_buff *skb)
 		 * Keep a reference on sk_wmem_alloc, this will be released
 		 * after sk_write_space() call
 		 */
-		atomic_sub(len - 1, &sk->sk_wmem_alloc);
+		WARN_ON(refcount_sub_and_test(len - 1, &sk->sk_wmem_alloc));
 		sk->sk_write_space(sk);
 		len = 1;
 	}
@@ -1646,7 +1646,7 @@ void sock_wfree(struct sk_buff *skb)
 	 * if sk_wmem_alloc reaches 0, we must finish what sk_free()
 	 * could not do because of in-flight packets
 	 */
-	if (atomic_sub_and_test(len, &sk->sk_wmem_alloc))
+	if (refcount_sub_and_test(len, &sk->sk_wmem_alloc))
 		__sk_free(sk);
 }
 EXPORT_SYMBOL(sock_wfree);
@@ -1658,7 +1658,7 @@ void __sock_wfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 
-	if (atomic_sub_and_test(skb->truesize, &sk->sk_wmem_alloc))
+	if (refcount_sub_and_test(skb->truesize, &sk->sk_wmem_alloc))
 		__sk_free(sk);
 }
 
@@ -1680,7 +1680,7 @@ void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	 * is enough to guarantee sk_free() wont free this sock until
 	 * all in-flight packets are completed
 	 */
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk->sk_wmem_alloc);
 }
 EXPORT_SYMBOL(skb_set_owner_w);
 
@@ -1708,7 +1708,7 @@ void skb_orphan_partial(struct sk_buff *skb)
 	    || skb->destructor == tcp_wfree
 #endif
 		) {
-		atomic_sub(skb->truesize - 1, &skb->sk->sk_wmem_alloc);
+		WARN_ON(refcount_sub_and_test(skb->truesize - 1, &skb->sk->sk_wmem_alloc));
 		skb->truesize = 1;
 	} else {
 		skb_orphan(skb);
@@ -1767,7 +1767,7 @@ EXPORT_SYMBOL(sock_i_ino);
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority)
 {
-	if (force || atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf) {
+	if (force || refcount_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf) {
 		struct sk_buff *skb = alloc_skb(size, priority);
 		if (skb) {
 			skb_set_owner_w(skb, sk);
@@ -1842,7 +1842,7 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
 			break;
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)
+		if (refcount_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)
 			break;
 		if (sk->sk_shutdown & SEND_SHUTDOWN)
 			break;
@@ -2145,7 +2145,7 @@ int __sk_mem_raise_allocated(struct sock *sk, int size, int amt, int kind)
 		if (sk->sk_type == SOCK_STREAM) {
 			if (sk->sk_wmem_queued < prot->sysctl_wmem[0])
 				return 1;
-		} else if (atomic_read(&sk->sk_wmem_alloc) <
+		} else if (refcount_read(&sk->sk_wmem_alloc) <
 			   prot->sysctl_wmem[0])
 				return 1;
 	}
@@ -2411,7 +2411,7 @@ static void sock_def_write_space(struct sock *sk)
 	/* Do not wake up a writer until he can make "significant"
 	 * progress.  --DaveM
 	 */
-	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
+	if ((refcount_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
 		wq = rcu_dereference(sk->sk_wq);
 		if (skwq_has_sleeper(wq))
 			wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5091f46..4d89969 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -150,7 +150,7 @@ void inet_sock_destruct(struct sock *sk)
 	}
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(refcount_read(&sk->sk_wmem_alloc));
 	WARN_ON(sk->sk_wmem_queued);
 	WARN_ON(sk->sk_forward_alloc);
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b1e2444..d02afc2 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -337,7 +337,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			skb->data_len += tailen;
 			skb->truesize += tailen;
 			if (sk)
-				atomic_add(tailen, &sk->sk_wmem_alloc);
+				refcount_add(tailen, &sk->sk_wmem_alloc);
 
 			skb_push(skb, -skb_network_offset(skb));
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 737ce82..a2ea706 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1036,7 +1036,7 @@ static int __ip_append_data(struct sock *sk,
 						(flags & MSG_DONTWAIT), &err);
 			} else {
 				skb = NULL;
-				if (atomic_read(&sk->sk_wmem_alloc) <=
+				if (refcount_read(&sk->sk_wmem_alloc) <=
 				    2 * sk->sk_sndbuf)
 					skb = sock_wmalloc(sk,
 							   alloclen + hh_len + 15, 1,
@@ -1144,7 +1144,7 @@ static int __ip_append_data(struct sock *sk,
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
-			atomic_add(copy, &sk->sk_wmem_alloc);
+			refcount_add(copy, &sk->sk_wmem_alloc);
 		}
 		offset += copy;
 		length -= copy;
@@ -1368,7 +1368,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		skb->len += len;
 		skb->data_len += len;
 		skb->truesize += len;
-		atomic_add(len, &sk->sk_wmem_alloc);
+		refcount_add(len, &sk->sk_wmem_alloc);
 		offset += len;
 		size -= len;
 	}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3354a61..1f82de5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -644,7 +644,7 @@ static bool tcp_should_autocork(struct sock *sk, struct sk_buff *skb,
 	return skb->len < size_goal &&
 	       sysctl_tcp_autocorking &&
 	       skb != tcp_write_queue_head(sk) &&
-	       atomic_read(&sk->sk_wmem_alloc) > skb->truesize;
+	       refcount_read(&sk->sk_wmem_alloc) > skb->truesize;
 }
 
 static void tcp_push(struct sock *sk, int flags, int mss_now,
@@ -672,7 +672,7 @@ static void tcp_push(struct sock *sk, int flags, int mss_now,
 		/* It is possible TX completion already happened
 		 * before we set TSQ_THROTTLED.
 		 */
-		if (atomic_read(&sk->sk_wmem_alloc) > skb->truesize)
+		if (refcount_read(&sk->sk_wmem_alloc) > skb->truesize)
 			return;
 	}
 
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index bc68da3..11f69bb 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -152,7 +152,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		swap(gso_skb->sk, skb->sk);
 		swap(gso_skb->destructor, skb->destructor);
 		sum_truesize += skb->truesize;
-		atomic_add(sum_truesize - gso_skb->truesize,
+		refcount_add(sum_truesize - gso_skb->truesize,
 			   &skb->sk->sk_wmem_alloc);
 	}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 22548b5..7cd1283 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -863,12 +863,11 @@ void tcp_wfree(struct sk_buff *skb)
 	struct sock *sk = skb->sk;
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned long flags, nval, oval;
-	int wmem;
 
 	/* Keep one reference on sk_wmem_alloc.
 	 * Will be released by sk_free() from here or tcp_tasklet_func()
 	 */
-	wmem = atomic_sub_return(skb->truesize - 1, &sk->sk_wmem_alloc);
+	WARN_ON(refcount_sub_and_test(skb->truesize - 1, &sk->sk_wmem_alloc));
 
 	/* If this softirq is serviced by ksoftirqd, we are likely under stress.
 	 * Wait until our queues (qdisc + devices) are drained.
@@ -877,7 +876,7 @@ void tcp_wfree(struct sk_buff *skb)
 	 * - chance for incoming ACK (processed by another cpu maybe)
 	 *   to migrate this flow (skb->ooo_okay will be eventually set)
 	 */
-	if (wmem >= SKB_TRUESIZE(1) && this_cpu_ksoftirqd() == current)
+	if (refcount_read(&sk->sk_wmem_alloc) >= SKB_TRUESIZE(1) && this_cpu_ksoftirqd() == current)
 		goto out;
 
 	for (oval = READ_ONCE(sk->sk_tsq_flags);; oval = nval) {
@@ -981,7 +980,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	skb->sk = sk;
 	skb->destructor = skb_is_tcp_pure_ack(skb) ? __sock_wfree : tcp_wfree;
 	skb_set_hash_from_sk(skb, sk);
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+	refcount_add(skb->truesize, &sk->sk_wmem_alloc);
 
 	skb_set_dst_pending_confirm(skb, sk->sk_dst_pending_confirm);
 
@@ -2101,7 +2100,7 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
 	limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
 	limit <<= factor;
 
-	if (atomic_read(&sk->sk_wmem_alloc) > limit) {
+	if (refcount_read(&sk->sk_wmem_alloc) > limit) {
 		/* Always send the 1st or 2nd skb in write queue.
 		 * No need to wait for TX completion to call us back,
 		 * after softirq/tasklet schedule.
@@ -2117,7 +2116,7 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
 		 * test again the condition.
 		 */
 		smp_mb__after_atomic();
-		if (atomic_read(&sk->sk_wmem_alloc) > limit)
+		if (refcount_read(&sk->sk_wmem_alloc) > limit)
 			return true;
 	}
 	return false;
@@ -2735,7 +2734,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 	/* Do not sent more than we queued. 1/4 is reserved for possible
 	 * copying overhead: fragmentation, tunneling, mangling etc.
 	 */
-	if (atomic_read(&sk->sk_wmem_alloc) >
+	if (refcount_read(&sk->sk_wmem_alloc) >
 	    min_t(u32, sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2),
 		  sk->sk_sndbuf))
 		return -EAGAIN;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ff54faa..b8f127e 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -317,7 +317,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 			skb->data_len += tailen;
 			skb->truesize += tailen;
 			if (sk)
-				atomic_add(tailen, &sk->sk_wmem_alloc);
+				refcount_add(tailen, &sk->sk_wmem_alloc);
 
 			skb_push(skb, -skb_network_offset(skb));
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 528b3c1..42a2f73 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1464,7 +1464,7 @@ static int __ip6_append_data(struct sock *sk,
 						(flags & MSG_DONTWAIT), &err);
 			} else {
 				skb = NULL;
-				if (atomic_read(&sk->sk_wmem_alloc) <=
+				if (refcount_read(&sk->sk_wmem_alloc) <=
 				    2 * sk->sk_sndbuf)
 					skb = sock_wmalloc(sk,
 							   alloclen + hh_len, 1,
@@ -1577,7 +1577,7 @@ static int __ip6_append_data(struct sock *sk,
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
-			atomic_add(copy, &sk->sk_wmem_alloc);
+			refcount_add(copy, &sk->sk_wmem_alloc);
 		}
 		offset += copy;
 		length -= copy;
diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index bf75c92..c343ac6 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -162,7 +162,7 @@ static void kcm_format_psock(struct kcm_psock *psock, struct seq_file *seq,
 		   psock->sk->sk_receive_queue.qlen,
 		   atomic_read(&psock->sk->sk_rmem_alloc),
 		   psock->sk->sk_write_queue.qlen,
-		   atomic_read(&psock->sk->sk_wmem_alloc));
+		   refcount_read(&psock->sk->sk_wmem_alloc));
 
 	if (psock->done)
 		seq_puts(seq, "Done ");
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9d96b82..ba00bd3 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -104,7 +104,7 @@ static void pfkey_sock_destruct(struct sock *sk)
 	}
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(refcount_read(&sk->sk_wmem_alloc));
 
 	atomic_dec(&net_pfkey->socks_nr);
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7dac4a9..9332b24 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -341,7 +341,7 @@ static void netlink_sock_destruct(struct sock *sk)
 	}
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(refcount_read(&sk->sk_wmem_alloc));
 	WARN_ON(nlk_sk(sk)->groups);
 }
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a0dbe7c..82eb052 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1320,7 +1320,7 @@ static void packet_sock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_error_queue);
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(refcount_read(&sk->sk_wmem_alloc));
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		pr_err("Attempt to release alive packet socket: %p\n", sk);
@@ -2482,7 +2482,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->data_len = to_write;
 	skb->len += to_write;
 	skb->truesize += to_write;
-	atomic_add(to_write, &po->sk.sk_wmem_alloc);
+	refcount_add(to_write, &po->sk.sk_wmem_alloc);
 
 	while (likely(to_write)) {
 		nr_frags = skb_shinfo(skb)->nr_frags;
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index a6c8da3..27b0b13 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -360,7 +360,7 @@ static unsigned int pn_socket_poll(struct file *file, struct socket *sock,
 		return POLLHUP;
 
 	if (sk->sk_state == TCP_ESTABLISHED &&
-		atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf &&
+		refcount_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf &&
 		atomic_read(&pn->tx_credits))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index dcf4742..592e68b 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -208,7 +208,7 @@ void rds_tcp_write_space(struct sock *sk)
 	tc->t_last_seen_una = rds_tcp_snd_una(tc);
 	rds_send_path_drop_acked(cp, rds_tcp_snd_una(tc), rds_tcp_is_acked);
 
-	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf)
+	if ((refcount_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf)
 		queue_delayed_work(rds_wq, &cp->cp_send_w, 0);
 
 out:
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 7fb59c3..b473ac2 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -56,7 +56,7 @@ static void rxrpc_sock_destructor(struct sock *);
  */
 static inline int rxrpc_writable(struct sock *sk)
 {
-	return atomic_read(&sk->sk_wmem_alloc) < (size_t) sk->sk_sndbuf;
+	return refcount_read(&sk->sk_wmem_alloc) < (size_t) sk->sk_sndbuf;
 }
 
 /*
@@ -665,7 +665,7 @@ static void rxrpc_sock_destructor(struct sock *sk)
 
 	rxrpc_purge_queue(&sk->sk_receive_queue);
 
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(refcount_read(&sk->sk_wmem_alloc));
 	WARN_ON(!sk_unhashed(sk));
 	WARN_ON(sk->sk_socket);
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 2209c2d..2b0778b 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -491,7 +491,7 @@ static void sch_atm_dequeue(unsigned long data)
 			ATM_SKB(skb)->vcc = flow->vcc;
 			memcpy(skb_push(skb, flow->hdr_len), flow->hdr,
 			       flow->hdr_len);
-			atomic_add(skb->truesize,
+			refcount_add(skb->truesize,
 				   &sk_atm(flow->vcc)->sk_wmem_alloc);
 			/* atm.atm_options are already set by atm_tc_enqueue */
 			flow->vcc->send(flow->vcc, skb);
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 71ce6b9..6574281 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -392,7 +392,7 @@ static void sctp_packet_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	 * therefore only reserve a single byte to keep socket around until
 	 * the packet has been transmitted.
 	 */
-	atomic_inc(&sk->sk_wmem_alloc);
+	refcount_inc(&sk->sk_wmem_alloc);
 }
 
 static int sctp_packet_pack(struct sctp_packet *packet,
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 206377f..25cd840 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -365,7 +365,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		assoc->c.sinit_num_ostreams, assoc->max_retrans,
 		assoc->init_retries, assoc->shutdown_retries,
 		assoc->rtx_data_chunks,
-		atomic_read(&sk->sk_wmem_alloc),
+		refcount_read(&sk->sk_wmem_alloc),
 		sk->sk_wmem_queued,
 		sk->sk_sndbuf,
 		sk->sk_rcvbuf);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c1120d5..67dfec1 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -164,7 +164,7 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 				sizeof(struct sk_buff) +
 				sizeof(struct sctp_chunk);
 
-	atomic_add(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
+	refcount_add(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
 	sk->sk_wmem_queued += chunk->skb->truesize;
 	sk_mem_charge(sk, chunk->skb->truesize);
 }
@@ -7539,7 +7539,7 @@ static void sctp_wfree(struct sk_buff *skb)
 				sizeof(struct sk_buff) +
 				sizeof(struct sctp_chunk);
 
-	atomic_sub(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
+	WARN_ON(refcount_sub_and_test(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc));
 
 	/*
 	 * This undoes what is done via sctp_set_owner_w and sk_mem_charge
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a48d403..a74339e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -442,7 +442,7 @@ static int unix_dgram_peer_wake_me(struct sock *sk, struct sock *other)
 static int unix_writable(const struct sock *sk)
 {
 	return sk->sk_state != TCP_LISTEN &&
-	       (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
+	       (refcount_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
 }
 
 static void unix_write_space(struct sock *sk)
@@ -487,7 +487,7 @@ static void unix_sock_destructor(struct sock *sk)
 
 	skb_queue_purge(&sk->sk_receive_queue);
 
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(refcount_read(&sk->sk_wmem_alloc));
 	WARN_ON(!sk_unhashed(sk));
 	WARN_ON(sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
@@ -2024,7 +2024,7 @@ static ssize_t unix_stream_sendpage(struct socket *socket, struct page *page,
 	skb->len += size;
 	skb->data_len += size;
 	skb->truesize += size;
-	atomic_add(size, &sk->sk_wmem_alloc);
+	refcount_add(size, &sk->sk_wmem_alloc);
 
 	if (newskb) {
 		err = unix_scm_to_skb(&scm, skb, false);
-- 
2.7.4
