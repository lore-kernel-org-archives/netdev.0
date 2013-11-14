From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/6] e1000e: Validate hwtstamp_config completely before
 applying it
Date: Thu, 14 Nov 2013 00:41:38 +0000
Message-ID: <1384389698.29151.8.camel@bwh-desktop.uk.level5networks.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53485 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab3KNAlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 19:41:42 -0500
In-Reply-To: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000e_hwtstamp_ioctl() should validate all fields of hwtstamp_config
before making any changes.  Currently it copies the configuration to
the e1000_adapter structure before validating it at all.

Change e1000e_config_hwtstamp() to take a pointer to the
hwstamp_config and to copy the config after validating it.

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4ef786775acb..f02816575369 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3482,10 +3482,10 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca)
  * specified. Matching the kind of event packet is not supported, with the
  * exception of "all V2 events regardless of level 2 or 4".
  **/
-static int e1000e_config_hwtstamp(struct e1000_adapter *adapter)
+static int e1000e_config_hwtstamp(struct e1000_adapter *adapter,
+				  struct hwtstamp_config *config)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct hwtstamp_config *config = &adapter->hwtstamp_config;
 	u32 tsync_tx_ctl = E1000_TSYNCTXCTL_ENABLED;
 	u32 tsync_rx_ctl = E1000_TSYNCRXCTL_ENABLED;
 	u32 rxmtrl = 0;
@@ -3586,6 +3586,8 @@ static int e1000e_config_hwtstamp(struct e1000_adapter *adapter)
 		return -ERANGE;
 	}
 
+	adapter->hwtstamp_config = *config;
+
 	/* enable/disable Tx h/w time stamping */
 	regval = er32(TSYNCTXCTL);
 	regval &= ~E1000_TSYNCTXCTL_ENABLED;
@@ -3874,7 +3876,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	e1000e_reset_adaptive(hw);
 
 	/* initialize systim and reset the ns time counter */
-	e1000e_config_hwtstamp(adapter);
+	e1000e_config_hwtstamp(adapter, &adapter->hwtstamp_config);
 
 	/* Set EEE advertisement as appropriate */
 	if (adapter->flags2 & FLAG2_HAS_EEE) {
@@ -5797,14 +5799,10 @@ static int e1000e_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
 	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
 		return -EFAULT;
 
-	adapter->hwtstamp_config = config;
-
-	ret_val = e1000e_config_hwtstamp(adapter);
+	ret_val = e1000e_config_hwtstamp(adapter, &config);
 	if (ret_val)
 		return ret_val;
 
-	config = adapter->hwtstamp_config;
-
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
