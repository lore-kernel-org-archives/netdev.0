From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] af_packet: de-inline some helper functions
Date: Wed, 2 Nov 2011 14:00:49 -0700
Message-ID: <20111102210049.GA3697@quad.lixom.net>
References: <1320266081-1387-1-git-send-email-olof@lixom.net>
 <20111102.163658.136546552375950246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, loke.chetan@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54320 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab1KBVAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 17:00:30 -0400
Received: by qabj40 with SMTP id j40so561281qab.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 14:00:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20111102.163658.136546552375950246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This popped some compiler errors due to mismatched prototypes. Just
remove most manual inlines, the compiler should be able to figure out
what makes sense to inline and not.

net/packet/af_packet.c:252: warning: 'prb_curr_blk_in_use' declared inline after being called
net/packet/af_packet.c:252: warning: previous declaration of 'prb_curr_blk_in_use' was here
net/packet/af_packet.c:258: warning: 'prb_queue_frozen' declared inline after being called
net/packet/af_packet.c:258: warning: previous declaration of 'prb_queue_frozen' was here
net/packet/af_packet.c:248: warning: 'packet_previous_frame' declared inline after being called
net/packet/af_packet.c:248: warning: previous declaration of 'packet_previous_frame' was here
net/packet/af_packet.c:251: warning: 'packet_increment_head' declared inline after being called
net/packet/af_packet.c:251: warning: previous declaration of 'packet_increment_head' was here

Signed-off-by: Olof Johansson <olof@lixom.net>
Cc: Chetan Loke <loke.chetan@gmail.com>
---
On Wed, Nov 02, 2011 at 04:36:58PM -0400, David Miller wrote:
> From: Olof Johansson <olof@lixom.net>
> Date: Wed,  2 Nov 2011 13:34:41 -0700
> 
> > Dave, let me know if you prefer to shuffle code around and move the
> > inline helpers to the top instead -- I went with the smaller change by
> > default.
> 
> Inline shouldn't be used at all, let the compiler decide.

Sounds reasonable. How about this -- I took out all but one that was
static inline __pure? 

I could go back and do only those who cause warnings if you prefer, but
that would mean it would be a bit random what is inline and not when
someone reads the code down the road.


