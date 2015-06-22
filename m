From: Maninder Singh <maninder1.s@samsung.com>
Subject: [RFC PATCH v2] packet: remove handling of tx_ring
Date: Mon, 22 Jun 2015 11:24:57 +0530
Message-ID: <1434952497-15216-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>
To: davem@davemloft.net, willemb@google.com, dborkman@redhat.com,
	al.drozdov@gmail.com, viro@zeniv.linux.org.uk,
	eyal.birger@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fransklaver@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v1 = replace if()/BUG with BUG_ON() for tx_ring.

v2 = remove handling of tx_ring in prb_setup_retire_blk_timer
for TPACKET_V3 because init_prb_bdqc is called only for NULL tx_ring 
and thus prb_setup_retire_blk_timer for NULL tx_ring only.

And also in funciton init_prb_bdqc there is no usage of tx_ring.
Thus removing tx_ring from init_prb_bdqc.

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Suggested-by: Frans Klaver <fransklaver@gmail.com>
---
 net/packet/af_packet.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fd51641..aeafcf0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -543,15 +543,11 @@ static void prb_init_blk_timer(struct packet_sock *po,
 	pkc->retire_blk_timer.expires = jiffies;
 }
 
-static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
+static void prb_setup_retire_blk_timer(struct packet_sock *po)
 {
 	struct tpacket_kbdq_core *pkc;
 
-	if (tx_ring)
-		BUG();
-
-	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
-			GET_PBDQC_FROM_RB(&po->rx_ring);
+	pkc = GET_PBDQC_FROM_RB(&po->rx_ring);
 	prb_init_blk_timer(po, pkc, prb_retire_rx_blk_timer_expired);
 }
 
@@ -607,7 +603,7 @@ static void prb_init_ft_ops(struct tpacket_kbdq_core *p1,
 static void init_prb_bdqc(struct packet_sock *po,
 			struct packet_ring_buffer *rb,
 			struct pgv *pg_vec,
-			union tpacket_req_u *req_u, int tx_ring)
+			union tpacket_req_u *req_u)
 {
 	struct tpacket_kbdq_core *p1 = GET_PBDQC_FROM_RB(rb);
 	struct tpacket_block_desc *pbd;
@@ -634,7 +630,7 @@ static void init_prb_bdqc(struct packet_sock *po,
 
 	p1->max_frame_len = p1->kblk_size - BLK_PLUS_PRIV(p1->blk_sizeof_priv);
 	prb_init_ft_ops(p1, req_u);
-	prb_setup_retire_blk_timer(po, tx_ring);
+	prb_setup_retire_blk_timer(po);
 	prb_open_block(p1, pbd);
 }
 
@@ -4001,7 +3997,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		 * it above but just being paranoid
 		 */
 			if (!tx_ring)
-				init_prb_bdqc(po, rb, pg_vec, req_u, tx_ring);
+				init_prb_bdqc(po, rb, pg_vec, req_u);
 			break;
 		default:
 			break;
-- 
1.7.9.5
