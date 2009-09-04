From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: Distribute transmission of FCoE traffic
	in 82599
Date: Thu, 03 Sep 2009 17:56:10 -0700
Message-ID: <20090904005609.14869.89202.stgit@localhost.localdomain>
References: <20090904005549.14869.66878.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:58718
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754700AbZIDA41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 20:56:27 -0400
In-Reply-To: <20090904005549.14869.66878.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds a simple selection of a FCoE tx queue based on the current cpu id to
distribute transmission of FCoE traffic evenly among multiple FCoE transmit
queues.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 724754a..45bf8b9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5168,9 +5168,15 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	tx_ring = &adapter->tx_ring[r_idx];
 
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
-	    (skb->protocol == htons(ETH_P_FCOE)))
+	    (skb->protocol == htons(ETH_P_FCOE))) {
 		tx_flags |= IXGBE_TX_FLAGS_FCOE;
-
+#ifdef IXGBE_FCOE
+		r_idx = smp_processor_id();
+		r_idx &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
+		r_idx += adapter->ring_feature[RING_F_FCOE].mask;
+		tx_ring = &adapter->tx_ring[r_idx];
+#endif
+	}
 	/* four things can cause us to need a context descriptor */
 	if (skb_is_gso(skb) ||
 	    (skb->ip_summed == CHECKSUM_PARTIAL) ||

