From: Jiri Slaby <jslaby@suse.cz>
Subject: [UBSAN] iwlmvm's iwl_mvm_enable_txq accesses IEEE80211_INVAL_HW_QUEUE
Date: Fri, 23 Jun 2017 09:48:22 +0200
Message-ID: <3f089134-9739-a61f-80e4-6f9ee7dd83b4@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
To: Johannes Berg <johannes.berg@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        luciano.coelho@intel.com, linuxwifi@intel.com,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

we have got an UBSAN report from opensuse's user who booten
UBSAN-enabled kernel by mistake:
UBSAN: Undefined behaviour in
drivers/net/wireless/intel/iwlwifi/mvm/utils.c:667:49
shift exponent 255 is too large for 64-bit type 'long unsigned int'
CPU: 2 PID: 1590 Comm: wpa_supplicant Not tainted 4.11.2-1-syzkaller #1
Hardware name: Dell Inc. Precision 5510/0N8J4R, BIOS 01.02.00 04/07/2016
Call Trace:
...
 iwl_mvm_enable_txq+0xc6d/0x1080 [iwlmvm]
 iwl_mvm_send_add_bcast_sta+0x275/0x850 [iwlmvm]
 iwl_mvm_add_bcast_sta+0x11b/0x280 [iwlmvm]
 iwl_mvm_mac_add_interface+0x51f/0x8b0 [iwlmvm]
 drv_add_interface+0x1a7/0x8c0 [mac80211]
 ieee80211_do_open+0xdff/0x2790 [mac80211]
 ieee80211_start_p2p_device+0xac/0xf0 [mac80211]
 nl80211_start_p2p_device+0x25d/0xab0 [cfg80211]
 genl_family_rcv_msg+0x835/0xf10
 genl_rcv_msg+0xd0/0x1c0
 netlink_rcv_skb+0x226/0x310
 genl_rcv+0x2d/0x40
 netlink_unicast+0x631/0x9d0
 netlink_sendmsg+0xa2e/0xf60
 sock_sendmsg+0xf7/0x180
 ___sys_sendmsg+0x777/0xa60
 __sys_sendmsg+0xd6/0x170
 SyS_sendmsg+0x32/0x50
 entry_SYSCALL_64_fastpath+0x23/0xc6



mac80211_queue is 255 which is IEEE80211_INVAL_HW_QUEUE, so it should
not be worked with at all.


The invalid queue is hopefully handled in ieee80211_check_queues after
drv_add_interface in ieee80211_do_open:

res = drv_add_interface(local, sdata);
if (res)
        goto err_stop;
res = ieee80211_check_queues(sdata,
        ieee80211_vif_type_p2p(&sdata->vif));


But the mvm driver still should not blindly shift 1 by 255 in
iwl_mvm_enable_txq. Should the check for the invalid queue be before
adding the interface in mac80211? Or should drivers check it in their
add_interface?

thanks,
-- 
js
suse labs
