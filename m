From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] net: fec: select queue depending on VLAN priority
Date: Mon,  8 May 2017 22:37:08 -0700
Message-ID: <20170509053708.2573-1-stefan@agner.ch>
Cc: andrew@lunn.ch, festevam@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Stefan Agner <stefan@agner.ch>
To: fugang.duan@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the addition of the multi queue code with commit 59d0f7465644
("net: fec: init multi queue date structure") the queue selection
has been handelt by the default transmit queue selection
implementation which tries to evenly distribute the traffic across
all available queues. This selection presumes that the queues are
using an equal priority, however, the queues 1 and 2 are actually
of higher priority (the classification of the queues is enabled in
fec_enet_enable_ring).

This can lead to net scheduler warnings and continuous TX ring
dumps when exercising the system with iperf.

Use only queue 0 for all common traffic (no VLAN and P802.1p
priority 0 and 1) and route level 2-7 through queue 1 and 2.

Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
Fixes: 59d0f7465644 ("net: fec: init multi queue date structure")
---
This patch solves the issue documented in this thread:
https://www.spinics.net/lists/netdev/msg430679.html

 drivers/net/ethernet/freescale/fec_main.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 91a16641e851..72343cbfddc9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -72,6 +72,7 @@ static void fec_enet_itr_coal_init(struct net_device *ndev);
 #define DRIVER_NAME	"fec"
 
 #define FEC_ENET_GET_QUQUE(_x) ((_x == 0) ? 1 : ((_x == 1) ? 2 : 0))
+static const u16 fec_enet_vlan_pri_to_queue[8] = {0, 0, 1, 1, 1, 2, 2, 2};
 
 /* Pause frame feild and FIFO threshold */
 #define FEC_ENET_FCE	(1 << 5)
@@ -3052,10 +3053,28 @@ static int fec_set_features(struct net_device *netdev,
 	return 0;
 }
 
+u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
+			  void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	u16 vlan_tci, vlan_pcp;
+
+	if (!(fep->quirks & FEC_QUIRK_HAS_AVB))
+		return fallback(ndev, skb);
+
+	/* Assign queue 0 if no VLAN tag present */
+	if (vlan_get_tag(skb, &vlan_tci) < 0)
+		return 0;
+
+	vlan_pcp = (vlan_tci & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+	return fec_enet_vlan_pri_to_queue[vlan_pcp];
+}
+
 static const struct net_device_ops fec_netdev_ops = {
 	.ndo_open		= fec_enet_open,
 	.ndo_stop		= fec_enet_close,
 	.ndo_start_xmit		= fec_enet_start_xmit,
+	.ndo_select_queue       = fec_enet_select_queue,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= fec_timeout,
-- 
2.12.2
