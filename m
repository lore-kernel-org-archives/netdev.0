From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 1/2] sh_eth: Fix promiscuous mode on chips without TSU
Date: Fri, 16 Jan 2015 17:51:12 +0000
Message-ID: <1421430672.1222.191.camel@xylophone.i.decadent.org.uk>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:47117 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbAPRvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 12:51:15 -0500
In-Reply-To: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently net_device_ops::set_rx_mode is only implemented for
chips with a TSU (multiple address table).  However we do need
to turn the PRM (promiscuous) flag on and off for other chips.

- Remove the unlikely() from the TSU functions that we may safely
  call for chips without a TSU
- Make setting of the MCT flag conditional on the tsu capability flag
- Rename sh_eth_set_multicast_list() to sh_eth_set_rx_mode() and plumb
  it into both net_device_ops structures
- Remove the previously-unreachable branch in sh_eth_rx_mode() that
  would otherwise reset the flags to defaults for non-TSU chips

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 167737f..0c4d5b5 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2417,7 +2417,7 @@ static int sh_eth_tsu_purge_all(struct net_device *ndev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int i, ret;
 
-	if (unlikely(!mdp->cd->tsu))
+	if (!mdp->cd->tsu)
 		return 0;
 
 	for (i = 0; i < SH_ETH_TSU_CAM_ENTRIES; i++) {
@@ -2440,7 +2440,7 @@ static void sh_eth_tsu_purge_mcast(struct net_device *ndev)
 	void *reg_offset = sh_eth_tsu_get_offset(mdp, TSU_ADRH0);
 	int i;
 
-	if (unlikely(!mdp->cd->tsu))
+	if (!mdp->cd->tsu)
 		return;
 
 	for (i = 0; i < SH_ETH_TSU_CAM_ENTRIES; i++, reg_offset += 8) {
@@ -2450,8 +2450,8 @@ static void sh_eth_tsu_purge_mcast(struct net_device *ndev)
 	}
 }
 
-/* Multicast reception directions set */
-static void sh_eth_set_multicast_list(struct net_device *ndev)
+/* Update promiscuous flag and multicast filter */
+static void sh_eth_set_rx_mode(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	u32 ecmr_bits;
@@ -2462,7 +2462,9 @@ static void sh_eth_set_multicast_list(struct net_device *ndev)
 	/* Initial condition is MCT = 1, PRM = 0.
 	 * Depending on ndev->flags, set PRM or clear MCT
 	 */
-	ecmr_bits = (sh_eth_read(ndev, ECMR) & ~ECMR_PRM) | ECMR_MCT;
+	ecmr_bits = sh_eth_read(ndev, ECMR) & ~ECMR_PRM;
+	if (mdp->cd->tsu)
+		ecmr_bits |= ECMR_MCT;
 
 	if (!(ndev->flags & IFF_MULTICAST)) {
 		sh_eth_tsu_purge_mcast(ndev);
@@ -2491,9 +2493,6 @@ static void sh_eth_set_multicast_list(struct net_device *ndev)
 				}
 			}
 		}
-	} else {
-		/* Normal, unicast/broadcast-only mode. */
-		ecmr_bits = (ecmr_bits & ~ECMR_PRM) | ECMR_MCT;
 	}
 
 	/* update the ethernet mode */
@@ -2701,6 +2700,7 @@ static const struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_stop		= sh_eth_close,
 	.ndo_start_xmit		= sh_eth_start_xmit,
 	.ndo_get_stats		= sh_eth_get_stats,
+	.ndo_set_rx_mode	= sh_eth_set_rx_mode,
 	.ndo_tx_timeout		= sh_eth_tx_timeout,
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -2713,7 +2713,7 @@ static const struct net_device_ops sh_eth_netdev_ops_tsu = {
 	.ndo_stop		= sh_eth_close,
 	.ndo_start_xmit		= sh_eth_start_xmit,
 	.ndo_get_stats		= sh_eth_get_stats,
-	.ndo_set_rx_mode	= sh_eth_set_multicast_list,
+	.ndo_set_rx_mode	= sh_eth_set_rx_mode,
 	.ndo_vlan_rx_add_vid	= sh_eth_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= sh_eth_vlan_rx_kill_vid,
 	.ndo_tx_timeout		= sh_eth_tx_timeout,
-- 
1.7.10.4
