From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 0/3] tc state machinery cleanups
Date: Fri, 15 May 2015 10:50:47 +0200
Message-ID: <1431679850-31896-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48177 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753926AbbEOIvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 04:51:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series prepares removal of tc_verd member from sk_buff.

It simplifies tc state machinery to what is required to keep current
mirred/ifb combinations working.

I tested a few scenarios, namely:

1 - htb based shaping on egress
2 - netem attached to ifb with mirred redirect from ingress qdisc
3 - mirred to different egress device
4 - mirred to ifb egress device with qdiscs set up on ifb
    to provide illusion of 'single' transmit interface for traffic shaping

After this series tc_verd is only used by ifb to skip actions on egress.

Part #2 of this series will remove tc_verd completely.

motivation is two-fold:
1) make states and state transitions more obvious
2) provide a way to later reduce skb size by 8 bytes
   (s/u16 mac_len/u8 mac_len/ would result in
    two 2 byte and one 4 byte hole, i.e. 8 byte reduction with
    minor reshuffling).

 drivers/net/ifb.c                    |   18 +++++++++---------
 drivers/staging/octeon/ethernet-tx.c |    1 +
 include/linux/skbuff.h               |    6 ++++--
 include/net/pkt_sched.h              |   18 ++++++++++++++++++
 include/uapi/linux/pkt_cls.h         |    6 +++---
 net/core/dev.c                       |   14 ++++++--------
 net/sched/act_mirred.c               |   17 +++++++++--------
 net/sched/sch_netem.c                |    2 +-
 8 files changed, 51 insertions(+), 31 deletions(-)
