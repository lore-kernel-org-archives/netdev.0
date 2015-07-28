From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [PATCH] packet: tpacket_snd(): fix signed/unsigned comparison
Date: Tue, 28 Jul 2015 13:57:01 +0300
Message-ID: <1438081021-1321-1-git-send-email-al.drozdov@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eyal Birger <eyal.birger@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tpacket_fill_skb() can return a negative value (-errno) which
is stored in tp_len variable. In that case the following
condition will be (but shouldn't be) true:

tp_len > dev->mtu + dev->hard_header_len

as dev->mtu and dev->hard_header_len are both unsigned.

That may lead to just returning an incorrect EMSGSIZE errno
to the user.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
---
 net/packet/af_packet.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c9e8741..d1d3625 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2403,7 +2403,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		}
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 					  addr, hlen);
-		if (tp_len > dev->mtu + dev->hard_header_len) {
+		if (likely(tp_len >= 0) &&
+		    tp_len > dev->mtu + dev->hard_header_len) {
 			struct ethhdr *ehdr;
 			/* Earlier code assumed this would be a VLAN pkt,
 			 * double-check this now that we have the actual
-- 
1.9.1
