From: Milan Kocian <milon@wq.cz>
Subject: Re: WARNING: at kernel/softirq.c:160 local_bh_enable_ip+0x7a/0xb0()
 (probably iwl4965)
Date: Sun, 5 May 2013 17:11:32 +0200
Message-ID: <20130505151132.GA6034@ntm.wq.cz>
References: <20130501090818.GA5907@ntm.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([80.92.240.241]:59112 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab3EEPLv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 May 2013 11:11:51 -0400
Content-Disposition: inline
In-Reply-To: <20130501090818.GA5907@ntm.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 01, 2013 at 11:08:18AM +0200, Milan Kocian wrote:
> hello,
> 
> after upgrade to the kernel v3.9 I see this nice warning after every reboot.
> 
> ------------[ cut here ]------------
> WARNING: at kernel/softirq.c:160 local_bh_enable_ip+0x7a/0xb0()
> Hardware name: 76693KG
> Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_ondemand cpufreq_conservative ipv6 rfcomm nfnetlink_log nfnetlink bnep deflate zlib_deflate zlib_inflate ctr twofish_x86_64_3way twofish_x86_64 twofish_common camellia_generic camellia_x86_64 serpent_sse2_x86_64 serpent_generic xts lrw gf128mul glue_helper blowfish_generic blowfish_x86_64 blowfish_common cast5_generic cast_common ablk_helper cryptd des_generic xcbc rmd160 sha512_generic sha1_ssse3 sha1_generic hmac crypto_null af_key xfrm_algo sha256_generic md_mod uinput usbhid fuse snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep arc4 btusb snd_pcm_oss snd_mixer_oss snd_pcm i915 thinkpad_acpi snd_page_alloc cfbfillrect cfbimgblt bluetooth crc16 iwl4965 iwlegacy mac80211 snd_seq_dummy acpi_cpufreq snd
 _seq_oss i2c_algo_bit snd_seq_midi cfg80211 firewire_ohci firewire_core crc_itu_t mperf snd_rawmidi cfbcopyarea pcmcia ehci_pci coretemp e1000e iTCO_wdt sdhci_pci drm_kms_helper drm lpc_ich uhci_hcd ehci_hcd snd_seq_midi_event yenta_socket pcmcia_rsrc pcmcia_core sdhci mfd_core mmc_core snd_seq usbcore kvm_intel kvm tpm_tis tpm tpm_bios snd_seq_device snd_timer i2c_i801 i2c_core microcode usb_common snd video rfkill ptp pps_core soundcore
> Pid: 5812, comm: wpa_supplicant Not tainted 3.9.0 #57
> Call Trace:
>  [<ffffffff81036829>] ? warn_slowpath_common+0x79/0xc0
>  [<ffffffff8103d71a>] ? local_bh_enable_ip+0x7a/0xb0
>  [<ffffffffa0329014>] ? il4965_tx_skb+0xc04/0xd50 [iwl4965]
>  [<ffffffffa02ba281>] ? ieee80211_crypto_tkip_encrypt+0x141/0x1d0 [mac80211]
>  [<ffffffff810f63d0>] ? __kmalloc+0x110/0x120
>  [<ffffffffa0329170>] ? il4965_mac_tx+0x10/0x30 [iwl4965]
>  [<ffffffffa02d1948>] ? __ieee80211_tx+0x138/0x370 [mac80211]
>  [<ffffffffa02d3e4e>] ? ieee80211_tx+0xee/0x120 [mac80211]
>  [<ffffffffa02d4f0f>] ? ieee80211_subif_start_xmit+0xb4f/0xd20 [mac80211]
>  [<ffffffff81352f40>] ? __skb_recv_datagram+0x110/0x300
>  [<ffffffff8135c08e>] ? dev_hard_start_xmit+0x21e/0x460
>  [<ffffffff8134fe20>] ? __alloc_skb+0x90/0x2a0
>  [<ffffffff8137653d>] ? sch_direct_xmit+0xed/0x1e0
>  [<ffffffff8135c4b9>] ? dev_queue_xmit+0x1e9/0x460
>  [<ffffffff813ecf1e>] ? packet_sendmsg+0xd7e/0xe60
>  [<ffffffff81343e8b>] ? sock_sendmsg+0x7b/0xb0
>  [<ffffffff813448f3>] ? move_addr_to_user+0x73/0xd0
>  [<ffffffff81346fce>] ? sys_sendto+0xfe/0x150
>  [<ffffffff8111ce25>] ? mntput_no_expire+0x25/0x170
>  [<ffffffff813475b4>] ? sys_recvmsg+0x44/0x80
>  [<ffffffff8140e5d6>] ? system_call_fastpath+0x1a/0x1f
> ---[ end trace 6443164a8c19ebbd ]---
> 
 
I tried to enable some kernel debug options and got little different
warning (see below) where last function is ieee80211_get_tkip_p2k.
So I blindly tried replace bh functions with non-bh variants in 
ieee80211_get_tkip_p2k and warning disappeared.

--- a/net/mac80211/tkip.c.orig	2013-05-05 16:39:42.360541954 +0200
+++ b/net/mac80211/tkip.c	2013-05-05 16:40:51.859673095 +0200
@@ -208,10 +208,10 @@ void ieee80211_get_tkip_p2k(struct ieee8
 	u32 iv32 = get_unaligned_le32(&data[4]);
 	u16 iv16 = data[2] | (data[0] << 8);
 
-	spin_lock_bh(&key->u.tkip.txlock);
+	spin_lock(&key->u.tkip.txlock);
 	ieee80211_compute_tkip_p1k(key, iv32);
 	tkip_mixing_phase2(tk, ctx, iv16, p2k);
-	spin_unlock_bh(&key->u.tkip.txlock);
+	spin_unlock(&key->u.tkip.txlock);
 }
 EXPORT_SYMBOL(ieee80211_get_tkip_p2k);
 

But I am not really sure if it's the right fix. Please review
carefully :-). CCing MAC80211 maintainer and linux-wireless.


