From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 5/5] bonding: remove bond read lock for bond_3ad_state_machine_handler()
Date: Mon, 21 Oct 2013 16:59:18 +0800
Message-ID: <5264ECE6.4040707@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:42271 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875Ab3JUJIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:08:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond now only attach and detach slave in rtnl lock,
so read_lock for bond could not protect slave list,
replace bond read lock with rtnl lock for bond_3ad_state_machine_handler().

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 187b1b7..d6fe00b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2068,8 +2068,10 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct slave *slave;
 	struct port *port;
 
-	read_lock(&bond->lock);
-
+	if (!rtnl_trylock()) {
+		queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
+		return;
+	}
 	//check if there are any slaves
 	if (!bond_has_slaves(bond))
 		goto re_arm;
@@ -2122,9 +2124,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 re_arm:
+	rtnl_unlock();
 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
-
-	read_unlock(&bond->lock);
 }
 
 /**
-- 
1.8.2.1
