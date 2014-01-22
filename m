From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/3] bonding: only affect active-backup mode when
 fail_over_mac is not none
Date: Wed, 22 Jan 2014 17:22:05 +0800
Message-ID: <52DF8DBD.4030803@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:17408 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaAVJWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 04:22:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According bonding.txt, the fail_over_mac only affect active-backup mode,
but now the fail_over_mac could be set to active or follow in every mode,
this will make the new slave could not be set to bond's MAC address at
enslavement for several modes, such as RR or XOR.

So this patch fix two problems:
1). If the fail_over_mac is active or follow and the mode is not active-backup,
    the new slave could be set to the bond's MAC address,

2). The first slave could work normally regardless it could support setting MAC
    address or not, and the bonding always be set to first slave's MAC address,
    so no need to set the first slave to bond's MAC address again when fail_over_mac
    is none at enslavement.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 598f100..ce0f5c0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1387,7 +1387,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
 
-	if (!bond->params.fail_over_mac) {
+	if (bond_has_slaves(bond) &&
+	    (!bond->params.fail_over_mac ||
+	     bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
 		/*
 		 * Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
-- 
1.8.0
