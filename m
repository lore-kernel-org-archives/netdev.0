From: Alan Stern <stern@rowland.harvard.edu>
Subject: Soft lockup in 3.17-rc7 when using PPP over L2TP over IPSEC
Date: Wed, 1 Oct 2014 21:59:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1410012150160.27089-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, <linux-ppp@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I reliably get the following lockup when trying to set up a VPN tunnel 
using L2TP over IPSEC:

[ 2214.970639] BUG: soft lockup - CPU#1 stuck for 22s! [pppd:9423]
[ 2214.970648] Modules linked in: l2tp_ppp l2tp_netlink l2tp_core pppoe pppox ppp_generic slhc authenc cmac rmd160 crypto_null ip_vti ip_tunnel af_key ah6 ah4 esp6 esp4 xfrm4_mode_beet xfrm4_tunnel tunnel4 xfrm4_mode_tunnel xfrm4_mode_transport xfrm6_mode_transport xfrm6_mode_ro xfrm6_mode_beet xfrm6_mode_tunnel ipcomp ipcomp6 xfrm6_tunnel tunnel6 xfrm_ipcomp salsa20_i586 camellia_generic cast6_generic cast5_generic cast_common deflate cts gcm ccm serpent_sse2_i586 serpent_generic glue_helper blowfish_generic blowfish_common twofish_generic twofish_i586 twofish_common xcbc sha512_generic des_generic geode_aes tpm_rng tpm timeriomem_rng virtio_rng uas usb_storage fuse ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 ip6table_filter xt_conntrack ip6_tables nf_con
 ntrack vfat
