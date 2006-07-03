From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch 5/7] net_device list cleanup: arch-dependent code and block devices
Date: Mon, 3 Jul 2006 12:18:55 +0400
Message-ID: <20060630164944.G22285@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	schwidefsky@de.ibm.com, davem@davemloft.net, ecashin@coraid.com,
	matthew@wil.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:35848 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1750988AbWGCQcA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:32:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060630150823.A22285@castle.nmd.msu.ru>; from "Andrey Savochkin" on Fri, Jun 30, 2006 at 03:08:23PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup of net_device list use in arch-dependent code and block devices.

The cleanup consists of
 - converting the to list_head, to make the list double-linked (thus making
   remove operation O(1)), and list walks more readable;
 - introducing of for_each_netdev wrapper over list_for_each.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
---
 arch/s390/appldata/appldata_net_sum.c |    2 +-
 arch/sparc64/solaris/ioctl.c          |    2 +-
 drivers/block/aoe/aoecmd.c            |    8 ++++++--
 drivers/parisc/led.c                  |    2 +-
 4 files changed, 9 insertions(+), 5 deletions(-)

--- ./arch/s390/appldata/appldata_net_sum.c.vedevbase-misc	Mon Jul  3 15:13:15 2006
+++ ./arch/s390/appldata/appldata_net_sum.c	Mon Jul  3 16:16:05 2006
@@ -107,7 +107,7 @@ static void appldata_get_net_sum_data(vo
 	tx_dropped = 0;
 	collisions = 0;
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		if (dev->get_stats == NULL) {
 			continue;
 		}
--- ./arch/sparc64/solaris/ioctl.c.vedevbase-misc	Mon Mar 20 08:53:29 2006
+++ ./arch/sparc64/solaris/ioctl.c	Mon Jul  3 16:16:05 2006
@@ -686,7 +686,7 @@ static inline int solaris_i(unsigned int
 			int i = 0;
 			
 			read_lock_bh(&dev_base_lock);
-			for (d = dev_base; d; d = d->next) i++;
+			for_each_netdev(d) i++;
 			read_unlock_bh(&dev_base_lock);
 
 			if (put_user (i, (int __user *)A(arg)))
--- ./drivers/block/aoe/aoecmd.c.vedevbase-misc	Mon Jul  3 15:09:57 2006
+++ ./drivers/block/aoe/aoecmd.c	Mon Jul  3 16:16:05 2006
@@ -204,14 +204,17 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigne
 	sl = sl_tail = NULL;
 
 	read_lock(&dev_base_lock);
-	for (ifp = dev_base; ifp; dev_put(ifp), ifp = ifp->next) {
+	for_each_netdev(ifp) {
 		dev_hold(ifp);
-		if (!is_aoe_netif(ifp))
+		if (!is_aoe_netif(ifp)) {
+			dev_put(ifp);
 			continue;
+		}
 
 		skb = new_skb(ifp, sizeof *h + sizeof *ch);
 		if (skb == NULL) {
 			printk(KERN_INFO "aoe: aoecmd_cfg: skb alloc failure\n");
+			dev_put(ifp);
 			continue;
 		}
 		if (sl_tail == NULL)
@@ -229,6 +232,7 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigne
 
 		skb->next = sl;
 		sl = skb;
+		dev_put(ifp);
 	}
 	read_unlock(&dev_base_lock);
 
--- ./drivers/parisc/led.c.vedevbase-misc	Mon Jul  3 15:13:46 2006
+++ ./drivers/parisc/led.c	Mon Jul  3 16:16:05 2006
@@ -367,7 +367,7 @@ static __inline__ int led_get_net_activi
 	 * for reading should be OK */
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 	    struct net_device_stats *stats;
 	    struct in_device *in_dev = __in_dev_get_rcu(dev);
 	    if (!in_dev || !in_dev->ifa_list)
