From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH v2 11/12] netdev: octeon_mgmt: Convert to use device tree.
Date: Fri,  4 Mar 2011 11:42:23 -0800
Message-ID: <1299267744-17278-12-git-send-email-ddaney@caviumnetworks.com>
References: <1299267744-17278-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1299267744-17278-1-git-send-email-ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

The device tree will supply the register bank base addresses, make
register addressing relative to those.  PHY connection is now
described by the device tree.

Signed-off-by: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/mips/cavium-octeon/octeon-platform.c |   62 ------
 drivers/net/octeon/octeon_mgmt.c          |  321 +++++++++++++++++++----------
 2 files changed, 217 insertions(+), 166 deletions(-)

diff --git a/arch/mips/cavium-octeon/octeon-platform.c b/arch/mips/cavium-octeon/octeon-platform.c
index ce471bd..104713c 100644
--- a/arch/mips/cavium-octeon/octeon-platform.c
+++ b/arch/mips/cavium-octeon/octeon-platform.c
@@ -168,68 +168,6 @@ out:
 }
 device_initcall(octeon_rng_device_init);
 
-/* Octeon mgmt port Ethernet interface.  */
-static int __init octeon_mgmt_device_init(void)
-{
-	struct platform_device *pd;
-	int ret = 0;
-	int port, num_ports;
-
-	struct resource mgmt_port_resource = {
-		.flags	= IORESOURCE_IRQ,
-		.start	= -1,
-		.end	= -1
-	};
-
-	if (!OCTEON_IS_MODEL(OCTEON_CN56XX) && !OCTEON_IS_MODEL(OCTEON_CN52XX))
-		return 0;
-
-	if (OCTEON_IS_MODEL(OCTEON_CN56XX))
-		num_ports = 1;
-	else
-		num_ports = 2;
-
-	for (port = 0; port < num_ports; port++) {
-		pd = platform_device_alloc("octeon_mgmt", port);
-		if (!pd) {
-			ret = -ENOMEM;
-			goto out;
-		}
-		/* No DMA restrictions */
-		pd->dev.coherent_dma_mask = DMA_BIT_MASK(64);
-		pd->dev.dma_mask = &pd->dev.coherent_dma_mask;
-
-		switch (port) {
-		case 0:
-			mgmt_port_resource.start = OCTEON_IRQ_MII0;
-			break;
-		case 1:
-			mgmt_port_resource.start = OCTEON_IRQ_MII1;
-			break;
-		default:
-			BUG();
-		}
-		mgmt_port_resource.end = mgmt_port_resource.start;
-
-		ret = platform_device_add_resources(pd, &mgmt_port_resource, 1);
-
-		if (ret)
-			goto fail;
-
-		ret = platform_device_add(pd);
-		if (ret)
-			goto fail;
-	}
-	return ret;
-fail:
-	platform_device_put(pd);
-
-out:
-	return ret;
-
-}
-device_initcall(octeon_mgmt_device_init);
-
 #ifdef CONFIG_USB
 
 static int __init octeon_ehci_device_init(void)
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index b264f0f..17be326 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -6,16 +6,18 @@
  * Copyright (C) 2009 Cavium Networks
  */
 
-#include <linux/capability.h>
-#include <linux/dma-mapping.h>
-#include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/netdevice.h>
+#include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
+#include <linux/capability.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
 #include <linux/if_vlan.h>
+#include <linux/of_mdio.h>
+#include <linux/of_net.h>
+#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/phy.h>
-#include <linux/spinlock.h>
 
 #include <asm/octeon/octeon.h>
 #include <asm/octeon/cvmx-mixx-defs.h>
@@ -55,8 +57,56 @@ union mgmt_port_ring_entry {
 	} s;
 };
 
