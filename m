From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 1/2] dt: emac: document device-tree based phy discovery and
 setup
Date: Sun, 5 Feb 2017 14:33:44 -0800
Message-ID: <23e29bef-4c49-8ff6-b156-3b028ed592c4@gmail.com>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ivan Mikhaylov <ivan-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 02/05/17 à 14:25, Christian Lamparter a écrit :
> This patch adds documentation for a new "phy-handler" property
> and "mdio" sub-node. These allows the enumeration of PHYs which
> are supported by the phy library under drivers/net/phy.
> 
> The EMAC ethernet controller in IBM and AMCC 4xx chips is
> currently stuck with a few privately defined phy
> implementations. It has no support for PHYs which
> are supported by the generic phylib.
> 
> Signed-off-by: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> ---
>  .../devicetree/bindings/powerpc/4xx/emac.txt       | 60 +++++++++++++++++++++-
>  1 file changed, 58 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> index 712baf6c3e24..0572d053c35a 100644
> --- a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> +++ b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> @@ -71,6 +71,8 @@
>  			  For Axon it can be absent, though my current driver
>  			  doesn't handle phy-address yet so for now, keep
>  			  0x00ffffff in it.
> +    - phy-handle	: See net/ethernet.txt file; used to describe
> +			  configurations where a external PHY is used.
>      - rx-fifo-size-gige : 1 cell, Rx fifo size in bytes for 1000 Mb/sec
>  			  operations (if absent the value is the same as
>  			  rx-fifo-size).  For Axon, either absent or 2048.
> @@ -82,7 +84,18 @@
>      - tah-channel       : 1 cell, optional. If appropriate, channel used on the
>  			  TAH engine.
>  
> -    Example:
> +    - mdio subnode	: When the EMAC has a phy connected to its local
> +			  mdio, which us supported by the kernel's network
> +			  PHY library in drivers/net/phy, there must be device
> +			  tree subnode with the following required properties:
> +				- #address-cells: Must be <1>.
> +				- #size-cells: Must be <0>.
> +
> +			  For each phy on the mdio bus, there must be a node
> +			  with the following fields:
> +				- reg: phy id used to communicate to phy.
> +				- device_type: Must be "ethernet-phy".

Just provide a reference to
Documentation/devicetree/bindings/net/phy.txt and
Documentation/devicetree/bindings/net/ethernet.txt here. device_type is
not required.

> +    Examples:
>  
>  	EMAC0: ethernet@40000800 {
>  		device_type = "network";
> @@ -104,6 +117,50 @@
>  		zmii-channel = <0>;
>  	};
>  
> +	EMAC1: ethernet@ef600c00 {
> +		device_type = "network";
> +		compatible = "ibm,emac-apm821xx", "ibm,emac4sync";
> +		interrupt-parent = <&EMAC1>;
> +		interrupts = <0 1>;
> +		#interrupt-cells = <1>;
> +		#address-cells = <0>;
> +		#size-cells = <0>;
> +		interrupt-map = <0 &UIC2 0x10 IRQ_TYPE_LEVEL_HIGH /* Status */
> +				 1 &UIC2 0x14 IRQ_TYPE_LEVEL_HIGH /* Wake */>;
> +		reg = <0xef600c00 0x000000c4>;
> +		local-mac-address = [000000000000]; /* Filled in by U-Boot */
> +		mal-device = <&MAL0>;
> +		mal-tx-channel = <0>;
> +		mal-rx-channel = <0>;
> +		cell-index = <0>;
> +		max-frame-size = <9000>;
> +		rx-fifo-size = <16384>;
> +		tx-fifo-size = <2048>;
> +		fifo-entry-size = <10>;
> +		phy-mode = "rgmii";
> +		phy-map = <0x00000000>;

If you have a proper mdio subnode, this property becomes irrelevant and
should be unused.

> +		phy-handle = <&phy0>;
> +		rgmii-device = <&RGMII0>;
> +		rgmii-channel = <0>;
> +		tah-device = <&TAH0>;
> +		tah-channel = <0>;
> +		has-inverted-stacr-oc;
> +		has-new-stacr-staopc;
> +
> +	        mdio {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			phy0: ethernet-phy@0 {
> +				device_type = "ethernet-phy";
> +				reg = <0>;
> +
> +				qca,ar8327-initvals = <
> +					0x0010 0x40000000>;
> +		};
> +	};
> +
> +
>        ii) McMAL node
>  
>      Required properties:
> @@ -145,4 +202,3 @@
>      - revision           : as provided by the RGMII new version register if
>  			   available.
>  			   For Axon: 0x0000012a
> -
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
