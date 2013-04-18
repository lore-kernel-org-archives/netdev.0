From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 3/5] bonding: primary_slave & curr_active_slave are not cleaned on enslave failure
Date: Thu, 18 Apr 2013 16:34:55 +0200
Message-ID: <1366295697-31037-4-git-send-email-nikolay@redhat.com>
References: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966598Ab3DROiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 10:38:06 -0400
In-Reply-To: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On enslave failure primary_slave can point to new_slave which is to be
freed, and the same applies to curr_active_slave. So check if this is
the case and clean up properly after err_detach because that's the first
error code path after they're set.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bf5a9df..a04a018 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1907,7 +1907,17 @@ err_detach:
 	bond_del_vlans_from_slave(bond, slave_dev);
 	write_lock_bh(&bond->lock);
 	bond_detach_slave(bond, new_slave);
+	if (bond->primary_slave == new_slave)
+		bond->primary_slave = NULL;
 	write_unlock_bh(&bond->lock);
+	if (bond->curr_active_slave == new_slave) {
+		read_lock(&bond->lock);
+		write_lock_bh(&bond->curr_slave_lock);
+		bond_change_active_slave(bond, NULL);
+		bond_select_active_slave(bond);
+		write_unlock_bh(&bond->curr_slave_lock);
+		read_unlock(&bond->lock);
+	}
 
 err_close:
 	slave_dev->priv_flags &= ~IFF_BONDING;
-- 
1.8.1.4
