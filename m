From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/9] cxgb4i: Handle dst_get_neighbour_noref() returning
 NULL.
Date: Fri, 02 Dec 2011 21:52:39 -0500 (EST)
Message-ID: <20111202.215239.198672307411678191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab1LCCwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index c8fd13a..5a4a3bf 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1127,6 +1127,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	struct net_device *ndev = cdev->ports[csk->port_id];
 	struct port_info *pi = netdev_priv(ndev);
 	struct sk_buff *skb = NULL;
+	struct neighbour *n;
 	unsigned int step;
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
@@ -1141,7 +1142,12 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	csk->l2t = cxgb4_l2t_get(lldi->l2t, dst_get_neighbour_noref(csk->dst), ndev, 0);
+	n = dst_get_neighbour_noref(csk->dst);
+	if (!n) {
+		pr_err("%s, can't get neighbour of csk->dst.\n", ndev->name);
+		goto rel_resource;
+	}
+	csk->l2t = cxgb4_l2t_get(lldi->l2t, n, ndev, 0);
 	if (!csk->l2t) {
 		pr_err("%s, cannot alloc l2t.\n", ndev->name);
 		goto rel_resource;
-- 
1.7.7.3
