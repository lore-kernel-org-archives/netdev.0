From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 1/2] be2net: remove usage of be_pci_func
Date: Mon, 8 Mar 2010 05:51:27 +0530
Message-ID: <20100308002125.GA18118@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:59333 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab0CHAVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 19:21:30 -0500
Received: by gwb15 with SMTP id 15so2735082gwb.19
        for <netdev@vger.kernel.org>; Sun, 07 Mar 2010 16:21:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When PCI functions are virtuialized in applications by assigning PCI
functions to VM (PCI passthrough), the be2net driver in the VM sees a
different function number. So, use of PCI function number in any
calculation will break existing code. This patch takes care of it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    5 -----
 drivers/net/benet/be_cmds.c |    6 ------
 drivers/net/benet/be_main.c |    2 +-
 3 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index be81fb2..8f07525 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -290,11 +290,6 @@ extern const struct ethtool_ops be_ethtool_ops;
 
 #define drvr_stats(adapter)		(&adapter->stats.drvr_stats)
 
-static inline unsigned int be_pci_func(struct be_adapter *adapter)
-{
-	return PCI_FUNC(adapter->pdev->devfn);
-}
-
 #define BE_SET_NETDEV_OPS(netdev, ops)	(netdev->netdev_ops = ops)
 
 #define PAGE_SHIFT_4K		12
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 4b1f805..c592153 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -465,8 +465,6 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 
-	AMAP_SET_BITS(struct amap_eq_context, func, req->context,
-			be_pci_func(adapter));
 	AMAP_SET_BITS(struct amap_eq_context, valid, req->context, 1);
 	/* 4byte eqe*/
 	AMAP_SET_BITS(struct amap_eq_context, size, req->context, 0);
@@ -629,7 +627,6 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 	AMAP_SET_BITS(struct amap_cq_context, eventable, ctxt, 1);
 	AMAP_SET_BITS(struct amap_cq_context, eqid, ctxt, eq->id);
 	AMAP_SET_BITS(struct amap_cq_context, armed, ctxt, 1);
-	AMAP_SET_BITS(struct amap_cq_context, func, ctxt, be_pci_func(adapter));
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
@@ -678,7 +675,6 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 
 	req->num_pages = PAGES_4K_SPANNED(q_mem->va, q_mem->size);
 
-	AMAP_SET_BITS(struct amap_mcc_context, fid, ctxt, be_pci_func(adapter));
 	AMAP_SET_BITS(struct amap_mcc_context, valid, ctxt, 1);
 	AMAP_SET_BITS(struct amap_mcc_context, ring_size, ctxt,
 		be_encoded_q_len(mccq->len));
@@ -727,8 +723,6 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 
 	AMAP_SET_BITS(struct amap_tx_context, tx_ring_size, ctxt,
 		be_encoded_q_len(txq->len));
-	AMAP_SET_BITS(struct amap_tx_context, pci_func_id, ctxt,
-			be_pci_func(adapter));
 	AMAP_SET_BITS(struct amap_tx_context, ctx_valid, ctxt, 1);
 	AMAP_SET_BITS(struct amap_tx_context, cq_id_send, ctxt, cq->id);
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 22f787f..7c9b57e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1382,7 +1382,7 @@ rx_eq_free:
 /* There are 8 evt ids per func. Retruns the evt id's bit number */
 static inline int be_evt_bit_get(struct be_adapter *adapter, u32 eq_id)
 {
-	return eq_id - 8 * be_pci_func(adapter);
+	return eq_id % 8;
 }
 
 static irqreturn_t be_intx(int irq, void *dev)
-- 
1.6.3.3

