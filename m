From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 2/4] ethtool: ensure channel counts are within bounds during SCHANNELS
Date: Mon,  8 Feb 2016 16:05:04 -0800
Message-ID: <1454976306-23523-3-git-send-email-jacob.e.keller@intel.com>
References: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jakub Kicinski <moorray3@wp.pl>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21883 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932818AbcBIAFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 19:05:13 -0500
In-Reply-To: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sanity check to ensure that all requested channel sizes are within
bounds, which should reduce errors in driver implementation.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 net/core/ethtool.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 59aebaf9ed54..dc4f6632f33b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1274,15 +1274,24 @@ static noinline_for_stack int ethtool_get_channels(struct net_device *dev,
 static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 						   void __user *useraddr)
 {
-	struct ethtool_channels channels;
+	struct ethtool_channels channels, max;
 	u32 max_rx_in_use = 0;
 
-	if (!dev->ethtool_ops->set_channels)
+	if (!dev->ethtool_ops->set_channels || !dev->ethtool_ops->get_channels)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&channels, useraddr, sizeof(channels)))
 		return -EFAULT;
 
+	dev->ethtool_ops->get_channels(dev, &max);
+
+	/* ensure new counts are within the maximums */
+	if ((channels.rx_count > max.max_rx) ||
+	    (channels.tx_count > max.max_tx) ||
+	    (channels.combined_count > max.max_combined) ||
+	    (channels.other_count > max.max_other))
+		return -EINVAL;
+
 	/* ensure the new Rx count fits within the configured Rx flow
 	 * indirection table settings */
 	if (netif_is_rxfh_configured(dev) &&
-- 
2.7.0.236.gda096a0.dirty
