From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/bonding: emit address change event in more places
Date: Mon,  2 Apr 2012 19:17:09 +0300
Message-ID: <1333383430-17456-2-git-send-email-ogerlitz@mellanox.com>
References: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, fubar@us.ibm.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:39632 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752243Ab2DBQRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 12:17:22 -0400
In-Reply-To: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>

commit 7d26bb103c4 "bonding: emit event when bonding changes MAC" didn't
take care to emit the NETDEV_CHANGEADDR event in other places where bonding
actually changes the mac address (to all zeroes), in bond_release, and
bond_release_all. As a result the neighbours aren't deleted by the core
networking code (which does so upon getting that event).

Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
---
 drivers/net/bonding/bond_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a20b585..b0a278d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2035,6 +2035,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	write_unlock_bh(&bond->lock);
 	unblock_netpoll_tx();
 
+	if (bond->slave_cnt == 0)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
+
 	bond_compute_features(bond);
 	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
 	    (old_features & NETIF_F_VLAN_CHALLENGED))
@@ -2218,6 +2221,8 @@ static int bond_release_all(struct net_device *bond_dev)
 out:
 	write_unlock_bh(&bond->lock);
 
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
+
 	bond_compute_features(bond);
 
 	return 0;
-- 
1.7.1
