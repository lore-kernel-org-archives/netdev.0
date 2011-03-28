From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/2] solos-pci: Signaling changes to carrier state
Date: Sun, 27 Mar 2011 19:06:35 -0700
Message-ID: <4D8FED2B.40904@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60896 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753251Ab1C1CGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 22:06:42 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local (pool-71-111-146-59.ptldor.dsl-w.verizon.net [71.111.146.59])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id p2S26aZW018745
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 20:06:42 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     Refactor to share common code from atm module (atm_dev_release_vccs()).

Signed-off-by: Philip Prindeville<philipp@redfish-solutions.com>
---
  drivers/atm/solos-pci.c |   25 +------------------------
  include/linux/atmdev.h  |    1 +
  net/atm/common.c        |    1 +
  3 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 968f022..265bbdf 100644
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
@@ -384,7 +383,7 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
  	/* Anything but 'Showtime' is down */
  	if (strcmp(state_str, "Showtime")) {
  		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
-		release_vccs(card->atmdev[port]);
+		atm_dev_release_vccs(card->atmdev[port]);
  		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
  		return 0;
  	}
@@ -830,28 +829,6 @@ static int list_vccs(int vci)
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


