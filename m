From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v2 2/4] bonding: Do not ignore notifications for miimon-work-queue
Date: Fri, 20 Mar 2015 22:39:23 -0700
Message-ID: <1426916363-18368-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:33298 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbbCUFjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:39:25 -0400
Received: by pablj1 with SMTP id lj1so8058139pab.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 22:39:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to reschedule the mii-work (aggressively)
just to handle the notification before resuming the regular
cycle.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eabea2d7d9..6da311509a2e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2143,8 +2143,11 @@ static void bond_mii_monitor(struct work_struct *work)
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
+	if (bond_get_notif_pending(bond, BOND_MII_NOTIF)) {
+		should_notify_peers = true;
+		goto re_arm;
+	}
 	rcu_read_lock();
-
 	should_notify_peers = bond_should_notify_peers(bond);
 
 	if (bond_miimon_inspect(bond)) {
@@ -2164,15 +2167,17 @@ static void bond_mii_monitor(struct work_struct *work)
 		rcu_read_unlock();
 
 re_arm:
-	if (bond->params.miimon)
-		queue_delayed_work(bond->wq, &bond->mii_work, delay);
-
 	if (should_notify_peers) {
-		if (!rtnl_trylock())
-			return;
-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
-		rtnl_unlock();
+		if (!rtnl_trylock()) {
+			delay = 1;
+			bond_set_notif_pending(bond, BOND_MII_NOTIF);
+		} else {
+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
+			rtnl_unlock();
+		}
 	}
+	if (bond->params.miimon)
+		queue_delayed_work(bond->wq, &bond->mii_work, delay);
 }
 
 static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
-- 
2.2.0.rc0.207.ga3a616c
