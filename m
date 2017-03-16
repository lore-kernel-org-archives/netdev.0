From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 4/9] net: vrf: Set slave's private flag before linking
Date: Thu, 16 Mar 2017 09:08:15 +0100
Message-ID: <1489651700-3586-5-git-send-email-jiri@resnulli.us>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34318 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751282AbdCPIIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:08:46 -0400
Received: by mail-wr0-f195.google.com with SMTP id u48so4828092wrc.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 01:08:27 -0700 (PDT)
In-Reply-To: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow listeners of the subsequent CHANGEUPPER notification to retrieve
the VRF's table ID by calling l3mdev_fib_table() with the slave netdev.
Without this change, the netdev won't be considered an L3 slave and the
function would return 0.

This is consistent with other master device such as bridge and bond that
set the slave's private flag before linking. It also makes
do_vrf_{add,del}_slave() symmetric.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/vrf.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index fea687f..7f28021 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -747,14 +747,18 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
 	int ret;
 
+	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
 	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
 	if (ret < 0)
-		return ret;
+		goto err;
 
-	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
 	cycle_netdev(port_dev);
 
 	return 0;
+
+err:
+	port_dev->priv_flags &= ~IFF_L3MDEV_SLAVE;
+	return ret;
 }
 
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
-- 
2.7.4
