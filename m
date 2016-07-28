From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] tipc: fix imbalance read_unlock_bh in __tipc_nl_add_monitor()
Date: Thu, 28 Jul 2016 02:07:49 +0000
Message-ID: <1469671669-12829-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33480 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758879AbcG1CIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 22:08:02 -0400
Received: by mail-pa0-f68.google.com with SMTP id q2so2649042pap.0
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 19:08:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the error handling case of nla_nest_start() failed read_unlock_bh()
is called  to unlock a lock that had not been taken yet. sparse warns
about the context imbalance as the following:

net/tipc/monitor.c:799:23: warning:
 context imbalance in '__tipc_nl_add_monitor' - different lock contexts for basic block

Fixes: cf6f7e1d5109 ('tipc: dump monitor attributes')
Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 net/tipc/monitor.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
index be70a57..b62caa1 100644
--- a/net/tipc/monitor.c
+++ b/net/tipc/monitor.c
@@ -794,10 +794,10 @@ int __tipc_nl_add_monitor(struct net *net, struct tipc_nl_msg *msg,
 	return 0;
 
 attr_msg_full:
+	read_unlock_bh(&mon->lock);
 	nla_nest_cancel(msg->skb, attrs);
 msg_full:
 	genlmsg_cancel(msg->skb, hdr);
-	read_unlock_bh(&mon->lock);
 
 	return -EMSGSIZE;
 }
