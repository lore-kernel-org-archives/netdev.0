From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: Kernel panic when using bridge
Date: Fri, 08 Apr 2011 23:51:10 -0500
Message-ID: <4D9FE5BE.6060600@scotdoyle.com>
References: <4D9E62D9.5010400@scotdoyle.com> <20110408121700.0aad53fe@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:37225 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab1DIEvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2011 00:51:13 -0400
In-Reply-To: <20110408121700.0aad53fe@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2011 02:17 PM, Stephen Hemminger wrote:
> Please reproduce with exactly 2.6.39-rc2 there were some bug fixes
> to make sure that header was initialized.

Hi Stephen, here's another panic with 2.6.39-rc2 (git commit 
bb3c90f0de7b34995b5e35cf5dc97a3d428b3761) using default kernel config 
options.

# sysctl -a | grep bridge
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-filter-vlan-tagged = 0
net.bridge.bridge-nf-filter-pppoe-tagged = 0

# /etc/network/interfaces
auto lo
iface lo inet loopback
auto br0
iface br0 inet static
     address x.y.z.237
     netmask 255.255.255.224
     gateway x.y.z.225
     bridge_ports    eth3
     bridge_stp    off
     bridge_maxwait    0
     bridge_fd    0
auto br0:1
iface br0:1 inet static
     address 10.0.0.1
     netmask 255.255.255.0
auto br0:2
iface br0:2 inet static
     address 10.0.1.1
     netmask 255.255.255.0

------

