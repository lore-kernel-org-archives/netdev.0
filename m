From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] e1000: Report link status in ethtool when
	interface is down
Date: Wed, 03 Feb 2010 16:49:28 -0800
Message-ID: <20100204004926.16084.32526.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:55759
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932617Ab0BDAtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 19:49:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

With this change ethtool will correctly report link status when
the interface is down. Currently ethtool reports the link as not
detected when the interface is down.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h         |    1 +
 drivers/net/e1000/e1000_ethtool.c |   19 ++++++++++++++++++-
 drivers/net/e1000/e1000_main.c    |    2 +-
 3 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index e8932db..9902b33 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -349,6 +349,7 @@ extern int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
 extern void e1000_update_stats(struct e1000_adapter *adapter);
+extern bool e1000_has_link(struct e1000_adapter *adapter);
 extern void e1000_power_up_phy(struct e1000_adapter *);
 extern void e1000_set_ethtool_ops(struct net_device *netdev);
 extern void e1000_check_options(struct e1000_adapter *adapter);
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 13e9ece..c67e931 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -215,6 +215,23 @@ static int e1000_set_settings(struct net_device *netdev,
 	return 0;
 }
 
+static u32 e1000_get_link(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	/*
+	 * If the link is not reported up to netdev, interrupts are disabled,
+	 * and so the physical link state may have changed since we last
+	 * looked. Set get_link_status to make sure that the true link
+	 * state is interrogated, rather than pulling a cached and possibly
+	 * stale link state from the driver.
+	 */
+	if (!netif_carrier_ok(netdev))
+		adapter->hw.get_link_status = 1;
+
+	return e1000_has_link(adapter);
+}
+
 static void e1000_get_pauseparam(struct net_device *netdev,
 				 struct ethtool_pauseparam *pause)
 {
@@ -1892,7 +1909,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_msglevel           = e1000_get_msglevel,
 	.set_msglevel           = e1000_set_msglevel,
 	.nway_reset             = e1000_nway_reset,
-	.get_link               = ethtool_op_get_link,
+	.get_link               = e1000_get_link,
 	.get_eeprom_len         = e1000_get_eeprom_len,
 	.get_eeprom             = e1000_get_eeprom,
 	.set_eeprom             = e1000_set_eeprom,
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b608528..4ff50d6 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2246,7 +2246,7 @@ static void e1000_82547_tx_fifo_stall(unsigned long data)
 	}
 }
 
-static bool e1000_has_link(struct e1000_adapter *adapter)
+bool e1000_has_link(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	bool link_active = false;

