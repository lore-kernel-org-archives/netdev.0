From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: [RFC] macvlan: Allow other mode macvlans in addition to passthru
Date: Fri, 20 Dec 2013 10:41:28 +0100
Message-ID: <1387532488-13688-1-git-send-email-helmut.schaa@googlemail.com>
Cc: Patrick McHardy <kaber@trash.net>,
	Helmut Schaa <helmut.schaa@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:56628 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165Ab3LTJlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 04:41:00 -0500
Received: by mail-ea0-f177.google.com with SMTP id n15so924028ead.22
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 01:40:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows a passthru macvlan to coexist with other macvlans. For example
the passthru macvlan can be put into a bridge while concurrently using a
private macvlan.

The passthru interface will not get frames destined for other macvlan
interfaces but everything else.

Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>
---
 drivers/net/macvlan.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index acf9379..1f6dae8c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -230,11 +230,11 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_PASS;
 	}
 
-	if (port->passthru)
+	vlan = macvlan_hash_lookup(port, eth->h_dest);
+
+	if (vlan == NULL && port->passthru)
 		vlan = list_first_or_null_rcu(&port->vlans,
 					      struct macvlan_dev, list);
-	else
-		vlan = macvlan_hash_lookup(port, eth->h_dest);
 	if (vlan == NULL)
 		return RX_HANDLER_PASS;
 
@@ -843,10 +843,6 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	}
 	port = macvlan_port_get_rtnl(lowerdev);
 
-	/* Only 1 macvlan device can be created in passthru mode */
-	if (port->passthru)
-		return -EINVAL;
-
 	vlan->lowerdev = lowerdev;
 	vlan->dev      = dev;
 	vlan->port     = port;
@@ -862,7 +858,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		vlan->flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
 
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
-		if (port->count)
+		/* Only a single passthru interface is allowed */
+		if (port->passthru)
 			return -EINVAL;
 		port->passthru = true;
 		eth_hw_addr_inherit(dev, lowerdev);
-- 
1.8.1.4
