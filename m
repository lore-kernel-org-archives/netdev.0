From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 21 Jul 2009 09:58:53 -0700
Message-ID: <20090721095853.30f4fbda@nehalam>
References: <4A65EC3F.4050400@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41391 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753974AbZGUQ67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 12:58:59 -0400
In-Reply-To: <4A65EC3F.4050400@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jul 2009 18:26:39 +0200
Rene Mayrhofer <rene.mayrhofer@gibraltar.at> wrote:

> Hi everybody,
> 
> [Please CC me in replies, I am not currently subscribed to this list.]
> 
> I have a fully reproducible kernel oops in the sky2 module in kernel
> 2.6.28.10. The kernel is a vanilla 2.6.28.10 (and I can't switch to
> anything newer at this time because of missing squashfs-lzma support),
> patched with PaX, netfilter-layer7, squashfs (with LZMA), and IMQ. The
> base system is a Debian Lenny with some updates from testing/unstable.
> 
> Whenever interfaces using the sky2 module (this box has 8 network
> interfaces in a 19" rack appliance) go down, the oops occurs:

Looks like the device is disappearing from the PCI bus when
brought down.  Can you reproduce it with 2.6.30.2 or 2.6.31-rc3?


> [~]# ifdown -a --exclude=lo
> [ 1535.000069] sky2 0000:01:00.0: error interrupt status=0xffffffff
> [ 1535.006649] sky2 0000:01:00.0: PCI hardware error (0xffff)
> [ 1535.012608] sky2 0000:01:00.0: PCI Express error (0xffffffff)
> [ 1535.018821] sky2 wan: ram data read parity error
> [ 1535.023827] sky2 wan: ram data write parity error
> [ 1535.028913] sky2 wan: MAC parity error
> [ 1535.032992] sky2 wan: RX parity error
> [ 1535.036983] sky2 wan: TCP segmentation error
> [ 1535.041655] general protection fault: 0000 [#1] PREEMPT SMP
> [ 1535.045601] last sysfs file:
> /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
> 
> [ 1535.045601] Modules linked in: xt_multiport cpufreq_userspace xt_DSCP
> xt_length xt_mark xt_dscp xt_MARK xt_CONNMARK xt_comment xt_policy
> ipt_REDIRECT ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle
> ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG
> xt_limit xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod
> p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat
> nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack
> nf_defrag_ipv4 ipv6 evdev parport_pc parport serio_raw pcspkr i2c_i801
> i2c_core iTCO_wdt rng_core intel_agp agpgart squashfs sqlzma unlzma loop
> aufs exportfs nls_utf8 nls_cp437 ide_generic sd_mod ide_gd_mod
> ata_generic pata_acpi ata_piix piix ide_pci_generic ide_core skge sky2
> thermal_sys
> [ 1535.045601]
> 
> [ 1535.045601] Pid: 9960, comm: mv Not tainted (2.6.28.10 #2)
> 
> [ 1535.045601] EIP: 0060:[<f808085a>] EFLAGS: 00010286 CPU: 0
> 
> [ 1535.045601] EIP is at sky2_mac_intr+0x22/0x9d [sky2]
> 
> [ 1535.045601] EAX: f8090f88 EBX: 00000001 ECX: 00000008 EDX: 000000ff
> 
> [ 1535.045601] ESI: 00000000 EDI: f682cb80 EBP: 00000080 ESP: f5f13ed4
> 
> [ 1535.045601]  DS: 0068 ES: 0068 FS: 00d8 GS: 0033 SS: 0068
> 
> [ 1535.045601] Process mv (pid: 9960, ti=f5f12000 task=f4a961c0
> task.ti=f5f12000)
> 
> [ 1535.045601] Stack:
> 
> [ 1535.045601]  ff08340b f682cb88 ffffffff ffffffff f712b800 f80839d6
> 00000040 f682cb88
> 
> [ 1535.045601]  00000000 00000001 f682cb80 c082111a 00000000 00000000
> 00000003 f7014b80
> [ 1535.045601]  c0a604e8 00000246 f7014b80 c0838f21 00000000 c0a604e8
> 00000101 c1d10124
> [ 1535.045601] Call Trace:
> [ 1535.045601]  [<f80839d6>] sky2_poll+0x1cb/0xbed [sky2]
> [ 1535.045601]  [<c082111a>] __wake_up+0x29/0x39
> [ 1535.045601]  [<c0a604e8>] _spin_unlock_irqrestore+0x22/0x39
> [ 1535.045601]  [<c0838f21>] __queue_work+0x4d/0x5a
> [ 1535.045601]  [<c0a604e8>] _spin_unlock_irqrestore+0x22/0x39
> [ 1535.045601]  [<c09eda45>] net_rx_action+0xb8/0x1f6
> [ 1535.045601]  [<c082f954>] __do_softirq+0x95/0x142
> [ 1535.045601]  [<c082fa49>] do_softirq+0x48/0x57
> [ 1535.045601]  [<c082fbc9>] irq_exit+0x3b/0x78
> [ 1535.045601]  [<c081218f>] smp_apic_timer_interrupt+0x75/0x7f
> [ 1535.045601]  [<c0804f48>] apic_timer_interrupt+0x28/0x30
> [ 1535.045601]  [<c0a60000>] rwsem_down_failed_common+0xa4/0x175
> [ 1535.045601] Code: c0 83 c4 14 5b 5e 5f 5d c3 55 89 d5 57 89 c7 56 53
> 89 d3 c1 e5 07 83 ec 04 8b 74 90 30 8d 85 08 0f 00 00 03 07 8a 10 88 54
> 24 03 <f6> 86 0d 05 00 00 02 74 12 0f b6 c2 50 56 68 84 5b 08 f8 e8 cd
> [ 1535.045601] EIP: [<f808085a>] sky2_mac_intr+0x22/0x9d [sky2] SS:ESP
> 0068:f5f13ed4
> [ 1535.302490] Kernel panic - not syncing: Fatal exception in interrupt
> [ 1535.309412] Rebooting in 30 seconds..
> 
> 
> Or even when doing it more slowly, interface by interface:
> 
> [~]# ifdown tun6to4; cat /proc/net/dev | cut -d: -f1 | grep -v Inter |
> grep -v face | sort -u | while read iface; do echo $iface; ifdown
> $iface; sleep 3s; done
> hb
> 
> lo
> 
> dmz
> 
> lan
> [ 1127.000261] sky2 0000:04:00.0: error interrupt status=0xffffffff
> [ 1127.007348] sky2 0000:04:00.0: PCI hardware error (0xffff)
> [ 1127.013745] sky2 0000:04:00.0: PCI Express error (0xffffffff)
> [ 1127.020468] sky2 lan: ram data read parity error
> [ 1127.025834] sky2 lan: ram data write parity error
> [ 1127.031302] sky2 lan: MAC parity error
> [ 1127.035671] sky2 lan: RX parity error
> [ 1127.039910] sky2 lan: TCP segmentation error
> [ 1127.045079] general protection fault: 0000 [#1] PREEMPT SMP
> [ 1127.048879] last sysfs file:
> /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
> 
> [ 1127.048879] Modules linked in: xt_multiport cpufreq_userspace xt_DSCP
> xt_length xt_mark xt_dscp xt_MARK xt_CONNMARK xt_comment xt_policy
> ipt_REDIRECT ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle
> ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG
> xt_limit xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod
> p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat
> nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack
> nf_defrag_ipv4 ipv6 evdev parport_pc parport pcspkr serio_raw i2c_i801
> i2c_core iTCO_wdt rng_core intel_agp agpgart squashfs sqlzma unlzma loop
> aufs exportfs nls_utf8 nls_cp437 ide_generic sd_mod ide_gd_mod
> ata_generic pata_acpi ata_piix piix ide_pci_generic ide_core skge sky2
> thermal_sys
> [ 1127.048879]
> 
> [ 1127.048879] Pid: 20150, comm: rndc Not tainted (2.6.28.10 #2)
> 
> [ 1127.048879] EIP: 0060:[<f808085a>] EFLAGS: 00010286 CPU: 0
> 
> [ 1127.048879] EIP is at sky2_mac_intr+0x22/0x9d [sky2]
> 
> [ 1127.048879] EAX: f80d8f88 EBX: 00000001 ECX: 00000008 EDX: 000000ff
> 
> [ 1127.048879] ESI: 00000000 EDI: f68c2a80 EBP: 00000080 ESP: eb83fb38
> 
> [ 1127.048879]  DS: 0068 ES: 0068 FS: 00d8 GS: 0000 SS: 0068
> 
> [ 1127.048879] Process rndc (pid: 20150, ti=eb83e000 task=f695bb00
> task.ti=eb83e000)
> 
> [ 1127.048879] Stack:
> 
> [ 1127.048879]  ff08340b f68c2a88 ffffffff ffffffff f712c000 f80839d6
> 00000040 f68c2a88
> 
> [ 1127.048879]  c0a78d54 f70344e0 f68c2a80 f695bb00 c0a78d54 c0a604e8
> c1d10980 c0a78d54
> 
> [ 1127.048879]  c0827013 00000000 0000000f 00000246 f70344e0 00000102
> c0be5180 c0832dc6
> 
> [ 1127.048879] Call Trace:
> 
> [ 1127.048879]  [<f80839d6>] sky2_poll+0x1cb/0xbed [sky2]
> 
> [ 1127.048879]  [<c0a604e8>] _spin_unlock_irqrestore+0x22/0x39
> 
> [ 1127.048879]  [<c0827013>] try_to_wake_up+0x158/0x162
> 
> [ 1127.048879]  [<c0832dc6>] process_timeout+0x0/0x5
> 
> [ 1127.048879]  [<c09eda45>] net_rx_action+0xb8/0x1f6
> 
> [ 1127.048879]  [<c082f954>] __do_softirq+0x95/0x142
> 
> [ 1127.048879]  [<c082fa49>] do_softirq+0x48/0x57
> 
> [ 1127.048879]  [<c082fbc9>] irq_exit+0x3b/0x78
> 
> [ 1127.048879]  [<c081218f>] smp_apic_timer_interrupt+0x75/0x7f
> 
> [ 1127.048879]  [<c0804f48>] apic_timer_interrupt+0x28/0x30
> 
> [ 1127.048879]  [<c0867764>] get_page_from_freelist+0x2b8/0x3df
> 
> [ 1127.048879]  [<c0867ae0>] __alloc_pages_internal+0x98/0x37f
> 
> [ 1127.048879]  [<c0862ee0>] find_lock_page+0x10/0x43
> 
> [ 1127.048879]  [<c0a60555>] _spin_unlock+0x10/0x23
> 
> [ 1127.048879]  [<c086fb70>] __do_fault+0xaa/0x3bc
> 
> [ 1127.048879]  [<c08718e1>] handle_mm_fault+0x54a/0xbfa
> 
> [ 1127.048879]  [<c0a60555>] _spin_unlock+0x10/0x23
> 
> [ 1127.048879]  [<c089442d>] __d_lookup+0xfa/0x116
> 
> [ 1127.048879]  [<c088cb78>] do_lookup+0x53/0x153
> 
> [ 1127.048879]  [<c0893375>] dput+0x16/0xfc
> 
> [ 1127.048879]  [<c088eb25>] __link_path_walk+0xb01/0xbfb
> 
> [ 1127.048879]  [<c0a60555>] _spin_unlock+0x10/0x23
> 
> [ 1127.048879]  [<c086f05e>] kmap_high+0x17c/0x186
> 
> [ 1127.048879]  [<c0819b76>] default_spin_lock_flags+0x5/0x7
> 
> [ 1127.048879]  [<c081a64b>] do_page_fault+0x335/0x86e
> 
> [ 1127.048879]  [<c0a60555>] _spin_unlock+0x10/0x23
> 
> [ 1127.048879]  [<c0870a91>] unmap_vmas+0x498/0x6ab
> 
> [ 1127.048879]  [<c087321e>] free_pgtables+0x7d/0x93
> 
> [ 1127.048879]  [<c086d42e>] vma_prio_tree_insert+0x17/0x7f
> 
> [ 1127.048879]  [<c0874a45>] vma_link+0x51/0x73
> 
> [ 1127.048879]  [<c0a60555>] _spin_unlock+0x10/0x23
> 
> [ 1127.048879]  [<c0874a5f>] vma_link+0x6b/0x73
> 
> [ 1127.048879]  [<c08763b8>] mmap_region+0x475/0x58c
> 
> [ 1127.048879]  [<c08767a4>] do_mmap_pgoff+0x2d5/0x326
> 
> [ 1127.048879]  [<c08081db>] sys_mmap2+0x62/0x77
> 
> [ 1127.048879]  [<c08081e9>] sys_mmap2+0x70/0x77
> 
> [ 1127.048879]  [<c081a316>] do_page_fault+0x0/0x86e
> 
> [ 1127.048879]  [<c0a60805>] error_code+0x75/0x80
> 
> [ 1127.048879] Code: c0 83 c4 14 5b 5e 5f 5d c3 55 89 d5 57 89 c7 56 53
> 89 d3 c1 e5 07 83 ec 04 8b 74 90 30 8d 85 08 0f 00 00 03 07 8a 10 88 54
> 24 03 <f6> 86 0d 05 00 00 02 74 12 0f b6 c2 50 56 68 84 5b 08 f8 e8 cd
> 
> [ 1127.048879] EIP: [<f808085a>] sky2_mac_intr+0x22/0x9d [sky2] SS:ESP
> 0068:eb83fb38
> 
> [ 1127.470534] Kernel panic - not syncing: Fatal exception in interrupt
> 
> [ 1127.478035] Rebooting in 30 seconds..
> 
> 
> 
> It seems that the oops occurs when the last network interface using the
> sky2 module goes down, although I am not completely certain about this.
> I am also fairly sure that the other patches applied to 2.6.28.10 are
> not at fault, as the same kernel works perfectly well on different
> hardware (which is not using the sky2 NIC module).
> 
> Attached are the lspci -v output and the kernel config.
> 
> Any hints on what may be wrong would be highly appreciated. I am able to
> try patches to sky2 and/or give remote ssh access to the box (although
> it will be offline for 5 minutes after triggering the oops...).

Try later kernels.  


-- 
