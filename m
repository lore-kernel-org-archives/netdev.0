From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] net: take care of bonding in build_skb_flow_key
Date: Wed,  6 Jan 2016 13:49:28 +0800
Message-ID: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
Cc: wen.gang.wang@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30331 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbcAFFqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 00:46:19 -0500
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u065kI7L025637
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 05:46:19 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id u065kILn023203
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 05:46:18 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id u065kILx018038
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 05:46:18 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A problem is found that we are looking for route basing a bonding device and
deal with path MTU there: The path MTU is set to the active slave device, not
the bonding master.

The patch tries to fix the issue by letting build_skb_flow_key() take care
of the transition of device index from bonding slave to the master.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 net/ipv4/route.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85f184e..3053f10 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -523,11 +523,20 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
 			       const struct sock *sk)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	int oif = skb->dev->ifindex;
+	int oif;
+	struct net_device *master = NULL;
+
 	u8 tos = RT_TOS(iph->tos);
 	u8 prot = iph->protocol;
 	u32 mark = skb->mark;
 
+	if (skb->dev->flags & IFF_SLAVE)
+		master = netdev_master_upper_dev_get(skb->dev);
+	if (master)
+		oif = master->ifindex;
+	else
+		oif = skb->dev->ifindex;
+
 	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
 }
 
-- 
2.1.0
