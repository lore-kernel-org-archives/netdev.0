From: Laura Abbott <labbott@redhat.com>
Subject: Suspicious RCU from iwlwifi driver
Date: Thu, 10 Dec 2015 15:22:17 -0800
Message-ID: <566A0929.2090706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Intel Linux Wireless <linuxwifi@intel.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Avri Altman <avri.altman@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm currently seeing a suspicous RCU usage warning:

===============================
[ INFO: suspicious RCU usage. ]
  4.4.0-rc4-next-20151210 #23 Not tainted
  -------------------------------
  drivers/net/wireless/intel/iwlwifi/mvm/sta.c:1226 suspicious rcu_dereference_protected() usage!
  
  other info that might help us debug this:
  
  rcu_scheduler_active = 1, debug_locks = 0
  4 locks held by irq/34-iwlwifi/978:
   #0:  (sync_cmd_lockdep_map){++++..}, at: [<ffffffffa073c1f5>] iwl_pcie_irq_handler+0x5/0x1870 [iwlwifi]
   #1:  (&(&rxq->lock)->rlock){+.+...}, at: [<ffffffffa073cafa>] iwl_pcie_irq_handler+0x90a/0x1870 [iwlwifi]
   #2:  (rcu_read_lock){......}, at: [<ffffffffa0827793>] ieee80211_rx_napi+0xc3/0xbd0 [mac80211]
   #3:  (&(&local->rx_path_lock)->rlock){+.....}, at: [<ffffffffa0823fce>] ieee80211_rx_handlers+0x3e/0x2c80 [mac80211]
  
   stack backtrace:
  CPU: 4 PID: 978 Comm: irq/34-iwlwifi Not tainted 4.4.0-rc4-next-20151210 #23
  Hardware name: LENOVO 20BFS0EC00/20BFS0EC00, BIOS GMET62WW (2.10 ) 03/19/2014
   0000000000000000 000000005a05ae61 ffff880407dc3760 ffffffff81434b69
   ffff8804053e3200 ffff880407dc3790 ffffffff81106757 0000000000000000
   ffff880408d8a868 ffff880408d8a868 ffff8804061cc630 ffff880407dc37b0
  Call Trace:
   [<ffffffff81434b69>] dump_stack+0x4b/0x72
   [<ffffffff81106757>] lockdep_rcu_suspicious+0xd7/0x110
   [<ffffffffa090eff8>] iwl_mvm_get_key_sta_id.part.3+0x88/0x90 [iwlmvm]
   [<ffffffffa09116b1>] iwl_mvm_update_tkip_key+0x241/0x280 [iwlmvm]
   [<ffffffffa08fde6c>] iwl_mvm_mac_update_tkip_key+0x1c/0x20 [iwlmvm]
   [<ffffffffa0816e89>] ieee80211_tkip_decrypt_data+0x249/0x5f0 [mac80211]
   [<ffffffff81729177>] ? skb_copy_bits+0x137/0x2f0
   [<ffffffff8172ba55>] ? __pskb_pull_tail+0x85/0x3a0
   [<ffffffffa080010e>] ieee80211_crypto_tkip_decrypt+0xce/0x150 [mac80211]
   [<ffffffffa0824900>] ieee80211_rx_handlers+0x970/0x2c80 [mac80211]
   [<ffffffff8110923a>] ? __lock_acquire+0x4ba/0x1b70
   [<ffffffffa0826df4>] ieee80211_prepare_and_rx_handle+0x1e4/0xac0 [mac80211]
   [<ffffffffa0827a06>] ieee80211_rx_napi+0x336/0xbd0 [mac80211]
   [<ffffffffa0827793>] ? ieee80211_rx_napi+0xc3/0xbd0 [mac80211]
   [<ffffffffa090adcd>] iwl_mvm_rx_rx_mpdu+0x4ad/0x880 [iwlmvm]
   [<ffffffffa090ab02>] ? iwl_mvm_rx_rx_mpdu+0x1e2/0x880 [iwlmvm]
   [<ffffffffa0905076>] iwl_mvm_rx+0x56/0x240 [iwlmvm]
   [<ffffffffa073d17c>] iwl_pcie_irq_handler+0xf8c/0x1870 [iwlwifi]
   [<ffffffff81882934>] ? __schedule+0x414/0xaf0
   [<ffffffff81120310>] irq_thread_fn+0x20/0x50
   [<ffffffff8112058b>] irq_thread+0x16b/0x1f0
   [<ffffffff81882934>] ? __schedule+0x414/0xaf0
   [<ffffffff811202f0>] ? irq_forced_thread_fn+0x70/0x70
   [<ffffffff81120370>] ? wake_threads_waitq+0x30/0x30
   [<ffffffff81120420>] ? irq_thread_dtor+0xb0/0xb0
   [<ffffffff810d3091>] kthread+0x101/0x120
   [<ffffffff81108999>] ? trace_hardirqs_on_caller+0x129/0x1b0
   [<ffffffff810d2f90>] ? kthread_create_on_node+0x250/0x250
   [<ffffffff81889e1f>] ret_from_fork+0x3f/0x70
   [<ffffffff810d2f90>] ? kthread_create_on_node+0x250/0x250

If I revert 9513c5e18a0dc55a1fc9c890715098ba2315830b
(iwlwifi: mvm: Avoid dereferencing sta if it was already flushed)
The warning goes away. Known issue?

Thanks,
Laura
