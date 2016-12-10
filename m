From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net 0/3] net: bridge: fast ageing on topology change
Date: Sat, 10 Dec 2016 13:44:26 -0500
Message-ID: <20161210184429.31600-1-vivien.didelot@savoirfairelinux.com>
Cc: Ido Schimmel <idosch@mellanox.com>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

802.1D [1] specifies that the bridges in a network must use a short
value to age out dynamic entries in the Filtering Database for a period,
once a topology change has been communicated by the root bridge.

This patchset fixes this for the in-kernel STP implementation.

Once the topology change flag is set in a net_bridge instance, the
ageing time value is shorten to twice the forward delay used by the
topology.

When the topology change flag is cleared, the ageing time configured for
the bridge is restored.

To accomplish that, a new bridge_ageing_time member is added to the
net_bridge structure, to store the user configured bridge ageing time.

Two helpers are added to offload the ageing time and set the topology
change flag in the net_bridge instance. Then the required logic is added
in the topology change helper if in-kernel STP is used.

This has been tested on the following topology:

    +--------------+
    | root bridge  |
    |  1  2  3  4  |
    +--+--+--+--+--+
       |  |  |  |      +--------+
       |  |  |  +------| laptop |
       |  |  |         +--------+
    +--+--+--+-----+
    |  1  2  3     |
    | slave bridge |
    +--------------+

When unplugging/replugging the laptop, the slave bridge (under test)
gets the topology change flag sent by the root bridge, and fast ageing
is triggered on the bridges. Once the topology change timer of the root
bridge expires, the topology change flag is cleared and the configured
ageing time is restored on the bridges.

A similar test has been done between two bridges under test.
When changing the forward delay of the root bridge with:

    # echo 3000 > /sys/class/net/br0/bridge/forward_delay

the ageing time correctly changes on both bridges from 300s to 60s while
the TOPOLOGY_CHANGE flag is present.

[1] "8.3.5 Notifying topology changes",
    http://profesores.elo.utfsm.cl/~agv/elo309/doc/802.1D-1998.pdf

No change since RFC: https://lkml.org/lkml/2016/10/19/828

Vivien Didelot (3):
  net: bridge: add helper to offload ageing time
  net: bridge: add helper to set topology change
  net: bridge: shorten ageing time on topology change

 net/bridge/br_device.c      |  2 +-
 net/bridge/br_private.h     |  4 ++-
 net/bridge/br_private_stp.h |  1 +
 net/bridge/br_stp.c         | 65 ++++++++++++++++++++++++++++++++++++++-------
 net/bridge/br_stp_if.c      | 14 +++-------
 net/bridge/br_stp_timer.c   |  2 +-
 6 files changed, 65 insertions(+), 23 deletions(-)

-- 
2.10.2
