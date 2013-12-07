From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v4 11/11] bonding: rebuild the bond_resend_igmp_join_requests_delayed()
Date: Sat, 7 Dec 2013 15:46:12 +0800
Message-ID: <52A2D244.3000107@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5992 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab3LGHqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 02:46:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_resend_igmp_join_requests_delayed() and
bond_resend_igmp_join_requests() should be integrated,
because the bond_resend_igmp_join_requests_delayed() did
nothing except bond_resend_igmp_join_requests().

The bond igmp_retrans could only be changed in bond_change_active_slave
and here, bond_change_active_slave will be called in RTNL and curr_slave_lock,
the bond_resend_igmp_join_requests already hold RTNL, so no need
to free RTNL and hold curr_slave_lock again, it may be a small optimization,
so move the igmp_retrans in RTNL and remove the curr_slave_lock.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77fdb78..556a53d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -591,33 +591,22 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
  * device and retransmit an IGMP JOIN request to the current active
  * slave.
  */
-static void bond_resend_igmp_join_requests(struct bonding *bond)
+static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
 {
+	struct bonding *bond = container_of(work, struct bonding,
+					    mcast_work.work);
+
 	if (!rtnl_trylock()) {
 		queue_delayed_work(bond->wq, &bond->mcast_work, 1);
 		return;
 	}
 	call_netdevice_notifiers(NETDEV_RESEND_IGMP, bond->dev);
-	rtnl_unlock();
 
-	/* We use curr_slave_lock to protect against concurrent access to
-	 * igmp_retrans from multiple running instances of this function and
-	 * bond_change_active_slave
-	 */
-	write_lock_bh(&bond->curr_slave_lock);
 	if (bond->igmp_retrans > 1) {
 		bond->igmp_retrans--;
 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
 	}
-	write_unlock_bh(&bond->curr_slave_lock);
-}
-
-static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
-{
-	struct bonding *bond = container_of(work, struct bonding,
-					    mcast_work.work);
-
-	bond_resend_igmp_join_requests(bond);
+	rtnl_unlock();
 }
 
 /* Flush bond's hardware addresses from slave
-- 
1.8.2.1
