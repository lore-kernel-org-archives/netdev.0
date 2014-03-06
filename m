From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next] bonding: make slave status notifications GFP_ATOMIC
Date: Thu,  6 Mar 2014 15:33:22 +0100
Message-ID: <1394116402-5585-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Thomas Glanzmann <thomas@glanzmann.de>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082AbaCFOiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 09:38:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're using GFP_KERNEL, however there are some path(s) where we
can hold some spinlocks, specifically bond->curr_slave_lock:

[    4.722916] BUG: sleeping function called from invalid context at mm/slub.c:965
[    4.724438] in_atomic(): 1, irqs_disabled(): 0, pid: 940, name: ifup-eth
[    4.726034] 5 locks held by ifup-eth/940:
...snip...
[    4.734646]  #4:  (&bond->curr_slave_lock){+...+.}, at: [<ffffffffa00badc6>] bond_enslave+0xda6/0xdd0 [bonding]
...snip...
[    4.759081]  [<ffffffffa00b6f11>] bond_change_active_slave+0x191/0x3b0 [bonding]
[    4.760917]  [<ffffffffa00b7227>] bond_select_active_slave+0xf7/0x1d0 [bonding]
[    4.762751]  [<ffffffffa00badce>] bond_enslave+0xdae/0xdd0 [bonding]
...snip...

As it's out of hot path and is a really rare event - change the gfp_t flags
to GFP_ATOMIC to avoid sleeping under spinlock.

v2: convert new notify calls to GFP_ATOMIC.

CC: Thomas Glanzmann <thomas@glanzmann.de>
CC: Ding Tianhong <dingtianhong@huawei.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b7127a1..63ee116 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -293,7 +293,7 @@ static inline void bond_set_active_slave(struct slave *slave)
 {
 	if (slave->backup) {
 		slave->backup = 0;
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
 
@@ -301,7 +301,7 @@ static inline void bond_set_backup_slave(struct slave *slave)
 {
 	if (!slave->backup) {
 		slave->backup = 1;
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
 
@@ -313,7 +313,7 @@ static inline void bond_set_slave_state(struct slave *slave,
 
 	slave->backup = slave_state;
 	if (notify) {
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 		slave->should_notify = 0;
 	} else {
 		if (slave->should_notify)
@@ -343,7 +343,7 @@ static inline void bond_slave_state_notify(struct bonding *bond)
 
 	bond_for_each_slave(bond, tmp, iter) {
 		if (tmp->should_notify) {
-			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_KERNEL);
+			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_ATOMIC);
 			tmp->should_notify = 0;
 		}
 	}
-- 
1.8.4
