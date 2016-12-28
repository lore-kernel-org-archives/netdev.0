From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next rfc 0/6] convert tc_verd to integer bitfields
Date: Wed, 28 Dec 2016 14:13:24 -0500
Message-ID: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34317 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbcL1TNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:13:33 -0500
Received: by mail-qk0-f193.google.com with SMTP id t184so33144443qkd.1
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2016 11:13:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The skb tc_verd field takes up two bytes but uses far fewer bits.
Convert the remaining use cases to bitfields that fit in existing
holes (depending on config options) and potentially save the two
bytes in struct sk_buff.

This patchset is based on an earlier set by Florian Westphal and its
discussion (http://www.spinics.net/lists/netdev/msg329181.html).

Patches 1 and 2 are low hanging fruit: removing the last traces of
  data that are no longer stored in tc_verd.

Patches 3 and 4 convert tc_verd to individual bitfields (5 bits).

Patch 5 reduces TC_AT to a single bitfield,
  as AT_STACK is not valid here (unlike in the case of TC_FROM).

Patch 6 changes TC_FROM to two bitfields with clearly defined purpose.

It may be possible to reduce storage further after this initial round.
If tc_skip_classify is set only by IFB, testing skb_iif may suffice.
The L2 header pushing/popping logic can perhaps be shared with
AF_PACKET, which currently not pkt_type for the same purpose.

Tested ingress mirred + netem + ifb: 

  ip link set dev ifb0 up
  tc qdisc add dev eth0 ingress
  tc filter add dev eth0 parent ffff: \
    u32 match ip dport 8000 0xffff \
    action mirred egress redirect dev ifb0
  tc qdisc add dev ifb0 root netem delay 1000ms
  nc -u -l 8000 &
  ssh $otherhost nc -u $host 8000

Tested egress mirred:

  ip link add veth1 type veth peer name veth2
  ip link set dev veth1 up
  ip link set dev veth2 up
  tcpdump -n -i veth2 udp and dst port 8000 &

  tc qdisc add dev eth0 root handle 1: prio
  tc filter add dev eth0 parent 1:0 \
    u32 match ip dport 8000 0xffff \
    action mirred egress redirect dev veth1
  tc qdisc add dev veth1 root netem delay 1000ms
  nc -u $otherhost 8000

Willem de Bruijn (6):
  net-tc: remove unused tc_verd fields
  net-tc: make MAX_RECLASSIFY_LOOP local
  net-tc: extract skip classify bit from tc_verd
  net-tc: convert tc_verd to integer bitfields
  net-tc: convert tc_at to tc_at_ingress
  net-tc: convert tc_from to tc_from_ingress and tc_redirected

 drivers/net/ifb.c                    | 16 ++++-------
 drivers/staging/octeon/ethernet-tx.c |  5 ++--
 include/linux/skbuff.h               | 15 ++++++----
 include/net/sch_generic.h            | 20 ++++++++++++-
 include/uapi/linux/pkt_cls.h         | 55 ------------------------------------
 net/core/dev.c                       | 20 ++++---------
 net/core/pktgen.c                    |  4 +--
 net/core/skbuff.c                    |  3 --
 net/sched/act_api.c                  |  8 ++----
 net/sched/act_ife.c                  |  7 ++---
 net/sched/act_mirred.c               | 21 +++++++-------
 net/sched/sch_api.c                  |  4 ++-
 net/sched/sch_netem.c                |  2 +-
 13 files changed, 64 insertions(+), 116 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
