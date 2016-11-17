From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/3] net: Check netdevice presence on dev_get_phys_port_id
Date: Thu, 17 Nov 2016 17:40:50 +0200
Message-ID: <1479397251-6932-3-git-send-email-tariqt@mellanox.com>
References: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53547 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934902AbcKQRKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:10:09 -0500
In-Reply-To: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Check presence of network device before calling device driver
ndo_get_phys_port_id callback. Otherwise callback may access
non-existing data structures and cause kernel panic.

Fixes: 66b52b0dc82c ("net: add ndo to get id of physical port of the device")
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Reported-by: Steve Wise <swise@opengridcomputing.com>
Cc: Jiri Pirko <jiri@mellanox.com>
---
 net/core/dev.c       | 2 ++
 net/core/rtnetlink.c | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6666b28b6815..7de0d000a9f8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6602,6 +6602,8 @@ int dev_get_phys_port_id(struct net_device *dev,
 
 	if (!ops->ndo_get_phys_port_id)
 		return -EOPNOTSUPP;
+	if (!netif_device_present(dev))
+		return -ENODEV;
 	return ops->ndo_get_phys_port_id(dev, ppid);
 }
 EXPORT_SYMBOL(dev_get_phys_port_id);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a6529c55ffb7..b3dd81f82e70 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1036,7 +1036,7 @@ static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
 
 	err = dev_get_phys_port_id(dev, &ppid);
 	if (err) {
-		if (err == -EOPNOTSUPP)
+		if (err == -EOPNOTSUPP || err == -ENODEV)
 			return 0;
 		return err;
 	}
-- 
1.8.3.1
