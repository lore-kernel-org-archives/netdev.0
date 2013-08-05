From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: fix send_peer_notif leekage on rtnl lock congestion
Date: Mon,  5 Aug 2013 21:47:33 +0200
Message-ID: <1375732053-829-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651Ab3HETsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 15:48:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bond_mii_monitor()/bond_activebackup_arp_mon(), we verify if we have any
notifications to be sent before trying to get the rtnl_trylock(), and if
we have - we set should_notify_peers and withdraw a notification. However,
if we fail the get the rtnl_trylock(), we don't send out any notification
and don't put the notification back to bond->send_peer_notif.

Fix it by putting back the notification to send_peer_notif in case of
rtnl_trylock() failure.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5697043..fd92738 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2383,7 +2383,10 @@ void bond_mii_monitor(struct work_struct *work)
 		if (!rtnl_trylock()) {
 			read_lock(&bond->lock);
 			delay = 1;
-			should_notify_peers = false;
+			if (should_notify_peers) {
+				bond->send_peer_notif++;
+				should_notify_peers = false;
+			}
 			goto re_arm;
 		}
 
@@ -2999,7 +3002,10 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		if (!rtnl_trylock()) {
 			read_lock(&bond->lock);
 			delta_in_ticks = 1;
-			should_notify_peers = false;
+			if (should_notify_peers) {
+				bond->send_peer_notif++;
+				should_notify_peers = false;
+			}
 			goto re_arm;
 		}
 
-- 
1.8.1.4
