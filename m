From: Bart Van Assche <bvanassche@acm.org>
Subject: Netpoll triggers soft lockup
Date: Thu, 11 Apr 2013 15:42:02 +0200
Message-ID: <5166BDAA.3000603@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:41780 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab3DKNmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 09:42:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While testing a driver against kernel 3.9-rc6 I ran into a soft lockup 
triggered by sending lots of kernel messages to a remote system via 
netconsole. This behavior was probably introduced by commit ca99ca14c 
("netpoll: protect napi_poll and poll_controller during 
dev_[open|close]"). That commit introduced a mutex in 
netpoll_poll_dev(), which can be called from interrupt context. Is there 
anyone who can tell me whether this is a bug in commit ca99ca14c or in 
netconsole ?

Read(10):------------[ cut here ]------------
WARNING: at kernel/mutex.c:434 mutex_trylock+0x16d/0x180()
Hardware name: P5Q DELUXE
Modules linked in: ib_srp scsi_transport_srp dm_mod qla2x00tgt(O) 
qla2xxx_scst(O) scsi_transport_fc iscsi_scst(O) ib_srpt(O) scst_vdisk(O) 
libcrc32c scst(O) crc32c brd netconsole configfs rdma_ucm rdma_cm iw_cm 
ib_addr scsi_tgt af_packet snd_hda_codec_hdmi snd_hda_codec_analog 
ib_ipoib ib_cm ib_uverbs ib_umad snd_hda_intel snd_hda_codec snd_hwdep 
snd_pcm snd_seq snd_timer mlx4_ib ib_sa ib_mad cpufreq_conservative 
ib_core cpufreq_userspace cpufreq_powersave snd_seq_device snd mlx4_core 
sr_mod skge soundcore pcspkr acpi_cpufreq button ehci_pci sg i2c_i801 
mperf snd_page_alloc cdrom microcode autofs4 ext3 jbd mbcache sd_mod 
crc_t10dif radeon uhci_hcd ttm drm_kms_helper ehci_hcd drm i2c_algo_bit 
i2c_core intel_agp intel_gtt agpgart usbcore usb_common processor 
thermal_sys hwmon scsi_dh_alua scsi_dh ata_generic ata_piix ahci libahci 
pata_marvell libata scsi_mod [last unloaded: scsi_transport_srp]
Pid: 178, comm: kworker/0:1H Tainted: G           O 3.9.0-rc6-debug+ #0
Call Trace:
  <IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
  [<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
  [<ffffffff814761dd>] mutex_trylock+0x16d/0x180
  [<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
  [<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
  [<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
  [<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
  [<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
  [<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
  [<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
  [<ffffffff8103fb76>] console_unlock+0x2d6/0x450
  [<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
  [<ffffffff8146f9f6>] printk+0x4d/0x4f
  [<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]
  [<ffffffffa000b924>] scsi_io_completion+0x294/0x6c0 [scsi_mod]
  [<ffffffffa000113d>] scsi_finish_command+0xbd/0x120 [scsi_mod]
  [<ffffffffa000b58f>] scsi_softirq_done+0x13f/0x160 [scsi_mod]
  [<ffffffff8121dbc0>] blk_done_softirq+0x80/0xa0
  [<ffffffff81046e81>] ? __do_softirq+0xb1/0x3c0
  [<ffffffff81046ed1>] __do_softirq+0x101/0x3c0
  [<ffffffff810cc649>] ? handle_irq_event+0x59/0x80
  [<ffffffff81047355>] irq_exit+0xb5/0xc0
  [<ffffffff81484cd3>] do_IRQ+0x63/0xe0
  [<ffffffff8147a82f>] common_interrupt+0x6f/0x6f
  <EOI>  [<ffffffff810a1ea2>] ? mark_held_locks+0xb2/0x130
  [<ffffffff8147a46a>] ? _raw_spin_unlock_irq+0x3a/0x50
  [<ffffffff8147a460>] ? _raw_spin_unlock_irq+0x30/0x50
  [<ffffffff812148e5>] blk_delay_work+0x35/0x40
  [<ffffffff8106135d>] process_one_work+0x1fd/0x650
  [<ffffffff810612f2>] ? process_one_work+0x192/0x650
  [<ffffffff81061b50>] worker_thread+0x110/0x380
  [<ffffffff81061a40>] ? rescuer_thread+0x250/0x250
  [<ffffffff81067d6b>] kthread+0xdb/0xe0
  [<ffffffff81067c90>] ? kthread_create_on_node+0x140/0x140
  [<ffffffff8148345c>] ret_from_fork+0x7c/0xb0
  [<ffffffff81067c90>] ? kthread_create_on_node+0x140/0x140
---[ end trace e3e3a22d8bb51cb7 ]---

Thanks,

Bart.
