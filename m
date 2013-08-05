From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/3] bonding: unwind on bond_add_vlan add failure
Date: Mon,  5 Aug 2013 15:28:24 +0200
Message-ID: <1375709304-16778-4-git-send-email-nikolay@redhat.com>
References: <1375709304-16778-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42268 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156Ab3HENcP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 09:32:15 -0400
In-Reply-To: <1375709304-16778-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>

In case of bond_add_vlan() failure currently we'll have the vlan's
refcnt bumped up in all slaves, but it will never go down because it
failed to get added to the bond, so properly unwind the added vlan if
bond_add_vlan fails.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ed1d261..0f9ca7e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -456,13 +456,13 @@ static int __bond_vlan_rx_add_vid(struct net_device *bond_dev,
 	if (res) {
 		pr_err("%s: Error: Failed to add vlan id %d\n",
 		       bond_dev->name, vid);
-		return res;
+		goto unwind;
 	}
 
 	return 0;
 
 unwind:
-	/* unwind from head to the slave that failed */
+	/* unwind from the slave that failed */
 	bond_for_each_slave_continue_reverse(bond, slave)
 		vlan_vid_del(slave->dev, proto, vid);
 
-- 
1.8.1.4