------------[ cut here ]------------
WARNING: at kernel/softirq.c:160 local_bh_enable_ip+0x7a/0xb0()
Hardware name: 76693KG
Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_ondemand cpufreq_conservative ipv6 nfnetlink_log bnep nfnetlink rfcomm deflate zlib_deflate zlib_inflate ctr twofish_x86_64_3way twofish_x86_64 twofish_common camellia_generic camellia_x86_64 serpent_sse2_x86_64 serpent_generic xts lrw gf128mul glue_helper blowfish_generic blowfish_x86_64 blowfish_common cast5_generic cast_common ablk_helper cryptd des_generic xcbc rmd160 sha512_generic sha1_ssse3 sha1_generic hmac crypto_null af_key xfrm_algo sha256_generic md_mod uinput usbhid fuse btusb bluetooth crc16 snd_hda_codec_analog acpi_cpufreq mperf coretemp snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss kvm_intel snd_pcm snd_page_alloc snd_seq_dummy snd_seq_oss snd_seq_midi arc4 kvm snd_rawmidi thinkp
 ad_acpi snd_seq_midi_event iwl4965 snd_seq iwlegacy mac80211 cfg80211 firewire_ohci firewire_core sdhci_pci sdhci mmc_core snd_seq_device snd_timer crc_itu_t i915 cfbfillrect cfbimgblt i2c_algo_bit uhci_hcd iTCO_wdt rfkill e1000e snd ehci_pci cfbcopyarea ehci_hcd usbcore pcmcia lpc_ich mfd_core drm_kms_helper drm soundcore usb_common microcode i2c_i801 i2c_core tpm_tis tpm tpm_bios yenta_socket pcmcia_rsrc pcmcia_core ptp pps_core video
Pid: 11995, comm: wpa_supplicant Not tainted 3.9.0milonlockdep #58
Call Trace:
 [<ffffffff81038e3a>] warn_slowpath_common+0x7a/0xc0
 [<ffffffff81038e95>] warn_slowpath_null+0x15/0x20
 [<ffffffff8103fe2a>] local_bh_enable_ip+0x7a/0xb0
 [<ffffffff81420e2a>] _raw_spin_unlock_bh+0x1a/0x20
 [<ffffffffa02d45f9>] ieee80211_get_tkip_p2k+0x89/0xa0 [mac80211]
 [<ffffffffa032406c>] il4965_tx_skb+0xc4c/0xda0 [iwl4965]
 [<ffffffff814210c6>] ? _raw_spin_lock+0x16/0x40
 [<ffffffffa03241d8>] il4965_mac_tx+0x18/0x30 [iwl4965]
 [<ffffffffa02dfedf>] __ieee80211_tx+0x11f/0x330 [mac80211]
 [<ffffffffa02e23eb>] ieee80211_tx+0xdb/0x100 [mac80211]
 [<ffffffffa02e2565>] ieee80211_xmit+0xa5/0x110 [mac80211]
 [<ffffffffa02e34c8>] ieee80211_subif_start_xmit+0xba8/0xd90 [mac80211]
 [<ffffffff8136cd36>] dev_hard_start_xmit+0x226/0x480
 [<ffffffff813606cc>] ? __alloc_skb+0x8c/0x290
 [<ffffffff81387bee>] sch_direct_xmit+0xfe/0x1d0
 [<ffffffff8136d170>] dev_queue_xmit+0x1e0/0x450
 [<ffffffff813ffa7f>] packet_sendmsg+0xdbf/0xe70
 [<ffffffff81354457>] sock_sendmsg+0x87/0xa0
 [<ffffffff81354ed4>] ? move_addr_to_user+0x74/0xd0
 [<ffffffff81357529>] sys_sendto+0x119/0x160
 [<ffffffff81357b24>] ? sys_recvmsg+0x44/0x80
 [<ffffffff81421f16>] system_call_fastpath+0x1a/0x1f
---[ end trace de4a367bdbd768e7 ]---


-- 
Milan Kocian
