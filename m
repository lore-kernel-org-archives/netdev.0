From: Heiko Schocher <hs@denx.de>
Subject: Re: powerpc, fs_enet: scanning PHY after Linux is up
Date: Wed, 06 Oct 2010 11:53:51 +0200
Message-ID: <4CAC472F.5070001@denx.de>
References: <4CA9830A.2030605@denx.de>
 <AANLkTinSersREjDnvg=8Gvpa6YmLuzgF1H8eEXRyCpW0@mail.gmail.com>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Holger Brunck <holger.brunck@keymile.com>,
	Detlev Zundel <dzu@denx.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.relay.invitel.net ([62.77.203.3]:50970 "EHLO
	a.relay.invitel.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab0JFJyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 05:54:01 -0400
In-reply-to: <AANLkTinSersREjDnvg=8Gvpa6YmLuzgF1H8eEXRyCpW0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Grant,

Thanks for your answer!

Grant Likely wrote:
> On Mon, Oct 4, 2010 at 1:32 AM, Heiko Schocher <hs@denx.de> wrote:
>> Hello all,
>>
>> we have on the mgcoge arch/powerpc/boot/dts/mgcoge.dts 3 fs_enet
>> devices. The first is accessible on boot, and so get correct
>> probed and works fine. For the other two fs_enet devices the PHYs
>> are on startup in reset, and gets later, through userapplikations,
>> out of reset ... so, on bootup, this 2 fs_enet devices could
>> not detect the PHY in drivers/of/of_mdio.c of_mdiobus_register(),
>> and if we want to use them later, we get for example:
>>
>> -bash-3.2# ifconfig eth2 172.31.31.33
>> net eth2: Could not attach to PHY
>> SIOCSIFFLAGS: No such device
>>
>> So the problem is, that we cannot rescan the PHYs, if they are
>> accessible. Also we could not load the fs_enet driver as a module,
>> because the first port is used fix.
>>
>> So, first question which comes in my mind, is:
>>
>> Is detecting the phy in drivers/of/of_mdio.c of_mdiobus_register()
>> the right place, or should it not better be done, when really
>> using the port?
>>
>> But we found another way to solve this issue:
>>
>> After the PHYs are out of reset, we just have to rescan the PHYs
>> with (for example PHY with addr 1)
>>
>> err = mdiobus_scan(bus, 1);
>>
>> and
>>
>> of_find_node_by_path("/soc@f0000000/cpm@119c0/mdio@10d40/ethernet-phy@1");
>> of_node_get(np);
>> dev_archdata_set_node(&err->dev.archdata, np);
>>
>> but thats just a hack ...
> 
> Yeah, that's a hack.  It really needs to be done via the of_mdio
> mechanisms so that dt <--> phy_device linkages remain consistent.

Yep, I know, thats the reason why I ask ;-)

>> So, the question is, is there a possibility to solve this problem?
>>
>> If there is no standard option, what would be with adding a
>> "scan_phy" file in
>>
>> /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40
>> (or better destination?)
>>
>> which with we could rescan a PHY with
>> "echo addr > /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40/scan_phy"
>> (so there is no need for using of_find_node_by_path(), as we should
>>  have the associated device node here, and can step through the child
>>  nodes with "for_each_child_of_node(np, child)" and check if reg == addr)
>>
>> or shouldn;t be at least, if the phy couldn;t be found when opening
>> the port, retrigger a scanning, if the phy now is accessible?
> 
> One option would be to still register a phy_device for each phy
> described in the device tree, but defer binding a driver to each phy
> that doesn't respond.  Then at of_phy_find_device() time, if it

Maybe I din;t get the trick, but the problem is, that
you can;t register a phy_device in drivers/of/of_mdio.c
of_mdiobus_register(), if the phy didn;t respond with the
phy_id ... and of_phy_find_device() is not (yet) used in fs_enet

> matches with a phy_device that isn't bound to a driver yet, then
> re-trigger the binding operation.  At which point the phy id can be
> probed and the correct driver can be chosen.  If binding succeeds,
> then return the phy_device handle.  If not, then fail as it currently
> does.

Wouldn;t it be good, just if we need a PHY (on calling fs_enet_open)
to look if there is one?

Something like that (not tested):

