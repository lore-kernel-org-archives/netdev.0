From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5 net-next] Netfilter ingress support (v4)
Date: Wed, 13 May 2015 18:19:33 +0200
Message-ID: <1431533978-26901-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, kaber@trash.net,
	ast@plumgrid.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is the v4 round of patches to add the Netfilter ingress hook, it basically
comes in two steps:

1) Add the CONFIG_NET_INGRESS switch to wrap the ingress static key around it.
   The idea is to use the same global static key to avoid adding more code to
   the hot path.

2) Add the Netfilter ingress hook after the tc ingress hook, under the global
   ingress_needed static key. As I said, the netfilter ingress hook also has
   its own static key, that is nested under the global static key. Please, see
   patch 5/5 for performance numbers and more information.

I originally started this next round, as it was suggested, exploring the
independent static key for netfilter ingress just after tc ingress, but the
results that I gathered from that patch are not good for non-users:

Result: OK: 6425927(c6425843+d83) usec, 100000000 (60byte,0frags)
  15561955pps 7469Mb/sec (7469738400bps) errors: 100000000

this roughly means 500Kpps less performance wrt. the base numbers, so that's
the reason why I discarded that approach and I focused on this.

The idea of this patchset is to open the window to nf_tables, which comes with
features that will work out-of-the-box (once the boiler plate code to support
the 'netdev' table family is in place), to avoid repeating myself [1], the most
relevant features are:

1) Multi-dimensional key dictionary lookups.
2) Arbitrary stateful flow tables.
3) Transactions and good support for dynamic updates.

But there are also interest aspects to consider from userspace, such as the
ability to support new layer 2 protocols without kernel updates, a well-defined
netlink interface, userspace libraries and utilities for third party
applications, among others.

I hope we can be happy with this approach.

Please, apply. Thanks.

[1] http://marc.info/?l=netfilter-devel&m=143033337020328&w=2

Pablo Neira Ayuso (5):
  netfilter: cleanup struct nf_hook_ops indentation
  netfilter: add hook list to nf_hook_state
  netfilter: add nf_hook_list_active()
  net: add CONFIG_NET_INGRESS to enable ingress filtering
  netfilter: add netfilter ingress hook after handle_ing() under unique
    static key

 include/linux/netdevice.h         |    3 +++
 include/linux/netfilter.h         |   39 +++++++++++++++++++++------------
 include/linux/netfilter_ingress.h |   41 +++++++++++++++++++++++++++++++++++
 include/linux/rtnetlink.h         |    2 +-
 include/uapi/linux/netfilter.h    |    6 ++++++
 net/Kconfig                       |    3 +++
 net/core/dev.c                    |   43 ++++++++++++++++++++++++++++++++++---
 net/netfilter/Kconfig             |    7 ++++++
 net/netfilter/core.c              |   37 ++++++++++++++++++++++++++-----
 net/sched/Kconfig                 |    1 +
 10 files changed, 159 insertions(+), 23 deletions(-)
 create mode 100644 include/linux/netfilter_ingress.h

--
1.7.10.4

