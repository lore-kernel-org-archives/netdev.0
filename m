From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] bonding: reset the slave's mtu when its be changed
Date: Fri, 10 Jan 2014 19:32:51 +0800
Message-ID: <52CFDA63.8070601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64659 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaAJLgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 06:36:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All slave should have the same mtu with mastet's, and the bond do it when
enslave the slave, but the user could change the slave's mtu, it will cause
the master and slave have different mtu, althrough in AB mode, it does not
matter if the slave is not the current slave, but in other mode, it is incorrect,
so reset the slave's mtu like the master set.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 398e299..e7b5bcf 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2882,18 +2882,17 @@ static int bond_slave_netdev_event(unsigned long event,
 		 */
 		break;
 	case NETDEV_CHANGEMTU:
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
+		/* All slave should have the same mtu
+		 * as master.
 		 */
+		if (slave->dev->mtu != bond->dev->mtu) {
+			int res;
+			slave->original_mtu = slave->dev->mtu;
+			res = dev_set_mtu(slave->dev, bond->dev->mtu);
+			if (res)
+				pr_debug("Error %d calling dev_set_mtu for slave %s\n",
+					 res, slave->dev->name);
+		}
 		break;
 	case NETDEV_CHANGENAME:
 		/*
--
1.8.0
