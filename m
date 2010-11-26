From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Add some info messages and fix an issue
Date: Fri, 26 Nov 2010 15:26:27 -0200
Message-ID: <1290792387-12331-1-git-send-email-leitao@linux.vnet.ibm.com>
References: <1290790908.11971.303.camel@Joe-Laptop>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:49845 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507Ab0KZR0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 12:26:36 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id oAQHJ0K3018851
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 15:19:00 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAQHPEF71859704
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 14:25:14 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAQHQJqf009187
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 15:26:20 -0200
In-Reply-To: <1290790908.11971.303.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <breno@cafe.(none)>

This patch adds some debug information about ehea not being able to
allocate enough spaces. Also it correctly updates the amount of available
skb.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_main.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 182b2a7..3d0af08 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -400,6 +400,7 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
 			skb_arr_rq1[index] = netdev_alloc_skb(dev,
 							      EHEA_L_PKT_SIZE);
 			if (!skb_arr_rq1[index]) {
+				ehea_info("Unable to allocate enough skb in the array\n");
 				pr->rq1_skba.os_skbs = fill_wqes - i;
 				break;
 			}
@@ -422,13 +423,20 @@ static void ehea_init_fill_rq1(struct ehea_port_res *pr, int nr_rq1a)
 	struct net_device *dev = pr->port->netdev;
 	int i;
 
-	for (i = 0; i < pr->rq1_skba.len; i++) {
+	if (nr_rq1a > pr->rq1_skba.len) {
+		ehea_error("NR_RQ1A bigger than skb array len\n");
+		return;
+	}
+
+	for (i = 0; i < nr_rq1a; i++) {
 		skb_arr_rq1[i] = netdev_alloc_skb(dev, EHEA_L_PKT_SIZE);
-		if (!skb_arr_rq1[i])
+		if (!skb_arr_rq1[i]) {
+			ehea_info("No enough memory to allocate skb array\n");
 			break;
+		}
 	}
 	/* Ring doorbell */
-	ehea_update_rq1a(pr->qp, nr_rq1a);
+	ehea_update_rq1a(pr->qp, i);
 }
 
 static int ehea_refill_rq_def(struct ehea_port_res *pr,
@@ -735,8 +743,10 @@ static int ehea_proc_rwqes(struct net_device *dev,
 
 					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
-					if (!skb)
+					if (!skb) {
+						ehea_info("Not enough memory to allocate skb\n");
 						break;
+					}
 				}
 				skb_copy_to_linear_data(skb, ((char *)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
-- 
1.7.1

