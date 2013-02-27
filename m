From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8192cu: Fix schedule while atomic bug splat
Date: Wed, 27 Feb 2013 14:10:30 -0600
Message-ID: <512e6836.2JGN8MWwRh2P7FD2%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: John W Linville <linville@tuxdriver.com>, jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:25906 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815Ab3B0UKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:10:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When run at debug 3 or higher, rtl8192cu reports a BUG as follows:

BUG: scheduling while atomic: kworker/u:0/5281/0x00000002
INFO: lockdep is turned off.
Modules linked in: rtl8192cu rtl8192c_common rtlwifi fuse af_packet bnep bluetooth b43 mac80211 cfg80211 ipv6 snd_hda_codec_conexant kvm_amd k
vm snd_hda_intel snd_hda_codec bcma rng_core snd_pcm ssb mmc_core snd_seq snd_timer snd_seq_device snd i2c_nforce2 sr_mod pcmcia forcedeth i2c_core soundcore
 cdrom sg serio_raw k8temp hwmon joydev ac battery pcmcia_core snd_page_alloc video button wmi autofs4 ext4 mbcache jbd2 crc16 thermal processor scsi_dh_alua
 scsi_dh_hp_sw scsi_dh_rdac scsi_dh_emc scsi_dh ata_generic pata_acpi pata_amd [last unloaded: rtlwifi]
Pid: 5281, comm: kworker/u:0 Tainted: G        W    3.8.0-wl+ #119
Call Trace:
 [<ffffffff814531e7>] __schedule_bug+0x62/0x70
 [<ffffffff81459af0>] __schedule+0x730/0xa30
 [<ffffffff81326e49>] ? usb_hcd_link_urb_to_ep+0x19/0xa0
 [<ffffffff8145a0d4>] schedule+0x24/0x70
 [<ffffffff814575ec>] schedule_timeout+0x18c/0x2f0
 [<ffffffff81459ec0>] ? wait_for_common+0x40/0x180
 [<ffffffff8133f461>] ? ehci_urb_enqueue+0xf1/0xee0
 [<ffffffff810a579d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff81459f65>] wait_for_common+0xe5/0x180
 [<ffffffff8107d1c0>] ? try_to_wake_up+0x2d0/0x2d0
 [<ffffffff8145a08e>] wait_for_completion_timeout+0xe/0x10
 [<ffffffff8132ab1c>] usb_start_wait_urb+0x8c/0x100
 [<ffffffff8132adf9>] usb_control_msg+0xd9/0x130
 [<ffffffffa057dd8d>] _usb_read_sync+0xcd/0x140 [rtlwifi]
 [<ffffffffa057de0e>] _usb_read32_sync+0xe/0x10 [rtlwifi]
 [<ffffffffa04b0555>] rtl92cu_update_hal_rate_table+0x1a5/0x1f0 [rtl8192cu]

The cause is a synchronous read from routine rtl92cu_update_hal_rate_table().
The resulting output is not critical, thus the debug statement is
deleted.

Reported-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---

Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -2058,8 +2058,6 @@ void rtl92cu_update_hal_rate_table(struc
 			       (shortgi_rate << 4) | (shortgi_rate);
 	}
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
-		 rtl_read_dword(rtlpriv, REG_ARFR0));
 }
 
 void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
