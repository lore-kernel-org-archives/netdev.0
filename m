From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/9] libcxgbi: Handle dst_get_neighbour_noref() returning
 NULL.
Date: Fri, 02 Dec 2011 21:52:35 -0500 (EST)
Message-ID: <20111202.215235.725617299076899257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab1LCCwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/cxgbi/libcxgbi.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index a026a2f..1d25a87 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -472,6 +472,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	struct net_device *ndev;
 	struct cxgbi_device *cdev;
 	struct rtable *rt = NULL;
+	struct neighbour *n;
 	struct flowi4 fl4;
 	struct cxgbi_sock *csk = NULL;
 	unsigned int mtu = 0;
@@ -493,7 +494,12 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		goto err_out;
 	}
 	dst = &rt->dst;
-	ndev = dst_get_neighbour_noref(dst)->dev;
+	n = dst_get_neighbour_noref(dst);
+	if (!n) {
+		err = -ENODEV;
+		goto rel_rt;
+	}
+	ndev = n->dev;
 
 	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
 		pr_info("multi-cast route %pI4, port %u, dev %s.\n",
@@ -507,7 +513,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		ndev = ip_dev_find(&init_net, daddr->sin_addr.s_addr);
 		mtu = ndev->mtu;
 		pr_info("rt dev %s, loopback -> %s, mtu %u.\n",
-			dst_get_neighbour_noref(dst)->dev->name, ndev->name, mtu);
+			n->dev->name, ndev->name, mtu);
 	}
 
 	cdev = cxgbi_device_find_by_netdev(ndev, &port);
-- 
1.7.7.3
