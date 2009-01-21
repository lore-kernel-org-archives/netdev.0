From: Thomas Klein <tklein@de.ibm.com>
Subject: [PATCH 3/3] ehea: Improve driver behaviour in low mem conditions
Date: Wed, 21 Jan 2009 15:49:41 +0100
Message-ID: <200901211549.41352.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:46820 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254AbZAUOwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 09:52:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reworked receive queue fill policies to make the driver more tolerant
in low memory conditions.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
diff -Nurp -X dontdiff linux-2.6.29-rc2/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.29-rc2/drivers/net/ehea/ehea_main.c	2009-01-20 17:03:17.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2009-01-20 17:03:57.000000000 +0100
@@ -370,8 +370,6 @@ static void ehea_refill_rq1(struct ehea_
 							      EHEA_L_PKT_SIZE);
 			if (!skb_arr_rq1[index]) {
 				pr->rq1_skba.os_skbs = fill_wqes - i;
-				ehea_error("%s: no mem for skb/%d wqes filled",
-					   dev->name, i);
 				break;
 			}
 		}
@@ -387,26 +385,19 @@ static void ehea_refill_rq1(struct ehea_
 	ehea_update_rq1a(pr->qp, adder);
 }
 
-static int ehea_init_fill_rq1(struct ehea_port_res *pr, int nr_rq1a)
+static void ehea_init_fill_rq1(struct ehea_port_res *pr, int nr_rq1a)
 {
-	int ret = 0;
 	struct sk_buff **skb_arr_rq1 = pr->rq1_skba.arr;
 	struct net_device *dev = pr->port->netdev;
 	int i;
 
 	for (i = 0; i < pr->rq1_skba.len; i++) {
 		skb_arr_rq1[i] = netdev_alloc_skb(dev, EHEA_L_PKT_SIZE);
-		if (!skb_arr_rq1[i]) {
-			ehea_error("%s: no mem for skb/%d wqes filled",
-				   dev->name, i);
-			ret = -ENOMEM;
-			goto out;
-		}
+		if (!skb_arr_rq1[i])
+			break;
 	}
 	/* Ring doorbell */
 	ehea_update_rq1a(pr->qp, nr_rq1a);
-out:
-	return ret;
 }
 
 static int ehea_refill_rq_def(struct ehea_port_res *pr,
@@ -435,10 +426,12 @@ static int ehea_refill_rq_def(struct ehe
 		u64 tmp_addr;
 		struct sk_buff *skb = netdev_alloc_skb(dev, packet_size);
 		if (!skb) {
-			ehea_error("%s: no mem for skb/%d wqes filled",
-				   pr->port->netdev->name, i);
 			q_skba->os_skbs = fill_wqes - i;
-			ret = -ENOMEM;
+			if (q_skba->os_skbs == q_skba->len - 2) {
+				ehea_info("%s: rq%i ran dry - no mem for skb",
+					  pr->port->netdev->name, rq_nr);
+				ret = -ENOMEM;
+			}
 			break;
 		}
 		skb_reserve(skb, NET_IP_ALIGN);
@@ -1201,11 +1194,11 @@ static int ehea_fill_port_res(struct ehe
 	int ret;
 	struct ehea_qp_init_attr *init_attr = &pr->qp->init_attr;
 
-	ret = ehea_init_fill_rq1(pr, init_attr->act_nr_rwqes_rq1
-				     - init_attr->act_nr_rwqes_rq2
-				     - init_attr->act_nr_rwqes_rq3 - 1);
+	ehea_init_fill_rq1(pr, init_attr->act_nr_rwqes_rq1
+			       - init_attr->act_nr_rwqes_rq2
+			       - init_attr->act_nr_rwqes_rq3 - 1);
 
-	ret |= ehea_refill_rq2(pr, init_attr->act_nr_rwqes_rq2 - 1);
+	ret = ehea_refill_rq2(pr, init_attr->act_nr_rwqes_rq2 - 1);
 
 	ret |= ehea_refill_rq3(pr, init_attr->act_nr_rwqes_rq3 - 1);
 
