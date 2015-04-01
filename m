From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 00/14] get rid of skb->nf_bridge pointer
Date: Wed,  1 Apr 2015 22:36:26 +0200
Message-ID: <1427920600-20366-1-git-send-email-fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42839 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752835AbbDAUgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ netdev hackers are encouraged to look at patches #2 and #11 specifically,
  those are the ones with largest impact outside netfilter land ]

Remove skb->nf_bridge pointer.

Unfortunately we still need some way to decide if skb is bridged
or not, else kfree_skb, skb_clone etc. would have to do costly lookups
in bridge netfilter.

We use a 2 bit state field in the skb for this purpose.
If its zero, skb is not bridged (same as skb->nf_bridge == NULL
in current kernel).

nf_bridge_info is stored in an rhashtable; bridge netfilter
and the few other places (nfqueue, nflog, physdev match) that need
to access bridge netfilter data do on-demand lookups in an rhashtable
to access the data associated with a bridged skb.

skb_clone and skb_copy will call into netfilter core
helpers for bridged skbs to duplicate the information if needed.
Likewise, kfree_skb removes and frees the bridge netfilter meta data
as well if needed.

In order to avoid those lookups where we're dealing with non-bridged
skbs, we store 2 bit state field in the skb.

Tested, on host connected to kvm-bridge:

ping -s $bignum $ip_behind_bridge

on bridge:
-j REDIRECT
-j DNAT --to-destination $ip_behind_bridge
-m physdev match with in/outdev match in FORWARD and INPUT (indev only)
- same w. active -j NFQUEUE.

 Patch 11 substitutes the pointer for on-demand lookups, most of the
 other patches prepare for this change by adding helpers and splitting
 state information into 'public' and 'bridge netfilter private'.

 The alternative to the rhashtable is to store the bridge netfilter
 metadata in skb->cb[], but there are some caveats since we need
 such metadata to survive local delivery too (else we'd break use of
 physdev match in INPUT).

 This is why external store was chosen.

 Feedback and suggestions welcome.

 include/linux/netfilter.h                  |    8 
 include/linux/netfilter_bridge.h           |  104 +++++-
 include/linux/skbuff.h                     |   87 ++---
 include/net/ip.h                           |    4 
 net/bridge/br_device.c                     |   19 -
 net/bridge/br_netfilter.c                  |  482 ++++++++++++++++++++---------
 net/bridge/br_private.h                    |    2 
 net/core/skbuff.c                          |    5 
 net/ipv4/ip_output.c                       |   30 +
 net/ipv4/netfilter/nf_defrag_ipv4.c        |    3 
 net/ipv4/netfilter/nf_reject_ipv4.c        |    6 
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c  |    3 
 net/ipv6/netfilter/nf_reject_ipv6.c        |    6 
 net/netfilter/core.c                       |   49 ++
 net/netfilter/ipset/ip_set_hash_netiface.c |   32 +
 net/netfilter/nf_log_common.c              |    7 
 net/netfilter/nf_queue.c                   |   22 -
 net/netfilter/nfnetlink_log.c              |   17 -
 net/netfilter/nfnetlink_queue_core.c       |   34 +-
 net/netfilter/xt_physdev.c                 |   36 +-
 20 files changed, 670 insertions(+), 286 deletions(-)
