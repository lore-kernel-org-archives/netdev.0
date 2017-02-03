From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 9/9] ldmvsw: disable tso and gso for bridge operations
Date: Fri,  3 Feb 2017 09:42:35 -0800
Message-ID: <1486143755-192532-10-git-send-email-shannon.nelson@oracle.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22322 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbdBCRoX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 12:44:23 -0500
In-Reply-To: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ldmvsw driver is specifically for supporting the ldom virtual
networking by running in the primary ldom and using the LDC to connect
the remaining ldoms to the outside world via a bridge.  With TSO and GSO
supported while connected the bridge, things tend to misbehave as seen in
our case by delayed packets, enough to begin triggering retransmits and
affecting overall throughput.  By turning off advertised support for TSO
and GSO we restore stable traffic flow through the bridge.

Orabug: 23293104

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c         |    5 ++---
 drivers/net/ethernet/sun/sunvnet_common.c |    3 ++-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 552c0a9..bd2cfbc 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -299,8 +299,7 @@ static struct net_device *vsw_alloc_netdev(u8 hwaddr[],
 	dev->ethtool_ops = &vsw_ethtool_ops;
 	dev->watchdog_timeo = VSW_TX_TIMEOUT;
 
-	dev->hw_features = NETIF_F_TSO | NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
-			   NETIF_F_HW_CSUM | NETIF_F_SG;
+	dev->hw_features = NETIF_F_HW_CSUM;
 	dev->features = dev->hw_features;
 
 	SET_NETDEV_DEV(dev, &vdev->dev);
@@ -390,7 +389,7 @@ static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	port->vp = vp;
 	port->dev = dev;
 	port->switch_port = 1;
-	port->tso = true;
+	port->tso = false; /* no tso in vsw, misbehaves in bridge */
 	port->tsolen = 0;
 
 	/* Mark the port as belonging to ldmvsw which directs the
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index a479a58..3d31c80 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -210,6 +210,7 @@ static int handle_attr_info(struct vio_driver_state *vio,
 	} else {
 		pkt->cflags &= ~VNET_LSO_IPV4_CAPAB;
 		pkt->ipv4_lso_maxlen = 0;
+		port->tsolen = 0;
 	}
 
 	/* for version >= 1.6, ACK packet mode we support */
@@ -1685,7 +1686,7 @@ static void vnet_port_reset(struct vnet_port *port)
 	del_timer(&port->clean_timer);
 	sunvnet_port_free_tx_bufs_common(port);
 	port->rmtu = 0;
-	port->tso = true;
+	port->tso = (port->vsw == 0);  /* no tso in vsw, misbehaves in bridge */
 	port->tsolen = 0;
 }
 
-- 
1.7.1