+#define MIX_ORING1	0x0
+#define MIX_ORING2	0x8
+#define MIX_IRING1	0x10
+#define MIX_IRING2	0x18
+#define MIX_CTL		0x20
+#define MIX_IRHWM	0x28
+#define MIX_IRCNT	0x30
+#define MIX_ORHWM	0x38
+#define MIX_ORCNT	0x40
+#define MIX_ISR		0x48
+#define MIX_INTENA	0x50
+#define MIX_REMCNT	0x58
+#define MIX_BIST	0x78
+
+#define AGL_GMX_PRT_CFG			0x10
+#define AGL_GMX_RX_FRM_CTL		0x18
+#define AGL_GMX_RX_FRM_MAX		0x30
+#define AGL_GMX_RX_JABBER		0x38
+#define AGL_GMX_RX_STATS_CTL		0x50
+
+#define AGL_GMX_RX_STATS_PKTS_DRP	0xb0
+#define AGL_GMX_RX_STATS_OCTS_DRP	0xb8
+#define AGL_GMX_RX_STATS_PKTS_BAD	0xc0
+
+#define AGL_GMX_RX_ADR_CTL		0x100
+#define AGL_GMX_RX_ADR_CAM_EN		0x108
+#define AGL_GMX_RX_ADR_CAM0		0x180
+#define AGL_GMX_RX_ADR_CAM1		0x188
+#define AGL_GMX_RX_ADR_CAM2		0x190
+#define AGL_GMX_RX_ADR_CAM3		0x198
+#define AGL_GMX_RX_ADR_CAM4		0x1a0
+#define AGL_GMX_RX_ADR_CAM5		0x1a8
+
+#define AGL_GMX_TX_STATS_CTL		0x268
+#define AGL_GMX_TX_CTL			0x270
+#define AGL_GMX_TX_STAT0		0x280
+#define AGL_GMX_TX_STAT1		0x288
+#define AGL_GMX_TX_STAT2		0x290
+#define AGL_GMX_TX_STAT3		0x298
+#define AGL_GMX_TX_STAT4		0x2a0
+#define AGL_GMX_TX_STAT5		0x2a8
+#define AGL_GMX_TX_STAT6		0x2b0
+#define AGL_GMX_TX_STAT7		0x2b8
+#define AGL_GMX_TX_STAT8		0x2c0
+#define AGL_GMX_TX_STAT9		0x2c8
+
 struct octeon_mgmt {
 	struct net_device *netdev;
+	u64 mix;
+	u64 agl;
 	int port;
 	int irq;
 	u64 *tx_ring;
@@ -82,31 +132,34 @@ struct octeon_mgmt {
 	struct napi_struct napi;
 	struct tasklet_struct tx_clean_tasklet;
 	struct phy_device *phydev;
+	struct device_node *phy_np;
+	resource_size_t mix_phys;
+	resource_size_t mix_size;
+	resource_size_t agl_phys;
+	resource_size_t agl_size;
 };
 
 static void octeon_mgmt_set_rx_irq(struct octeon_mgmt *p, int enable)
 {
-	int port = p->port;
 	union cvmx_mixx_intena mix_intena;
 	unsigned long flags;
 
 	spin_lock_irqsave(&p->lock, flags);
-	mix_intena.u64 = cvmx_read_csr(CVMX_MIXX_INTENA(port));
+	mix_intena.u64 = cvmx_read_csr(p->mix + MIX_INTENA);
 	mix_intena.s.ithena = enable ? 1 : 0;
-	cvmx_write_csr(CVMX_MIXX_INTENA(port), mix_intena.u64);
+	cvmx_write_csr(p->mix + MIX_INTENA, mix_intena.u64);
 	spin_unlock_irqrestore(&p->lock, flags);
 }
 
 static void octeon_mgmt_set_tx_irq(struct octeon_mgmt *p, int enable)
 {
-	int port = p->port;
 	union cvmx_mixx_intena mix_intena;
 	unsigned long flags;
 
 	spin_lock_irqsave(&p->lock, flags);
-	mix_intena.u64 = cvmx_read_csr(CVMX_MIXX_INTENA(port));
+	mix_intena.u64 = cvmx_read_csr(p->mix + MIX_INTENA);
 	mix_intena.s.othena = enable ? 1 : 0;
-	cvmx_write_csr(CVMX_MIXX_INTENA(port), mix_intena.u64);
+	cvmx_write_csr(p->mix + MIX_INTENA, mix_intena.u64);
 	spin_unlock_irqrestore(&p->lock, flags);
 }
 
@@ -143,7 +196,6 @@ static unsigned int ring_size_to_bytes(unsigned int ring_size)
 static void octeon_mgmt_rx_fill_ring(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 
 	while (p->rx_current_fill < ring_max_fill(OCTEON_MGMT_RX_RING_SIZE)) {
 		unsigned int size;
@@ -174,24 +226,23 @@ static void octeon_mgmt_rx_fill_ring(struct net_device *netdev)
 			(p->rx_next_fill + 1) % OCTEON_MGMT_RX_RING_SIZE;
 		p->rx_current_fill++;
 		/* Ring the bell.  */
-		cvmx_write_csr(CVMX_MIXX_IRING2(port), 1);
+		cvmx_write_csr(p->mix + MIX_IRING2, 1);
 	}
 }
 
 static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 {
-	int port = p->port;
 	union cvmx_mixx_orcnt mix_orcnt;
 	union mgmt_port_ring_entry re;
 	struct sk_buff *skb;
 	int cleaned = 0;
 	unsigned long flags;
 
-	mix_orcnt.u64 = cvmx_read_csr(CVMX_MIXX_ORCNT(port));
+	mix_orcnt.u64 = cvmx_read_csr(p->mix + MIX_ORCNT);
 	while (mix_orcnt.s.orcnt) {
 		spin_lock_irqsave(&p->tx_list.lock, flags);
 
-		mix_orcnt.u64 = cvmx_read_csr(CVMX_MIXX_ORCNT(port));
+		mix_orcnt.u64 = cvmx_read_csr(p->mix + MIX_ORCNT);
 
 		if (mix_orcnt.s.orcnt == 0) {
 			spin_unlock_irqrestore(&p->tx_list.lock, flags);
@@ -211,7 +262,7 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 		mix_orcnt.s.orcnt = 1;
 
 		/* Acknowledge to hardware that we have the buffer.  */
-		cvmx_write_csr(CVMX_MIXX_ORCNT(port), mix_orcnt.u64);
+		cvmx_write_csr(p->mix + MIX_ORCNT, mix_orcnt.u64);
 		p->tx_current_fill--;
 
 		spin_unlock_irqrestore(&p->tx_list.lock, flags);
@@ -221,7 +272,7 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 		dev_kfree_skb_any(skb);
 		cleaned++;
 
-		mix_orcnt.u64 = cvmx_read_csr(CVMX_MIXX_ORCNT(port));
+		mix_orcnt.u64 = cvmx_read_csr(p->mix + MIX_ORCNT);
 	}
 
 	if (cleaned && netif_queue_stopped(p->netdev))
@@ -238,13 +289,12 @@ static void octeon_mgmt_clean_tx_tasklet(unsigned long arg)
 static void octeon_mgmt_update_rx_stats(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 	unsigned long flags;
 	u64 drop, bad;
 
 	/* These reads also clear the count registers.  */
-	drop = cvmx_read_csr(CVMX_AGL_GMX_RXX_STATS_PKTS_DRP(port));
-	bad = cvmx_read_csr(CVMX_AGL_GMX_RXX_STATS_PKTS_BAD(port));
+	drop = cvmx_read_csr(p->agl + AGL_GMX_RX_STATS_PKTS_DRP);
+	bad = cvmx_read_csr(p->agl + AGL_GMX_RX_STATS_PKTS_BAD);
 
 	if (drop || bad) {
 		/* Do an atomic update. */
@@ -258,15 +308,14 @@ static void octeon_mgmt_update_rx_stats(struct net_device *netdev)
 static void octeon_mgmt_update_tx_stats(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 	unsigned long flags;
 
 	union cvmx_agl_gmx_txx_stat0 s0;
 	union cvmx_agl_gmx_txx_stat1 s1;
 
 	/* These reads also clear the count registers.  */
-	s0.u64 = cvmx_read_csr(CVMX_AGL_GMX_TXX_STAT0(port));
-	s1.u64 = cvmx_read_csr(CVMX_AGL_GMX_TXX_STAT1(port));
+	s0.u64 = cvmx_read_csr(p->agl + AGL_GMX_TX_STAT0);
+	s1.u64 = cvmx_read_csr(p->agl + AGL_GMX_TX_STAT1);
 
 	if (s0.s.xsdef || s0.s.xscol || s1.s.scol || s1.s.mcol) {
 		/* Do an atomic update. */
@@ -305,7 +354,6 @@ static u64 octeon_mgmt_dequeue_rx_buffer(struct octeon_mgmt *p,
 
 static int octeon_mgmt_receive_one(struct octeon_mgmt *p)
 {
-	int port = p->port;
 	struct net_device *netdev = p->netdev;
 	union cvmx_mixx_ircnt mix_ircnt;
 	union mgmt_port_ring_entry re;
@@ -378,18 +426,17 @@ done:
 	/* Tell the hardware we processed a packet.  */
 	mix_ircnt.u64 = 0;
 	mix_ircnt.s.ircnt = 1;
-	cvmx_write_csr(CVMX_MIXX_IRCNT(port), mix_ircnt.u64);
+	cvmx_write_csr(p->mix + MIX_IRCNT, mix_ircnt.u64);
 	return rc;
 }
 
 static int octeon_mgmt_receive_packets(struct octeon_mgmt *p, int budget)
 {
-	int port = p->port;
 	unsigned int work_done = 0;
 	union cvmx_mixx_ircnt mix_ircnt;
 	int rc;
 
-	mix_ircnt.u64 = cvmx_read_csr(CVMX_MIXX_IRCNT(port));
+	mix_ircnt.u64 = cvmx_read_csr(p->mix + MIX_IRCNT);
 	while (work_done < budget && mix_ircnt.s.ircnt) {
 
 		rc = octeon_mgmt_receive_one(p);
@@ -397,7 +444,7 @@ static int octeon_mgmt_receive_packets(struct octeon_mgmt *p, int budget)
 			work_done++;
 
 		/* Check for more packets. */
-		mix_ircnt.u64 = cvmx_read_csr(CVMX_MIXX_IRCNT(port));
+		mix_ircnt.u64 = cvmx_read_csr(p->mix + MIX_IRCNT);
 	}
 
 	octeon_mgmt_rx_fill_ring(p->netdev);
@@ -431,16 +478,16 @@ static void octeon_mgmt_reset_hw(struct octeon_mgmt *p)
 	union cvmx_agl_gmx_bist agl_gmx_bist;
 
 	mix_ctl.u64 = 0;
-	cvmx_write_csr(CVMX_MIXX_CTL(p->port), mix_ctl.u64);
+	cvmx_write_csr(p->mix + MIX_CTL, mix_ctl.u64);
 	do {
-		mix_ctl.u64 = cvmx_read_csr(CVMX_MIXX_CTL(p->port));
+		mix_ctl.u64 = cvmx_read_csr(p->mix + MIX_CTL);
 	} while (mix_ctl.s.busy);
 	mix_ctl.s.reset = 1;
-	cvmx_write_csr(CVMX_MIXX_CTL(p->port), mix_ctl.u64);
-	cvmx_read_csr(CVMX_MIXX_CTL(p->port));
+	cvmx_write_csr(p->mix + MIX_CTL, mix_ctl.u64);
+	cvmx_read_csr(p->mix + MIX_CTL);
 	cvmx_wait(64);
 
-	mix_bist.u64 = cvmx_read_csr(CVMX_MIXX_BIST(p->port));
+	mix_bist.u64 = cvmx_read_csr(p->mix + MIX_BIST);
 	if (mix_bist.u64)
 		dev_warn(p->dev, "MIX failed BIST (0x%016llx)\n",
 			(unsigned long long)mix_bist.u64);
@@ -471,7 +518,6 @@ static void octeon_mgmt_cam_state_add(struct octeon_mgmt_cam_state *cs,
 static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 	union cvmx_agl_gmx_rxx_adr_ctl adr_ctl;
 	union cvmx_agl_gmx_prtx_cfg agl_gmx_prtx;
 	unsigned long flags;
@@ -517,29 +563,29 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 	spin_lock_irqsave(&p->lock, flags);
 
 	/* Disable packet I/O. */
-	agl_gmx_prtx.u64 = cvmx_read_csr(CVMX_AGL_GMX_PRTX_CFG(port));
+	agl_gmx_prtx.u64 = cvmx_read_csr(p->agl + AGL_GMX_PRT_CFG);
 	prev_packet_enable = agl_gmx_prtx.s.en;
 	agl_gmx_prtx.s.en = 0;
-	cvmx_write_csr(CVMX_AGL_GMX_PRTX_CFG(port), agl_gmx_prtx.u64);
+	cvmx_write_csr(p->agl + AGL_GMX_PRT_CFG, agl_gmx_prtx.u64);
 
 	adr_ctl.u64 = 0;
 	adr_ctl.s.cam_mode = cam_mode;
 	adr_ctl.s.mcst = multicast_mode;
 	adr_ctl.s.bcst = 1;     /* Allow broadcast */
 
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CTL(port), adr_ctl.u64);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CTL, adr_ctl.u64);
 
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CAM0(port), cam_state.cam[0]);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CAM1(port), cam_state.cam[1]);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CAM2(port), cam_state.cam[2]);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CAM3(port), cam_state.cam[3]);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CAM4(port), cam_state.cam[4]);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CAM5(port), cam_state.cam[5]);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_ADR_CAM_EN(port), cam_state.cam_mask);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CAM0, cam_state.cam[0]);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CAM1, cam_state.cam[1]);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CAM2, cam_state.cam[2]);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CAM3, cam_state.cam[3]);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CAM4, cam_state.cam[4]);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CAM5, cam_state.cam[5]);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_ADR_CAM_EN, cam_state.cam_mask);
 
 	/* Restore packet I/O. */
 	agl_gmx_prtx.s.en = prev_packet_enable;
