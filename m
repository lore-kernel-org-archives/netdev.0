From: "David Rivshin (Allworx)" <drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net v2 3/3] drivers: net: cpsw: use of_phy_connect() in fixed-link case
Date: Thu, 21 Apr 2016 14:41:06 -0400
Message-ID: <1461264066-12358-1-git-send-email-drivshin.allworx@gmail.com>
References: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
	Andrew Goodbody <andrew.goodbody-nYQdZkeIoGZN8Ch2cx6nig@public.gmane.org>,
	Markus Brunner <systemprogrammierung.brunner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nicolas Chauvet <kwizart-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461261035-5578-1-git-send-email-drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>

If a fixed-link DT subnode is used, the phy_device was looked up so
that a PHY ID string could be constructed and passed to phy_connect().
This is not necessary, as the device_node can be passed directly to
of_phy_connect() instead. This reuses the same codepath as if the
phy-handle DT property was used.

Signed-off-by: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>
Tested-by: Nicolas Chauvet <kwizart-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

Changes since v1 [1]:
- Rebased (trivial conflict, e5a03bfd modified the deleted snprintf)
- Added Tested-by from Nicolas Chauvet

[1] https://patchwork.ozlabs.org/patch/560327/


 drivers/net/ethernet/ti/cpsw.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3c81413..245f919 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2038,30 +2038,21 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 							"phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (slave_data->phy_node) {
 			dev_dbg(&pdev->dev,
 				"slave[%d] using phy-handle=\"%s\"\n",
 				i, slave_data->phy_node->full_name);
 		} else if (of_phy_is_fixed_link(slave_node)) {
-			struct device_node *phy_node;
-			struct phy_device *phy_dev;
-
 			/* In the case of a fixed PHY, the DT node associated
 			 * to the PHY is the Ethernet MAC DT node.
 			 */
 			ret = of_phy_register_fixed_link(slave_node);
 			if (ret)
 				return ret;
-			phy_node = of_node_get(slave_node);
-			phy_dev = of_phy_find_device(phy_node);
-			if (!phy_dev)
-				return -ENODEV;
-			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, phy_dev->mdio.bus->id,
-				 phy_dev->mdio.addr);
+			slave_data->phy_node = of_node_get(slave_node);
 		} else if (parp) {
 			u32 phyid;
 			struct device_node *mdio_node;
 			struct platform_device *mdio;
 
 			if (lenp != (sizeof(__be32) * 2)) {
 				dev_err(&pdev->dev, "Invalid slave[%d] phy_id property\n", i);
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
