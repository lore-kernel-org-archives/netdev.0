From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [PATCH] af_packet: don't pass empty blocks for PACKET_V3
Date: Thu,  5 Feb 2015 08:58:11 +0300
Message-ID: <1423115891-3578-1-git-send-email-al.drozdov@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Willem de Bruijn <willemb@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't close an empty block on timeout. Its meaningless to
pass it to the user. Moreover, passing empty blocks wastes
CPU & buffer space increasing probability of packets
dropping on small timeouts.

Side effect of this patch is indefinite user-space wait
in poll on idle links. But, I believe its better to set
timeout for poll(2) when needed than to get empty blocks
every millisecond when not needed.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
---
 net/packet/af_packet.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9cfe2e1..9a2f70a 100644
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