-	cvmx_write_csr(CVMX_AGL_GMX_PRTX_CFG(port), agl_gmx_prtx.u64);
+	cvmx_write_csr(p->agl + AGL_GMX_PRT_CFG, agl_gmx_prtx.u64);
 
 	spin_unlock_irqrestore(&p->lock, flags);
 }
@@ -561,7 +607,6 @@ static int octeon_mgmt_set_mac_address(struct net_device *netdev, void *addr)
 static int octeon_mgmt_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 	int size_without_fcs = new_mtu + OCTEON_MGMT_RX_HEADROOM;
 
 	/*
@@ -577,8 +622,8 @@ static int octeon_mgmt_change_mtu(struct net_device *netdev, int new_mtu)
 
 	netdev->mtu = new_mtu;
 
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_FRM_MAX(port), size_without_fcs);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_JABBER(port),
+	cvmx_write_csr(p->agl + AGL_GMX_RX_FRM_MAX, size_without_fcs);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_JABBER,
 		       (size_without_fcs + 7) & 0xfff8);
 
 	return 0;
@@ -588,14 +633,13 @@ static irqreturn_t octeon_mgmt_interrupt(int cpl, void *dev_id)
 {
 	struct net_device *netdev = dev_id;
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 	union cvmx_mixx_isr mixx_isr;
 
-	mixx_isr.u64 = cvmx_read_csr(CVMX_MIXX_ISR(port));
+	mixx_isr.u64 = cvmx_read_csr(p->mix + MIX_ISR);
 
 	/* Clear any pending interrupts */
