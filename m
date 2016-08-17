From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v8] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 14:38:40 -0500
Message-ID: <57B4BD40.1070703@codeaurora.org>
References: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
 <db618958-a940-9ea2-ff52-e12c81894ad6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
	mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
	davem@davemloft.net, LinoSanfilippo@gmx.de
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <db618958-a940-9ea2-ff52-e12c81894ad6@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> On 08/11/2016 02:34 PM, Timur Tabi wrote:
>> >Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
>> >This driver supports the following features:
>> >1) Checksum offload.
>> >2) Interrupt coalescing support.
>> >3) SGMII phy.
>> >4) phylib interface for external phy

> OK, so this is looking good now, just a few nits, feel free to submit as
> clean up patches, would this one be accepted.

I will post a v9.

>> >+soc {
>> >+	#address-cells = <1>;
>> >+	#size-cells = <1>;
>> >+	dma-ranges = <0 0 0xffffffff>;
>> >+
>> >+	emac0: ethernet@feb20000 {
>> >+		compatible = "qcom,fsm9900-emac";
>> >+		#address-cells = <1>;
>> >+		#size-cells = <1>;
>> >+		reg-names = "base", "csr", "ptp", "sgmii";
>> >+		reg =   <0xfeb20000 0x10000>,
>> >+			<0xfeb36000 0x1000>,
>> >+			<0xfeb3c000 0x4000>,
>> >+			<0xfeb38000 0x400>;
>> >+		interrupt-parent = <&emac0>;
>> >+		#interrupt-cells = <1>;
>> >+		interrupts = <76 80>;
>> >+		interrupt-names = "emac_core0", "sgmii_irq";
>> >+		phy0: ethernet-phy@0 {
>> >+			compatible = "qcom,fsm9900-emac-phy";
>> >+			reg = <0>;
>> >+		}

> If this is an external PHY, the expectation is that it will be hanging
> off a MDIO bus controller, either the MDIO bus internal to the MAC, or
> an external MDIO bus (separate register range).

So for starters, I forgot to delete the 'compatible' property from this 
document.  Its presence breaks of_mdiobus_child_is_phy().

> If such a PHY node is provided, the expectation is that your Ethernet
> MAC will have a phy-handle property and a phy-mode property to specify
> how to connect to this external PHY, so in your specific case, better
> remove the PHY from your example, or detail further how it should be done.

Something is odd about of_mdiobus_register().

This function scans child nodes to look for PHYs:

/* Loop over the child nodes and register a phy_device for each phy */
for_each_available_child_of_node(np, child) {
	addr = of_mdio_parse_addr(&mdio->dev, child);

And in my driver, this works.  However, later when I try to call 
of_phy_find_device(), it fails.  That's because of_phy_find_device() 
wants the np of the child node.  But the only way to get that is with a 
phy-phandle property which I need to manually parse.

So what's the point of having of_mdiobus_register() parse child nodes, 
if you need a phy-phandle pointer anyway?

>> >diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
>> >index a76e380..85b599f 100644
>> >--- a/drivers/net/ethernet/qualcomm/Kconfig
>> >+++ b/drivers/net/ethernet/qualcomm/Kconfig
>> >@@ -24,4 +24,15 @@ config QCA7000
>> >  	  To compile this driver as a module, choose M here. The module
>> >  	  will be called qcaspi.
>> >
>> >+config QCOM_EMAC
>> >+	tristate "Qualcomm Technologies, Inc. EMAC Gigabit Ethernet support"
>> >+	select CRC32

> select PHYLIB?

Ok.

>> >diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
>> >index 9da2d75..1b3a0ce 100644
>> >--- a/drivers/net/ethernet/qualcomm/Makefile
>> >+++ b/drivers/net/ethernet/qualcomm/Makefile
>> >@@ -4,3 +4,5 @@
>> >
>> >  obj-$(CONFIG_QCA7000) += qcaspi.o
>> >  qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
>> >+
>> >+obj-$(CONFIG_QCOM_EMAC) += emac/

> Since you have a check on CONFIG_QCOM_EMAC in emac/Makefile, you could
> always recurse into that directory while building (use obj-y).

Obviously, having "obj-$(CONFIG_QCOM_EMAC)" in both Makefiles is 
redundant, but wouldn't it make more sense to change 
"obj-$(CONFIG_QCOM_EMAC)" to "obj-y" in 
drivers/net/ethernet/qualcomm/emac/Makefile, so that I only recurse if 
necessary?

>> >+static void emac_adjust_link(struct net_device *netdev)
>> >+{
>> >+	struct emac_adapter *adpt = netdev_priv(netdev);
>> >+	struct phy_device *phydev = netdev->phydev;
>> >+
>> >+	if (phydev->link)
>> >+		emac_mac_start(adpt);
>> >+	else
>> >+		emac_mac_stop(adpt);

> This is really excessive here, you typically don't need to completely
> stop your transmitter/receiver/DMA/what have you, just reprogram the MAC
> with the appropriate link speed/duplex/pause parameters.

Yes, I realize that a lot of the reinit code in my driver is "heavy", 
and that it could be optimized for specific situations.  However, I'd 
like to save that for another patch, because it would require me to 
study the documentation and do extensive tests.

I can't tell you today whether emac_mac_start() is overkill for the 
specific link change.  For all I know, the hardware does require the TX 
to stop before changing the link speed.  Remember, the EMAC does have a 
weird double-phy (one internal, one external).

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
