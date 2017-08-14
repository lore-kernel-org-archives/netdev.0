From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net-next v2 3/3] ftgmac100: Support NCSI VLAN filtering when available
Date: Mon, 14 Aug 2017 11:29:52 +1000
Message-ID: <20170814012952.13740-4-sam@mendozajonas.com>
References: <20170814012952.13740-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        Joel Stanley <joel@jms.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>, ratagupt@in.ibm.com
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814012952.13740-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Register the ndo_vlan_rx_{add,kill}_vid callbacks and set the
NETIF_F_HW_VLAN_CTAG_FILTER if NCSI is available.
This allows the VLAN core to notify the NCSI driver when changes occur
so that the remote NCSI channel can be properly configured to filter on
the set VLAN tags.

Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
v2: Moved ftgmac100 change into same patch and reordered

 drivers/net/ethernet/faraday/ftgmac100.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 34dae51effd4..05fe7123d5ae 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1623,6 +1623,8 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ftgmac100_poll_controller,
 #endif
+	.ndo_vlan_rx_add_vid	= ncsi_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= ncsi_vlan_rx_kill_vid,
 };
 
 static int ftgmac100_setup_mdio(struct net_device *netdev)
@@ -1837,6 +1839,9 @@ static int ftgmac100_probe(struct platform_device *pdev)
 		NETIF_F_GRO | NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_RX |
 		NETIF_F_HW_VLAN_CTAG_TX;
 
+	if (priv->use_ncsi)
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+
 	/* AST2400  doesn't have working HW checksum generation */
 	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac")))
 		netdev->hw_features &= ~NETIF_F_HW_CSUM;
-- 
2.14.0
