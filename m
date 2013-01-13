From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sat, 12 Jan 2013 19:06:14 -0800
Message-ID: <1358046374.20249.1789.camel@edumazet-glaptop>
References: <50F1699E.1000200@hartkopp.net>
	 <20130112.132316.2121287993605534669.davem@davemloft.net>
	 <20130112.133630.257139657732337147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:51916 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab3AMDGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 22:06:17 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so1646661pad.2
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 19:06:17 -0800 (PST)
In-Reply-To: <20130112.133630.257139657732337147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

act_mirred needs to find the current net_ns, and struct net
pointer is not provided in the call chain. We run in process
context and current->nsproxy->net_ns is the needed pointer.

For ifb, things are easier, as the current ifb device can provide
the net pointer immediately.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ifb.c      |    2 +-
 net/sched/act_mirred.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 344dceb..8216438 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -90,7 +90,7 @@ static void ri_tasklet(unsigned long dev)
 		u64_stats_update_end(&dp->tsync);
 
 		rcu_read_lock();
-		skb->dev = dev_get_by_index_rcu(&init_net, skb->skb_iif);
+		skb->dev = dev_get_by_index_rcu(dev_net(_dev), skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 9c0fd0c..f5a7e18 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -88,7 +88,7 @@ static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	}
 	if (parm->ifindex) {
-		dev = __dev_get_by_index(&init_net, parm->ifindex);
+		dev = __dev_get_by_index(current->nsproxy->net_ns, parm->ifindex);
 		if (dev == NULL)
 			return -ENODEV;
 		switch (dev->type) {
