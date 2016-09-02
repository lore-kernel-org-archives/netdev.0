From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [2/2] ath10k: use complete() instead complete_all()
Date: Fri, 2 Sep 2016 17:55:20 +0200
Message-ID: <cf7ac1577bed46af9e664cb1134c6643@euamsexm01a.eu.qualcomm.com>
References: <1471525926-20384-3-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, <netdev@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ath10k@lists.infradead.org>,
        Daniel Wagner <daniel.wagner@bmw-carit.de>,
        "Luis R . Rodriguez" <mcgrof@kernel.org>,
        Christian Lamparter <chunkeey@googlemail.com>
To: Daniel Wagner <wagi@monom.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471525926-20384-3-git-send-email-wagi@monom.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Wagner <wagi@monom.org> wrote:
> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
> 
> There is only one waiter for the completion, therefore there
> is no need to use complete_all(). Let's make that clear by
> using complete() instead of complete_all().
> 
> The usage pattern of the completion is:
> 
> waiter context                          waker context
> 
> scan.started
> ------------
> 
> ath10k_start_scan()
>   lockdep_assert_held(conf_mutex)
>   auth10k_wmi_start_scan()
>   wait_for_completion_timeout(scan.started)
> 
> 					ath10k_wmi_event_scan_start_failed()
> 					  complete(scan.started)
> 
> 					ath10k_wmi_event_scan_started()
> 					  complete(scan.started)
> 
> scan.completed
> --------------
> 
> ath10k_scan_stop()
>   lockdep_assert_held(conf_mutex)
>   ath10k_wmi_stop_scan()
>   wait_for_completion_timeout(scan.completed)
> 
> 					__ath10k_scan_finish()
> 					  complete(scan.completed)
> 
> scan.on_channel
> ---------------
> 
> ath10k_remain_on_channel()
>   mutex_lock(conf_mutex)
>   ath10k_start_scan()
>   wait_for_completion_timeout(scan.on_channel)
> 
> 					ath10k_wmi_event_scan_foreign_chan()
> 					  complete(scan.on_channel)
> 
> offchan_tx_completed
> --------------------
> 
> ath10k_offchan_tx_work()
>   mutex_lock(conf_mutex)
>   reinit_completion(offchan_tx_completed)
>   wait_for_completion_timeout(offchan_tx_completed)
> 
> 					ath10k_report_offchain_tx()
> 					  complete(offchan_tx_completed)
> 
> install_key_done
> ----------------
> ath10k_install_key()
>   lockep_assert_held(conf_mutex)
>   reinit_completion(install_key_done)
>   wait_for_completion_timeout(install_key_done)
> 
> 				        ath10k_htt_t2h_msg_handler()
> 					  complete(install_key_done)
> 
> vdev_setup_done
> ---------------
> 
> ath10k_monitor_vdev_start()
>   lockdep_assert_held(conf_mutex)
>    reinit_completion(vdev_setup_done)
>   ath10k_vdev_setup_sync()
>     wait_for_completion_timeout(vdev_setup_done)
> 
> 					ath10k_wmi_event_vdev_start_resp()
> 					  complete(vdev_setup_done)
> 
> ath10k_monitor_vdev_stop()
>   lockdep_assert_held(conf_mutex)
>   reinit_completion(vdev_setup_done()
>   ath10k_vdev_setup_sync()
>     wait_for_completion_timeout(vdev_setup_done)
> 
> 					ath10k_wmi_event_vdev_stopped()
> 					 complete(vdev_setup_done)
> 
> thermal.wmi_sync
> ----------------
> ath10k_thermal_show_temp()
>   mutex_lock(conf_mutex)
>   reinit_completion(thermal.wmi_sync)
>   wait_for_completion_timeout(thermal.wmi_sync)
> 
> 					ath10k_thermal_event_temperature()
> 					  complete(thermal.wmi_sync)
> 
> bss_survey_done
> ---------------
> ath10k_mac_update_bss_chan_survey
>   lockdep_assert_held(conf_mutex)
>   reinit_completion(bss_survey_done)
>   wait_for_completion_timeout(bss_survey_done)
> 
> 					ath10k_wmi_event_pdev_bss_chan_info()
> 					  complete(bss_survey_done)
> 
> All complete() calls happen while the conf_mutex is taken. That means
> at max one waiter is possible.
> 
> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>

Thanks, 1 patch applied to ath-next branch of ath.git:

881ed54ecc13 ath10k: use complete() instead complete_all()

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9287731/
