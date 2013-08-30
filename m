From: Eric Wong <normalperson@yhbt.net>
Subject: ipv4: warnings on sk_wmem_queued
Date: Fri, 30 Aug 2013 19:56:38 +0000
Message-ID: <20130830195638.GA27393@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed these warnings on stock 3.10.9 running stress tests on
cmogstored.git (git://bogomips.org/cmogstored.git) doing standard
HTTP server stuff between lo and tmpfs:

HTTP PUT requests hit: read(socket) + pwrite()
HTTP GET requests hit: send(MSG_MORE) + sendfile()

HTTP/1.1 persistent connections used for all GETs (using ab), but not
PUTs since I was lazy at curl scripting.

PUT requests are concurrent 100M uploads,
GET responses range from 110 bytes to 1GB

I'm doing a bunch of these requests in parallel with ab and curl so I
can't tell which caused the warning.  No errors bubbled up cmogstored.

This is fairly new hardware: Haswell E3-1230 v3 @ 3.30GHz on
NO_HZ_{FULL,_ALL}=y, PREEMPT=y

sysctl: tcp_low_latency=1, tcp_slow_start_after_idle=0
sockopts: TCP_NODELAY, SO_KEEPALIVE, SO_REUSEADDR

No changes to socket buffers anywhere, no TFO.

I was going to reboot into 3.10.10 before I looked at dmesg.  These
warnings happened after ~8 hours of stress tests, and those stress tests
are still running.

Aug 30 06:03:54 localhost kernel: ------------[ cut here ]------------
Aug 30 06:03:54 localhost kernel: WARNING: at net/core/stream.c:200 sk_stream_kill_queues+0x131/0x140()
Aug 30 06:03:54 localhost kernel: Modules linked in: fuse ufs minix ntfs vfat msdos fat libcrc32c reiserfs ext2 dm_mod binfmt_misc w83627ehf hwmon_vid lm63 loop snd_hda_codec_realtek coretemp kvm_intel kvm crc32c_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd radeon cfbfillrect cfbimgblt cfbcopyarea sg ttm snd_hda_intel drm_kms_helper microcode snd_hda_codec drm snd_hwdep snd_pcm agpgart e1000e igb snd_page_alloc snd_timer snd sr_mod evdev firewire_core firmware_class i2c_algo_bit crc_itu_t ptp ehci_pci dca i2c_i801 cdrom pps_core ehci_hcd xhci_hcd fan video backlight thermal acpi_cpufreq mperf freq_table button processor [last unloaded: firewire_ohci]
Aug 30 06:03:54 localhost kernel: CPU: 5 PID: 8390 Comm: cmogstored Tainted: G        W    3.10.9meltdown2 #11
Aug 30 06:03:54 localhost kernel: Hardware name: Supermicro X10SAE/X10SAE, BIOS 1.00 05/03/2013
Aug 30 06:03:54 localhost kernel: 0000000000000009 ffff88083dd43a38 ffffffff814244c6 ffff88083dd43a78
Aug 30 06:03:54 localhost kernel: ffffffff81034720 0000000000000000 ffff8803addf2080 ffff8803addf21d8
Aug 30 06:03:54 localhost kernel: 0000000000000000 0000000000000000 00000000000002d1 ffff88083dd43a88
Aug 30 06:03:54 localhost kernel: Call Trace:
Aug 30 06:03:54 localhost kernel: <IRQ>  [<ffffffff814244c6>] dump_stack+0x19/0x1b
Aug 30 06:03:54 localhost kernel: [<ffffffff81034720>] warn_slowpath_common+0x70/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff8103476a>] warn_slowpath_null+0x1a/0x20
Aug 30 06:03:54 localhost kernel: [<ffffffff81388c01>] sk_stream_kill_queues+0x131/0x140
Aug 30 06:03:54 localhost kernel: [<ffffffff813c5d1a>] inet_csk_destroy_sock+0x5a/0x140
Aug 30 06:03:54 localhost kernel: [<ffffffff813c8ef7>] tcp_done+0x67/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff813dfd94>] tcp_time_wait+0x74/0x1c0
Aug 30 06:03:54 localhost kernel: [<ffffffff813cdc24>] tcp_fin+0x114/0x1f0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d1098>] tcp_data_queue+0x708/0xcb0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d4b07>] tcp_rcv_state_process+0x6d7/0xc80
Aug 30 06:03:54 localhost kernel: [<ffffffff813d3ab6>] ? tcp_rcv_established+0x166/0x790
Aug 30 06:03:54 localhost kernel: [<ffffffff813db90f>] tcp_v4_do_rcv+0xcf/0x380
Aug 30 06:03:54 localhost kernel: [<ffffffff813debe1>] tcp_v4_rcv+0x691/0x800
Aug 30 06:03:54 localhost kernel: [<ffffffff81068565>] ? sched_clock_cpu+0xc5/0x120
Aug 30 06:03:54 localhost kernel: [<ffffffff813bb05e>] ip_local_deliver_finish+0xbe/0x220
Aug 30 06:03:54 localhost kernel: [<ffffffff813bb338>] ip_local_deliver+0x38/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff813bad99>] ip_rcv_finish+0x109/0x310
Aug 30 06:03:54 localhost kernel: [<ffffffff813bb561>] ip_rcv+0x1d1/0x300
Aug 30 06:03:54 localhost kernel: [<ffffffff8105a76d>] ? run_posix_cpu_timers+0x3d/0x830
Aug 30 06:03:54 localhost kernel: [<ffffffff8138c3b2>] __netif_receive_skb_core+0x4a2/0x610
Aug 30 06:03:54 localhost kernel: [<ffffffff8138f2c1>] __netif_receive_skb+0x21/0x70
Aug 30 06:03:54 localhost kernel: [<ffffffff8138f3ac>] process_backlog+0x9c/0x170
Aug 30 06:03:54 localhost kernel: [<ffffffff8138f77c>] net_rx_action+0xbc/0x200
Aug 30 06:03:54 localhost kernel: [<ffffffff8103c140>] __do_softirq+0xe0/0x280
Aug 30 06:03:54 localhost kernel: [<ffffffff8143173c>] call_softirq+0x1c/0x30
Aug 30 06:03:54 localhost kernel: <EOI>  [<ffffffff810039f5>] do_softirq+0x55/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff8103c057>] local_bh_enable+0xa7/0xb0
Aug 30 06:03:54 localhost kernel: [<ffffffff813bf1f4>] ip_finish_output+0x224/0x390
Aug 30 06:03:54 localhost kernel: [<ffffffff813c073e>] ip_output+0x4e/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff813bff19>] ip_local_out+0x29/0x30
Aug 30 06:03:54 localhost kernel: [<ffffffff813c0073>] ip_queue_xmit+0x153/0x3c0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d6c25>] tcp_transmit_skb+0x3c5/0x820
Aug 30 06:03:54 localhost kernel: [<ffffffff813d72c1>] tcp_write_xmit+0x191/0xaa0
Aug 30 06:03:54 localhost kernel: [<ffffffff8138434c>] ? __kmalloc_reserve.isra.49+0x3c/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d7c42>] __tcp_push_pending_frames+0x32/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d8a8f>] tcp_send_fin+0x6f/0x190
Aug 30 06:03:54 localhost kernel: [<ffffffff813cc508>] tcp_close+0x378/0x410
Aug 30 06:03:54 localhost kernel: [<ffffffff813efe5a>] inet_release+0x5a/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff8137a218>] sock_release+0x28/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff8137a5c2>] sock_close+0x12/0x20
Aug 30 06:03:54 localhost kernel: [<ffffffff81123def>] __fput+0xaf/0x240
Aug 30 06:03:54 localhost kernel: [<ffffffff8112403e>] ____fput+0xe/0x10
Aug 30 06:03:54 localhost kernel: [<ffffffff81054d47>] task_work_run+0xa7/0xe0
Aug 30 06:03:54 localhost kernel: [<ffffffff8100209c>] do_notify_resume+0x9c/0xb0
Aug 30 06:03:54 localhost kernel: [<ffffffff81430788>] int_signal+0x12/0x17
Aug 30 06:03:54 localhost kernel: ---[ end trace 1a0bb0997c6a8dcf ]---
Aug 30 06:03:54 localhost kernel: ------------[ cut here ]------------
Aug 30 06:03:54 localhost kernel: WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x191/0x1e0()
Aug 30 06:03:54 localhost kernel: Modules linked in: fuse ufs minix ntfs vfat msdos fat libcrc32c reiserfs ext2 dm_mod binfmt_misc w83627ehf hwmon_vid lm63 loop snd_hda_codec_realtek coretemp kvm_intel kvm crc32c_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd radeon cfbfillrect cfbimgblt cfbcopyarea sg ttm snd_hda_intel drm_kms_helper microcode snd_hda_codec drm snd_hwdep snd_pcm agpgart e1000e igb snd_page_alloc snd_timer snd sr_mod evdev firewire_core firmware_class i2c_algo_bit crc_itu_t ptp ehci_pci dca i2c_i801 cdrom pps_core ehci_hcd xhci_hcd fan video backlight thermal acpi_cpufreq mperf freq_table button processor [last unloaded: firewire_ohci]
Aug 30 06:03:54 localhost kernel: CPU: 5 PID: 8390 Comm: cmogstored Tainted: G        W    3.10.9meltdown2 #11
Aug 30 06:03:54 localhost kernel: Hardware name: Supermicro X10SAE/X10SAE, BIOS 1.00 05/03/2013
Aug 30 06:03:54 localhost kernel: 0000000000000009 ffff88083dd43bf8 ffffffff814244c6 ffff88083dd43c38
Aug 30 06:03:54 localhost kernel: ffffffff81034720 ffff8807e84147b0 ffff8803addf2080 ffff8803addf21d8
Aug 30 06:03:54 localhost kernel: ffff8803addf2080 ffff8805dd8150ac 0000000000004c1d ffff88083dd43c48
Aug 30 06:03:54 localhost kernel: Call Trace:
Aug 30 06:03:54 localhost kernel: <IRQ>  [<ffffffff814244c6>] dump_stack+0x19/0x1b
Aug 30 06:03:54 localhost kernel: [<ffffffff81034720>] warn_slowpath_common+0x70/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff8103476a>] warn_slowpath_null+0x1a/0x20
Aug 30 06:03:54 localhost kernel: [<ffffffff813f01d1>] inet_sock_destruct+0x191/0x1e0
Aug 30 06:03:54 localhost kernel: [<ffffffff8137f2ed>] __sk_free+0x1d/0x110
Aug 30 06:03:54 localhost kernel: [<ffffffff8137f471>] sk_free+0x21/0x30
Aug 30 06:03:54 localhost kernel: [<ffffffff813dec07>] tcp_v4_rcv+0x6b7/0x800
Aug 30 06:03:54 localhost kernel: [<ffffffff81068565>] ? sched_clock_cpu+0xc5/0x120
Aug 30 06:03:54 localhost kernel: [<ffffffff813bb05e>] ip_local_deliver_finish+0xbe/0x220
Aug 30 06:03:54 localhost kernel: [<ffffffff813bb338>] ip_local_deliver+0x38/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff813bad99>] ip_rcv_finish+0x109/0x310
Aug 30 06:03:54 localhost kernel: [<ffffffff813bb561>] ip_rcv+0x1d1/0x300
Aug 30 06:03:54 localhost kernel: [<ffffffff8105a76d>] ? run_posix_cpu_timers+0x3d/0x830
Aug 30 06:03:54 localhost kernel: [<ffffffff8138c3b2>] __netif_receive_skb_core+0x4a2/0x610
Aug 30 06:03:54 localhost kernel: [<ffffffff8138f2c1>] __netif_receive_skb+0x21/0x70
Aug 30 06:03:54 localhost kernel: [<ffffffff8138f3ac>] process_backlog+0x9c/0x170
Aug 30 06:03:54 localhost kernel: [<ffffffff8138f77c>] net_rx_action+0xbc/0x200
Aug 30 06:03:54 localhost kernel: [<ffffffff8103c140>] __do_softirq+0xe0/0x280
Aug 30 06:03:54 localhost kernel: [<ffffffff8143173c>] call_softirq+0x1c/0x30
Aug 30 06:03:54 localhost kernel: <EOI>  [<ffffffff810039f5>] do_softirq+0x55/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff8103c057>] local_bh_enable+0xa7/0xb0
Aug 30 06:03:54 localhost kernel: [<ffffffff813bf1f4>] ip_finish_output+0x224/0x390
Aug 30 06:03:54 localhost kernel: [<ffffffff813c073e>] ip_output+0x4e/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff813bff19>] ip_local_out+0x29/0x30
Aug 30 06:03:54 localhost kernel: [<ffffffff813c0073>] ip_queue_xmit+0x153/0x3c0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d6c25>] tcp_transmit_skb+0x3c5/0x820
Aug 30 06:03:54 localhost kernel: [<ffffffff813d72c1>] tcp_write_xmit+0x191/0xaa0
Aug 30 06:03:54 localhost kernel: [<ffffffff8138434c>] ? __kmalloc_reserve.isra.49+0x3c/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d7c42>] __tcp_push_pending_frames+0x32/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff813d8a8f>] tcp_send_fin+0x6f/0x190
Aug 30 06:03:54 localhost kernel: [<ffffffff813cc508>] tcp_close+0x378/0x410
Aug 30 06:03:54 localhost kernel: [<ffffffff813efe5a>] inet_release+0x5a/0xa0
Aug 30 06:03:54 localhost kernel: [<ffffffff8137a218>] sock_release+0x28/0x90
Aug 30 06:03:54 localhost kernel: [<ffffffff8137a5c2>] sock_close+0x12/0x20
Aug 30 06:03:54 localhost kernel: [<ffffffff81123def>] __fput+0xaf/0x240
Aug 30 06:03:54 localhost kernel: [<ffffffff8112403e>] ____fput+0xe/0x10
Aug 30 06:03:54 localhost kernel: [<ffffffff81054d47>] task_work_run+0xa7/0xe0
Aug 30 06:03:54 localhost kernel: [<ffffffff8100209c>] do_notify_resume+0x9c/0xb0
Aug 30 06:03:54 localhost kernel: [<ffffffff81430788>] int_signal+0x12/0x17
Aug 30 06:03:54 localhost kernel: ---[ end trace 1a0bb0997c6a8dd0 ]---

Thanks for reading!
