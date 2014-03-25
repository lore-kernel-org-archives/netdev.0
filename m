From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 27/54] ehea: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:13 -0700
Message-ID: <1395727540-12148-27-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58475 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbaCYGLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:34 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in functions that can
be called in hard irq and other contexts.

None of the locations was a packet drop so dev_kfree_skb_any is
inappropriate.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 7628e0fd8455..538903bf13bc 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -490,7 +490,7 @@ static int ehea_refill_rq_def(struct ehea_port_res *pr,
 		skb_arr[index] = skb;
 		tmp_addr = ehea_map_vaddr(skb->data);
 		if (tmp_addr == -1) {
-			dev_kfree_skb(skb);
+			dev_consume_skb_any(skb);
 			q_skba->os_skbs = fill_wqes - i;
 			ret = 0;
 			break;
@@ -856,7 +856,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 
 			index = EHEA_BMASK_GET(EHEA_WR_ID_INDEX, cqe->wr_id);
 			skb = pr->sq_skba.arr[index];
-			dev_kfree_skb(skb);
+			dev_consume_skb_any(skb);
 			pr->sq_skba.arr[index] = NULL;
 		}
 
@@ -2044,7 +2044,7 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 		skb_copy_bits(skb, 0, imm_data, skb->len);
 
 	swqe->immediate_data_length = skb->len;
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 }
 
 static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.7.10.4
