From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon,  4 May 2015 12:50:45 +0200
Message-ID: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Another round of the patchset to add Netfilter ingress support. This new
patchset introduces the necessary updates in 2 steps:

1) Add minismalistic ingress hook infrastructure that allows to register one
   client at a time, so you hit -EBUSY in case the hook is in use. Basically,
   we have a function pointer that is rcu-protected to invoke the corresponding
   filter framework which has minimal performance impact in the critical ingress
   path and avoid more pollution in it. This patch also ports the ingress qdisc
   on top of this.

   This also results in most of the qdisc ingress code that used to be embedded
   into net/core/dev.c can now be placed in net/sched/sch_ingress.c, which
   should allow to get rid of the Qdisc->enqueue() call.

2) Add Netfilter ingress support using the minimalistic hook infrastructure.
   There is some extra memory consumption (24 bytes) in net_device but pahole
   reports here a hole due to ____cacheline_aligned_in_smp to get the transmit
   path area in a different cache line. So I'm not sure it's worth the effort
   to reduce this to 8 bytes at the cost of getting the hook code a bit more
   complicated.

As already said, this opens the window to existing nftables core features that
are not present in qdisc ingress and that can be used out-of-the-box, most
relevantly:

1) Multi-dimensional key dictionary lookups.
2) Arbitrary stateful flow tables.
3) Transactions.

Among others. You can find more on previous RFCs, see:

http://www.spinics.net/lists/netdev/msg325210.html
http://marc.info/?l=netfilter-devel&m=143033337020328&w=2

In summary, this provides the facility to keep both tc and netfilter in place,
while the user can select what they prefer to filter from ingress.

Thanks.

Pablo Neira Ayuso (4):
  net: add minimalistic ingress filter hook and port sch_ingress on top of it
  netfilter: cleanup struct nf_hook_ops indentation
  netfilter: add hook list to nf_hook_state
  net: add netfilter ingress hook

 include/linux/netdevice.h         |   16 ++++++++
 include/linux/netfilter.h         |   22 +++++-----
 include/linux/netfilter_ingress.h |   26 ++++++++++++
 include/uapi/linux/netfilter.h    |    6 +++
 net/Kconfig                       |    9 +++++
 net/core/dev.c                    |   81 ++++++++++++++++++-------------------
 net/netfilter/Makefile            |    1 +
 net/netfilter/core.c              |   29 ++++++++++---
 net/netfilter/ingress.c           |   41 +++++++++++++++++++
 net/sched/Kconfig                 |    1 +
 net/sched/sch_ingress.c           |   38 +++++++++++++++--
 11 files changed, 211 insertions(+), 59 deletions(-)
 create mode 100644 include/linux/netfilter_ingress.h
 create mode 100644 net/netfilter/ingress.c

-- 
1.7.10.4
