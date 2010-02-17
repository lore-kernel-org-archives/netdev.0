From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/18] igb: Report link status in ethtool when
	interface is down
Date: Wed, 17 Feb 2010 03:01:21 -0800
Message-ID: <20100217110119.17723.33322.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:34139 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753437Ab0BQLBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:01:38 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

With this change ethtool will correctly report link status when
the interface is down. Currently ethtool reports the link as not
detected when the interface is down.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    1 +
 drivers/net/igb/igb_ethtool.c |   20 +++++++++++++++++++-
 drivers/net/igb/igb_main.c    |    2 +-
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 0efd285..452a4de 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -356,6 +356,7 @@ extern void igb_unmap_and_free_tx_resource(struct igb_ring *,
 					   struct igb_buffer *);
 extern void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
 extern void igb_update_stats(struct igb_adapter *);
+extern bool igb_has_link(struct igb_adapter *adapter);
 extern void igb_set_ethtool_ops(struct net_device *);
 
 static inline s32 igb_reset_phy(struct e1000_hw *hw)
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 145a8eb..4eea03b 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -234,6 +234,24 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
+static u32 igb_get_link(struct net_device *netdev)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_mac_info *mac = &adapter->hw.mac;
+
+	/*
+	 * If the link is not reported up to netdev, interrupts are disabled,
+	 * and so the physical link state may have changed since we last
+	 * looked. Set get_link_status to make sure that the true link
+	 * state is interrogated, rather than pulling a cached and possibly
+	 * stale link state from the driver.
+	 */
+	if (!netif_carrier_ok(netdev))
+		mac->get_link_status = 1;
+
+	return igb_has_link(adapter);
+}
+
 static void igb_get_pauseparam(struct net_device *netdev,
 			       struct ethtool_pauseparam *pause)
 {
@@ -2077,7 +2095,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.get_msglevel           = igb_get_msglevel,
 	.set_msglevel           = igb_set_msglevel,
 	.nway_reset             = igb_nway_reset,
-	.get_link               = ethtool_op_get_link,
+	.get_link               = igb_get_link,
 	.get_eeprom_len         = igb_get_eeprom_len,
 	.get_eeprom             = igb_get_eeprom,
 	.set_eeprom             = igb_set_eeprom,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 677b5f5..e40319e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3020,7 +3020,7 @@ static void igb_update_phy_info(unsigned long data)
  * igb_has_link - check shared code for link and determine up/down
  * @adapter: pointer to driver private info
  **/
-static bool igb_has_link(struct igb_adapter *adapter)
+bool igb_has_link(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	bool link_active = false;

