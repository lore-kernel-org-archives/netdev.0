From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 00:52:14 +0200
Message-ID: <20160912225214.GA3585@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473669337-21221-4-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John

> +#include <linux/module.h>
> +#include <linux/phy.h>
> +#include <linux/netdevice.h>
> +#include <net/dsa.h>
> +#include <net/switchdev.h>
> +#include <linux/phy.h>

One linux/phy.h is enough.

> +	/* Setup connection between CPU ports & PHYs */
> +	for (i = 0; i < DSA_MAX_PORTS; i++) {
> +		/* CPU port gets connected to all PHYs in the switch */
> +		if (dsa_is_cpu_port(ds, i)) {
> +			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(priv->cpu_port),
> +				  QCA8K_PORT_LOOKUP_MEMBER,
> +				  ds->enabled_port_mask << 1);
> +		}
> +
> +		/* Invividual PHYs gets connected to CPU port only */
> +		if (ds->enabled_port_mask & BIT(i)) {
> +			int port = qca8k_phy_to_port(i);
> +			int shift = 16 * (port % 2);
> +

snip

> +static void
> +qca8k_get_ethtool_stats(struct dsa_switch *ds, int phy,
> +			uint64_t *data)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +	const struct qca8k_mib_desc *mib;
> +	u32 reg, i, port;
> +	u64 hi;
> +
> +	port = qca8k_phy_to_port(phy);

snip

> +static inline int qca8k_phy_to_port(int phy)
> +{
> +	if (phy < 5)
> +		return phy + 1;
> +
> +	return -1;
> +}

What keep throwing me while reading this code is the use of PHY/phy.

What is meant by a phy in this driver?

DSA is all about switches. Switches are a switch fabric and a number
of ports. The ports contain Ethernet MACs, and optionally contain
embedded PHYs. If there are not embedded PHYs, there are often
external PHYs, and sometimes we just have MACs connected back to back.

Generally, DSA drivers don't need to do much with the MAC. Maybe set
the speed and duplex, and maybe signal delays. They also don't need to
do much with the PHY, phylib and a phy driver does all the work. DSA
is all about the switch fabric.

Yet i see phy scattered in a few places in this driver, and it seems
like they have nothing to do with the PHY.

Please can you change the terminology here? It might help if you can
remove qca8k_phy_to_port(). Why do you need to add 1? Could this be
eliminated via a better choice of reg in the device tree?

Thanks
	Andrew	   
