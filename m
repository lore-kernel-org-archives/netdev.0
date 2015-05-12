From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 1/6] packet: rollover prepare: move code out of callsites
Date: Tue, 12 May 2015 11:56:45 -0400
Message-ID: <1431446210-13286-2-git-send-email-willemb@google.com>
References: <1431446210-13286-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	david.laight@aculab.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34975 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbbELP4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:56:55 -0400
Received: by ykec202 with SMTP id c202so4615479yke.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:56:54 -0700 (PDT)
In-Reply-To: <1431446210-13286-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

packet_rcv_fanout calls fanout_demux_rollover twice. Move all rollover
logic into the callee to simplify these callsites, especially with
upcoming changes.

The main differences between the two callsites is that the FLAG
variant tests whether the socket previously selected by another
mode (RR, RND, HASH, ..) has room before migrating flows, whereas the
rollover mode has no original socket to test.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9471327..7255bd8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1318,18 +1318,22 @@ static unsigned int fanout_demux_rnd(struct packet_fanout *f,
 
 static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  struct sk_buff *skb,
-					  unsigned int idx, unsigned int skip,
+					  unsigned int idx, bool try_self,
 					  unsigned int num)
 {
 	unsigned int i, j;
 
+	if (try_self && packet_rcv_has_room(pkt_sk(f->arr[idx]), skb))
+		return idx;
+
 	i = j = min_t(int, f->next[idx], num - 1);
 	do {
-		if (i != skip && packet_rcv_has_room(pkt_sk(f->arr[i]), skb)) {
+		if (i != idx && packet_rcv_has_room(pkt_sk(f->arr[i]), skb)) {
 			if (i != j)
 				f->next[idx] = i;
 			return i;
 		}
+
 		if (++i == num)
 			i = 0;
 	} while (i != j);
@@ -1386,17 +1390,14 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 		idx = fanout_demux_qm(f, skb, num);
 		break;
 	case PACKET_FANOUT_ROLLOVER:
-		idx = fanout_demux_rollover(f, skb, 0, (unsigned int) -1, num);
+		idx = fanout_demux_rollover(f, skb, 0, false, num);
 		break;
 	}
 
-	po = pkt_sk(f->arr[idx]);
-	if (fanout_has_flag(f, PACKET_FANOUT_FLAG_ROLLOVER) &&
-	    unlikely(!packet_rcv_has_room(po, skb))) {
-		idx = fanout_demux_rollover(f, skb, idx, idx, num);
-		po = pkt_sk(f->arr[idx]);
-	}
+	if (fanout_has_flag(f, PACKET_FANOUT_FLAG_ROLLOVER))
+		idx = fanout_demux_rollover(f, skb, idx, true, num);
 
+	po = pkt_sk(f->arr[idx]);
 	return po->prot_hook.func(skb, dev, &po->prot_hook, orig_dev);
 }
 
-- 
2.2.0.rc0.207.ga3a616c
