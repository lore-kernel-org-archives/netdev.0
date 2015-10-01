From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Thu, 1 Oct 2015 12:17:06 -0400
Message-ID: <20151001161706.GA1836@ketchup.mtl.sfl>
References: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
 <20150925043640.GB18915@ketchup.lan>
 <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
 <20150924.225508.2124748200966556070.davem@davemloft.net>
 <20150925150303.GA21567@ketchup.mtl.sfl>
 <20150930185652.GA2455@ketchup.lan>
 <CAE4R7bBooYJTBTUpb6zCRfoZs4N9VW1exfFBZgY5B1FmdQVtpg@mail.gmail.com>
 <20151001151535.GA31603@ketchup.mtl.sfl>
 <20151001152821.GK20219@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:59174
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753274AbbJAQRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 12:17:09 -0400
Content-Disposition: inline
In-Reply-To: <20151001152821.GK20219@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Oct. Thursday 01 (40) 05:28 PM, Andrew Lunn wrote:
> > > Does this help?  Maybe we should walk before running and focus on
> > > getting non-batch ops working and then revisit?
> > 
> > I agree. I understand the need for a prepare phase, but it looks like it
> > exists for specific combinations, i.e. stacked and bonded devices.
> > 
> > For basic Ethernet switch chips (even DSA), it is *for the moment* a bit
> > too unnecessarily complex.
> 
> I think we are going to need it though. I have bonding on my TODO
> list. That will put DSA into a stacked system.
>  
> > What I will suggest next, is to explicitly skip the prepare phase in DSA
> > (with a good comment as you already suggested), and fix switchdev to
> > allow drivers to return -EOPNOTSUPP from its commit phase.
> 
> The switches have a limited number of bonds, called trunks in Marvells
> terminology. So we will need the prepare phase to say: Sorry, im out
> of trunks, do it in software. And different chips have different
> numbers of trunks, so it will need to go down into the chip driver,
> the DSA layer probably cannot decide.

I understand. Please consider my last comment, which is not invalidated
here: asking the hardware for a support, and the prepare transaction
framework are 2 differents things here.

In other words: struct switchdev_trans != -EOPNOTSUPP.

Even with Marvell switches, bonding 2 ports may not be supported, but if
it does, it won't need the switchdev_trans framework for this operation.

If we take a look at how dsa_slave_stp_update works today in
net/dsa/slave.c, it is quite complicated:

    dsa_slave_stp_update(dev, state)
        if (ds->drv->port_stp_update)
	    return ds->drv->port_stp_update(port, state);
        else
	    return -EOPNOTSUPP;

This checks that the driver implemented this operation. And:

    dsa_slave_port_attr_set(dev, attr, trans)
        ...
	case SWITCHDEV_ATTR_PORT_STP_STATE:
	    if (switchdev_trans_ph_prepare(trans))
	        return ds->drv->port_stp_update ? 0 : -EOPNOTSUPP;
	    else
	        return ds->drv->port_stp_update(port, state);

DSA drivers don't need dynamic resources from the kernel. But they may
not support an object. I would like to make the distinction, by skipping
the prepare phase in the DSA framework and allowing DSA drivers to
eventually return -EOPNOTSUPP from their feature implementation. It
makes no difference for the caller of switchdev_port_{obj_add,attr_set}
anyway.

Thanks,
-v
