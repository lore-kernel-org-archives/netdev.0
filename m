From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/5]  xps_flows: XPS flow steering when there is no socket
Date: Wed, 28 Sep 2016 20:54:23 -0700
Message-ID: <20160929035428.204355-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <rick.jones2@hpe.com>,
        <alexander.duyck@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37945 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750700AbcI2Dym (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 23:54:42 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T3s8e0018385
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25rm8vkec2-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:41 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 7204da8e85f811e6b4050002c9521c9e-4f2f1a50 for <netdev@vger.kernel.org>;        Wed,
 28 Sep 2016 20:54:39 -0700
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
incremented in dql_completed by the number of operations completed (a
new argument to the function).

This patch set creates /sys/class/net/eth*/xps_dev_flow_table_cnt
which number of entries in the XPS flow table.

Note that the functionality here is technically best effort (for
instance we don't obtain a lock while processing a flow table entry).
Under high load it is possible that OOO packets can still be generated
due to XPS if two threads are hammering on the same flow table entry.
The assumption of these patches is that OOO packets are not the end of
the world and these should prevent OOO in most common use cases with
XPS.

This is a followup to previous RFC version. Fixes from RFC are:

  - Move counters to DQL
  - Fixed typo
  - Simplified get flow index funtion
  - Fixed sysfs flow_table_cnt to properly use DEVICE_ATTR_RW
  - Renamed the mechanism

V2:
  - Added documentation in scaling.txt and sysfs documentation
  - Call skb_tx_hash directly from get_xps_queue. This allows
    the socketless transmit flow steering to work properly if
    a flow is bouncing between non-XPS and XPS CPUS. (suggested
    by Alexander Duyck).
  - Added a whold bunch of tested results provided by Rick Jones
    (Thanks Rick!)

Tested:
  Manually forced all packets to go through the xps_flows path.
  Observed that some flows were deferred to change queues because
  packets were in flight witht the flow bucket.

Testing done by Rick Jones:

  Here is a quick look at performance tests for the result of trying the
  prototype fix for the packet reordering problem with VMs sending over
  an XPS-configured NIC.  In particular, the Emulex/Avago/Broadcom
  Skyhawk.  The fix was applied to a 4.4 kernel.

  Before: 3884 Mbit/s
  After: 8897 Mbit/s

  That was from a VM on a node with a Skyhawk and 2 E5-2640 processors
  to baremetal E5-2640 with a BE3.  Physical MTU was 1500, the VM's
  vNIC's MTU was 1400.  Systems were HPE ProLiants in OS Control Mode
  for power management, with the "performance" frequency governor
  loaded. An OpenStack Mitaka setup with Distributed Virtual Router.

  We had some other NIC types in the setup as well.  XPS was also
  enabled on the ConnectX3-Pro.  It was not enabled on the 82599ES (a
  function of the kernel being used, which had it disabled from the
  first reports of XPS negatively affecting VM traffic at the beginning
  of the year)

  Average Mbit/s From NIC type To Bare Metal BE3:

   NIC Type,
   CPU on VM Host            Before        After
  ------------------------------------------------
  ConnectX-3 Pro,E5-2670v3    9224         9271
  BE3, E5-2640                9016         9022
  82599, E5-2640              9192         9003
  BCM57840, E5-2640           9213         9153
  Skyhawk, E5-2640            3884         8897

  For completeness:
  Average Mbit/s To NIC type from Bare Metal BE3:

  NIC Type,
  CPU on VM Host            Before        After
  ------------------------------------------------
  ConnectX-3 Pro,E5-2670v3    9322         9144
  BE3, E5-2640                9074         9017
  82599, E5-2640              8670         8564
  BCM57840, E5-2640           2468 *       7979
  Skyhawk, E5-2640            8897         9269

  * This is the Busted bnx2x NIC FW GRO implementation issue.  It was
    not visible in the "After" because the system was setup to disable
    the NIC FW GRO by the time it booted on the fix kernel.

  Average Transactions/s Between NIC type and Bare Metal BE3:

  NIC Type,
  CPU on VM Host            Before        After
  ------------------------------------------------
  ConnectX-3 Pro,E5-2670v3   12421         12612
  BE3, E5-2640                8178          8484
  82599, E5-2640              8499          8549
  BCM57840, E5-2640           8544          8560
  Skyhawk, E5-2640            8537          8701

Tom Herbert (5):
  net: Set SW hash in skb_set_hash_from_sk
  dql: Add counters for number of queuing and completion operations
  net: Add xps_dev_flow_table_cnt
  xps_flows: XPS for packets that don't have a socket
  xps: Documentation for transmit socketles flow steering

 Documentation/ABI/testing/sysfs-class-net |   8 +++
 Documentation/networking/scaling.txt      |  26 ++++++++
 include/linux/dynamic_queue_limits.h      |   7 +-
 include/linux/netdevice.h                 |  26 +++++++-
 include/net/sock.h                        |   6 +-
 lib/dynamic_queue_limits.c                |   3 +-
 net/Kconfig                               |   6 ++
 net/core/dev.c                            |  87 +++++++++++++++++++------
 net/core/net-sysfs.c                      | 103 ++++++++++++++++++++++++++++++
 9 files changed, 246 insertions(+), 26 deletions(-)

-- 
2.9.3
