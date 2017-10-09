From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e/i40evf: fix incorrect default ITR values on driver load
Date: Mon,  9 Oct 2017 15:38:31 -0700
Message-ID: <20171009223841.2557-5-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36096 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755258AbdJIWjG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:06 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The ITR register expects to be programmed in units of 2 microseconds.
Because of this, all of the drivers I40E_ITR_* constants are in terms of
this 2 microsecond register.

Unfortunately, the rx_itr_default value is expected to be programmed in
microseconds.

Effectively the driver defaults to an ITR value of half the expected
value (in terms of minimum microseconds between interrupts).

Fix this by changing the default values to be calculated using
ITR_REG_TO_USEC macro which indicates that we're converting from the
register units into microseconds.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h     | 6 ++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   | 6 ++++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 60b11fdeca2d..d4b0cc36afb1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8983,8 +8983,8 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    I40E_FLAG_MSIX_ENABLED;
 
 	/* Set default ITR */
-	pf->rx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_RX_DEF;
-	pf->tx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_TX_DEF;
+	pf->rx_itr_default = I40E_ITR_RX_DEF;
+	pf->tx_itr_default = I40E_ITR_TX_DEF;
 
 	/* Depending on PF configurations, it is possible that the RSS
 	 * maximum might end up larger than the available queues
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index a4e3e665a1a1..c3156aa3f709 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -38,8 +38,10 @@
 #define I40E_ITR_8K                0x003E
 #define I40E_ITR_4K                0x007A
 #define I40E_MAX_INTRL             0x3B    /* reg uses 4 usec resolution */
-#define I40E_ITR_RX_DEF            I40E_ITR_20K
-#define I40E_ITR_TX_DEF            I40E_ITR_20K
+#define I40E_ITR_RX_DEF            (ITR_REG_TO_USEC(I40E_ITR_20K) | \
+				    I40E_ITR_DYNAMIC)
+#define I40E_ITR_TX_DEF            (ITR_REG_TO_USEC(I40E_ITR_20K) | \
+				    I40E_ITR_DYNAMIC)
 #define I40E_ITR_DYNAMIC           0x8000  /* use top bit as a flag */
 #define I40E_MIN_INT_RATE          250     /* ~= 1000000 / (I40E_MAX_ITR * 2) */
 #define I40E_MAX_INT_RATE          500000  /* == 1000000 / (I40E_MIN_ITR * 2) */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index d8ca802a71a9..8f9830d7649a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -38,8 +38,10 @@
 #define I40E_ITR_8K                0x003E
 #define I40E_ITR_4K                0x007A
 #define I40E_MAX_INTRL             0x3B    /* reg uses 4 usec resolution */
-#define I40E_ITR_RX_DEF            I40E_ITR_20K
-#define I40E_ITR_TX_DEF            I40E_ITR_20K
+#define I40E_ITR_RX_DEF            (ITR_REG_TO_USEC(I40E_ITR_20K) | \
+				    I40E_ITR_DYNAMIC)
+#define I40E_ITR_TX_DEF            (ITR_REG_TO_USEC(I40E_ITR_20K) | \
+				    I40E_ITR_DYNAMIC)
 #define I40E_ITR_DYNAMIC           0x8000  /* use top bit as a flag */
 #define I40E_MIN_INT_RATE          250     /* ~= 1000000 / (I40E_MAX_ITR * 2) */
 #define I40E_MAX_INT_RATE          500000  /* == 1000000 / (I40E_MIN_ITR * 2) */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f62d9565c7b5..5bcbd46e2f6c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1223,7 +1223,7 @@ static int i40evf_alloc_queues(struct i40evf_adapter *adapter)
 		tx_ring->netdev = adapter->netdev;
 		tx_ring->dev = &adapter->pdev->dev;
 		tx_ring->count = adapter->tx_desc_count;
-		tx_ring->tx_itr_setting = (I40E_ITR_DYNAMIC | I40E_ITR_TX_DEF);
+		tx_ring->tx_itr_setting = I40E_ITR_TX_DEF;
 		if (adapter->flags & I40EVF_FLAG_WB_ON_ITR_CAPABLE)
 			tx_ring->flags |= I40E_TXR_FLAGS_WB_ON_ITR;
 
@@ -1232,7 +1232,7 @@ static int i40evf_alloc_queues(struct i40evf_adapter *adapter)
 		rx_ring->netdev = adapter->netdev;
 		rx_ring->dev = &adapter->pdev->dev;
 		rx_ring->count = adapter->rx_desc_count;
-		rx_ring->rx_itr_setting = (I40E_ITR_DYNAMIC | I40E_ITR_RX_DEF);
+		rx_ring->rx_itr_setting = I40E_ITR_RX_DEF;
 	}
 
 	adapter->num_active_queues = num_active_queues;
-- 
2.14.2
