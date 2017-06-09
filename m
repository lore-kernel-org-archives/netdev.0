From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH v2] sh_eth: add support to change MTU
Date: Fri,  9 Jun 2017 22:32:15 +0200
Message-ID: <20170609203215.1206-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hardware supports the MTU to be changed and the driver it self is
somewhat prepared to support this. This patch hooks up the callbacks to
be able to change the MTU from user-space.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---

Based on v4.12-rc1 and tested on Renesas R-Car Koelsch M2.

Test procedure:

1. On host set MTU to something large (9000) was used for this test.

2. On target set MTU to something other then 1500, in this test the max
   MTU of 1978 is used.

3. Send ping with large payload and observe that it works.

   ping -M do -s 1954 <target>

   The reason for 1954 instead of 1982 is two fold:

   1. On Linux (different on Mac IIRC) the ICMP/ping implementation
      doesn’t encapsulate the 28 byte ICMP (8) + IP (20).
   2. The driver internally reserve 4 bytes of transmission buffer for
      an optional VLAN header (4). And since no VLAN is used in this
      setup the additional 4 bytes can carry data.

4. For extra verification the packet flow is inspected using tcpdump to
   verify that there is no packet fragmentation.

* Changes since v1
- Fix spelling mistake in comment, thanks Sergei!
- Add Acked-by from Sergei.

 drivers/net/ethernet/renesas/sh_eth.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index f68c4db656eda846..9c6e4025bfc9f5c5 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2558,6 +2558,17 @@ static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
+static int sh_eth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (netif_running(dev))
+		return -EBUSY;
+
+	dev->mtu = new_mtu;
+	netdev_update_features(dev);
+
+	return 0;
+}
+
 /* For TSU_POSTn. Please refer to the manual about this (strange) bitfields */
 static void *sh_eth_tsu_get_post_reg_offset(struct sh_eth_private *mdp,
 					    int entry)
@@ -3029,6 +3040,7 @@ static const struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_set_rx_mode	= sh_eth_set_rx_mode,
 	.ndo_tx_timeout		= sh_eth_tx_timeout,
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
+	.ndo_change_mtu		= sh_eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
@@ -3043,6 +3055,7 @@ static const struct net_device_ops sh_eth_netdev_ops_tsu = {
 	.ndo_vlan_rx_kill_vid	= sh_eth_vlan_rx_kill_vid,
 	.ndo_tx_timeout		= sh_eth_tx_timeout,
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
+	.ndo_change_mtu		= sh_eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
@@ -3171,6 +3184,13 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	}
 	sh_eth_set_default_cpu_data(mdp->cd);
 
+	/* User's manua states max MTU should be 2048 but due to the
+	 * alignment calculations in sh_eth_ring_init() the practical
+	 * MTU is a bit less. Maybe this can be optimized some more.
+	 */
+	ndev->max_mtu = 2000 - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN);
+	ndev->min_mtu = ETH_MIN_MTU;
+
 	/* set function */
 	if (mdp->cd->tsu)
 		ndev->netdev_ops = &sh_eth_netdev_ops_tsu;
-- 
2.13.1
