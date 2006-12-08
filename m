From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 10/22] e1000: Make copybreak parameter changeable by user.
Date: Fri, 08 Dec 2006 15:03:07 -0800
Message-ID: <20061208230306.30109.9494.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4386 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761260AbWLHWxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:02 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Allow the user to vary the size that copybreak works. Currently cb is enabled
for packets < 256 bytes, but various tests indicate that this should be
configurable for specific use cases.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index a7dba40..0ebd8e2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -213,6 +213,13 @@ static void e1000_netpoll (struct net_de
 
 extern void e1000_check_options(struct e1000_adapter *adapter);
 
+#define COPYBREAK_DEFAULT 256
+static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
+module_param(copybreak, uint, 0644);
+MODULE_PARM_DESC(copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
+
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
 
@@ -4235,8 +4248,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts
 		 * of reassembly being done in the stack */
-#define E1000_CB_LENGTH 256
-		if (length < E1000_CB_LENGTH) {
+		if (length < copybreak) {
 			struct sk_buff *new_skb =
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
@@ -4394,7 +4406,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 
 		/* page alloc/put takes too long and effects small packet
 		 * throughput, so unsplit small packets and save the alloc/put*/
-		if (l1 && ((length + l1) <= adapter->rx_ps_bsize0)) {
+		if (l1 && (l1 <= copybreak) && ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
 			/* there is no documentation about how to call
 			 * kmap_atomic, so we can't hold the mapping



---
Auke Kok <auke-jan.h.kok@intel.com>
