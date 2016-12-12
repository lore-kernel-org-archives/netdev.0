From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: Fix opps when adding vlan bridge
Date: Mon, 12 Dec 2016 14:04:16 +0100
Message-ID: <20161212130416.GC27057@lunn.ch>
References: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
 <87a8c2w55e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52382 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750712AbcLLNEV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 08:04:21 -0500
Content-Disposition: inline
In-Reply-To: <87a8c2w55e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 11, 2016 at 04:02:37PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > @@ -1804,6 +1807,9 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
> >  			    chip->ports[port].bridge_dev)
> >  				break; /* same bridge, check next VLAN */
> >  
> > +			if (!chip->ports[i].bridge_dev)
> > +				continue;
> > +
> 
> The above truncated test:
> 
> 			if (chip->ports[i].bridge_dev ==
> 			    chip->ports[port].bridge_dev)
> 				break; /* same bridge, check next VLAN */
> 
> should handle the case where bridge_dev is NULL, but if you want to
> explicitly test it, I'd move it before this statement.
> 
> >  			netdev_warn(ds->ports[port].netdev,
> >  				    "hardware VLAN %d already used by %s\n",
> >  				    vlan.vid,

Hi Vivien

I don't think you comment is correct. Here is the loop, with my two
additions.

                for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
                        if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
                                continue;

                        if (!ds->ports[port].netdev)
                                continue;

                        if (vlan.data[i] ==
                            GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
                                continue;

                        if (chip->ports[i].bridge_dev ==
                            chip->ports[port].bridge_dev)
                                break; /* same bridge, check next VLAN */

                        if (!chip->ports[i].bridge_dev)
                                continue;

                        netdev_warn(ds->ports[port].netdev,
                                    "hardware VLAN %d already used by %s\n",
                                    vlan.vid,
                                    netdev_name(chip->ports[i].bridge_dev));
                        err = -EOPNOTSUPP;
                        goto unlock;
                }

The opps was occurring in netdev_name(). I did not check which
one. The obvious one, or the netdev_warn(netdev,... one.

> The above truncated test:
> 
> 			if (chip->ports[i].bridge_dev ==
> 			    chip->ports[port].bridge_dev)
> 				break; /* same bridge, check next VLAN */
>
> should handle the case where bridge_dev is NULL, but if you want to
> explicitly test it, I'd move it before this statement.

This will not stop chip->ports[i].bridge_dev == NULL from reaching the
netdev_warn().

	Andrew
