From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/10] infiniband: Remove rt->rt_src usage in addr4_resolve()
Date: Mon, 09 May 2011 22:31:33 -0700 (PDT)
Message-ID: <20110509.223133.245392004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53420
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753762Ab1EJFcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:32:05 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9FB2724C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use an explicit flow key and fetch it from there.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 4ffc224..8e21d45 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -185,15 +185,20 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	__be32 dst_ip = dst_in->sin_addr.s_addr;
 	struct rtable *rt;
 	struct neighbour *neigh;
+	struct flowi4 fl4;
 	int ret;
 
-	rt = ip_route_output(&init_net, dst_ip, src_ip, 0, addr->bound_dev_if);
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.daddr = dst_ip;
+	fl4.saddr = src_ip;
+	fl4.flowi4_oif = addr->bound_dev_if;
+	rt = ip_route_output_key(&init_net, &fl4);
 	if (IS_ERR(rt)) {
 		ret = PTR_ERR(rt);
 		goto out;
 	}
 	src_in->sin_family = AF_INET;
-	src_in->sin_addr.s_addr = rt->rt_src;
+	src_in->sin_addr.s_addr = fl4.saddr;
 
 	if (rt->dst.dev->flags & IFF_LOOPBACK) {
 		ret = rdma_translate_ip((struct sockaddr *) dst_in, addr);
-- 
1.7.5.1

