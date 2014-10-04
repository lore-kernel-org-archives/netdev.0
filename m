From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net-next] net: phy: adjust fixed_phy_register() return
 value
Date: Sat, 4 Oct 2014 14:07:31 +0200
Message-ID: <20141004140731.15c18a77@free-electrons.com>
References: <20141001214509.2BF4F10070D@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, f.fainelli@gmail.com
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50190 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750959AbaJDMHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 08:07:34 -0400
In-Reply-To: <20141001214509.2BF4F10070D@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Petri Gynther,

Sorry for the late answer.

On Wed,  1 Oct 2014 14:45:09 -0700 (PDT), Petri Gynther wrote:
> Adjust fixed_phy_register() to return struct phy_device *, so that
> it becomes easy to use fixed PHYs without device tree support:
> 
>   phydev = fixed_phy_register(PHY_POLL, &fixed_phy_status, NULL);
>   fixed_phy_set_link_update(phydev, fixed_phy_link_update);
>   phy_connect_direct(netdev, phydev, handler_fn, phy_interface);
> 
> This change is a prerequisite for modifying bcmgenet driver to work
> without a device tree on Broadcom's MIPS-based 7xxx platforms.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

On the principle, I'm obviously fine, but I have one comment below.


>  	/* New binding */
>  	fixed_link_node = of_get_child_by_name(np, "fixed-link");
> @@ -299,7 +300,8 @@ int of_phy_register_fixed_link(struct device_node *np)
>  		status.asym_pause = of_property_read_bool(fixed_link_node,
>  							  "asym-pause");
>  		of_node_put(fixed_link_node);
> -		return fixed_phy_register(PHY_POLL, &status, np);
> +		phy = fixed_phy_register(PHY_POLL, &status, np);
> +		return (!phy || IS_ERR(phy));
>  	}
>  
>  	/* Old binding */
> @@ -310,7 +312,8 @@ int of_phy_register_fixed_link(struct device_node *np)
>  		status.speed = be32_to_cpu(fixed_link_prop[2]);
>  		status.pause = be32_to_cpu(fixed_link_prop[3]);
>  		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
> -		return fixed_phy_register(PHY_POLL, &status, np);
> +		phy = fixed_phy_register(PHY_POLL, &status, np);
> +		return (!phy || IS_ERR(phy));

I am not sure this return (!phy || IS_ERR(phy)) is doing the right
thing. This function is supposed to return an error code on failure, or
0 on success. I don't see how your error handling returns an error code
on failure. What about doing the more explicit:

		phy = fixed_phy_register(PHY_POLL, &status, np);
		if (IS_ERR(phy))
			return PTR_ERR(phy);
		else
			return 0;

Or am I missing something?

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
