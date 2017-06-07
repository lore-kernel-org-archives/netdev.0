From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/5] net: dsa: add cross-chip VLAN support
Date: Wed,  7 Jun 2017 18:12:12 -0400
Message-ID: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current code in DSA does not support cross-chip VLAN. This means
that in a multi-chip environment such as this one (similar to ZII Rev B)

         [CPU].................... (mdio)
    (eth0) |   :       :          :
          _|_____    _______    _______
         [__sw0__]--[__sw1__]--[__sw2__]
          |  |  |    |  |  |    |  |  |
          v  v  v    v  v  v    v  v  v
          p1 p2 p3   p4 p5 p6   p7 p8 p9 

adding a VLAN to p9 won't be enough to reach the CPU, until at least one
port of sw0 and sw1 join the VLAN as well and become aware of the VID.

This patchset makes the DSA core program the VLAN on the CPU and DSA
links itself, which brings seamlessly cross-chip VLAN support to DSA.

With this series applied*, the hardware VLAN tables of a 3-switch setup
look like this after adding a VLAN to only one port of the end switch:

    # cat /sys/class/net/br0/bridge/default_pvid 
    42
    # cat /sys/kernel/debug/mv88e6xxx/sw{0,1,2}/vtu
    # ip link set up master br0 dev lan6
    # cat /sys/kernel/debug/mv88e6xxx/sw{0,1,2}/vtu
     VID  FID  SID  0  1  2  3  4  5  6
      42    1    0  x  x  x  x  x  =  =
     VID  FID  SID  0  1  2  3  4  5  6
      42    1    0  x  x  x  x  x  =  =
     VID  FID  SID  0  1  2  3  4  5  6  7  8  9
      42    1    0  u  x  x  x  x  x  x  x  x  =

('x' is excluded, 'u' is untagged, '=' is unmodified DSA and CPU ports.)

Completely removing a VLAN entry (which is currently the responsibility
of drivers anyway) is not supported yet since it requires some caching.

(*) the output is shown from this out-of-tree debugfs patch:
https://github.com/vivien/linux/commit/7b61a684b9d6b6a499135a587c7f62a1fddceb8b.patch

Changes in v2:
  - canonical incrementation (port++ instead of ++port)
  - check CPU and DSA ports before purging a VLAN
  - add Reviewed-by tags

Vivien Didelot (5):
  net: dsa: mv88e6xxx: define membership on VLAN add
  net: dsa: check VLAN capability of every switch
  net: dsa: add CPU and DSA ports as VLAN members
  net: dsa: mv88e6xxx: exclude all ports in new VLAN
  net: dsa: mv88e6xxx: do not skip ports on VLAN del

 drivers/net/dsa/mv88e6xxx/chip.c | 27 ++++++++++++++-------------
 net/dsa/switch.c                 | 30 ++++++++++++++++++++----------
 2 files changed, 34 insertions(+), 23 deletions(-)

-- 
2.13.1
