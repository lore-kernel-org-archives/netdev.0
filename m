From: anuradhak@cumulusnetworks.com
Subject: [RFC PATCH net-next v3 3/4] rocker: Handle IFF_PROTODOWN by doing a PHYS-DOWN on the switch port.
Date: Mon, 27 Apr 2015 10:38:23 -0700
Message-ID: <1430156304-13187-4-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34336 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058AbbD0Rih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:38:37 -0400
Received: by pdbqa5 with SMTP id qa5so135520632pdb.1
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 10:38:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

IFF_PROTODOWN can be set by user space applications like MLAG on detecting
errors on a switch port. This patch provides sample switch driver changes
for handling IFF_PROTODOWN. Rocker PHYS disables the port in response to
protodown.

Note: I understand Scott has some rocker changes on hold. I will re-spin
this patch once his changes are in.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a87b177..e3084e3 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3838,7 +3838,8 @@ static int rocker_port_open(struct net_device *dev)
 
 	napi_enable(&rocker_port->napi_tx);
 	napi_enable(&rocker_port->napi_rx);
-	rocker_port_set_enable(rocker_port, true);
+	if (!(dev->flags & IFF_PROTO_DOWN))
+		rocker_port_set_enable(rocker_port, true);
 	netif_start_queue(dev);
 	return 0;
 
@@ -4238,6 +4239,18 @@ static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
 	return rocker_port_stp_update(rocker_port, state);
 }
 
+static int rocker_port_swdev_port_phy_state_set(struct net_device *dev,
+						bool enable)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	if (enable && (dev->flags & IFF_UP) && !(dev->flags & IFF_PROTO_DOWN))
+		rocker_port_set_enable(rocker_port, true);
+	else
+		rocker_port_set_enable(rocker_port, false);
+	return 0;
+}
+
 static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
 					  __be32 dst, int dst_len,
 					  struct fib_info *fi,
@@ -4268,6 +4281,7 @@ static const struct swdev_ops rocker_port_swdev_ops = {
 	.swdev_port_stp_update		= rocker_port_swdev_port_stp_update,
 	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
 	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
+	.swdev_port_phy_state_set	= rocker_port_swdev_port_phy_state_set,
 };
 
 /********************
-- 
1.7.10.4
