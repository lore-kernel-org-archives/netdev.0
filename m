From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 12:13:09 -0800
Message-ID: <54E3A0D5.5020801@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:52345 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbbBQUNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 15:13:51 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YNoWk-002axO-97
	for netdev@vger.kernel.org; Tue, 17 Feb 2015 20:13:50 +0000
In-Reply-To: <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2015 11:26 AM, Florian Fainelli wrote:
> In order to support bridging offloads in DSA switch drivers, select
> NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
> NDOs that we are required to implement.
>
> To facilitate the integratation at the DSA driver level, we implement 3
> types of operations:
>
> - port_join_bridge
> - port_leave_bridge
> - port_stp_update
>
> DSA will resolve which switch ports that are currently bridge port
> members as some Switch hardware/drivers need to know about that to limit
> the register programming to just the relevant registers (especially for
> slow MDIO buses).
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   include/net/dsa.h  |  10 +++++
>   net/dsa/Kconfig    |   1 +
>   net/dsa/dsa.c      |   7 ++++
>   net/dsa/dsa_priv.h |   2 +
>   net/dsa/slave.c    | 117 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>   5 files changed, 137 insertions(+)
>
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index ed3c34bbb67a..92be34791963 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -275,6 +275,16 @@ struct dsa_switch_driver {
>   	int	(*get_regs_len)(struct dsa_switch *ds, int port);
>   	void	(*get_regs)(struct dsa_switch *ds, int port,
>   			    struct ethtool_regs *regs, void *p);
> +
> +	/*
> +	 * Bridge integration
> +	 */
> +	int	(*port_join_bridge)(struct dsa_switch *ds, int port,
> +				    u32 br_port_mask);
> +	int	(*port_leave_bridge)(struct dsa_switch *ds, int port,
> +				     u32 br_port_mask);
> +	int	(*port_stp_update)(struct dsa_switch *ds, int port,
> +				   u8 state);
>   };
>
>   void register_switch_driver(struct dsa_switch_driver *type);
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 5f8ac404535b..b45206e8dd3e 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -8,6 +8,7 @@ config NET_DSA
>   	tristate
>   	depends on HAVE_NET_DSA
>   	select PHYLIB
> +	select NET_SWITCHDEV

Should this be "select" or "depends on" ?

Downside of depends is that we'll need some ifdefs in the code,
but on the other side it would let people disable it if it is
not needed.

Thanks,
Guenter
