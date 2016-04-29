From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: New DSA design for cross-chip operations
Date: Fri, 29 Apr 2016 17:33:44 -0400 (EDT)
Message-ID: <1570407369.390644.1461965624673.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39959 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbcD2Vdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 17:33:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here's a proposal for a new design of DSA. It is meant to discuss the
actual state and future implementation of the D (for distributed) in
DSA, which consists of supporting several interconnected switch chips,
exposed to the user as one big switch unit.

There's still a lot of work to finish in DSA before running into
cross-chip operations, but it'll help to start thinking about it now.

Please read carefully and comment the whole thread.

Today, switchdev is used to push stateless network port operations down
to the parent switch devices.

DSA uses switchdev, without additional value. The dsa_switch_driver
functions are basically wrappers around the switchdev ops with a bit of
syntactic sugar. For instance, we have this:

    int (*port_vlan_del)(struct dsa_switch *ds, int port,
                         const struct switchdev_obj_port_vlan *vlan);

over this:

    int switchdev_port_obj_del(struct net_device *dev,
                               const struct switchdev_obj *obj);

What Linux actually does for the D in DSA? Not much. We just have a
bench of dsa_switch structures hanging a dsa_switch_tree structure. But
they are all managed independently from one another.

What is the issue with this? Let's take this example of three
interconnected 6-port switch devices.

          sw0             sw1             sw2                                                             
    [ 0 1 2 3 4 5 ] [ 0 1 2 3 4 5 ] [ 0 1 2 3 4 5 ]                                                       
      |   '     ^     ^         ^     ^     '                                                             
      v   '     |     |         |     |     '                                                             
     CPU  '     `-DSA-'         `-DSA-'     '                                                             
          '                                 '                                                             
          + - - - - - - - br0 - - - - - - - +  

With this setup, the user will see 13 network interfaces:
sw{0,1,2}p{1,2,3,4} and sw2p5.

Now let's put sw0p2 and sw2p3 in a same VLAN 42:

    ip link add name br0 type bridge
    ip link set master br0 dev sw0p2 up
    ip link set master br0 dev sw2p3 up
    bridge vlan add vid 42 dev sw0p2
    bridge vlan add vid 42 dev sw2p3
    echo 1 > /sys/class/net/br0/bridge/vlan_filtering

Today, the above commands will add the VID 1 (br0's default_pvid) and
VID 42 to sw0 and sw2 and enable 802.1Q policy on sw0p2 and sw2p3 if
their drivers support it.

But the data path is broken, since additional setup is required to allow
correct hardware bridging of frames between sw0 and sw2:

  * depending on their model, sw0 and sw2 may need to allow external
    frames from respectively sw2p3 and sw0p2.

  * sw1 needs to program VID 1 and VID 42 in order not to drop unknown
    packets for such tag.

  * if the DSA links do not automatically learn MAC addresses behind the
    two ports, they need to be programmed to switch packets
    correctly. This is also true for adding or removing static MAC
    addresses.

So for basically every bridge operation (bridge join/leave, VLAN/FDB
add/del, etc.), we need a cross-chip variant in order to notify all
other switches of the tree.

My first RFC [1] added yet another dsa_switch_driver operation to
implement the cross-chip bridging (allowing or preventing frames):

    void (*cross_chip_bridge)(struct dsa_switch *ds, int sw_index,
                              int sw_port, struct net_device *bridge);

Such notifications must be added also for VLAN and FDB operations. We
can hardly make them returning an error, since the operation already
occurred on the concerned switch. Rolling back operations would be very
complex.

So now, how can we prevent for some reason a cross-chip port operation?
Let's say sw1 cannot add VID 42, how can it interpose with the switchdev
operation?

If we still want to use switchdev to propagate bridge operations to a
switch device, DSA has to scale the switchdev operations "horizontally",
on every switch of the tree. That way, if one device on the data path
returns an error, the whole operation can be aborted.

That's why I propose a dsa_switch_driver to implement not only internal
port operations, but *cross-chip* port operations. That would be the
whole difference between a DSA device and another basic Ethernet switch.

So now, instead of the following operation:

    void (*port_vlan_add)(struct dsa_switch *ds, int port,
                          const struct switchdev_obj_port_vlan *vlan,
                          struct switchdev_trans *trans);

a dsa_switch_driver will have to implement:

    void (*port_vlan_add)(struct dsa_switch *ds, int index, int port,
                          const struct switchdev_obj_port_vlan *vlan,
                          struct switchdev_trans *trans);

With regards to the previous example, the 3 switches sw0, sw1 and sw2
would be called with port_vlan_add(ds, 0, 2, vlan, trans) and
port_vlan_add(ds, 2, 3, vlan, trans). The drivers are responsible for
programming the related VID in their chip with the DSA links as members
as well as the eventual internal port if they are parents.

The DSA slave code will be lighten up by calling tree-wide operations,
in charge of propagating a port operation to every switch of the tree.

Now, for a driver to properly configure cross-chip bridging, it needs to
access the state of every port of the tree. The bridge device the port
is bridged to must be exposed. That's why I propose to introduce a new
dsa_port structure to contains state-full data about a port of a tree.

In a dsa_switch_driver function such as the following:

    int (*port_bridge_join)(struct dsa_switch *ds, struct dsa_port *dp,
                            struct net_device *bridge);

a driver can iterate on ports of a DSA tree, check their bridge device
and program their chip accordingly.

Since one of the Linux phisolophy is to be port-centric (the user should
not be aware of underlying switch devices), it makes sense to introduce
such structure, and program a DSA switch with this scope.

Maybe more info would need to be stored in such structure, such as the
net_device pointer (for user network interfaces, used by the DSA core),
the VLANs the port is currently a member of, a vlan_filtering bool or
the STP state, etc.

With this port-centric structure, we'll also benefit from a more
consistent public API for DSA, like pointers to the CPU dsa_port in the
tree, same for the upstream port, consistent helpers such as
dsa_port_is_{cpu,dsa}, etc.

A second RFC [2] proposed an implementation of this new design.

We can go a bit further, by moving the port setup at the DSA layer level
with a new setup_port cross-chip function, and call it once the DSA tree
is complete and the DSA core has registered the net_device of user
ports. This will lighten up the drivers' huge setup code, and allow
drivers to initialize cross-chip setup (basically forbidding a new
external port to egress frames) on this switch.

[1] https://lkml.org/lkml/2016/4/20/733
[2] https://lkml.org/lkml/2016/4/27/1013

Cheers,

        Vivien
