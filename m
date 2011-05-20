From: Amerigo Wang <amwang@redhat.com>
Subject: [V3 Patch 1/3] netpoll: disable netpoll when enslave a device
Date: Fri, 20 May 2011 15:39:10 +0800
Message-ID: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab1ETHjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2011 03:39:07 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p4K7d7L7002236
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 03:39:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V3: rename NETDEV_ENSLAVE to NETDEV_JOIN

Currently we do nothing when we enslave a net device which is running netconsole.
Neil pointed out that we may get weird results in such case, so let's disable
netpoll on the device being enslaved. I think it is too harsh to prevent
the device being ensalved if it is running netconsole.

By the way, this patch also removes the NETDEV_GOING_DOWN from netconsole
netdev notifier, because netpoll will check if the device is running or not
and we don't handle NETDEV_PRE_UP neither.

This patch is based on net-next-2.6.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>

---

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 088fd84..f4960f5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1640,6 +1640,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
+	call_netdevice_notifiers(NETDEV_JOIN, slave_dev);
+
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
 	if (is_zero_ether_addr(bond->dev->dev_addr))
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index a83e101..4190786 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -621,11 +621,10 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	bool stopped = false;
 
 	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
-	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
+	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_JOIN))
 		goto done;
 
 	spin_lock_irqsave(&target_list_lock, flags);
-restart:
 	list_for_each_entry(nt, &target_list, list) {
 		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
@@ -633,6 +632,8 @@ restart:
 			case NETDEV_CHANGENAME:
 				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
 				break;
+			case NETDEV_BONDING_DESLAVE:
+			case NETDEV_JOIN:
 			case NETDEV_UNREGISTER:
 				/*
 				 * rtnl_lock already held
@@ -647,11 +648,7 @@ restart:
 					dev_put(nt->np.dev);
 					nt->np.dev = NULL;
 					netconsole_target_put(nt);
-					goto restart;
 				}
-				/* Fall through */
-			case NETDEV_GOING_DOWN:
-			case NETDEV_BONDING_DESLAVE:
 				nt->enabled = 0;
 				stopped = true;
 				break;
@@ -660,10 +657,21 @@ restart:
 		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
-	if (stopped && (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE))
+	if (stopped) {
 		printk(KERN_INFO "netconsole: network logging stopped on "
-			"interface %s as it %s\n",  dev->name,
-			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
+		       "interface %s as it ", dev->name);
+		switch (event) {
+		case NETDEV_UNREGISTER:
+			printk(KERN_CONT "unregistered\n");
+			break;
+		case NETDEV_BONDING_DESLAVE:
+			printk(KERN_CONT "released slaves\n");
+			break;
+		case NETDEV_JOIN:
+			printk(KERN_CONT "is joining a master device\n");
+			break;
+		}
+	}
 
 done:
 	return NOTIFY_DONE;
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 621dfa1..a577762 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -211,6 +211,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_UNREGISTER_BATCH 0x0011
 #define NETDEV_BONDING_DESLAVE  0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
+#define NETDEV_JOIN		0x0014
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
-- 
1.7.1

