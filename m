From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: speedup netdev_set_master()
Date: Fri, 19 Mar 2010 00:37:40 +0100
Message-ID: <1268955460.2894.207.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:33969 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab0CRXhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 19:37:45 -0400
Received: by bwz1 with SMTP id 1so2563296bwz.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 16:37:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently force a synchronize_net() in netdev_set_master()

This seems necessary only when a slave had a master and we dismantle it.

In the other case ("ifenslave bond0 ethO"), we dont need this long
delay.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 17b1686..ff578ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3733,11 +3733,10 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 
 	slave->master = master;
 
-	synchronize_net();
-
-	if (old)
+	if (old) {
+		synchronize_net();
 		dev_put(old);
-
+	}
 	if (master)
 		slave->flags |= IFF_SLAVE;
 	else


