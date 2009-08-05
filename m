From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: allow vlan egress priority mapping in DCB mode
Date: Tue, 04 Aug 2009 18:27:28 -0700
Message-ID: <20090805012726.24350.63928.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Lucy Liu <lucy.liu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:49821
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932863AbZHEB1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 21:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucy Liu <lucy.liu@intel.com>

The skb priority to vlan-qos egress mapping that can be configured using
set_egress_map with vconfig is overriden by the DCB code in the driver.

This patch allows this existing mechanism to work and will increase the
configuration flexibility of DCB mode on Linux.

A hierarchy of configuration is:

1. Modifies the ixgbe_select_queue() routine for DCB mode to return the
priority value from the VLAN tag. It will normally be zero, unless the egress
priority map has modified it. This will get packets into the correct queue and
result in the queue_mapping field being set correctly.

2. Any tc filter which modifies queue_mapping will be honored, as the filters
are handled after the vlan egress map is handled.

Signed-off-by: Lucy Liu <lucy.liu@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 110c65a..0586774 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5124,7 +5124,7 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 		return smp_processor_id();
 
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-		return 0;  /* All traffic should default to class 0 */
+		return (skb->vlan_tci & IXGBE_TX_FLAGS_VLAN_PRIO_MASK) >> 13;
 
 	return skb_tx_hash(dev, skb);
 }

