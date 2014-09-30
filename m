From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v6 01/10] net: pxa168_eth: clean up
Date: Tue, 30 Sep 2014 16:28:07 +0200
Message-ID: <1412087296-18475-2-git-send-email-antoine.tenart@free-electrons.com>
References: <1412087296-18475-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 jszhang@marvell.com, linux-arm-kernel@lists.infradead.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1412087296-18475-1-git-send-email-antoine.tenart@free-electrons.com>
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

Clean up a bit the pxa168_eth driver before adding the device tree
support.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 102 +++++++++++++++---------------
 1 file changed, 50 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 8f5aa7c62b18..b370162dbe02 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -22,27 +22,29 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include <linux/dma-mapping.h>
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <linux/tcp.h>
-#include <linux/udp.h>
-#include <linux/etherdevice.h>
 #include <linux/bitops.h>
+#include <linux/clk.h>
 #include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
 #include <linux/ethtool.h>
-#include <linux/platform_device.h>
-#include <linux/module.h>
+#include <linux/in.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/ip.h>
 #include <linux/kernel.h>
-#include <linux/workqueue.h>
-#include <linux/clk.h>
+#include <linux/module.h>
+#include <linux/of.h>
 #include <linux/phy.h>
-#include <linux/io.h>
-#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+#include <linux/pxa168_eth.h>
+#include <linux/tcp.h>
 #include <linux/types.h>
+#include <linux/udp.h>
+#include <linux/workqueue.h>
+
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
-#include <linux/pxa168_eth.h>
 
 #define DRIVER_NAME	"pxa168-eth"
 #define DRIVER_VERSION	"0.3"
@@ -296,7 +298,7 @@ static void abort_dma(struct pxa168_eth_private *pep)
 	} while (max_retries-- > 0 && delay <= 0);
 
 	if (max_retries <= 0)
-		printk(KERN_ERR "%s : DMA Stuck\n", __func__);
+		netdev_err(pep->dev, "%s : DMA Stuck\n", __func__);
 }
 
 static int ethernet_phy_get(struct pxa168_eth_private *pep)
@@ -507,9 +509,10 @@ static int add_del_hash_entry(struct pxa168_eth_private *pep,
 
 	if (i == HOP_NUMBER) {
 		if (!del) {
-			printk(KERN_INFO "%s: table section is full, need to "
-					"move to 16kB implementation?\n",
-					 __FILE__);
+			netdev_info(pep->dev,
+				    "%s: table section is full, need to "
+				    "move to 16kB implementation?\n",
+				    __FILE__);
 			return -ENOSPC;
 		} else
 			return 0;
@@ -726,7 +729,7 @@ static int txq_reclaim(struct net_device *dev, int force)
 
 		if (cmd_sts & TX_ERROR) {
 			if (net_ratelimit())
-				printk(KERN_ERR "%s: Error in TX\n", dev->name);
+				netdev_err(dev, "Error in TX\n");
 			dev->stats.tx_errors++;
 		}
 		dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
@@ -743,8 +746,7 @@ static void pxa168_eth_tx_timeout(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 
-	printk(KERN_INFO "%s: TX timeout  desc_count %d\n",
-	       dev->name, pep->tx_desc_count);
+	netdev_info(dev, "TX timeout  desc_count %d\n", pep->tx_desc_count);
 
 	schedule_work(&pep->tx_timeout_task);
 }
@@ -814,9 +816,8 @@ static int rxq_process(struct net_device *dev, int budget)
 			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 			    (RX_FIRST_DESC | RX_LAST_DESC)) {
 				if (net_ratelimit())
-					printk(KERN_ERR
-					       "%s: Rx pkt on multiple desc\n",
-					       dev->name);
+					netdev_err(dev,
+						   "Rx pkt on multiple desc\n");
 			}
 			if (cmd_sts & RX_ERROR)
 				stats->rx_errors++;
@@ -871,7 +872,7 @@ static void handle_link_event(struct pxa168_eth_private *pep)
 	port_status = rdl(pep, PORT_STATUS);
 	if (!(port_status & LINK_UP)) {
 		if (netif_carrier_ok(dev)) {
-			printk(KERN_INFO "%s: link down\n", dev->name);
+			netdev_info(dev, "link down\n");
 			netif_carrier_off(dev);
 			txq_reclaim(dev, 1);
 		}
@@ -884,9 +885,8 @@ static void handle_link_event(struct pxa168_eth_private *pep)
 
 	duplex = (port_status & FULL_DUPLEX) ? 1 : 0;
 	fc = (port_status & FLOW_CONTROL_ENABLED) ? 1 : 0;
-	printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
-	       "flow control %sabled\n", dev->name,
-	       speed, duplex ? "full" : "half", fc ? "en" : "dis");
+	netdev_info(dev, "link up, %d Mb/s, %s duplex, flow control %sabled\n",
+		    speed, duplex ? "full" : "half", fc ? "en" : "dis");
 	if (!netif_carrier_ok(dev))
 		netif_carrier_on(dev);
 }
