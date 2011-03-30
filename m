From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/1] atm/solos-pci: Don't flap VCs when carrier state changes
Date: Wed, 30 Mar 2011 17:17:04 -0600
Message-ID: <1301527024-28875-1-git-send-email-philipp_subx@redfish-solutions.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:41829 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613Ab1C3XRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 19:17:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip A. Prindeville <philipp@redfish-solutions.com>

Don't flap VCs when carrier state changes; higher-level protocols
can detect loss of connectivity and act accordingly. This is more
consistent with how other network interfaces work.

We no longer use release_vccs() so we can delete it.

release_vccs() was duplicated from net/atm/common.c; make the
corresponding function exported, since other code duplicates it
and could leverage it if it were public.

Signed-off-by: Philip A. Prindeville <philipp@redfish-solutions.com>
---
 drivers/atm/solos-pci.c |   26 +-------------------------
 include/linux/atmdev.h  |    1 +
 net/atm/common.c        |    1 +
 3 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 968f022..cd0ff66 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -165,7 +165,6 @@ static uint32_t fpga_tx(struct solos_card *);
 static irqreturn_t solos_irq(int irq, void *dev_id);
 static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vci);
 static int list_vccs(int vci);
-static void release_vccs(struct atm_dev *dev);
 static int atm_init(struct solos_card *, struct device *);
 static void atm_remove(struct solos_card *);
 static int send_command(struct solos_card *card, int dev, const char *buf, size_t size);
@@ -384,7 +383,6 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 	/* Anything but 'Showtime' is down */
 	if (strcmp(state_str, "Showtime")) {
 		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
-		release_vccs(card->atmdev[port]);
 		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
 		return 0;
 	}
@@ -830,28 +828,6 @@ static int list_vccs(int vci)
 	return num_found;
 }
 
-static void release_vccs(struct atm_dev *dev)
-{
-        int i;
-
-        write_lock_irq(&vcc_sklist_lock);
-        for (i = 0; i < VCC_HTABLE_SIZE; i++) {
-                struct hlist_head *head = &vcc_hash[i];
-                struct hlist_node *node, *tmp;
-                struct sock *s;
-                struct atm_vcc *vcc;
-
-                sk_for_each_safe(s, node, tmp, head) {
-                        vcc = atm_sk(s);
-                        if (vcc->dev == dev) {
-                                vcc_release_async(vcc, -EPIPE);
-                                sk_del_node_init(s);
-                        }
-                }
-        }
-        write_unlock_irq(&vcc_sklist_lock);
-}
-
 
 static int popen(struct atm_vcc *vcc)
 {
@@ -1269,7 +1245,7 @@ static int atm_init(struct solos_card *card, struct device *parent)
 		card->atmdev[i]->ci_range.vci_bits = 16;
 		card->atmdev[i]->dev_data = card;
 		card->atmdev[i]->phy_data = (void *)(unsigned long)i;
-		atm_dev_signal_change(card->atmdev[i], ATM_PHY_SIG_UNKNOWN);
+		atm_dev_signal_change(card->atmdev[i], ATM_PHY_SIG_FOUND);
 
 		skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
 		if (!skb) {
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 475f8c4..381f4ce 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -443,6 +443,7 @@ void atm_dev_signal_change(struct atm_dev *dev, char signal);
 
 void vcc_insert_socket(struct sock *sk);
 
+void atm_dev_release_vccs(struct atm_dev *dev);
 
 /*
  * This is approximately the algorithm used by alloc_skb.
diff --git a/net/atm/common.c b/net/atm/common.c
index 1b9c52a..22b963d 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -252,6 +252,7 @@ void atm_dev_release_vccs(struct atm_dev *dev)
 	}
 	write_unlock_irq(&vcc_sklist_lock);
 }
+EXPORT_SYMBOL(atm_dev_release_vccs);
 
 static int adjust_tp(struct atm_trafprm *tp, unsigned char aal)
 {
-- 
1.7.4

