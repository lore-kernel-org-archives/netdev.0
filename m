From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next v2 09/10] dpaa_eth: enable multiple Tx traffic classes
Date: Thu, 9 Mar 2017 16:37:04 +0200
Message-ID: <1489070225-7891-10-git-send-email-madalin.bucur@nxp.com>
References: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@nxp.com>, linux-kernel@vger.kernel.org,
 camelia.groza@nxp.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
 dan.carpenter@oracle.com
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Camelia Groza <camelia.groza@nxp.com>

Implement the setup_tc ndo to configure prioritised Tx traffic classes.
Priorities range from 0 (lowest) to 3 (highest). The driver assigns
NR_CPUS queues to each traffic class.

Signed-off-by: Camelia Groza <camelia.groza@nxp.com>
Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 36 ++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index ac75d09..1b3ea38 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -342,6 +342,41 @@ static void dpaa_get_stats64(struct net_device *net_dev,
 	}
 }
 
+static int dpaa_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
+			 struct tc_to_netdev *tc)
+{
+	struct dpaa_priv *priv = netdev_priv(net_dev);
+	int i;
+
+	if (tc->type != TC_SETUP_MQPRIO)
+		return -EINVAL;
+
+	if (tc->tc == priv->num_tc)
+		return 0;
+
+	if (!tc->tc) {
+		netdev_reset_tc(net_dev);
+		goto out;
+	}
+
+	if (tc->tc > DPAA_TC_NUM) {
+		netdev_err(net_dev, "Too many traffic classes: max %d supported.\n",
+			   DPAA_TC_NUM);
+		return -EINVAL;
+	}
+
+	netdev_set_num_tc(net_dev, tc->tc);
+
+	for (i = 0; i < tc->tc; i++)
+		netdev_set_tc_queue(net_dev, i, DPAA_TC_TXQ_NUM,
+				    i * DPAA_TC_TXQ_NUM);
+
+out:
+	priv->num_tc = tc->tc ? tc->tc : 1;
+	netif_set_real_num_tx_queues(net_dev, priv->num_tc * DPAA_TC_TXQ_NUM);
+	return 0;
+}
+
 static struct mac_device *dpaa_mac_dev_get(struct platform_device *pdev)
 {
 	struct platform_device *of_dev;
@@ -2417,6 +2452,7 @@ static const struct net_device_ops dpaa_ops = {
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_set_rx_mode = dpaa_set_rx_mode,
 	.ndo_do_ioctl = dpaa_ioctl,
+	.ndo_setup_tc = dpaa_setup_tc,
 };
 
 static int dpaa_napi_add(struct net_device *net_dev)
-- 
2.1.0
