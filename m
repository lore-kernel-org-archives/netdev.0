From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/7] net: dsa: mv88e6xxx: add hardware VLAN support
Date: Thu, 13 Aug 2015 12:52:16 -0400
Message-ID: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Chris Healy" <cphealy@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

This patchset brings support to access hardware VLAN entries in DSA and
mv88e6xxx, through switchdev VLAN objects.

In the following example, ports swp[0-2] belong to bridge br0, and ports
swp[3-4] belong to bridge br1. Here's an example of what can be achieved
after this patchset:

    # bridge vlan add dev swp1 vid 100 master
    # bridge vlan add dev swp2 vid 100 master
    # bridge vlan add dev swp3 vid 100 master
    # bridge vlan add dev swp4 vid 100 master
    # bridge vlan del dev swp1 vid 100 master

The above commands correctly programmed hardware VLAN 100 for port swp2,
while ports swp3 and swp4 use software VLAN 100, as shown with:

    # bridge vlan
    port	vlan ids
    swp0	None
    swp0
    swp1	None
    swp1
    swp2	 100
    
    swp2	 100
    
    swp3	 100
    
    swp3
    swp4	 100
    
    swp4
    br0	None
    br1	None

Assuming that port 5 is the CPU port, the hardware VLAN table would
contain the following data:

    VID  FID  SID  0  1  2  3  4  5  6
    100    8    0  x  x  t  x  x  t  x

Where 'x' means excluded, and 't' means tagged.

Also, adding an FDB entry to VLAN 100 for port swp2 like this:

    # bridge fdb add 3c:97:0e:11:6e:30 dev swp2 vlan 100

Would result in the following example output:

    # bridge fdb
    # 01:00:5e:00:00:01 dev eth0 self permanent
    # 01:00:5e:00:00:01 dev eth1 self permanent
    # 00:50:d2:10:78:15 dev swp0 master br0 permanent
    # 00:50:d2:10:78:15 dev swp2 vlan 100 master br0 permanent
    # 3c:97:0e:11:6e:30 dev swp2 vlan 100 self static
    # 00:50:d2:10:78:15 dev swp3 master br1 permanent
    # 00:50:d2:10:78:15 dev swp3 vlan 100 master br1 permanent

And the Address Translation Unit would contain:

    DB   T/P  Vec State Addr
    008  Port 004   e   3c:97:0e:11:6e:30

Cheers,
-v

Vivien Didelot (7):
  net: dsa: add support for switchdev VLAN objects
  net: dsa: mv88e6xxx: flush VTU and STU entries
  net: dsa: mv88e6xxx: add VLAN Get Next support
  net: dsa: mv88e6xxx: add VLAN support to FDB dump
  net: dsa: mv88e6xxx: add VLAN Purge support
  net: dsa: mv88e6xxx: add VLAN Load support
  net: dsa: mv88e6xxx: use port 802.1Q mode Secure

 drivers/net/dsa/mv88e6352.c |   5 +
 drivers/net/dsa/mv88e6xxx.c | 510 +++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx.h |  45 ++++
 include/net/dsa.h           |  11 +
 net/dsa/slave.c             | 158 ++++++++++++++
 5 files changed, 720 insertions(+), 9 deletions(-)

-- 
2.5.0
