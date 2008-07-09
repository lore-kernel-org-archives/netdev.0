From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/08]: VLAN update
Date: Wed,  9 Jul 2008 14:09:45 +0200 (MEST)
Message-ID: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58609 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbYGIMJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches include an updated set of the VLAN packet socket fixes,
now also supporting VLAN TCI delivery to userspace using mmaped packet
sockets, as well as a patch to add ->get_flags ethtool support and
a few minor cleanup patches.

To recap the VLAN packet socket problems fixed by these patches:

- With hardware tagging, outgoing packets are visible without
  the VLAN header, while with software tagging the full VLAN
  header is visible

- With hardware stripping, incoming packets for locally configured
  VLANs appear on the VLAN device without being visible on the
  underlying device. Packets for unknown VLANs are not visible
  at all. Without hardware stripping, all VLAN packets are visible
  on the underlying device.

The patches move the VLAN TCI from skb->cb to a new skb member
to avoid clashes with qdiscs and packet sockets use of skb->cb.
On the TX path this is enough to make sure that packet sockets
can be made aware of the VLAN TCI. On the hardware accelerated
RX path, we also store the VLAN TCI in the skb and manually invoke
the ptype_all handlers. The packet socket code stores the TCI in
either the auxdata (for regular packet sockets) or the new
tpacket2_hdr (for mmaped packet sockets) and delivers it to
userspace, where it can be used to reconstruct the VLAN header.

The only remaining problem is that socket filters contructed for
VLAN headers don't work properly since no header is present.
Since with the approach taken by these patches, userspace has
to be aware of VLAN acceleration anyway, it seems reasonable
to add a new filter instruction for getting the VLAN TCI from
the skb and expect it to construct its filters accordingly.
This is not done so far however, other suggestions are still
welcome :)


 include/linux/if_packet.h |   23 ++++++
 include/linux/if_vlan.h   |   31 ++------
 include/linux/netdevice.h |    1 +
 include/linux/skbuff.h    |    3 +
 net/8021q/vlan.c          |    8 +--
 net/8021q/vlan_core.c     |    4 +
 net/8021q/vlan_dev.c      |  116 +++++++----------------------
 net/8021q/vlanproc.c      |   11 +--
 net/core/dev.c            |   27 +++++++
 net/core/skbuff.c         |    3 +
 net/packet/af_packet.c    |  181 ++++++++++++++++++++++++++++++++++++--------
 11 files changed, 248 insertions(+), 160 deletions(-)

Patrick McHardy (8):
      vlan: Don't store VLAN tag in cb
      vlan: deliver packets received with VLAN acceleration to network taps
      packet: support extensible, 64 bit clean mmaped ring structure
      packet: deliver VLAN TCI to userspace
      vlan: ethtool ->get_flags support
      vlan: clean up vlan_dev_hard_header()
      vlan: clean up hard_start_xmit functions
      vlan: remove unnecessary include statements
