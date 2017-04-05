From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Wed, 5 Apr 2017 20:21:55 +0200
Message-ID: <20170405182155.GF21965@lunn.ch>
References: <20170405092024.16048-1-jbe@pengutronix.de>
 <20170405092024.16048-4-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170405092024.16048-4-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 05, 2017 at 11:20:23AM +0200, Juergen Borleis wrote:
> In this mode the switch device and the internal phys will be managed via
> I2C interface. The MDIO interface is still supported, but for the
> (emulated) CPU port only.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
> ---
>  .../devicetree/bindings/net/dsa/lan9303.txt        |  74 ++++++++++++++
>  drivers/net/phy/Kconfig                            |  17 ++++
>  drivers/net/phy/Makefile                           |   5 +
>  drivers/net/phy/lan9303_i2c.c                      | 109 +++++++++++++++++++++
>  4 files changed, 205 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/lan9303.txt
>  create mode 100644 drivers/net/phy/lan9303_i2c.c
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/lan9303.txt b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
> new file mode 100644
> index 0000000000000..2c8a466065a27
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
> @@ -0,0 +1,74 @@
> +SMSC/MicroChip LAN9303 three port ethernet switch
> +-------------------------------------------------
> +
> +Required properties:
> +
> +- compatible: should be "smsc,lan9303"
> +- #size-cells: must be 0
> +- #address-cells: must be 1
> +
> +Optional properties:
> +
> +- phy-reset-gpios: GPIO to be used to reset the whole device, always low active
> +- phy-reset-duration: reset duration, defaults to 200 ms

It is good to state the unit, ms.

> +
> +Subnodes:
> +
> +The integrated switch subnode should be specified according to the binding
> +described in dsa/dsa.txt. The CPU port of this switch is always port 0.
> +
> +Example:
> +
> +I2C managed mode:
> +
> +	master: masterdevice@X {
> +		phy-handle = <&ethphy>;
> +		status = "okay";
> +
> +		mdio {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			ethphy: ethernet-phy@0 {
> +				compatible = "ethernet-phy-ieee802.3-c22";
> +				reg = <0>;
> +				max-speed = <100>;
> +			};

If there is RMII between the CPU interface and the switch, why is this
PHY needed?

> +		};
> +
> +	};
> +
> +	switch: switch@a {
> +		compatible = "smsc,lan9303";
> +		reg = <0xa>;
> +		status = "okay";
> +		interrupts-extended = <&gpio2 7 IRQ_TYPE_LEVEL_LOW>;

This interrupt is not in the binding documentation, or the code.

> +		phy-reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
> +		phy-reset-duration = <200>;
> +
> +		dsa,member = <0 0>;
> +
> +		ports {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			port@0 { /* RMII fixed link to master */
> +				reg = <0>;
> +				label = "cpu";
> +				ethernet = <&master>;
> +				max-speed = <100>;

max-speed does not do anything i think, since there is no adjust_link
function.

	Andrew
