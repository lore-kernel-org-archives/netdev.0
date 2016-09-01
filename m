From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/4] xps_flows: XPS flow steering when there is no socket
Date: Wed, 31 Aug 2016 17:10:01 -0700
Message-ID: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <rick.jones2@hpe.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43146 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753869AbcIAAKR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 20:10:17 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8107Eg9023619
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 17:10:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 25651ean9q-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 17:10:16 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 74a669b46fd811e6ad430002c99293a0-f88e7a50 for <netdev@vger.kernel.org>;        Wed,
 31 Aug 2016 17:10:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces transmit flow steering for socketless packets.
The idea is that we record the transmit queues in a flow table that is
indexed by skbuff hash.  The flow table entries have two values: the
queue_index and the head cnt of packets from the TX queue. We only allow
a queue to change for a flow if the tail cnt in the TX queue advances
beyond the recorded head cnt. That is the condition that should indicate
that all outstanding packets for the flow have completed transmission so
the queue can change.

Tracking the inflight queue is performed as part of DQL. Two fields are
added to the dql structure: num_enqueue_ops and num_completed_ops.
num_enqueue_ops incremented in dql_queued and num_completed_ops is
incremented in dql_completed by the number of operations completed (an
new argument to the function).

This patch set creates /sys/class/net/eth*/xps_dev_flow_table_cnt
which number of entries in the XPS flow table.

Note that the functionality here is technically best effort (for
instance we don't obtain a lock while processing a flow table entry).
Under high load it is possible that OOO packets can still be generated
due to XPS if two threads are hammering on the same flow table entry.
The assumption of this patches is that OOO packets are not the end of
the world and these should prevent OOO in most common use cases with
XPS.

This is a followup to previous RFC version. Fixes from RFC are:

  - Move counters to DQL
  - Fixed typo
  - Simplified get flow index funtion
  - Fixed sysfs flow_table_cnt to properly use DEVICE_ATTR_RW
  - Renamed the mechanism

Tested:
  Manually forced all packets to go through the xps_flows path.
  Observed that some flows were deferred to change queues because
  packets were in flight witht the flow bucket.

Tom Herbert (4):
  net: Set SW hash in skb_set_hash_from_sk
  dql: Add counters for number of queuing and completion operations
  net: Add xps_dev_flow_table_cnt
  xps_flows: XPS for packets that don't have a socket

 include/linux/dynamic_queue_limits.h |   7 ++-
 include/linux/netdevice.h            |  26 ++++++++-
 include/net/sock.h                   |   6 +-
 lib/dynamic_queue_limits.c           |   3 +-
 net/Kconfig                          |   6 ++
 net/core/dev.c                       |  85 ++++++++++++++++++++++++-----
 net/core/net-sysfs.c                 | 103 +++++++++++++++++++++++++++++++++++
 7 files changed, 214 insertions(+), 22 deletions(-)

-- 
2.8.0.rc2
