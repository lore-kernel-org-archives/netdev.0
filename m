From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 3/4] bonding: Do not ignore notifications for AD-work-queue
Date: Wed, 11 Mar 2015 22:54:38 -0700
Message-ID: <1426139678-27207-1-git-send-email-maheshb@google.com>
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
Received: from mail-ob0-f201.google.com ([209.85.214.201]:32915 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbbCLFyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 01:54:41 -0400
Received: by obbnt9 with SMTP id nt9so3835088obb.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 22:54:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to reschedule the AD-work (aggressively)
just to handle the notification before resuming the regular
cycle.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index d5dc7c659773..8e647bffa335 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2178,6 +2178,12 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct port *port;
 	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
 	bool update_slave_arr = false;
+	unsigned long delay;
+
+	if (bond_get_notif_pending(bond, BOND_AD_NOTIF)) {
+		should_notify_rtnl = true;
+		goto re_arm_notify;
+	}
 
 	/* Lock to protect data accessed by all (e.g., port->sm_vars) and
 	 * against running with bond_3ad_unbind_slave. ad_rx_machine may run
@@ -2244,11 +2250,19 @@ re_arm:
 	if (update_slave_arr)
 		bond_slave_arr_work_rearm(bond, 0);
 
-	if (should_notify_rtnl && rtnl_trylock()) {
-		bond_slave_state_notify(bond);
-		rtnl_unlock();
+re_arm_notify:
+	delay = ad_delta_in_ticks;
+	if (should_notify_rtnl) {
+		if (rtnl_trylock()) {
+			bond_slave_state_notify(bond);
+			rtnl_unlock();
+			bond_set_notif_pending(bond, BOND_AD_NOTIF, 0);
+		} else {
+			delay = 1;
+			bond_set_notif_pending(bond, BOND_AD_NOTIF, 1);
+		}
 	}
-	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->ad_work, delay);
 }
 
 /**
-- 
2.2.0.rc0.207.ga3a616c
