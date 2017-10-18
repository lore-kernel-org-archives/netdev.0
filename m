From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] packet: avoid panic in packet_getsockopt()
Date: Wed, 18 Oct 2017 15:08:24 -0700
Message-ID: <1508364504.31614.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:52143 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdJRWI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 18:08:26 -0400
Received: by mail-io0-f195.google.com with SMTP id b186so7879342iof.8
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 15:08:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller got crashes in packet_getsockopt() processing
PACKET_ROLLOVER_STATS command while another thread was managing
to change po->rollover

Using RCU will fix this bug. We might later add proper RCU annotations
for sparse sake.

Fixes: a9b6391814d5 ("packet: rollover statistics")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bec01a3daf5b02bd716dbff5c9efef8d6a7982be..1d8a7add86b4f29880e11c6f4971d79319dcb426 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1796,8 +1796,10 @@ static struct packet_fanout *fanout_release(struct sock *sk)
 		else
 			f = NULL;
 
-		if (po->rollover)
+		if (po->rollover) {
 			kfree_rcu(po->rollover, rcu);
+			po->rollover = NULL;
+		}
 	}
 	mutex_unlock(&fanout_mutex);
 
@@ -3851,6 +3853,7 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	void *data = &val;
 	union tpacket_stats_u st;
 	struct tpacket_rollover_stats rstats;
+	struct packet_rollover *rollover;
 
 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -3929,13 +3932,18 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		       0);
 		break;
 	case PACKET_ROLLOVER_STATS:
-		if (!po->rollover)
+		rcu_read_lock();
+		rollover = rcu_dereference(po->rollover);
+		if (rollover) {
+			rstats.tp_all = atomic_long_read(&rollover->num);
+			rstats.tp_huge = atomic_long_read(&rollover->num_huge);
+			rstats.tp_failed = atomic_long_read(&rollover->num_failed);
+			data = &rstats;
+			lv = sizeof(rstats);
+		}
+		rcu_read_unlock();
+		if (!rollover)
 			return -EINVAL;
-		rstats.tp_all = atomic_long_read(&po->rollover->num);
-		rstats.tp_huge = atomic_long_read(&po->rollover->num_huge);
-		rstats.tp_failed = atomic_long_read(&po->rollover->num_failed);
-		data = &rstats;
-		lv = sizeof(rstats);
 		break;
 	case PACKET_TX_HAS_OFF:
 		val = po->tp_tx_has_off;
