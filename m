From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 5/5] iwlwifi: iwl3945 switch private
	workqueue to ieee80211->workqueue
Date: Wed,  9 Jan 2008 20:03:14 +0900
Message-ID: <1199876594889-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Joonwoo Park <joonwpark81@gmail.com>,
	ipw3945-devel@lists.sourceforge.net
To: Zhu Yi <yi.zhu@intel.com>, netdev@vger.kernel.org
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The ieee80211 provides workqueue for nic drivers. private workqueue dosen't need anymore
TODO: remove workqueue in iwl_priv

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    6 ++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   53 ++++++++++-----------------
 2 files changed, 23 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 3a45fe9..65283e9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -423,7 +423,7 @@ static void iwl3945_rx_reply_rx(struct iwl_priv *priv,
 					if (priv->call_post_assoc_from_beacon &&
 					    (priv->iw_mode ==
 						IEEE80211_IF_TYPE_STA))
-						queue_work(priv->workqueue,
+						queue_work(priv->hw->workqueue,
 						    &priv->post_associate.work);
 
 					priv->call_post_assoc_from_beacon = 0;
@@ -452,7 +452,7 @@ static void iwl3945_rx_reply_rx(struct iwl_priv *priv,
 				priv->assoc_capability =
 				    le16_to_cpu(mgnt->u.assoc_resp.capab_info);
 				if (priv->beacon_int)
-					queue_work(priv->workqueue,
+					queue_work(priv->hw->workqueue,
 					    &priv->post_associate.work);
 				else
 					priv->call_post_assoc_from_beacon = 1;
@@ -1775,7 +1775,7 @@ void iwl3945_reg_txpower_periodic(struct iwl_priv *priv)
 	iwl_hw_reg_comp_txpower_temp(priv);
 
  reschedule:
-	queue_delayed_work(priv->workqueue,
+	queue_delayed_work(priv->hw->workqueue,
 			   &priv->thermal_periodic, REG_RECALIB_PERIOD * HZ);
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 7e8d8b3..bf1fd56 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2248,7 +2248,7 @@ static int iwl_scan_cancel(struct iwl_priv *priv)
 		if (!test_bit(STATUS_SCAN_ABORTING, &priv->status)) {
 			IWL_DEBUG_SCAN("Queuing scan abort.\n");
 			set_bit(STATUS_SCAN_ABORTING, &priv->status);
-			queue_work(priv->workqueue, &priv->abort_scan);
+			queue_work(priv->hw->workqueue, &priv->abort_scan);
 
 		} else
 			IWL_DEBUG_SCAN("Scan abort already in progress.\n");
@@ -2399,7 +2399,7 @@ static int iwl_scan_initiate(struct iwl_priv *priv)
 	priv->scan_start = jiffies;
 	priv->scan_pass_start = priv->scan_start;
 
-	queue_work(priv->workqueue, &priv->request_scan);
+	queue_work(priv->hw->workqueue, &priv->request_scan);
 
 	return 0;
 }
@@ -3014,7 +3014,7 @@ static void iwl_radio_kill_sw(struct iwl_priv *priv, int disable_radio)
 		return;
 	}
 
-	queue_work(priv->workqueue, &priv->restart);
+	queue_work(priv->hw->workqueue, &priv->restart);
 	return;
 }
 
@@ -3389,7 +3389,7 @@ int iwl_tx_queue_reclaim(struct iwl_priv *priv, int txq_id, int index)
 		} else if (nfreed > 1) {
 			IWL_ERROR("HCMD skipped: index (%d) %d %d\n", index,
 					q->first_empty, q->last_used);
-			queue_work(priv->workqueue, &priv->restart);
+			queue_work(priv->hw->workqueue, &priv->restart);
 		}
 		nfreed++;
 	}
@@ -3489,7 +3489,7 @@ static void iwl_rx_reply_alive(struct iwl_priv *priv,
 	/* We delay the ALIVE response by 5ms to
 	 * give the HW RF Kill time to activate... */
 	if (palive->is_valid == UCODE_VALID_OK)
-		queue_delayed_work(priv->workqueue, pwork,
+		queue_delayed_work(priv->hw->workqueue, pwork,
 				   msecs_to_jiffies(5));
 	else
 		IWL_WARNING("uCode did not respond OK.\n");
@@ -3614,7 +3614,7 @@ static void iwl_rx_beacon_notif(struct iwl_priv *priv,
 
 	if ((priv->iw_mode == IEEE80211_IF_TYPE_AP) &&
 	    (!test_bit(STATUS_EXIT_PENDING, &priv->status)))
-		queue_work(priv->workqueue, &priv->beacon_update);
+		queue_work(priv->hw->workqueue, &priv->beacon_update);
 }
 
 /* Service response to REPLY_SCAN_CMD (0x80) */
@@ -3718,13 +3718,13 @@ static void iwl_rx_scan_complete_notif(struct iwl_priv *priv,
 	IWL_DEBUG_INFO("Scan took %dms\n",
 		jiffies_to_msecs(elapsed_jiffies(priv->scan_start, jiffies)));
 
-	queue_work(priv->workqueue, &priv->scan_completed);
+	queue_work(priv->hw->workqueue, &priv->scan_completed);
 
 	return;
 
 reschedule:
 	priv->scan_pass_start = jiffies;
-	queue_work(priv->workqueue, &priv->request_scan);
+	queue_work(priv->hw->workqueue, &priv->request_scan);
 }
 
 /* Handle notification from uCode that card's power state is changing
@@ -3760,7 +3760,7 @@ static void iwl_rx_card_state_notif(struct iwl_priv *priv,
 	     test_bit(STATUS_RF_KILL_HW, &priv->status)) ||
 	    (test_bit(STATUS_RF_KILL_SW, &status) !=
 	     test_bit(STATUS_RF_KILL_SW, &priv->status)))
-		queue_work(priv->workqueue, &priv->rf_kill);
+		queue_work(priv->hw->workqueue, &priv->rf_kill);
 	else
 		wake_up_interruptible(&priv->wait_command_queue);
 }
@@ -4029,7 +4029,7 @@ int iwl_rx_queue_restock(struct iwl_priv *priv)
 	/* If the pre-allocated buffer pool is dropping low, schedule to
 	 * refill it */
 	if (rxq->free_count <= RX_LOW_WATERMARK)
-		queue_work(priv->workqueue, &priv->rx_replenish);
+		queue_work(priv->hw->workqueue, &priv->rx_replenish);
 
 
 	/* If we've added more space for the firmware to place data, tell it */
@@ -4642,7 +4642,7 @@ static void iwl_irq_handle_error(struct iwl_priv *priv)
 			       sizeof(priv->recovery_rxon));
 			priv->error_recovering = 1;
 		}
