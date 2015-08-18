From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv4 net-next 00/10] OVS conntrack support
Date: Tue, 18 Aug 2015 16:39:38 -0700
Message-ID: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The goal of this series is to allow OVS to send packets through the Linux
kernel connection tracker, and subsequently match on fields populated by
conntrack.

This version addresses the feedback from v3, primarily shifting the masked
set of connmark and connlabel to nest under the conntrack action. This
simplifies the API from the perspective of the SET_FIELD actions by not
requiring special-casing for these fields. The fields are still maskable, but
must be set as part of conntrack action execution. Some related refactoring and
code simplifications have been rolled in due to these changes as well.

This functionality is enabled through the CONFIG_OPENVSWITCH_CONNTRACK option.

The branch below has been updated with the corresponding userspace pieces:
https://github.com/joestringer/ovs dev/ct_20150818

v4: Shift ability to set ct_mark/ct_label into ACTION_ATTR_CT.
    Streamline fetching/setting conntrack fields.
    Update some documentation.
    Add acks from v2/v3 review.

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

Joe Stringer (10):
  openvswitch: Serialize acts with original netlink len
  openvswitch: Move MASKED* macros to datapath.h
  ipv6: Export nf_ct_frag6_gather()
  dst: Add __skb_dst_copy() variation
  openvswitch: Add conntrack action
  openvswitch: Allow matching on conntrack mark
  netfilter: Always export nf_connlabels_replace()
  netfilter: connlabels: Export setting connlabel length
  openvswitch: Allow matching on conntrack label
  openvswitch: Allow attaching helpers to ct action

 include/net/dst.h                           |   9 +-
 include/net/netfilter/nf_conntrack_labels.h |   4 +
 include/uapi/linux/openvswitch.h            |  58 +++
 net/ipv6/netfilter/nf_conntrack_reasm.c     |   1 +
 net/netfilter/nf_conntrack_labels.c         |  34 +-
 net/netfilter/xt_connlabel.c                |  16 +-
 net/openvswitch/Kconfig                     |  11 +
 net/openvswitch/Makefile                    |   2 +
 net/openvswitch/actions.c                   | 229 +++++++--
 net/openvswitch/conntrack.c                 | 713 ++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h                 |  92 ++++
 net/openvswitch/datapath.c                  |  74 ++-
 net/openvswitch/datapath.h                  |  12 +
 net/openvswitch/flow.c                      |   2 +
 net/openvswitch/flow.h                      |   9 +
 net/openvswitch/flow_netlink.c              | 103 +++-
 net/openvswitch/flow_netlink.h              |   4 +-
 net/openvswitch/vport.c                     |   1 +
 18 files changed, 1293 insertions(+), 81 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

-- 
2.1.4