in drivers/net/fs_enet/fs_enet-main.c in fs_init_phy()
called from fs_enet_open():

Do first:
phydev =  of_phy_find_device(fep->fpi->phy_node);

Look if there is a driver (phy_dev->drv == NULL ?)

If not, call new function
of_mdiobus_register_phy(mii_bus, fep->fpi->phy_node)
see below patch for it.

If this succeeds, all is OK, and we can use this phy,
else ethernet not work.

!!just no idea, how to get mii_bus pointer ...

here the patch for the new function of_mdiobus_register_phy():

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index b474833..7afbb0b 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -21,6 +21,51 @@
 MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
 MODULE_LICENSE("GPL");

+int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child)
+{
+	struct phy_device *phy;
+	const __be32 *addr;
+	int len;
+	int rc;
+
+	/* A PHY must have a reg property in the range [0-31] */
+	addr = of_get_property(child, "reg", &len);
+	if (!addr || len < sizeof(*addr) || *addr >= 32 || *addr < 0) {
+		dev_err(&mdio->dev, "%s has invalid PHY address\n",
+			child->full_name);
+		return -1;
+	}
+
+	if (mdio->irq) {
+		mdio->irq[*addr] = irq_of_parse_and_map(child, 0);
+		if (!mdio->irq[*addr])
+			mdio->irq[*addr] = PHY_POLL;
+	}
+
+	phy = get_phy_device(mdio, be32_to_cpup(addr));
+	if (!phy || IS_ERR(phy)) {
+		dev_err(&mdio->dev, "error probing PHY at address %i\n",
+			*addr);
+		return -2;
+	}
+	phy_scan_fixups(phy);
+	/* Associate the OF node with the device structure so it
+	 * can be looked up later */
+	of_node_get(child);
+	dev_archdata_set_node(&phy->dev.archdata, child);
+
+	/* All data is now stored in the phy struct; register it */
+	rc = phy_device_register(phy);
+	if (rc) {
+		phy_device_free(phy);
+		of_node_put(child);
+		return -3;
+	}
+
+	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
+		child->name, *addr);
+}
+
 /**
  * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
  * @mdio: pointer to mii_bus structure
@@ -31,7 +76,6 @@ MODULE_LICENSE("GPL");
  */
 int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
-	struct phy_device *phy;
 	struct device_node *child;
 	int rc, i;

@@ -51,46 +95,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)

 	/* Loop over the child nodes and register a phy_device for each one */
 	for_each_child_of_node(np, child) {
-		const __be32 *addr;
-		int len;
-
-		/* A PHY must have a reg property in the range [0-31] */
-		addr = of_get_property(child, "reg", &len);
-		if (!addr || len < sizeof(*addr) || *addr >= 32 || *addr < 0) {
-			dev_err(&mdio->dev, "%s has invalid PHY address\n",
-				child->full_name);
-			continue;
-		}
-
-		if (mdio->irq) {
-			mdio->irq[*addr] = irq_of_parse_and_map(child, 0);
-			if (!mdio->irq[*addr])
-				mdio->irq[*addr] = PHY_POLL;
-		}
-
-		phy = get_phy_device(mdio, be32_to_cpup(addr));
-		if (!phy || IS_ERR(phy)) {
-			dev_err(&mdio->dev, "error probing PHY at address %i\n",
-				*addr);
-			continue;
-		}
-		phy_scan_fixups(phy);
-
-		/* Associate the OF node with the device structure so it
-		 * can be looked up later */
-		of_node_get(child);
-		dev_archdata_set_node(&phy->dev.archdata, child);
-
-		/* All data is now stored in the phy struct; register it */
-		rc = phy_device_register(phy);
-		if (rc) {
-			phy_device_free(phy);
-			of_node_put(child);
-			continue;
-		}
-
-		dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
-			child->name, *addr);
+		of_mdiobus_register_phy(mdio, child);
 	}

 	return 0;

With this change, it would work on boot as actual (phy_device_register()
will fail for the PHYs who don;t work when booting).

Later, when opening the ethernet device, fs_init_phy, will look, if
we have a valid phy with driver, if not we try to register it again.
If this is successfull, we can use the device, if not we will fail,
as now ... what do you think?

bye,
Heiko
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
