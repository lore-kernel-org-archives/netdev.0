From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: scheduling while atomic: br2684ctl (atm)
Date: Wed, 22 Sep 2010 14:54:51 -0700
Message-ID: <20100922215450.GO2435@linux.vnet.ibm.com>
References: <647401.39574.qm@web58406.mail.re3.yahoo.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karl Hiramoto <karl@hiramoto.org>,
	"David S. Miller" <davem@davemloft.net>,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mikko Vinni <mmvinni@yahoo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <647401.39574.qm@web58406.mail.re3.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2010 at 12:42:29AM -0700, Mikko Vinni wrote:
> Hi all,
> 
> I get the following message apparently every time (on 2.6.36-rc4+ at least) when
> killing any old br2684ctl processes. "unregister_atmdevice_notifier" was added 
> by
> 7313bb8f ("atm: propagate signal changes via notifier") so perhaps the 
> unregister
> part was not tested properly for rcu interaction?

This complaint will happen when you call synchronize_rcu() while in some
context where it is illegal to block, for example, if irqs are disabled
or if a spinlock is held.  I don't see commit 7313bb8f, but perhaps
unregister_atmdevice_notifier() is holding a spinlock across the call
to atomic_notifier_chain_unregister()?

							Thanx, Paul

> So far I haven't noticed any ill effects from the message. Let me know if I
> should test something. Thanks.
> 
> Mikko
> 
> 
> [29874.827053] PM: restore of devices complete after 3623.342 msecs
> [29874.827053] wlan0: Trigger new scan to find an IBSS to join
> [29875.020370] wlan0: Creating new IBSS network, BSSID 8a:4c:35:ef:eb:6b
> [29875.613701] wlan0: no IPv6 routers present
> [29876.027033] nas0: no IPv6 routers present
> [29876.831216] cxacru 3-1:1.0: receive of cm 0x90 failed (-104)
> [29876.844328] r8169 0000:09:00.0: PME# enabled
> [29876.878731] snapshot_ioctl: ioctl '4004330c' is deprecated and will be 
> removed soon, update your suspend-to-disk utilities
> [29876.878741] Restarting tasks ... done.
> [29876.903718] PM: Basic memory bitmaps freed
> [29876.903718] video LNXVIDEO:01: Restoring backlight state
> [29879.703963] cxacru 3-1:1.0: found firmware cxacru-fw.bin
> [29879.708273] cxacru 3-1:1.0: loading firmware
> [29881.277932] cxacru 3-1:1.0: starting device
> [29882.346357] cxacru0: ADSL USB MODEM (usb-0000:00:12.0-1) 00:04:ed:09:1e:5a
> [29882.362575] ATM dev 0: ADSL state: running
> [29882.362593] ATM dev 0: ADSL line: down
> [29882.580484] BUG: scheduling while atomic: br2684ctl/28543/0x00000002
> [29882.580498] Modules linked in: nls_cp437 vfat fat usb_storage cpufreq_stats 
> iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack 
> nf_defrag_ipv4 ip_tables x_tables br2684 ipv6 sco bnep l2cap bluetooth ext2 
> cxacru arc4 ecb usbatm atm uvcvideo videodev v4l1_compat v4l2_compat_ioctl32 
> snd_seq_dummy snd_seq_oss snd_hda_codec_atihdmi snd_seq_midi_event 
> snd_hda_codec_idt snd_seq snd_seq_device ath5k snd_hda_intel snd_pcm_oss 
> snd_hda_codec snd_mixer_oss mac80211 joydev ath snd_hwdep snd_pcm video ohci_hcd 
> hp_wmi output snd_timer cfg80211 ehci_hcd hp_accel lis3lv02d battery rfkill 
> input_polldev snd wmi thermal ohci1394 psmouse jmb38x_ms pcspkr ac edac_core 
> i2c_piix4 sg soundcore usbcore snd_page_alloc button serio_raw evdev memstick 
> powernow_k8 led_class r8169 processor k10temp mii ieee1394 mperf rtc_cmos 
> rtc_core rtc_lib ext4 mbcache jbd2 crc16 sr_mod cdrom sd_mod ahci libahci 
> pata_atiixp pata_acpi libata scsi_mod radeon ttm drm_kms_helper drm i2c_algo_bit 
> i2c_core [last unloaded: mmc_core]
> [29882.580796] Pid: 28543, comm: br2684ctl Not tainted 
> 2.6.36-rc4-CUST-00214-g2422084 #49
> [29882.580808] Call Trace:
> [29882.580845]  [<ffffffff8103cfd1>] __schedule_bug+0x61/0x70
> [29882.580865]  [<ffffffff8131202e>] schedule+0x8de/0xa90
> [29882.580882]  [<ffffffff81312745>] schedule_timeout+0x215/0x350
> [29882.580900]  [<ffffffff8127f470>] ? flush_backlog+0x0/0x120
> [29882.580924]  [<ffffffff81080722>] ? smp_call_function_single+0x172/0x190
> [29882.580937]  [<ffffffff8127f470>] ? flush_backlog+0x0/0x120
> [29882.580951]  [<ffffffff81311610>] wait_for_common+0xc0/0x150
> [29882.580968]  [<ffffffff81046050>] ? default_wake_function+0x0/0x10
> [29882.580985]  [<ffffffff81311748>] wait_for_completion+0x18/0x20
> [29882.581004]  [<ffffffff810a95d6>] synchronize_rcu+0x46/0x50
> [29882.581025]  [<ffffffff810683a0>] ? wakeme_after_rcu+0x0/0x10
> [29882.581051]  [<ffffffff81070eb0>] atomic_notifier_chain_unregister+0x60/0x80
> [29882.581083]  [<ffffffffa050ddc3>] unregister_atmdevice_notifier+0x13/0x20 
> [atm]
> [29882.581102]  [<ffffffffa05d588d>] br2684_push+0x2bd/0x320 [br2684]
> [29882.581124]  [<ffffffffa050e2f6>] vcc_release+0x76/0x130 [atm]
> [29882.581142]  [<ffffffff8126ef94>] sock_release+0x24/0x90
> [29882.581155]  [<ffffffff8126f012>] sock_close+0x12/0x30
> [29882.581174]  [<ffffffff8110c5c5>] fput+0xd5/0x230
> [29882.581188]  [<ffffffff81108edb>] filp_close+0x5b/0x80
> [29882.581207]  [<ffffffff8104ee67>] put_files_struct+0x97/0x100
> [29882.581221]  [<ffffffff8104ef8d>] exit_files+0x4d/0x60
> [29882.581234]  [<ffffffff8104f118>] do_exit+0x178/0x810
> [29882.581256]  [<ffffffff8100cc9c>] ? fpu_finit+0x1c/0x30
> [29882.581270]  [<ffffffff8104fa3f>] do_group_exit+0x4f/0xb0
> [29882.581283]  [<ffffffff8104fab2>] sys_exit_group+0x12/0x20
> [29882.581300]  [<ffffffff81002e82>] system_call_fastpath+0x16/0x1b
> [29883.353415] ATM dev 0: ADSL line: initializing
> [29884.359446] ATM dev 0: ADSL line: down
> [29887.862669] ata3.00: configured for UDMA/100
> [29887.862688] ata3: EH complete
> 
> 
>       
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
