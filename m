From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 0/5] replace skb tc_verd member with 3 dedicated bit flags
Date: Mon,  4 May 2015 20:48:33 +0200
Message-ID: <1430765318-13788-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46860 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbbEDSsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:48:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series removes the tc_verd member from sk_buff
and uses 3 new flag bits instead.  It is on top of
http://patchwork.ozlabs.org/patch/467186/
(tc: remove unused redirect ttl) from Alexei.

The patch set tries to not affect tc inner workings.
I tested a few scenarios, namely:

- htb on egress
- netem attached to ifb with mirred redirect from ingress
  qdisc
- mirred to different device
- bogus packet reclassify loop

All of that works as expected (i.e. in last case most packets
are dropped).

motivation is two-fold:
1) provide better documentation as to what tc_verd is
   used for and try to move some flag set/clear operations
   into sch_ingress

2) provide a way to reduce skb size by 8 bytes
   (s/u16 mac_len/u8 mac_len/ would result in
    two 2 byte and one 4 byte hole, i.e. 8 byte reduction with
    minor reshuffling).

Florian Westphal (5):
      net: sched: replace NCLS macro with tc_nocls bit flag
      net: sched: use counter to break reclassify loops
      net: sched: remove FROM INGRESS/EGRESS
      net: sched: remove AT INGRESS/EGRESS
      skbuff: remove tc_verd member

Documentation/networking/tc-actions-env-rules.txt |    4 ----
 drivers/net/ifb.c                                 |   15 +++++----------
 drivers/staging/octeon/ethernet-tx.c              |    4 +++-
 include/linux/skbuff.h                            |   17 +++++++++++------
 include/net/sch_generic.h                         |   15 ---------------
 include/uapi/linux/pkt_cls.h                      |    4 +---
 net/core/dev.c                                    |   10 ++--------
 net/core/skbuff.c                                 |    3 ---
 net/sched/act_api.c                               |    4 ++--
 net/sched/act_mirred.c                            |    9 ++++-----
 net/sched/sch_api.c                               |   12 +++---------
 net/sched/sch_ingress.c                           |    2 ++
 net/sched/sch_netem.c                             |    2 +-
 13 files changed, 34 insertions(+), 67 deletions(-)
