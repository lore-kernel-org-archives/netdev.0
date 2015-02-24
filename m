From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [RESEND PATCH] af_packet: don't pass empty blocks for PACKET_V3
Date: Tue, 24 Feb 2015 08:18:28 +0300
Message-ID: <1424755108-10493-1-git-send-email-al.drozdov@gmail.com>
References: <1423115891-3578-1-git-send-email-al.drozdov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>,
	Dan Collins <dan@dcollins.co.nz>, Guy Harris <guy@alum.mit.edu>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Willem de Bruijn <willemb@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423115891-3578-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before da413eec729d ("packet: Fixed TPACKET V3 to signal poll when block is
closed rather than every packet") poll listening for an af_packet socket was
not signaled if there was no packets to process. After the patch poll is
signaled evety time when block retire timer expires. That happens because
af_packet closes the current block on timeout even if the block is empty.

Passing empty blocks to the user not only wastes CPU but also wastes ring
buffer space increasing probability of packets dropping on small timeouts.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
Cc: Dan Collins <dan@dcollins.co.nz>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Guy Harris <guy@alum.mit.edu>
---
 net/packet/af_packet.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9c28cec..1da46ef 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -698,6 +698,10 @@ static void prb_retire_rx_blk_timer_expired(unsigned long data)
 
 	if (pkc->last_kactive_blk_num == pkc->kactive_blk_num) {
 		if (!frozen) {
+			if (!BLOCK_NUM_PKTS(pbd)) {
+				/* An empty block. Just refresh the timer. */
+				goto refresh_timer;
+			}
 			prb_retire_current_block(pkc, po, TP_STATUS_BLK_TMO);
 			if (!prb_dispatch_next_block(pkc, po))
 				goto refresh_timer;
@@ -798,7 +802,11 @@ static void prb_close_block(struct tpacket_kbdq_core *pkc1,
 		h1->ts_last_pkt.ts_sec = last_pkt->tp_sec;
 		h1->ts_last_pkt.ts_nsec	= last_pkt->tp_nsec;
 	} else {
-		/* Ok, we tmo'd - so get the current time */
+		/* Ok, we tmo'd - so get the current time.
+		 *
+		 * It shouldn't really happen as we don't close empty
+		 * blocks. See prb_retire_rx_blk_timer_expired().
+		 */
 		struct timespec ts;
 		getnstimeofday(&ts);
 		h1->ts_last_pkt.ts_sec = ts.tv_sec;
-- 
1.9.1
