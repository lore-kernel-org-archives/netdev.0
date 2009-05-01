From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: correct the cleanup in bond_create()
Date: Fri, 1 May 2009 23:44:23 +0200
Message-ID: <20090501214422.GA16065@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45521 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336AbZEAVo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 17:44:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the cleanup in bond_create nicer :) Also now the forgotten
free_netdev is called.

Jirka

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bonding/bond_main.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fd73836..a35374a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5173,16 +5173,15 @@ int bond_create(char *name, struct bond_params *params)
 	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
 	res = bond_create_sysfs_entry(netdev_priv(bond_dev));
-	if (res < 0) {
-		rtnl_lock();
-		down_write(&bonding_rwsem);
-		bond_deinit(bond_dev);
-		unregister_netdevice(bond_dev);
-		goto out_rtnl;
-	}
+	if (res < 0)
+		goto out_unreg;
 
 	return 0;
 
+out_unreg:
+	rtnl_lock();
+	down_write(&bonding_rwsem);
+	unregister_netdevice(bond_dev);
 out_bond:
 	bond_deinit(bond_dev);
 out_netdev:
