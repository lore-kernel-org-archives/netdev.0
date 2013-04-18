From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCHv2 1/5] bonding: mc addresses don't get deleted on enslave failure
Date: Thu, 18 Apr 2013 19:33:34 +0200
Message-ID: <1366306418-3661-2-git-send-email-nikolay@redhat.com>
References: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62589 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967289Ab3DRRgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 13:36:42 -0400
In-Reply-To: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add bond_mc_list_flush() after err_detach as that's the first error path
after the addresses are added. The main issue is the mc addresses' refcount
which only gets bumped up.

v2: update log message and don't move code unnecessarily

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a61a760..6fe1544 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1901,6 +1901,11 @@ err_dest_symlinks:
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
 
 err_detach:
+	if (!USES_PRIMARY(bond->params.mode)) {
+		netif_addr_lock_bh(bond_dev);
+		bond_mc_list_flush(bond_dev, slave_dev);
+		netif_addr_unlock_bh(bond_dev);
+	}
 	write_lock_bh(&bond->lock);
 	bond_detach_slave(bond, new_slave);
 	write_unlock_bh(&bond->lock);
-- 
1.8.1.4
