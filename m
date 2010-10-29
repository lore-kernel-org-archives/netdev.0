From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] aoe: remove dev_base_lock use from aoecmd_cfg_pkts()
Date: Fri, 29 Oct 2010 13:15:29 +0200
Message-ID: <1288350929.2560.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Ed L. Cashin" <ecashin@coraid.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63546 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759688Ab0J2LPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 07:15:33 -0400
Received: by wyf28 with SMTP id 28so3020652wyf.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 04:15:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_base_lock is the legacy way to lock the device list, and is planned
to disappear. (writers hold RTNL, readers hold RCU lock)

Convert aoecmd_cfg_pkts() to RCU locking.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Ed L. Cashin" <ecashin@coraid.com>
---
 drivers/block/aoe/aoecmd.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 5674bd0..de0435e 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -297,8 +297,8 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigned char aoeminor, struct sk_buff_head *qu
 	struct sk_buff *skb;
 	struct net_device *ifp;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, ifp) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, ifp) {
 		dev_hold(ifp);
 		if (!is_aoe_netif(ifp))
 			goto cont;
@@ -325,7 +325,7 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigned char aoeminor, struct sk_buff_head *qu
 cont:
 		dev_put(ifp);
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static void


