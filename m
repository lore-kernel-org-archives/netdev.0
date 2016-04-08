From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH net-next] macvlan: Set nocarrier when lowerdev admin down
Date: Thu,  7 Apr 2016 21:06:24 -0400
Message-ID: <1460077584-20824-1-git-send-email-dbanerje@akamai.com>
References: <57063EDD.3040406@cumulusnetworks.com>
Cc: Debabrata Banerjee <dbanerje@akamai.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:34489 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932237AbcDHBPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 21:15:03 -0400
In-Reply-To: <57063EDD.3040406@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the lowerdev is set administratively down disable carrier on the
macvlan interface. This means operstate gets set properly instead of
still being "up".

Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
---
 drivers/net/macvlan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2bcf1f3..16d0e56 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1525,10 +1525,14 @@ static int macvlan_device_event(struct notifier_block *unused,
 
 	switch (event) {
 	case NETDEV_UP:
+	case NETDEV_DOWN:
 	case NETDEV_CHANGE:
-		list_for_each_entry(vlan, &port->vlans, list)
+		list_for_each_entry(vlan, &port->vlans, list) {
 			netif_stacked_transfer_operstate(vlan->lowerdev,
 							 vlan->dev);
+			if (!(vlan->lowerdev->flags & IFF_UP))
+				netif_carrier_off(vlan->dev);
+		}
 		break;
 	case NETDEV_FEAT_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list) {
-- 
2.8.0
