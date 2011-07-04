From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH] net/fec: add device tree probe support
Date: Mon, 4 Jul 2011 13:50:22 +0800
Message-ID: <20110704055021.GC10245@S2100-06.ap.freescale.net>
References: <1309680401-22904-1-git-send-email-shawn.guo@linaro.org>
 <20110703212312.GD13742@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Shawn Guo <shawn.guo@linaro.org>, <patches@linaro.org>,
	<netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	Jason Liu <jason.hui@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:13604 "EHLO
	TX2EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab1GDFoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 01:44:04 -0400
Content-Disposition: inline
In-Reply-To: <20110703212312.GD13742@ponder.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 03, 2011 at 03:23:12PM -0600, Grant Likely wrote:
> On Sun, Jul 03, 2011 at 04:06:41PM +0800, Shawn Guo wrote:
> > It adds device tree probe support for fec driver.
> > 
> > Signed-off-by: Jason Liu <jason.hui@linaro.org>
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: Grant Likely <grant.likely@secretlab.ca>
> 
> Minor comments below.  After addressing them you can add my:
> 
> Acked-by: Grant Likely <grant.likely@secretlab.ca>
> 
> I don't see any reason not to merge this one in v3.1
> 
> g.
> 
> > ---
> >  Documentation/devicetree/bindings/net/fsl-fec.txt |   24 ++++
> >  drivers/net/fec.c                                 |  120 ++++++++++++++++++++-
> >  2 files changed, 139 insertions(+), 5 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/fsl-fec.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> > new file mode 100644
> > index 0000000..1dad888
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> > @@ -0,0 +1,24 @@
> > +* Freescale Fast Ethernet Controller (FEC)
> > +
> > +Required properties:
> > +- compatible : Should be "fsl,<soc>-fec"
> > +- reg : Address and length of the register set for the device
> > +- interrupts : Should contain fec interrupt
> > +- phy-mode : String, operation mode of the PHY interface.
> > +  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
> > +  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi".
> 
> We don't have a common binding for this yet.  Should be
> "fsl,phy-mode".
> 
There is nothing really fsl specific.  How does the following patch
look to you?

---8<---------
diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index 86f334a..cc117db 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -8,6 +8,49 @@
 #include <linux/etherdevice.h>
 #include <linux/kernel.h>
 #include <linux/of_net.h>
+#include <linux/phy.h>
+
+/**
+ * It maps 'enum phy_interface_t' found in include/linux/phy.h
+ * into the device tree binding of 'phy-mode', so that Ethernet
+ * device driver can get phy interface from device tree.
+ */
+static const char *phy_modes[] = {
+       [PHY_INTERFACE_MODE_MII]        = "mii",
+       [PHY_INTERFACE_MODE_GMII]       = "gmii",
+       [PHY_INTERFACE_MODE_SGMII]      = "sgmii",
+       [PHY_INTERFACE_MODE_TBI]        = "tbi",
+       [PHY_INTERFACE_MODE_RMII]       = "rmii",
+       [PHY_INTERFACE_MODE_RGMII]      = "rgmii",
+       [PHY_INTERFACE_MODE_RGMII_ID]   = "rgmii-id",
+       [PHY_INTERFACE_MODE_RGMII_RXID] = "rgmii-rxid",
+       [PHY_INTERFACE_MODE_RGMII_TXID] = "rgmii-txid",
+       [PHY_INTERFACE_MODE_RTBI]       = "rtbi",
+};
+
+/**
+ * of_get_phy_mode - Get phy mode for given device_node
+ * @np:        Pointer to the given device_node
+ *
+ * The function gets phy interface string from property 'phy-mode',
+ * and return its index in phy_modes table, or errno in error case.
+ */
+const int of_get_phy_mode(struct device_node *np)
+{
+       const char *pm;
+       int err, i;
+
+       err = of_property_read_string(np, "phy-mode", &pm);
+       if (err < 0)
+               return err;
+
+       for (i = 0; i < ARRAY_SIZE(phy_modes); i++)
+               if (!strcasecmp(pm, phy_modes[i]))
+                       return i;
+
+       return -ENODEV;
+}
+EXPORT_SYMBOL_GPL(of_get_phy_mode);

 /**
  * Search the device tree for the best MAC address to use.  'mac-address' is
------------

[...]
> > @@ -734,8 +748,25 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
> >  	 */
> >  	iap = macaddr;
> >  
> > +#ifdef CONFIG_OF
> > +	/*
> > +	 * 2) from device tree data
> > +	 */
> > +	if (!is_valid_ether_addr(iap)) {
> > +		struct device_node *np = fep->pdev->dev.of_node;
> > +		if (np) {
> > +			const char *mac;
> > +			int err;
> > +			err = of_property_read_string(np,
> > +					"local-mac-address", &mac);
> > +			if (err)
> > +				iap = (unsigned char *) mac;
> 
> There is already a function for doing this.  of_get_mac_address().
> And mac address is *not* a string, it is a byte array.
> 
Yes, I mistakenly converted of_find_property to of_property_read_string.
Anyway, I'm now using of_get_mac_address as you suggested.

-- 
Regards,
Shawn

