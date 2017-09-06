From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 06 Sep 2017 11:25:26 -0400
Message-ID: <874lsfg87t.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34636 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932263AbdIFP2u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 11:28:50 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Nikolay,

Andrew Lunn <andrew@lunn.ch> writes:

> Then starts the work passing down to the hardware that the host has
> joined/left a group. The existing switchdev mdb object cannot be used,
> since the semantics are different. The existing
> SWITCHDEV_OBJ_ID_PORT_MDB is used to indicate a specific multicast
> group should be forwarded out that port of the switch. However here we
> require the exact opposite. We want multicast frames for the group
> received on the port to the forwarded to the host. Hence add a new
> object SWITCHDEV_OBJ_ID_HOST_MDB, a multicast database entry to
> forward to the host. This new object is then propagated through the
> DSA layers. No DSA driver changes should be needed, this should just
> work...

I'm not sure if you already explained that, if so, sorry in advance.

I don't understand why SWITCHDEV_OBJ_ID_PORT_MDB cannot be used. Isn't
setting the obj->orig_dev to the bridge device itself enough to
distinguish br0 from a switch port?

This way, the only change necessary in net/dsa/slave.c is something
like (abbreviated):

    static int dsa_slave_port_obj_add(struct net_device *dev,
                                    const struct switchdev_obj *obj,
                                    struct switchdev_trans *trans)
    {
            struct dsa_slave_priv *p = netdev_priv(dev);
            struct dsa_port *port = p->dp;

            /* Is the target port the bridge device itself? */
            if (obj->orig_dev == port->br)
                    port = port->cpu_dp;

            return dsa_port_mdb_add(port, obj, trans);
    }

The main problem is that we will soon want support for multiple CPU
ports. This means that each DSA slave will have its dedicated CPU port,
instead of having only one for the whole switch tree.

So adding the MDB entry to all CPU ports as you did in a patch 5/8 in
dsa_switch_host_mdb_*() is not correct because you can have CPU port
sw0p0 being a member of br0 and CPU port sw0p10 being a member of br1.

So is it correct to simply notify SWITCHDEV_OBJ_ID_PORT_MDB with
orig_dev = br->dev so that its members get recursively notified?

Even if SWITCHDEV_OBJ_ID_HOST_MDB is necessary, we need to handle it the
way I described, otherwise we don't have a correct mapping between a
slave port and its CPU port that we need to configure.


Thanks,

        Vivien
