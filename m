From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH v2 net-next] ravb: Add fixed-link support
Date: Tue, 15 Dec 2015 19:44:13 +0900
Message-ID: <1450176253-24131-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

This patch adds support of the fixed PHY.
This patch is based on commit 87009814cdbb ("ucc_geth: use the new fixed
PHY helpers").

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's next networking
tree.

v2 [Yoshihiro Kaneko]
* compile tested only
* As suggested by Sergei Shtylyov
  - use of_node_get() to increment refcount.

 drivers/net/ethernet/renesas/ravb_main.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 120cc25..3448eb0 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -882,6 +882,7 @@ static int ravb_phy_init(struct net_device *ndev)
 	struct ravb_private *priv = netdev_priv(ndev);
 	struct phy_device *phydev;
 	struct device_node *pn;
+	int err;
 
 	priv->link = 0;
 	priv->speed = 0;
@@ -889,6 +890,17 @@ static int ravb_phy_init(struct net_device *ndev)
 
 	/* Try connecting to PHY */
 	pn = of_parse_phandle(np, "phy-handle", 0);
+	if (!pn) {
+		/* In the case of a fixed PHY, the DT node associated
+		 * to the PHY is the Ethernet MAC DT node.
+		 */
+		if (of_phy_is_fixed_link(np)) {
+			err = of_phy_register_fixed_link(np);
+			if (err)
+				return err;
+		}
+		pn = of_node_get(np);
+	}
 	phydev = of_phy_connect(ndev, pn, ravb_adjust_link, 0,
 				priv->phy_interface);
 	if (!phydev) {
-- 
1.9.1

