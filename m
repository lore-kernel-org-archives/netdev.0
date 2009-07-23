From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: Don't priority tag control frames in DCB
	mode
Date: Wed, 22 Jul 2009 17:07:33 -0700
Message-ID: <20090723000733.27299.56014.stgit@localhost.localdomain>
References: <20090723000705.27299.19299.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Lucy Liu <lucy.liu@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:60896
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750909AbZGWAHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 20:07:54 -0400
In-Reply-To: <20090723000705.27299.19299.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucy Liu <lucy.liu@intel.com>

Certain types of control packets (LLDP, LACP, etc.) are not supposed to have a
priority tag or vlan tag inserted.  Ixgbe driver is currently priority
tagging everything (if packet is not on a VLAN interface).

This patch modifies DCB mode, so that packets marked with skb priority
TC_PRIO_CONTROL are not priority tagged.  It also transmits these packets on
the highest priority traffic class.
Programs (like dcbd) can set the skb priority using a socket option.  Or, a tc
filter can be configured to set the priority value. Using the value
TC_PRIO_CONTROL (7) has the benefit that it is already defined in the kernel,
and the bonding LACP code already sets the skb->priority field to this value.

Signed-off-by: Lucy Liu <lucy.liu@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a2119d7..47a3c6d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
+#include <linux/pkt_sched.h>
 #include <linux/ipv6.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
@@ -5126,9 +5127,6 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	int count = 0;
 	unsigned int f;
 
-	r_idx = skb->queue_mapping;
-	tx_ring = &adapter->tx_ring[r_idx];
-
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb);
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
@@ -5138,11 +5136,19 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		tx_flags |= (skb->queue_mapping << 13);
-		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
-		tx_flags |= IXGBE_TX_FLAGS_VLAN;
+		if (skb->priority != TC_PRIO_CONTROL) {
+			tx_flags |= (skb->queue_mapping << 13);
+			tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
+			tx_flags |= IXGBE_TX_FLAGS_VLAN;
+		} else {
+			skb->queue_mapping =
+				adapter->ring_feature[RING_F_DCB].indices-1;
+		}
 	}
 
+	r_idx = skb->queue_mapping;
+	tx_ring = &adapter->tx_ring[r_idx];
+
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
 	    (skb->protocol == htons(ETH_P_FCOE)))
 		tx_flags |= IXGBE_TX_FLAGS_FCOE;

