From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] e1000: allow ethtool coalesece to adjust
	interrupts per second
Date: Mon, 06 Jul 2009 13:44:20 -0700
Message-ID: <20090706204358.17533.64103.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:33013
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752326AbZGFUoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 16:44:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch allows on-the-fly adjustment of the interrupts per second generated
by e1000 devices 82545/82546 (hardware support of ITR register is a
requirement)

adjust using this command:
ethtool -C eth0 rx-usecs 10

where 10 is 10 microseconds per interrupt interval, so 10 = 100,000 interrupts
per second, and 125 = 8000 interrupts per second.

changes should be immediate.

1,3 are special values and indicate the automatic tuning mode to the driver,
where 1 is 4000-90000 interrupts per second and 3 is 4000-20000 interrupts
per second and is the driver default.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h         |    3 ++
 drivers/net/e1000/e1000_ethtool.c |   51 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index e9a416f..c87f2cb 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -111,6 +111,9 @@ do {									\
 #define E1000_MIN_RXD                       80
 #define E1000_MAX_82544_RXD               4096
 
+#define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */
+#define E1000_MAX_ITR_USECS		10000 /* 100    irq/sec */
+
 /* this is the size past which hardware will drop packets when setting LPE=0 */
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
 
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index c854c96..27f996a 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1904,6 +1904,53 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+static int e1000_get_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *ec)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (adapter->hw.mac_type < e1000_82545)
+		return -EOPNOTSUPP;
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
+	if (hw->mac_type < e1000_82545)
+		return -EOPNOTSUPP;
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
@@ -1978,7 +2025,9 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_strings            = e1000_get_strings,
 	.phys_id                = e1000_phys_id,
 	.get_ethtool_stats      = e1000_get_ethtool_stats,
-	.get_sset_count		= e1000_get_sset_count,
+	.get_sset_count         = e1000_get_sset_count,
+	.get_coalesce           = e1000_get_coalesce,
+	.set_coalesce           = e1000_set_coalesce,
 };
 
 void e1000_set_ethtool_ops(struct net_device *netdev)

