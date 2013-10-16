From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net 0/4] bridge: Fix problems around the PVID
Date: Wed, 16 Oct 2013 17:07:12 +0900
Message-ID: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:44171 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3JPIIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 04:08:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There seem to be some undesirable behaviors related with PVID.
1. It has no effect assigning PVID to a port. PVID cannot be applied
to any frame regardless of whether we set it or not.
2. FDB entries learned via frames applied PVID are registered with
VID 0 rather than VID value of PVID.
3. We can set 0 or 4095 as a PVID that are not allowed in IEEE 802.1Q.
This leads interoperational problems such as sending frames with VID
4095, which is not allowed in IEEE 802.1Q, and treating frames with VID
0 as they belong to VLAN 0, which is expected to be handled as they have
no VID according to IEEE 802.1Q.

Note: 2nd and 3rd problems are potential and not exposed unless 1st problem
is fixed, because we cannot activate PVID due to it.

This is my analysis for each behavior.
1. We are using VLAN_TAG_PRESENT bit when getting PVID, and not when
adding/deleting PVID.
It can be fixed in either way using or not using VLAN_TAG_PRESENT,
but I think the latter is slightly more efficient.

2. We are setting skb->vlan_tci with the value of PVID but the variable
vid, which is used in FDB later, is set to 0 at br_allowed_ingress()
when untagged frames arrive at a port with PVID valid. I'm afraid that
vid should be updated to the value of PVID if PVID is valid.

3. According to IEEE 802.1Q-2011 (6.9.1 and Table 9-2), we cannot use
VID 0 or 4095 as a PVID.
It looks like that there are more stuff to consider.

- VID 0:
VID 0 shall not be configured in any FDB entry and used in a tag header
to indicate it is a 802.1p priority-tagged frame.
Priority-tagged frames should be applied PVID (from IEEE 802.1Q 6.9.1).
In my opinion, since we can filter incomming priority-tagged frames by
deleting PVID, we don't need to filter them by vlan_bitmap.
In other words, priority-tagged frames don't have VID 0 but have no VID,
which is the same as untagged frames, and should be filtered by unsetting
PVID.
So, not only we cannot set PVID as 0, but also we don't need to add 0 to
vlan_bitmap, which enables us to simply forbid to add vlan 0.

- VID 4095:
VID 4095 shall not be transmitted in a tag header. This VID value may be
used to indicate a wildcard match for the VID in management operations or
FDB entries (from IEEE 802.1Q Table 9-2).
In current implementation, we can create a static FDB entry with all
existing VIDs by not specifying any VID when creating it.
I don't think this way to add wildcard-like entries needs to change,
and VID 4095 looks no use and can be unacceptable to add.

Consequently, I believe what we should do for 3rd problem is below:
- Not allowing VID 0 and 4095 to be added.
- Applying PVID to priority-tagged (VID 0) frames.

Note: It has been descovered that another problem related to priority-tags
remains. If we use vlan 0 interface such as eth0.0, we cannot communicate
with another end station via a linux bridge.
This problem exists regardless of whether this patch set is applied or not
because we might receive untagged frames from another end station even if we
are sending priority-tagged frames.
This issue will be addressed by another patch set introducing an additional
egress policy, on which Vlad Yasevich is working.
See http://marc.info/?t=137880893800001&r=1&w=2 for detailed discussion.

Patch set follows this mail.
The order of patches is not the same as described above, because the way
to fix 1st problem is based on the assumption that we don't use VID 0 as
a PVID, which is realized by fixing 3rd problem.
(1/4)(2/4): Fix 3rd problem.
(3/4): Fix 1st problem.
(4/4): Fix 2nd probelm.

v2:
- Add descriptions about the problem related to priority-tags in cover letter.
- Revise patch comments to reference the newest spec.

Toshiaki Makita (4):
  bridge: Don't use VID 0 and 4095 in vlan filtering
  bridge: Apply the PVID to priority-tagged frames
  bridge: Fix the way the PVID is referenced
  bridge: Fix updating FDB entries when the PVID is applied

 net/bridge/br_fdb.c     |   4 +-
 net/bridge/br_netlink.c |   2 +-
 net/bridge/br_private.h |   4 +-
 net/bridge/br_vlan.c    | 125 ++++++++++++++++++++++++++----------------------
 4 files changed, 71 insertions(+), 64 deletions(-)

-- 
1.8.1.2
