From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] igb: Use only a single Tx queue in SR-IOV
	mode
Date: Thu, 01 Jul 2010 16:38:16 -0700
Message-ID: <20100701233814.16171.78454.stgit@localhost.localdomain>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	stable@kernel.org, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:50817 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753759Ab0GAXih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:38:37 -0400
In-Reply-To: <20100701233733.16171.4629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The 82576 expects the second rx queue in any pool to receive L2 switch
loop back packets sent from the second tx queue in another pool.  The
82576 VF driver does not enable the second rx queue so if the PF driver
sends packets destined to a VF from its second tx queue then the VF
driver will never see them.  In SR-IOV mode limit the number of tx queues
used by the PF driver to one. This patch fixes a bug reported in which
the PF cannot communciate with the VF and should be considered for 2.6.34
stable.

CC: stable@kernel.org
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3881918..e79689e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -630,9 +630,6 @@ static void igb_cache_ring_register(struct igb_adapter *adapter)
 			for (; i < adapter->rss_queues; i++)
 				adapter->rx_ring[i]->reg_idx = rbase_offset +
 				                               Q_IDX_82576(i);
-			for (; j < adapter->rss_queues; j++)
-				adapter->tx_ring[j]->reg_idx = rbase_offset +
-				                               Q_IDX_82576(j);
 		}
 	case e1000_82575:
 	case e1000_82580:
@@ -996,7 +993,10 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 
 	/* Number of supported queues. */
 	adapter->num_rx_queues = adapter->rss_queues;
-	adapter->num_tx_queues = adapter->rss_queues;
+	if (adapter->vfs_allocated_count)
+		adapter->num_tx_queues = 1;
+	else
+		adapter->num_tx_queues = adapter->rss_queues;
 
 	/* start with one vector for every rx queue */
 	numvecs = adapter->num_rx_queues;

