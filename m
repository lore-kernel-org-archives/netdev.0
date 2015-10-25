From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 8/8] net: mv643xx_eth: add missing of_node_put
Date: Sun, 25 Oct 2015 14:57:07 +0100
Message-ID: <1445781427-7110-9-git-send-email-Julia.Lawall@lip6.fr>
References: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Jason Cooper <jason@lakedaemon.net>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

for_each_available_child_of_node performs an of_node_get on each iteration, so
a break out of the loop requires an of_node_put.

A simplified version of the semantic patch that fixes this problem is as
follows (http://coccinelle.lip6.fr):

// <smpl>
@@
expression root,e;
local idexpression child;
@@

 for_each_available_child_of_node(root, child) {
   ... when != of_node_put(child)
       when != e = child
(
   return child;
|
+  of_node_put(child);
?  return ...;
)
   ...
 }
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 603d29d..18ea385 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2785,8 +2785,10 @@ static int mv643xx_eth_shared_of_probe(struct platform_device *pdev)
 
 	for_each_available_child_of_node(np, pnp) {
 		ret = mv643xx_eth_shared_of_add_port(pdev, pnp);
-		if (ret)
+		if (ret) {
+			of_node_put(pnp);
 			return ret;
+		}
 	}
 	return 0;
 }