[ 1691.681069] BUG: unable to handle kernel NULL pointer dereference at 
00000000000000cc
[ 1691.688879] IP: [<ffffffff8129fb8d>] ip_options_compile+0x1c1/0x435
[ 1691.695126] PGD 0
[ 1691.697131] Oops: 0000 [#1] SMP
[ 1691.700357] last sysfs file: /sys/devices/virtual/misc/kvm/uevent
[ 1691.706418] CPU 0
[ 1691.708241] Modules linked in: kvm_intel kvm bridge stp loop snd_pcm 
snd_timer snd soundcore snd_page_alloc tpm_tis i7core_edac psmouse ghes 
tpm evdev edac_core pcspkr serio_raw processor tpm_bios button dcdbas 
thermal_sys hed power_meter ext2 mbcache dm_mod raid1 md_mod sd_mod 
crc_t10dif usb_storage uas uhci_hcd mpt2sas scsi_transport_sas 
raid_class ehci_hcd igb scsi_mod usbcore dca bnx2 [last unloaded: 
scsi_wait_scan]
[ 1691.745849]
[ 1691.747330] Pid: 0, comm: swapper Not tainted 2.6.39-rc2+ #3 Dell 
Inc. PowerEdge R510/0DPRKF
[ 1691.755752] RIP: 0010:[<ffffffff8129fb8d>]  [<ffffffff8129fb8d>] 
ip_options_compile+0x1c1/0x435
[ 1691.764418] RSP: 0018:ffff88042f203af0  EFLAGS: 00010286
[ 1691.769702] RAX: 0000000000000024 RBX: ffff88041c9fa900 RCX: 
ffff880403466865
[ 1691.776800] RDX: 0000000000000027 RSI: 0000000000000000 RDI: 
ffffffff817e6100
[ 1691.783899] RBP: ffff880403466863 R08: ffffffffa01ade89 R09: 
ffff88042f203c58
[ 1691.790997] R10: ffffe1c4ff103b40 R11: 0000000000000004 R12: 
ffff88041c9fa928
[ 1691.798095] R13: 0000000000000027 R14: ffff88040346684e R15: 
0000000000000027
[ 1691.805194] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[ 1691.813245] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1691.818960] CR2: 00000000000000cc CR3: 0000000001603000 CR4: 
00000000000006f0
[ 1691.826058] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 1691.833156] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 1691.840254] Process swapper (pid: 0, threadinfo ffffffff81600000, 
task ffffffff8160b020)
[ 1691.848303] Stack:
[ 1691.850300]  ffff88042ec02900 ffff8804051ac740 0000000000000000 
ffffffff817e6100
[ 1691.857693]  0000000000000282 ffffffff810ec848 0000000000000282 
ffff88041c9fa928
[ 1691.865085]  ffff88041c9fa900 ffff8804038e8000 ffff88040346684e 
ffff8804038e8000
[ 1691.872480] Call Trace:
[ 1691.874910] <IRQ>
[ 1691.877005]  [<ffffffff810ec848>] ? __slab_free+0x80/0x14a
[ 1691.882465]  [<ffffffffa01b1e3a>] ? br_parse_ip_options+0x133/0x1a0 
[bridge]
[ 1691.889480]  [<ffffffffa01b2bd8>] ? br_nf_pre_routing+0x348/0x3cb 
[bridge]
[ 1691.896324]  [<ffffffff8119d88f>] ? cpumask_next_and+0x2b/0x3a
[ 1691.902127]  [<ffffffff81298517>] ? nf_iterate+0x41/0x7e
[ 1691.907413]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[ 1691.913908]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[ 1691.920402]  [<ffffffff812985c7>] ? nf_hook_slow+0x73/0x114
[ 1691.925947]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[ 1691.932442]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[ 1691.938937]  [<ffffffffa01ade6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
[ 1691.945432]  [<ffffffff810ee373>] ? 
__kmalloc_node_track_caller+0xd4/0x10d
[ 1691.952274]  [<ffffffffa01ae1e5>] ? br_handle_frame+0x195/0x1ac [bridge]
[ 1691.958942]  [<ffffffffa01ae050>] ? 
br_handle_frame_finish+0x1c7/0x1c7 [bridge]
[ 1691.966217]  [<ffffffff812764df>] ? __netif_receive_skb+0x2a7/0x450
[ 1691.972452]  [<ffffffff81276918>] ? netif_receive_skb+0x52/0x58
[ 1691.978340]  [<ffffffff81276e1a>] ? napi_gro_receive+0x1f/0x2f
[ 1691.984143]  [<ffffffff812769ef>] ? napi_skb_finish+0x1c/0x31
[ 1691.989862]  [<ffffffffa0226fcd>] ? igb_poll+0x6d9/0x9ee [igb]
[ 1691.995666]  [<ffffffff8103eb92>] ? try_to_wake_up+0x16a/0x17c
[ 1692.001470]  [<ffffffff8109034f>] ? handle_irq_event+0x40/0x55
[ 1692.007275]  [<ffffffff8106fc3c>] ? arch_local_irq_save+0x14/0x1d
[ 1692.013338]  [<ffffffff81276f45>] ? net_rx_action+0xa4/0x1b1
[ 1692.018971]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
[ 1692.024516]  [<ffffffff81333b5c>] ? call_softirq+0x1c/0x30
[ 1692.029973]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[ 1692.035257]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
[ 1692.040368]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[ 1692.045308]  [<ffffffff8132cad3>] ? common_interrupt+0x13/0x13
[ 1692.051110] <EOI>
[ 1692.053204]  [<ffffffff81061348>] ? enqueue_hrtimer+0x3f/0x53
[ 1692.058922]  [<ffffffffa032c417>] ? arch_local_irq_enable+0x7/0x8 
[processor]
[ 1692.066021]  [<ffffffffa032cfdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[ 1692.073208]  [<ffffffff8125df49>] ? menu_select+0x169/0x296
[ 1692.078752]  [<ffffffff8125d059>] ? cpuidle_idle_call+0xf4/0x17e
[ 1692.084727]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[ 1692.089838]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[ 1692.095469]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 1692.101703] Code: 4d 02 3c 03 0f 86 59 02 00 00 0f b6 d0 44 39 ea 7f 
32 83 c2 03 44 39 ea 0f 8f 45 02 00 00 48 85 db 74 18 48 8b 74 24 10 0f 
b6 c0 <8b> 96 cc 00 00 00 89 54 05 ff 41 80 4c 24 08 04 80 01 04 41 80
[ 1692.121051] RIP  [<ffffffff8129fb8d>] ip_options_compile+0x1c1/0x435
[ 1692.127382]  RSP <ffff88042f203af0>
[ 1692.130850] CR2: 00000000000000cc
[ 1692.134470] ---[ end trace 0afda543b32ed72b ]---
[ 1692.139064] BUG: scheduling while atomic: swapper/0/0x10000100
[ 1692.144866] Modules linked in: kvm_intel kvm bridge stp loop snd_pcm 
snd_timer snd soundcore snd_page_alloc tpm_tis i7core_edac psmouse ghes 
tpm evdev edac_core pcspkr serio_raw processor tpm_bios button dcdbas 
thermal_sys hed power_meter ext2 mbcache dm_mod raid1 md_mod sd_mod 
crc_t10dif usb_storage uas uhci_hcd mpt2sas scsi_transport_sas 
raid_class ehci_hcd igb scsi_mod usbcore dca bnx2 [last unloaded: 
scsi_wait_scan]
[ 1692.182294] CPU 0
[ 1692.184119] Modules linked in: kvm_intel kvm bridge stp loop snd_pcm 
snd_timer snd soundcore snd_page_alloc tpm_tis i7core_edac psmouse ghes 
tpm evdev edac_core pcspkr serio_raw processor tpm_bios button dcdbas 
thermal_sys hed power_meter ext2 mbcache dm_mod raid1 md_mod sd_mod 
crc_t10dif usb_storage uas uhci_hcd mpt2sas scsi_transport_sas 
raid_class ehci_hcd igb scsi_mod usbcore dca bnx2 [last unloaded: 
scsi_wait_scan]
[ 1692.221718]
[ 1692.223199] Pid: 0, comm: swapper Tainted: G      D     2.6.39-rc2+ 
#3 Dell Inc. PowerEdge R510/0DPRKF
[ 1692.232487] RIP: 0010:[<ffffffffa032c417>]  [<ffffffffa032c417>] 
arch_local_irq_enable+0x7/0x8 [processor]
[ 1692.242105] RSP: 0018:ffffffff81601eb0  EFLAGS: 00000292
[ 1692.247389] RAX: 000000000003fce5 RBX: ffffffff81061348 RCX: 
00000000000003e8
[ 1692.254489] RDX: 00000000000000c5 RSI: 0000000225c17d03 RDI: 
000000000f93df4d
[ 1692.261588] RBP: ffff880405349800 R08: 00000000fffffffd R09: 
0000000000000000
[ 1692.268689] R10: ffff88042f210ac0 R11: 0000000000000040 R12: 
ffffffff8132cace
[ 1692.275790] R13: ffff88042f20feb0 R14: ffffffff811a2ed2 R15: 
ffff88042f20fdc8
[ 1692.282892] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[ 1692.290943] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1692.296660] CR2: 00000000000000cc CR3: 0000000001603000 CR4: 
00000000000006f0
[ 1692.303759] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 1692.310860] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 1692.317959] Process swapper (pid: 0, threadinfo ffffffff81600000, 
task ffffffff8160b020)
[ 1692.326010] Stack:
[ 1692.328008]  ffffffffa032cfdf 0000000000011140 ffffffff8125df49 
000000010005525f
[ 1692.335406]  ffff880405349820 ffff8804053498f0 0000000000000002 
ffffffffffffffff
[ 1692.342803]  ffffffff8125d059 0000000000000000 ffffffff81600000 
ffffffff816812d0
[ 1692.350197] Call Trace:
[ 1692.352630]  [<ffffffffa032cfdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[ 1692.359818]  [<ffffffff8125df49>] ? menu_select+0x169/0x296
[ 1692.365362]  [<ffffffff8125d059>] ? cpuidle_idle_call+0xf4/0x17e
[ 1692.371339]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[ 1692.376452]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[ 1692.382084]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[ 1692.388319] Code: 63 1c fb 48 83 c4 38 89 e8 5b 5d 41 5c 41 5d 41 5e 
41 5f c3 0f 09 0f 1f 44 00 00 c3 fa 66 0f 1f 44 00 00 c3 fb 66 0f 1f 44 
00 00 <c3> 48 8b 15 81 20 3f e1 48 8d 42 fd 48 83 f8 01 0f 96 c0 48 ff
[ 1692.407673] Call Trace:
[ 1692.410105]  [<ffffffffa032cfdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[ 1692.417294]  [<ffffffff8125df49>] ? menu_select+0x169/0x296
[ 1692.422838]  [<ffffffff8125d059>] ? cpuidle_idle_call+0xf4/0x17e
[ 1692.428815]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[ 1692.433928]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[ 1692.439560]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
^M
^GMessage from[ 1692.446160] BUG: unable to handle kernel NULL pointer 
dereference at 00000000000000e0
[ 1692.455313] IP: [<ffffffffa0226ca8>] igb_poll+0x3b4/0x9ee [igb]
[ 1692.461214] PGD 404c2e067 PUD 402966067 PMD 0
[ 1692.465660] Oops: 0000 [#2] SMP
[ 1692.468887] last sysfs file: /sys/devices/virtual/misc/kvm/uevent
[ 1692.474947] CPU 0
[ 1692.476772] Modules linked in: kvm_intel kvm bridge stp loop snd_pcm 
snd_timer snd soundcore snd_page_alloc tpm_tis i7core_edac psmouse ghes 
tpm evdev edac_core pcspkr serio_raw processor tpm_bios button dcdbas 
thermal_sys hed power_meter ext2 mbcache dm_mod raid1 md_mod sd_mod 
crc_t10dif usb_storage uas uhci_hcd mpt2sas scsi_transport_sas 
raid_class ehci_hcd igb scsi_mod usbcore dca bnx2 [last unloaded: 
scsi_wait_scan]
[ 1692.514362]
[ 1692.515843] Pid: 1740, comm: rsyslogd Tainted: G      D     
2.6.39-rc2+ #3 Dell Inc. PowerEdge R510/0DPRKF
[ 1692.525475] RIP: 0010:[<ffffffffa0226ca8>]  [<ffffffffa0226ca8>] 
igb_poll+0x3b4/0x9ee [igb]
[ 1692.533796] RSP: 0018:ffff880403081b90  EFLAGS: 00010203
[ 1692.539078] RAX: ffff880404f24e58 RBX: ffff880404f25a40 RCX: 
0000000000000000
[ 1692.546176] RDX: 0000000000000040 RSI: 0000000000001043 RDI: 
ffff880404f24e58
[ 1692.553273] RBP: 0000000000000000 R08: 00000000f352249a R09: 
ffff88042f20f470
[ 1692.560373] R10: 0000000000000000 R11: 0000000000000293 R12: 
000000000000000c
[ 1692.567470] R13: ffffc9001267b320 R14: 0000000000000000 R15: 
ffff880403ff3140
[ 1692.574571] FS:  00007f4ce614f700(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[ 1692.582619] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1692.588334] CR2: 00000000000000e0 CR3: 0000000403c96000 CR4: 
00000000000006f0
[ 1692.595434] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 1692.602532] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 1692.609630] Process rsyslogd (pid: 1740, threadinfo ffff880403080000, 
task ffff880413b8a170)
[ 1692.618025] Stack:
[ 1692.620024]  0000000000000000 ffffffff8105b633 0000000000000082 
ffffffff8103eb92
[ 1692.627419]  ffffffff8132b45a 0000000000000082 0000000000000000 
000010431d887e00
[ 1692.634813]  0000000100000015 ffff880404f24e40 ffff880400000000 
ffff8804038e8740
[ 1692.642208] Call Trace:
[ 1692.644640]  [<ffffffff8105b633>] ? wq_worker_waking_up+0x8/0x20
[ 1692.650615]  [<ffffffff8103eb92>] ? try_to_wake_up+0x16a/0x17c
[ 1692.656418]  [<ffffffff8132b45a>] ? schedule+0x56e/0x585
[ 1692.661703]  [<ffffffff8132c775>] ? _raw_spin_lock_irq+0xd/0x1a
[ 1692.667592]  [<ffffffff81276f45>] ? net_rx_action+0xa4/0x1b1
[ 1692.673221]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
[ 1692.678765]  [<ffffffff81333b5c>] ? call_softirq+0x1c/0x30
[ 1692.684224]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[ 1692.689507]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
[ 1692.694618]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[ 1692.699556]  [<ffffffff8132cad3>] ? common_interrupt+0x13/0x13
[ 1692.705360]  [<ffffffff811439a0>] ? kmsg_poll+0x3a/0x3a
[ 1692.710559]  [<ffffffff81045ba5>] ? spin_unlock_irq.clone.1+0xe/0x10
[ 1692.716882]  [<ffffffff81045e01>] ? do_syslog+0x1e2/0x430
[ 1692.722253]  [<ffffffff811439e6>] ? kmsg_read+0x46/0x50
[ 1692.727451]  [<ffffffff8113aefa>] ? proc_reg_read+0x6f/0x88
[ 1692.732995]  [<ffffffff810f6868>] ? vfs_read+0x9f/0xf2
[ 1692.738106]  [<ffffffff810f6900>] ? sys_read+0x45/0x6b
[ 1692.743218]  [<ffffffff81332952>] ? system_call_fastpath+0x16/0x1b
[ 1692.749364] Code: 89 74 24 3c e9 78 03 00 00 8b 54 24 70 39 54 24 44 
0f 8d 75 03 00 00 ff 44 24 44 0f ae e8 49 8b 6d 00 ff 44 24 40 b9 00 00 
00 00
[ 1692.762725]  8b 85 e0 00 00 00 49 c7 45 00 00 00 00 00 41 8b 77 0c 0f 18
[ 1692.769844] RIP  [<ffffffffa0226ca8>] igb_poll+0x3b4/0x9ee [igb]
[ 1692.775829]  RSP <ffff880403081b90>
[ 1692.779295] CR2: 00000000000000e0
  syslogd@r510-1 [ 1692.782628] ---[ end trace 0afda543b32ed72c ]---
[ 1692.788575] BUG: scheduling while atomic: rsyslogd/1740/0x10000100
at Apr  8 20:34:[ 1692.794754] Modules linked in: kvm_intel04 ...^M
  kernel kvm bridge:[ 1691.697131]  stp loopOops: 0000 [#1]  snd_pcm 
snd_timerSMP
^M^M
^GMessa snd soundcorege from syslogd@ snd_page_alloc tpm_tisr510-1 at 
Apr  8 i7core_edac psmouse 20:34:04 ...^M
  ghes tpm kernel:[ 1691.7 evdev edac_core00357] last sysf pcspkr 
serio_raws file: /sys/dev processor tpm_biosices/virtual/mis button 
dcdbasc/kvm/uevent
^M^M thermal_sys hed
^GMessage from  power_meter ext2syslogd@r510-1 a mbcache dm_modt Apr  8 
20:34:0 raid1 md_mod4 ...^M
  kernel: sd_mod crc_t10dif[ 1691.848303] S usb_storage uastack:
^M^M
^GMess uhci_hcd mpt2sasage from syslogd scsi_transport_sas 
raid_class@r510-1 at Apr   ehci_hcd igb8 20:34:04 ...^M^M scsi_mod usbcore
  kernel:[ 1691. dca bnx2872480] Call Tra [last unloaded: scsi_wait_scan]
ce:
^M^M
^GMessag[ 1692.865388] CPU 0
[ 1692.868564] Modules linked in:e from syslogd@r kvm_intel kvm510-1 at 
Apr  8  bridge stp20:34:04 ...^M
   loop snd_pcmkernel:[ 1691.87 snd_timer snd4910] <IRQ>
^M soundcore snd_page_alloc tpm_tis i7core_edac psmouse ghes tpm evdev 
edac_core pcspkr serio_raw processor tpm_bios button dcdbas thermal_sys 
hed power_meter ext2 mbcache dm_mod raid1 md_mod sd_mod crc_t10dif 
usb_storage uas uhci_hcd mpt2sas scsi_transport_sas raid_class ehci_hcd 
igb scsi_mod usbcore dca bnx2 [last unloaded: scsi_wait_scan]
[ 1692.913092]
[ 1692.914574] Pid: 1740, comm: rsyslogd Tainted: G      D     
2.6.39-rc2+ #3 Dell Inc. PowerEdge R510/0DPRKF
[ 1692.924208] RIP: 0010:[<ffffffff81045ba5>]  [<ffffffff81045ba5>] 
spin_unlock_irq.clone.1+0xe/0x10
[ 1692.933051] RSP: 0018:ffff880403081e30  EFLAGS: 00000286
[ 1692.938336] RAX: 000000000001455c RBX: ffff880403afecc0 RCX: 
ffffffff817518a0
[ 1692.945435] RDX: 0000000000014520 RSI: 0000000000000003 RDI: 
ffffffff81751888
[ 1692.952536] RBP: 0000000000000fff R08: ffffffff811439a0 R09: 
0000000000000000
[ 1692.959636] R10: 0000000000000000 R11: 0000000000000293 R12: 
ffffffff8132cad3
[ 1692.966737] R13: 0000000000000e33 R14: 00007f4ce7983693 R15: 
ffff880403081da8
[ 1692.973837] FS:  00007f4ce614f700(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[ 1692.981890] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1692.987607] CR2: 00000000000000e0 CR3: 0000000403c96000 CR4: 
00000000000006f0
[ 1692.994706] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 1693.001805] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 1693.008907] Process rsyslogd (pid: 1740, threadinfo ffff880403080000, 
task ffff880413b8a170)
[ 1693.017303] Stack:
[ 1693.019301]  ffffffff81045e01 0000000003afed20 ffffffff00000020 
0000000000000000
[ 1693.026696]  0000000000000001 ffff880403081fd8 0000000000000000 
0002000003081e60
[ 1693.034093]  ffff880404f9b090 0000000100000000 00007f4ce7982860 
0000000000000fff
[ 1693.041490] Call Trace:
[ 1693.043922]  [<ffffffff81045e01>] ? do_syslog+0x1e2/0x430
[ 1693.049295]  [<ffffffff811439e6>] ? kmsg_read+0x46/0x50
[ 1693.054493]  [<ffffffff8113aefa>] ? proc_reg_read+0x6f/0x88
[ 1693.060039]  [<ffffffff810f6868>] ? vfs_read+0x9f/0xf2
[ 1693.065153]  [<ffffffff810f6900>] ? sys_read+0x45/0x6b
[ 1693.070266]  [<ffffffff81332952>] ? system_call_fastpath+0x16/0x1b
[ 1693.076415] Code: 00 00 75 14 c7 05 48 be 72 00 01 00 00 00 c7 05 42 
be 72 00 01 00 00 00 48 83 c4 08 c3 66 ff 05 ea bc 70 00 fb 66 0f 1f 44 
00 00 <c3> c3 48 83 ec 08 48 c7 c2 a8 38 61 81 48 c7 c6 3e 2b 4c 81 48
[ 1693.095772] Call Trace:
[ 1693.098205]  [<ffffffff81045e01>] ? do_syslog+0x1e2/0x430
[ 1693.103579]  [<ffffffff811439e6>] ? kmsg_read+0x46/0x50
[ 1693.108778]  [<ffffffff8113aefa>] ? proc_reg_read+0x6f/0x88
[ 1693.114323]  [<ffffffff810f6868>] ? vfs_read+0x9f/0xf2
[ 1693.119435]  [<ffffffff810f6900>] ? sys_read+0x45/0x6b
[ 1693.124547]  [<ffffffff81332952>] ? system_call_fastpath+0x16/0x1b
[ 1693.130704] Kernel panic - not syncing: Fatal exception in interrupt
[ 1693.137028] Pid: 1740, comm: rsyslogd Tainted: G      D     
2.6.39-rc2+ #3
[ 1693.143870] Call Trace:
[ 1693.146304]  [<ffffffff8132ac78>] ? panic+0x92/0x1a1
[ 1693.151244]  [<ffffffff8132d836>] ? oops_end+0xa9/0xb6
[ 1693.156359]  [<ffffffff8102ca16>] ? no_context+0x1ed/0x1fa
[ 1693.161819]  [<ffffffff8132f623>] ? do_page_fault+0x16b/0x308
[ 1693.167537]  [<ffffffff8132cd95>] ? page_fault+0x25/0x30
[ 1693.172824]  [<ffffffffa0226ca8>] ? igb_poll+0x3b4/0x9ee [igb]
[ 1693.178629]  [<ffffffff8105b633>] ? wq_worker_waking_up+0x8/0x20
[ 1693.184606]  [<ffffffff8103eb92>] ? try_to_wake_up+0x16a/0x17c
[ 1693.190410]  [<ffffffff8132b45a>] ? schedule+0x56e/0x585
[ 1693.195697]  [<ffffffff8132c775>] ? _raw_spin_lock_irq+0xd/0x1a
[ 1693.201588]  [<ffffffff81276f45>] ? net_rx_action+0xa4/0x1b1
[ 1693.207219]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
[ 1693.212764]  [<ffffffff81333b5c>] ? call_softirq+0x1c/0x30
[ 1693.218222]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[ 1693.223507]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
[ 1693.228619]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[ 1693.233560]  [<ffffffff8132cad3>] ? common_interrupt+0x13/0x13
[ 1693.239365]  [<ffffffff811439a0>] ? kmsg_poll+0x3a/0x3a
[ 1693.244564]  [<ffffffff81045ba5>] ? spin_unlock_irq.clone.1+0xe/0x10
[ 1693.250888]  [<ffffffff81045e01>] ? do_syslog+0x1e2/0x430
[ 1693.256259]  [<ffffffff811439e6>] ? kmsg_read+0x46/0x50
[ 1693.261459]  [<ffffffff8113aefa>] ? proc_reg_read+0x6f/0x88
[ 1693.267005]  [<ffffffff810f6868>] ? vfs_read+0x9f/0xf2
[ 1693.272117]  [<ffffffff810f6900>] ? sys_read+0x45/0x6b
[ 1693.277231]  [<ffffffff81332952>] ? system_call_fastpath+0x16/0x1b

