From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/8 v8] Open vSwitch upcall optimiziations
Date: Sat, 30 Nov 2013 13:21:29 +0100
Message-ID: <cover.1385813891.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:59171 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3K3MVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 07:21:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reposting this before the merge window as it will go through Jesse's
tree.

Given jumbo frames, the capacity of the slow path is improved by 
a factor of 2.5x.

V8: - Dropped patch adding NLM_F_REPLACE support, I'll pursue this in a
      separate patch series. Addresses Jesse's comments.
    - Improved comment describing OVS_DATAPATH_VERSION bump.
V7: - removed unintential kernel-doc comment
    - WARN_ONCE() -> WARN(), message on single line, added \n
V6: - Added memory mapped netlink i/o support
    - Drop user_features if old user space not aware of user features
      reuses an existing datapath
V5: - Removed padding requirement in user space
    - Added OVS_DP_F_UNALIGNED flag let user space signal ability to
      receive unaligned Netlink messages, fall back to linear copy
      otherwise.
V4: - Daniel Borkmann pointed out that the style in skbuff.h has changed
      in net-next, adapted to no longer using extern in headers.
V3: - Removed unneeded alignment of nlmsg_len after padding
V2: - Added skb_zerocopy_headlen() to calculate headroom of destination
      buffer. This also takes care of the from->head_frag issue.
    - Attribute alignment for frag_list case
    - API documentation
    - performance data for CHECKSUM_PARTIAL tx case

Thomas Graf (7):
  genl: Add genlmsg_new_unicast() for unicast message allocation
  netlink: Avoid netlink mmap alloc if msg size exceeds frame size
  openvswitch: Enable memory mapped Netlink i/o
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Allow user space to announce ability to accept unaligned
    Netlink messages
  openvswitch: Drop user features if old user space attempted to create
    datapath
  openvswitch: Use skb_zerocopy() for upcall

 include/linux/skbuff.h               |   3 +
 include/net/genetlink.h              |   4 +
 include/uapi/linux/openvswitch.h     |  14 +++-
 net/core/skbuff.c                    |  85 +++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c |  59 +--------------
 net/netlink/af_netlink.c             |   4 +
 net/netlink/genetlink.c              |  21 +++++
 net/openvswitch/datapath.c           | 143 ++++++++++++++++++++++++-----------
 net/openvswitch/datapath.h           |   2 +
 9 files changed, 236 insertions(+), 99 deletions(-)

-- 
1.8.3.1
