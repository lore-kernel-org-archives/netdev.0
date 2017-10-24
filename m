From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: af_packet: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 01:46:26 -0700
Message-ID: <20171024084626.GA23908@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Mike Maloney <maloney@google.com>,
        Jarno Rajahalme <jarno@ovn.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Mike Maloney <maloney@google.com>
Cc: Jarno Rajahalme <jarno@ovn.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/packet/af_packet.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4f4fa323171d..9603f6ff17a4 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -201,11 +201,8 @@ static void prb_retire_current_block(struct tpacket_kbdq_core *,
 static int prb_queue_frozen(struct tpacket_kbdq_core *);
 static void prb_open_block(struct tpacket_kbdq_core *,
 		struct tpacket_block_desc *);
-static void prb_retire_rx_blk_timer_expired(unsigned long);
+static void prb_retire_rx_blk_timer_expired(struct timer_list *);
 static void _prb_refresh_rx_retire_blk_timer(struct tpacket_kbdq_core *);
-static void prb_init_blk_timer(struct packet_sock *,
-		struct tpacket_kbdq_core *,
-		void (*func) (unsigned long));
 static void prb_fill_rxhash(struct tpacket_kbdq_core *, struct tpacket3_hdr *);
 static void prb_clear_rxhash(struct tpacket_kbdq_core *,
 		struct tpacket3_hdr *);
@@ -540,20 +537,14 @@ static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
 	prb_del_retire_blk_timer(pkc);
 }
 
-static void prb_init_blk_timer(struct packet_sock *po,
-		struct tpacket_kbdq_core *pkc,
-		void (*func) (unsigned long))
-{
-	setup_timer(&pkc->retire_blk_timer, func, (long)po);
-	pkc->retire_blk_timer.expires = jiffies;
-}
-
 static void prb_setup_retire_blk_timer(struct packet_sock *po)
 {
 	struct tpacket_kbdq_core *pkc;
 
 	pkc = GET_PBDQC_FROM_RB(&po->rx_ring);
-	prb_init_blk_timer(po, pkc, prb_retire_rx_blk_timer_expired);
+	timer_setup(&pkc->retire_blk_timer, prb_retire_rx_blk_timer_expired,
+		    0);
+	pkc->retire_blk_timer.expires = jiffies;
 }
 
 static int prb_calc_retire_blk_tmo(struct packet_sock *po,
@@ -671,9 +662,10 @@ static void _prb_refresh_rx_retire_blk_timer(struct tpacket_kbdq_core *pkc)
  * prb_calc_retire_blk_tmo() calculates the tmo.
  *
  */
-static void prb_retire_rx_blk_timer_expired(unsigned long data)
+static void prb_retire_rx_blk_timer_expired(struct timer_list *t)
 {
-	struct packet_sock *po = (struct packet_sock *)data;
+	struct packet_sock *po =
+		from_timer(po, t, rx_ring.prb_bdqc.retire_blk_timer);
 	struct tpacket_kbdq_core *pkc = GET_PBDQC_FROM_RB(&po->rx_ring);
 	unsigned int frozen;
 	struct tpacket_block_desc *pbd;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
