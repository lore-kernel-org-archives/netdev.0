From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/3] net: Check netdevice presence on dev_get_phys_port_name
Date: Thu, 17 Nov 2016 17:40:51 +0200
Message-ID: <1479397251-6932-4-git-send-email-tariqt@mellanox.com>
References: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53548 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754415AbcKQRKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:10:09 -0500
In-Reply-To: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Check presence of network device before calling device driver
ndo_get_phys_port_name callback. Otherwise callback may access
non-existing data structures and cause kernel panic.

Fixes: db24a9044ee1 ('net: add support for phys_port_name')
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
index 7de0d000a9f8..b21d77405863 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6623,6 +6623,8 @@ int dev_get_phys_port_name(struct net_device *dev,
 
 	if (!ops->ndo_get_phys_port_name)
 		return -EOPNOTSUPP;
+	if (!netif_device_present(dev))
+		return -ENODEV;
 	return ops->ndo_get_phys_port_name(dev, name, len);
 }
 EXPORT_SYMBOL(dev_get_phys_port_name);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b3dd81f82e70..40cd41376566 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1054,7 +1054,7 @@ static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
 
 	err = dev_get_phys_port_name(dev, name, sizeof(name));
 	if (err) {
-		if (err == -EOPNOTSUPP)
+		if (err == -EOPNOTSUPP || err == -ENODEV)
 			return 0;
 		return err;
 	}
-- 
1.8.3.1
