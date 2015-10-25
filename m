From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/8] net: phy: mdio: add missing of_node_put
Date: Sun, 25 Oct 2015 14:57:03 +0100
Message-ID: <1445781427-7110-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Jason Cooper <jason@lakedaemon.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
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
 drivers/net/phy/mdio-mux-mmioreg.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 2377c13..7fde454 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -113,12 +113,14 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 		if (!iprop || len != sizeof(uint32_t)) {
 			dev_err(&pdev->dev, "mdio-mux child node %s is "
 				"missing a 'reg' property\n", np2->full_name);
+			of_node_put(np2);
 			return -ENODEV;
 		}
 		if (be32_to_cpup(iprop) & ~s->mask) {
 			dev_err(&pdev->dev, "mdio-mux child node %s has "
 				"a 'reg' value with unmasked bits\n",
 				np2->full_name);
+			of_node_put(np2);
 			return -ENODEV;
 		}
 	}

