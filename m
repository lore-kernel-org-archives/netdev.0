From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 0/4] bridge: 802.1ad vlan protocol support
Date: Mon,  9 Jun 2014 20:34:43 +0900
Message-ID: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:60940 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbaFILfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 07:35:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently bridge vlan filtering doesn't work fine with 802.1ad protocol.
Only if a bridge is configured without pvid, the bridge receives only
802.1ad tagged frames and no STP is used, it will work.
Otherwise:
- If pvid is configured, it can put only 802.1Q tags but cannot put 802.1ad
  tags.
- If 802.1Q and 802.1ad tagged frames arrive in mixture, it applies filtering
  regardless of their protocols.
- While an 802.1ad bridge should use another mac address for STP BPDU and
  should forward customer's BPDU frames, it can't.
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
- I think the typical usage of an 802.1ad bridge is segregating 802.1Q tagged
  traffic (like what is described above), and this doesn't need the ability to
  be set protocols per port. Also, If a bridge has many ports and it supports
  per-port setting, we might have to make much more extra configurations to
  change protocols of all ports.

- I assume that the main perpose to set protocol per port is to assign S-VID
  according to C-VID, or to realize two logical bridges (one is an 802.1Q
  filtering bridge and the other is an 802.1ad filtering bridge) in one bridge.
  The former usually needs additional features such as vlan id mapping, and
  is likely to make bridge's code complicated. If a user wants, such enhanced
  features can be accomplished by a combination of multiple bridges, so it is
  not absolutely necessary to implement these features in a bridge itself.
  The latter is simply unnecessary because we can easily make two bridges of
  which one is an 802.1Q bridge and the other is an 802.1ad bridge.

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

Changes:
RFC -> v1:
- Add S-TAG tx offload.
- Remove a fix around stacked vlan which has already been fixed.
- Take into account Bridge Group Addresses.
- Separate handling of protocol-mismatch from br_vlan_get_tag().
- Change the way to set vlan_proto from netlink to sysfs because no other
  existing configuration per bridge can be set by netlink.

Toshiaki Makita (4):
  bridge: Add 802.1ad tx vlan acceleration
  bridge: Prepare for 802.1ad vlan filtering support
  bridge: Consider the Nearest Customer Bridge group addresses
  bridge: Support 802.1ad vlan filtering

 net/bridge/br_device.c   |   6 ++-
 net/bridge/br_input.c    |  15 +++++-
 net/bridge/br_private.h  |  18 +++++++
 net/bridge/br_sysfs_br.c |  18 +++++++
 net/bridge/br_vlan.c     | 137 ++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 179 insertions(+), 15 deletions(-)

-- 
1.8.1.2