-	cvmx_write_csr(CVMX_MIXX_ISR(port), mixx_isr.u64);
-	cvmx_read_csr(CVMX_MIXX_ISR(port));
+	cvmx_write_csr(p->mix + MIX_ISR, mixx_isr.u64);
+	cvmx_read_csr(p->mix + MIX_ISR);
 
 	if (mixx_isr.s.irthresh) {
 		octeon_mgmt_disable_rx_irq(p);
@@ -626,7 +670,6 @@ static int octeon_mgmt_ioctl(struct net_device *netdev,
 static void octeon_mgmt_adjust_link(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 	union cvmx_agl_gmx_prtx_cfg prtx_cfg;
 	unsigned long flags;
 	int link_changed = 0;
@@ -637,11 +680,9 @@ static void octeon_mgmt_adjust_link(struct net_device *netdev)
 			link_changed = 1;
 		if (p->last_duplex != p->phydev->duplex) {
 			p->last_duplex = p->phydev->duplex;
-			prtx_cfg.u64 =
-				cvmx_read_csr(CVMX_AGL_GMX_PRTX_CFG(port));
+			prtx_cfg.u64 = cvmx_read_csr(p->agl + AGL_GMX_PRT_CFG);
 			prtx_cfg.s.duplex = p->phydev->duplex;
-			cvmx_write_csr(CVMX_AGL_GMX_PRTX_CFG(port),
-				       prtx_cfg.u64);
+			cvmx_write_csr(p->agl + AGL_GMX_PRT_CFG, prtx_cfg.u64);
 		}
 	} else {
 		if (p->last_link)
@@ -667,18 +708,16 @@ static void octeon_mgmt_adjust_link(struct net_device *netdev)
 static int octeon_mgmt_init_phy(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	char phy_id[20];
 
-	if (octeon_is_simulation()) {
+	if (octeon_is_simulation() || p->phy_np == NULL) {
 		/* No PHYs in the simulator. */
 		netif_carrier_on(netdev);
 		return 0;
 	}
 
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, "0", p->port);
-
-	p->phydev = phy_connect(netdev, phy_id, octeon_mgmt_adjust_link, 0,
-				PHY_INTERFACE_MODE_MII);
+	p->phydev = of_phy_connect(netdev, p->phy_np,
+				   octeon_mgmt_adjust_link, 0,
+				   PHY_INTERFACE_MODE_MII);
 
 	if (IS_ERR(p->phydev)) {
 		p->phydev = NULL;
@@ -734,14 +773,14 @@ static int octeon_mgmt_open(struct net_device *netdev)
 
 	octeon_mgmt_reset_hw(p);
 
-	mix_ctl.u64 = cvmx_read_csr(CVMX_MIXX_CTL(port));
+	mix_ctl.u64 = cvmx_read_csr(p->mix + MIX_CTL);
 
 	/* Bring it out of reset if needed. */
 	if (mix_ctl.s.reset) {
 		mix_ctl.s.reset = 0;
-		cvmx_write_csr(CVMX_MIXX_CTL(port), mix_ctl.u64);
+		cvmx_write_csr(p->mix + MIX_CTL, mix_ctl.u64);
 		do {
-			mix_ctl.u64 = cvmx_read_csr(CVMX_MIXX_CTL(port));
+			mix_ctl.u64 = cvmx_read_csr(p->mix + MIX_CTL);
 		} while (mix_ctl.s.reset);
 	}
 
@@ -752,17 +791,17 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	oring1.u64 = 0;
 	oring1.s.obase = p->tx_ring_handle >> 3;
 	oring1.s.osize = OCTEON_MGMT_TX_RING_SIZE;
-	cvmx_write_csr(CVMX_MIXX_ORING1(port), oring1.u64);
+	cvmx_write_csr(p->mix + MIX_ORING1, oring1.u64);
 
 	iring1.u64 = 0;
 	iring1.s.ibase = p->rx_ring_handle >> 3;
 	iring1.s.isize = OCTEON_MGMT_RX_RING_SIZE;
-	cvmx_write_csr(CVMX_MIXX_IRING1(port), iring1.u64);
+	cvmx_write_csr(p->mix + MIX_IRING1, iring1.u64);
 
 	/* Disable packet I/O. */
-	prtx_cfg.u64 = cvmx_read_csr(CVMX_AGL_GMX_PRTX_CFG(port));
+	prtx_cfg.u64 = cvmx_read_csr(p->agl + AGL_GMX_PRT_CFG);
 	prtx_cfg.s.en = 0;
-	cvmx_write_csr(CVMX_AGL_GMX_PRTX_CFG(port), prtx_cfg.u64);
+	cvmx_write_csr(p->agl + AGL_GMX_PRT_CFG, prtx_cfg.u64);
 
 	memcpy(sa.sa_data, netdev->dev_addr, ETH_ALEN);
 	octeon_mgmt_set_mac_address(netdev, &sa);
@@ -779,7 +818,7 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	mix_ctl.s.nbtarb = 0;       /* Arbitration mode */
 	/* MII CB-request FIFO programmable high watermark */
 	mix_ctl.s.mrq_hwm = 1;
-	cvmx_write_csr(CVMX_MIXX_CTL(port), mix_ctl.u64);
+	cvmx_write_csr(p->mix + MIX_CTL, mix_ctl.u64);
 
 	if (OCTEON_IS_MODEL(OCTEON_CN56XX_PASS1_X)
 	    || OCTEON_IS_MODEL(OCTEON_CN52XX_PASS1_X)) {
@@ -806,16 +845,16 @@ static int octeon_mgmt_open(struct net_device *netdev)
 
 	/* Clear statistics. */
 	/* Clear on read. */
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_STATS_CTL(port), 1);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_STATS_PKTS_DRP(port), 0);
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_STATS_PKTS_BAD(port), 0);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_STATS_CTL, 1);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_STATS_PKTS_DRP, 0);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_STATS_PKTS_BAD, 0);
 
