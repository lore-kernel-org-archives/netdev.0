From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-2.6] bonding:restore backup and inactive flag of slave
Date: Mon, 15 Aug 2011 18:25:16 +0800
Message-ID: <13dbe805d13bba461e50483c0162ce8bc1366204.1313403625.git.panweiping3@gmail.com>
References: <CANMAZFWYUqDDp+_9EOOubRcvC90zHO9NR7D_N5D=uTjokpgU6A@mail.gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60897 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab1HOKXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 06:23:55 -0400
Received: by qwk3 with SMTP id 3so2383679qwk.19
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 03:23:54 -0700 (PDT)
In-Reply-To: <CANMAZFWYUqDDp+_9EOOubRcvC90zHO9NR7D_N5D=uTjokpgU6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eduard Sinelnikov (eduard.sinelnikov@gmail.com) found that if we change
bonding mode from active backup to round robin, some slaves are still keeping
"backup", and won't transmit packets.

As Jay Vosburgh(fubar@us.ibm.com) pointed out that we can work around that by
removing the bond_is_active_slave() check, because the "backup" flag is only
meaningful for active backup mode.

But if we just simply ignore the bond_is_active_slave() check,
the transmission will work fine, but we can't maintain the correct value of
"backup" flag for each slaves, though it is meaningless for other mode than
active backup.

I'd like to restore "backup" and "inactive" flag in bond_open,
thus we can keep the correct value of them.

As for bond_is_active_slave(), I'd like to prepare another patch to handle it.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_main.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 38a83ac..3ed9827 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3419,9 +3419,27 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i;
 
 	bond->kill_timers = 0;
 
+	// restore slave->backup and slave->inactive
+	read_lock(&bond->lock);
+	read_lock(&bond->curr_slave_lock);
+	if (bond->slave_cnt > 0) {
+		bond_for_each_slave(bond, slave, i) {
+			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+				&& (slave != bond->curr_active_slave)) {
+				bond_set_slave_inactive_flags(slave);
+			} else {
+				bond_set_slave_active_flags(slave);
+			}
+		}
+	}
+	read_unlock(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+
 	INIT_DELAYED_WORK(&bond->mcast_work, bond_resend_igmp_join_requests_delayed);
 
 	if (bond_is_lb(bond)) {
-- 
1.7.4.4

