From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/8] libcxgbi: Use flowi4's saddr in cxgbi_check_route().
Date: Wed, 04 May 2011 10:14:57 -0700 (PDT)
Message-ID: <20110504.101457.183055649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754770Ab1EDRPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:30 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CF76A24C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:14:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of rt->rt_src

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/cxgbi/libcxgbi.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 0c33d25..a2a9c7c 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -450,13 +450,13 @@ static struct cxgbi_sock *cxgbi_sock_create(struct cxgbi_device *cdev)
 	return csk;
 }
 
-static struct rtable *find_route_ipv4(__be32 saddr, __be32 daddr,
+static struct rtable *find_route_ipv4(struct flowi4 *fl4,
+				      __be32 saddr, __be32 daddr,
 				      __be16 sport, __be16 dport, u8 tos)
 {
 	struct rtable *rt;
-	struct flowi4 fl4;
 
-	rt = ip_route_output_ports(&init_net, &fl4, NULL, daddr, saddr,
+	rt = ip_route_output_ports(&init_net, fl4, NULL, daddr, saddr,
 				   dport, sport, IPPROTO_TCP, tos, 0);
 	if (IS_ERR(rt))
 		return NULL;
@@ -471,6 +471,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	struct net_device *ndev;
 	struct cxgbi_device *cdev;
 	struct rtable *rt = NULL;
+	struct flowi4 fl4;
 	struct cxgbi_sock *csk = NULL;
 	unsigned int mtu = 0;
 	int port = 0xFFFF;
@@ -483,7 +484,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		goto err_out;
 	}
 
-	rt = find_route_ipv4(0, daddr->sin_addr.s_addr, 0, daddr->sin_port, 0);
+	rt = find_route_ipv4(&fl4, 0, daddr->sin_addr.s_addr, 0, daddr->sin_port, 0);
 	if (!rt) {
 		pr_info("no route to ipv4 0x%x, port %u.\n",
 			daddr->sin_addr.s_addr, daddr->sin_port);
@@ -532,7 +533,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	csk->daddr.sin_addr.s_addr = daddr->sin_addr.s_addr;
 	csk->daddr.sin_port = daddr->sin_port;
 	csk->daddr.sin_family = daddr->sin_family;
-	csk->saddr.sin_addr.s_addr = rt->rt_src;
+	csk->saddr.sin_addr.s_addr = fl4.saddr;
 
 	return csk;
 
-- 
1.7.4.5

