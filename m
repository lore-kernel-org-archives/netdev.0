From: Scott Feldman <scott.feldman@intel.com>
Subject: [PATCH 2.6 2/3] e100: fix skb leak in tx timeout
Date: Thu, 10 Jun 2004 11:21:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406101116340.5831@sfeldma-ich5.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* If e100 experiences a transmit timeout, and the tx ring is completely
full at the time, it will leak all of the skbs on the tx ring (because
extra logic is needed to distinguish ring full from ring empty).  Jay
Vosburgh [fubar@us.ibm.com].

Signed-off by: scott.feldman@intel.com


-----------

--- linux-2.5/drivers/net/e100.c	2004-06-10 11:07:00.015557584 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-06-10 11:07:18.487749384 -0700
@@ -1323,7 +1323,7 @@ static inline int e100_tx_clean(struct n
 static void e100_clean_cbs(struct nic *nic)
 {
 	if(nic->cbs) {
-		while(nic->cb_to_clean != nic->cb_to_use) {
+		while(nic->cbs_avail != nic->params.cbs.count) {
 			struct cb *cb = nic->cb_to_clean;
 			if(cb->skb) {
 				pci_unmap_single(nic->pdev,
@@ -1333,8 +1333,8 @@ static void e100_clean_cbs(struct nic *n
 				dev_kfree_skb(cb->skb);
 			}
 			nic->cb_to_clean = nic->cb_to_clean->next;
+			nic->cbs_avail++;
 		}
-		nic->cbs_avail = nic->params.cbs.count;
 		pci_free_consistent(nic->pdev,
 			sizeof(struct cb) * nic->params.cbs.count,
 			nic->cbs, nic->cbs_dma_addr);
