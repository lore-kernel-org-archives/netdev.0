From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [RFC 2/2] net: emac: add support for device-tree based PHY discovery and setup
Date: Sun, 19 Feb 2017 15:44:28 +0100
Message-ID: <3297010.C0QBqU6b2f@debian64>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com> <2409103.Lage0nq55N@debian64> <20170215142308.GB10670@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        Christian Lamparter <chunkeey@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36544 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751208AbdBSOql (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 09:46:41 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so10159635wmd.3
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 06:46:40 -0800 (PST)
In-Reply-To: <20170215142308.GB10670@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, February 15, 2017 3:23:08 PM CET Andrew Lunn wrote:
> > > > Is the PHY just powered down by chance (BMCR_PWRDN set?) and resetting
> > > > it implicitly clears the power down that seems to be what is going on.
> > > 
> > > Yes, the PHY is just in the BMCR_PDOWN state. I can do the same
> > > on the WNDR4700, by messing with u-boot:
> 
> Hi Christian
> 
> What happens if you list the PHYs in the device tree, with their PHY
> ID. That should avoid it looking for the ID and getting 0xffff
> back. It should just probe the correct PHY driver. If the first thing
> the drivers probe function does it reset the power down bit, it might
> work.

I just tested it. And it didn't work (Same result/error).

It fails because the PHYs on the dsa slave-bus are not detected via the
device tree method. See <http://lxr.free-electrons.com/source/net/dsa/dsa2.c#L322>

|315         if (!ds->slave_mii_bus && ds->ops->phy_read) {
|316                 ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
|317                 if (!ds->slave_mii_bus)
|318                         return -ENOMEM;
|319 
|320                 dsa_slave_mii_bus_init(ds);
|321 
|322                 err = mdiobus_register(ds->slave_mii_bus);
|323                 if (err < 0)
|324                         return err;
|325         }

You see that dsa2 just calls mdiobus_register() which will do the
PHY discovery with mdiobus_scan() 
<http://lxr.free-electrons.com/source/drivers/net/phy/mdio_bus.c#L335>
which relys on the values from MII_PHYSID1 and MII_PHYSID2.

In order to get it work, this mdiobus_register would need to be
replaced with of_mdiobus_register().

---
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 737be6470c7f..5a90ec81040f 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -18,6 +18,7 @@
 #include <net/dsa.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
+#include <linux/of_mdio.h>
 #include "dsa_priv.h"
 
 static LIST_HEAD(dsa_switch_trees);
@@ -288,7 +289,8 @@ static void dsa_user_port_unapply(struct dsa_port *port, u32 index,
 	}
 }
 
-static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
+static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds,
+			struct device_node *ports)
 {
 	struct dsa_port *port;
 	u32 index;
@@ -322,7 +324,10 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 
 		dsa_slave_mii_bus_init(ds);
 
-		err = mdiobus_register(ds->slave_mii_bus);
+		if (!ports)
+			err = mdiobus_register(ds->slave_mii_bus);
+		else
+			err = of_mdiobus_register(ds->slave_mii_bus, ports);
 		if (err < 0)
 			return err;
 	}
@@ -383,7 +388,8 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	dsa_switch_unregister_notifier(ds);
 }
 
-static int dsa_dst_apply(struct dsa_switch_tree *dst)
+static int dsa_dst_apply(struct dsa_switch_tree *dst,
+			 struct device_node *ports)
 {
 	struct dsa_switch *ds;
 	u32 index;
@@ -394,7 +400,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 		if (!ds)
 			continue;
 
-		err = dsa_ds_apply(dst, ds);
+		err = dsa_ds_apply(dst, ds, ports);
 		if (err)
 			return err;
 	}
@@ -649,7 +655,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	struct dsa_chip_data *pdata = dev->platform_data;
 	struct device_node *np = dev->of_node;
 	struct dsa_switch_tree *dst;
-	struct device_node *ports;
+	struct device_node *ports = NULL;
 	u32 tree, index;
 	int i, err;
 
@@ -722,7 +728,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 		goto out_del_dst;
 	}
 
-	err = dsa_dst_apply(dst);
+	err = dsa_dst_apply(dst, ports);
 	if (err) {
 		dsa_dst_unapply(dst);
 		goto out_del_dst;
---

With this patch applied, the device discovery works as intended:


| [    4.514106] Generic PHY 4ef600c00.ethern:00: attached PHY driver [Generic PHY] (mii_bus:phy_addr=4ef600c00.ethern:00, irq=-1)
|[    4.525975] Generic PHY dsa-0.0:01: attached PHY driver [Generic PHY] (mii_bus:phy_addr=dsa-0.0:01, irq=-1)
|[    4.536269] Generic PHY dsa-0.0:02: attached PHY driver [Generic PHY] (mii_bus:phy_addr=dsa-0.0:02, irq=-1)
|[    4.546562] Generic PHY dsa-0.0:03: attached PHY driver [Generic PHY] (mii_bus:phy_addr=dsa-0.0:03, irq=-1)
|[    4.556887] Generic PHY dsa-0.0:04: attached PHY driver [Generic PHY] (mii_bus:phy_addr=dsa-0.0:04, irq=-1)

>From what I can tell, the PHY works. Although it will ping-pong for a bit:
|[  170.463823] qca8k 4ef600c00.ethern:10 lan1: Link is Down
|[  172.511860] qca8k 4ef600c00.ethern:10 lan1: Link is Up - 1Gbps/Full - flow control rx/tx
|[  174.559823] qca8k 4ef600c00.ethern:10 lan1: Link is Down
|[  175.583853] qca8k 4ef600c00.ethern:10 lan1: Link is Up - 1Gbps/Full - flow control rx/tx
|[  179.679816] qca8k 4ef600c00.ethern:10 lan1: Link is Down
|[  182.751846] qca8k 4ef600c00.ethern:10 lan1: Link is Up - 1Gbps/Full - flow control rx/tx
|[  186.847834] qca8k 4ef600c00.ethern:10 lan1: Link is Down
|[  188.895847] qca8k 4ef600c00.ethern:10 lan1: Link is Up - 1Gbps/Full - flow control rx/tx
(But it will stay up).


As for the patch. It's a bit cheesy because it forces you to specify the
compatible property on the "dsa_slave_bus":

| mdio {
|	#address-cells = <1>;
|	#size-cells = <0>;
|  ...
|  phy_port2: phy@1 { /* this phy is PDOWNed */
|		compatible = "ethernet-phy-id004d.d034", "ethernet-phy-ieee802.3-c22";
|		^^ this is ignored!
|		reg = <1>;
|	};
|  ...
|	switch0@16 {
|		compatible = "qca,qca8337";
|		#address-cells = <1>;
|		#size-cells = <0>;
|		reg = <16>;
|      ports {
|			#address-cells = <1>;
|			#size-cells = <0>;
|				...
|				port@2 {
|					compatible = "ethernet-phy-id004d.d034", "ethernet-phy-ieee802.3-c22";
|					// ^^ This compatible string is parsed. However of_mdiobus_register()
|					// should look up the ignored compatible string from the phy_handle
|					// property down below.
|					phy-handle = <&phy_port2>;
|					// ^^ since this is the real device on the mdiobus. And this is going
|					// to be tricky since the switch itself it there as well.
|					reg = <1>;
|					label = "lan3";
|				};
|		...
|		};

So, anyone: What would be a good solution for this?

Thanks,
Christian
