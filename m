From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 04/12] net: axienet: Handle jumbo frames for lesser frame sizes
Date: Tue,  5 May 2015 11:25:57 +0200
Message-ID: <4d41c4f2f9e8829a5e5aff1281de527e1dcf72e3.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
 linux-kernel@vger.kernel.org, monstr@monstr.eu,
 linux-arm-kernel@lists.infradead.org, Anirudha Sarangi <anirudh@xilinx.com>,
 John Linn <John.Linn@xilinx.com>,
 =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

In the current implementation, jumbo frames are supported only
for the frame sizes > 16K. This patch corrects this logic to
handle jumbo frames for lesser frame sizes (< 16K) ensuring jumbo frame
MTU is within the limit of max frame size configured in the h/w
design.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet.h      |  9 ++---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 46 +++++++++++------------
 2 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
index 4c9b4fa1d3c1..4e309440964a 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -11,16 +11,16 @@
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
+#include <linux/if_vlan.h>
 
 /* Packet size info */
 #define XAE_HDR_SIZE			14 /* Size of Ethernet header */
-#define XAE_HDR_VLAN_SIZE		18 /* Size of an Ethernet hdr + VLAN */
 #define XAE_TRL_SIZE			 4 /* Size of Ethernet trailer (FCS) */
 #define XAE_MTU			      1500 /* Max MTU of an Ethernet frame */
 #define XAE_JUMBO_MTU		      9000 /* Max MTU of a jumbo Eth. frame */
 
 #define XAE_MAX_FRAME_SIZE	 (XAE_MTU + XAE_HDR_SIZE + XAE_TRL_SIZE)
-#define XAE_MAX_VLAN_FRAME_SIZE  (XAE_MTU + XAE_HDR_VLAN_SIZE + XAE_TRL_SIZE)
+#define XAE_MAX_VLAN_FRAME_SIZE  (XAE_MTU + VLAN_ETH_HLEN + XAE_TRL_SIZE)
 #define XAE_MAX_JUMBO_FRAME_SIZE (XAE_JUMBO_MTU + XAE_HDR_SIZE + XAE_TRL_SIZE)
 
 /* Configuration options */
@@ -407,8 +407,7 @@ struct axidma_bd {
  *		  Txed/Rxed in the existing hardware. If jumbo option is
  *		  supported, the maximum frame size would be 9k. Else it is
  *		  1522 bytes (assuming support for basic VLAN)
- * @jumbo_support: Stores hardware configuration for jumbo support. If hardware
- *		   can handle jumbo packets, this entry will be 1, else 0.
+ * @rxmem:	Stores rx memory size for jumbo frame handling.
  */
 struct axienet_local {
 	struct net_device *ndev;
@@ -446,7 +445,7 @@ struct axienet_local {
 	u32 rx_bd_ci;
 
 	u32 max_frm_size;
-	u32 jumbo_support;
+	u32 rxmem;
 
 	int csum_offload_on_tx_path;
 	int csum_offload_on_rx_path;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index b83425393a24..b1081e1893b0 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -471,14 +471,16 @@ static void axienet_device_reset(struct net_device *ndev)
 	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_RX_CR_OFFSET);
 
 	lp->max_frm_size = XAE_MAX_VLAN_FRAME_SIZE;
+	lp->options |= XAE_OPTION_VLAN;
 	lp->options &= (~XAE_OPTION_JUMBO);
 
 	if ((ndev->mtu > XAE_MTU) &&
-	    (ndev->mtu <= XAE_JUMBO_MTU) &&
-	    (lp->jumbo_support)) {
-		lp->max_frm_size = ndev->mtu + XAE_HDR_VLAN_SIZE +
-				   XAE_TRL_SIZE;
-		lp->options |= XAE_OPTION_JUMBO;
+		(ndev->mtu <= XAE_JUMBO_MTU)) {
+		lp->max_frm_size = ndev->mtu + VLAN_ETH_HLEN +
+					XAE_TRL_SIZE;
+
+		if (lp->max_frm_size <= lp->rxmem)
+			lp->options |= XAE_OPTION_JUMBO;
 	}
 
 	if (axienet_dma_bd_init(ndev)) {
@@ -1027,15 +1029,15 @@ static int axienet_change_mtu(struct net_device *ndev, int new_mtu)
 
 	if (netif_running(ndev))
 		return -EBUSY;
-	if (lp->jumbo_support) {
-		if ((new_mtu > XAE_JUMBO_MTU) || (new_mtu < 64))
-			return -EINVAL;
-		ndev->mtu = new_mtu;
-	} else {
-		if ((new_mtu > XAE_MTU) || (new_mtu < 64))
-			return -EINVAL;
-		ndev->mtu = new_mtu;
-	}
+
+	if ((new_mtu + VLAN_ETH_HLEN +
+		XAE_TRL_SIZE) > lp->rxmem)
+		return -EINVAL;
+
+	if ((new_mtu > XAE_JUMBO_MTU) || (new_mtu < 64))
+		return -EINVAL;
+
+	ndev->mtu = new_mtu;
 
 	return 0;
 }
@@ -1556,16 +1558,14 @@ static int axienet_of_probe(struct platform_device *op)
 		}
 	}
 	/* For supporting jumbo frames, the Axi Ethernet hardware must have
-	 * a larger Rx/Tx Memory. Typically, the size must be more than or
-	 * equal to 16384 bytes, so that we can enable jumbo option and start
-	 * supporting jumbo frames. Here we check for memory allocated for
-	 * Rx/Tx in the hardware from the device-tree and accordingly set
-	 * flags. */
+	 * a larger Rx/Tx Memory. Typically, the size must be large so that
+	 * we can enable jumbo option and start supporting jumbo frames.
+	 * Here we check for memory allocated for Rx/Tx in the hardware from
+	 * the device-tree and accordingly set flags.
+	 */
 	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,rxmem", NULL);
-	if (p) {
-		if ((be32_to_cpup(p)) >= 0x4000)
-			lp->jumbo_support = 1;
-	}
+	if (p)
+		lp->rxmem = be32_to_cpup(p);
 	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,phy-type", NULL);
 	if (p)
 		lp->phy_type = be32_to_cpup(p);
-- 
2.3.5
