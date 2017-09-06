From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 06 Sep 2017 14:29:26 -0400
Message-ID: <87o9qnel4p.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch> <874lsfg87t.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170906170120.GF15315@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, jiri@resnulli.us,
        nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46932 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752220AbdIFScv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 14:32:51 -0400
In-Reply-To: <20170906170120.GF15315@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> I don't understand why SWITCHDEV_OBJ_ID_PORT_MDB cannot be used. Isn't
>> setting the obj->orig_dev to the bridge device itself enough to
>> distinguish br0 from a switch port?
>
> I did consider this. But conceptually, it seems wrong.
> SWITCHDEV_OBJ_ID_PORT_MDB has always been about egress. I don't like
> adding a special case for ingress. Adding a new switchdev object
> avoids this special case.

SWITCHDEV_OBJ_ID_PORT_MDB means manipulating an MDB entry on a port.
When one want to add an MDB entry to br0, SWITCHDEV_OBJ_ID_PORT_MDB is
used. If the device is br->dev, the lower devices (bridged ports) get
recursively notified and switchdev users can program themselves
accordingly. In the case of DSA, a slave port will program its
associated CPU port (port->cpu_dp) if orig_dev is a bridge.

This seems totally correct to me. I don't see any reason for adding and
maintaining a new switchdev object. What do switchdev guys think?

>> The main problem is that we will soon want support for multiple CPU
>> ports.
>
> We keep saying that, but it never actually happens. We should solve
> multiple CPU problems when we actually add support for multiple CPUs.
> Probably at that point, we need to push SWITCHDEV_OBJ_ID_PORT_HOST_MDB
> right down to a port, so that port can setup what needs setting up so
> its frames goes to its CPU port.

This is not correct. I am currently making this easier, i.e. the
dsa_master patchset I sent before net-next closed.

I do understand your point however and even if this multi-CPU feature
takes time to arrive, we can always find a proper design which makes it
easy. Assuming that each port has its dedicated CPU port is the correct
concept to follow.

>> So adding the MDB entry to all CPU ports as you did in a patch 5/8 in
>> dsa_switch_host_mdb_*() is not correct because you can have CPU port
>> sw0p0 being a member of br0 and CPU port sw0p10 being a member of br1.
>
> Be careful, you are making assumptions about mapping cpu ports to
> bridges. That is not been defined yet.

I am not making any assumptions, but you did because you assume that all
CPU ports will be part of the same bridge.

We need to handle things at the DSA core level the following way:

If one programs the bridge device itself, a switchdev object is
notified, and each DSA slave devices member of the bridge will call the
correct dsa_port_* function (agnostic to the port type) with its cpu_dp.

This covers cleanly all cases. You also don't need any new DSA notifier.
You only need your 6/8 patch. To acheive that, there is two ways:

1) either we keep SWITCHDEV_OBJ_ID_PORT_MDB for the bridge device itself
and the slave devices are notified accordingly with a correct orig_dev:

    static int dsa_slave_port_obj_add(struct net_device *dev,
                                      const struct switchdev_obj *obj,
                                      struct switchdev_trans *trans)
    {
            struct dsa_slave_priv *p = netdev_priv(dev);
            struct dsa_port *port = p->dp;
    
            /* Program the CPU port if the target is the bridge itself */
            if (obj->orig_dev == port->br)
                    port = port->cpu_dp;
    
            switch (obj->id) {
            case SWITCHDEV_OBJ_ID_PORT_MDB:
                return dsa_port_mdb_add(port, obj, trans);
            ...
            }
    }

2) or you introduce a switchdev object which, by definition, targets the
CPU ports of our bridge members:

    static int dsa_slave_port_obj_add(struct net_device *dev,
                                      const struct switchdev_obj *obj,
                                      struct switchdev_trans *trans)
    {
            struct dsa_slave_priv *p = netdev_priv(dev);
            struct dsa_port *port = p->dp;

            switch (obj->id) {
            case SWITCHDEV_OBJ_ID_PORT_HOST_MDB:
                port = port->cpu_dp;
                /* fall through... */
            case SWITCHDEV_OBJ_ID_PORT_MDB:
                return dsa_port_mdb_add(port, obj, trans);
            ...
            }
    }

You basically just need that and your 6/8 patch for the DSA part.


Thanks,

        Vivien
