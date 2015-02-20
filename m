From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [PATCH] af_packet: allow packets defragmentation not only for hash fanout type
Date: Fri, 20 Feb 2015 08:24:27 +0300
Message-ID: <1424409867-23041-1-git-send-email-al.drozdov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Willem de Bruijn <willemb@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Packets defragmentation was introduced for PACKET_FANOUT_HASH only,
see 7736d33f4262 ("packet: Add pre-defragmentation support for ipv4
fanouts")

It may be useful to have defragmentation enabled regardless of
fanout type. Without that, the AF_PACKET user may have to:
1. Collect fragments from different rings
2. Defragment by itself

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
---
 net/packet/af_packet.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9c28cec..99fc628 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1349,14 +1349,14 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
+	if (fanout_has_flag(f, PACKET_FANOUT_FLAG_DEFRAG)) {
+		skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
+		if (!skb)
+			return 0;
+	}
 	switch (f->type) {
 	case PACKET_FANOUT_HASH:
 	default:
-		if (fanout_has_flag(f, PACKET_FANOUT_FLAG_DEFRAG)) {
-			skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
-			if (!skb)
-				return 0;
-		}
 		idx = fanout_demux_hash(f, skb, num);
 		break;
 	case PACKET_FANOUT_LB:
-- 
1.9.1
