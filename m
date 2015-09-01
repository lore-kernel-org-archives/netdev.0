From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 00/11] flow_dissector:  Paramterize dissection and other features
Date: Tue, 1 Sep 2015 09:24:22 -0700
Message-ID: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37908 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751172AbbIAQZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:04 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t81GP181002543
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1wnews837v-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:02 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 fe49d0a850c511e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:01 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds some new capabilities to flow_dissector:

- Add flags to flow dissector functions to control dissection
  - Flag to stop dissection when L3 header is seen (don't
    dissect L4)
  - Flag to stop dissection when encapsulation is detected
  - Flag to parse first fragment of fragmented packet. This
    may provide L4 ports
- Added new reporting in key_control
  - Packet is a fragment
  - Packet is a first fragment
  - Packet has encapsulation

Also:
  - Make __skb_set_sw_hash a general function
  - Create functions to get a flow hash based on flowi4 or flowi6
    structures without an reference to an skbuff
  - Ignore flow dissector return value from ___skb_get_hash. Just
    use whatever key fields are found to make a hash

Tested:

Ran 200 netperf TCP_RR instances for IPv6 and IPv4. Did not see any
regression. Ran UDP_RR with 10000 byte request and response size
for IPv4 and IPv6, no regression observed however I did see better
performance with IPv6 flow labels due to use of flow labels for L4
hash.

Tom Herbert (11):
  flow_dissector: Move skb related functions to skbuff.h
  skbuff: Make __skb_set_sw_hash a general function
  flowi: Abstract out functions to get flow hash based on flowi
  flow_dissector: Jump to exit code in __skb_flow_dissect
  flow_dissector: Add flags argument to skb_flow_dissector functions
  flow_dissector: Add control/reporting of fragmentation
  flow_dissector: Support IPv6 fragment header
  flow_dissector: Add flag to stop parsing at L3
  flow_dissector: Add flag to stop parsing when an IPv6 flow label is
    seen
  flow_dissector: Add control/reporting of encapsulation
  flow_dissector: Ignore flow dissector return value from
    ___skb_get_hash

 drivers/net/bonding/bond_main.c             |   2 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c |   2 +-
 drivers/net/hyperv/netvsc_drv.c             |   2 +-
 include/linux/skbuff.h                      | 113 +++++++++++++++++----
 include/net/flow.h                          |  19 ++++
 include/net/flow_dissector.h                |  65 +++----------
 net/core/flow.c                             |  36 +++++++
 net/core/flow_dissector.c                   | 146 ++++++++++++++++++----------
 net/ethernet/eth.c                          |   2 +-
 net/sched/cls_flow.c                        |   2 +-
 net/sched/cls_flower.c                      |   2 +-
 net/sched/sch_choke.c                       |   4 +-
 12 files changed, 267 insertions(+), 128 deletions(-)

-- 
1.8.1
