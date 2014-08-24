From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 07/12] net: dsa: allow drivers to do link adjustment
Date: Sun, 24 Aug 2014 11:44:24 -0700
Message-ID: <1408905869-10471-8-git-send-email-f.fainelli@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41601 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbaHXSpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 14:45:13 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so18874076pdb.19
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 11:45:11 -0700 (PDT)
In-Reply-To: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
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
index 6620d4722efa..4507c50d29a6 100644
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
index 35cd8b7a56b8..893afe9e60aa 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -357,6 +357,7 @@ static const struct net_device_ops notag_netdev_ops = {
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
