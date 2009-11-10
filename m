From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/10] AOE: use rcu to find network device
Date: Tue, 10 Nov 2009 09:54:50 -0800
Message-ID: <20091110175647.409162953@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	"Ed L. Cashin" <ecashin@coraid.com>,
	Harvey Harrison <harvey.harrison@gmail.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58719 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756182AbZKJSHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:07:33 -0500
Content-Disposition: inline; filename=aoe-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gets rid of another use of read_lock(&dev_base_lock) by using
RCU. Also, it only increments the reference count of the device actually
used rather than holding and releasing every device

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/block/aoe/aoecmd.c	2009-11-09 22:19:06.082480836 -0800
+++ b/drivers/block/aoe/aoecmd.c	2009-11-10 09:28:38.222438732 -0800
@@ -296,17 +296,18 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigne
 	struct sk_buff *skb;
 	struct net_device *ifp;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, ifp) {
-		dev_hold(ifp);
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, ifp) {
 		if (!is_aoe_netif(ifp))
-			goto cont;
+			continue;
 
 		skb = new_skb(sizeof *h + sizeof *ch);
 		if (skb == NULL) {
 			printk(KERN_INFO "aoe: skb alloc failure\n");
-			goto cont;
+			continue;
 		}
+
+		dev_hold(ifp);
 		skb_put(skb, sizeof *h + sizeof *ch);
 		skb->dev = ifp;
 		__skb_queue_tail(queue, skb);
@@ -320,11 +321,8 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigne
 		h->major = cpu_to_be16(aoemajor);
 		h->minor = aoeminor;
 		h->cmd = AOECMD_CFG;
-
-cont:
-		dev_put(ifp);
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static void

-- 

