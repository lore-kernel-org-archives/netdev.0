From: greearb@candelatech.com
Subject: [PATCH 1/2] net:  Support getting/setting RX-FCS in drivers.
Date: Fri, 17 Jun 2011 12:40:14 -0700
Message-ID: <1308339615-5866-2-git-send-email-greearb@candelatech.com>
References: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53823 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083Ab1FQTk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:40:27 -0400
In-Reply-To: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This will allow us to enable/disable having the Ethernet
frame checksum appended to the skb.  Enabling this is
useful when sniffing packets.

In particular, this can be used to test logic that allows
a NIC to receive all frames, even ones with bad checksums.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 439b173... 675ddc0... M	include/linux/ethtool.h
:100644 100644 fd14116... 0e01860... M	net/core/ethtool.c
 include/linux/ethtool.h |    8 ++++++++
 net/core/ethtool.c      |    8 ++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 439b173..675ddc0 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -877,6 +877,9 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  * 		   and flag of the device.
  * @get_dump_data: Get dump data.
  * @set_dump: Set dump specific flags to the device.
+ * @set_save_rxfcs:  Set flag to save (1), or discard (0), the Ethernet
+ *	Frame Checksum for received packets.
+ * @get_save_rxfcs:  Get current value for Save RX-FCS flag.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -955,6 +958,8 @@ struct ethtool_ops {
 	int	(*get_dump_data)(struct net_device *,
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
+	int	(*set_save_rxfcs)(struct net_device *, u32);
+	u32	(*get_save_rxfcs)(struct net_device *);
 
 };
 #endif /* __KERNEL__ */
@@ -1029,6 +1034,9 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_SAVE_RXFCS	0x00000041 /* Get RX Save Frame Checksum */
+#define ETHTOOL_SET_SAVE_RXFCS	0x00000042 /* Set RX Save Frame Checksum */
+
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fd14116..0e01860 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2152,6 +2152,14 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_DUMP_DATA:
 		rc = ethtool_get_dump_data(dev, useraddr);
 		break;
+	case ETHTOOL_SET_SAVE_RXFCS:
+		rc = ethtool_set_value(dev, useraddr,
+				       dev->ethtool_ops->set_save_rxfcs);
+		break;
+	case ETHTOOL_GET_SAVE_RXFCS:
+		rc =  ethtool_get_value(dev, useraddr, ethcmd,
+					dev->ethtool_ops->get_save_rxfcs);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.3.4

