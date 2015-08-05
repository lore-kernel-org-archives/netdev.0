From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net-next 0/9] OVS conntrack support
Date: Tue,  4 Aug 2015 21:49:50 -0700
Message-ID: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
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

This version addresses the feedback from v2, mostly minor tidyups and a few
corner cases that were missed in v1. The biggest change is rather than
attempting to handle VLANs specifically for header reconstruction after
fragmentation, the entire L2 header is used as a more generic solution which
should handle more corner cases correctly.

This functionality is enabled through the CONFIG_OPENVSWITCH_CONNTRACK option.

The branch below has been updated with the corresponding userspace pieces:
https://github.com/justinpettit/ovs conntrack

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

Joe Stringer (8):
  openvswitch: Serialize acts with original netlink len
  openvswitch: Move MASKED* macros to datapath.h
  ipv6: Export nf_ct_frag6_gather()
  netfilter: connlabels: Export setting connlabel length
  openvswitch: Add conntrack action
  netfilter: Always export nf_connlabels_replace()
  openvswitch: Allow matching on conntrack label
  openvswitch: Allow attaching helpers to ct action

Justin Pettit (1):
  openvswitch: Allow matching on conntrack mark

 include/net/netfilter/nf_conntrack_labels.h |   4 +
 include/uapi/linux/openvswitch.h            |  49 ++
 net/ipv6/netfilter/nf_conntrack_reasm.c     |   1 +
 net/netfilter/nf_conntrack_labels.c         |  34 +-
 net/netfilter/xt_connlabel.c                |  16 +-
 net/openvswitch/Kconfig                     |  11 +
 net/openvswitch/Makefile                    |   2 +
 net/openvswitch/actions.c                   | 216 +++++++--
 net/openvswitch/conntrack.c                 | 688 ++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h                 | 126 +++++
 net/openvswitch/datapath.c                  |  75 ++-
 net/openvswitch/datapath.h                  |  12 +
 net/openvswitch/flow.c                      |   5 +
 net/openvswitch/flow.h                      |   9 +
 net/openvswitch/flow_netlink.c              | 102 ++++-
 net/openvswitch/flow_netlink.h              |   4 +-
 net/openvswitch/vport.c                     |   1 +
 17 files changed, 1276 insertions(+), 79 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

-- 
2.1.4
