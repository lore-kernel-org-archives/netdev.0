From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 07/12] net: dsa: allow drivers to do link adjustment
Date: Tue,  5 Aug 2014 15:31:41 -0700
Message-ID: <1407277906-19989-8-git-send-email-f.fainelli@gmail.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:53485 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbaHEWcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 18:32:13 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so2197640pad.21
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 15:32:13 -0700 (PDT)
In-Reply-To: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever libphy determines that the link status of a given PHY/port has
changed, allow to call into the switch driver link adjustment callback
so proper actions can be taken care of by the switch driver upon link
notification.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 7 +++++++
 net/dsa/slave.c   | 4 ++++
 2 files changed, 11 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 35141155f368..e024511dbcdb 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -16,6 +16,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
+#include <linux/phy.h>
 
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
@@ -179,6 +180,12 @@ struct dsa_switch_driver {
 	void	(*poll_link)(struct dsa_switch *ds);
 
 	/*
+	 * Link state adjustment (called from libphy)
+	 */
+	void	(*adjust_link)(struct dsa_switch *ds, int port,
+				struct phy_device *phydev);
+
+	/*
 	 * ethtool hardware statistics.
 	 */
 	void	(*get_strings)(struct dsa_switch *ds, int port, uint8_t *data);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d1dfa3d8552f..08a92db7f109 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -357,6 +357,7 @@ static const struct net_device_ops dummy_netdev_ops = {
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
 	unsigned int status_changed = 0;
 
 	if (p->old_link != p->phy->link) {
@@ -374,6 +375,9 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 		p->old_pause = p->phy->pause;
 	}
 
+	if (ds->drv->adjust_link && status_changed)
+		ds->drv->adjust_link(ds, p->port, p->phy);
+
 	if (status_changed)
 		phy_print_status(p->phy);
 }
-- 
1.9.1
