From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 09/30] solos: Kill existing connections on link down event
Date: Tue, 17 Mar 2009 21:29:17 +0000
Message-ID: <1237325357.27681.338.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37657 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758058AbZCQV3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:24 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqg-0001v3-3Z
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:22 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   30 ++++++++++++++++++++++++++++--
 1 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 4c87dfb..c289b62 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -132,6 +132,7 @@ static int fpga_tx(struct solos_card *);
 static irqreturn_t solos_irq(int irq, void *dev_id);
 static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vci);
 static int list_vccs(int vci);
+static void release_vccs(struct atm_dev *dev);
 static int atm_init(struct solos_card *);
 static void atm_remove(struct solos_card *);
 static int send_command(struct solos_card *card, int dev, const char *buf, size_t size);
@@ -332,7 +333,10 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 	str = next_string(skb);
 	if (!strcmp(str, "Showtime"))
 		state = ATM_PHY_SIG_FOUND;
-	else state = ATM_PHY_SIG_LOST;
+	else {
+		state = ATM_PHY_SIG_LOST;
+		release_vccs(card->atmdev[port]);
+	}
 
 	card->atmdev[port]->link_rate = rate_down;
 	card->atmdev[port]->signal = state;
@@ -683,7 +687,7 @@ static int list_vccs(int vci)
 			       vcc->vci);
 		}
 	} else {
-		for(i=0; i<32; i++){
+		for(i = 0; i < VCC_HTABLE_SIZE; i++){
 			head = &vcc_hash[i];
 			sk_for_each(s, node, head) {
 				num_found ++;
@@ -699,6 +703,28 @@ static int list_vccs(int vci)
 	return num_found;
 }
 
+static void release_vccs(struct atm_dev *dev)
+{
+        int i;
+
+        write_lock_irq(&vcc_sklist_lock);
+        for (i = 0; i < VCC_HTABLE_SIZE; i++) {
+                struct hlist_head *head = &vcc_hash[i];
+                struct hlist_node *node, *tmp;
+                struct sock *s;
+                struct atm_vcc *vcc;
+
+                sk_for_each_safe(s, node, tmp, head) {
+                        vcc = atm_sk(s);
+                        if (vcc->dev == dev) {
+                                vcc_release_async(vcc, -EPIPE);
+                                sk_del_node_init(s);
+                        }
+                }
+        }
+        write_unlock_irq(&vcc_sklist_lock);
+}
+
 
 static int popen(struct atm_vcc *vcc)
 {
-- 
1.6.0.6


