From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: freeing an active object
Date: Mon, 30 Nov 2015 00:23:16 +0100
Message-ID: <1448839396.2891.14.camel@tiscali.nl>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
	 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
	 <1448828800.2603.17.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Tilman Schmidt <tilman@imap.cc>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud6.xs4all.net ([194.109.24.31]:48078 "EHLO
	lb3-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751430AbbK2XXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 18:23:21 -0500
In-Reply-To: <1448828800.2603.17.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On zo, 2015-11-29 at 21:26 +0100, Paul Bolle wrote:
> If the above is correct it would be nice to know the .config of the
> kernel used by syzkaller.
> 
> Anyhow, without further details of the chain of events that triggered
> this warning, I'm afraid it will be hard to determine which struct
> timer_list is at the root of all this. (Ie, there's probably quite a 
> bit of code to wade through in order to determine that.)

I've been able to reproduce this on 4.3 with both
CONFIG_DEBUG_OBJECTS_TIMERS and CONFIG_DEBUG_KOBJECT_RELEASE set. (I
have not tested yet whether just CONFIG_DEBUG_OBJECTS_TIMERS is enough.)

The WARNING is triggered by doing just:
    ldattach GIGASET_M101 /dev/ttyS0
    killall ldattach
    modprobe -r ser_gigaset

(I haven't checked whether "modprobe -r ser_gigaset" is even needed, bit
I doubt that.) 

Relevant part of dmesg attached at the end of this message. This should
give me (and Tilman too?) an entry to get to bottom of this. Since this
is relevant for anyone with just the ser-gigaset module installed, I
hope to do that soon.

Thanks, again, for the report Sacha!


Paul Bolle

<6>[  167.257866] gigaset: Driver for Gigaset 307x
<6>[  167.257870] gigaset: Kernel CAPI interface
<6>[  167.260966] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
<5>[  167.260979] kcapi: controller [001]: ser_gigaset attached
<5>[  167.261627] kcapi: controller [001] "ser_gigaset" ready.
<5>[  170.953077] kcapi: controller [001] down.
<6>[  170.953339] kobject: 'ttyGS0' (ffff8803ee191410): kobject_release, parent           (null) (delayed 2000)
<6>[  170.953347] kobject: '(null)' (ffff8803ee393500): kobject_release, parent           (null) (delayed 3000)
<6>[  170.953398] kobject: 'ser_gigaset.0' (ffff8803ee195420): kobject_release, parent           (null) (delayed 4000)
<4>[  170.953402] ------------[ cut here ]------------
<4>[  170.953410] WARNING: CPU: 2 PID: 2711 at lib/debugobjects.c:263 debug_print_object+0x87/0xb0()
<3>[  170.953416] ODEBUG: free active (active state 0) object type: timer_list hint: delayed_work_timer_fn+0x0/0x20
<5>[  170.953419] Modules linked in: ser_gigaset gigaset kernelcapi crc_ccitt fuse ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw bnep iTCO_wdt iTCO_vendor_support intel_rapl iosf_mbi x86_pkg_temp_thermal coretemp uvcvideo kvm_intel snd_hda_codec_hdmi kvm videobuf2_vmalloc snd_hda_codec_conexant snd_hda_codec_generic arc4 iwldvm videobuf2_core btusb btrtl snd_hda_intel mac80211 btbcm crct10dif_pclmul crc32_pclmul crc32c_intel btintel videobuf2_memops snd_hda_codec bluetooth v4l
 2_common videodev
<5>[  170.953480]  media snd_hda_core iwlwifi snd_hwdep snd_seq snd_seq_device cfg80211 pcspkr i2c_i801 snd_pcm thinkpad_acpi wmi tpm_tis snd_timer snd rfkill tpm mei_me mei soundcore lpc_ich shpchp 8021q garp stp llc mrp i915 i2c_algo_bit drm_kms_helper drm e1000e serio_raw sdhci_pci sdhci mmc_core ptp pps_core video
<5>[  170.953519] CPU: 2 PID: 2711 Comm: ldattach Tainted: G        W       4.3.0-1.local2.fc22.x86_64 #1
<5>[  170.953522] Hardware name: LENOVO 4291V7X/4291V7X, BIOS 8DET69WW (1.39 ) 07/18/2013
<5>[  170.953525]  0000000000000000 00000000de7b6fd7 ffff8803e596f918 ffffffff8139cd6f
<5>[  170.953530]  ffff8803e596f960 ffff8803e596f950 ffffffff8109ef52 ffff880408e22d20
<5>[  170.953535]  ffffffff81c54780 ffffffff81a661b4 ffff8803e596fa30 0000000000000001
<5>[  170.953540] Call Trace:
<5>[  170.953548]  [<ffffffff8139cd6f>] dump_stack+0x44/0x55
<5>[  170.953554]  [<ffffffff8109ef52>] warn_slowpath_common+0x82/0xc0
<5>[  170.953558]  [<ffffffff8109efec>] warn_slowpath_fmt+0x5c/0x80
<5>[  170.953563]  [<ffffffff813ba0c7>] debug_print_object+0x87/0xb0
<5>[  170.953568]  [<ffffffff810b6260>] ? __queue_work+0x330/0x330
<5>[  170.953573]  [<ffffffff813bb0e6>] debug_check_no_obj_freed+0x1e6/0x250
<5>[  170.953581]  [<ffffffffa08172b8>] ? gigaset_freecshw+0x48/0x60 [ser_gigaset]
<5>[  170.953587]  [<ffffffff811ff95c>] kfree+0x10c/0x160
<5>[  170.953591]  [<ffffffffa08172b8>] gigaset_freecshw+0x48/0x60 [ser_gigaset]
<5>[  170.953598]  [<ffffffffa07fd2d8>] gigaset_freecs+0xc8/0x1d0 [gigaset]
<5>[  170.953603]  [<ffffffffa0817795>] gigaset_tty_close+0x75/0x90 [ser_gigaset]
<5>[  170.953611]  [<ffffffff8147fb78>] tty_ldisc_close.isra.1+0x38/0x50
<5>[  170.953615]  [<ffffffff8147fca8>] tty_ldisc_kill+0x18/0x90
<5>[  170.953620]  [<ffffffff814805d4>] tty_ldisc_release+0x124/0x1a0
<5>[  170.953624]  [<ffffffff81479473>] tty_release+0x3b3/0x560
<5>[  170.953632]  [<ffffffff8122036c>] __fput+0xdc/0x1e0
<5>[  170.953637]  [<ffffffff812204ae>] ____fput+0xe/0x10
<5>[  170.953641]  [<ffffffff810bb213>] task_work_run+0x73/0x90
<5>[  170.953646]  [<ffffffff810a1bb1>] do_exit+0x391/0xae0
<5>[  170.953650]  [<ffffffff810a2387>] do_group_exit+0x47/0xb0
<5>[  170.953656]  [<ffffffff810ad6c4>] get_signal+0x274/0x600
<5>[  170.953665]  [<ffffffff81015287>] do_signal+0x37/0x6b0
<5>[  170.953670]  [<ffffffff810d3108>] ? dequeue_entity+0x3b8/0xa80
<5>[  170.953676]  [<ffffffff810d6034>] ? set_next_entity+0xa4/0x880
<5>[  170.953680]  [<ffffffff810146f1>] ? __switch_to+0x261/0x4b0
<5>[  170.953686]  [<ffffffff81003b8d>] prepare_exit_to_usermode+0xbd/0x110
<5>[  170.953690]  [<ffffffff81003c35>] syscall_return_slowpath+0x55/0x150
<5>[  170.953697]  [<ffffffff817773cc>] int_ret_from_sys_call+0x25/0x8f
<4>[  170.953701] ---[ end trace c70f8fb2d5e06c74 ]---
<5>[  170.953709] kcapi: controller [001]: ser_gigaset unregistered
<6>[  174.461524] kobject: 'ser_gigaset' (ffff8803eadfac00): kobject_release, parent ffff88040b427818 (delayed 4000)
<6>[  174.461628] kobject: 'drivers' (ffff8803ee393700): kobject_release, parent ffffffffa08191d0 (delayed 1000)
<6>[  174.461632] kobject: 'holders' (ffff8803ee392700): kobject_release, parent ffffffffa08191d0 (delayed 3000)
<6>[  174.461637] kobject: 'notes' (ffff8803ee393400): kobject_release, parent ffffffffa08191d0 (delayed 2000)
<6>[  177.460222] kobject: 'ser_gigaset' (ffffffffa08191d0): kobject_release, parent ffff88040b4f5a18 (delayed 1000)
<6>[  178.472578] kobject: 'holders' (ffff8803d7653500): kobject_release, parent ffffffffa080c950 (delayed 2000)
<6>[  178.472595] kobject: 'notes' (ffff8803d7652600): kobject_release, parent ffffffffa080c950 (delayed 3000)
<6>[  181.470840] kobject: 'gigaset' (ffffffffa080c950): kobject_release, parent ffff88040b4f5a18 (delayed 2000)
<6>[  183.474016] kobject: 'holders' (ffff8800d4341e00): kobject_release, parent ffffffffa07eb050 (delayed 4000)
<6>[  183.474034] kobject: 'notes' (ffff8800d4340c00): kobject_release, parent ffffffffa07eb050 (delayed 3000)
<6>[  187.472010] kobject: 'crc_ccitt' (ffffffffa07eb050): kobject_release, parent ffff88040b4f5a18 (delayed 2000)
<6>[  189.477972] kobject: 'holders' (ffff8803e5ae7900): kobject_release, parent ffffffffa07f41d0 (delayed 1000)
<6>[  189.477989] kobject: 'notes' (ffff8803ee3a4a00): kobject_release, parent ffffffffa07f41d0 (delayed 2000)
<6>[  191.476701] kobject: 'kernelcapi' (ffffffffa07f41d0): kobject_release, parent ffff88040b4f5a18 (delayed 3000)
