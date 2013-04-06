From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/51] ipvs: prefer NETDEV_DOWN event to free cached dsts
Date: Sat,  6 Apr 2013 14:17:01 +0200
Message-ID: <1365250670-14993-3-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38871 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163349Ab3DFMSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 08:18:07 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

The real server becomes unreachable on down event,
no need to wait device unregistration. Should help in
releasing dsts early before dst->dev is replaced with lo.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8104120..6b55ba6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1514,10 +1514,8 @@ __ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
 	spin_unlock_bh(&dest->dst_lock);
 
 }
-/*
- * Netdev event receiver
- * Currently only NETDEV_UNREGISTER is handled, i.e. if we hold a reference to
- * a device that is "unregister" it must be released.
+/* Netdev event receiver
+ * Currently only NETDEV_DOWN is handled to release refs to cached dsts
  */
 static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
@@ -1529,7 +1527,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	struct ip_vs_dest *dest;
 	unsigned int idx;
 
-	if (event != NETDEV_UNREGISTER || !ipvs)
+	if (event != NETDEV_DOWN || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
 	EnterFunction(2);
-- 
1.7.10.4
