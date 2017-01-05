From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] packet: fix panic in __packet_set_timestamp on tpacket_v3 in tx mode
Date: Thu,  5 Jan 2017 02:34:28 +0100
Message-ID: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
Cc: sowmini.varadhan@oracle.com, willemb@google.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57921 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754004AbdAECGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 21:06:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TX timestamping is in use with TPACKET_V3's TX ring, then we'll
hit the BUG() in __packet_set_timestamp() when ring buffer slot is
returned to user space via tpacket_destruct_skb(). This is due to v3
being assumed as unreachable here, but since 7f953ab2ba46 ("af_packet:
TX_RING support for TPACKET_V3") it's not anymore. Fix it by filling
the timestamp back into the ring slot.

Fixes: 7f953ab2ba46 ("af_packet: TX_RING support for TPACKET_V3")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/packet/af_packet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 7e39087..ddbda25 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -481,6 +481,9 @@ static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
 		h.h2->tp_nsec = ts.tv_nsec;
 		break;
 	case TPACKET_V3:
+		h.h3->tp_sec = ts.tv_sec;
+		h.h3->tp_nsec = ts.tv_nsec;
+		break;
 	default:
 		WARN(1, "TPACKET version not supported.\n");
 		BUG();
-- 
2.5.5
