From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net-packet: fix null pointer exception in rollover mode
Date: Sun, 17 May 2015 19:44:02 -0400
Message-ID: <1431906242-26430-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:33808 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbbEQXoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 19:44:05 -0400
Received: by yhom41 with SMTP id m41so45779824yho.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 16:44:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rollover can be enabled as flag or mode. Allocate state in both cases.
This solves a NULL pointer exception in fanout_demux_rollover on
referencing po->rollover if using mode rollover.

Also make sure that in rollover mode each silo is tried (contrary
to rollover flag, where the main socket is excluded after an initial
try_self).

Tested:
  Passes tools/testing/net/psock_fanout.c, which tests both modes and
  flag. My previous tests were limited to bench_rollover, which only
  stresses the flag. The test now completes safely. it still gives an
  error for mode rollover, because it does not expect the new headroom
  (ROOM_NORMAL) requirement. I will send a separate patch to the test.

Fixes: 0648ab70afe6 ("packet: rollover prepare: per-socket state")

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

I should have run this test and caught this before submission, of
course. Apologies for the oversight.
---
 net/packet/af_packet.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c30d147..fd51641 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1389,7 +1389,7 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  unsigned int idx, bool try_self,
 					  unsigned int num)
 {
-	struct packet_sock *po, *po_next;
+	struct packet_sock *po, *po_next, *po_skip = NULL;
 	unsigned int i, j, room = ROOM_NONE;
 
 	po = pkt_sk(f->arr[idx]);
@@ -1399,12 +1399,13 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 		if (room == ROOM_NORMAL ||
 		    (room == ROOM_LOW && !fanout_flow_is_huge(po, skb)))
 			return idx;
+		po_skip = po;
 	}
 
 	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
 		po_next = pkt_sk(f->arr[i]);
-		if (po_next != po && !po_next->pressure &&
+		if (po_next != po_skip && !po_next->pressure &&
 		    packet_rcv_has_room(po_next, skb) == ROOM_NORMAL) {
 			if (i != j)
 				po->rollover->sock = i;
@@ -1549,7 +1550,8 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	if (po->fanout)
 		return -EALREADY;
 
-	if (type_flags & PACKET_FANOUT_FLAG_ROLLOVER) {
+	if (type == PACKET_FANOUT_ROLLOVER ||
+	    (type_flags & PACKET_FANOUT_FLAG_ROLLOVER)) {
 		po->rollover = kzalloc(sizeof(*po->rollover), GFP_KERNEL);
 		if (!po->rollover)
 			return -ENOMEM;
-- 
2.2.0.rc0.207.ga3a616c
