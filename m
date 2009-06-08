From: Stephen Hemminger <shemminger@vyatta.com>
Subject: BUG: bonding module can only be loaded once
Date: Mon, 8 Jun 2009 15:11:27 -0700
Message-ID: <20090608151127.70146505@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sf.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756080AbZFHWLo@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to create multiple bonding dynamically, it is common practice to
load the bonding module multiple times.  This got broken in recent kernels
2.6.29 and later.

Doing the following will OOPS:
  modprobe -o bond0 bonding
  modprobe -o bond1 bonding

2.6.29 actually OOPS on error handling, but that is fixed in 2.6.30.
But 2.6.30 still has the regression (caused by sysfs).

This regression was introduced by changes to sysfs and proc that
made duplicate insertion a problem.

[  134.012562] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
[  134.012565] bonding: Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.
[  134.012571] ------------[ cut here ]------------
[  134.012578] WARNING: at fs/proc/generic.c:590 proc_register+0x154/0x191()
[  134.012581] Hardware name: System Product Name
[  134.012583] proc_dir_entry 'net/bonding' already registered
[  134.012585] Modules linked in: bond1(+) bond0 binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm ipv6 video output pci_slot acpi_cpufreq cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw soundcore snd_page_alloc wmi evdev rtc_cmos sg sr_mod cdrom hid_belkin usbhid mvsas pata_acpi pata_marvell libsas ata_piix scsi_transport_sas ahci sky2 igb dca floppy fuse
[  134.012639] Pid: 7370, comm: modprobe Not tainted 2.6.30-rc8 #134
[  134.012641] Call Trace:
[  134.012646]  [<ffffffff802edf10>] ? proc_register+0x154/0x191
[  134.012650]  [<ffffffff802edf10>] ? proc_register+0x154/0x191
[  134.012655]  [<ffffffff802326c8>] ? warn_slowpath_common+0x77/0xa3
[  134.012659]  [<ffffffff80232750>] ? warn_slowpath_fmt+0x51/0x59
[  134.012663]  [<ffffffff802edf10>] ? proc_register+0x154/0x191
[  134.012668]  [<ffffffff802ee111>] ? proc_mkdir_mode+0x3c/0x51
[  134.012677]  [<ffffffffa0078787>] ? bonding_init+0x787/0x825 [bond1]
[  134.012685]  [<ffffffffa0078000>] ? bonding_init+0x0/0x825 [bond1]
[  134.012690]  [<ffffffff80209052>] ? do_one_initcall+0x51/0x120
[  134.012695]  [<ffffffff80383870>] ? __up_read+0x13/0x8d
[  134.012701]  [<ffffffff80248999>] ? __blocking_notifier_call_chain+0x51/0x5f
[  134.012705]  [<ffffffff80256d2c>] ? sys_init_module+0xa0/0x1bf
[  134.012709]  [<ffffffff8020aeeb>] ? system_call_fastpath+0x16/0x1b
[  134.012712] ---[ end trace cade86cfa6baa544 ]---
[  134.014510] ------------[ cut here ]------------
[  134.014516] WARNING: at fs/sysfs/dir.c:487 sysfs_add_one+0xcc/0xe4()
[  134.014519] Hardware name: System Product Name
[  134.014521] sysfs: cannot create duplicate filename '/class/net/bonding_masters'
[  134.014524] Modules linked in: bond1(+) bond0 binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm ipv6 video output pci_slot acpi_cpufreq cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw soundcore snd_page_alloc wmi evdev rtc_cmos sg sr_mod cdrom hid_belkin usbhid mvsas pata_acpi pata_marvell libsas ata_piix scsi_transport_sas ahci sky2 igb dca floppy fuse
[  134.014603] Pid: 7370, comm: modprobe Tainted: G        W  2.6.30-rc8 #134
[  134.014605] Call Trace:
[  134.014610]  [<ffffffff802f4171>] ? sysfs_add_one+0xcc/0xe4
[  134.014614]  [<ffffffff802f4171>] ? sysfs_add_one+0xcc/0xe4
[  134.014618]  [<ffffffff802326c8>] ? warn_slowpath_common+0x77/0xa3
[  134.014623]  [<ffffffff80232750>] ? warn_slowpath_fmt+0x51/0x59
[  134.014628]  [<ffffffff802f409d>] ? sysfs_pathname+0x35/0x3d
[  134.014632]  [<ffffffff802f409d>] ? sysfs_pathname+0x35/0x3d
[  134.014636]  [<ffffffff802f409d>] ? sysfs_pathname+0x35/0x3d
[  134.014640]  [<ffffffff802f4171>] ? sysfs_add_one+0xcc/0xe4
[  134.014644]  [<ffffffff802f3b47>] ? sysfs_add_file_mode+0x4e/0x7f
[  134.014655]  [<ffffffffa02d2ef9>] ? bond_create_sysfs+0xd/0x45 [bond1]
[  134.014664]  [<ffffffffa00787e7>] ? bonding_init+0x7e7/0x825 [bond1]
[  134.014673]  [<ffffffffa0078000>] ? bonding_init+0x0/0x825 [bond1]
[  134.014677]  [<ffffffff80209052>] ? do_one_initcall+0x51/0x120
[  134.014682]  [<ffffffff80383870>] ? __up_read+0x13/0x8d
[  134.014687]  [<ffffffff80248999>] ? __blocking_notifier_call_chain+0x51/0x5f
[  134.014691]  [<ffffffff80256d2c>] ? sys_init_module+0xa0/0x1bf
[  134.014695]  [<ffffffff8020aeeb>] ? system_call_fastpath+0x16/0x1b
[  134.014698] ---[ end trace cade86cfa6baa545 ]---
