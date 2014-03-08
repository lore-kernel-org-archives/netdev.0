From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCHv3 3/4] of: provide a binding for fixed link PHYs
Date: Sat, 08 Mar 2014 05:50:33 +0000
Message-ID: <20140308055033.BE0F2C405B0@trevor.secretlab.ca>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@ free-electrons.com> <1393930704-24374-4-git-send-email-thomas.petazzoni@ free-electrons.com>
Cc: Lior Amsalem <alior@marvell.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:38673 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaCHFuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 00:50:37 -0500
Received: by mail-wg0-f49.google.com with SMTP id a1so1838755wgh.20
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 21:50:36 -0800 (PST)
In-Reply-To: <1393930704-24374-4-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Mar 2014 11:58:23 +0100, Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:
> Some Ethernet MACs have a "fixed link", and are not connected to a
> normal MDIO-managed PHY device. For those situations, a Device Tree
> binding allows to describe a "fixed link" using a special PHY node.
> 
> This patch adds:
> 
>  * A documentation for the fixed PHY Device Tree binding.
> 
>  * An of_phy_is_fixed_link() function that an Ethernet driver can call
>    on its PHY phandle to find out whether it's a fixed link PHY or
>    not. It should typically be used to know if
>    of_phy_register_fixed_link() should be called.
> 
>  * An of_phy_register_fixed_link() function that instantiates the
>    fixed PHY into the PHY subsystem, so that when the driver calls
>    of_phy_connect(), the PHY device associated to the OF node will be
>    found.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  .../devicetree/bindings/net/fixed-link.txt         | 34 ++++++++++++++++++++++
>  drivers/of/of_mdio.c                               | 24 +++++++++++++++
>  include/linux/of_mdio.h                            | 15 ++++++++++
>  3 files changed, 73 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> new file mode 100644
> index 0000000..9f2a1a50
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -0,0 +1,34 @@
> +Fixed link Device Tree binding
> +------------------------------
> +
> +Some Ethernet MACs have a "fixed link", and are not connected to a
> +normal MDIO-managed PHY device. For those situations, a Device Tree
> +binding allows to describe a "fixed link".
> +
> +Such a fixed link situation is described by creating a PHY node as a
> +sub-node of an Ethernet device, with the following properties:
> +
> +* 'fixed-link' (boolean, mandatory), to indicate that this PHY is a
> +  fixed link PHY.
> +* 'speed' (integer, mandatory), to indicate the link speed. Accepted
> +  values are 10, 100 and 1000
> +* 'full-duplex' (boolean, optional), to indicate that full duplex is
> +  used. When absent, half duplex is assumed.
> +* 'pause' (boolean, optional), to indicate that pause should be
> +  enabled.
> +* 'asym-pause' (boolean, optional), to indicate that asym_pause should
> +  be enabled.
> +
> +Example:
> +
> +ethernet@0 {
> +	...
> +	phy = <&phy0>;
> +	phy0: phy@0 {
> +	      fixed-link;
> +	      speed = <1000>;
> +	      full-duplex;
> +	};

The phy phandle to a child node is superfluous. A phandle to a fixed
child node doesn't make a whole lot of sense.

You've worn me down though. I'll ack the binding with a few tweaks in
usage. This binding provides a direct super-set of the old fixed-link
property binding. There should be a single function for parsing it. That
way we can allow the new behaviour on drivers using the old. The new
binding should be preferred over the old.

ie. a call to of_phy_is_fixed_link() should look for a fixed link node
first, followed by the older property version.

There should be a strong recommendation for the child node name. Make it
"fixed-link". The only reason a device should ever deviate from that is
if it has multiple links that all need to be processed.

If anyone complains that "fixed-link" is ambiguous, then perhaps
"mii-fixed-link" would be better. I don't see a problem though.

There should be no address portion in the node name. It isn't a child
device, the node is merely more configuration data for the parent.

Example:

ethernet@0 {
	...
	fixed-link {
	      speed = <1000>;
	      full-duplex;
	};

g.
