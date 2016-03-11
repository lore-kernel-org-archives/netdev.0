From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 2/2] phy: fixed-phy: Allow DT description of
 an MDIO bus and PHYs.
Date: Fri, 11 Mar 2016 15:30:56 -0800
Message-ID: <56E35530.6000009@gmail.com>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <1457737726-23907-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35731 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbcCKXce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:32:34 -0500
Received: by mail-pf0-f170.google.com with SMTP id n5so55545048pfn.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 15:32:34 -0800 (PST)
In-Reply-To: <1457737726-23907-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 15:08, Andrew Lunn wrote:
> Not all MACs are connected to PHYs. They can for example be connected
> to a switch. Using the fixed PHY properties with the MAC is possible,
> but requires support in the MAC. It is however simpler to make use of
> the phy-handle property to point to a PHY. To achieve this, the PHY
> must be in the device tree.
> 
> Allow virtual MDIO busses to be represented in device tree, which
> contains virtual fixed-phys.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  .../devicetree/bindings/net/fixed-link.txt         |  39 +++++++
>  drivers/net/phy/fixed_phy.c                        | 122 ++++++++++++++++++++-
>  2 files changed, 157 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> index ec5d889fe3d8..2a22b92007fa 100644
> --- a/Documentation/devicetree/bindings/net/fixed-link.txt
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -52,3 +52,42 @@ ethernet@1 {
>  	};
>  	...
>  };
> +
> +Fixed link PHYs on an MDIO bus
> +------------------------------
> +
> +An alternative to using the fixed link properties in the MAC is to
> +define an MDIO bus with a number of fixed link phys on it.
> +
> +Required properties:
> +- compatible = ""linux,mdio-fixed-phy";

One too many " here.

> +- #address-cells = <1>;
> +- #size-cells = <0>;
> +
> +Child nodes represent PHYs on this mdio bus. Standard properties for
> +fixed links, 'speed', 'full-duplex', 'pause', 'asym-pause',
> +'link-gpios', as defined above are used. Additionally a 'reg' property
> +is required for the address of the PHY on the bus. This should be of
> +value 0 to 31.

This is a virtual bus, the only limitation is because we re-use to the
maximum permission extent the real MDIO bus code, and this is putting a
SW constraint on something that does not have one here.

> +
> +Example
> +-------
> +
> +mdio {
> +	compatible = "linux,mdio-fixed-phy";
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +
> +	phy0: phy@0 {
> +		reg = <0>;
> +		speed = <1000>;
> +		pause;
> +		link-gpios = <&gpio0 12 GPIO_ACTIVE_HIGH>;
> +	};
> +
> +	phy1: phy@8 {
> +		reg = <8>;
> +		speed = <100>;
> +		full-duplex;
> +	};

The 'fixed-link' property, although it suffers from one basic issue
which is that it is placed on the consumer of it (e.g: an Ethernet MAC
Device Tree node) while being a two-headed snake (you actually describe
a data-pipe with a fixed-link) is not quite perfect, but this does not
seem to look any better.

One thing that Thomas solved nicely was avoid the need for allocating an
address on the virtual MDIO bus, but this is coming back here, which
does not seem needed except for correctness wrt. how real MDIO buses.

-- 
Florian
