From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bridge: avoid ethtool on non running interface
Date: Tue, 24 Aug 2010 16:12:56 -0700
Message-ID: <20100824161256.0a6079e7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53737 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933554Ab0HXXM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 19:12:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bridge port is offline, don't call ethtool to query speed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_if.c     |   23 ++++++++++++-----------
 net/bridge/br_notify.c |    9 +--------
 2 files changed, 13 insertions(+), 19 deletions(-)

--- a/net/bridge/br_if.c	2010-08-24 16:10:13.999318302 -0700
+++ b/net/bridge/br_if.c	2010-08-24 16:11:16.086598495 -0700
@@ -67,20 +67,21 @@ void br_port_carrier_check(struct net_br
 	struct net_device *dev = p->dev;
 	struct net_bridge *br = p->br;
 
-	if (netif_carrier_ok(dev))
+	if (netif_running(dev) && netif_carrier_ok(dev))
 		p->path_cost = port_cost(dev);
 
-	if (netif_running(br->dev)) {
-		spin_lock_bh(&br->lock);
-		if (netif_carrier_ok(dev)) {
-			if (p->state == BR_STATE_DISABLED)
-				br_stp_enable_port(p);
-		} else {
-			if (p->state != BR_STATE_DISABLED)
-				br_stp_disable_port(p);
-		}
-		spin_unlock_bh(&br->lock);
+	if (!netif_running(br->dev))
+		return;
+
+	spin_lock_bh(&br->lock);
+	if (netif_running(dev) && netif_carrier_ok(dev)) {
+		if (p->state == BR_STATE_DISABLED)
+			br_stp_enable_port(p);
+	} else {
+		if (p->state != BR_STATE_DISABLED)
+			br_stp_disable_port(p);
 	}
+	spin_unlock_bh(&br->lock);
 }
 
 static void release_nbp(struct kobject *kobj)
