From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v4 6/7] bonding: handle NETIF_F_HW_SWITCH_OFFLOAD flag and add ndo_bridge_setlink/dellink handlers
Date: Thu, 29 Jan 2015 22:40:16 -0800
Message-ID: <1422600017-42393-7-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:50866 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbbA3Gk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 01:40:29 -0500
Received: by mail-pa0-f50.google.com with SMTP id rd3so48611918pab.9
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 22:40:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

We want bond to pick up the offload flag if any of its slaves have it.

NETIF_F_HW_SWITCH_OFFLOAD flag is added to the mask, so that
netdev_increment_features does not ignore it.

This also adds ndo_bridge_setlink and ndo_bridge_dellink handlers.
These currently point to the default handlers provided by the
switchdev api.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e229a86..c9e519c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -77,6 +77,7 @@
 #include <net/pkt_sched.h>
 #include <linux/rculist.h>
 #include <net/flow_keys.h>
+#include <net/switchdev.h>
 #include <net/bonding.h>
 #include <net/bond_3ad.h>
 #include <net/bond_alb.h>
@@ -979,7 +980,11 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	netdev_features_t mask;
 	struct slave *slave;
 
-	mask = features;
+	/* If any slave has the offload feature flag set,
+	 * set the offload flag on the bond.
+	 */
+	mask = features | NETIF_F_HW_SWITCH_OFFLOAD;
+
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
 
@@ -3952,6 +3957,8 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
+	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
+	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
 };
 
 static const struct device_type bond_type = {
-- 
1.7.10.4
