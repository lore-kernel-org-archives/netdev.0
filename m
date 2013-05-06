From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: WARNING: at kernel/softirq.c:160 local_bh_enable_ip+0x7a/0xb0()
 (probably iwl4965)
Date: Mon, 6 May 2013 12:43:08 +0200
Message-ID: <20130506104307.GA2652@redhat.com>
References: <20130501090818.GA5907@ntm.wq.cz>
 <20130505151132.GA6034@ntm.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753787Ab3EFKlo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 06:41:44 -0400
Content-Disposition: inline
In-Reply-To: <20130505151132.GA6034@ntm.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 05, 2013 at 05:11:32PM +0200, Milan Kocian wrote:
> On Wed, May 01, 2013 at 11:08:18AM +0200, Milan Kocian wrote:
> > hello,
> > 
> > after upgrade to the kernel v3.9 I see this nice warning after every reboot.
> > 
> > ------------[ cut here ]------------
> > WARNING: at kernel/softirq.c:160 local_bh_enable_ip+0x7a/0xb0()
> > Hardware name: 76693KG
> > Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_ondemand cpufreq_conservative ipv6 rfcomm nfnetlink_log nfnetlink bnep deflate zlib_deflate zlib_inflate ctr twofish_x86_64_3way twofish_x86_64 twofish_common camellia_generic camellia_x86_64 serpent_sse2_x86_64 serpent_generic xts lrw gf128mul glue_helper blowfish_generic blowfish_x86_64 blowfish_common cast5_generic cast_common ablk_helper cryptd des_generic xcbc rmd160 sha512_generic sha1_ssse3 sha1_generic hmac crypto_null af_key xfrm_algo sha256_generic md_mod uinput usbhid fuse snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep arc4 btusb snd_pcm_oss snd_mixer_oss snd_pcm i915 thinkpad_acpi snd_page_alloc cfbfillrect cfbimgblt bluetooth crc16 iwl4965 iwlegacy mac80211 snd_seq_dummy acpi_cpufreq s
 nd_seq_oss i2c_algo_bit snd_seq_midi cfg80211 firewire_ohci firewire_core crc_itu_t mperf snd_rawmidi cfbcopyarea pcmcia ehci_pci coretemp e1000e iTCO_wdt sdhci_pci drm_kms_helper drm lpc_ich!
>   uhci_hcd ehci_hcd snd_seq_midi_event yenta_socket pcmcia_rsrc pcmcia_core sdhci mfd_core mmc_core snd_seq usbcore kvm_intel kvm tpm_tis tpm tpm_bios snd_seq_device snd_timer i2c_i801 i2c_core microcode usb_common snd video rfkill ptp pps_core soundcore
> > Pid: 5812, comm: wpa_supplicant Not tainted 3.9.0 #57
> > Call Trace:
> >  [<ffffffff81036829>] ? warn_slowpath_common+0x79/0xc0
> >  [<ffffffff8103d71a>] ? local_bh_enable_ip+0x7a/0xb0
> >  [<ffffffffa0329014>] ? il4965_tx_skb+0xc04/0xd50 [iwl4965]
> >  [<ffffffffa02ba281>] ? ieee80211_crypto_tkip_encrypt+0x141/0x1d0 [mac80211]
> >  [<ffffffff810f63d0>] ? __kmalloc+0x110/0x120
> >  [<ffffffffa0329170>] ? il4965_mac_tx+0x10/0x30 [iwl4965]
> >  [<ffffffffa02d1948>] ? __ieee80211_tx+0x138/0x370 [mac80211]
> >  [<ffffffffa02d3e4e>] ? ieee80211_tx+0xee/0x120 [mac80211]
> >  [<ffffffffa02d4f0f>] ? ieee80211_subif_start_xmit+0xb4f/0xd20 [mac80211]
> >  [<ffffffff81352f40>] ? __skb_recv_datagram+0x110/0x300
> >  [<ffffffff8135c08e>] ? dev_hard_start_xmit+0x21e/0x460
> >  [<ffffffff8134fe20>] ? __alloc_skb+0x90/0x2a0
> >  [<ffffffff8137653d>] ? sch_direct_xmit+0xed/0x1e0
> >  [<ffffffff8135c4b9>] ? dev_queue_xmit+0x1e9/0x460
> >  [<ffffffff813ecf1e>] ? packet_sendmsg+0xd7e/0xe60
> >  [<ffffffff81343e8b>] ? sock_sendmsg+0x7b/0xb0
> >  [<ffffffff813448f3>] ? move_addr_to_user+0x73/0xd0
> >  [<ffffffff81346fce>] ? sys_sendto+0xfe/0x150
> >  [<ffffffff8111ce25>] ? mntput_no_expire+0x25/0x170
> >  [<ffffffff813475b4>] ? sys_recvmsg+0x44/0x80
> >  [<ffffffff8140e5d6>] ? system_call_fastpath+0x1a/0x1f
> > ---[ end trace 6443164a8c19ebbd ]---
> > 

iwl4965_tx_skb disables interrupts hence this warnings when enabling bh.

> I tried to enable some kernel debug options and got little different
> warning (see below) where last function is ieee80211_get_tkip_p2k.
> So I blindly tried replace bh functions with non-bh variants in 
> ieee80211_get_tkip_p2k and warning disappeared.
> 
> --- a/net/mac80211/tkip.c.orig	2013-05-05 16:39:42.360541954 +0200
> +++ b/net/mac80211/tkip.c	2013-05-05 16:40:51.859673095 +0200
> @@ -208,10 +208,10 @@ void ieee80211_get_tkip_p2k(struct ieee8
>  	u32 iv32 = get_unaligned_le32(&data[4]);
>  	u16 iv16 = data[2] | (data[0] << 8);
>  
> -	spin_lock_bh(&key->u.tkip.txlock);
> +	spin_lock(&key->u.tkip.txlock);
>  	ieee80211_compute_tkip_p1k(key, iv32);
>  	tkip_mixing_phase2(tk, ctx, iv16, p2k);
> -	spin_unlock_bh(&key->u.tkip.txlock);
> +	spin_unlock(&key->u.tkip.txlock);
>  }
>  EXPORT_SYMBOL(ieee80211_get_tkip_p2k);
>  
> 
> But I am not really sure if it's the right fix. Please review
> carefully :-). CCing MAC80211 maintainer and linux-wireless.

ieee80211_get_tkip_p2k is allways called with bh disabled, so this
fix if fine.

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
