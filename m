From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v7 3/4] rocker: Handle protodown notifications.
Date: Tue, 14 Jul 2015 13:43:21 -0700
Message-ID: <1436906602-2958-4-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34345 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbGNUng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 16:43:36 -0400
Received: by pdbep18 with SMTP id ep18so11969701pdb.1
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 13:43:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

protodown can be set by user space applications like MLAG on detecting
errors on a switch port. This patch provides sample switch driver changes
for handling protodown. Rocker PHYS disables the port in response to
protodown.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2d8578cade..b6c25c9 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3983,7 +3983,8 @@ static int rocker_port_open(struct net_device *dev)
 
 	napi_enable(&rocker_port->napi_tx);
 	napi_enable(&rocker_port->napi_rx);
-	rocker_port_set_enable(rocker_port, true);
+	if (!dev->proto_down)
+		rocker_port_set_enable(rocker_port, true);
 	netif_start_queue(dev);
 	return 0;
 
@@ -4167,6 +4168,17 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	return err ? -EOPNOTSUPP : 0;
 }
 
+static int rocker_port_change_proto_down(struct net_device *dev,
+					 bool proto_down)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	if (rocker_port->dev->flags & IFF_UP)
+		rocker_port_set_enable(rocker_port, !proto_down);
+	rocker_port->dev->proto_down = proto_down;
+	return 0;
+}
+
 static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
@@ -4179,6 +4191,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_del			= switchdev_port_fdb_del,
 	.ndo_fdb_dump			= switchdev_port_fdb_dump,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
+	.ndo_change_proto_down		= rocker_port_change_proto_down,
 };
 
 /********************
-- 
1.7.10.4
