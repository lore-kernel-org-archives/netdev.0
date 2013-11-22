From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/8 v7] Open vSwitch upcall optimiziations
Date: Fri, 22 Nov 2013 17:56:03 +0100
Message-ID: <cover.1385137618.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51453 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab3KVQ4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 11:56:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reposting this before the merge window as it will go through Jesse's
tree.

Given jumbo frames, the capacity of the slow path is improved by 
a factor of 2.5x.

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

Thomas Graf (8):
  genl: Add genlmsg_new_unicast() for unicast message allocation
  netlink: Avoid netlink mmap alloc if msg size exceeds frame size
  openvswitch: Enable memory mapped Netlink i/o
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Allow user space to announce ability to accept unaligned
    Netlink messages
  openvswitch: Allow update of dp with OVS_DP_CMD_NEW if NLM_F_REPLACE
    is set
  openvswitch: Drop user features if old user space attempted to create
    datapath
  openvswitch: Use skb_zerocopy() for upcall

 include/linux/skbuff.h               |   3 +
 include/net/genetlink.h              |   4 +
 include/uapi/linux/openvswitch.h     |  14 ++-
 net/core/skbuff.c                    |  85 ++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c |  59 +----------
 net/netlink/af_netlink.c             |   4 +
 net/netlink/genetlink.c              |  21 ++++
 net/openvswitch/datapath.c           | 192 ++++++++++++++++++++++-------------
 net/openvswitch/datapath.h           |   2 +
 9 files changed, 255 insertions(+), 129 deletions(-)

-- 
1.8.3.1
