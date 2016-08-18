From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 2/2] ath10k: use complete() instead complete_all()
Date: Thu, 18 Aug 2016 15:12:06 +0200
Message-ID: <1471525926-20384-3-git-send-email-wagi@monom.org>
References: <1471525926-20384-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
 Daniel Wagner <daniel.wagner@bmw-carit.de>,
 "Luis R . Rodriguez" <mcgrof@kernel.org>,
 Christian Lamparter <chunkeey@googlemail.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <1471525926-20384-1-git-send-email-wagi@monom.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

There is only one waiter for the completion, therefore there
is no need to use complete_all(). Let's make that clear by
using complete() instead of complete_all().

The usage pattern of the completion is:

waiter context                          waker context

scan.started
------------

ath10k_start_scan()
  lockdep_assert_held(conf_mutex)
  auth10k_wmi_start_scan()
  wait_for_completion_timeout(scan.started)

					ath10k_wmi_event_scan_start_failed()
					  complete(scan.started)

					ath10k_wmi_event_scan_started()
					  complete(scan.started)

scan.completed
--------------

ath10k_scan_stop()
  lockdep_assert_held(conf_mutex)
  ath10k_wmi_stop_scan()
  wait_for_completion_timeout(scan.completed)

					__ath10k_scan_finish()
					  complete(scan.completed)

scan.on_channel
---------------

ath10k_remain_on_channel()
  mutex_lock(conf_mutex)
  ath10k_start_scan()
  wait_for_completion_timeout(scan.on_channel)

					ath10k_wmi_event_scan_foreign_chan()
					  complete(scan.on_channel)

offchan_tx_completed
--------------------

ath10k_offchan_tx_work()
  mutex_lock(conf_mutex)
  reinit_completion(offchan_tx_completed)
  wait_for_completion_timeout(offchan_tx_completed)

					ath10k_report_offchain_tx()
					  complete(offchan_tx_completed)

install_key_done
----------------
ath10k_install_key()
  lockep_assert_held(conf_mutex)
  reinit_completion(install_key_done)
  wait_for_completion_timeout(install_key_done)

				        ath10k_htt_t2h_msg_handler()
					  complete(install_key_done)

vdev_setup_done
---------------

ath10k_monitor_vdev_start()
  lockdep_assert_held(conf_mutex)
   reinit_completion(vdev_setup_done)
  ath10k_vdev_setup_sync()
    wait_for_completion_timeout(vdev_setup_done)

					ath10k_wmi_event_vdev_start_resp()
					  complete(vdev_setup_done)

ath10k_monitor_vdev_stop()
  lockdep_assert_held(conf_mutex)
  reinit_completion(vdev_setup_done()
  ath10k_vdev_setup_sync()
    wait_for_completion_timeout(vdev_setup_done)

					ath10k_wmi_event_vdev_stopped()
					 complete(vdev_setup_done)

thermal.wmi_sync
----------------
ath10k_thermal_show_temp()
  mutex_lock(conf_mutex)
  reinit_completion(thermal.wmi_sync)
  wait_for_completion_timeout(thermal.wmi_sync)

					ath10k_thermal_event_temperature()
					  complete(thermal.wmi_sync)

bss_survey_done
---------------
ath10k_mac_update_bss_chan_survey
  lockdep_assert_held(conf_mutex)
  reinit_completion(bss_survey_done)
  wait_for_completion_timeout(bss_survey_done)

					ath10k_wmi_event_pdev_bss_chan_info()
					  complete(bss_survey_done)

All complete() calls happen while the conf_mutex is taken. That means
at max one waiter is possible.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
---
 drivers/net/wireless/ath/ath10k/core.c | 16 ++++++++--------
 drivers/net/wireless/ath/ath10k/mac.c  |  2 +-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index e889829..ed76601 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -1497,14 +1497,14 @@ static void ath10k_core_restart(struct work_struct *work)
 
 	ieee80211_stop_queues(ar->hw);
 	ath10k_drain_tx(ar);
-	complete_all(&ar->scan.started);
-	complete_all(&ar->scan.completed);
-	complete_all(&ar->scan.on_channel);
-	complete_all(&ar->offchan_tx_completed);
-	complete_all(&ar->install_key_done);
-	complete_all(&ar->vdev_setup_done);
-	complete_all(&ar->thermal.wmi_sync);
-	complete_all(&ar->bss_survey_done);
+	complete(&ar->scan.started);
+	complete(&ar->scan.completed);
+	complete(&ar->scan.on_channel);
+	complete(&ar->offchan_tx_completed);
+	complete(&ar->install_key_done);
+	complete(&ar->vdev_setup_done);
+	complete(&ar->thermal.wmi_sync);
+	complete(&ar->bss_survey_done);
 	wake_up(&ar->htt.empty_tx_wq);
 	wake_up(&ar->wmi.tx_credits_wq);
 	wake_up(&ar->peer_mapping_wq);
diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index 0bbd0a0..c3c1c25 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -3894,7 +3894,7 @@ void __ath10k_scan_finish(struct ath10k *ar)
 		ar->scan.roc_freq = 0;
 		ath10k_offchan_tx_purge(ar);
 		cancel_delayed_work(&ar->scan.timeout);
-		complete_all(&ar->scan.completed);
+		complete(&ar->scan.completed);
 		break;
 	}
 }
-- 
2.7.4
