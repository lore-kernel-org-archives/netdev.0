From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH net-2.6] ifb: goto resched directly if error happens and dp->tq isn't empty
Date: Sun,  5 Dec 2010 08:09:08 +0800
Message-ID: <1291507748-4958-1-git-send-email-xiaosuo@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:37149 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab0LEAJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 19:09:29 -0500
Received: by ywl5 with SMTP id 5so5410543ywl.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 16:09:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we break the loop when there are still skbs in tq and no skb in
rq, the skbs will be left in txq until new skbs are enqueued into rq.
In rare cases, no new skb is queued, then these skbs will stay in rq
forever.

After this patch, if tq isn't empty when we break the loop, we goto
resched directly.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ab9f675..fe337bd 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -104,6 +104,8 @@ static void ri_tasklet(unsigned long dev)
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
 			stats->tx_dropped++;
+			if (skb_queue_len(&dp->tq) != 0)
+				goto resched;
 			break;
 		}
 		rcu_read_unlock();
