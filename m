From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v2 3/4] bonding: Do not ignore notifications for AD-work-queue
Date: Fri, 20 Mar 2015 22:39:24 -0700
Message-ID: <1426916364-18406-1-git-send-email-maheshb@google.com>
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
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33804 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbbCUFj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:39:27 -0400
Received: by yhaf10 with SMTP id f10so121317yha.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 22:39:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to reschedule the AD-work (aggressively)
just to handle the notification before resuming the regular
cycle.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index d5dc7c659773..b8444746521f 100644
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
@@ -2244,11 +2250,18 @@ re_arm:
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
+		} else {
+			delay = 1;
+			bond_set_notif_pending(bond, BOND_AD_NOTIF);
+		}
 	}
-	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->ad_work, delay);
 }
 
 /**
-- 
2.2.0.rc0.207.ga3a616c