-		queue_work(priv->workqueue, &priv->restart);
+		queue_work(priv->hw->workqueue, &priv->restart);
 	}
 }
 
@@ -4750,7 +4750,7 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 		 *   iwl_rx_card_state_notif() */
 		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status)) {
 			clear_bit(STATUS_RF_KILL_HW, &priv->status);
-			queue_work(priv->workqueue, &priv->restart);
+			queue_work(priv->hw->workqueue, &priv->restart);
 		}
 
 		handled |= CSR_INT_BIT_RF_KILL;
@@ -6093,7 +6093,7 @@ static void iwl_init_alive_start(struct iwl_priv *priv)
 	return;
 
  restart:
-	queue_work(priv->workqueue, &priv->restart);
+	queue_work(priv->hw->workqueue, &priv->restart);
 }
 
 
@@ -6213,7 +6213,7 @@ static void iwl_alive_start(struct iwl_priv *priv)
 	return;
 
  restart:
-	queue_work(priv->workqueue, &priv->restart);
+	queue_work(priv->hw->workqueue, &priv->restart);
 }
 
 static void iwl_cancel_deferred_work(struct iwl_priv *priv);
@@ -6451,7 +6451,7 @@ static void iwl_bg_rf_kill(struct work_struct *work)
 			  "HW and/or SW RF Kill no longer active, restarting "
 			  "device\n");
 		if (!test_bit(STATUS_EXIT_PENDING, &priv->status))
-			queue_work(priv->workqueue, &priv->restart);
+			queue_work(priv->hw->workqueue, &priv->restart);
 	} else {
 
 		if (!test_bit(STATUS_RF_KILL_HW, &priv->status))
@@ -6676,7 +6676,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 	if (rc)
 		goto done;
 
-	queue_delayed_work(priv->workqueue, &priv->scan_check,
+	queue_delayed_work(priv->hw->workqueue, &priv->scan_check,
 			   IWL_SCAN_CHECK_WATCHDOG);
 
 	mutex_unlock(&priv->mutex);
@@ -6684,7 +6684,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 
  done:
 	/* inform mac80211 sacn aborted */
-	queue_work(priv->workqueue, &priv->scan_completed);
+	queue_work(priv->hw->workqueue, &priv->scan_completed);
 	mutex_unlock(&priv->mutex);
 }
 
@@ -6708,7 +6708,7 @@ static void iwl_bg_restart(struct work_struct *data)
 		return;
 
 	iwl_down(priv);
-	queue_work(priv->workqueue, &priv->up);
+	queue_work(priv->hw->workqueue, &priv->up);
 }
 
 static void iwl_bg_rx_replenish(struct work_struct *data)
@@ -7593,7 +7593,7 @@ static int iwl_mac_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb,
 	iwl_reset_qos(priv);
 #endif
 
-	queue_work(priv->workqueue, &priv->post_associate.work);
+	queue_work(priv->hw->workqueue, &priv->post_associate.work);
 
 	mutex_unlock(&priv->mutex);
 
@@ -8259,8 +8259,6 @@ static DEVICE_ATTR(dump_events, S_IWUSR, NULL, dump_event_log);
 
 static void iwl_setup_deferred_work(struct iwl_priv *priv)
 {
-	priv->workqueue = create_workqueue(DRV_NAME);
-
 	init_waitqueue_head(&priv->wait_command_queue);
 
 	INIT_WORK(&priv->up, iwl_bg_up);
@@ -8584,8 +8582,6 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
  out_disable_msi:
 	pci_disable_msi(pdev);
-	destroy_workqueue(priv->workqueue);
-	priv->workqueue = NULL;
 	iwl_unset_hw_setting(priv);
 
  out_iounmap:
@@ -8640,15 +8636,6 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 		iwl_rate_control_unregister(priv->hw);
 	}
 
-	/*netif_stop_queue(dev); */
-	flush_workqueue(priv->workqueue);
-
-	/* ieee80211_unregister_hw calls iwl_mac_stop, which flushes
-	 * priv->workqueue... so we can't take down the workqueue
-	 * until now... */
-	destroy_workqueue(priv->workqueue);
-	priv->workqueue = NULL;
-
 	free_irq(pdev->irq, priv);
 	pci_disable_msi(pdev);
 	pci_iounmap(pdev, priv->hw_base);
@@ -8732,7 +8719,7 @@ static void iwl_resume(struct iwl_priv *priv)
 
 	/* Bring the device back up */
 	clear_bit(STATUS_IN_SUSPEND, &priv->status);
-	queue_work(priv->workqueue, &priv->up);
+	queue_work(priv->hw->workqueue, &priv->up);
 }
 
 static int iwl_pci_resume(struct pci_dev *pdev)
-- 
1.5.3.rc5


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
