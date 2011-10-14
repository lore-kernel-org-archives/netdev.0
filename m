From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 14/15] ehea: Add GRO support
Date: Fri, 14 Oct 2011 12:31:11 -0300
Message-ID: <1318606272-27647-15-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51442 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933207Ab1JNPbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:49 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9EGqd4B010483
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:52:39 -0400
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFUNaW3023012
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:23 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVdXJ008902
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:40 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

Add GRO support to the ehea driver.

v3:
[cascardo] no need to enable GRO, since it's enabled by default
[cascardo] vgrp was removed in the vlan cleanup

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 3b8e657..bfd08b2 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -647,15 +647,6 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	return 0;
 }
 
-static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
-			  struct sk_buff *skb)
-{
-	if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
-		__vlan_hwaccel_put_tag(skb, cqe->vlan_tag);
-
-	netif_receive_skb(skb);
-}
-
 static int ehea_proc_rwqes(struct net_device *dev,
 			   struct ehea_port_res *pr,
 			   int budget)
@@ -732,7 +723,11 @@ static int ehea_proc_rwqes(struct net_device *dev,
 			}
 
 			processed_bytes += skb->len;
-			ehea_proc_skb(pr, cqe, skb);
+
+			if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+				__vlan_hwaccel_put_tag(skb, cqe->vlan_tag);
+
+			napi_gro_receive(&pr->napi, skb);
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
-- 
1.7.4.4
