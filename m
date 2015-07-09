From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] of_mdio: add new DT property 'link' for fixed-link
Date: Thu, 09 Jul 2015 11:24:25 -0700
Message-ID: <559EBC59.6020003@gmail.com>
References: <559EB0A4.5080101@list.ru> <559EB1A6.1090008@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Grant Likely <grant.likely@linaro.org>,
	devicetree@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35074 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbbGIS0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 14:26:11 -0400
In-Reply-To: <559EB1A6.1090008@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(there is no such thing as linux-net@vger.kernel.org, please remove it
from your future submissions).

On 09/07/15 10:38, Stas Sergeev wrote:
> 
> Currently for fixed-link the link state is always set to UP.

Not quite true, this is always a driver decision to make.

> This patch introduces the new property 'link' that accepts the
> following string arguments: "up", "down" and "auto".
> "down" may be needed if the link is physically unconnected.

In which case you probably do not even care about inserting such a
property in the first place, do you? What would be the value of forcibly
having a link permanently down (not counting loopback)?

> "auto" is needed to enable the link paramaters auto-negotiation,
> that is built into some MII protocols, namely SGMII.

RGMII also has an in-band status FWIW.

> The appropriate documentation is added and explicitly states that
> "auto" is very specific (protocol, HW and driver-specific), and
> is therefore should be used with care.

And therefore probably be made a device (and driver) specific decision
whether this is the right thing to do.

I do no think this addition to the "fixed-link" property is desirable
the way you have defined it.

More comments below.

> 
> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
> 
> CC: Rob Herring <robh+dt@kernel.org>
> CC: Pawel Moll <pawel.moll@arm.com>
> CC: Mark Rutland <mark.rutland@arm.com>
> CC: Ian Campbell <ijc+devicetree@hellion.org.uk>
> CC: Kumar Gala <galak@codeaurora.org>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> CC: Grant Likely <grant.likely@linaro.org>
> CC: devicetree@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: netdev@vger.kernel.org
> ---
>  .../devicetree/bindings/net/fixed-link.txt         |  8 +++-
>  drivers/of/of_mdio.c                               | 48 ++++++++++++++++++++--
>  include/linux/of_mdio.h                            |  5 +++
>  3 files changed, 57 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> index 82bf7e0..070f554 100644
> --- a/Documentation/devicetree/bindings/net/fixed-link.txt
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -9,8 +9,14 @@ Such a fixed link situation is described by creating a 'fixed-link'
>  sub-node of the Ethernet MAC device node, with the following
>  properties:
> 
> +* 'link' (string, optional), to indicate the link state. Accepted
> +  values are "up", "down" and "auto". "auto" means auto-negotiation of
> +  link parameters. Auto-negotiation is MII protocol, HW and driver-specific
> +  and is not supported in many cases, so use it only when you know what
> +  you do.
>  * 'speed' (integer, mandatory), to indicate the link speed. Accepted
> -  values are 10, 100 and 1000
> +  values are 10, 100 and 1000. If the 'link' property is set to 'auto',
> +  'speed' may not be set. It will then be auto-negotiated, if possible.
>  * 'full-duplex' (boolean, optional), to indicate that full duplex is
>    used. When absent, half duplex is assumed.
>  * 'pause' (boolean, optional), to indicate that pause should be
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 1bd4305..2152cf8 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -280,6 +280,26 @@ bool of_phy_is_fixed_link(struct device_node *np)
>  }
>  EXPORT_SYMBOL(of_phy_is_fixed_link);
> 
> +bool of_phy_is_autoneg_link(struct device_node *np)
> +{
> +	struct device_node *dn;
> +	const char *link_str;
> +	int rc;
> +	bool ret = false;
> +
> +	dn = of_get_child_by_name(np, "fixed-link");
> +	if (!dn)
> +		return false;
> +
> +	rc = of_property_read_string(dn, "link", &link_str);
> +	if (rc == 0 && strcmp(link_str, "auto") == 0)
> +		ret = true;
> +
> +	of_node_put(dn);
> +	return ret;
> +}
> +EXPORT_SYMBOL(of_phy_is_autoneg_link);
> +
>  int of_phy_register_fixed_link(struct device_node *np)
>  {
>  	struct fixed_phy_status status = {};
> @@ -291,11 +311,33 @@ int of_phy_register_fixed_link(struct device_node *np)
>  	/* New binding */
>  	fixed_link_node = of_get_child_by_name(np, "fixed-link");
>  	if (fixed_link_node) {
> -		status.link = 1;
> +		const char *link_str;
> +		int ret;
> +		bool link_auto = false;
> +
> +		ret = of_property_read_string(fixed_link_node, "link",
> +					      &link_str);
> +		if (ret == 0) {
> +			if (strcmp(link_str, "up") == 0)
> +				status.link = 1;
> +			else
> +				status.link = 0;
> +			if (strcmp(link_str, "auto") == 0)
> +				link_auto = true;
> +		} else {
> +			status.link = 1;
> +		}
>  		status.duplex = of_property_read_bool(fixed_link_node,
>  						      "full-duplex");
> -		if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
> -			return -EINVAL;
> +		if (of_property_read_u32(fixed_link_node, "speed",
> +					 &status.speed) != 0) {
> +			/* in auto mode just set to some sane value:
> +			 * it will be changed by MAC later */
> +			if (link_auto)
> +				status.speed = 1000;

This is a completely arbitrary speed, that does not more or less sense
than defaulting to 100 or anything else, a driver should be able to set
the speed it wants, based on the parsing of a 'phy-mode' property for
instance. 1000 does not make sense on e.g: MII links.
-- 
Florian
