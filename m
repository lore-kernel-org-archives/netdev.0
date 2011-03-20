From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/1] solos-pci: Use shared code for VCC management
Date: Sun, 20 Mar 2011 15:30:10 -0700
Message-ID: <4D867FF2.5040107@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:47476 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751349Ab1CTWaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 18:30:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The solos-pci driver duplicates the net/atm/common.c function atm_dev_release_vccs() locally as the static function release_vccs().  Let's have the driver share code.

Signed-off-by: Philip A. Prindeville <philipp@redfish-solutions.com>

---

--- a/drivers/atm/solos-pci.c	2011-03-20 01:42:22.000000000 -0600
+++ b/drivers/atm/solos-pci.c	2011-03-20 14:23:26.000000000 -0600
@@ -165,7 +165,6 @@ static uint32_t fpga_tx(struct solos_car
  static irqreturn_t solos_irq(int irq, void *dev_id);
  static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vci);
  static int list_vccs(int vci);
-static void release_vccs(struct atm_dev *dev);
  static int atm_init(struct solos_card *, struct device *);
  static void atm_remove(struct solos_card *);
  static int send_command(struct solos_card *card, int dev, const char *buf, size_t size);
@@ -384,7 +383,7 @@ static int process_status(struct solos_c
  	/* Anything but 'Showtime' is down */
  	if (strcmp(state_str, "Showtime")) {
  		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
-		release_vccs(card->atmdev[port]);
+		atm_dev_release_vccs(card->atmdev[port]);
  		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
  		return 0;
  	}
@@ -837,28 +836,6 @@ static int list_vccs(int vci)
  	return num_found;
  }

-static void release_vccs(struct atm_dev *dev)
-{
-        int i;
-
-        write_lock_irq(&vcc_sklist_lock);
-        for (i = 0; i<  VCC_HTABLE_SIZE; i++) {
-                struct hlist_head *head =&vcc_hash[i];
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
--- a/net/atm/common.c	2011-01-04 17:50:19.000000000 -0700
+++ b/net/atm/common.c	2011-03-20 15:22:59.000000000 -0600
@@ -252,6 +252,7 @@ void atm_dev_release_vccs(struct atm_dev
  	}
  	write_unlock_irq(&vcc_sklist_lock);
  }
+EXPORT_SYMBOL(atm_dev_release_vccs);

  static int adjust_tp(struct atm_trafprm *tp, unsigned char aal)
  {
--- a/include/linux/atmdev.h	2011-01-04 17:50:19.000000000 -0700
+++ b/include/linux/atmdev.h	2011-03-20 15:25:08.000000000 -0600
@@ -443,6 +443,7 @@ void atm_dev_signal_change(struct atm_de

  void vcc_insert_socket(struct sock *sk);

+void atm_dev_release_vccs(struct atm_dev *dev);

  /*
   * This is approximately the algorithm used by alloc_skb.


