From: Josh Boyer <jwboyer@redhat.com>
Subject: DMA-API check_sync errors with 3.2
Date: Tue, 8 Nov 2011 12:31:53 -0500
Message-ID: <20111108173153.GE14216@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fedoraproject.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Joerg Roedel <joerg.roedel@amd.com>,
	Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

We have a few reports coming in on 3.2 git snapshots and 3.2-rc1
where the DMA-API reports an error about a driver trying to sync
memory it has not allocated.  I've seen a couple reports of this for
sky2 and one for tg3, but I'm not sure if it's a driver problem or
something a bit more generic.  An example trace is below:

backtrace:
:WARNING: at lib/dma-debug.c:965 check_sync+0x2a8/0x530()
:Hardware name: P5K-E
:sky2 0000:02:00.0: DMA-API: device driver tries to sync DMA memory it has not
allocated [device address=0x0000000105258040] [size=60 bytes]
:Modules linked in: fuse lp parport ebtable_nat ebtables ipt_MASQUERADE
iptable_nat nf_nat xt_CHECKSUM iptable_mangle tun bridge lockd stp llc
ip6t_REJECT nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_ipv6
nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 ip6table_filter xt_state
nf_conntrack ip6_tables raid1 uvcvideo videodev snd_usb_audio
snd_hda_codec_hdmi media v4l2_compat_ioctl32 snd_usbmidi_lib joydev snd_rawmidi
snd_seq_device snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep
snd_pcm snd_timer snd microcode i2c_i801 iTCO_wdt iTCO_vendor_support serio_raw
sky2 asus_atk0110 soundcore snd_page_alloc configfs virtio_net kvm_intel kvm
uinput sunrpc raid10 btrfs zlib_deflate libcrc32c ata_generic pata_acpi
firewire_ohci firewire_core crc_itu_t pata_jmicron radeon ttm drm_kms_helper
drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
:Pid: 2520, comm: boinc Not tainted 3.2.0-0.rc0.git6.0.fc17.x86_64 #1
:Call Trace:
: <IRQ>  [<ffffffff8107ce9f>] warn_slowpath_common+0x7f/0xc0
: [<ffffffff8107cf96>] warn_slowpath_fmt+0x46/0x50
: [<ffffffff81325658>] check_sync+0x2a8/0x530
: [<ffffffff81311c8e>] ? random32+0x2e/0x40
: [<ffffffff81325b62>] debug_dma_sync_single_for_cpu+0x42/0x50
: [<ffffffff81192cac>] ? ksize+0x1c/0xc0
: [<ffffffff813217cc>] ? is_swiotlb_buffer+0x3c/0x50
: [<ffffffff81321fe8>] ? swiotlb_sync_single+0x38/0x80
: [<ffffffff8132212c>] ? swiotlb_sync_single_for_cpu+0xc/0x10
: [<ffffffffa0331873>] sky2_poll+0x573/0xd90 [sky2]
: [<ffffffff815454e1>] ? net_rx_action+0xa1/0x460
: [<ffffffff815455a9>] net_rx_action+0x169/0x460
: [<ffffffff81020c89>] ? sched_clock+0x9/0x10
: [<ffffffff810ab9b5>] ? sched_clock_local+0x25/0x90
: [<ffffffff810858f8>] __do_softirq+0xc8/0x3a0
: [<ffffffff810ab9b5>] ? sched_clock_local+0x25/0x90
: [<ffffffff81685efc>] call_softirq+0x1c/0x30
: [<ffffffff8101b385>] do_softirq+0xa5/0xe0
: [<ffffffff81085f2e>] irq_exit+0xbe/0xf0
: [<ffffffff816867d3>] do_IRQ+0x63/0xe0
: [<ffffffff8167b673>] common_interrupt+0x73/0x73
: <EOI>  [<ffffffff8167b719>] ? retint_swapgs+0x13/0x1b

>From what I can tell, net_rx_action is calling dma_issue_pending_all at
the end of the function and this is forcing the flush and check (though
I really haven't figured out why), and it's being attributed to the driver.

Originally there was a suggestion that c6a21d0b8d (dma-debug:
hash_bucket_find needs to allow for offsets within an entry) would solve
the issue, but that seems to have not proven true.  We still see this on
kernels that have that commit included.  I've linked the bug reports below.

Any ideas?

josh

https://bugzilla.redhat.com/show_bug.cgi?id=751005
https://bugzilla.redhat.com/show_bug.cgi?id=751797
https://bugzilla.redhat.com/show_bug.cgi?id=752113
