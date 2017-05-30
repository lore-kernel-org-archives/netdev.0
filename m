From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Tue, 30 May 2017 15:45:37 -0400
Message-ID: <87inki5dsu.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530104419.6052-1-john@phrozen.org> <20170530104419.6052-2-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: John Crispin <john@phrozen.org>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530104419.6052-2-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

John Crispin <john@phrozen.org> writes:

> +static inline bool dsa_is_upstream_port(struct dsa_switch *ds, int p)
> +{
> +	return dsa_is_cpu_port(ds, p) || dsa_is_dsa_port(ds, p);
> +}

This looks confusing to me. What DSA calls an "upstream" port for the
moment is the port which goes to the CPU interface.

     CPU0 (eth0)
       |
       | sw0         sw1         sw2
     [p0 p1 p2]--[p0 p1 p2]--[p0 p1 p2]
          |           |           |  |
          eth1     eth2        eth3  eth4

So in the example above, sw1p0 is an upstream port, but sw1p2 is not.
This is why dsa_upstream_port makes use of ds->rtable.

> @@ -1140,11 +1140,16 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	struct net_device *master;
>  	struct net_device *slave_dev;
>  	struct dsa_slave_priv *p;
> +	int port_cpu = ds->ports[port].upstream;

ds->ports[port] is p->dp.

>  	int ret;
>  
> -	master = ds->dst->master_netdev;
> -	if (ds->master_netdev)
> +	if (port_cpu && ds->ports[port_cpu].ethernet)

0 is a valid port index for a CPU, e.g. Marvell 88E6390.

> +		master = ds->ports[port_cpu].ethernet;
> +	else if (ds->master_netdev)
>  		master = ds->master_netdev;
> +	else
> +		master = ds->dst->master_netdev;
> +	master->dsa_ptr = (void *)ds->dst;
>  
>  	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
>  				 NET_NAME_UNKNOWN, ether_setup);
> @@ -1173,6 +1178,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	p->dp = &ds->ports[port];
>  	INIT_LIST_HEAD(&p->mall_tc_list);
>  	p->xmit = dst->tag_ops->xmit;
> +	p->master = master;

I'm a bit confused why we need all these references to net devices. We
now have ds->master_netdev, dst->master_netdev, dp->ethernet and
p->master...

Wouldn't it be simpler if we only had dp->ethernet (or whichever more
explicit name) for the conduit interface used to send/receive frames?

Maybe I am missing something, in which case I'm sorry in advance.


Thanks,

        Vivien
