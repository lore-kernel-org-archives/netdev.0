From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: add automatic packet steering support
Date: Tue, 28 Mar 2017 12:40:02 -0700
Message-ID: <20170328194002.GA1066@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0076.outbound.protection.outlook.com ([104.47.37.76]:62080
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755402AbdC1Tke (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 15:40:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: VSR Burru <veerasenareddy.burru@cavium.com>

Add automatic packet steering support.  NIC firmware does the actual work;
host driver helps by instructing Octeon's Packet Interface Unit (PKI) to
calculate 5-tuple hash (source ip, destination ip, source port, destination
port, protocol) for egress packets, which the firmware uses to map a flow
to an egress queue. For ingress traffic, same 5-tuple hash is calculated
and reverse mapped to get the matching queue.

Packet steering can be enabled or disabled via ethtool like this:

    ethtool --set-priv-flags ethX pkt_steering on|off

Also, remove deprecated OCT_PRIV_FLAG_TX_BYTES private flag.

Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c      | 14 ++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c   | 20 +++++++++++++++-----
 drivers/net/ethernet/cavium/liquidio/lio_main.c      |  4 ++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c   |  2 ++
 .../net/ethernet/cavium/liquidio/liquidio_common.h   |  2 ++
 drivers/net/ethernet/cavium/liquidio/octeon_device.h |  4 ++--
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h    |  8 ++++----
 7 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index f629c2f..79dbf71 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -248,6 +248,20 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 		netif_info(lio, probe, lio->netdev, "Set RX/TX flow control parameters\n");
 		break;
 
+	case OCTNET_CMD_PKT_STEERING_ENABLE:
+		netif_info(lio, probe, lio->netdev,
+			   "%s Packet Steering Enabled\n", netdev->name);
+		lio_set_priv_flag(lio->oct_dev, OCT_PRIV_FLAG_PKT_STEERING,
+				  true);
+		break;
+
+	case OCTNET_CMD_PKT_STEERING_DISABLE:
+		netif_info(lio, probe, lio->netdev,
+			   "%s Packet Steering Disabled\n", netdev->name);
+		lio_set_priv_flag(lio->oct_dev, OCT_PRIV_FLAG_PKT_STEERING,
+				  false);
+		break;
+
 	default:
 		dev_err(&oct->pci_dev->dev, "%s Unknown cmd %d\n", __func__,
 			nctrl->ncmd.s.cmd);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 50384ce..a2e7663 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -202,6 +202,7 @@ static const char oct_droq_stats_strings[][ETH_GSTRING_LEN] = {
 
 /* LiquidIO driver private flags */
 static const char oct_priv_flags_strings[][ETH_GSTRING_LEN] = {
+	"pkt_steering",
 };
 
 #define OCTNIC_NCMD_AUTONEG_ON  0x1
@@ -2461,6 +2462,18 @@ static void lio_get_regs(struct net_device *dev,
 	}
 }
 
+void lio_set_pkt_steering(struct net_device *netdev, bool flag)
+{
+	int cmd;
+
+	if (flag)
+		cmd = OCTNET_CMD_PKT_STEERING_ENABLE;
+	else
+		cmd = OCTNET_CMD_PKT_STEERING_DISABLE;
+
+	liquidio_set_feature(netdev, cmd, 0);
+}
+
 static u32 lio_get_priv_flags(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -2470,11 +2483,8 @@ static u32 lio_get_priv_flags(struct net_device *netdev)
 
 static int lio_set_priv_flags(struct net_device *netdev, u32 flags)
 {
-	struct lio *lio = GET_LIO(netdev);
-	bool intr_by_tx_bytes = !!(flags & (0x1 << OCT_PRIV_FLAG_TX_BYTES));
-
-	lio_set_priv_flag(lio->oct_dev, OCT_PRIV_FLAG_TX_BYTES,
-			  intr_by_tx_bytes);
+	lio_set_pkt_steering(netdev, !!(flags &
+					(0x1 << OCT_PRIV_FLAG_PKT_STEERING)));
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index be9c0e3..b2d1117 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -4119,6 +4119,10 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			liquidio_set_feature(netdev,
 					     OCTNET_CMD_VERBOSE_ENABLE, 0);
 
+		if (OCTEON_CN23XX_PF(octeon_dev))
+			liquidio_set_feature(netdev,
+					     OCTNET_CMD_PKT_STEERING_ENABLE, 0);
+
 		if (setup_link_status_change_wq(netdev))
 			goto setup_nic_dev_fail;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 9d5e035..3592b65 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -2994,6 +2994,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE,
 					     0);
 
+		liquidio_set_feature(netdev, OCTNET_CMD_PKT_STEERING_ENABLE, 0);
+
 		if (setup_link_status_change_wq(netdev))
 			goto setup_nic_dev_fail;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 294c6f3..26cfe81 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -217,6 +217,8 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 
 #define   OCTNET_CMD_SET_UC_LIST       0x1b
 #define   OCTNET_CMD_SET_VF_LINKSTATE  0x1c
+#define   OCTNET_CMD_PKT_STEERING_ENABLE  0x1e
+#define   OCTNET_CMD_PKT_STEERING_DISABLE 0x1f
 #define   OCTNET_CMD_VXLAN_PORT_ADD    0x0
 #define   OCTNET_CMD_VXLAN_PORT_DEL    0x1
 #define   OCTNET_CMD_RXCSUM_ENABLE     0x0
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index c301a38..6a0d04a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -805,9 +805,9 @@ void octeon_free_ioq_vector(struct octeon_device *oct);
 int octeon_allocate_ioq_vector(struct octeon_device  *oct);
 void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq);
 
-/* LiquidIO driver pivate flags */
+/* LiquidIO driver private flags */
 enum {
-	OCT_PRIV_FLAG_TX_BYTES = 0, /* Tx interrupts by pending byte count */
+	OCT_PRIV_FLAG_PKT_STEERING,
 };
 
 #define OCT_PRIV_FLAG_DEFAULT 0x0
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 0c7a5c9..3417ca1 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -203,8 +203,8 @@ octnet_prepare_pci_cmd_o3(struct octeon_device *oct,
 	}
 
 	pki_ih3->w       = 1;
-	pki_ih3->raw     = 1;
-	pki_ih3->utag    = 1;
+	pki_ih3->raw     = 0;
+	pki_ih3->utag    = 0;
 	pki_ih3->utt     = 1;
 	pki_ih3->uqpg    = oct->instr_queue[setup->s.iq_no]->txpciq.s.use_qpg;
 
@@ -217,8 +217,8 @@ octnet_prepare_pci_cmd_o3(struct octeon_device *oct,
 
 	pki_ih3->tagtype = ORDERED_TAG;
 	pki_ih3->qpg     = oct->instr_queue[setup->s.iq_no]->txpciq.s.qpg;
-	pki_ih3->pm      = 0x7; /*0x7 - meant for Parse nothing, uninterpreted*/
-	pki_ih3->sl      = 8;   /* sl will be sizeof(pki_ih3)*/
+	pki_ih3->pm      = 0x0; /* parse from L2 */
+	pki_ih3->sl      = ih3->fsz;
 
 	irh = (struct octeon_instr_irh *)&cmd->cmd3.irh;
 
