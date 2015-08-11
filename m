From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net-next 00/10] OVS conntrack support
Date: Tue, 11 Aug 2015 15:59:11 -0700
Message-ID: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The goal of this series is to allow OVS to send packets through the Linux
kernel connection tracker, and subsequently match on fields populated by
conntrack.

This version addresses the feedback from v2, mostly going over the dst
reference taking and skb metadata to check that they are restored correctly
after fragmentation.

This functionality is enabled through the CONFIG_OPENVSWITCH_CONNTRACK option.

The branch below has been updated with the corresponding userspace pieces:
https://github.com/justinpettit/ovs conntrack

v3: Better handling of skb->dst in output/fragmentation
    Address cases involving l2 metadata and checksums
    Make MRU types more consistent
    Better cleanup in error paths
    Fix sparse warnings

v2: Split out per-netns connlabel width setting functions
    Simplify reference tracking in output path.
    Handle output cases where flow key is invalidated by prior push/pop
    Store entire L2 header to apply to fragments
    Various bits of refactoring, comments, styles, log improvements
    Defer patch to scrub skb
    Rebase

v1: First non-RFC post.
    Fragment handling.
    Conntrack label support.

Joe Stringer (9):
  openvswitch: Serialize acts with original netlink len
  openvswitch: Move MASKED* macros to datapath.h
  ipv6: Export nf_ct_frag6_gather()
  dst: Add __skb_dst_copy() variation
  openvswitch: Add conntrack action
  netfilter: Always export nf_connlabels_replace()
  netfilter: connlabels: Export setting connlabel length
  openvswitch: Allow matching on conntrack label
  openvswitch: Allow attaching helpers to ct action

Justin Pettit (1):
  openvswitch: Allow matching on conntrack mark

 include/net/dst.h                           |   9 +-
 include/net/netfilter/nf_conntrack_labels.h |   4 +
 include/uapi/linux/openvswitch.h            |  49 ++
 net/ipv6/netfilter/nf_conntrack_reasm.c     |   1 +
 net/netfilter/nf_conntrack_labels.c         |  34 +-
 net/netfilter/xt_connlabel.c                |  16 +-
 net/openvswitch/Kconfig                     |  11 +
 net/openvswitch/Makefile                    |   2 +
 net/openvswitch/actions.c                   | 232 ++++++++--
 net/openvswitch/conntrack.c                 | 688 ++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h                 | 126 +++++
 net/openvswitch/datapath.c                  |  74 ++-
 net/openvswitch/datapath.h                  |  12 +
 net/openvswitch/flow.c                      |   5 +
 net/openvswitch/flow.h                      |   9 +
 net/openvswitch/flow_netlink.c              | 103 ++++-
 net/openvswitch/flow_netlink.h              |   4 +-
 net/openvswitch/vport.c                     |   1 +
 18 files changed, 1299 insertions(+), 81 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

-- 
2.1.4
