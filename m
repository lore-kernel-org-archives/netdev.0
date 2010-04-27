From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] ixgbe: fix bug when EITR=0 causing no
	writebacks
Date: Tue, 27 Apr 2010 04:37:41 -0700
Message-ID: <20100427113739.24431.46358.stgit@localhost.localdomain>
References: <20100427113651.24431.9221.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:35177
	"EHLO qmta07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754997Ab0D0Lh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 07:37:59 -0400
In-Reply-To: <20100427113651.24431.9221.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

writebacks can be held indefinitely by hardware if EITR=0, when
combined with TXDCTL.WTHRESH=8.  When EITR=0, WTHRESH should be
set back to zero.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   31 +++++++++++++++++++------------
 drivers/net/ixgbe/ixgbe_main.c    |    9 +++++++--
 2 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index b72a997..dfbfe35 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2083,7 +2083,7 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
  * this function must be called before setting the new value of
  * rx_itr_setting
  */
-static void ixgbe_reenable_rsc(struct ixgbe_adapter *adapter,
+static bool ixgbe_reenable_rsc(struct ixgbe_adapter *adapter,
                                struct ethtool_coalesce *ec)
 {
 	/* check the old value and enable RSC if necessary */
@@ -2093,11 +2093,9 @@ static void ixgbe_reenable_rsc(struct ixgbe_adapter *adapter,
 		adapter->netdev->features |= NETIF_F_LRO;
 		DPRINTK(PROBE, INFO, "rx-usecs set to %d, re-enabling RSC\n",
 		        ec->rx_coalesce_usecs);
-		if (netif_running(adapter->netdev))
-			ixgbe_reinit_locked(adapter);
-		else
-			ixgbe_reset(adapter);
+		return true;
 	}
+	return false;
 }
 
 static int ixgbe_set_coalesce(struct net_device *netdev,
@@ -2106,6 +2104,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_q_vector *q_vector;
 	int i;
+	bool need_reset = false;
 
 	/* don't accept tx specific changes if we've got mixed RxTx vectors */
 	if (adapter->q_vector[0]->txr_count && adapter->q_vector[0]->rxr_count
@@ -2128,7 +2127,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 			return -EINVAL;
 
 		/* check the old value and enable RSC if necessary */
-		ixgbe_reenable_rsc(adapter, ec);
+		need_reset = ixgbe_reenable_rsc(adapter, ec);
 
 		/* store the value in ints/second */
 		adapter->rx_eitr_param = 1000000/ec->rx_coalesce_usecs;
@@ -2139,7 +2138,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		adapter->rx_itr_setting &= ~1;
 	} else if (ec->rx_coalesce_usecs == 1) {
 		/* check the old value and enable RSC if necessary */
-		ixgbe_reenable_rsc(adapter, ec);
+		need_reset = ixgbe_reenable_rsc(adapter, ec);
 
 		/* 1 means dynamic mode */
 		adapter->rx_eitr_param = 20000;
@@ -2164,11 +2163,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 			DPRINTK(PROBE, INFO,
 			        "rx-usecs set to 0, disabling RSC\n");
 
-			if (netif_running(netdev))
-				ixgbe_reinit_locked(adapter);
-			else
-				ixgbe_reset(adapter);
-			return 0;
+			need_reset = true;
 		}
 	}
 
@@ -2220,6 +2215,18 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		ixgbe_write_eitr(q_vector);
 	}
 
+	/*
+	 * do reset here at the end to make sure EITR==0 case is handled
+	 * correctly w.r.t stopping tx, and changing TXDCTL.WTHRESH settings
+	 * also locks in RSC enable/disable which requires reset
+	 */
+	if (need_reset) {
+		if (netif_running(netdev))
+			ixgbe_reinit_locked(adapter);
+		else
+			ixgbe_reset(adapter);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0c4ca68..fe7e260 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2945,8 +2945,13 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
-		/* enable WTHRESH=8 descriptors, to encourage burst writeback */
-		txdctl |= (8 << 16);
+		if (adapter->rx_itr_setting == 0) {
+			/* cannot set wthresh when itr==0 */
+			txdctl &= ~0x007F0000;
+		} else {
+			/* enable WTHRESH=8 descriptors, to encourage burst writeback */
+			txdctl |= (8 << 16);
+		}
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 	}
 

