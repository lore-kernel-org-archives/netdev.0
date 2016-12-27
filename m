From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 14/16] net: mvpp2: adapt rxq distribution to PPv2.2
Date: Tue, 27 Dec 2016 17:54:35 +0100
Message-ID: <1482857677-16166-15-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36724 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933190AbcL0Qyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:50 -0500
In-Reply-To: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In PPv2.1, we have a maximum of 8 RXQs per port, with a default of 4
RXQs per port, and we were assigning RXQs 0->3 to the first port, 4->7
to the second port, 8->11 to the third port, etc.

In PPv2.2, we have a maximum of 32 RXQs per port, and we must allocate
RXQs from the range of 32 RXQs available for each port. So port 0 must
use RXQs in the range 0->31, port 1 in the range 32->63, etc.

This commit adapts the mvpp2 to this difference between PPv2.1 and
PPv2.2:

 - The constant definition MVPP2_MAX_RXQ is replaced by a new field
   'max_port_rxqs' in 'struct mvpp2', which stores the maximum number of
   RXQs per port. This field is initialized during ->probe() depending
   on the IP version.

 - MVPP2_RXQ_TOTAL_NUM is removed, and instead we calculate the total
   number of RXQs by multiplying the number of ports by the maximum of
   RXQs per port. This was anyway used in only one place.

 - In mvpp2_port_probe(), the calculation of port->first_rxq is adjusted
   to cope with the different allocation strategy between PPv2.1 and
   PPv2.2. Due to this change, the 'next_first_rxq' argument of this
   function is no longer needed and is removed.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index baad991..20e9429 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -399,15 +399,9 @@
 /* Maximum number of TXQs used by single port */
 #define MVPP2_MAX_TXQ			8
 
-/* Maximum number of RXQs used by single port */
-#define MVPP2_MAX_RXQ			8
-
 /* Dfault number of RXQs in use */
 #define MVPP2_DEFAULT_RXQ		4
 
-/* Total number of RXQs available to all ports */
-#define MVPP2_RXQ_TOTAL_NUM		(MVPP2_MAX_PORTS * MVPP2_MAX_RXQ)
-
 /* Max number of Rx descriptors */
 #define MVPP2_MAX_RXD			128
 
@@ -728,6 +722,9 @@ struct mvpp2 {
 
 	/* HW version */
 	enum { MVPP21, MVPP22 } hw_version;
+
+	/* Maximum number of RXQs per port */
+	unsigned int max_port_rxqs;
 };
 
 struct mvpp2_pcpu_stats {
@@ -6333,7 +6330,8 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	struct mvpp2_txq_pcpu *txq_pcpu;
 	int queue, cpu, err;
 
-	if (port->first_rxq + rxq_number > MVPP2_RXQ_TOTAL_NUM)
+	if (port->first_rxq + rxq_number >
+	    MVPP2_MAX_PORTS * priv->max_port_rxqs)
 		return -EINVAL;
 
 	/* Disable port */
@@ -6452,8 +6450,7 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 /* Ports initialization */
 static int mvpp2_port_probe(struct platform_device *pdev,
 			    struct device_node *port_node,
-			    struct mvpp2 *priv,
-			    int *next_first_rxq)
+			    struct mvpp2 *priv)
 {
 	struct device_node *phy_node;
 	struct mvpp2_port *port;
@@ -6511,7 +6508,11 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 
 	port->priv = priv;
 	port->id = id;
-	port->first_rxq = *next_first_rxq;
+	if (priv->hw_version == MVPP21)
+		port->first_rxq = port->id * rxq_number;
+	else
+		port->first_rxq = port->id * priv->max_port_rxqs;
+
 	port->phy_node = phy_node;
 	port->phy_interface = phy_mode;
 
@@ -6608,8 +6609,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	}
 	netdev_info(dev, "Using %s mac address %pM\n", mac_from, dev->dev_addr);
 
-	/* Increment the first Rx queue number to be used by the next port */
-	*next_first_rxq += rxq_number;
 	priv->port_list[id] = port;
 	return 0;
 
@@ -6755,7 +6754,7 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	u32 val;
 
 	/* Checks for hardware constraints */
-	if (rxq_number % 4 || (rxq_number > MVPP2_MAX_RXQ) ||
+	if (rxq_number % 4 || (rxq_number > priv->max_port_rxqs) ||
 	    (txq_number > MVPP2_MAX_TXQ)) {
 		dev_err(&pdev->dev, "invalid queue size parameter\n");
 		return -EINVAL;
@@ -6844,7 +6843,7 @@ static int mvpp2_probe(struct platform_device *pdev)
 	struct device_node *port_node;
 	struct mvpp2 *priv;
 	struct resource *res;
-	int port_count, first_rxq, cpu;
+	int port_count, cpu;
 	int err;
 
 	priv = devm_kzalloc(&pdev->dev, sizeof(struct mvpp2), GFP_KERNEL);
@@ -6879,6 +6878,11 @@ static int mvpp2_probe(struct platform_device *pdev)
 		priv->cpu_base[cpu] = priv->base + cpu * addr_space_sz;
 	}
 
+	if (priv->hw_version == MVPP21)
+		priv->max_port_rxqs = 8;
+	else
+		priv->max_port_rxqs = 32;
+
 	priv->pp_clk = devm_clk_get(&pdev->dev, "pp_clk");
 	if (IS_ERR(priv->pp_clk))
 		return PTR_ERR(priv->pp_clk);
@@ -6921,9 +6925,8 @@ static int mvpp2_probe(struct platform_device *pdev)
 	}
 
 	/* Initialize ports */
-	first_rxq = 0;
 	for_each_available_child_of_node(dn, port_node) {
-		err = mvpp2_port_probe(pdev, port_node, priv, &first_rxq);
+		err = mvpp2_port_probe(pdev, port_node, priv);
 		if (err < 0)
 			goto err_gop_clk;
 	}
-- 
2.7.4
