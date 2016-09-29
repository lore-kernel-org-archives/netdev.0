From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 5/5] xps: Documentation for transmit socketles flow steering
Date: Wed, 28 Sep 2016 20:54:28 -0700
Message-ID: <20160929035428.204355-6-tom@herbertland.com>
References: <20160929035428.204355-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <rick.jones2@hpe.com>,
        <alexander.duyck@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36302 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752970AbcI2Dyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 23:54:50 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T3snKG006572
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25rqcu1r5h-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:49 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 7703804485f811e680da0002c9931860-f0dfaa50 for <netdev@vger.kernel.org>;        Wed,
 28 Sep 2016 20:54:47 -0700
In-Reply-To: <20160929035428.204355-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/ABI/testing/sysfs-class-net |  8 ++++++++
 Documentation/networking/scaling.txt      | 26 ++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
index 668604f..0d2a6a9 100644
--- a/Documentation/ABI/testing/sysfs-class-net
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -251,3 +251,11 @@ Contact:	netdev@vger.kernel.org
 Description:
 		Indicates the unique physical switch identifier of a switch this
 		port belongs to, as a string.
+
+What:		/sys/class/net/<iface>/xps_dev_flow_table_cnt
+Date:		October 2016
+KernelVersion:	4.8
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of entries in the XPS socketless flow
+		table.
diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 59f4db2..7f9590c 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -400,6 +400,26 @@ transport layer is responsible for setting ooo_okay appropriately. TCP,
 for instance, sets the flag when all data for a connection has been
 acknowledged.
 
+XPS: Transmit Socketless Flow Steering
+======================================
+
+Not all flows have an associated socket in which the transmit queue and
+ooo information can be saved. For instance, packets being transmitted over
+OVS for VMs do not have a socket that is visible to the kernel. To allow
+XPS to be effectively used a flow hash table is employed to save queue and
+ooo information for such socketless flows.
+
+The idea is that transmit queues are saved for socketless flows in a
+flow table that is indexed by skbuff hash. The flow table entries have
+two values: the queue_index and the head cnt of packets from the TX
+queue. When a packet is being sent without an associated socket the
+hash table is consulted which returns the queue_index to use. The
+returned queue is compared to the queue that would be selected by XPS.
+If they are are different the XPS queue is selected only if the tail cnt
+in the TX queue advances beyond the recorded head cnt. This checks if
+sending the packet on the new queue could cause ooo packets for the
+flow.
+
 ==== XPS Configuration
 
 XPS is only available if the kconfig symbol CONFIG_XPS is enabled (on by
@@ -409,6 +429,12 @@ queue is configured using the sysfs file entry:
 
 /sys/class/net/<dev>/queues/tx-<n>/xps_cpus
 
+Transmit socketless flow steering is enabled by setting the number of
+entries in the XPS flow table. This is configured in the sysfs file
+entry:
+
+/sys/class/net/<dev>/xps_dev_flow_table_cnt
+
 == Suggested Configuration
 
 For a network device with a single transmission queue, XPS configuration
-- 
2.9.3
