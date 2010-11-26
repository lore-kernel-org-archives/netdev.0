From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Add some info messages and fix an issue
Date: Fri, 26 Nov 2010 14:26:11 -0200
Message-ID: <1290788771-10019-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:42191 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab0KZQ0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 11:26:32 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id oAQGeoed017340
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 14:40:50 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAQGXTBE2965720
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 14:33:29 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAQGQHev019090
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 14:26:17 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds some debug information about ehea not being able to
allocate enough spaces. Also it correctly updates the amount of available
skb.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_main.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 182b2a7..a70457b 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -400,6 +400,8 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
 			skb_arr_rq1[index] = netdev_alloc_skb(dev,
 							      EHEA_L_PKT_SIZE);
 			if (!skb_arr_rq1[index]) {
+				ehea_info("Unable to allocate enough skb in
+					   the array\n");
 				pr->rq1_skba.os_skbs = fill_wqes - i;
 				break;
 			}
@@ -422,13 +424,20 @@ static void ehea_init_fill_rq1(struct ehea_port_res *pr, int nr_rq1a)
 	struct net_device *dev = pr->port->netdev;
 	int i;
 
-	for (i = 0; i < pr->rq1_skba.len; i++) {
+	if (nr_rq1a > pr->rq1_skba.len) {
+		ehea_error("NR_RQ1A is bigger than skb array len\n");
+		return;
+	}
+
+	for (i = 0; i < nr_rq1a; i++) {
 		skb_arr_rq1[i] = netdev_alloc_skb(dev, EHEA_L_PKT_SIZE);
-		if (!skb_arr_rq1[i])
+		if (!skb_arr_rq1[i]) {
+			ehea_info("Not enough memory to allocate skb array\n");
 			break;
+		}
 	}
 	/* Ring doorbell */
-	ehea_update_rq1a(pr->qp, nr_rq1a);
+	ehea_update_rq1a(pr->qp, i);
 }
 
 static int ehea_refill_rq_def(struct ehea_port_res *pr,
@@ -735,8 +744,11 @@ static int ehea_proc_rwqes(struct net_device *dev,
 
 					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
-					if (!skb)
+					if (!skb) {
+						ehea_info("Not enough memory to
+							   allocate skb\n");
 						break;
+					}
 				}
 				skb_copy_to_linear_data(skb, ((char *)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
-- 
1.7.1

