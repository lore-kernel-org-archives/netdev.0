From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 00/20] net: dsa: dsa_port structure and tree-wide ops
Date: Wed, 27 Apr 2016 18:29:57 -0400
Message-ID: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a previous RFC [1], I introduced the need to implement cross-chip operations
in the DSA layer.

Here's a summary. In a multiple switches setup such as the following, every
switch of the tree must be aware of its configuration in order to configure a
correct data path between chips.

          sw0             sw1             sw2                                                             
    [ 0 1 2 3 4 5 ] [ 0 1 2 3 4 5 ] [ 0 1 2 3 4 5 ]                                                       
      |   '     ^     ^         ^     ^     '                                                             
      v   '     |     |         |     |     '                                                             
     CPU  '     `-DSA-'         `-DSA-'     '                                                             
          '                                 '                                                             
          + - - - - - - - br0 - - - - - - - +  

For instance, bridging sw0p2 and sw2p3 together in a VLAN 42 requires both
chips to allow frames from the external port to egress its internal port, all
DSA ports between them must learn their address, and sw1 must also be aware of
the VLAN 42 in order to allow tagged packets to cross the chip.

To implement all that nicely, we need a way to progagate such notification to
every switch of a DSA tree.

The patchset introduces a dsa_port structure to bundle port-centric info such
as its switch index, port number, bridge device, and change the DSA driver
functions to take such structure as parameter instead of a internal port
number.

The DSA layer then introduces tree-wide operations, which calls every switch
driver when a port operation occurs. This is the responsibility of a switch
driver to check if the related port is internal or external to its chip, and
behave in consequence.

See the patchset as different logical groups (that may be split later):

  * patches 1 to 5: introduce the dsa_port structure to DSA drivers

  * patches 6 to 11: put the bridge device in the dsa_port structure and allow
    the DSA drivers to get rid of their private bridge_dev pointer

  * patches 12 to 16: introduce tree-wide operations. Driver are now aware of
    cross-chip port operations

  * patches 17 to 20: implement cross-chip hardware bridging in mv88e6xxx

A branch is available here [2] and a debugfs patch is maintained here [3] in
order to inspect the Marvell switch's internal structures, such as the PVT.

Many things remains to do after this, such as using dsa_port_is_{cpu,dsa}
helpers, getting rid of dst->switches and ds->ports in favor of their related
switch and port lists, and introduce dynamic number of switches and ports.

[1] https://lkml.org/lkml/2016/4/20/733
[2] https://github.com/vivien/linux/tree/dsa/dev
[3] https://github.com/vivien/linux/commit/da33b1a698fef3a66515a05e2b9f31d0279a89d4.patch

Cheers,

Vivien Didelot (20):
  net: dsa: introduce a dsa_port structure
  net: dsa: be consistent with NETDEV_CHANGEUPPER
  net: dsa: pass dsa_port down to drivers bridge ops
  net: dsa: pass dsa_port down to drivers FDB ops
  net: dsa: pass dsa_port down to drivers VLAN ops
  net: dsa: move bridge device in dsa_port
  net: dsa: list ports in switch
  net: dsa: bcm_sf2: use bridge device from dsa_port
  net: dsa: mv88e6xxx: check HW vlan with dsa_port
  net: dsa: mv88e6xxx: setup a dsa_port
  net: dsa: mv88e6xxx: use bridge from dsa_port
  net: dsa: rename dst->ds to dst->switches
  net: dsa: list switches in tree
  net: dsa: add tree-wide bridge ops
  net: dsa: add tree-wide FDB ops
  net: dsa: add tree-wide VLAN ops
  net: dsa: mv88e6xxx: factorize port bridge change
  net: dsa: mv88e6xxx: add flags to info
  net: dsa: mv88e6xxx: conditionally init PVT
  net: dsa: mv88e6xxx: setup PVT on cross-chip ops

 drivers/net/dsa/bcm_sf2.c   |  92 +++++-----
 drivers/net/dsa/bcm_sf2.h   |   2 -
 drivers/net/dsa/mv88e6352.c |   1 +
 drivers/net/dsa/mv88e6xxx.c | 397 ++++++++++++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx.h |  41 +++--
 include/net/dsa.h           |  57 +++++--
 net/dsa/Makefile            |   2 +-
 net/dsa/dsa.c               |  25 ++-
 net/dsa/dsa_priv.h          |  37 +++--
 net/dsa/slave.c             | 283 +++++++++----------------------
 net/dsa/tag_brcm.c          |   6 +-
 net/dsa/tag_dsa.c           |  10 +-
 net/dsa/tag_edsa.c          |  10 +-
 net/dsa/tag_trailer.c       |   4 +-
 net/dsa/tree.c              | 187 +++++++++++++++++++++
 15 files changed, 751 insertions(+), 403 deletions(-)
 create mode 100644 net/dsa/tree.c

-- 
2.8.0
