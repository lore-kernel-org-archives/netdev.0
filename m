From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] ethtool: Add helper routines to pass vf to rx_flow_spec
Date: Thu, 28 May 2015 04:25:26 -0700
Message-ID: <1432812339-17129-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Alex Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4939 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753669AbbE1LZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:41 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The ring_cookie is 64 bits wide which is much larger than can be used
for actual queue index values. So provide some helper routines to
pack a VF index into the cookie. This is useful to steer packets to
a VF ring without having to know the queue layout of the device.

CC: Alex Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/uapi/linux/ethtool.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index ae832b4..0594933 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -796,6 +796,31 @@ struct ethtool_rx_flow_spec {
 	__u32		location;
 };
 
+/* How rings are layed out when accessing virtual functions or
+ * offloaded queues is device specific. To allow users to do flow
+ * steering and specify these queues the ring cookie is partitioned
+ * into a 32bit queue index with an 8 bit virtual function id.
+ * This also leaves the 3bytes for further specifiers. It is possible
+ * future devices may support more than 256 virtual functions if
+ * devices start supporting PCIe w/ARI. However at the moment I
+ * do not know of any devices that support this so I do not reserve
+ * space for this at this time. If a future patch consumes the next
+ * byte it should be aware of this possiblity.
+ */
+#define ETHTOOL_RX_FLOW_SPEC_RING	0x00000000FFFFFFFFLL
+#define ETHTOOL_RX_FLOW_SPEC_RING_VF	0x000000FF00000000LL
+#define ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF 32
+static inline __u64 ethtool_get_flow_spec_ring(__u64 ring_cookie)
+{
+	return ETHTOOL_RX_FLOW_SPEC_RING & ring_cookie;
+};
+
+static inline __u64 ethtool_get_flow_spec_ring_vf(__u64 ring_cookie)
+{
+	return (ETHTOOL_RX_FLOW_SPEC_RING_VF & ring_cookie) >>
+				ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF;
+};
+
 /**
  * struct ethtool_rxnfc - command to get or set RX flow classification rules
  * @cmd: Specific command number - %ETHTOOL_GRXFH, %ETHTOOL_SRXFH,
-- 
2.1.0
