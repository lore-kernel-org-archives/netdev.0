From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6] e100: 1/2 fix skb leak in tx timeout
Date: Tue, 08 Jun 2004 14:26:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406082126.i58LQZO5006010@death.nxdomain.ibm.com>
Cc: "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	If e100 experiences a transmit timeout, and the tx ring is
completely full at that time, it will leak all of the skbs on the tx
ring (because extra logic is needed to distinguish ring full from ring
empty).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


diff -urN linux-2.6.6-virgin/drivers/net/e100.c linux-2.6.6/drivers/net/e100.c
--- linux-2.6.6-virgin/drivers/net/e100.c	2004-06-08 13:51:34.000000000 -0700
+++ linux-2.6.6/drivers/net/e100.c	2004-06-08 13:52:37.000000000 -0700
@@ -1322,7 +1322,8 @@
 static void e100_clean_cbs(struct nic *nic)
 {
 	if(nic->cbs) {
-		while(nic->cb_to_clean != nic->cb_to_use) {
+		while((nic->cb_to_clean != nic->cb_to_use) ||
+		      (0 == nic->cbs_avail)) {
 			struct cb *cb = nic->cb_to_clean;
 			if(cb->skb) {
 				pci_unmap_single(nic->pdev,
@@ -1332,6 +1333,7 @@
 				dev_kfree_skb(cb->skb);
 			}
 			nic->cb_to_clean = nic->cb_to_clean->next;
+			nic->cbs_avail++;
 		}
 		nic->cbs_avail = nic->params.cbs.count;
 		pci_free_consistent(nic->pdev,
