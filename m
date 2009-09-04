From: Patrick McHardy <kaber@trash.net>
Subject: net_sched 00/07: classful multiqueue dummy scheduler
Date: Fri,  4 Sep 2009 18:41:12 +0200 (MEST)
Message-ID: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35532 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbZIDQlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 12:41:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches contain a classful multiqueue ("mq") dummy scheduler to fix a
couple of problems with the current multiqueue TC API integration. The
changelogs of patch 05 and 07 contain more details.

The mq scheduler does two things:

- present device TX queues as classes, allowing to attach different qdiscs
  to them, which are grafted to the TX queues

- present accumulated statistics of all device queue root qdiscs

Its used by default for multiqueue devices instead of the regular pfifo_fast
qdisc, but can also be attached manually to restore multiqueue behaviour
after attaching a non-multiqueue (shared) qdisc.

Patches 1-4 contain some preparatory cleanups because I was getting tired
of copying unnecessary checks and dummy functions :)

Patch 5 introduces a dev->qdisc pointer, which points to the root qdisc from
userspace's point of view. This is later used for the mq qdisc, which isn't
actually attached to any device queues. Patch 7 contains the mq scheduler.

I've tested the scheduler with a hacked macvlan version which uses 4 queues,
but since I don't own a multiqueue capable device I couldn't test this on
real hardware.

Any comments and test results welcome :)


 include/linux/netdevice.h |    3 +
 include/net/sch_generic.h |    6 +
 net/core/rtnetlink.c      |    6 +-
 net/sched/Makefile        |    2 +-
 net/sched/cls_api.c       |   10 +-
 net/sched/sch_api.c       |   99 ++++++++-----------
 net/sched/sch_cbq.c       |   38 ++++----
 net/sched/sch_generic.c   |   58 +++++++++--
 net/sched/sch_hfsc.c      |    4 +-
 net/sched/sch_htb.c       |   35 ++++----
 net/sched/sch_ingress.c   |   14 ---
 net/sched/sch_mq.c        |  234 +++++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_multiq.c    |   33 +------
 net/sched/sch_prio.c      |   32 +------
 net/sched/sch_red.c       |   21 ----
 net/sched/sch_sfq.c       |    7 --
 net/sched/sch_tbf.c       |   22 ----
 17 files changed, 375 insertions(+), 249 deletions(-)
 create mode 100644 net/sched/sch_mq.c

Patrick McHardy (7):
      net_sched: fix class grafting errno codes
      net_sched: make cls_ops->tcf_chain() optional
      net_sched: make cls_ops->change and cls_ops->delete optional
      net_sched: remove some unnecessary checks in classful schedulers
      net_sched: reintroduce dev->qdisc for use by sch_api
      net_sched: move dev_graft_qdisc() to sch_generic.c
      net_sched: add classful multiqueue dummy scheduler
