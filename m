From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] ixgbe: add the external ixgbe fiber transceiver status
Date: Wed,  8 Feb 2017 22:03:27 -0500
Message-ID: <1486609408-6770-1-git-send-email-yanjun.zhu@oracle.com>
To: jeffrey.t.kirsher@intel.com, broonie@kernel.org,
        davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:27993 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdBIFMm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 00:12:42 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v19345iv029880
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 9 Feb 2017 03:04:05 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the ixgbe fiber transceiver is external, it is necessary to get
the present/absent status of this external ixgbe fiber transceiver.

The steps to get the present/absent status:
The enp1s0f0 is an external ixgbe fiber NIC.

ethtool enp1s0f0

...
        Port: FIBRE
        PHYAD: 0
        Transceiver: external(present) <---The transceiver is present.
        Auto-negotiation: on
        Supports Wake-on: d
...

Or
...
        Port: FIBRE
        PHYAD: 0
        Transceiver: external(absent) <---The transceiver is absent
        Auto-negotiation: on
        Supports Wake-on: d
...

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 15 +++++++++++++++
 include/uapi/linux/ethtool.h                     |  4 ++++
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index fd192bf..b3f86f4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -313,6 +313,21 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		break;
 	}
 
+	/* When the tranceiver is external, the following is meaningful.
+	 * ecmd->reserved[0] has 3 values:
+	 * 0x0: tranceiver absent
+	 * 0x4: tranceiver present
+	 * others: not support
+	 */
+	if (ecmd->port == PORT_FIBRE) {
+		u32 status = IXGBE_READ_REG(hw, IXGBE_ESDP) & IXGBE_ESDP_SDP2;
+
+		if (status == 0x4)
+			ecmd->transceiver = XCVR_EXTERNAL_PRESENT;
+		if (status == 0x0)
+			ecmd->transceiver = XCVR_EXTERNAL_ABSENT;
+	}
+
 	/* Indicate pause support */
 	ecmd->supported |= SUPPORTED_Pause;
 
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 3dc91a4..8e8225a 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1541,6 +1541,10 @@ static inline int ethtool_validate_duplex(__u8 duplex)
 #define XCVR_DUMMY2		0x03
 #define XCVR_DUMMY3		0x04
 
+/* The fiber transceiver status */
+#define XCVR_EXTERNAL_ABSENT	0x05
+#define XCVR_EXTERNAL_PRESENT	0x06
+
 /* Enable or disable autonegotiation. */
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
-- 
2.7.4
