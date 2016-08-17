From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v8] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 13:03:52 -0700
Message-ID: <e1bdbfa3-c74e-6f08-da36-632224f2bcd9@gmail.com>
References: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
 <db618958-a940-9ea2-ff52-e12c81894ad6@gmail.com>
 <57B4BD40.1070703@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
	mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
	davem@davemloft.net, LinoSanfilippo@gmx.de
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57B4BD40.1070703@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2016 12:38 PM, Timur Tabi wrote:
>> If this is an external PHY, the expectation is that it will be hanging
>> off a MDIO bus controller, either the MDIO bus internal to the MAC, or
>> an external MDIO bus (separate register range).
> 
> So for starters, I forgot to delete the 'compatible' property from this
> document.  Its presence breaks of_mdiobus_child_is_phy().

The MDIO devices and Ethernet PHY binding should certainly be improved,
but the bulk of it is either you use ethernet-phy-ieee802.3-c22 or
ethernet-phy-ieee802.3-c45, or nothing. Else, the MDIO bus probing code
just assumes it can match a MDIO device (not specifically an Ethernet
PHY) with its compatible string.

> 
>> If such a PHY node is provided, the expectation is that your Ethernet
>> MAC will have a phy-handle property and a phy-mode property to specify
>> how to connect to this external PHY, so in your specific case, better
>> remove the PHY from your example, or detail further how it should be
>> done.
> 
> Something is odd about of_mdiobus_register().
> 
> This function scans child nodes to look for PHYs:
> 
> /* Loop over the child nodes and register a phy_device for each phy */
> for_each_available_child_of_node(np, child) {
>     addr = of_mdio_parse_addr(&mdio->dev, child);
> 
> And in my driver, this works.  However, later when I try to call
> of_phy_find_device(), it fails.  That's because of_phy_find_device()
> wants the np of the child node.  But the only way to get that is with a
> phy-phandle property which I need to manually parse.

of_get_phandle() should return the device_node pointer associated with
the phy-handle property which you can later use and pass to
of_phy_find_device(). There are plenty of examples in the tree and the
logic is almost always the same.

> 
> So what's the point of having of_mdiobus_register() parse child nodes,
> if you need a phy-phandle pointer anyway?

Not all MDIO devices are Ethernet PHYs, some of them are Ethernet
switches, or any other PHY (USB, PCIE, SATA) just sitting on the same
MDIO bus HW instance so you need to create device_node and struct device
instances for these deviecs listed in the Device Tree since the bus is
self-discoverable (like I2C).

Your Ethernet controller somehow needs to know which Ethernet PHY it is
attached to since the location of the Ethernet PHY on the bus could
change from design to design, let alone the actual topology (you could
have a GPIO bit-banged MDIO bus or something else).

>> Since you have a check on CONFIG_QCOM_EMAC in emac/Makefile, you could
>> always recurse into that directory while building (use obj-y).
> 
> Obviously, having "obj-$(CONFIG_QCOM_EMAC)" in both Makefiles is
> redundant, but wouldn't it make more sense to change
> "obj-$(CONFIG_QCOM_EMAC)" to "obj-y" in
> drivers/net/ethernet/qualcomm/emac/Makefile, so that I only recurse if
> necessary?

Whichever makes the most sense, when there is a directory involved, my
preference is to always recurse in that directory and selectively
compile from there, since the Kconfig/Makefile options are all located
within the same hierarchical level, just a preference.

> 
>>> >+static void emac_adjust_link(struct net_device *netdev)
>>> >+{
>>> >+    struct emac_adapter *adpt = netdev_priv(netdev);
>>> >+    struct phy_device *phydev = netdev->phydev;
>>> >+
>>> >+    if (phydev->link)
>>> >+        emac_mac_start(adpt);
>>> >+    else
>>> >+        emac_mac_stop(adpt);
> 
>> This is really excessive here, you typically don't need to completely
>> stop your transmitter/receiver/DMA/what have you, just reprogram the MAC
>> with the appropriate link speed/duplex/pause parameters.
> 
> Yes, I realize that a lot of the reinit code in my driver is "heavy",
> and that it could be optimized for specific situations.  However, I'd
> like to save that for another patch, because it would require me to
> study the documentation and do extensive tests.
> 
> I can't tell you today whether emac_mac_start() is overkill for the
> specific link change.  For all I know, the hardware does require the TX
> to stop before changing the link speed.  Remember, the EMAC does have a
> weird double-phy (one internal, one external).

Fair enough, not having to stop the TX from the SW perspective should be
kind of basic requirement here, most drivers/HW don't seem to require
that, because even if packets were inflight at the time the link went
down, the MAC should sense the carrier loss and report that accordingly.
Now there could be many different ways to implement and screw that up,
so yes, future patch seems like a good approach.
-- 
Florian
