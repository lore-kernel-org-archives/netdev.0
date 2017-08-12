From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e/i40evf: adjust packet size to account for double VLANs
Date: Sat, 12 Aug 2017 04:08:34 -0700
Message-ID: <20170812110848.18264-3-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54045 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750862AbdHLLIx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:53 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Now that the kernel supports double VLAN tags, we should at least play
nice. Adjust the max packet size to account for two VLAN tags, not just
one.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h     | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a7e5a76703e7..0cb571e337f6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9770,8 +9770,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 
 	/* MTU range: 68 - 9706 */
 	netdev->min_mtu = ETH_MIN_MTU;
-	netdev->max_mtu = I40E_MAX_RXBUFFER -
-			  (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
+	netdev->max_mtu = I40E_MAX_RXBUFFER - I40E_PACKET_HDR_PAD;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index b288d58313a6..a39892d2453d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -130,6 +130,7 @@ enum i40e_dyn_idx_t {
  * i.e. RXBUFFER_512 --> 1216 byte skb (size-2048 slab)
  */
 #define I40E_RX_HDR_SIZE I40E_RXBUFFER_256
+#define I40E_PACKET_HDR_PAD (ETH_HLEN + ETH_FCS_LEN + (VLAN_HLEN * 2))
 #define i40e_rx_desc i40e_32byte_rx_desc
 
 #define I40E_RX_DMA_ATTR \
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 901282c87cf6..472f606629d4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -117,6 +117,7 @@ enum i40e_dyn_idx_t {
  * i.e. RXBUFFER_512 --> 1216 byte skb (size-2048 slab)
  */
 #define I40E_RX_HDR_SIZE I40E_RXBUFFER_256
+#define I40E_PACKET_HDR_PAD (ETH_HLEN + ETH_FCS_LEN + (VLAN_HLEN * 2))
 #define i40e_rx_desc i40e_32byte_rx_desc
 
 #define I40E_RX_DMA_ATTR \
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 93536b9fc629..22919b444ddf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2625,7 +2625,7 @@ static void i40evf_init_task(struct work_struct *work)
 
 	/* MTU range: 68 - 9710 */
 	netdev->min_mtu = ETH_MIN_MTU;
-	netdev->max_mtu = I40E_MAX_RXBUFFER - (ETH_HLEN + ETH_FCS_LEN);
+	netdev->max_mtu = I40E_MAX_RXBUFFER - I40E_PACKET_HDR_PAD;
 
 	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
 		dev_info(&pdev->dev, "Invalid MAC address %pM, using random\n",
-- 
2.14.0
