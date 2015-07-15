From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] bonding: fix bond dev flags after convert to arphrd_ether
Date: Wed, 15 Jul 2015 22:09:43 +0200
Message-ID: <1436990983-1406-1-git-send-email-razor@blackwall.org>
Cc: monis@voltaire.com, j.vosburgh@gmail.com,
	gospo@cumulusnetworks.com, vfalico@gmail.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36762 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbbGOUJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 16:09:48 -0400
Received: by wgxm20 with SMTP id m20so42118440wgx.3
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 13:09:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

If a bonding device enslaves devices != arphrd_ether it'll change types
and if later these devices are released, it can enslave an arphrd_ether
device and switch back calling ether_setup() which resets dev->flags to
IFF_BROADCAST|IFF_MULTICAST and clears IFF_MASTER which then could lead
to many different bugs. This bug seems to have been there since the
introduction of ether_setup() in bond_enslave().

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: e36b9d16c6a6 ("bonding: clean muticast addresses when device changes type")
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 317a49480475..8ba119896e55 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1368,6 +1368,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 				bond_setup_by_slave(bond_dev, slave_dev);
 			else {
 				ether_setup(bond_dev);
+				bond_dev->flags |= IFF_MASTER;
 				bond_dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 			}
 
-- 
1.9.3
