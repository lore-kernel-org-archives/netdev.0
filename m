From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 01/10] netpoll: move setting of NETPOLL_RX_DROP into netpoll_poll_dev
Date: Fri, 14 Mar 2014 20:44:37 -0700
Message-ID: <871ty4qg62.fsf_-_@xmission.com>
References: <87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
	<20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:54253 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203AbaCODon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:44:43 -0400
In-Reply-To: <877g7wqg8e.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 20:43:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Today netpoll depends on setting NETPOLL_RX_DROP before networking
drivers receive packets in interrupt context so that the packets can
be dropped.  Move this setting into netpoll_poll_dev from
poll_one_napi so that if ndo_poll_controller happens to receive
packets we will drop the packets on the floor instead of letting the
packets bounce through the networking stack and potentially cause problems.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a664f7829a6d..ef4f45df539f 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -144,8 +144,7 @@ static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
  * network adapter, forcing superfluous retries and possibly timeouts.
  * Thus, we set our budget to greater than 1.
  */
-static int poll_one_napi(struct netpoll_info *npinfo,
-			 struct napi_struct *napi, int budget)
+static int poll_one_napi(struct napi_struct *napi, int budget)
 {
 	int work;
 
@@ -156,16 +155,12 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
 		return budget;
 
-	npinfo->rx_flags |= NETPOLL_RX_DROP;
-	atomic_inc(&trapped);
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
 	work = napi->poll(napi, budget);
 	trace_napi_poll(napi);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
-	atomic_dec(&trapped);
-	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
 
 	return budget - work;
 }
@@ -178,8 +173,7 @@ static void poll_napi(struct net_device *dev)
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
-			budget = poll_one_napi(rcu_dereference_bh(dev->npinfo),
-					       napi, budget);
+			budget = poll_one_napi(napi, budget);
 			spin_unlock(&napi->poll_lock);
 
 			if (!budget)
@@ -215,6 +209,9 @@ static void netpoll_poll_dev(struct net_device *dev)
 		return;
 	}
 
+	ni->rx_flags |= NETPOLL_RX_DROP;
+	atomic_inc(&trapped);
+
 	ops = dev->netdev_ops;
 	if (!ops->ndo_poll_controller) {
 		up(&ni->dev_lock);
@@ -226,6 +223,9 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
+	atomic_dec(&trapped);
+	ni->rx_flags &= ~NETPOLL_RX_DROP;
+
 	up(&ni->dev_lock);
 
 	if (dev->flags & IFF_SLAVE) {
-- 
1.7.5.4
