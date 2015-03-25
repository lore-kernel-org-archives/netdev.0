From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: dsa: Handle non-bridge master change
Date: Wed, 25 Mar 2015 08:08:37 -0700
Message-ID: <1427296117-1805-1-git-send-email-linux@roeck-us.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:43061 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209AbbCYPIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:08:51 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YamvK-001Jel-3D
	for netdev@vger.kernel.org; Wed, 25 Mar 2015 15:08:50 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Master change notifications may occur other than when joining or
leaving a bridge, for example when being added to or removed from
a bond or Open vSwitch. In that case, do nothing instead of asking
the switch driver to remove a port from a bridge that it didn't join.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Modeled after 'rocker: handle non-bridge master change',
after confirming that the condition is seen on dsa interfaces.

 net/dsa/slave.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f0af7aa331c1..39555f3f263b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -830,12 +830,13 @@ static bool dsa_slave_dev_check(struct net_device *dev)
 static int dsa_slave_master_changed(struct net_device *dev)
 {
 	struct net_device *master = netdev_master_upper_dev_get(dev);
+	struct dsa_slave_priv *p = netdev_priv(dev);
 	int err = 0;
 
 	if (master && master->rtnl_link_ops &&
 	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
 		err = dsa_slave_bridge_port_join(dev, master);
-	else
+	else if (dsa_port_is_bridged(p))
 		err = dsa_slave_bridge_port_leave(dev);
 
 	return err;
-- 
2.1.0
