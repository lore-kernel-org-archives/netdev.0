From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 8/8] ixgbe: Add support for
	dcbnl_rtnl_ops.setapp/getapp
Date: Mon, 31 Aug 2009 15:34:28 -0700
Message-ID: <20090831223428.30995.63567.stgit@localhost.localdomain>
References: <20090831223110.30995.61162.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:44172
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbZHaWer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:34:47 -0400
In-Reply-To: <20090831223110.30995.61162.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add support for dcbnl_rtnl_ops.setapp/getapp to set or get the current user
priority bitmap for the given application protocol. Currently, 82599 only
supports setapp/getapp for Fiber Channel over Ethernet (FCoE) protocol.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |    4 ++
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   60 ++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_fcoe.c   |   64 ++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_fcoe.h   |    4 ++
 drivers/net/ixgbe/ixgbe_main.c   |    2 +
 5 files changed, 134 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index daed0ac..dd688d4 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -452,6 +452,10 @@ extern int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 extern int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid);
 extern int ixgbe_fcoe_enable(struct net_device *netdev);
 extern int ixgbe_fcoe_disable(struct net_device *netdev);
+#ifdef CONFIG_IXGBE_DCB
+extern u8 ixgbe_fcoe_getapp(struct ixgbe_adapter *adapter);
+extern u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up);
+#endif /* CONFIG_IXGBE_DCB */
 #endif /* IXGBE_FCOE */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index e05c62a..47d9dde 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -480,6 +480,64 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 	return;
 }
 
+/**
+ * ixgbe_dcbnl_getapp - retrieve the DCBX application user priority
+ * @netdev : the corresponding netdev
+ * @idtype : identifies the id as ether type or TCP/UDP port number
+ * @id: id is either ether type or TCP/UDP port number
+ *
+ * Returns : on success, returns a non-zero 802.1p user priority bitmap
+ * otherwise returns 0 as the invalid user priority bitmap to indicate an
+ * error.
+ */
+static u8 ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
+{
+	u8 rval = 0;
+
+	switch (idtype) {
+	case DCB_APP_IDTYPE_ETHTYPE:
+#ifdef IXGBE_FCOE
+		if (id == ETH_P_FCOE)
+			rval = ixgbe_fcoe_getapp(netdev_priv(netdev));
+#endif
+		break;
+	case DCB_APP_IDTYPE_PORTNUM:
+		break;
+	default:
+		break;
+	}
+	return rval;
+}
+
+/**
+ * ixgbe_dcbnl_setapp - set the DCBX application user priority
+ * @netdev : the corresponding netdev
+ * @idtype : identifies the id as ether type or TCP/UDP port number
+ * @id: id is either ether type or TCP/UDP port number
+ * @up: the 802.1p user priority bitmap
+ *
+ * Returns : 0 on success or 1 on error
+ */
+static u8 ixgbe_dcbnl_setapp(struct net_device *netdev,
+                             u8 idtype, u16 id, u8 up)
+{
+	u8 rval = 1;
+
+	switch (idtype) {
+	case DCB_APP_IDTYPE_ETHTYPE:
+#ifdef IXGBE_FCOE
+		if (id == ETH_P_FCOE)
+			rval = ixgbe_fcoe_setapp(netdev_priv(netdev), up);
+#endif
+		break;
+	case DCB_APP_IDTYPE_PORTNUM:
+		break;
+	default:
+		break;
+	}
+	return rval;
+}
+
 struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
@@ -500,5 +558,7 @@ struct dcbnl_rtnl_ops dcbnl_ops = {
 	.setnumtcs	= ixgbe_dcbnl_setnumtcs,
 	.getpfcstate	= ixgbe_dcbnl_getpfcstate,
 	.setpfcstate	= ixgbe_dcbnl_setpfcstate,
+	.getapp		= ixgbe_dcbnl_getapp,
+	.setapp		= ixgbe_dcbnl_setapp,
 };
 
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 26fe46f..0607cff 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -27,6 +27,9 @@
 
 
 #include "ixgbe.h"
+#ifdef CONFIG_IXGBE_DCB
+#include "ixgbe_dcb_82599.h"
+#endif /* CONFIG_IXGBE_DCB */
 #include <linux/if_ether.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_device.h>
@@ -648,3 +651,64 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 out_disable:
 	return rc;
 }
+
+#ifdef CONFIG_IXGBE_DCB
+/**
+ * ixgbe_fcoe_getapp - retrieves current user priority bitmap for FCoE
+ * @adapter : ixgbe adapter
+ *
+ * Finds out the corresponding user priority bitmap from the current
+ * traffic class that FCoE belongs to. Returns 0 as the invalid user
+ * priority bitmap to indicate an error.
+ *
+ * Returns : 802.1p user priority bitmap for FCoE
+ */
+u8 ixgbe_fcoe_getapp(struct ixgbe_adapter *adapter)
+{
+	int i;
+	u8 tc;
+	u32 up2tc;
+
+	up2tc = IXGBE_READ_REG(&adapter->hw, IXGBE_RTTUP2TC);
+	for (i = 0; i < MAX_USER_PRIORITY; i++) {
+		tc = (u8)(up2tc >> (i * IXGBE_RTTUP2TC_UP_SHIFT));
+		tc &= (MAX_TRAFFIC_CLASS - 1);
+		if (adapter->fcoe.tc == tc)
+			return 1 << i;
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_fcoe_setapp - sets the user priority bitmap for FCoE
+ * @adapter : ixgbe adapter
+ * @up : 802.1p user priority bitmap
+ *
+ * Finds out the traffic class from the input user priority
+ * bitmap for FCoE.
+ *
+ * Returns : 0 on success otherwise returns 1 on error
+ */
+u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up)
+{
+	int i;
+	u32 up2tc;
+
+	/* valid user priority bitmap must not be 0 */
+	if (up) {
+		/* from user priority to the corresponding traffic class */
+		up2tc = IXGBE_READ_REG(&adapter->hw, IXGBE_RTTUP2TC);
+		for (i = 0; i < MAX_USER_PRIORITY; i++) {
+			if (up & (1 << i)) {
+				up2tc >>= (i * IXGBE_RTTUP2TC_UP_SHIFT);
+				up2tc &= (MAX_TRAFFIC_CLASS - 1);
+				adapter->fcoe.tc = (u8)up2tc;
+				return 0;
+			}
+		}
+	}
+
+	return 1;
+}
+#endif /* CONFIG_IXGBE_DCB */
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index c5b5002..b5dee7b 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -46,6 +46,9 @@
 #define IXGBE_FCBUFF_MIN	4096	/* 4KB min */
 #define IXGBE_FCOE_DDP_MAX	512	/* 9 bits xid */
 
+/* Default traffic class to use for FCoE */
+#define IXGBE_FCOE_DEFTC	3
+
 /* fcerr */
 #define IXGBE_FCERR_BADCRC       0x00100000
 
@@ -59,6 +62,7 @@ struct ixgbe_fcoe_ddp {
 };
 
 struct ixgbe_fcoe {
+	u8 tc;
 	spinlock_t lock;
 	struct pci_pool *pool;
 	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f46618d..7eb60f6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3801,6 +3801,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
 		adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
 		adapter->ring_feature[RING_F_FCOE].indices = 0;
+		/* Default traffic class to use for FCoE */
+		adapter->fcoe.tc = IXGBE_FCOE_DEFTC;
 #endif /* IXGBE_FCOE */
 	}
 

