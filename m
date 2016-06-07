From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 4/5] net: dsa: Initialize CPU port ethtool
 ops per tree
Date: Tue, 7 Jun 2016 02:34:01 +0200
Message-ID: <20160607003401.GP12165@lunn.ch>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
 <1465254895-11152-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemlof.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60951 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394AbcFGAeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 20:34:04 -0400
Content-Disposition: inline
In-Reply-To: <1465254895-11152-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2016 at 04:14:54PM -0700, Florian Fainelli wrote:
> Now that we can properly support multiple distinct trees in the system,
> using a global variable: dsa_cpu_port_ethtool_ops is getting clobbered
> as soon as the second switch tree gets probed, and we don't want that.
> 
> We need to move this to be dynamically allocated, and since we can't
> really be comparing addresses anymore to determine first time
> initialization versus any other times, just move this to dsa.c and
> dsa2.c where the remainder of the dst/ds initialization happens.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/dsa/dsa.c      | 28 ++++++++++++++++++++++++++++
>  net/dsa/dsa2.c     |  4 ++++
>  net/dsa/dsa_priv.h |  2 ++
>  net/dsa/slave.c    | 10 ----------
>  4 files changed, 34 insertions(+), 10 deletions(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index ce3b942dce76..37026f04ee4d 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -266,6 +266,30 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
>  	return ops;
>  }
>  
> +int dsa_cpu_port_ethtool_setup(struct dsa_switch_tree *dst,
> +			       struct dsa_switch *ds)
> +{
> +	struct net_device *master;
> +	struct ethtool_ops *cpu_ops;
> +
> +	master = ds->dst->master_netdev;
> +	if (ds->master_netdev)
> +		master = ds->master_netdev;
> +
> +	cpu_ops = devm_kzalloc(ds->dev, sizeof(*cpu_ops), GFP_KERNEL);
> +	if (!cpu_ops)
> +		return -ENOMEM;
> +
> +	memcpy(&dst->master_ethtool_ops, master->ethtool_ops,
> +	       sizeof(struct ethtool_ops));
> +	memcpy(cpu_ops, &dst->master_ethtool_ops,
> +	       sizeof(struct ethtool_ops));
> +	dsa_cpu_port_ethtool_init(cpu_ops);
> +	master->ethtool_ops = cpu_ops;
> +
> +	return 0;
> +}

Hi Florian

Why is there not a symmetrical dsa_cpu_port_ethertool_destroy method,
which will restore master->ethtool_ops when the switch module is
unloaded. I think at the moment, you end up with master->ethtool_ops
pointing at released memory.

	 Andrew
