From: Li Zhong <zhong@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next] packet: fix using smp_processor_id() in
 preemptible code
Date: Fri, 13 Dec 2013 06:51:04 +0800
Message-ID: <1386888664.2586.3.camel@ThinkPad-T5421>
References: <1386828604.2584.13.camel@ThinkPad-T5421>
	 <52A83699.9010504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net
To: Daniel Borkmann <dborkman@redhat.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:37047 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3LLBvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:51:45 -0500
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zhong@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 07:21:43 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 8371FE0056
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 07:24:01 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBC1pZVt48365646
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 07:21:35 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBC1peB9007115
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 07:21:40 +0530
In-Reply-To: <52A83699.9010504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches tries to fix the following warning on next-1211 by
replacing smp_processor_id() with raw_smp_processor_id(). 

[   11.120893] BUG: using smp_processor_id() in preemptible [00000000] code: arping/3510
[   11.120913] caller is .packet_sendmsg+0xc14/0xe68
[   11.120920] CPU: 13 PID: 3510 Comm: arping Not tainted 3.13.0-rc3-next-20131211-dirty #1
[   11.120926] Call Trace:
[   11.120932] [c0000001f803f6f0] [c0000000000138dc] .show_stack+0x110/0x25c (unreliable)
[   11.120942] [c0000001f803f7e0] [c00000000083dd24] .dump_stack+0xa0/0x37c
[   11.120951] [c0000001f803f870] [c000000000493fd4] .debug_smp_processor_id+0xfc/0x12c
[   11.120959] [c0000001f803f900] [c0000000007eba78] .packet_sendmsg+0xc14/0xe68
[   11.120968] [c0000001f803fa80] [c000000000700968] .sock_sendmsg+0xa0/0xe0
[   11.120975] [c0000001f803fbf0] [c0000000007014d8] .SyS_sendto+0x100/0x148
[   11.120983] [c0000001f803fd60] [c0000000006fff10] .SyS_socketcall+0x1c4/0x2e8
[   11.120990] [c0000001f803fe30] [c00000000000a1e4] syscall_exit+0x0/0x9c

Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
---
v2: as Daniel suggested, removed the part about setting queue_mapping 

 net/packet/af_packet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9d70f13..cc803c6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -310,7 +310,7 @@ static bool packet_use_direct_xmit(const struct packet_sock *po)
 
 static u16 packet_pick_tx_queue(struct net_device *dev)
 {
-	return (u16) smp_processor_id() % dev->real_num_tx_queues;
+	return (u16) raw_smp_processor_id() % dev->real_num_tx_queues;
 }
 
 /* register_prot_hook must be invoked with the po->bind_lock held,
