From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2.6.29] ucc_geth: Fix oops when using fixed-link support
Date: Sat, 21 Mar 2009 01:34:17 +0300
Message-ID: <20090320223417.GA20018@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Li Yang <leoli@freescale.com>,
	Haiying Wang <Haiying.Wang@freescale.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:42036 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752988AbZCTWeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 18:34:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b1c4a9dddf09fe99b8f88252718ac5b357363dc4 ("ucc_geth: Change
uec phy id to the same format as gianfar's") introduced a regression
in the ucc_geth driver that causes this oops when fixed-link is used:

Unable to handle kernel paging request for data at address 0x00000000
Faulting instruction address: 0xc0151270
Oops: Kernel access of bad area, sig: 11 [#1]
TMCUTU
NIP: c0151270 LR: c0151270 CTR: c0017760
REGS: cf81fa60 TRAP: 0300   Not tainted  (2.6.29-rc8)
MSR: 00009032 <EE,ME,IR,DR>  CR: 24024042  XER: 20000000
DAR: 00000000, DSISR: 20000000
TASK = cf81cba0[1] 'swapper' THREAD: cf81e000
GPR00: c0151270 cf81fb10 cf81cba0 00000000 c0272e20 c025f354 00001e80
cf86b08c
GPR08: d1068200 cffffb74 06000000 d106c200 42024042 10085148 0fffd000
0ffc81a0
GPR16: 00000001 00000001 00000000 007ffeb0 00000000 0000c000 cf83f36c
cf83f000
GPR24: 00000030 cf83f360 cf81fb20 00000000 d106c200 20000000 00001e80
cf83f360
NIP [c0151270] ucc_geth_open+0x330/0x1efc
LR [c0151270] ucc_geth_open+0x330/0x1efc
Call Trace:
[cf81fb10] [c0151270] ucc_geth_open+0x330/0x1efc (unreliable)
[cf81fba0] [c0187638] dev_open+0xbc/0x12c
[cf81fbc0] [c0187e38] dev_change_flags+0x8c/0x1b0

This patch fixes the issue by removing offending (and somewhat
duplicate) code from init_phy() routine, and changes _probe()
function to use uec_mdio_bus_name().

Also, since we fully construct phy_bus_id in the _probe() routine,
we no longer need ->phy_address and ->mdio_bus fields in
ucc_geth_info structure.

I wish the patch would be a bit shorter, but it seems like the only
way to fix the issue in a sane way. Luckily, the patch has been
tested with real PHYs and fixed-link, so no further regressions
expected.

Reported-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Tested-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

On Fri, Mar 20, 2009 at 09:46:13PM +0100, Joakim Tjernlund wrote:
[...]
> > I would suggest something along these lines (unfortunately
> > right now I can't test it on real HW, only compile-tested):
> 
> Tested here, works fine for fixed-link PHYs, thanks.
> I left the 
>     priv->oldlink = 0;
>     priv->oldspeed = 0;
>     priv->oldduplex = -1;
> in though. Seemed like a good idea.

Yeah, good catch.

> Tested By: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Thanks!

I found a QE board to test this patch, so now we have real PHY
and fixed-links known to work.

 drivers/net/ucc_geth.c |   34 ++++++++++------------------------
 drivers/net/ucc_geth.h |    3 +--
 2 files changed, 11 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e879868..1f61e42 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1536,32 +1536,15 @@ static void adjust_link(struct net_device *dev)
 static int init_phy(struct net_device *dev)
 {
 	struct ucc_geth_private *priv = netdev_priv(dev);
-	struct device_node *np = priv->node;
-	struct device_node *phy, *mdio;
-	const phandle *ph;
-	char bus_name[MII_BUS_ID_SIZE];
-	const unsigned int *id;
+	struct ucc_geth_info *ug_info = priv->ug_info;
 	struct phy_device *phydev;
-	char phy_id[BUS_ID_SIZE];
 
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	ph = of_get_property(np, "phy-handle", NULL);
-	phy = of_find_node_by_phandle(*ph);
-	mdio = of_get_parent(phy);
-
-	id = of_get_property(phy, "reg", NULL);
-
-	of_node_put(phy);
-	of_node_put(mdio);
-
-	uec_mdio_bus_name(bus_name, mdio);
-	snprintf(phy_id, sizeof(phy_id), "%s:%02x",
-                                bus_name, *id);
-
-	phydev = phy_connect(dev, phy_id, &adjust_link, 0, priv->phy_interface);
+	phydev = phy_connect(dev, ug_info->phy_bus_id, &adjust_link, 0,
+			     priv->phy_interface);
 
 	if (IS_ERR(phydev)) {
 		printk("%s: Could not attach to PHY\n", dev->name);
@@ -3629,10 +3612,12 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
 	fixed_link = of_get_property(np, "fixed-link", NULL);
 	if (fixed_link) {
-		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "0");
-		ug_info->phy_address = fixed_link[0];
+		snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_id),
+			 PHY_ID_FMT, "0", fixed_link[0]);
 		phy = NULL;
 	} else {
+		char bus_name[MII_BUS_ID_SIZE];
+
 		ph = of_get_property(np, "phy-handle", NULL);
 		phy = of_find_node_by_phandle(*ph);
 
@@ -3643,7 +3628,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		prop = of_get_property(phy, "reg", NULL);
 		if (prop == NULL)
 			return -1;
-		ug_info->phy_address = *prop;
 
 		/* Set the bus id */
 		mdio = of_get_parent(phy);
@@ -3657,7 +3641,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		if (err)
 			return -1;
 
-		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "%x", res.start);
+		uec_mdio_bus_name(bus_name, mdio);
+		snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_id),
+			"%s:%02x", bus_name, *prop);
 	}
 
 	/* get the phy interface type, or default to MII */
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 16cbe42..611bdef 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1091,8 +1091,7 @@ struct ucc_geth_info {
 	u32 eventRegMask;
 	u16 pausePeriod;
 	u16 extensionField;
-	u8 phy_address;
-	char mdio_bus[MII_BUS_ID_SIZE];
+	char phy_bus_id[BUS_ID_SIZE];
 	u8 weightfactor[NUM_TX_QUEUES];
 	u8 interruptcoalescingmaxvalue[NUM_RX_QUEUES];
 	u8 l2qt[UCC_GETH_VLAN_PRIORITY_MAX];
-- 
1.5.6.5
