From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 3/4] net-next: dsa: Add support for multiple cpu ports.
Date: Wed, 4 Jan 2017 14:22:35 +0100
Message-ID: <20170104132235.GG10768@lunn.ch>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
 <1483515484-21793-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42853 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967691AbdADNX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 08:23:56 -0500
Content-Disposition: inline
In-Reply-To: <1483515484-21793-4-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 08:38:03AM +0100, John Crispin wrote:
>  static int dsa_user_port_apply(struct device_node *port, u32 index,
> @@ -475,6 +475,28 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
>  
>  	dst->rcv = dst->tag_ops->rcv;
>  
> +	dev_hold(ethernet_dev);
> +	ds->cd->port_ethernet[index] = ethernet_dev;
> +
> +	return 0;
> +}
> +
> +static int dsa_user_parse(struct device_node *port, u32 index,
> +			  struct dsa_switch *ds)
> +{

Please put this function next to dsa_cpu_parse(). All the
apply/unapply functions are together, and all the _parse functions
should be together.

> +	struct device_node *cpu_port;
> +	const unsigned int *cpu_port_reg;
> +	int cpu_port_index;
> +
> +	cpu_port = of_parse_phandle(port, "cpu", 0);
> +	if (cpu_port) {
> +		cpu_port_reg = of_get_property(cpu_port, "reg", NULL);
> +		if (!cpu_port_reg)
> +			return -EINVAL;
> +		cpu_port_index = be32_to_cpup(cpu_port_reg);
> +		ds->cd->port_cpu[index] = cpu_port_index;
> +	}
> +
>  	return 0;
>  }
>  
> @@ -482,18 +504,20 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
>  {
>  	struct device_node *port;
>  	u32 index;
> -	int err;
> +	int err = 0;
>  
>  	for (index = 0; index < DSA_MAX_PORTS; index++) {
>  		port = ds->ports[index].dn;
>  		if (!port)
>  			continue;
>  
> -		if (dsa_port_is_cpu(port)) {
> +		if (dsa_port_is_cpu(port))
>  			err = dsa_cpu_parse(port, index, dst, ds);
> -			if (err)
> -				return err;
> -		}
> +		else if (!dsa_port_is_dsa(port))
> +			err = dsa_user_parse(port, index,  ds);
> +
> +		if (err)
> +			return err;

Having this if (err) here is correct, but it goes against the general
pattern we have in the code. Please indent it so it is under the
err =, and remove the initialisation of err.

Also, if one branch of an if/else has {}, the coding style says the
other branch should also use {}.

Just to make this code look nicer, i would be tempted to add a helper,
dsa_port_is_user().

>  	}
>  
>  	pr_info("DSA: switch %d %d parsed\n", dst->tree, ds->index);

Thanks
	Andrew
