From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: get netdev_rx_handler_unregister out of locks
Date: Tue,  2 Apr 2013 17:15:16 +0200
Message-ID: <1364915716-4857-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761362Ab3DBPQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that netdev_rx_handler_unregister contains synchronize_net(), we need
to call it outside of bond->lock, cause it might sleep. Also, remove the
already unneded synchronize_net().

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 11a8cb3..78c9e2d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1975,12 +1975,11 @@ static int __bond_release_one(struct net_device *bond_dev,
 		return -EINVAL;
 	}
 
+	write_unlock_bh(&bond->lock);
 	/* unregister rx_handler early so bond_handle_frame wouldn't be called
 	 * for this slave anymore.
 	 */
 	netdev_rx_handler_unregister(slave_dev);
-	write_unlock_bh(&bond->lock);
-	synchronize_net();
 	write_lock_bh(&bond->lock);
 
 	if (!all && !bond->params.fail_over_mac) {
-- 
1.7.1
