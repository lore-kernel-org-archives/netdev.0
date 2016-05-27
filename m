From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 09/16] dsa: dsa: Split up creating/destroying of DSA and CPU ports
Date: Fri, 27 May 2016 12:36:48 -0400
Message-ID: <87fut35ufz.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-10-git-send-email-andrew@lunn.ch> <87lh2v604y.fsf@ketchup.mtl.sfl> <20160527150744.GC20214@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58285 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869AbcE0Qgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:36:52 -0400
In-Reply-To: <20160527150744.GC20214@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, May 27, 2016 at 10:33:49AM -0400, Vivien Didelot wrote:
>> Hi Andrew,
>> 
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> > -static void dsa_switch_destroy(struct dsa_switch *ds)
>> > +void dsa_cpu_dsa_destroy(struct device_node *port_dn)
>> >  {
>> > -	struct device_node *port_dn;
>> >  	struct phy_device *phydev;
>> > +
>> > +	if (of_phy_is_fixed_link(port_dn)) {
>> > +		phydev = of_phy_find_device(port_dn);
>> > +		if (phydev) {
>> > +			phy_device_free(phydev);
>> > +			fixed_phy_unregister(phydev);
>> > +		}
>> > +	}
>> > +}
>> > +
>> > +static void dsa_switch_destroy(struct dsa_switch *ds)
>> > +{
>> >  	int port;
>> >  
>> >  #ifdef CONFIG_NET_DSA_HWMON
>> > @@ -445,17 +467,11 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>> >  		dsa_slave_destroy(ds->ports[port].netdev);
>> >  	}
>> >  
>> > -	/* Remove any fixed link PHYs */
>> > +	/* Disable configuration of the CPU and DSA ports */
>> >  	for (port = 0; port < DSA_MAX_PORTS; port++) {
>> > -		port_dn = ds->ports[port].dn;
>> > -		if (of_phy_is_fixed_link(port_dn)) {
>> > -			phydev = of_phy_find_device(port_dn);
>> > -			if (phydev) {
>> > -				phy_device_free(phydev);
>> > -				of_node_put(port_dn);
>> 
>> Why does dsa_cpu_dsa_destroy drop that of_node_put call?
>
> The of node reference counting is broken. The DT maintainers actually
> say not to care, the whole reference counting scheme is broken. Which
> is a bit sad really. There was a discussion about this a couple of
> months ago.
>
> Anyway, the reference is taken in dsa_of_probe() as part of the
> or_each_available_child_of_node(child, port). This reference has
> nothing to do with the port being a fixed link or not. So freeing it
> here is inappropriate. The correct place to free it would probably be
> in dsa_of_remove.

OK, good to know. Can you split that in its own patch (prefered), or at
least document that in the commit message?

>> > -				fixed_phy_unregister(phydev);
>> > -			}
>> > -		}
>> > +		if ((dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
>> > +			continue;
>> 
>> Why do we skip DSA and CPU ports here? The previous code didn't.
>> 
>> > +		dsa_cpu_dsa_destroy(ds->ports[port].dn);
>
> They are now destroyed by the newly added dsa_cpu_dsa_destroy().  I'm
> making the code more symmetrical and easier to re-use. The inverse of
> this function is dsa_switch_setup_one() and it also uses a helper
> function to setup the dsa and cpu ports, dsa_cpu_dsa_setups().

But dsa_cpu_dsa_destroy() is not called here. Shouldn't we drop (like
before) or at least invert the condition above?

Thanks,

        Vivien
