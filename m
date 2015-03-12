From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 2/4] bonding: Do not ignore notifications for miimon-work-queue
Date: Wed, 11 Mar 2015 22:54:37 -0700
Message-ID: <1426139677-27167-1-git-send-email-maheshb@google.com>
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
Received: from mail-ig0-f201.google.com ([209.85.213.201]:34336 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbbCLFyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 01:54:40 -0400
Received: by igqa13 with SMTP id a13so3919675igq.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 22:54:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to reschedule the mii-work (aggressively)
just to handle the notification before resuming the regular
cycle.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eabea2d7d9..54ecb7a22bae 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2143,10 +2143,13 @@ static void bond_mii_monitor(struct work_struct *work)
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
-	rcu_read_lock();
-
+	if (bond_get_notif_pending(bond, BOND_MII_NOTIF)) {
+		should_notify_peers = true;
+		goto re_arm;
+	}
 	should_notify_peers = bond_should_notify_peers(bond);
 
+	rcu_read_lock();
 	if (bond_miimon_inspect(bond)) {
 		rcu_read_unlock();
 
@@ -2164,15 +2167,18 @@ static void bond_mii_monitor(struct work_struct *work)
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
+			bond_set_notif_pending(bond, BOND_MII_NOTIF, 1);
+		} else {
+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
+			rtnl_unlock();
+			bond_set_notif_pending(bond, BOND_MII_NOTIF, 0);
+		}
 	}
+	if (bond->params.miimon)
+		queue_delayed_work(bond->wq, &bond->mii_work, delay);
 }
 
 static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
-- 
2.2.0.rc0.207.ga3a616c
