From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 0/4] xfs: Transmit flow steering
Date: Tue, 30 Aug 2016 17:00:30 -0700
Message-ID: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35141 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752803AbcHaAnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 20:43:20 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u7UNwvkv016036
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:02:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 255bq9x0v0-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:02:39 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 f48343266f0d11e6bdb60002c9dfb610-cd7f7aa0 for <netdev@vger.kernel.org>;        Tue,
 30 Aug 2016 17:00:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces transmit flow steering. The idea is that we
record the transmit queues in a flow table that is indexed by skbuff.
The flow table entries have two values: the queue_index and the head cnt
of packets from the TX queue. We only allow a queue to change for a flow
if the tail cnt in the TX queue advances beyond the recorded head cnt.
That is the condition that should indicate that all outstanding packets
for the flow have completed transmission so the queue can change.

Tracking the inflight queue is performed as part of BQL. Two fields are
added to netdevice structure: head_cnt and tail_cnt. head_cnt is
incremented in netdev_tx_sent_queue and tail_cnt is incremented in
netdev_tx_completed_queue by the number of packets completed.

This patch set creates /sys/class/net/eth*/xps_dev_flow_table_cnt
which number of entries in the XPS flow table.

Tom Herbert (4):
  net: Set SW hash in skb_set_hash_from_sk
  bql: Add tracking of inflight packets
  net: Add xps_dev_flow_table_cnt
  xfs: Transmit flow steering

 include/linux/netdevice.h | 26 +++++++++++++
 include/net/sock.h        |  6 +--
 net/Kconfig               |  6 +++
 net/core/dev.c            | 93 +++++++++++++++++++++++++++++++++++++++--------
 net/core/net-sysfs.c      | 87 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 199 insertions(+), 19 deletions(-)

-- 
2.8.0.rc2
