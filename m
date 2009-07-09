From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Fix coexistence of FCoE and Flow Director in
	82599
Date: Thu, 09 Jul 2009 05:29:50 -0700
Message-ID: <20090709122944.962.54056.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:57370
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757947AbZGIMaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 08:30:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Fix coexistence of Fiber Channel over Ethernet (FCoE) and Flow Director (FDIR)
in 82599 and remove the disabling of FDIR when FCoE is enabled.

Currently, FDIR is turned off when FCoE is enabled under the assumption that
FCoE is always enabled with DCB being turned on. However, FDIR does not have
to be turned off all the time when FCoE is enabled since FCoE can be enabled
without DCB being turned on, e.g., use link pause only. This patch makes sure
that when DCB is turned on or off, FDIR is turned on or off correspondingly;
and when FCoE is enabled, it does not disable FDIR, rather, it will have FDIR
set up properly so FCoE and FDIR can coexist regardless of DCB being on or off.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    6 ++++++
 drivers/net/ixgbe/ixgbe_main.c   |   19 +++++++++++--------
 2 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index d56890f..7c5978a 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -138,6 +138,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->hw.fc.requested_mode = ixgbe_fc_none;
 		}
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+		}
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		ixgbe_init_interrupt_scheme(adapter);
 		if (netif_running(netdev))
@@ -154,6 +158,8 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->dcb_cfg.pfc_mode_enable = false;
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
+			if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 			ixgbe_init_interrupt_scheme(adapter);
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_open(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a3061aa..e3442f4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3130,7 +3130,11 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 #endif
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 			DPRINTK(PROBE, INFO, "FCOE enabled with RSS \n");
-			ixgbe_set_rss_queues(adapter);
+			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
+			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+				ixgbe_set_fdir_queues(adapter);
+			else
+				ixgbe_set_rss_queues(adapter);
 		}
 		/* adding FCoE rx rings to the end */
 		f->mask = adapter->num_rx_queues;
@@ -3388,7 +3392,12 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 		}
 #endif /* CONFIG_IXGBE_DCB */
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-			ixgbe_cache_ring_rss(adapter);
+			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
+			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+				ixgbe_cache_ring_fdir(adapter);
+			else
+				ixgbe_cache_ring_rss(adapter);
+
 			fcoe_i = f->mask;
 		}
 		for (i = 0; i < f->indices; i++, fcoe_i++)
@@ -5578,12 +5587,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 				netdev->features |= NETIF_F_FCOE_CRC;
 				netdev->features |= NETIF_F_FSO;
 				netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
-				DPRINTK(DRV, INFO, "FCoE enabled, "
-					"disabling Flow Director\n");
-				adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-				adapter->flags &=
-				        ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-				adapter->atr_sample_rate = 0;
 			} else {
 				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
 			}

