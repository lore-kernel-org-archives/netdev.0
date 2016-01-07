From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 11/26] phylink: add phylink infrastructure
Date: Thu, 07 Jan 2016 12:09:35 -0800
Message-ID: <568EC5FF.8030803@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zjj-00075Z-Q1@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35005 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbcAGUKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:10:09 -0500
Received: by mail-pa0-f44.google.com with SMTP id ho8so5814644pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:10:09 -0800 (PST)
In-Reply-To: <E1a5zjj-00075Z-Q1@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
[snip]
> +void phylink_phy_change(struct phy_device *phy, bool up, bool do_carrier)
> +{
> +	struct phylink *pl = phy->phylink;
> +
> +	mutex_lock(&pl->state_mutex);
> +	pl->phy_state.speed = phy->speed;
> +	pl->phy_state.duplex = phy->duplex;
> +	pl->phy_state.pause = MLO_PAUSE_NONE;
> +	if (phy->pause)
> +		pl->phy_state.pause |= MLO_PAUSE_SYM;
> +	if (phy->asym_pause)
> +		pl->phy_state.pause |= MLO_PAUSE_ASYM;
> +	pl->phy_state.link = up;
> +	mutex_unlock(&pl->state_mutex);
> +
> +	phylink_run_resolve(pl);
> +
> +	netdev_dbg(pl->netdev, "phy link %s\n", up ? "up" : "down");
> +}

Should this function be exported?

[snip]

> +
> +	phy_node = of_parse_phandle(dn, "phy-handle", 0);
> +	if (!phy_node)
> +		phy_node = of_parse_phandle(dn, "phy", 0);
> +	if (!phy_node)
> +		phy_node = of_parse_phandle(dn, "phy-device", 0);
> +
> +	if (!phy_node) {

This could be worth becoming a helper function that drivers could use,
as a subsequent patch for instance.


> +		if (pl->link_an_mode == MLO_AN_PHY) {
> +			netdev_err(pl->netdev, "unable to find PHY node\n");
> +			return -ENODEV;
> +		}
> +		return 0;
> +	}


> +
> +	phy_dev = of_phy_attach(pl->netdev, phy_node, 0, pl->link_interface);
> +	/* We're done with the phy_node handle */
> +	of_node_put(phy_node);
> +
> +	if (!phy_dev)
> +		return -ENODEV;
> +
> +	ret = phylink_bringup_phy(pl, phy_dev);
> +	if (ret)
> +		phy_detach(phy_dev);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(phylink_of_phy_connect);

Overall, this looks good to me, I am not very comfortable with the API
similarities between PHY link and traditional PHY devices, since that
forces PHY link to duplicate a bit of code (ioctl among other things).

Would it be better to have a generic PHY device have the option to be
overloaded with PHY link operations such that drivers do not have to
absorb API changes?
-- 
Florian
