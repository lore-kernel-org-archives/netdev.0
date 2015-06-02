From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 0/9] net: dsa: mv88e6352: add 802.1q VLAN support
Date: Mon,  1 Jun 2015 21:27:41 -0400
Message-ID: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Scott Feldman" <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"Chris Healy" <cphealy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset brings support for the 802.1q and VLAN operations to the Marvell
88E6352 switch and compatibles.

The patch 1/9 adds more glue between switchdev and DSA.

Patches 2/9 to 4/9 add the VLAN operations to DSA and the mv88e6xxx family of
switches.

Patches 5/9 to 9/9 is the necessary configuration that I figured out during the
VLAN tests I did. So far, I was able to confirm the following scenarios:

  * Port untagged to Port untagged
  * Port untagged to Port tagged
  * Port tagged to Port tagged
  * Port untagged to CPU tagged
  * Port tagged to CPU tagged
  * CPU tagged to port tagged

>From the userspace, here's a few commands I use to start using VLANs:

    # create bridge
    ip link set dev eth0 up
    ip link add name br0 type bridge
    echo 1 > /sys/class/net/br0/bridge/vlan_filtering
    ip link set dev br0 up

    # setup switch ports
    for i in $(seq 0 4); do
      ip link set dev swp$i up master br0
      # HACK: bridge assumes the following but doesn't call ndo_bridge_setlink
      bridge vlan add vid 1 pvid untagged dev swp$i master self
    done

Best,
 -v

Vivien Didelot (9):
  net: dsa: add basic support for switchdev obj
  net: dsa: add basic support for VLAN operations
  net: dsa: mv88e6xxx: add support for VTU ops
  net: dsa: mv88e6352: add support for VLAN
  net: dsa: mv88e6352: disable mirroring
  net: dsa: mv88e6352: allow egress of unknown multicast
  net: dsa: mv88e6352: lock CPU port from learning addresses
  net: dsa: mv88e6352: set port 802.1Q mode to Secure
  net: dsa: fix EDSA frame from hwaccel frame

 drivers/net/dsa/mv88e6352.c |  12 +-
 drivers/net/dsa/mv88e6xxx.c | 303 ++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx.h |  39 ++++++
 include/net/dsa.h           |   7 +
 net/dsa/slave.c             | 100 ++++++++++++++-
 net/dsa/tag_edsa.c          |   5 +
 6 files changed, 446 insertions(+), 20 deletions(-)

-- 
2.4.1
