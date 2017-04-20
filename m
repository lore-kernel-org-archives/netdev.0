From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Thu, 20 Apr 2017 10:38:46 -0700
Message-ID: <e32156d3-1aa7-6dff-2087-73aa71356207@gmail.com>
References: <20170418084827.19613-1-jbe@pengutronix.de>
 <20170418084827.19613-4-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
To: Juergen Borleis <jbe-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170418084827.19613-4-jbe-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/18/2017 01:48 AM, Juergen Borleis wrote:
> In this mode the switch device and the internal phys will be managed via
> I2C interface. The MDIO interface is still supported, but for the
> (emulated) CPU port only.
> 
> Signed-off-by: Juergen Borleis <jbe-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> CC: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
> CC: mark.rutland-5wv7dgnIgG8@public.gmane.org
> ---
>  .../devicetree/bindings/net/dsa/lan9303.txt        |  62 +++++++++++
>  drivers/net/dsa/Kconfig                            |  16 +++
>  drivers/net/dsa/Makefile                           |   2 +
>  drivers/net/dsa/lan9303_i2c.c                      | 113 +++++++++++++++++++++
>  4 files changed, 193 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/lan9303.txt
>  create mode 100644 drivers/net/dsa/lan9303_i2c.c
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/lan9303.txt b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
> new file mode 100644
> index 0000000000000..2edc2561467a7
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
> @@ -0,0 +1,62 @@
> +SMSC/MicroChip LAN9303 three port ethernet switch
> +-------------------------------------------------
> +
> +Required properties:
> +
> +- compatible: should be "smsc,lan9303-i2c"
> +
> +Optional properties:
> +
> +- reset-gpios: GPIO to be used to reset the whole device
> +- reset-duration: reset duration in milliseconds, defaults to 200 ms
> +
> +Subnodes:
> +
> +The integrated switch subnode should be specified according to the binding
> +described in dsa/dsa.txt. The CPU port of this switch is always port 0.
> +
> +Note: always use 'reg = <0/1/2>;' for the three DSA ports, even if the device is
> +configured to use 1/2/3 instead. This hardware configuration will be
> +auto-detected and mapped accordingly.
> +
> +Example:
> +
> +I2C managed mode:
> +
> +	master: masterdevice@X {
> +		status = "okay";
> +
> +		fixed-link { /* RMII fixed link to LAN9303 */
> +			speed = <100>;
> +			full-duplex;
> +		};
> +	};
> +
> +	switch: switch@a {
> +		compatible = "smsc,lan9303-i2c";
> +		reg = <0xa>;
> +		status = "okay";
> +		reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
> +		reset-duration = <200>;
> +
> +		ports {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			port@0 { /* RMII fixed link to master */
> +				reg = <0>;
> +				label = "cpu";
> +				ethernet = <&master>;
> +			};
> +
> +			port@1 { /* external port 1 */
> +				reg = <1>;
> +				label = "lan1;
> +			};
> +
> +			port@2 { /* external port 2 */
> +				reg = <2>;
> +				label = "lan2";
> +			};
> +		};
> +	};
> diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
> index 31a2b229106dd..c56533bffc8ce 100644
> --- a/drivers/net/dsa/Kconfig
> +++ b/drivers/net/dsa/Kconfig
> @@ -50,4 +50,20 @@ config NET_DSA_MT7530
>  	  This enables support for the Mediatek MT7530 Ethernet switch
>  	  chip.
>  
> +config NET_DSA_SMSC_LAN9303
> +	tristate
> +	select NET_DSA_TAG_LAN9303
> +	---help---
> +	  This enables support for the SMSC/Microchip LAN9303 3 port ethernet
> +	  switch chips.
> +

Should not this hunk ^^^ be part of the previous patch (patch #2)? It's
not a big deal, but it would have been more natural and would allow
building the driver right away even in the absence of bus "glue" modules.

> +config NET_DSA_SMSC_LAN9303_I2C
> +	tristate "SMSC/Microchip LAN9303 3-ports 10/100 ethernet switch in I2C managed mode"
> +	depends on NET_DSA
> +	select NET_DSA_SMSC_LAN9303
> +	select REGMAP_I2C
> +	---help---
> +	  Enable access functions if the SMSC/Microchip LAN9303 is configured
> +	  for I2C managed mode.
> +
>  endmenu
> diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
> index 2ae07f4fbf635..c1981ba18963f 100644
> --- a/drivers/net/dsa/Makefile
> +++ b/drivers/net/dsa/Makefile
> @@ -3,6 +3,8 @@ obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm-sf2.o
>  bcm-sf2-objs			:= bcm_sf2.o bcm_sf2_cfp.o
>  obj-$(CONFIG_NET_DSA_QCA8K)	+= qca8k.o
>  obj-$(CONFIG_NET_DSA_MT7530)	+= mt7530.o
> +obj-$(CONFIG_NET_DSA_SMSC_LAN9303) += lan9303-core.o

Same thing here.

Other than that:

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
