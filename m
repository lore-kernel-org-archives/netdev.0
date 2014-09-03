From: roy.qing.li@gmail.com
Subject: [PATCH v2] openvswitch: distinguish between the dropped and consumed skb
Date: Wed,  3 Sep 2014 17:43:45 +0800
Message-ID: <1409737426-22245-1-git-send-email-roy.qing.li@gmail.com>
Cc: tgraf@noironetworks.com, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:37773 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994AbaICJoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 05:44:00 -0400
Received: by mail-pd0-f177.google.com with SMTP id r10so10606443pdi.22
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 02:43:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

distinguish between the dropped and consumed skb, not assume the skb
is consumed always

Cc: Thomas Graf <tgraf@noironetworks.com>
Cc: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/openvswitch/datapath.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 35d866f..91d66b7 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -265,8 +265,11 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 		upcall.key = &key;
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
-		ovs_dp_upcall(dp, skb, &upcall);
-		consume_skb(skb);
+		error = ovs_dp_upcall(dp, skb, &upcall);
+		if (unlikely(error))
+			kfree_skb(skb);
+		else
+			consume_skb(skb);
 		stats_counter = &stats->n_missed;
 		goto out;
 	}
-- 
1.7.10.4
