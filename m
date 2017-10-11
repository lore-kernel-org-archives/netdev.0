From: Allen Pais <allen.pais-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] [net-next]NFC: Convert timers to use timer_setup()
Date: Wed, 11 Oct 2017 16:03:44 +0530
Message-ID: <1507718024-2134-1-git-send-email-allen.pais@oracle.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Allen Pais <allen.pais-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Switch to using the new timer_setup() and from_timer()
for net/nfc/*

Signed-off-by: Allen Pais <allen.pais-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
---
 net/nfc/core.c          |  8 +++-----
 net/nfc/hci/core.c      |  7 +++----
 net/nfc/hci/llc_shdlc.c | 23 +++++++++--------------
 net/nfc/llcp_core.c     | 14 ++++++--------
 4 files changed, 21 insertions(+), 31 deletions(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index e5e23c2..56e5467 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -1015,9 +1015,9 @@ static void nfc_check_pres_work(struct work_struct *work)
 	device_unlock(&dev->dev);
 }
 
-static void nfc_check_pres_timeout(unsigned long data)
+static void nfc_check_pres_timeout(struct timer_list *t)
 {
-	struct nfc_dev *dev = (struct nfc_dev *)data;
+	struct nfc_dev *dev = from_timer(dev, t, check_pres_timer);
 
 	schedule_work(&dev->check_pres_work);
 }
@@ -1094,9 +1094,7 @@ struct nfc_dev *nfc_allocate_device(struct nfc_ops *ops,
 	dev->targets_generation = 1;
 
 	if (ops->check_presence) {
-		setup_timer(&dev->check_pres_timer, nfc_check_pres_timeout,
-			    (unsigned long)dev);
-
+		timer_setup(&dev->check_pres_timer, nfc_check_pres_timeout, 0);
 		INIT_WORK(&dev->check_pres_work, nfc_check_pres_work);
 	}
 
diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index a8a6e78..ac8030c4 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -428,9 +428,9 @@ void nfc_hci_event_received(struct nfc_hci_dev *hdev, u8 pipe, u8 event,
 		nfc_hci_driver_failure(hdev, r);
 }
 
-static void nfc_hci_cmd_timeout(unsigned long data)
+static void nfc_hci_cmd_timeout(struct timer_list *t)
 {
-	struct nfc_hci_dev *hdev = (struct nfc_hci_dev *)data;
+	struct nfc_hci_dev *hdev = from_timer(hdev, t, cmd_timer);
 
 	schedule_work(&hdev->msg_tx_work);
 }
@@ -1004,8 +1004,7 @@ int nfc_hci_register_device(struct nfc_hci_dev *hdev)
 
 	INIT_WORK(&hdev->msg_tx_work, nfc_hci_msg_tx_work);
 
-	setup_timer(&hdev->cmd_timer, nfc_hci_cmd_timeout,
-		    (unsigned long)hdev);
+	timer_setup(&hdev->cmd_timer, nfc_hci_cmd_timeout, 0);
 
 	skb_queue_head_init(&hdev->rx_hcp_frags);
 
diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index 58df37e..fe98893 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -580,27 +580,27 @@ static void llc_shdlc_handle_send_queue(struct llc_shdlc *shdlc)
 	}
 }
 
-static void llc_shdlc_connect_timeout(unsigned long data)
+static void llc_shdlc_connect_timeout(struct timer_list *t)
 {
-	struct llc_shdlc *shdlc = (struct llc_shdlc *)data;
+	struct llc_shdlc *shdlc = from_timer(shdlc, t, connect_timer);
 
 	pr_debug("\n");
 
 	schedule_work(&shdlc->sm_work);
 }
 
-static void llc_shdlc_t1_timeout(unsigned long data)
+static void llc_shdlc_t1_timeout(struct timer_list *t)
 {
-	struct llc_shdlc *shdlc = (struct llc_shdlc *)data;
+	struct llc_shdlc *shdlc = from_timer(shdlc, t, t1_timer);
 
 	pr_debug("SoftIRQ: need to send ack\n");
 
 	schedule_work(&shdlc->sm_work);
 }
 
-static void llc_shdlc_t2_timeout(unsigned long data)
+static void llc_shdlc_t2_timeout(struct timer_list *t)
 {
-	struct llc_shdlc *shdlc = (struct llc_shdlc *)data;
+	struct llc_shdlc *shdlc = from_timer(shdlc, t, t2_timer);
 
 	pr_debug("SoftIRQ: need to retransmit\n");
 
@@ -763,14 +763,9 @@ static void *llc_shdlc_init(struct nfc_hci_dev *hdev, xmit_to_drv_t xmit_to_drv,
 	mutex_init(&shdlc->state_mutex);
 	shdlc->state = SHDLC_DISCONNECTED;
 
-	setup_timer(&shdlc->connect_timer, llc_shdlc_connect_timeout,
-		    (unsigned long)shdlc);
-
-	setup_timer(&shdlc->t1_timer, llc_shdlc_t1_timeout,
-		    (unsigned long)shdlc);
-
-	setup_timer(&shdlc->t2_timer, llc_shdlc_t2_timeout,
-		    (unsigned long)shdlc);
+	timer_setup(&shdlc->connect_timer, llc_shdlc_connect_timeout, 0);
+	timer_setup(&shdlc->t1_timer, llc_shdlc_t1_timeout, 0);
+	timer_setup(&shdlc->t2_timer, llc_shdlc_t2_timeout, 0);
 
 	shdlc->w = SHDLC_MAX_WINDOW;
 	shdlc->srej_support = SHDLC_SREJ_SUPPORT;
diff --git a/net/nfc/llcp_core.c b/net/nfc/llcp_core.c
index 7988185..ef4026a 100644
--- a/net/nfc/llcp_core.c
+++ b/net/nfc/llcp_core.c
@@ -242,9 +242,9 @@ static void nfc_llcp_timeout_work(struct work_struct *work)
 	nfc_dep_link_down(local->dev);
 }
 
-static void nfc_llcp_symm_timer(unsigned long data)
+static void nfc_llcp_symm_timer(struct timer_list *t)
 {
-	struct nfc_llcp_local *local = (struct nfc_llcp_local *) data;
+	struct nfc_llcp_local *local = from_timer(local, t, link_timer);
 
 	pr_err("SYMM timeout\n");
 
@@ -285,9 +285,9 @@ static void nfc_llcp_sdreq_timeout_work(struct work_struct *work)
 		nfc_genl_llc_send_sdres(local->dev, &nl_sdres_list);
 }
 
-static void nfc_llcp_sdreq_timer(unsigned long data)
+static void nfc_llcp_sdreq_timer(struct timer_list *t)
 {
-	struct nfc_llcp_local *local = (struct nfc_llcp_local *) data;
+	struct nfc_llcp_local *local = from_timer(local, t, sdreq_timer);
 
 	schedule_work(&local->sdreq_timeout_work);
 }
@@ -1573,8 +1573,7 @@ int nfc_llcp_register_device(struct nfc_dev *ndev)
 	INIT_LIST_HEAD(&local->list);
 	kref_init(&local->ref);
 	mutex_init(&local->sdp_lock);
-	setup_timer(&local->link_timer, nfc_llcp_symm_timer,
-		    (unsigned long)local);
+	timer_setup(&local->link_timer, nfc_llcp_symm_timer, 0);
 
 	skb_queue_head_init(&local->tx_queue);
 	INIT_WORK(&local->tx_work, nfc_llcp_tx_work);
@@ -1600,8 +1599,7 @@ int nfc_llcp_register_device(struct nfc_dev *ndev)
 
 	mutex_init(&local->sdreq_lock);
 	INIT_HLIST_HEAD(&local->pending_sdreqs);
-	setup_timer(&local->sdreq_timer, nfc_llcp_sdreq_timer,
-		    (unsigned long)local);
+	timer_setup(&local->sdreq_timer, nfc_llcp_sdreq_timer, 0);
 	INIT_WORK(&local->sdreq_timeout_work, nfc_llcp_sdreq_timeout_work);
 
 	list_add(&local->list, &llcp_devices);
-- 
2.7.4
