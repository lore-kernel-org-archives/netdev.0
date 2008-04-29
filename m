From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/8][BONDING]: Do not call free_netdev for already registered
 device.
Date: Tue, 29 Apr 2008 18:54:34 +0400
Message-ID: <481736AA.9050805@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58802 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbYD2PHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:07:52 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the call to bond_create_sysfs_entry in bond_create fails, the
proper rollback is to call unregister_netdevice, not free_netdev.
Otherwise - kernel BUG at net/core/dev.c:4057!

Checked with artificial failures injected into bond_create_sysfs_entry.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/bonding/bond_main.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6e91b4b..36121b6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4936,14 +4936,18 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
 	res = bond_create_sysfs_entry(bond_dev->priv);
-	if (res < 0) {
-		rtnl_lock();
-		down_write(&bonding_rwsem);
-		goto out_bond;
-	}
+	if (res < 0)
+		goto out_unreg;
 
 	return 0;
 
+out_unreg:
+	rtnl_lock();
+	down_write(&bonding_rwsem);
+	bond_deinit(bond_dev);
+	unregister_netdevice(bond_dev);
+	goto out_rtnl;
+
 out_bond:
 	bond_deinit(bond_dev);
 out_netdev:
-- 
1.5.3.4

