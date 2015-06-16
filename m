From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] packet: free packet_rollover after synchronize_net
Date: Tue, 16 Jun 2015 12:51:37 -0400
Message-ID: <1434473497-28551-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:34229 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbbFPQvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 12:51:44 -0400
Received: by yhid80 with SMTP id d80so15576615yhi.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 09:51:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Destruction of the po->rollover must be delayed until there are no
more packets in flight that can access it. The field is destroyed in
packet_release, before synchronize_net. Delay using rcu.

Fixes: 0648ab70afe6 ("packet: rollover prepare: per-socket state")

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 3 ++-
 net/packet/internal.h  | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fd51641..20e8c40 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1634,7 +1634,8 @@ static void fanout_release(struct sock *sk)
 	}
 	mutex_unlock(&fanout_mutex);
 
-	kfree(po->rollover);
+	if (po->rollover)
+		kfree_rcu(po->rollover, rcu);
 }
 
 static const struct proto_ops packet_ops;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index c035d26..e20b3e8 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -89,6 +89,7 @@ struct packet_fanout {
 
 struct packet_rollover {
 	int			sock;
+	struct rcu_head		rcu;
 	atomic_long_t		num;
 	atomic_long_t		num_huge;
 	atomic_long_t		num_failed;
-- 
2.2.0.rc0.207.ga3a616c
