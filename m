From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/6 v9] Open vSwitch zercopy upcall optimiziation
Date: Fri, 13 Dec 2013 15:22:16 +0100
Message-ID: <cover.1386943635.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, eric.dumazet@gmail.com, fleitner@redhat.com,
	ffusco@redhat.com, dborkmann@redhat.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:43930 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab3LMOWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 09:22:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series implementing a zerocopy method for OVS upcall messages. Based
on top of commit: (''openvswitch: Enable memory mapped Netlink i/o'')

Thomas Graf (6):
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Allow user space to announce ability to accept unaligned
    Netlink messages
  openvswitch: Drop user features if old user space attempted to create
    datapath
  openvswitch: Pass datapath into userspace queue functions
  openvswitch: Use skb_zerocopy() for upcall
  openvswitch: Compute checksum in skb_gso_segment() if needed

 include/linux/skbuff.h               |   3 +
 include/uapi/linux/openvswitch.h     |  14 ++++-
 net/core/skbuff.c                    |  85 ++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c |  59 ++-----------------
 net/openvswitch/datapath.c           | 106 ++++++++++++++++++++++++++---------
 net/openvswitch/datapath.h           |   2 +
 6 files changed, 185 insertions(+), 84 deletions(-)

---
V9: - Dropped patches 1-3 (merged)
    - Dropped skb argument from upcall_msg_size()
    - Dropped dp_ifindex and net argument from all queue functions
    - Added patch to remove NETIF_F_HW_CSUM from __skb_gso_segment()
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
