From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Regression in skge that started around acb42a3 (so past v3.3-rc1)
Date: Mon, 30 Jan 2012 10:58:16 -0500
Message-ID: <20120130155816.GA1400@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: shemminger@vyatta.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I hadn't done any git bisection yet, but with acb42a3 I started getting this:

(and only on i686 - x86_64 does not show these):

(This is with Xen, the other one is without)
[   28.602121] eth2: no IPv6 routers present
[   70.457712] eth2: hw csum failure.
[   70.458695] Pid: 0, comm: swapper/0 Not tainted 3.3.0-rc1-00287-gacb42a3 #1
[   70.
[   70.458695]  [<c140942b>] __skb_checksum_complete+0xb/0x10
[   70.458695]  [<c148e3b0>] nf_ip_checksum+0x60/0x120
[   70.458695]  [<c143ee6b>] udp_error+0xbb/0x1f0
[   70.458695]  [<c103c1e4>] ? check_events+0x8/0xc
[   70.458695]  [<c103c1db>] ? xen_restore_fl_direct_reloc+0x4/0x4
[   70.458695]  [<c11497ee>] ? put_cpu_partial+0x9e/0xb0
[   70.458695]  [<c143edb0>] ? udp_pkt_to_tuple+0x60/0x60
[   70.458695]  [<c143a2b6>] nf_conntrack_in+0xc6/0x5c0
[   70.458695]  [<c14751f8>] ? __udp4_lib_rcv+0x428/0x630
[   70.458695]  [<c1149dd0>] ? kfree+0xf0/0x120
[   70.458695]  [<c1405b60>] ? skb_release_data+0x90/0xb0
[   70.458695]  [<c1405b60>] ? skb_release_data+0x90/0xb0
[   70.458695]  [<c14057d8>] ? __kfree_skb+0x38/0x90
[   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
[   70.458695]  [<c148f41e>] ipv4_conntrack_in+0x1e/0x30
[   70.458695]  [<c14360d3>] nf_iterate+0x63/0x90
[   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
[   70.458695]  [<c1436292>] nf_hook_slow+0x62/0x140
[   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
[   70.458695]  [<c144dbb5>] ip_rcv+0x235/0x310
[   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
[   70.458695]  [<c1412c36>] __netif_receive_skb+0x1d6/0x550
[   70.458695]  [<c147c6a9>] ? inet_gro_receive+0x59/0x1f0
[   70.458695]  [<c1413312>] netif_receive_skb+0x22/0x90
[   70.458695]  [<c1413487>] napi_skb_finish+0x37/0x50
[   70.458695]  [<c14139e3>] napi_gro_receive+0xe3/0xf0
[   70.458695]  [<c12ff4c0>] ? xen_swiotlb_map_sg+0x20/0x20
[   70.458695]  [<c12ff4d9>] ? xen_swiotlb_unmap_page+0x19/0x20
[   70.458695]  [<f7983d6c>] skge_poll+0x34c/0x6f4 [skge]
[   70.458695]  [<c141431a>] net_rx_action+0xfa/0x2a0
[   70.458695]  [<c107cecf>] __do_softirq+0x9f/0x210
[   70.458695]  [<c107ce30>] ? irq_exit+0xd0/0xd0
[   70.458695]  <IRQ>  [<c107ce15>] ? irq_exit+0xb5/0xd0
[   70.458695]  [<c12f4ac0>] ? xen_evtchn_do_upcall+0x20/0x30
[   70.458695]  [<c153b157>] ? xen_do_upcall+0x7/0xc
[   70.458695]  [<c10023a7>] ? hypercall_page+0x3a7/0x1000
[   70.458695]  [<c103b802>] ? xen_safe_halt+0x12/0x20
[   70.458695]  [<c104c53d>] ? default_idle+0xfd/0x200
[   70.458695]  [<c103c1db>] ? xen_restore_fl_direct_reloc+0x4/0x4
[   70.458695]  [<c1043fd8>] ? cpu_idle+0xa8/0xf0
[   70.458695]  [<c151658b>] ? rest_init+0x7b/0x80
[   70.458695]  [<c16f886d>] ? start_kernel+0x348/0x34e
[   70.458695]  [<c16f834f>] ? kernel_init+0x149/0x149
[   70.458695]  [<c16f80ba>] ? i386_start_kernel+0xa9/0xb0
[   70.458695]  [<c16fb3b1>] ? xen_start_kernel+0x5f2/0x5fa
[   70.458695]  [<c1409076>] ? memcpy_fromiovecend+0x76/0x80
^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G^G failed.
[FAILED]

which now look like this:

[  288.735236] IP: [<c127b1aa>] memcpy+0x1a/0x0a4f001 *pde = 0000000000000000 
[  288.735236] Oops: 0000 [#1] PREEMPT SMP 
[  288.751724] Modules linked in: dm_multipath dm_mod iscsi_boot_sysfs iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi libcrc32c crc32c sg sd_mod ata_generic sata_nv nouveau fbcon tileblit font bitblit e1000 softcursor ttm libata skge drm_kms_helper mxm_wmi video wmi scsi_mod [last unloaded: dump_dma]
[  288.751724] 
[  288.751724] Pid: 0, comm: swapper/0 Tainted: G           O 3.3.0-rc1-00383-g0a96265 #1 BIOSTAR Group N61PB-M2S/N61PB-M2S
[  288.751724] EIP: 0060:[<c127b1aa>] EFLAGS: 00010217 CPU: 0
[  288.751724] EIP is at memcpy+0x1a/0x40
[  288.751724] EAX: f0a11040 EBX: 00000062 ECX: 00000018 EDX: 00000000
[  288.751724] ESI: 00000000 EDI: f0a11040 EBP: f100bf2c ESP: f100bf20
[  288.751724]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  288.751724] Process swapper/0 (pid: 0, ti=f100a000 task=c16b1020 task.ti=c16aa000)
[  288.751724] Stack:
[  288.751724]  f1297c00 f1086144 f762dd80 f100bf88 f8449ccb 39e70110 00000043 39e70110
[  288.751724]  00000043 00000000 c176b140 00000002 f100bf98 f0991d80 f1297c00 f11c4060
[  288.751724]  ffff0000 00000040 f1297c08 f1297800 00000000 00000000 00000062 f1297c08
[  288.751724] Call Trace:
[  288.751724]  [<f8449ccb>] skge_poll+0x2ab/0x6f4 [skge]
[  288.751724]  [<c1413dba>] net_rx_action+0xfa/0x2a0
[  288.751724]  [<c107cecf>] __do_softirq+0x9f/0x210
[  288.751724]  [<c107ce30>] ? irq_exit+0xd0/0xd0
[  288.751724]  <IRQ> 
[  288.751724]  [<c107ce15>] ? irq_exit+0xb5/0xd0
[  288.751724]  [<c1045e06>] ? do_IRQ+0x46/0xb0
[  288.751724]  [<c107cdc1>] ? irq_exit+0x61/0xd0
[  288.751724]  [<c105fb23>] ? smp_apic_timer_interrupt+0x53/0x90
[  288.751724]  [<c153abb0>] ? common_interrupt+0x30/0x38
[  288.751724]  [<c10685f5>] ? native_safe_halt+0x5/0x10
[  288.751724]  [<c104c53d>] ? default_idle+0xfd/0x200
[  288.751724]  [<c104c68c>] ? amd_e400_idle+0x4c/0x100
[  288.751724]  [<c1043fd8>] ? cpu_idle+0xa8/0xf0
[  288.751724]  [<c151602b>] ? rest_init+0x7b/0x80
[  288.751724]  [<c16f686d>] ? start_kernel+0x348/0x34e
[  288.751724]  [<c16f634f>] ? kernel_init+0x149/0x149
[  288.751724]  [<c16f60ba>] ? i386_start_kernel+0xa9/0xb0
[  288.751724] Code: c6 43 4c 04 88 43 4d 8b 1c 24 89 ec 5d c3 90 90 90 55 89 e5 83 ec 0c 89 1c 24 89 cb 89 74 24 04 c1 e9 02 89 d6 89 7c 24 08 89 c7 <f3> a5 89 d9 83 e1 03 74 02 f3 a4 8b 1c 24 8b 74 24 04 8b 7c 24 
[  288.751724] EIP: [<c127b1aa>] memcpy+0x1a/0x40 SS:ESP 0068:f100bf20
[  288.751724] CR2: 0000000000000000
[  288.972094] ---[ end trace dca3e5f32515fe5d ]---
[  288.976724] Kernel panic - not syncing: Fatal exception in interrupt
[  288.983094] panic occurred, switching back to text console

Any thoughts on which patch might be the culprit?
