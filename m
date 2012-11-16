From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net-rps: Fix brokeness causing OOO packets
Date: Fri, 16 Nov 2012 11:04:15 -0800
Message-ID: <1353092655.10798.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50325 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab2KPTER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 14:04:17 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so2126129pbc.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 11:04:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

In commit c445477d74ab3779 which adds aRFS to the kernel, the CPU
selected for RFS is not set correctly when CPU is changing.
This is causing OOO packets and probably other issues.

Signed-off-by: Tom Herbert <therbert@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index bda6d00..c0946cb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2818,8 +2818,10 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		if (unlikely(tcpu != next_cpu) &&
 		    (tcpu == RPS_NO_CPU || !cpu_online(tcpu) ||
 		     ((int)(per_cpu(softnet_data, tcpu).input_queue_head -
-		      rflow->last_qtail)) >= 0))
+		      rflow->last_qtail)) >= 0)) {
+			tcpu = next_cpu;
 			rflow = set_rps_cpu(dev, skb, rflow, next_cpu);
+		}
 
 		if (tcpu != RPS_NO_CPU && cpu_online(tcpu)) {
 			*rflowp = rflow;
