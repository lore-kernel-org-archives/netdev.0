From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: fix locking in enslave failure path
Date: Mon, 22 Apr 2013 20:12:22 +0200
Message-ID: <1366654342-2715-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136Ab3DVSP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 14:15:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 3c5913b53fefc9d9e15a2d0f93042766658d9f3f ("bonding:
primary_slave & curr_active_slave are not cleaned on enslave failure")
I didn't account for the use of curr_active_slave without curr_slave_lock
and since there are such users, we should hold bond->lock for writing while
setting it to NULL (in the NULL case we don't need the curr_slave_lock).
Keeping the bond lock as to avoid the extra release/acquire cycle.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dbbea0e..7db40de1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1915,14 +1915,16 @@ err_detach:
 	bond_detach_slave(bond, new_slave);
 	if (bond->primary_slave == new_slave)
 		bond->primary_slave = NULL;
-	write_unlock_bh(&bond->lock);
 	if (bond->curr_active_slave == new_slave) {
+		bond_change_active_slave(bond, NULL);
+		write_unlock_bh(&bond->lock);
 		read_lock(&bond->lock);
 		write_lock_bh(&bond->curr_slave_lock);
-		bond_change_active_slave(bond, NULL);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
 		read_unlock(&bond->lock);
+	} else {
+		write_unlock_bh(&bond->lock);
 	}
 	slave_disable_netpoll(new_slave);
 
-- 
1.8.1.4
