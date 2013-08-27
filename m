From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 04/11] openvswitch:: link upper device for port devices
Date: Tue, 27 Aug 2013 13:20:41 -0700
Message-ID: <1377634848-34327-5-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Jiri Pirko <jiri@resnulli.us>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:41755 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752591Ab3H0UVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:06 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so5257206pbb.20
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:04 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>

Link upper device properly. That will make IFLA_MASTER filled up.
Set the master to port 0 of the datapath under which the port belongs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-netdev.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 5982f3f..09d93c1 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -25,6 +25,7 @@
 #include <linux/llc.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
+#include <linux/openvswitch.h>
 
 #include <net/llc.h>
 
@@ -74,6 +75,15 @@ static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
 	return RX_HANDLER_CONSUMED;
 }
 
+static struct net_device *get_dpdev(struct datapath *dp)
+{
+	struct vport *local;
+
+	local = ovs_vport_ovsl(dp, OVSP_LOCAL);
+	BUG_ON(!local);
+	return netdev_vport_priv(local)->dev;
+}
+
 static struct vport *netdev_create(const struct vport_parms *parms)
 {
 	struct vport *vport;
@@ -103,10 +113,15 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	}
 
 	rtnl_lock();
+	err = netdev_master_upper_dev_link(netdev_vport->dev,
+					   get_dpdev(vport->dp));
+	if (err)
+		goto error_unlock;
+
 	err = netdev_rx_handler_register(netdev_vport->dev, netdev_frame_hook,
 					 vport);
 	if (err)
-		goto error_unlock;
+		goto error_master_upper_dev_unlink;
 
 	dev_set_promiscuity(netdev_vport->dev, 1);
 	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
@@ -114,6 +129,8 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 
 	return vport;
 
+error_master_upper_dev_unlink:
+	netdev_upper_dev_unlink(netdev_vport->dev, get_dpdev(vport->dp));
 error_unlock:
 	rtnl_unlock();
 error_put:
@@ -140,6 +157,7 @@ static void netdev_destroy(struct vport *vport)
 	rtnl_lock();
 	netdev_vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
 	netdev_rx_handler_unregister(netdev_vport->dev);
+	netdev_upper_dev_unlink(netdev_vport->dev, get_dpdev(vport->dp));
 	dev_set_promiscuity(netdev_vport->dev, -1);
 	rtnl_unlock();
 
-- 
1.8.1.2
