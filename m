From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v3 0/7] Compact netfilter hooks list
Date: Wed, 21 Sep 2016 11:35:00 -0400
Message-ID: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:35957 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754251AbcIUPfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:35:41 -0400
Received: by mail-yw0-f195.google.com with SMTP id v2so3078415ywg.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:35:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series makes a simple change to shrink the netfilter hook list
from a double linked list, to a singly linked list.  Since the hooks
are always traversed in-order, there is no need to maintain a previous
pointer.

This was jointly developed by Florian Westphal.

It has been tested with RCU debugging and lockdep debugging enabled.  A
more rigorous stress test is underway, but this is being submitted for
early feedback.

Apologies for the size of patch 7/7, particularly the refactor in
nf_hook_thresh.  It didn't make sense to split the refactor out at the
time, but if desired, it can be reworked.

After this series, the hook entry head in nf_hook_state will not always
be a valid pointer.  I don't know if the circular nature of the hook list
could have ever been abused with a string of custom queue and non-queue
hook handlers.  If so, this patch would likely break that behavior.

Previous series can be found at:
http://www.spinics.net/lists/netdev/msg386080.html

Aaron Conole (5):
  netfilter: call nf_hook_ingress with rcu_read_lock
  nf_hook_slow: Remove explicit rcu_read_lock
  nf_register_net_hook: Only allow sane values
  nf_queue_handler: whitespace cleanup
  netfilter: replace list_head with single linked list

Florian Westphal (2):
  netfilter: bridge: add and use br_nf_hook_thresh
  netfilter: call nf_hook_state_init with rcu_read_lock held

 include/linux/netdevice.h                      |   2 +-
 include/linux/netfilter.h                      |  61 ++++++----
 include/linux/netfilter_ingress.h              |  16 ++-
 include/net/netfilter/br_netfilter.h           |   6 +
 include/net/netfilter/nf_queue.h               |   9 +-
 include/net/netns/netfilter.h                  |   2 +-
 net/bridge/br_netfilter_hooks.c                |  53 +++++++--
 net/bridge/br_netfilter_ipv6.c                 |  12 +-
 net/bridge/netfilter/ebt_redirect.c            |   2 +-
 net/bridge/netfilter/ebtables.c                |   2 +-
 net/core/dev.c                                 |   7 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   2 +-
 net/netfilter/core.c                           | 152 ++++++++++++++++---------
 net/netfilter/nf_conntrack_core.c              |   2 +-
 net/netfilter/nf_conntrack_h323_main.c         |   2 +-
 net/netfilter/nf_conntrack_helper.c            |   2 +-
 net/netfilter/nf_internals.h                   |  10 +-
 net/netfilter/nf_queue.c                       |  18 +--
 net/netfilter/nfnetlink_cthelper.c             |   2 +-
 net/netfilter/nfnetlink_log.c                  |   6 +-
 net/netfilter/nfnetlink_queue.c                |  10 +-
 net/netfilter/xt_helper.c                      |   2 +-
 25 files changed, 249 insertions(+), 137 deletions(-)

-- 
2.7.4