-Olof

 net/packet/af_packet.c |   52 ++++++++++++++++++++++++------------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 03bb45a..82a6f34 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -335,7 +335,7 @@ struct packet_skb_cb {
 	(((x)->kactive_blk_num < ((x)->knum_blocks-1)) ? \
 	((x)->kactive_blk_num+1) : 0)
 
-static inline struct packet_sock *pkt_sk(struct sock *sk)
+static struct packet_sock *pkt_sk(struct sock *sk)
 {
 	return (struct packet_sock *)sk;
 }
@@ -477,7 +477,7 @@ static void *packet_lookup_frame(struct packet_sock *po,
 	return h.raw;
 }
 
-static inline void *packet_current_frame(struct packet_sock *po,
+static void *packet_current_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status)
 {
@@ -715,7 +715,7 @@ out:
 	spin_unlock(&po->sk.sk_receive_queue.lock);
 }
 
-static inline void prb_flush_block(struct tpacket_kbdq_core *pkc1,
+static void prb_flush_block(struct tpacket_kbdq_core *pkc1,
 		struct tpacket_block_desc *pbd1, __u32 status)
 {
 	/* Flush everything minus the block header */
@@ -793,7 +793,7 @@ static void prb_close_block(struct tpacket_kbdq_core *pkc1,
 	pkc1->kactive_blk_num = GET_NEXT_PRB_BLK_NUM(pkc1);
 }
 
-static inline void prb_thaw_queue(struct tpacket_kbdq_core *pkc)
+static void prb_thaw_queue(struct tpacket_kbdq_core *pkc)
 {
 	pkc->reset_pending_on_curr_blk = 0;
 }
@@ -869,7 +869,7 @@ static void prb_open_block(struct tpacket_kbdq_core *pkc1,
  *         case and __packet_lookup_frame_in_block will check if block-0
  *         is free and can now be re-used.
  */
-static inline void prb_freeze_queue(struct tpacket_kbdq_core *pkc,
+static void prb_freeze_queue(struct tpacket_kbdq_core *pkc,
 				  struct packet_sock *po)
 {
 	pkc->reset_pending_on_curr_blk = 1;
@@ -940,36 +940,36 @@ static void prb_retire_current_block(struct tpacket_kbdq_core *pkc,
 	BUG();
 }
 
-static inline int prb_curr_blk_in_use(struct tpacket_kbdq_core *pkc,
+static int prb_curr_blk_in_use(struct tpacket_kbdq_core *pkc,
 				      struct tpacket_block_desc *pbd)
 {
 	return TP_STATUS_USER & BLOCK_STATUS(pbd);
 }
 
-static inline int prb_queue_frozen(struct tpacket_kbdq_core *pkc)
+static int prb_queue_frozen(struct tpacket_kbdq_core *pkc)
 {
 	return pkc->reset_pending_on_curr_blk;
 }
 
-static inline void prb_clear_blk_fill_status(struct packet_ring_buffer *rb)
+static void prb_clear_blk_fill_status(struct packet_ring_buffer *rb)
 {
 	struct tpacket_kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
 	atomic_dec(&pkc->blk_fill_in_prog);
 }
 
-static inline void prb_fill_rxhash(struct tpacket_kbdq_core *pkc,
+static void prb_fill_rxhash(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
 	ppd->hv1.tp_rxhash = skb_get_rxhash(pkc->skb);
 }
 
-static inline void prb_clear_rxhash(struct tpacket_kbdq_core *pkc,
+static void prb_clear_rxhash(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
 	ppd->hv1.tp_rxhash = 0;
 }
 
-static inline void prb_fill_vlan_info(struct tpacket_kbdq_core *pkc,
+static void prb_fill_vlan_info(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
 	if (vlan_tx_tag_present(pkc->skb)) {
@@ -991,7 +991,7 @@ static void prb_run_all_ft_ops(struct tpacket_kbdq_core *pkc,
 		prb_clear_rxhash(pkc, ppd);
 }
 
-static inline void prb_fill_curr_block(char *curr,
+static void prb_fill_curr_block(char *curr,
 				struct tpacket_kbdq_core *pkc,
 				struct tpacket_block_desc *pbd,
 				unsigned int len)
@@ -1071,7 +1071,7 @@ static void *__packet_lookup_frame_in_block(struct packet_sock *po,
 	return NULL;
 }
 
-static inline void *packet_current_rx_frame(struct packet_sock *po,
+static void *packet_current_rx_frame(struct packet_sock *po,
 					    struct sk_buff *skb,
 					    int status, unsigned int len)
 {
@@ -1091,7 +1091,7 @@ static inline void *packet_current_rx_frame(struct packet_sock *po,
 	}
 }
 
-static inline void *prb_lookup_block(struct packet_sock *po,
+static void *prb_lookup_block(struct packet_sock *po,
 				     struct packet_ring_buffer *rb,
 				     unsigned int previous,
 				     int status)
@@ -1104,7 +1104,7 @@ static inline void *prb_lookup_block(struct packet_sock *po,
 	return pbd;
 }
 
-static inline int prb_previous_blk_num(struct packet_ring_buffer *rb)
+static int prb_previous_blk_num(struct packet_ring_buffer *rb)
 {
 	unsigned int prev;
 	if (rb->prb_bdqc.kactive_blk_num)
@@ -1115,7 +1115,7 @@ static inline int prb_previous_blk_num(struct packet_ring_buffer *rb)
 }
 
 /* Assumes caller has held the rx_queue.lock */
-static inline void *__prb_previous_block(struct packet_sock *po,
+static void *__prb_previous_block(struct packet_sock *po,
 					 struct packet_ring_buffer *rb,
 					 int status)
 {
@@ -1123,7 +1123,7 @@ static inline void *__prb_previous_block(struct packet_sock *po,
 	return prb_lookup_block(po, rb, previous, status);
 }
 
-static inline void *packet_previous_rx_frame(struct packet_sock *po,
+static void *packet_previous_rx_frame(struct packet_sock *po,
 					     struct packet_ring_buffer *rb,
 					     int status)
 {
@@ -1133,7 +1133,7 @@ static inline void *packet_previous_rx_frame(struct packet_sock *po,
 	return __prb_previous_block(po, rb, status);
 }
 
-static inline void packet_increment_rx_head(struct packet_sock *po,
+static void packet_increment_rx_head(struct packet_sock *po,
 					    struct packet_ring_buffer *rb)
 {
 	switch (po->tp_version) {
@@ -1148,7 +1148,7 @@ static inline void packet_increment_rx_head(struct packet_sock *po,
 	}
 }
 
-static inline void *packet_previous_frame(struct packet_sock *po,
+static void *packet_previous_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status)
 {
@@ -1156,7 +1156,7 @@ static inline void *packet_previous_frame(struct packet_sock *po,
 	return packet_lookup_frame(po, rb, previous, status);
 }
 
-static inline void packet_increment_head(struct packet_ring_buffer *buff)
+static void packet_increment_head(struct packet_ring_buffer *buff)
 {
 	buff->head = buff->head != buff->frame_max ? buff->head+1 : 0;
 }
@@ -1558,7 +1558,7 @@ out_free:
 	return err;
 }
 
-static inline unsigned int run_filter(const struct sk_buff *skb,
+static unsigned int run_filter(const struct sk_buff *skb,
 				      const struct sock *sk,
 				      unsigned int res)
 {
@@ -2167,10 +2167,10 @@ out:
 	return err;
 }
 
-static inline struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
-					       size_t reserve, size_t len,
-					       size_t linear, int noblock,
-					       int *err)
+static struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
+				        size_t reserve, size_t len,
+				        size_t linear, int noblock,
+				        int *err)
 {
 	struct sk_buff *skb;
 
@@ -3494,7 +3494,7 @@ static void free_pg_vec(struct pgv *pg_vec, unsigned int order,
 	kfree(pg_vec);
 }
 
-static inline char *alloc_one_pg_vec_page(unsigned long order)
+static char *alloc_one_pg_vec_page(unsigned long order)
 {
 	char *buffer = NULL;
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP |
-- 
1.7.4.1
