From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6 RFC] Netfilter ingress support (v2)
Date: Wed, 29 Apr 2015 20:53:03 +0200
Message-ID: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55851 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbbD2Ssw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 14:48:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is a second round of the patchset to add Netfilter ingress support. This
new patchset introduces the necessary updates in 3 steps:

0) Three some small cleanups and preparation patches to support this.

1) Move the generic hook infrastructure to net/core/hooks.c. This avoids the
   dependency between the layer 2 and 3 hooks.

2) Add the Netfilter ingress hook just after the ingress qdisc. This introduces
   a penalty in the critical ingress path, but this is canceled in the next
   final step.

3) Port the ingress qdisc on top of the Netfilter ingress hook infrastructure
   as suggested by Patrick. This also provides flexible configurations since
   you can combine nftables with the existing ingress qdisc by placing the
   ingress filter chain before or after it. Another nice side effect of this
   change is that most of the qdisc ingress code that is embedded into
   net/core/dev.c now can be placed in net/sched/sch_ingress.c

This patchset provides the basic infrastructure to allow the use of nftables
from ingress, this just needs some extra boiler plate code in place to add the
new 'netdev' family already posted [2][1] on top of this. This opens the window
to existing nftables core features that are not present in qdisc ingress and
that can be used out-of-the-box, most relevantly:

1) Multi-dimensional key dictionary lookups: You can build tuples composed on N
   selectors (any kind of supported selector) and find the action to be
   performed on the packet in practical O(1).

	ip saddr . ip daddr . tcp dport { \
		2.2.2.2 . 3.3.3.3 . 80 : ...action here..., \
		..., \
	}

2) Arbitrary stateful flow tables. Basically, based on whatever tuple of
   selectors, we can dynamically create elements from the packet path that are
   inserted in the set. These elements store the internal state information,
   using the set extension infrastructure, so follow up packets match that
   element and update the internal stateful information.

        flow ip saddr . tcp dport counter

   where the content listing would look like:

	{
		1.2.3.4 . 80 : counter packets 1001 bytes 40040,
		1.2.3.4 . 443 : counter packets 123 bytes 3000,
		...
	}

3) Transactions: tc comes with no way to atomically update rulesets. This
   basically requires the introduction of a new batch-based interface similar
   to what we already have in nftables.

These would require in qdisc ingress a similar virtual machine approach to
address this in a generic fashion, a generic set infrastructure and a new
netlink interface to support batches, updates from the userspace side, which is
basically what nftables provides.

>From the userspace side: Nice syntax, well-defined grammar, unified interface,
support new protocols without kernel upgrades (You will only need to upgrade
the userspace nft tool to add native support protocol layout) among many others.

Wrt. performance numbers, the critical ingress path when no ingress filters
are registered is not affected:

* Without patchset:

  Result: OK: 11901881(c11901881+d0) usec, 10000000 (60byte,0frags)
  840203pps 403Mb/sec (403297440bps) errors: 10000000

* With patchset:

  Result: OK: 11885627(c11885627+d0) usec, 10000000 (60byte,0frags)
  841352pps 403Mb/sec (403848960bps) errors: 10000000

I have obtained these numbers using Alexei's rx patch for pktgen to benchmark
the netif_receive_core() path.

In summary, this provides the facility to keep both tc and netfilter in place,
while the user can select what they prefer to filter from ingress. Many scripts
on the Internet and documentation already show that many of them have been
using iptables from prerouting as alternative, when it came to IP traffic,
since long time already.

Patrick already indicated more arguments at:

	http://www.spinics.net/lists/netdev/msg325210.html

Thanks.

[1] http://patchwork.ozlabs.org/patch/460065/
[2] http://patchwork.ozlabs.org/patch/460062/

Pablo Neira Ayuso (6):
  netfilter: cleanup struct nf_hook_ops indentation
  netfilter: add hook list to nf_hook_state
  netfilter: add nf_hook_list_active()
  netfilter: move generic hook infrastructure into net/core/hooks.c
  net: add netfilter ingress hook
  net: move qdisc ingress filtering on top of netfilter ingress hooks

 MAINTAINERS                       |    1 +
 include/linux/netdevice.h         |    4 +
 include/linux/netfilter.h         |   92 +------------------
 include/linux/netfilter_hooks.h   |  118 ++++++++++++++++++++++++
 include/linux/netfilter_ingress.h |   44 +++++++++
 include/linux/rtnetlink.h         |   13 ---
 include/net/netfilter/nf_queue.h  |    1 +
 include/uapi/linux/netfilter.h    |    6 ++
 net/Kconfig                       |   14 +++
 net/core/Makefile                 |    1 +
 net/core/dev.c                    |  106 +++++----------------
 net/core/hooks.c                  |  182 +++++++++++++++++++++++++++++++++++++
 net/netfilter/core.c              |  151 +-----------------------------
 net/netfilter/nf_internals.h      |    2 -
 net/sched/Kconfig                 |    1 +
 net/sched/sch_ingress.c           |   60 +++++++++++-
 16 files changed, 457 insertions(+), 339 deletions(-)
 create mode 100644 include/linux/netfilter_hooks.h
 create mode 100644 include/linux/netfilter_ingress.h
 create mode 100644 net/core/hooks.c

-- 
1.7.10.4
