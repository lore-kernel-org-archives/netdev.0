From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 0/3] net: dsa: cross-chip operations
Date: Wed, 20 Apr 2016 16:26:06 -0400
Message-ID: <1461183969-24610-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset aims to start a thread on cross-chips operations in DSA, no need
to spend time on reviewing the details of the code (especially for mv88e6xxx).

So when several switch chips are interconnected, we need to configure them all
to ensure correct hardware switching. We can think about this case:

          sw0             sw1             sw2
    [ 0 1 2 3 4 5 ] [ 0 1 2 3 4 5 ] [ 0 1 2 3 4 5 ]
      |   '     ^     ^         ^     ^     '
      v   '     |     |         |     |     '
     CPU  '     `-DSA-'         `-DSA-'     '
          '                                 '
          + - - - - - - - br0 - - - - - - - +

Here sw1 needs to be aware of br0, to configure itself with MAC addresses,
VIDs, or whatever to ensure hardware frame bridging between sw0 and sw2.

Two cross-chip unbridged ports (e.g. sw0p3 and sw1p1) of mv88e6xxx-supported
devices can currently talk to each other, because the chips are configured to
allow frames to ingress from any external ports. This is not what we want, and
this patchset fixes that. The only important part for the thread is 1/3 though.

Some Marvell switches have a cross-chip port based VLAN table used to allow or
not external frames to egress its internal ports. So a new switch-level
operation needs to be added in order to inform the other switches that a port
joined or left a bridge group. This is what dsa_slave_broadcast_bridge() does.

But this is not enough. When a port joins a bridge group, its switch driver
needs to learn the existing cross-chip members, so that ingressing frames from
them can be allowed. This is what dsa_tree_broadcast_bridge() does.

But that is ugly. This adds yet another DSA function, and makes the DSA layer
code quite complex. Also, similar notifications need to be implemented to
configure cross-chip VLANs (for VLAN filtering aware systems where br0 is
implemented with a 802.1Q VLAN), FDB additions/deletions so that frames get
switched correctly by the hardware, etc.

Actually the DSA drivers functions are just switchdev ops with a bit of
syntactic sugar, but no real value added. The purpose of the DSA layer is to
scale the switchdev ops "horizontally" to every tree port. To avoid numerous
operations and keep it simple for drivers, I think we need 2 things:

  1) The scope of DSA switch driver ops should be the DSA tree, not the switch.
  This means having each dsa_switch_driver implements functions such as:

      int (*port_bridge_join)(struct dsa_switch *ds, int sw_index, int sw_port,
           struct net_device *bridge);

  instead of the current:

      int (*port_bridge_join)(struct dsa_switch *ds, int port,
           struct net_device *bridge);

  So that drivers can configure their in-chip or cross-chip stuffs, return 0 or
  -EOPNOTSUPP if ds->index != sw_index. Replacing dsa_slave_broadcast_bridge.

  2) To replace dsa_tree_broadcast_bridge, drivers need to access public info
  in the tree, such as bridge membership of every port. That can be acheived
  with a bit of refactoring like the following:

      /* include/net/dsa.h */
      struct dsa_port {
          struct list_head    list;
          struct dsa_switch   *ds;
          int                 port;
          struct net_device   *bridge_dev;
      }

      struct dsa_switch_tree {
          ...
          struct list_head ports;
      };

      /* net/dsa/dsa_priv.h */
      struct dsa_slave_priv {
          ...
          dsa_port dp;
      };

      Then DSA switch drivers can implement tree-level ops such as:

      int (*port_bridge_join)(struct dsa_switch *ds, struct dsa_port *dp,
           struct net_device *bridge);

I'm working on an RFC for the above. Let me know what you think and if this
seems correct to you.

Cheers,

Vivien Didelot (3):
  net: dsa: add cross-chip notification for bridge
  net: dsa: mv88e6xxx: initialize PVT
  net: dsa: mv88e6xxx: setup PVT

 drivers/net/dsa/mv88e6352.c |   1 +
 drivers/net/dsa/mv88e6xxx.c | 181 ++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx.h |   7 ++
 include/net/dsa.h           |   6 ++
 net/dsa/slave.c             |  60 ++++++++++++++-
 5 files changed, 246 insertions(+), 9 deletions(-)

-- 
2.8.0
