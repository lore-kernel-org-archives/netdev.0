From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH RESEND net-next] bonding: don't permit slaves to change their
 mtu independently
Date: Sat, 25 Jan 2014 12:55:09 +0800
Message-ID: <52E343AD.3080402@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2912 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaAYE6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 23:58:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have come to a conclusion by testing all modes for mtu changing:

1). If the slaves support changing mtu and no need to restart the device,
    just like virtual nic, the master will not lost any packages for all
    mode.

2). If the slaves support changing mtu and need to restart the device,
    just like Intel 82599, the AB, 802.3, ALB and TLB mode may lost
    packages, but other modes could work well.

The reason is that when the slave's mtu has been changed, the slave's hw will
restart, if the slave is current active slave, the master may set the
slave to backup state and reselect a new slave, after the reselect processing,
the master could work again, but if in load-balance mode, the master could
select another active slave to send and recv packages.

So the best way to fix the problem is don't permit slave to change their
mtu independently.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ca949f..e127031c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2808,20 +2808,12 @@ static int bond_slave_netdev_event(unsigned long event,
 		 * ... Or is it this?
 		 */
 		break;
-	case NETDEV_CHANGEMTU:
-		/*
-		 * TODO: Should slaves be allowed to
-		 * independently alter their MTU?  For
-		 * an active-backup bond, slaves need
-		 * not be the same type of device, so
-		 * MTUs may vary.  For other modes,
-		 * slaves arguably should have the
-		 * same MTUs. To do this, we'd need to
-		 * take over the slave's change_mtu
-		 * function for the duration of their
-		 * servitude.
+	case NETDEV_PRECHANGEMTU:
+		/* The master and slaves should have the
+		 * same mtu, so don't permit slaves to
+		 * change their mtu independently.
 		 */
-		break;
+		return NOTIFY_BAD;
 	case NETDEV_CHANGENAME:
 		/* we don't care if we don't have primary set */
 		if (!USES_PRIMARY(bond->params.mode) ||
-- 
1.8.0
