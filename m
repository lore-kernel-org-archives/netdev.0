From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 2/2] ARM: dts: Add the ethernet and ethernet PHY to the
 cygnus core DT.
Date: Tue, 25 Apr 2017 16:59:55 -0700
Message-ID: <0cb00eb7-41d0-0390-4687-d966499ed9f4@gmail.com>
References: <20170425235357.7690-1-eric@anholt.net>
 <20170425235357.7690-2-eric@anholt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170425235357.7690-2-eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/25/2017 04:53 PM, Eric Anholt wrote:
> Cygnus has a single AMAC controller connected to the B53 switch with 2
> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
> the external ethernet jacks.
> 
> Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> 
> v2: Call the node "switch", just call the ports "port" (suggestions by
>     Florian), drop max-speed on the phys (suggestion by Andrew Lunn),
>     call the other nodes "ethernet" and "ethernet-phy" (suggestions by
>     Sergei Shtylyov)
> 
>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 58 ++++++++++++++++++++++++++++++++++
>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>  2 files changed, 66 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi b/arch/arm/boot/dts/bcm-cygnus.dtsi
> index 009f1346b817..9fd89be0f5e0 100644
> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
> @@ -142,6 +142,54 @@
>  			interrupts = <0>;
>  		};
>  
> +		mdio: mdio@18002000 {
> +			compatible = "brcm,iproc-mdio";
> +			reg = <0x18002000 0x8>;
> +			#size-cells = <1>;
> +			#address-cells = <0>;

Sorry for not noticing earlier, since you override this correctly in the
board-level DTS file can you put a:

			status = "disabled"

property in there by default?

Thanks!

> +
> +			gphy0: ethernet-phy@0 {
> +				reg = <0>;
> +			};
> +
> +			gphy1: ethernet-phy@1 {
> +				reg = <1>;
> +			};
> +		};
> +
> +		switch: switch@18007000 {
> +			compatible = "brcm,bcm11360-srab", "brcm,cygnus-srab";
> +			reg = <0x18007000 0x1000>;
> +			status = "disabled";
> +
> +			ports {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				port@0 {
> +					reg = <0>;
> +					phy-handle = <&gphy0>;
> +					phy-mode = "rgmii";
> +				};
> +
> +				port@1 {
> +					reg = <1>;
> +					phy-handle = <&gphy1>;
> +					phy-mode = "rgmii";
> +				};
> +
> +				port@8 {
> +					reg = <8>;
> +					label = "cpu";
> +					ethernet = <&eth0>;
> +					fixed-link {
> +						speed = <1000>;
> +						full-duplex;
> +					};
> +				};
> +			};
> +		};
> +
>  		i2c0: i2c@18008000 {
>  			compatible = "brcm,cygnus-iproc-i2c", "brcm,iproc-i2c";
>  			reg = <0x18008000 0x100>;
> @@ -295,6 +343,16 @@
>  			status = "disabled";
>  		};
>  
> +		eth0: ethernet@18042000 {
> +			compatible = "brcm,amac";
> +			reg = <0x18042000 0x1000>,
> +			      <0x18110000 0x1000>;
> +			reg-names = "amac_base", "idm_base";
> +			interrupts = <GIC_SPI 110 IRQ_TYPE_LEVEL_HIGH>;
> +			max-speed = <1000>;
> +			status = "disabled";
> +		};
> +
>  		nand: nand@18046000 {
>  			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
>  			reg = <0x18046000 0x600>, <0xf8105408 0x600>,
> diff --git a/arch/arm/boot/dts/bcm911360_entphn.dts b/arch/arm/boot/dts/bcm911360_entphn.dts
> index 8b3800f46288..e037dea63f4a 100644
> --- a/arch/arm/boot/dts/bcm911360_entphn.dts
> +++ b/arch/arm/boot/dts/bcm911360_entphn.dts
> @@ -57,6 +57,14 @@
>  	};
>  };
>  
> +&eth0 {
> +	status = "okay";
> +};
> +
> +&switch {
> +	status = "okay";
> +};
> +
>  &uart3 {
>  	status = "okay";
>  };
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
