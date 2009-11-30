From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 06/20] net: Simplfy default_device_exit and improve batching.
Date: Mon, 30 Nov 2009 00:25:30 -0800
Message-ID: <1259569530-30609-5-git-send-email-ebiederm@xmission.com>
References: <m1ljhodbtw.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53816 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbZK3IZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 03:25:34 -0500
In-Reply-To: <m1ljhodbtw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

- Defer dellink to net_cleanup() allowing for batching.
- Fix comment.
- Use for_each_netdev_safe again as dev_change_net_namespace touches
  at most one network device (unlike veth dellink).

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 124029e..c3e3400 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5735,14 +5735,13 @@ static struct pernet_operations __net_initdata netdev_net_ops = {
 
 static void __net_exit default_device_exit(struct net *net)
 {
-	struct net_device *dev;
+	struct net_device *dev, *aux;
 	/*
-	 * Push all migratable of the network devices back to the
+	 * Push all migratable network devices back to the
 	 * initial network namespace
 	 */
 	rtnl_lock();
-restart:
-	for_each_netdev(net, dev) {
+	for_each_netdev_safe(net, dev, aux) {
 		int err;
 		char fb_name[IFNAMSIZ];
 
@@ -5750,11 +5749,9 @@ restart:
 		if (dev->features & NETIF_F_NETNS_LOCAL)
 			continue;
 
-		/* Delete virtual devices */
-		if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink) {
-			dev->rtnl_link_ops->dellink(dev, NULL);
-			goto restart;
-		}
+		/* Leave virtual devices for the generic cleanup */
+		if (dev->rtnl_link_ops)
+			continue;
 
 		/* Push remaing network devices to init_net */
 		snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
@@ -5764,7 +5761,6 @@ restart:
 				__func__, dev->name, err);
 			BUG();
 		}
-		goto restart;
 	}
 	rtnl_unlock();
 }
-- 
1.6.5.2.143.g8cc62