[ 2214.970769]  fat snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel arc4 iwldvm snd_hda_controller snd_hda_codec uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common videodev mac80211 snd_hwdep coretemp kvm_intel kvm media snd_seq snd_seq_device iTCO_wdt iTCO_vendor_support snd_pcm snd_timer snd joydev iwlwifi microcode serio_raw cfg80211 asus_laptop lpc_ich atl1c soundcore sparse_keymap rfkill input_polldev acpi_cpufreq binfmt_misc i915 i2c_algo_bit drm_kms_helper drm i2c_core video
[ 2214.970854] CPU: 1 PID: 9423 Comm: pppd Tainted: G        W     3.16.3-200.fc20.i686 #1
[ 2214.970860] Hardware name: ASUSTeK Computer Inc.         UL20A               /UL20A     , BIOS 207     11/02/2009
[ 2214.970866] task: f0706a00 ti: e359c000 task.ti: e359c000
[ 2214.970873] EIP: 0060:[<c0a077b8>] EFLAGS: 00200287 CPU: 1
[ 2214.970885] EIP is at _raw_spin_lock_bh+0x28/0x40
[ 2214.970890] EAX: e5ff02a4 EBX: e5ff02a4 ECX: 00000060 EDX: 0000005f
[ 2214.970895] ESI: e5ff02b0 EDI: e3470d40 EBP: e359dc34 ESP: e359dc34
[ 2214.970900]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[ 2214.970906] CR0: 8005003b CR2: b72eb000 CR3: 25f28000 CR4: 000407d0
[ 2214.970910] Stack:
[ 2214.970914]  e359dc9c f94efe2a f5140000 e359dc50 c045aba6 f5140000 00200286 e359dc78
[ 2214.970929]  c045c553 00000001 f5140000 001f9076 00200286 628a17c6 f075acc0 f075acc0
[ 2214.970942]  00000000 00200246 f4464848 00200246 00200246 e359dc9c e3470d84 f075acc0
[ 2214.970957] Call Trace:
[ 2214.970973]  [<f94efe2a>] ppp_push+0x32a/0x550 [ppp_generic]
[ 2214.970986]  [<c045aba6>] ? internal_add_timer+0x26/0x60
[ 2214.970994]  [<c045c553>] ? mod_timer_pending+0x63/0x130
[ 2214.971005]  [<f94f288d>] ppp_xmit_process+0x3cd/0x5e0 [ppp_generic]
[ 2214.971007]  [<c0914ae1>] ? harmonize_features+0x31/0x1d0
[ 2214.971007]  [<f94f2c78>] ppp_start_xmit+0x108/0x180 [ppp_generic]
[ 2214.971007]  [<c0915024>] dev_hard_start_xmit+0x2c4/0x540
[ 2214.971007]  [<c093244f>] sch_direct_xmit+0x9f/0x170
[ 2214.971007]  [<c091546a>] __dev_queue_xmit+0x1ca/0x430
[ 2214.971007]  [<c094c9b0>] ? ip_fragment+0x930/0x930
[ 2214.971007]  [<c09156df>] dev_queue_xmit+0xf/0x20
[ 2214.971007]  [<c091bacf>] neigh_direct_output+0xf/0x20
[ 2214.971007]  [<c094cb5a>] ip_finish_output+0x1aa/0x850
[ 2214.971007]  [<c094c9b0>] ? ip_fragment+0x930/0x930
[ 2214.971007]  [<c094dbbf>] ip_output+0x8f/0xe0
[ 2214.971007]  [<c094c9b0>] ? ip_fragment+0x930/0x930
[ 2214.971007]  [<c09a4f52>] xfrm_output_resume+0x342/0x3a0
[ 2214.971007]  [<c09a5013>] xfrm_output+0x43/0xf0
[ 2214.971007]  [<c0998f4d>] xfrm4_output_finish+0x3d/0x40
[ 2214.971007]  [<c0998e25>] __xfrm4_output+0x25/0x40
[ 2214.971007]  [<c0998f7f>] xfrm4_output+0x2f/0x70
[ 2214.971007]  [<c0998e00>] ? xfrm4_udp_encap_rcv+0x1b0/0x1b0
[ 2214.971007]  [<c094d2e7>] ip_local_out_sk+0x27/0x30
[ 2214.971007]  [<c094d5f4>] ip_queue_xmit+0x124/0x3f0
[ 2214.971007]  [<c0999f04>] ? xfrm_bundle_ok+0x64/0x170
[ 2214.971007]  [<c099a0ab>] ? xfrm_dst_check+0x1b/0x30
[ 2214.971007]  [<f94fd618>] l2tp_xmit_skb+0x298/0x4b0 [l2tp_core]
[ 2214.971007]  [<f950cd04>] pppol2tp_xmit+0x124/0x1d0 [l2tp_ppp]
[ 2214.971007]  [<f94f2adb>] ppp_channel_push+0x3b/0xb0 [ppp_generic]
[ 2214.971007]  [<f94f2d77>] ppp_write+0x87/0xc8 [ppp_generic]
[ 2214.971007]  [<f94f2cf0>] ? ppp_start_xmit+0x180/0x180 [ppp_generic]
[ 2214.971007]  [<c057723d>] vfs_write+0x9d/0x1d0
[ 2214.971007]  [<c0577951>] SyS_write+0x51/0xb0
[ 2214.971007]  [<c0a07b9f>] sysenter_do_call+0x12/0x12
[ 2214.971007] Code: 00 00 00 55 89 e5 66 66 66 66 90 64 81 05 90 b6 dc c0 00 02 00 00 ba 00 01 00 00 f0 66 0f c1 10 0f b6 ce 38 d1 75 04 5d c3 f3 90 <0f> b6 10 38 ca 75 f7 5d c3 90 90 90 90 90 90 90 90 90 90 90 90
[ 2220.002045] iwlwifi 0000:01:00.0: No space in command queue
[ 2220.002058] iwlwifi 0000:01:00.0: Restarting adapter queue is full
[ 2220.002073] iwlwifi 0000:01:00.0: Error sending REPLY_LEDS_CMD: enqueue_hcmd failed: -28
[ 2220.002524] ieee80211 phy0: Hardware restart was requested

A few seconds after this appears, the second CPU also locks up and the 
system becomes useless.

I don't know if the problem is in the networking core or in the 
wireless driver.  If anyone wants, I can try testing using a wired 
Ethernet connection.

Note: This problem is not new.  It has been happening for at least the
last several kernel versions -- in fact, I don't know if this has ever
worked.

Can this be debugged and fixed?

Alan Stern

