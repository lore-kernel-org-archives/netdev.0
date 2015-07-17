From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] clarify implementation of ethtool's get_ts_info op
Date: Fri, 17 Jul 2015 07:25:10 -0700
Message-ID: <1437143123-5031-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19520 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757773AbbGQOZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:34 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds some clarification about the intended way to implement
both SIOCSHWTSTAMP and ethtool's get_ts_info. The HWTSTAMP API has
several Rx filters which are very specific, as well as more general
filters. The specific filters really only exist to support some broken
hardware which can't fully implement the generic filters. This patch
adds clarification that it is okay to support the specific filters in
SIOCSHWTSTAMP by upscaling them to the generic filters. In addition,
update the header for ethtool_ts_info to specify that drivers ought to
only report the filters they support without upscaling in this manner.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Reviewed-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/timestamping.txt | 7 +++++++
 include/uapi/linux/ethtool.h              | 5 +++++
 2 files changed, 12 insertions(+)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 5f09226..a977339 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -359,6 +359,13 @@ the requested fine-grained filtering for incoming packets is not
 supported, the driver may time stamp more than just the requested types
 of packets.
 
+Drivers are free to use a more permissive configuration than the requested
+configuration. It is expected that drivers should only implement directly the
+most generic mode that can be supported. For example if the hardware can
+support HWTSTAMP_FILTER_V2_EVENT, then it should generally always upscale
+HWTSTAMP_FILTER_V2_L2_SYNC_MESSAGE, and so forth, as HWTSTAMP_FILTER_V2_EVENT
+is more generic (and more useful to applications).
+
 A driver which supports hardware time stamping shall update the struct
 with the actual, possibly more permissive configuration. If the
 requested packets cannot be time stamped, then nothing should be
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cd67aec..cd16291 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1093,6 +1093,11 @@ struct ethtool_sfeatures {
  * the 'hwtstamp_tx_types' and 'hwtstamp_rx_filters' enumeration values,
  * respectively.  For example, if the device supports HWTSTAMP_TX_ON,
  * then (1 << HWTSTAMP_TX_ON) in 'tx_types' will be set.
+ *
+ * Drivers should only report the filters they actually support without
+ * upscaling in the SIOCSHWTSTAMP ioctl. If the SIOCSHWSTAMP request for
+ * HWTSTAMP_FILTER_V1_SYNC is supported by HWTSTAMP_FILTER_V1_EVENT, then the
+ * driver should only report HWTSTAMP_FILTER_V1_EVENT in this op.
  */
 struct ethtool_ts_info {
 	__u32	cmd;
-- 
2.4.3
