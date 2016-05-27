From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 09/16] dsa: dsa: Split up creating/destroying of DSA and CPU ports
Date: Fri, 27 May 2016 15:25:47 -0400
Message-ID: <87bn3rz4jo.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-10-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35983 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbcE0TZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 15:25:51 -0400
In-Reply-To: <1464312050-23023-10-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Florian,

I suggest to use this RFC to agree on a consistent and robust API for
the DSA layer. Some functions have non-intuitive names or signatures.

What about:

    <namespace>_<action>[_<object>]

where <namespace> matches the first argument. So instead of
dsa_cpu_dsa_setup, we would have:

    dsa_switch_setup_cpu_dsa_port(struct dsa_switch *ds, ...)

[...]

Andrew Lunn <andrew@lunn.ch> writes:

>  /* basic switch operations **************************************************/
> -static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
> +int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
> +		      struct device_node *port_dn, int port)
>  {

We will need the port number in the struct dsa_port at some point. The
device_node is already a member of this structure.

I suggest to add the port index before this patch and change this
function for a more logical:

    dsa_switch_setup_cpu_dsa_port(struct dsa_switch *ds, struct dsa_port *dp)

[...]

>  	/* Perform configuration of the CPU and DSA ports */
> -	ret = dsa_cpu_dsa_setup(ds, dst->master_netdev);
> +	ret = dsa_cpu_dsa_setups(ds, parent);
>  	if (ret < 0) {
>  		netdev_err(dst->master_netdev, "[%d] : can't configure CPU and DSA ports\n",
>  			   index);

dsa_cpu_dsa_setups is not really meaningful and doesn't add much
value. At least I'd call it dsa_switch_setup_cpu_dsa_ports(), or better,
move the loop directly where it is needed so we know which port sucked:

dsa_switch_setup_one:

        /* Perform configuration of the CPU and DSA ports */
        for (port = 0; port < DSA_MAX_PORTS; port++) {
                if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
                        continue;

                ret = dsa_switch_setup_cpu_dsa_port(ds, dev, ds->ports[port]);
                if (ret) {
                        netdev_err(dst->master_netdev,
                                   "[%d] : can't configure port %d\n",
                                   index, ds->ports[port]->index);
                        break;
                }
        }
        
Thanks,

        Vivien
