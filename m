From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/9] netpoll: Pass budget into poll_napi
Date: Fri, 14 Mar 2014 18:31:25 -0700
Message-ID: <878uscuu1e.fsf_-_@xmission.com>
References: <1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
	<87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60132 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418AbaCOBbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:31:31 -0400
In-Reply-To: <87eh24uu3d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 18:30:14 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This moves the control logic to the top level in netpoll_poll_dev
instead of having it dispersed throughout netpoll_poll_dev,
poll_napi and poll_one_napi.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ef4f45df539f..147c75855c9b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -165,10 +165,9 @@ static int poll_one_napi(struct napi_struct *napi, int budget)
 	return budget - work;
 }
 
-static void poll_napi(struct net_device *dev)
+static void poll_napi(struct net_device *dev, int budget)
 {
 	struct napi_struct *napi;
-	int budget = 16;
 
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
@@ -196,6 +195,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 {
 	const struct net_device_ops *ops;
 	struct netpoll_info *ni = rcu_dereference_bh(dev->npinfo);
+	int budget = 16;
 
 	/* Don't do any rx activity if the dev_lock mutex is held
 	 * the dev_open/close paths use this to block netpoll activity
@@ -221,7 +221,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	/* Process pending work on NIC */
 	ops->ndo_poll_controller(dev);
 
-	poll_napi(dev);
+	poll_napi(dev, budget);
 
 	atomic_dec(&trapped);
 	ni->rx_flags &= ~NETPOLL_RX_DROP;
-- 
1.7.5.4
