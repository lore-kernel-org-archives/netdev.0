From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 19:01:20 +0200
Message-ID: <20170906170120.GF15315@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <874lsfg87t.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, jiri@resnulli.us,
        nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58883 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753829AbdIFRBW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 13:01:22 -0400
Content-Disposition: inline
In-Reply-To: <874lsfg87t.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 06, 2017 at 11:25:26AM -0400, Vivien Didelot wrote:
> Hi Andrew, Nikolay,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > Then starts the work passing down to the hardware that the host has
> > joined/left a group. The existing switchdev mdb object cannot be used,
> > since the semantics are different. The existing
> > SWITCHDEV_OBJ_ID_PORT_MDB is used to indicate a specific multicast
> > group should be forwarded out that port of the switch. However here we
> > require the exact opposite. We want multicast frames for the group
> > received on the port to the forwarded to the host. Hence add a new
> > object SWITCHDEV_OBJ_ID_HOST_MDB, a multicast database entry to
> > forward to the host. This new object is then propagated through the
> > DSA layers. No DSA driver changes should be needed, this should just
> > work...
> 
> I'm not sure if you already explained that, if so, sorry in advance.
> 
> I don't understand why SWITCHDEV_OBJ_ID_PORT_MDB cannot be used. Isn't
> setting the obj->orig_dev to the bridge device itself enough to
> distinguish br0 from a switch port?

Hi Vivien

I did consider this. But conceptually, it seems wrong.
SWITCHDEV_OBJ_ID_PORT_MDB has always been about egress. I don't like
adding a special case for ingress. Adding a new switchdev object
avoids this special case.

>     static int dsa_slave_port_obj_add(struct net_device *dev,
>                                     const struct switchdev_obj *obj,
>                                     struct switchdev_trans *trans)
>     {
>             struct dsa_slave_priv *p = netdev_priv(dev);
>             struct dsa_port *port = p->dp;
> 
>             /* Is the target port the bridge device itself? */
>             if (obj->orig_dev == port->br)
>                     port = port->cpu_dp;
> 
>             return dsa_port_mdb_add(port, obj, trans);
>     }
> 
> The main problem is that we will soon want support for multiple CPU
> ports.

We keep saying that, but it never actually happens. We should solve
multiple CPU problems when we actually add support for multiple CPUs.
Probably at that point, we need to push SWITCHDEV_OBJ_ID_PORT_HOST_MDB
right down to a port, so that port can setup what needs setting up so
its frames goes to its CPU port.

> So adding the MDB entry to all CPU ports as you did in a patch 5/8 in
> dsa_switch_host_mdb_*() is not correct because you can have CPU port
> sw0p0 being a member of br0 and CPU port sw0p10 being a member of br1.

Be careful, you are making assumptions about mapping cpu ports to
bridges. That is not been defined yet.

	 Andrew
