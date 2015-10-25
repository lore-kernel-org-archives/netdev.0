From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/8] net: netcp: add missing of_node_put
Date: Sun, 25 Oct 2015 14:57:01 +0100
Message-ID: <1445781427-7110-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Murali Karicheri <m-karicheri2@ti.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Jason Cooper <jason@lakedaemon.net>
To: Wingman Kwok <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445781427-7110-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

for_each_child_of_node performs an of_node_get on each iteration, so
a break out of the loop requires an of_node_put.

A simplified version of the semantic patch that fixes this problem is as
follows (http://coccinelle.lip6.fr):

// <smpl>
@@
local idexpression r.n;
expression r,e;
@@

 for_each_child_of_node(r,n) {
   ...
(
   of_node_put(n);
|
   e = n
|
+  of_node_put(n);
?  break;
)
   ...
 }
... when != n
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/ti/netcp_ethss.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 6bff8d8..4e70e75 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2637,8 +2637,10 @@ static void init_secondary_ports(struct gbe_priv *gbe_dev,
 			mac_phy_link = true;
 
 		slave->open = true;
-		if (gbe_dev->num_slaves >= gbe_dev->max_num_slaves)
+		if (gbe_dev->num_slaves >= gbe_dev->max_num_slaves) {
+			of_node_put(port);
 			break;
+		}
 	}
 
 	/* of_phy_connect() is needed only for MAC-PHY interface */
@@ -3137,8 +3139,10 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 			continue;
 		}
 		gbe_dev->num_slaves++;
-		if (gbe_dev->num_slaves >= gbe_dev->max_num_slaves)
+		if (gbe_dev->num_slaves >= gbe_dev->max_num_slaves) {
+			of_node_put(interface);
 			break;
+		}
 	}
 	of_node_put(interfaces);
 
