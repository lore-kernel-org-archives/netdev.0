From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/4] sched, cbq: remove OVL_STRATEGY/POLICE support
Date: Wed,  8 Jun 2016 17:35:37 +0200
Message-ID: <1465400141-29088-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59856 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161796AbcFHPfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 11:35:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute2 does not implement any options that result in the
TCA_CBQ_OVL_STRATEGY/TCA_CBQ_POLICE attributes being set/used.

This series removes these two attributes from cbq and makes kernel reject
them via EOPNOTSUPP in case they are seen.

The two followup changes then remove several features from qdisc
infrastructure that are then no longer used/needed.  These are:
 - The 'drop' method provided by most qdiscs
 - the 'reshape_fail' function used by some qdiscs
 - the __parent member in struct Qdisc

I tested this with allmod and allyesconfig builds and also with
a brief cbq script:

  tc qdisc add dev eth0 root handle 1:0 cbq bandwidth 10Mbit avpkt 1000 cell 8
  tc class add dev eth0 parent 1:0 classid 1:1 est 1sec 8sec cbq bandwidth 10Mbit rate 5Mbit prio 1 allot 1514 maxburst 20 cell 8 avpkt 1000 bounded split 1:0 defmap 3f
  tc class add dev eth0 parent 1:0 classid 1:2 est 1sec 8sec cbq bandwidth 10Mbit rate 5Mbit prio 1 allot 1514 maxburst 20 cell 8 avpkt 1000 bounded split 1:0 defmap 3f
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip tos 0x10 0xff classid 1:1 police rate 2Mbit burst 10K reclassify
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip tos 0x0c 0xff classid 1:2
  tc filter add dev eth0 parent 1:0 protocol ip prio 2 u32 match ip tos 0x10 0xff classid 1:2
  tc filter add dev eth0 parent 1:0 protocol ip prio 3 u32 match ip tos 0x0 0x0 classid 1:2

Florian Westphal (4):
      cbq: remove TCA_CBQ_OVL_STRATEGY support
      cbq: remove TCA_CBQ_POLICE support
      sched: remove qdisc_rehape_fail
      sched: remove qdisc->drop

 include/net/sch_generic.h |   59 ---------
 net/sched/sch_atm.c       |   15 --
 net/sched/sch_cbq.c       |  285 ----------------------------------------------
 net/sched/sch_choke.c     |   17 --
 net/sched/sch_drr.c       |   21 ---
 net/sched/sch_dsmark.c    |   18 --
 net/sched/sch_fifo.c      |    7 -
 net/sched/sch_fq_codel.c  |   10 -
 net/sched/sch_gred.c      |   35 -----
 net/sched/sch_hfsc.c      |   26 ----
 net/sched/sch_hhf.c       |   10 -
 net/sched/sch_htb.c       |   26 ----
 net/sched/sch_multiq.c    |   22 ---
 net/sched/sch_netem.c     |   34 -----
 net/sched/sch_plug.c      |    2 
 net/sched/sch_prio.c      |   19 ---
 net/sched/sch_qfq.c       |   47 -------
 net/sched/sch_red.c       |   20 ---
 net/sched/sch_sfq.c       |    1 
 net/sched/sch_tbf.c       |   17 --
 20 files changed, 13 insertions(+), 678 deletions(-)