@@ -1039,9 +1039,8 @@ static void rxq_deinit(struct net_device *dev)
 		}
 	}
 	if (pep->rx_desc_count)
-		printk(KERN_ERR
-		       "Error in freeing Rx Ring. %d skb's still\n",
-		       pep->rx_desc_count);
+		netdev_err(dev, "Error in freeing Rx Ring. %d skb's still\n",
+			   pep->rx_desc_count);
 	/* Free RX ring */
 	if (pep->p_rx_desc_area)
 		dma_free_coherent(pep->dev->dev.parent, pep->rx_desc_area_size,
@@ -1280,15 +1279,15 @@ static int pxa168_smi_read(struct mii_bus *bus, int phy_addr, int regnum)
 	int val;
 
 	if (smi_wait_ready(pep)) {
-		printk(KERN_WARNING "pxa168_eth: SMI bus busy timeout\n");
+		netdev_warn(pep->dev, "pxa168_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 	wrl(pep, SMI, (phy_addr << 16) | (regnum << 21) | SMI_OP_R);
 	/* now wait for the data to be valid */
 	for (i = 0; !((val = rdl(pep, SMI)) & SMI_R_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
-			printk(KERN_WARNING
-				"pxa168_eth: SMI bus read not valid\n");
+			netdev_warn(pep->dev,
+				    "pxa168_eth: SMI bus read not valid\n");
 			return -ENODEV;
 		}
 		msleep(10);
@@ -1303,7 +1302,7 @@ static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int regnum,
 	struct pxa168_eth_private *pep = bus->priv;
 
 	if (smi_wait_ready(pep)) {
-		printk(KERN_WARNING "pxa168_eth: SMI bus busy timeout\n");
+		netdev_warn(pep->dev, "pxa168_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1311,7 +1310,7 @@ static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int regnum,
 	    SMI_OP_W | (value & 0xffff));
 
 	if (smi_wait_ready(pep)) {
-		printk(KERN_ERR "pxa168_eth: SMI bus busy timeout\n");
+		netdev_err(pep->dev, "pxa168_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1425,23 +1424,23 @@ static void pxa168_get_drvinfo(struct net_device *dev,
 }
 
 static const struct ethtool_ops pxa168_ethtool_ops = {
-	.get_settings = pxa168_get_settings,
-	.set_settings = pxa168_set_settings,
-	.get_drvinfo = pxa168_get_drvinfo,
-	.get_link = ethtool_op_get_link,
-	.get_ts_info = ethtool_op_get_ts_info,
+	.get_settings	= pxa168_get_settings,
+	.set_settings	= pxa168_set_settings,
+	.get_drvinfo	= pxa168_get_drvinfo,
+	.get_link	= ethtool_op_get_link,
+	.get_ts_info	= ethtool_op_get_ts_info,
 };
 
 static const struct net_device_ops pxa168_eth_netdev_ops = {
-	.ndo_open = pxa168_eth_open,
-	.ndo_stop = pxa168_eth_stop,
-	.ndo_start_xmit = pxa168_eth_start_xmit,
-	.ndo_set_rx_mode = pxa168_eth_set_rx_mode,
-	.ndo_set_mac_address = pxa168_eth_set_mac_address,
-	.ndo_validate_addr = eth_validate_addr,
-	.ndo_do_ioctl = pxa168_eth_do_ioctl,
-	.ndo_change_mtu = pxa168_eth_change_mtu,
-	.ndo_tx_timeout = pxa168_eth_tx_timeout,
+	.ndo_open		= pxa168_eth_open,
+	.ndo_stop		= pxa168_eth_stop,
+	.ndo_start_xmit		= pxa168_eth_start_xmit,
+	.ndo_set_rx_mode	= pxa168_eth_set_rx_mode,
+	.ndo_set_mac_address	= pxa168_eth_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= pxa168_eth_do_ioctl,
+	.ndo_change_mtu		= pxa168_eth_change_mtu,
+	.ndo_tx_timeout		= pxa168_eth_tx_timeout,
 };
 
 static int pxa168_eth_probe(struct platform_device *pdev)
@@ -1456,8 +1455,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 
 	clk = clk_get(&pdev->dev, "MFUCLK");
 	if (IS_ERR(clk)) {
-		printk(KERN_ERR "%s: Fast Ethernet failed to get clock\n",
-			DRIVER_NAME);
+		dev_err(&pdev->dev, "Fast Ethernet failed to get clock\n");
 		return -ENODEV;
 	}
 	clk_enable(clk);
@@ -1492,7 +1490,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 
 	INIT_WORK(&pep->tx_timeout_task, pxa168_eth_tx_timeout_task);
 
-	printk(KERN_INFO "%s:Using random mac address\n", DRIVER_NAME);
+	dev_info(&pdev->dev, "Using random mac address\n");
 	eth_hw_addr_random(dev);
 
 	pep->pd = dev_get_platdata(&pdev->dev);
-- 
1.9.1
