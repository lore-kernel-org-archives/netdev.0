From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 4/7] net: vrf: Add extack messages for enslave errors
Date: Tue,  3 Oct 2017 21:58:51 -0700
Message-ID: <1507093134-20406-5-git-send-email-dsahern@gmail.com>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jiri@mellanox.com, idosch@mellanox.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33032 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751177AbdJDE7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:59:05 -0400
Received: by mail-pg0-f67.google.com with SMTP id b11so3048281pgn.0
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 21:59:05 -0700 (PDT)
In-Reply-To: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/vrf.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 77d0655a0250..0b54f553228e 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -772,8 +772,11 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev,
 	/* do not allow loopback device to be enslaved to a VRF.
 	 * The vrf device acts as the loopback for the vrf.
 	 */
-	if (port_dev == dev_net(dev)->loopback_dev)
+	if (port_dev == dev_net(dev)->loopback_dev) {
+		NL_SET_ERR_MSG(extack,
+			       "Can not enslave loopback device to a VRF");
 		return -EOPNOTSUPP;
+	}
 
 	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
 	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL, extack);
@@ -792,7 +795,13 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev,
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev,
 			 struct netlink_ext_ack *extack)
 {
-	if (netif_is_l3_master(port_dev) || netif_is_l3_slave(port_dev))
+	if (netif_is_l3_master(port_dev)) {
+		NL_SET_ERR_MSG(extack,
+			       "Can not enslave an L3 master device to a VRF");
+		return -EINVAL;
+	}
+
+	if (netif_is_l3_slave(port_dev))
 		return -EINVAL;
 
 	return do_vrf_add_slave(dev, port_dev, extack);
-- 
2.1.4
