From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v2 3/4] net: mvneta: get optional axi clk
Date: Wed, 20 Jan 2016 17:20:21 +0800
Message-ID: <1453281622-7829-4-git-send-email-jszhang@marvell.com>
References: <1453281622-7829-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, devicetree@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
 <mw@semihalf.com>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1453281622-7829-1-git-send-email-jszhang@marvell.com>
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

Some platforms may provide more than one clk for the mvneta IP, for
example Marvell BG4CT provides "core" clk for the mac core, and
"axi" clk for the AXI bus logic. Obviously this "axi" clk also need to
be enabled. This patch adds this optional "axi" clk support.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 736a9ec..ca25933 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -373,6 +373,8 @@ struct mvneta_port {
 
 	/* Core clock */
 	struct clk *clk;
+	/* AXI clock */
+	struct clk *clk_axi;
 	u8 mcast_count[256];
 	u16 tx_ring_size;
 	u16 rx_ring_size;
@@ -3615,6 +3617,10 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(pp->clk);
 
+	pp->clk_axi = devm_clk_get(&pdev->dev, "axi");
+	if (!IS_ERR(pp->clk_axi))
+		clk_prepare_enable(pp->clk_axi);
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	pp->base = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(pp->base)) {
@@ -3726,6 +3732,7 @@ err_free_stats:
 err_free_ports:
 	free_percpu(pp->ports);
 err_clk:
+	clk_disable_unprepare(pp->clk_axi);
 	clk_disable_unprepare(pp->clk);
 err_put_phy_node:
 	of_node_put(phy_node);
@@ -3743,6 +3750,7 @@ static int mvneta_remove(struct platform_device *pdev)
 	struct mvneta_port *pp = netdev_priv(dev);
 
 	unregister_netdev(dev);
+	clk_disable_unprepare(pp->clk_axi);
 	clk_disable_unprepare(pp->clk);
 	free_percpu(pp->ports);
 	free_percpu(pp->stats);
-- 
2.7.0.rc3
