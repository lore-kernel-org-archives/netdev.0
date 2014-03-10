From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC 0/3] bridge: 802.1ad vlan protocol support
Date: Mon, 10 Mar 2014 17:11:03 +0900
Message-ID: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
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

Currently bridge vlan filtering doesn't work fine with 802.1ad protocol.
Only if a bridge is configured without pvid and the bridge receives only
802.1ad single tagged frames, it will work.
Otherwise:
- If pvid is configured, it can put only 802.1Q tags but cannot put 802.1ad
  tags.
- If 802.1Q and 802.1ad tagged frames arrive in mixture, it applies filtering
  regardless of their protocols.
- If 802.1Q is used as inner vlan tag (second vlan tag in stacked vlan),
  not only outer tag but also inner tag will be stripped on an untagged port.
Thus, we can't properly handle frames once 802.1ad is used.

Handling 802.1ad is useful if we want to allow stacked vlans to be used,
e.g., guest VMs wants to use vlan tags and the host also wants to segregate
guest's traffic from other guests' by vlan tags.

Here is the image describing how to configure a bridge to filter VMs traffic.

         +-------+p/u   +-----+  +---------+
 +----+  |       |------|vnet0|--|User A VM|
 |eth0|--|802.1ad|      +-----+  +---------+
 +----+  |bridge |p/u   +-----+  +---------+
         |       |------|vnet1|--|User B VM|
         +-------+      +-----+  +---------+
p/u: pvid/untagged

This patch set enables us to set vlan protocols per bridge.
This tries to implement a bridge like S-VLAN component in IEEE 802.1Q-2011
spec.

Note that there is another possible implementation that sets vlan protocols
per port. Some HW switches seem to take that approach.
However, I think per-bridge approach is better, because;
- I think the typical usage is segregating 802.1Q tagged traffic (like what
  is described above), and this doesn't need the ability to be set protocols
  per port. Also, If a bridge has many ports and it supports per-port
  setting, we might have to make much more extra configurations to change
  protocols of all ports, in this case.

- I assume that the main perpose to set protocol per port is to assign S-VID
  according to C-VID, or to realize two logical bridges (one is an 802.1Q
  filtering bridge and another is an 802.1ad filtering bridge) in one bridge.
  The former usually needs additional features such as vlan id mapping, and
  is likely to be complicated. If a user wants, such enhanced features can be
  accomplished by a combination of multiple bridges, so it is not absolutely
  necessary to implement these features in a bridge itself.
  The latter is simply unnecessary because we can easily make two bridges
  of which one is an 802.1Q bridge and another is an 802.1ad bridge.

Here is an example of the enhanced feature that we can realize by using
multiple bridges and veth interfaces. This way is documented in
IEEE 802.1Q-2011 clause 15.4 (C-tagged service interface).

 +----+  +-------+p/u         +------+  +----+  +--+
 |eth0|--|802.1ad|----veth----|802.1Q|--|vnet|--|VM|
 +----+  |bridge |----veth----|bridge|  +----+  +--+
         +-------+p/u         +------+
p/u: pvid/untagged

In this configuration, we can map C-VIDs to any S-VID.
For example;
 C-VID 10 and 20 to S-VID 100
 C-VID 30 to S-VID 110
This is achieved through the 802.1Q bridge that forwards C-tagged frames to
proper ports of the 802.1ad bridge.

As this patch set is RFC, this includes a patch which is not appropriate for
net-next (patch 1). If this approach is acceptable, I will submit each patch
to appropriate tree. In this version, all patches except iproute2 (patch 4)
are based on net-next.

Toshiaki Makita (3):
  bridge: Fix handling stacked vlan tags
  bridge: Prepare for 802.1ad vlan filtering support
  bridge: Support 802.1ad vlan filtering

 include/uapi/linux/if_bridge.h |   2 +
 net/bridge/br_device.c         |   1 +
 net/bridge/br_input.c          |   2 +-
 net/bridge/br_netlink.c        |  67 ++++++++++++++-------
 net/bridge/br_private.h        |  30 +++++++++-
 net/bridge/br_vlan.c           | 128 ++++++++++++++++++++++++++++++-----------
 6 files changed, 170 insertions(+), 60 deletions(-)

-- 
1.8.1.2
