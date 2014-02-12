From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 06/14] net: axienet: Handle jumbo frames for lesser frame sizes
Date: Wed, 12 Feb 2014 16:55:40 +0100
Message-ID: <7732b1e09951dca7b6786fa7ba3579c378f4f4c1.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2263-1392220604-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2263-1392220604-0001

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
index 44b8d2b..b3c50bd 100644
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
@@ -408,8 +408,7 @@ struct axidma_bd {
  *		  Txed/Rxed in the existing hardware. If jumbo option is
  *		  supported, the maximum frame size would be 9k. Else it is
  *		  1522 bytes (assuming support for basic VLAN)
- * @jumbo_support: Stores hardware configuration for jumbo support. If hardware
- *		   can handle jumbo packets, this entry will be 1, else 0.
+ * @rxmem:	Stores rx memory size for jumbo frame handling.
  */
 struct axienet_local {
 	struct net_device *ndev;
@@ -448,7 +447,7 @@ struct axienet_local {
 	u32 rx_bd_ci;

 	u32 max_frm_size;
-	u32 jumbo_support;
+	u32 rxmem;

 	int csum_offload_on_tx_path;
 	int csum_offload_on_rx_path;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 3c24f97..9595403 100644
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
 	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,temac-type",
 				       NULL);
 	if (p)
--
1.8.2.3


--=_mimegpg-monstr-desktop-2263-1392220604-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7mb0ACgkQykllyylKDCEX2ACdFt1HWctY468x9hETmqFz5wd/
4X0AnjXa4XnmiN+Phcds4DCsEerBmXmE
=ey7t
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2263-1392220604-0001--
