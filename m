From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: Fw: [PATCH] ucc_geth: Correct fixed_link OOPS.
Date: Fri, 20 Mar 2009 23:07:40 +0300
Message-ID: <20090320200740.GA32082@oksana.dev.rtsoft.ru>
References: <OF20EA88BB.017079CD-ONC125757F.006C40A2-C125757F.006C646E@transmode.se>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:41759 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751870AbZCTUHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 16:07:43 -0400
Content-Disposition: inline
In-Reply-To: <OF20EA88BB.017079CD-ONC125757F.006C40A2-C125757F.006C646E@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 08:43:56PM +0100, Joakim Tjernlund wrote:
> hmm, this mail didn't seem to reach the lists. Resending
> 
>  Jocke
> ----- Forwarded by Joakim Tjernlund/Transmode on 20/03/2009 20:42 -----
> 
> From:
> Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> To:
> leoli@freescale.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
> Cc:
> Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date:
> 20/03/2009 18:01
> Subject:
> [PATCH] ucc_geth: Correct fixed_link OOPS.
> 
> 
> 
> fixed_link(PHY less) mode will get you an NULL
> deference as it does not have a phy-handle.
> Correct by using already probed information.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
> The below fixes the problem and seems like the right thing to do.
> Can we have this in 2.6.29?
> 
>  drivers/net/ucc_geth.c |   17 +----------------
>  1 files changed, 1 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index dc2f8f2..12e5c3d 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -1536,11 +1536,6 @@ static void adjust_link(struct net_device *dev)
>  static int init_phy(struct net_device *dev)
>  {
>                  struct ucc_geth_private *priv = netdev_priv(dev);
> -                struct device_node *np = priv->node;
> -                struct device_node *phy, *mdio;
> -                const phandle *ph;
> -                char bus_name[MII_BUS_ID_SIZE];
> -                const unsigned int *id;
>                  struct phy_device *phydev;
>                  char phy_id[BUS_ID_SIZE];
>  
> @@ -1548,18 +1543,8 @@ static int init_phy(struct net_device *dev)
>                  priv->oldspeed = 0;
>                  priv->oldduplex = -1;
>  
> -                ph = of_get_property(np, "phy-handle", NULL);
> -                phy = of_find_node_by_phandle(*ph);
> -                mdio = of_get_parent(phy);
> -
> -                id = of_get_property(phy, "reg", NULL);
> -
> -                of_node_put(phy);
> -                of_node_put(mdio);
> -
> -                uec_mdio_bus_name(bus_name, mdio);
>                  snprintf(phy_id, sizeof(phy_id), "%s:%02x",
> -                                bus_name, *id);
> +                                 priv->ug_info->mdio_bus, 
> priv->ug_info->phy_address);
>  
>                  phydev = phy_connect(dev, phy_id, &adjust_link, 0, 
> priv->phy_interface);

This effectivly breaks boards where Gianfar is using UCC's MDIO
bus (i.e. breaks commit b1c4a9dddf09fe99b8f88252718ac5b357363dc4,
which is the cause of fixed-link breakage, btw). And, your patch
is line-wrapped and tabs are substituted by white spaces...

I would suggest something along these lines (unfortunately
right now I can't test it on real HW, only compile-tested):


diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e879868..58b78ed 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1536,32 +1536,11 @@ static void adjust_link(struct net_device *dev)
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
-
-	priv->oldlink = 0;
-	priv->oldspeed = 0;
-	priv->oldduplex = -1;
-
-	ph = of_get_property(np, "phy-handle", NULL);
-	phy = of_find_node_by_phandle(*ph);
-	mdio = of_get_parent(phy);
-
-	id = of_get_property(phy, "reg", NULL);
 
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
@@ -3629,10 +3608,12 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
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
 
@@ -3643,7 +3624,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		prop = of_get_property(phy, "reg", NULL);
 		if (prop == NULL)
 			return -1;
-		ug_info->phy_address = *prop;
 
 		/* Set the bus id */
 		mdio = of_get_parent(phy);
@@ -3657,7 +3637,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
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
