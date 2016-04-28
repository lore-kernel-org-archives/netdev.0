From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 0/9] netfilter: remove per-netns conntrack tables, part 1
Date: Thu, 28 Apr 2016 19:13:39 +0200
Message-ID: <1461863628-23350-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ CCing netdev so netns folks can have a look too ]

This patch series removes the per-netns connection tracking tables.
All conntrack objects are then stored in one global global table.

This avoids the infamous 'vmalloc' when lots of namespaces are used:
We no longer allocate a new conntrack table for each namespace (with 64k
size this saves 512kb of memory per netns).

- net namespace address is made part of conntrack hash, to spread
  conntracks over entire table even if netns has overlapping ip addresses.
- lookup and iterators net_eq() to skip conntracks living in a different
  namespace.

Only the main conntrack table is converted here:
NAT bysrc and expectation hashes are still per namespace (will be unified
in a followup series).  Also, this retains the per-namespace kmem cache
for the conntrack objects.  This will also be resolved in a followup series.

Comments welcome.

 include/net/netfilter/nf_conntrack_core.h             |   11 
 include/net/netns/conntrack.h                         |    2 
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c        |    2 
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |   38 ++
 net/netfilter/nf_conntrack_core.c                     |  233 +++++++++---------
 net/netfilter/nf_conntrack_helper.c                   |    6 
 net/netfilter/nf_conntrack_netlink.c                  |   11 
 net/netfilter/nf_conntrack_standalone.c               |   13 -
 net/netfilter/nf_nat_core.c                           |    2 
 net/netfilter/nfnetlink_cttimeout.c                   |    6 
 10 files changed, 179 insertions(+), 145 deletions(-)

