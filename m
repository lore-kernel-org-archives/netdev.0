From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix build error with FCOE_CONFIG without
	DCB_CONFIG
Date: Sun, 08 Aug 2010 18:46:15 -0700
Message-ID: <20100809014538.595.63259.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:59193 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755228Ab0HIBqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 21:46:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Building ixgbe without DCB_CONFIG and FCOE_CONFIG will cause
a build error.  This resolves the build error by wrapping
the fcoe.up in CONFIG_IXGBE_DCB ifdefs.

Also frames were being priority VLAN tagged even without DCB
enabled.  This fixes this so that 8021Q priority tags are
only added with DCB actually enabled.

Reported-by: divya <dipraksh@linux.vnet.ibm.com>
Reported-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7d6a415..55394a2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6155,9 +6155,11 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 			txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
 			txq += adapter->ring_feature[RING_F_FCOE].mask;
 			return txq;
+#ifdef CONFIG_IXGBE_DCB
 		} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			txq = adapter->fcoe.up;
 			return txq;
+#endif
 		}
 	}
 #endif
@@ -6216,10 +6218,14 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
 	    (skb->protocol == htons(ETH_P_FCOE) ||
 	     skb->protocol == htons(ETH_P_FIP))) {
-		tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
-			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
-		tx_flags |= ((adapter->fcoe.up << 13)
-			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+#ifdef CONFIG_IXGBE_DCB
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
+				      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+			tx_flags |= ((adapter->fcoe.up << 13)
+				      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+		}
+#endif
 		/* flag for FCoE offloads */
 		if (skb->protocol == htons(ETH_P_FCOE))
 			tx_flags |= IXGBE_TX_FLAGS_FCOE;

