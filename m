From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH v2 5/6] netpoll: Remove strong unnecessary assumptions about skbs
Date: Thu, 27 Mar 2014 15:41:04 -0700
Message-ID: <871txnqn7j.fsf_-_@x220.int.ebiederm.org>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
	<87vbuzqnh3.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:44020 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915AbaC0WlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 18:41:16 -0400
In-Reply-To: <87vbuzqnh3.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 27 Mar 2014 15:35:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove the assumption that the skbs that make it to
netpoll_send_skb_on_dev are allocated with find_skb, such that
skb->users == 1 and nothing is attached that would prevent the skbs from
being freed from hard irq context.

Remove this assumption by replacing __kfree_skb on error paths with
dev_kfree_skb_irq (in hard irq context) and kfree_skb (in process
context).

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index f3012800a81b..2136c9aacdbf 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -112,7 +112,7 @@ static void queue_process(struct work_struct *work)
 		struct netdev_queue *txq;
 
 		if (!netif_device_present(dev) || !netif_running(dev)) {
-			__kfree_skb(skb);
+			kfree_skb(skb);
 			continue;
 		}
 
@@ -332,7 +332,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 
 	npinfo = rcu_dereference_bh(np->dev->npinfo);
 	if (!npinfo || !netif_running(dev) || !netif_device_present(dev)) {
-		__kfree_skb(skb);
+		dev_kfree_skb_irq(skb);
 		return;
 	}
 
-- 
1.7.10.4
