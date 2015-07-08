From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v4 3/4] rocker: Handle protodown notifications.
Date: Wed,  8 Jul 2015 14:04:24 -0700
Message-ID: <1436389465-3077-4-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33027 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932472AbbGHVEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:04:42 -0400
Received: by pacws9 with SMTP id ws9so139186648pac.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:04:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

protodown can be set by user space applications like MLAG on detecting
errors on a switch port. This patch provides sample switch driver changes
for handling protodown. Rocker PHYS disables the port in response to
protodown.

To test this unctionality I used the qemu-rocker patch that Scott sent out
in response to the v3 posting (needed to set link up/down when phy is
nabled/disabled).


Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2d8578cade..10051fa 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3983,7 +3983,8 @@ static int rocker_port_open(struct net_device *dev)
 
 	napi_enable(&rocker_port->napi_tx);
 	napi_enable(&rocker_port->napi_rx);
-	rocker_port_set_enable(rocker_port, true);
+	if (!(dev->proto_flags & IF_PROTOF_DOWN))
+		rocker_port_set_enable(rocker_port, true);
 	netif_start_queue(dev);
 	return 0;
 
@@ -4167,6 +4168,21 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	return err ? -EOPNOTSUPP : 0;
 }
 
+static int rocker_port_change_proto_flags(struct net_device *dev,
+					  unsigned int flags)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	if (rocker_port->dev->flags & IFF_UP) {
+		if (flags & IF_PROTOF_DOWN)
+			rocker_port_set_enable(rocker_port, false);
+		else
+			rocker_port_set_enable(rocker_port, true);
+	}
+	rocker_port->dev->proto_flags = flags;
+	return 0;
+}
+
 static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
@@ -4179,6 +4195,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_del			= switchdev_port_fdb_del,
 	.ndo_fdb_dump			= switchdev_port_fdb_dump,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
+	.ndo_change_proto_flags		= rocker_port_change_proto_flags,
 };
 
 /********************
-- 
1.7.10.4
