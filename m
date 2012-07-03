From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/19] cxgbi: Convert over to dst_neigh_lookup().
Date: Tue, 03 Jul 2012 02:46:31 -0700 (PDT)
Message-ID: <20120703.024631.381383489523289799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100Ab2GCJqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:31 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6720A58411F
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/cxgbi/libcxgbi.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index d9253db..b44c1cf 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -494,7 +494,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		goto err_out;
 	}
 	dst = &rt->dst;
-	n = dst_get_neighbour_noref(dst);
+	n = dst_neigh_lookup(dst, &daddr->sin_addr.s_addr);
 	if (!n) {
 		err = -ENODEV;
 		goto rel_rt;
@@ -506,7 +506,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 			&daddr->sin_addr.s_addr, ntohs(daddr->sin_port),
 			ndev->name);
 		err = -ENETUNREACH;
-		goto rel_rt;
+		goto rel_neigh;
 	}
 
 	if (ndev->flags & IFF_LOOPBACK) {
@@ -521,7 +521,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		pr_info("dst %pI4, %s, NOT cxgbi device.\n",
 			&daddr->sin_addr.s_addr, ndev->name);
 		err = -ENETUNREACH;
-		goto rel_rt;
+		goto rel_neigh;
 	}
 	log_debug(1 << CXGBI_DBG_SOCK,
 		"route to %pI4 :%u, ndev p#%d,%s, cdev 0x%p.\n",
@@ -531,7 +531,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	csk = cxgbi_sock_create(cdev);
 	if (!csk) {
 		err = -ENOMEM;
-		goto rel_rt;
+		goto rel_neigh;
 	}
 	csk->cdev = cdev;
 	csk->port_id = port;
@@ -541,9 +541,13 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	csk->daddr.sin_port = daddr->sin_port;
 	csk->daddr.sin_family = daddr->sin_family;
 	csk->saddr.sin_addr.s_addr = fl4.saddr;
+	neigh_release(n);
 
 	return csk;
 
+rel_neigh:
+	neigh_release(n);
+
 rel_rt:
 	ip_rt_put(rt);
 	if (csk)
-- 
1.7.10
