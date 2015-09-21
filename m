From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 2/4] net: Remove use of IFF_SLAVE with L3 devices
Date: Mon, 21 Sep 2015 16:32:56 -0700
Message-ID: <1442878378-13322-3-git-send-email-dsa@cumulusnetworks.com>
References: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36405 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932553AbbIUXdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:33:16 -0400
Received: by padbj2 with SMTP id bj2so4652626pad.3
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 16:33:16 -0700 (PDT)
In-Reply-To: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of IFF_SLAVE flag causes problems with IPv6. addrconf_notify does
not respond to netdev events for devices with IFF_SLAVE set. This breaks
DAD, neighbor discovery and spirals to non-working death for IPv6.

L3 master devices will have IFF_MASTER and IFF_L3MDEV set.
L3 slave devices will only have IFF_L3MDEV set.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c         | 2 --
 include/linux/netdevice.h | 2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index bf48c8b448fc..9e3afe011396 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -430,7 +430,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 	if (ret < 0)
 		goto out_unregister;
 
-	port_dev->flags |= IFF_SLAVE;
 	port_dev->priv_flags |= IFF_L3MDEV;
 	__vrf_insert_slave(queue, slave);
 	cycle_netdev(port_dev);
@@ -460,7 +459,6 @@ static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 	struct slave *slave;
 
 	netdev_upper_dev_unlink(port_dev, dev);
-	port_dev->flags &= ~IFF_SLAVE;
 	port_dev->priv_flags &= ~IFF_L3MDEV;
 
 	netdev_rx_handler_unregister(port_dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ae95d922a569..5ae287d1e3fe 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3831,7 +3831,7 @@ static inline bool netif_is_l3_master(const struct net_device *dev)
 
 static inline bool netif_is_l3_slave(const struct net_device *dev)
 {
-	return dev->flags & IFF_SLAVE && dev->priv_flags & IFF_L3MDEV;
+	return !(dev->flags & IFF_MASTER) && dev->priv_flags & IFF_L3MDEV;
 }
 
 static inline bool netif_is_bridge_master(const struct net_device *dev)
-- 
1.9.1
