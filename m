From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 12/14] e1000: Make the copybreak value a module parameter
Date: Fri, 15 Dec 2006 10:40:39 +0100
Message-ID: <1166175639.3365.133.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751503AbWLOKBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:01:09 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9h2LI006193
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:43:02 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9h1qc006192
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:43:01 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: Make the copybreak value a module parameter
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Allow the user to vary the size that copybreak works. Currently cb is enabled
for packets < 256 bytes, but various tests indicate that this should be
configurable for specific use cases. In addition, this parameter allows us
to force never/always during testing to get full and predictable coverage of 
both code paths.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |   19 ++++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -213,6 +213,12 @@ static void e1000_netpoll (struct net_de
 
 extern void e1000_check_options(struct e1000_adapter *adapter);
 
+#define COPYBREAK_DEFAULT 256
+static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
+module_param(copybreak, uint, 0644);
+MODULE_PARM_DESC(copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
+
 static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
                      pci_channel_state_t state);
 static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev);
@@ -264,7 +271,13 @@ e1000_init_module(void)
 	printk(KERN_INFO "%s\n", e1000_copyright);
 
 	ret = pci_register_driver(&e1000_driver);
-
+	if (copybreak != COPYBREAK_DEFAULT) {
+		if (copybreak == 0)
+			printk(KERN_INFO "e1000: copybreak disabled\n");
+		else
+			printk(KERN_INFO "e1000: copybreak enabled for "
+			       "packets <= %u bytes\n", copybreak);
+	}
 	return ret;
 }
 
@@ -4245,8 +4258,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts
 		 * of reassembly being done in the stack */
-#define E1000_CB_LENGTH 256
-		if (length < E1000_CB_LENGTH) {
+		if (length < copybreak) {
 			struct sk_buff *new_skb =
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
@@ -4404,7 +4416,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 
 		/* page alloc/put takes too long and effects small packet
 		 * throughput, so unsplit small packets and save the alloc/put*/
-		if (l1 && ((length + l1) <= adapter->rx_ps_bsize0)) {
+		if (l1 && (l1 <= copybreak) && ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
 			/* there is no documentation about how to call
 			 * kmap_atomic, so we can't hold the mapping

