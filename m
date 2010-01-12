From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.33RC3 libvirtd ->sky2 & rcu oops (was Sky2 oops - Driver
	tries to sync DMA memory it has not allocated)
Date: Mon, 11 Jan 2010 17:49:09 -0800
Message-ID: <20100112014909.GB10869@linux.vnet.ibm.com>
References: <4B49015D.9000903@majjas.com> <4B4A341B.6010800@majjas.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753140Ab0ALBtO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B4A341B.6010800@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2010 at 03:10:03PM -0500, Michael Breuer wrote:
> On 1/9/2010 5:21 PM, Michael Breuer wrote:
>> Hi,
>>
>> Attempting to move back to mainline after my recent 2.6.32 issues...
>> Config is make oldconfig from working 2.6.32 config. Patch for af_packet.c 
>> (for skb issue found in 2.6.32) included. Attaching .config and NMI 
>> backtraces.
>>
>> System becomes unusable after bringing up the network:
>>
>> Jan  9 16:36:50 mail kernel: ------------[ cut here ]------------
>> Jan  9 16:36:50 mail kernel: WARNING: at lib/dma-debug.c:902 
>> check_sync+0xbd/0x426()
>> Jan  9 16:36:50 mail kernel: Hardware name: System Product Name
>> Jan  9 16:36:50 mail kernel: sky2 0000:04:00.0: DMA-API: device driver 
>> tries to sync DMA memory it has not allocated [device 
>> address=0x0000000311686822] [size=60 bytes]
>> Jan  9 16:36:50 mail kernel: Modules linked in: bridge stp appletalk psnap 
>> llc nfsd lockd nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc 
>> acpi_cpufreq sit tunnel4 ipt_LOG ipt_MASQUERADE iptable_nat nf_nat 
>> iptable_mangle iptable_raw nf_conntrack_netbios_ns nf_conntrack_ftp 
>> nf_conntrack_ipv6 xt_multiport ip6table_filter xt_DSCP xt_dscp xt_MARK 
>> ip6table_mangle ip6_tables ipv6 dm_multipath kvm_intel kvm 
>> snd_hda_codec_analog snd_ens1371 gameport snd_rawmidi snd_ac97_codec 
>> snd_hda_intel ac97_bus snd_hda_codec snd_hwdep snd_seq gspca_spca505 
>> snd_seq_device gspca_main snd_pcm videodev snd_timer snd v4l1_compat 
>> v4l2_compat_ioctl32 firewire_ohci soundcore snd_page_alloc iTCO_wdt 
>> i2c_i801 iTCO_vendor_support firewire_core crc_itu_t sky2 pcspkr wmi 
>> asus_atk0110 hwmon fbcon tileblit font bitblit softcursor raid456 
>> async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx 
>> raid1 ata_generic pata_acpi pata_marvell nouveau ttm drm_kms_helper drm 
>> agpgart fb i2c_algo_bit cfbcopyarea i2c_core cfbimgblt cfbfil
>> Jan  9 16:36:50 mail kernel: lrect [last unloaded: scsi_wait_scan]
>> Jan  9 16:36:50 mail kernel: Pid: 5271, comm: libvirtd Not tainted 
>> 2.6.33-rc3WITHMMAPNODMAR-00147-g3c8ad49-dirty #1
>> Jan  9 16:36:50 mail kernel: Call Trace:
>> Jan  9 16:36:50 mail kernel: <IRQ>  [<ffffffff81049fe5>] 
>> warn_slowpath_common+0x7c/0x94
>> Jan  9 16:36:50 mail kernel: [<ffffffff8104a054>] 
>> warn_slowpath_fmt+0x41/0x43
>> Jan  9 16:36:50 mail kernel: [<ffffffff81261c0a>] check_sync+0xbd/0x426
>> Jan  9 16:36:50 mail kernel: [<ffffffff813b2aff>] ? 
>> __netdev_alloc_skb+0x34/0x50
>> Jan  9 16:36:50 mail kernel: [<ffffffff812622c6>] 
>> debug_dma_sync_single_for_cpu+0x42/0x44
>> Jan  9 16:36:50 mail kernel: [<ffffffff8125f6c7>] ? 
>> swiotlb_sync_single+0x2a/0xb6
>> Jan  9 16:36:50 mail kernel: [<ffffffff8125f823>] ? 
>> swiotlb_sync_single_for_cpu+0xc/0xe
>> Jan  9 16:36:50 mail kernel: [<ffffffffa018efcb>] sky2_poll+0x4d5/0xaf0 
>> [sky2]
>> Jan  9 16:36:50 mail kernel: [<ffffffff8106a1a3>] ? 
>> sched_clock_cpu+0x44/0xce
>> Jan  9 16:36:50 mail kernel: [<ffffffff81070573>] ? 
>> clockevents_program_event+0x7a/0x83
>> Jan  9 16:36:50 mail kernel: [<ffffffff813b9766>] net_rx_action+0xb5/0x1f0
>> Jan  9 16:36:50 mail kernel: [<ffffffff8105059c>] __do_softirq+0xf8/0x1cd
>> Jan  9 16:36:50 mail kernel: [<ffffffff8109389a>] ? 
>> handle_IRQ_event+0x119/0x12b
>> Jan  9 16:36:50 mail kernel: [<ffffffff8100ab1c>] call_softirq+0x1c/0x30
>> Jan  9 16:36:50 mail kernel: [<ffffffff8100c2b3>] do_softirq+0x4b/0xa3
>> Jan  9 16:36:50 mail kernel: [<ffffffff81050188>] irq_exit+0x4a/0x8c
>> Jan  9 16:36:50 mail kernel: [<ffffffff8145a83c>] do_IRQ+0xac/0xc3
>> Jan  9 16:36:50 mail kernel: [<ffffffff81455a93>] ret_from_intr+0x0/0x16
>> Jan  9 16:36:50 mail kernel: <EOI>  [<ffffffff8104474c>] ? 
>> set_cpus_allowed_ptr+0x22/0x14b
>> Jan  9 16:36:50 mail kernel: [<ffffffff81087aff>] 
>> cpuset_attach_task+0x27/0x9c
>> Jan  9 16:36:50 mail kernel: [<ffffffff81087bfe>] cpuset_attach+0x8a/0x133
>> Jan  9 16:36:50 mail kernel: [<ffffffff81042cba>] ? 
>> sched_move_task+0x104/0x110
>> Jan  9 16:36:50 mail kernel: [<ffffffff81085b4f>] 
>> cgroup_attach_task+0x4d5/0x533
>> Jan  9 16:36:50 mail kernel: [<ffffffff81085e05>] cgroup_clone+0x258/0x2ac
>> Jan  9 16:36:50 mail kernel: [<ffffffff81088a74>] 
>> ns_cgroup_clone+0x58/0x75
>> Jan  9 16:36:50 mail kernel: [<ffffffff81048ec1>] 
>> copy_process+0xcef/0x13af
>> Jan  9 16:36:50 mail kernel: [<ffffffff810d9044>] ? 
>> handle_mm_fault+0x355/0x7ff
>> Jan  9 16:36:50 mail kernel: [<ffffffff8108f769>] ? 
>> audit_filter_rules+0x19a/0x7c5
>> Jan  9 16:36:50 mail kernel: [<ffffffff810496ec>] do_fork+0x16b/0x309
>> Jan  9 16:36:50 mail kernel: [<ffffffff81251d12>] ? __up_read+0x82/0x8a
>> Jan  9 16:36:50 mail kernel: [<ffffffff81010f22>] sys_clone+0x28/0x2a
>> Jan  9 16:36:50 mail kernel: [<ffffffff81009f33>] stub_clone+0x13/0x20
>> Jan  9 16:36:50 mail kernel: [<ffffffff81009bf2>] ? 
>> system_call_fastpath+0x16/0x1b
>> Jan  9 16:36:50 mail kernel: ---[ end trace cd5e0588bad4ec83 ]---
>> Then... after a few more normal boot messages (samba starting up, etc.) I 
>> just see rcu stalls with NMI backtraces for each cpu. I've attached the 
>> first one - the rcu stall oops repeats until the reboot I forced.
> Tracked this down to libvirtd. No idea why yet - but these oops occur when 
> starting libvirtd. Version of libvirt is 0.7.0-15.fc12.x86_64.

RCU stall warnings are usually due to an infinite loop somewhere in the
kernel.  If you are running !CONFIG_PREEMPT, then any infinite loop not
containing some call to schedule will get you a stall warning.  If you
are running CONFIG_PREEMPT, then the infinite loop is in some section of
code with preemption disabled (or irqs disabled).

The stall-warning dump will normally finger one or more of the CPUs.
Since you are getting repeated warnings, look at the stacks and see
which of the most-recently-called functions stays the same in successive
stack traces.  This information should help you finger the infinite (or
longer than average) loop.

> Also, checking back to 2.6.32 - found that the sky2 oops listed above also 
> occurs (started it seems after an update to 
> libvirt-java-0.4.0-1.fc12.noarch two days ago). However the subsequent rcu 
> stall doesn't happen on 2.6.32 - system behaves normally (which is why I 
> missed the oops).
> Now running OK on 2.6.33 w/o libvirtd.

Then if looking at the stack traces doesn't locate the offending loop,
bisection might help.

							Thanx, Paul

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
