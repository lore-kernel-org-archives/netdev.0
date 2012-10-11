From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: removing the timer from cdc-ncm
Date: Thu, 11 Oct 2012 12:17:14 +0200
Message-ID: <87zk3te2j9.fsf@nemi.mork.no>
References: <6020948.EvS2esPpc0@linux-lqwf.site>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A8BED59B5@EXDCVYMBSTM006.EQ1STM.local>
	<9022066.PsM0uBqIB8@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9022066.PsM0uBqIB8-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org> (Oliver Neukum's message of
	"Wed, 26 Sep 2012 10:57:12 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:
> On Tuesday 25 September 2012 13:18:10 Alexey ORISHKO wrote:
>
>> Linux host got panic right after data path has been established
>> (i.e. connected to mobile network). 
>
> Thank you. Worse than I hoped, but not unexpected. I'll stare at the
> code a bit.

I had the same experience, but thought I was going to look a bit more at
it before sending anything and forgot all about it.  So this time I am
just sending you my preliminary results instead of waiting.

I am running with your initial patch, Alexeys suggested cleanup, and
some additional debug printks.  The driver receives a few ARPs from the
device, but crashes on the very first outgoing dhcp packet (which is
dumped with a ">>" prefix from cdc_ncm_tx_bundle just before calling
cdc_ncm_fill_tx_frame):

[48880.037638] cdc_ncm: wwan0: network connection: connected
[48880.044038] IPv6: ADDRCONF(NETDEV_CHANGE): wwan0: link becomes ready
[48880.048351] >> 00000000: ff ff ff ff ff ff 02 80 37 ec 02 00 08 00 45 10  ........7.....E.
[48880.048361] >> 00000010: 01 48 00 00 00 00 80 11 39 96 00 00 00 00 ff ff  .H......9.......
[48880.048365] >> 00000020: ff ff 00 44 00 43 01 34 9e fd 01 01 06 00 9e 31  ...D.C.4.......1
[48880.048370] >> 00000030: 64 26 00 00 00 00 00 00 00 00 00 00 00 00 00 00  d&..............
[48880.048374] >> 00000040: 00 00 00 00 00 00 02 80 37 ec 02 00 00 00 00 00  ........7.......
[48880.048378] >> 00000050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048382] >> 00000060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048386] >> 00000070: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048390] >> 00000080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048395] >> 00000090: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048398] >> 000000a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048406] >> 000000b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048411] >> 000000c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048414] >> 000000d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048418] >> 000000e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048422] >> 000000f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048427] >> 00000100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048431] >> 00000110: 00 00 00 00 00 00 63 82 53 63 35 01 01 37 07 01  ......c.Sc5..7..
[48880.048435] >> 00000120: 1c 02 03 0f 06 0c ff 00 00 00 00 00 00 00 00 00  ................
[48880.048439] >> 00000130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048444] >> 00000140: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[48880.048448] >> 00000150: 00 00 00 00 00 00                                ......
[48880.048453] cdc_ncm_fill_tx_frame: ctx=ffff880162c97600, skb=ffff88018237bac0
[48880.048494] BUG: unable to handle kernel NULL pointer dereference at 0000000000000068
[48880.048573] IP: [<ffffffffa06ba879>] cdc_ncm_tx_bundle+0x168/0x43b [cdc_ncm]
[48880.048638] PGD 0 
[48880.048663] Oops: 0000 [#1] SMP 
[48880.048702] Modules linked in: cdc_wdm cdc_ncm(O) netconsole configfs usbnet(O) mii cdc_acm usbhid hid option usb_storage uas nfsv3 nfsv4 auth_rpcgss udf crc_itu_t xt_multiport iptable_filter ip_tables cpufreq_userspace cpufreq_stats cpufreq_conservative cpufreq_powersave rfcomm bnep xt_hl binfmt_misc ip6table_filter ip6_tables x_tables fuse nfsd nfs_acl nfs lockd fscache sunrpc 8021q garp stp llc tun ext2 loop snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss iTCO_wdt snd_pcm iTCO_vendor_support thinkpad_acpi nvram snd_page_alloc snd_seq_midi snd_seq_midi_event snd_rawmidi arc4 iwldvm mac80211 snd_seq snd_timer snd_seq_device qcserial usb_wwan coretemp kvm_intel usbserial uvcvideo videobuf2_vmalloc btusb kvm videobuf2_memops videobuf2_core bluetooth
  psmouse i2c_i801 serio_raw videodev evdev crc16 lpc_ich acpi_cpufreq mfd_core ac battery snd iwlwifi mperf wmi i915 cfg80211 rfkill video processor button drm_kms_helper drm soundcore mei i2c_algo_bit i2c_core ext3 mbcache jbd sha256_generic ablk_helper cryptd aes_x86_64 aes_generic cbc dm_crypt dm_mod nbd sg sd_mod sr_mod crc_t10dif cdrom microcode thermal thermal_sys uhci_hcd ahci ehci_hcd libahci libata e1000e scsi_mod usbcore usb_common [last unloaded: cdc_ncm]
[48880.050129] CPU 1 
[48880.050151] Pid: 5467, comm: dhclient Tainted: G        W  O 3.6.0 #36 LENOVO 2776LEG/2776LEG
[48880.050218] RIP: 0010:[<ffffffffa06ba879>]  [<ffffffffa06ba879>] cdc_ncm_tx_bundle+0x168/0x43b [cdc_ncm]
[48880.050297] RSP: 0018:ffff880232189ab8  EFLAGS: 00010287
[48880.050340] RAX: 0000000000000000 RBX: ffff880162c97600 RCX: 00000000ffffffff
[48880.050395] RDX: 0000000000000800 RSI: ffff8802310bac00 RDI: 0000000000000246
[48880.050448] RBP: ffff880230a0e8c0 R08: 0000000000001100 R09: 000000015eb6d202
[48880.050502] R10: 00000000ffffffff R11: ffff880230a0e8c0 R12: 0000000000000000
[48880.050556] R13: 0000000000000001 R14: 0000000000000212 R15: 00000000000001e8
[48880.050610] FS:  00007fb27436d700(0000) GS:ffff88023bc80000(0000) knlGS:0000000000000000
[48880.050673] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[48880.050717] CR2: 0000000000000068 CR3: 0000000226196000 CR4: 00000000000007e0
[48880.050771] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[48880.050827] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[48880.050882] Process dhclient (pid: 5467, threadinfo ffff880232188000, task ffff88020f4f0810)
[48880.050945] Stack:
[48880.050964]  0000000000000156 0000000000000001 0000000000000000 ffffffff812a8b00
[48880.051039]  ffff8801b2b70980 0000000000000000 0000000000000000 0000000000004000
[48880.051114]  0000000000000001 ffff88016f63f000 ffff88018237bac0 ffffffffa03ac5fc
[48880.051193] Call Trace:
[48880.051221]  [<ffffffff812a8b00>] ? build_skb+0x7b/0xa9
[48880.051266]  [<ffffffffa03ac5fc>] ? usbnet_start_xmit+0x99/0x4e9 [usbnet]
[48880.051321]  [<ffffffff812b50b1>] ? dev_hard_start_xmit+0x3db/0x533
[48880.051373]  [<ffffffff812c9d5a>] ? sch_direct_xmit+0x64/0x13a
[48880.051426]  [<ffffffff812b5521>] ? dev_queue_xmit+0x318/0x4eb
[48880.051477]  [<ffffffff81347a8a>] ? packet_sendmsg_spkt+0x268/0x297
[48880.051528]  [<ffffffff812a0644>] ? sock_sendmsg+0x53/0x6b
[48880.051576]  [<ffffffff8124bb5d>] ? pty_write+0x48/0x53
[48880.051619]  [<ffffffff8129f9f6>] ? copy_from_user+0x18/0x30
[48880.051669]  [<ffffffff8129fa46>] ? move_addr_to_kernel+0x2a/0x65
[48880.051718]  [<ffffffff812a0b6a>] ? sys_sendto+0xf7/0x137
[48880.051765]  [<ffffffff8110b27b>] ? vfs_write+0xc9/0xff
[48880.051810]  [<ffffffff8136f779>] ? system_call_fastpath+0x16/0x1b
[48880.051859] Code: 44 89 f1 31 c0 48 89 d7 f3 aa c7 83 58 01 00 00 00 00 00 00 45 31 ed e9 d9 00 00 00 8b 93 68 01 00 00 41 39 d6 0f 83 e2 00 00 00 <41> 8b 4c 24 68 44 29 f2 39 d1 76 28 66 45 85 ed 0f 85 cc 00 00 
[48880.052010] RIP  [<ffffffffa06ba879>] cdc_ncm_tx_bundle+0x168/0x43b [cdc_ncm]
[48880.052010]  RSP <ffff880232189ab8>
[48880.052010] CR2: 0000000000000068
[48880.079274] ---[ end trace 993ca2b17e744958 ]---
[48880.079284] Kernel panic - not syncing: Fatal exception in interrupt
[48880.079340] panic occurred, switching back to text console
[48880.079405] ------------[ cut here ]------------
[48880.079479] WARNING: at drivers/gpu/drm/i915/intel_display.c:1225 intel_crtc_disable+0x52/0x86 [i915]()
[48880.079549] Hardware name: 2776LEG
[48880.079578] pipe B assertion failure (expected off, current on)
[48880.080007] Modules linked in: cdc_wdm cdc_ncm(O) netconsole configfs usbnet(O) mii cdc_acm usbhid hid option usb_storage uas nfsv3 nfsv4 auth_rpcgss udf crc_itu_t xt_multiport iptable_filter ip_tables cpufreq_userspace cpufreq_stats cpufreq_conservative cpufreq_powersave rfcomm bnep xt_hl binfmt_misc ip6table_filter ip6_tables x_tables fuse nfsd nfs_acl nfs lockd fscache sunrpc 8021q garp stp llc tun ext2 loop snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss iTCO_wdt snd_pcm iTCO_vendor_support thinkpad_acpi nvram snd_page_alloc snd_seq_midi snd_seq_midi_event snd_rawmidi arc4 iwldvm mac80211 snd_seq snd_timer snd_seq_device qcserial usb_wwan coretemp kvm_intel usbserial uvcvideo videobuf2_vmalloc btusb kvm videobuf2_memops videobuf2_core bluetooth
  psmouse i2c_i801 serio_raw videodev evdev crc16 lpc_ich acpi_cpufreq mfd_core ac battery snd iwlwifi mperf wmi i915 cfg80211 rfkill video processor button drm_kms_helper drm soundcore mei i2c_algo_bit i2c_core ext3 mbcache jbd sha256_generic ablk_helper cryptd aes_x86_64 aes_generic cbc dm_crypt dm_mod nbd sg sd_mod sr_mod crc_t10dif cdrom microcode thermal thermal_sys uhci_hcd ahci ehci_hcd libahci libata e1000e scsi_mod usbcore usb_common [last unloaded: cdc_ncm]
[48880.080007] Pid: 5467, comm: dhclient Tainted: G      D W  O 3.6.0 #36
[48880.080007] Call Trace:
[48880.080007]  [<ffffffff8103e0ed>] ? warn_slowpath_common+0x78/0x8c
[48880.080007]  [<ffffffff8103e19f>] ? warn_slowpath_fmt+0x45/0x4a
[48880.080007]  [<ffffffffa02b5ce1>] ? intel_crtc_disable+0x52/0x86 [i915]
[48880.080007]  [<ffffffffa0212f0a>] ? drm_helper_disable_unused_functions+0xf1/0x133 [drm_kms_helper]
[48880.080007]  [<ffffffffa0213dd0>] ? drm_crtc_helper_set_config+0x185/0x919 [drm_kms_helper]
[48880.080007]  [<ffffffffa021113a>] ? drm_fb_helper_restore_fbdev_mode+0x30/0x4a [drm_kms_helper]
[48880.080007]  [<ffffffffa021118b>] ? drm_fb_helper_force_kernel_mode+0x37/0x62 [drm_kms_helper]
[48880.080007]  [<ffffffffa0211aa2>] ? drm_fb_helper_panic+0x20/0x26 [drm_kms_helper]
[48880.080007]  [<ffffffff8136d416>] ? notifier_call_chain+0x2e/0x5b
[48880.080007]  [<ffffffff81368236>] ? panic+0xf3/0x1dd
[48880.080007]  [<ffffffff8136b013>] ? oops_end+0xaa/0xb7
[48880.080007]  [<ffffffff8103319a>] ? no_context+0x254/0x263
[48880.080007]  [<ffffffff8136d249>] ? do_page_fault+0x1ad/0x34c
[48880.080007]  [<ffffffffa0699240>] ? write_msg+0x9f/0x102 [netconsole]
[48880.080007]  [<ffffffff81101319>] ? ____cache_alloc+0x3f/0x246
[48880.080007]  [<ffffffff8136a5a5>] ? page_fault+0x25/0x30
[48880.080007]  [<ffffffffa06ba879>] ? cdc_ncm_tx_bundle+0x168/0x43b [cdc_ncm]
[48880.080007]  [<ffffffffa06ba93a>] ? cdc_ncm_tx_bundle+0x229/0x43b [cdc_ncm]
[48880.080007]  [<ffffffff812a8b00>] ? build_skb+0x7b/0xa9
[48880.080007]  [<ffffffffa03ac5fc>] ? usbnet_start_xmit+0x99/0x4e9 [usbnet]
[48880.080007]  [<ffffffff812b50b1>] ? dev_hard_start_xmit+0x3db/0x533
[48880.080007]  [<ffffffff812c9d5a>] ? sch_direct_xmit+0x64/0x13a
[48880.080007]  [<ffffffff812b5521>] ? dev_queue_xmit+0x318/0x4eb
[48880.080007]  [<ffffffff81347a8a>] ? packet_sendmsg_spkt+0x268/0x297
[48880.080007]  [<ffffffff812a0644>] ? sock_sendmsg+0x53/0x6b
[48880.080007]  [<ffffffff8124bb5d>] ? pty_write+0x48/0x53
[48880.080007]  [<ffffffff8129f9f6>] ? copy_from_user+0x18/0x30
[48880.080007]  [<ffffffff8129fa46>] ? move_addr_to_kernel+0x2a/0x65
[48880.080007]  [<ffffffff812a0b6a>] ? sys_sendto+0xf7/0x137
[48880.080007]  [<ffffffff8110b27b>] ? vfs_write+0xc9/0xff
[48880.080007]  [<ffffffff8136f779>] ? system_call_fastpath+0x16/0x1b
[48880.080007] ---[ end trace 993ca2b17e744959 ]---
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
