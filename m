From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 00/10] net: sched: introduce multichain support for filters
Date: Wed, 17 May 2017 11:07:53 +0200
Message-ID: <20170517090803.4461-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35049 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753677AbdEQJIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 05:08:07 -0400
Received: by mail-wm0-f68.google.com with SMTP id v4so1934965wmb.2
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 02:08:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently, each classful qdisc holds one chain of filters.
This chain is traversed and each filter could be matched on, which
may lead to execution of list of actions. One of such action
could be "reclassify", which would "reset" the processing of the
filter chain.

So this filter chain could be looked at as a flat table.
Sometimes it is convenient for user to configure a hierarchy
of tables. Example usecase is encapsulation.

Hierarchy of tables is a common way how it is done in HW pipelines.
So it is much more convenient to offload this.

This patchset contains two major patches:
8/10 - This patch introduces the support for having multiple
       chains of filters.
10/10 - This patch adds new control action to allow going to specified chain

The rest of the patches are smaller or bigger depencies of those 2.
Please see individual patch descriptions for details.

Corresponding iproute2 patches are appended as a reply to this cover letter.

Simple example:
$ tc qdisc add dev eth0 ingress
$ tc filter add dev eth0 parent ffff: protocol ip pref 33 flower dst_mac 52:54:00:3d:c7:6d action goto chain 11
$ tc filter add dev eth0 parent ffff: protocol ip pref 22 chain 11 flower dst_ip 192.168.40.1 action drop
$ tc filter show dev eth0 root
filter parent ffff: protocol ip pref 33 flower chain 0
filter parent ffff: protocol ip pref 33 flower chain 0 handle 0x1
  dst_mac 52:54:00:3d:c7:6d
  eth_type ipv4
        action order 1: gact action goto chain 11
         random type none pass val 0
         index 2 ref 1 bind 1

filter parent ffff: protocol ip pref 22 flower chain 11
filter parent ffff: protocol ip pref 22 flower chain 11 handle 0x1
  eth_type ipv4
  dst_ip 192.168.40.1
        action order 1: gact action drop
         random type none pass val 0
         index 3 ref 1 bind 1

---
v3->v4:
- 01/10 - bring back removed NET_CLS_ACT ifdefs as spotted by Cong
- 06/10 - use tcf_chain_tp_prev helper in tcf_chain_tp_insert as
          suggested by Cong
v2->v3:
- 10/10 - added "unlikely" to the reclassify and goto checks
          as suggested by Daniel
v1->v2:
- 09/10 - no need to push tp all the way down to actions
- 10/10 - reworked gact to generic control action as suggested by Jamal

Jiri Pirko (10):
  net: sched: move tc_classify function to cls_api.c
  net: sched: introduce tcf block infractructure
  net: sched: rename tcf_destroy_chain helper
  net: sched: replace nprio by a bool to make the function more readable
  net: sched: move TC_H_MAJ macro call into tcf_auto_prio
  net: sched: introduce helpers to work with filter chains
  net: sched: push chain dump to a separate function
  net: sched: introduce multichain support for filters
  net: sched: push tp down to action init
  net: sched: add termination action to allow goto chain

 include/net/act_api.h          |  13 +-
 include/net/pkt_cls.h          |  24 ++-
 include/net/pkt_sched.h        |   3 -
 include/net/sch_generic.h      |  26 ++-
 include/uapi/linux/pkt_cls.h   |   1 +
 include/uapi/linux/rtnetlink.h |   1 +
 net/core/dev.c                 |   5 +-
 net/sched/act_api.c            |  55 +++++-
 net/sched/cls_api.c            | 411 ++++++++++++++++++++++++++++++++---------
 net/sched/sch_api.c            |  50 +----
 net/sched/sch_atm.c            |  29 ++-
 net/sched/sch_cbq.c            |  21 ++-
 net/sched/sch_drr.c            |  15 +-
 net/sched/sch_dsmark.c         |  19 +-
 net/sched/sch_fq_codel.c       |  17 +-
 net/sched/sch_hfsc.c           |  21 ++-
 net/sched/sch_htb.c            |  28 ++-
 net/sched/sch_ingress.c        |  61 ++++--
 net/sched/sch_multiq.c         |  16 +-
 net/sched/sch_prio.c           |  19 +-
 net/sched/sch_qfq.c            |  16 +-
 net/sched/sch_sfb.c            |  17 +-
 net/sched/sch_sfq.c            |  17 +-
 23 files changed, 625 insertions(+), 260 deletions(-)

-- 
2.9.3
