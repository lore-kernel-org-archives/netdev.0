From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/5] e1000e: Add interrupt moderation run-time ethtool
	interface
Date: Mon, 14 Apr 2008 10:06:04 -0700
Message-ID: <20080414170604.23286.86187.stgit@localhost.localdomain>
References: <20080414170557.23286.71580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9403 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbYDNRGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 13:06:12 -0400
In-Reply-To: <20080414170557.23286.71580.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool -c / -C interface can now be used to modify the
irq moderation algorithm. This change does not require an
adapter reset and can thus be used at all times. The adapter
only supports changing/reading rx-usecs which has special
values for 0, 1 and 3:

0 - no irq moderation whatsoever
1 - normal moderation favoring regular mixed traffic (default)
3 - best attempt at low latency possible at cost of CPU

For values between 10 and 10000 the rx-usecs defines "the minimum
time between successive irqs" in usec, unlike the module parameter.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h   |    3 +++
 drivers/net/e1000e/ethtool.c |   43 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 4d3d1c2..79a426f 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -70,6 +70,9 @@ struct e1000_info;
 #define E1000_MAX_RXD			4096
 #define E1000_MIN_RXD			80
 
+#define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */
+#define E1000_MAX_ITR_USECS		10000 /* 100    irq/sec */
+
 /* Early Receive defines */
 #define E1000_ERT_2048			0x100
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index c894a6f..ce045ac 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1770,6 +1770,47 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+static int e1000_get_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *ec)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (adapter->itr_setting <= 3)
+		ec->rx_coalesce_usecs = adapter->itr_setting;
+	else
+		ec->rx_coalesce_usecs = 1000000 / adapter->itr_setting;
+
+	return 0;
+}
+
+static int e1000_set_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *ec)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	if ((ec->rx_coalesce_usecs > E1000_MAX_ITR_USECS) ||
+	    ((ec->rx_coalesce_usecs > 3) &&
+	     (ec->rx_coalesce_usecs < E1000_MIN_ITR_USECS)) ||
+	    (ec->rx_coalesce_usecs == 2))
+		return -EINVAL;
+
+	if (ec->rx_coalesce_usecs <= 3) {
+		adapter->itr = 20000;
+		adapter->itr_setting = ec->rx_coalesce_usecs;
+	} else {
+		adapter->itr = (1000000 / ec->rx_coalesce_usecs);
+		adapter->itr_setting = adapter->itr & ~3;
+	}
+
+	if (adapter->itr_setting != 0)
+		ew32(ITR, 1000000000 / (adapter->itr * 256));
+	else
+		ew32(ITR, 0);
+
+	return 0;
+}
+
 static int e1000_nway_reset(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1845,6 +1886,8 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.phys_id		= e1000_phys_id,
 	.get_ethtool_stats	= e1000_get_ethtool_stats,
 	.get_sset_count		= e1000e_get_sset_count,
+	.get_coalesce		= e1000_get_coalesce,
+	.set_coalesce		= e1000_set_coalesce,
 };
 
 void e1000e_set_ethtool_ops(struct net_device *netdev)

