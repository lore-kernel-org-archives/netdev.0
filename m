From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 07/11] openvswitch: Avoid memory corruption in queue_userspace_packet()
Date: Tue, 15 Jul 2014 10:15:16 -0700
Message-ID: <1405444516-17058-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:59654 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758527AbaGORPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:15:20 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so2182325pad.37
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:15:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

In queue_userspace_packet(), the ovs_nla_put_flow return value is
not checked. This is fine as long as key_attr_size() returns the
correct value. In case it does not, the current code may corrupt buffer
memory. Add a run time assertion catch this case to avoid silent
failure.

Reported-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 995dfa1..de7d4db 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -481,7 +481,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	upcall->dp_ifindex = dp_ifindex;
 
 	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
-	ovs_nla_put_flow(upcall_info->key, upcall_info->key, user_skb);
+	err = ovs_nla_put_flow(upcall_info->key, upcall_info->key, user_skb);
+	BUG_ON(err);
 	nla_nest_end(user_skb, nla);
 
 	if (upcall_info->userdata)
-- 
1.9.3