-	cvmx_write_csr(CVMX_AGL_GMX_TXX_STATS_CTL(port), 1);
-	cvmx_write_csr(CVMX_AGL_GMX_TXX_STAT0(port), 0);
-	cvmx_write_csr(CVMX_AGL_GMX_TXX_STAT1(port), 0);
+	cvmx_write_csr(p->agl + AGL_GMX_TX_STATS_CTL, 1);
+	cvmx_write_csr(p->agl + AGL_GMX_TX_STAT0, 0);
+	cvmx_write_csr(p->agl + AGL_GMX_TX_STAT1, 0);
 
 	/* Clear any pending interrupts */
-	cvmx_write_csr(CVMX_MIXX_ISR(port), cvmx_read_csr(CVMX_MIXX_ISR(port)));
+	cvmx_write_csr(p->mix + MIX_ISR, cvmx_read_csr(p->mix + MIX_ISR));
 
 	if (request_irq(p->irq, octeon_mgmt_interrupt, 0, netdev->name,
 			netdev)) {
@@ -826,18 +865,18 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	/* Interrupt every single RX packet */
 	mix_irhwm.u64 = 0;
 	mix_irhwm.s.irhwm = 0;
-	cvmx_write_csr(CVMX_MIXX_IRHWM(port), mix_irhwm.u64);
+	cvmx_write_csr(p->mix + MIX_IRHWM, mix_irhwm.u64);
 
 	/* Interrupt when we have 1 or more packets to clean.  */
 	mix_orhwm.u64 = 0;
 	mix_orhwm.s.orhwm = 1;
-	cvmx_write_csr(CVMX_MIXX_ORHWM(port), mix_orhwm.u64);
+	cvmx_write_csr(p->mix + MIX_ORHWM, mix_orhwm.u64);
 
 	/* Enable receive and transmit interrupts */
 	mix_intena.u64 = 0;
 	mix_intena.s.ithena = 1;
 	mix_intena.s.othena = 1;
-	cvmx_write_csr(CVMX_MIXX_INTENA(port), mix_intena.u64);
+	cvmx_write_csr(p->mix + MIX_INTENA, mix_intena.u64);
 
 
 	/* Enable packet I/O. */
@@ -868,7 +907,7 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	 * frame.  GMX checks that the PREAMBLE is sent correctly.
 	 */
 	rxx_frm_ctl.s.pre_chk = 1;
-	cvmx_write_csr(CVMX_AGL_GMX_RXX_FRM_CTL(port), rxx_frm_ctl.u64);
+	cvmx_write_csr(p->agl + AGL_GMX_RX_FRM_CTL, rxx_frm_ctl.u64);
 
 	/* Enable the AGL block */
 	agl_gmx_inf_mode.u64 = 0;
@@ -876,13 +915,13 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	cvmx_write_csr(CVMX_AGL_GMX_INF_MODE, agl_gmx_inf_mode.u64);
 
 	/* Configure the port duplex and enables */
-	prtx_cfg.u64 = cvmx_read_csr(CVMX_AGL_GMX_PRTX_CFG(port));
+	prtx_cfg.u64 = cvmx_read_csr(p->agl + AGL_GMX_PRT_CFG);
 	prtx_cfg.s.tx_en = 1;
 	prtx_cfg.s.rx_en = 1;
 	prtx_cfg.s.en = 1;
 	p->last_duplex = 1;
 	prtx_cfg.s.duplex = p->last_duplex;
-	cvmx_write_csr(CVMX_AGL_GMX_PRTX_CFG(port), prtx_cfg.u64);
+	cvmx_write_csr(p->agl + AGL_GMX_PRT_CFG, prtx_cfg.u64);
 
 	p->last_link = 0;
 	netif_carrier_off(netdev);
@@ -946,7 +985,6 @@ static int octeon_mgmt_stop(struct net_device *netdev)
 static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	int port = p->port;
 	union mgmt_port_ring_entry re;
 	unsigned long flags;
 	int rv = NETDEV_TX_BUSY;
@@ -990,7 +1028,7 @@ static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	netdev->stats.tx_bytes += skb->len;
 
 	/* Ring the bell.  */
-	cvmx_write_csr(CVMX_MIXX_ORING2(port), 1);
+	cvmx_write_csr(p->mix + MIX_ORING2, 1);
 
 	rv = NETDEV_TX_OK;
 out:
@@ -1069,10 +1107,14 @@ static const struct net_device_ops octeon_mgmt_ops = {
 
 static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 {
-	struct resource *res_irq;
 	struct net_device *netdev;
 	struct octeon_mgmt *p;
-	int i;
+	const __be32 *data;
+	const u8 *mac;
+	struct resource *res_mix;
+	struct resource *res_agl;
+	int len;
+	int result;
 
 	netdev = alloc_etherdev(sizeof(struct octeon_mgmt));
 	if (netdev == NULL)
@@ -1086,14 +1128,63 @@ static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 	p->netdev = netdev;
 	p->dev = &pdev->dev;
 
-	p->port = pdev->id;
+	data = of_get_property(pdev->dev.of_node, "cell-index", &len);
+	if (data && len == sizeof(*data)) {
+		p->port = be32_to_cpup(data);
+	} else {
+		dev_err(&pdev->dev, "no 'cell-index' property\n");
+		result = -ENXIO;
+		goto err;
+	}
+
 	snprintf(netdev->name, IFNAMSIZ, "mgmt%d", p->port);
 
-	res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (!res_irq)
+	result = platform_get_irq(pdev, 0);
+	if (result < 0)
+		goto err;
+
+	p->irq = result;
+
+	res_mix = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res_mix == NULL) {
+		dev_err(&pdev->dev, "no 'reg' resource\n");
+		result = -ENXIO;
+		goto err;
+	}
+
+	res_agl = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (res_agl == NULL) {
+		dev_err(&pdev->dev, "no 'reg' resource\n");
+		result = -ENXIO;
 		goto err;
+	}
+
+	p->mix_phys = res_mix->start;
+	p->mix_size = resource_size(res_mix);
+	p->agl_phys = res_agl->start;
+	p->agl_size = resource_size(res_agl);
+
+
+	if (!devm_request_mem_region(&pdev->dev, p->mix_phys, p->mix_size,
+				     res_mix->name)) {
+		dev_err(&pdev->dev, "request_mem_region (%s) failed\n",
+			res_mix->name);
+		result = -ENXIO;
+		goto err;
+	}
+
+	if (!devm_request_mem_region(&pdev->dev, p->agl_phys, p->agl_size,
+				     res_agl->name)) {
+		result = -ENXIO;
+		dev_err(&pdev->dev, "request_mem_region (%s) failed\n",
+			res_agl->name);
+		goto fail_region1;
+	}
+
+
+	p->mix = (u64)ioremap(p->mix_phys, p->mix_size);
+	p->agl = (u64)ioremap(p->agl_phys, p->agl_size);
 
-	p->irq = res_irq->start;
 	spin_lock_init(&p->lock);
 
 	skb_queue_head_init(&p->tx_list);
@@ -1104,39 +1195,61 @@ static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 	netdev->netdev_ops = &octeon_mgmt_ops;
 	netdev->ethtool_ops = &octeon_mgmt_ethtool_ops;
 
-	/* The mgmt ports get the first N MACs.  */
-	for (i = 0; i < 6; i++)
-		netdev->dev_addr[i] = octeon_bootinfo->mac_addr_base[i];
-	netdev->dev_addr[5] += p->port;
+	mac = of_get_mac_address(pdev->dev.of_node);
 
-	if (p->port >= octeon_bootinfo->mac_addr_count)
-		dev_err(&pdev->dev,
-			"Error %s: Using MAC outside of the assigned range: %pM\n",
-			netdev->name, netdev->dev_addr);
+	if (mac)
+		memcpy(netdev->dev_addr, mac, 6);
 
-	if (register_netdev(netdev))
-		goto err;
+	p->phy_np = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
+
+	pdev->dev.coherent_dma_mask = DMA_BIT_MASK(64);
+	pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
+
+	result = register_netdev(netdev);
+	if (result)
+		goto fail_region2;
 
 	dev_info(&pdev->dev, "Version " DRV_VERSION "\n");
 	return 0;
+
+fail_region2:
+	iounmap((void *)p->agl);
+	iounmap((void *)p->mix);
+	devm_release_mem_region(&pdev->dev, p->agl_phys, p->agl_size);
+fail_region1:
+	devm_release_mem_region(&pdev->dev, p->mix_phys, p->mix_size);
 err:
 	free_netdev(netdev);
-	return -ENOENT;
+	return result;
 }
 
 static int __devexit octeon_mgmt_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+	struct octeon_mgmt *p = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
+	iounmap((void *)p->agl);
+	iounmap((void *)p->mix);
+	devm_release_mem_region(&pdev->dev, p->agl_phys, p->agl_size);
+	devm_release_mem_region(&pdev->dev, p->mix_phys, p->mix_size);
 	free_netdev(netdev);
 	return 0;
 }
 
+static struct of_device_id octeon_mgmt_match[] = {
+	{
+		.compatible = "cavium,octeon-5750-mix",
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(of, octeon_mgmt_match);
+
 static struct platform_driver octeon_mgmt_driver = {
 	.driver = {
 		.name		= "octeon_mgmt",
 		.owner		= THIS_MODULE,
+		.of_match_table = octeon_mgmt_match,
 	},
 	.probe		= octeon_mgmt_probe,
 	.remove		= __devexit_p(octeon_mgmt_remove),
-- 
1.7.2.3
