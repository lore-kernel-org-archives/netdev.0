From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/9] net: vrf: Set slave's private flag before linking
Date: Wed, 15 Mar 2017 12:05:07 +0100
Message-ID: <1489575912-6469-5-git-send-email-jiri@resnulli.us>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34135 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdCOLF0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:05:26 -0400
Received: by mail-wm0-f65.google.com with SMTP id u132so4072806wmg.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:05:20 -0700 (PDT)
In-Reply-To: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
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
index 22379da..c693267 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -746,14 +746,18 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
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
