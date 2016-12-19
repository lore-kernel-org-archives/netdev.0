From: Shahar Klein <shahark@mellanox.com>
Subject: Re: Soft lockup in tc_classify
Date: Mon, 19 Dec 2016 18:39:17 +0200
Message-ID: <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com>
 <584EA60B.80803@iogearbox.net>
 <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com>
 <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="------------4A80CCDCA830F630058E70A5"
Cc: <shahark@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>,
        "Linux Netdev List" <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        "David Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "Daniel Borkmann" <daniel@iogearbox.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0075.outbound.protection.outlook.com ([104.47.2.75]:64160
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751713AbcLSUMe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 15:12:34 -0500
In-Reply-To: <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------4A80CCDCA830F630058E70A5
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit



On 12/13/2016 12:51 AM, Cong Wang wrote:
> On Mon, Dec 12, 2016 at 1:18 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Mon, Dec 12, 2016 at 3:28 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>
>>> Note that there's still the RCU fix missing for the deletion race that
>>> Cong will still send out, but you say that the only thing you do is to
>>> add a single rule, but no other operation in involved during that test?
>>
>> What's missing to have the deletion race fixed? making a patch or
>> testing to a patch which was sent?
>
> If you think it would help for this problem, here is my patch rebased
> on the latest net-next.
>
> Again, I don't see how it could help this case yet, especially I don't
> see how we could have a loop in this singly linked list.
>

I've applied cong's patch and hit a different lockup(full log attached):

[  264.725414] RIP: 0010:fl_classify+0x1f1/0x2b0 [cls_flower]

(gdb) list *(fl_classify+0x1f1)
0x1591 is in fl_classify (net/sched/cls_flower.c:187).
182		if (f && !tc_skip_sw(f->flags)) {
183			*res = f->res;
184			return tcf_exts_exec(skb, &f->exts, res);
185		}
186		return -1;
187	}
188	
189	static int fl_init(struct tcf_proto *tp)
190	{
191		struct cls_fl_head *head;
(gdb)

Daniel suggested I'll add a print:
                 case RTM_DELTFILTER:
-                   err = tp->ops->delete(tp, fh);
+                 printk(KERN_ERR "DEBUGG:SK %s:%d\n", __func__, __LINE__);
+                 err = tp->ops->delete(tp, fh, &last);
                         if (err == 0) {

and I couldn't see this print in the output.....





--------------4A80CCDCA830F630058E70A5
Content-Type: text/plain; charset="UTF-8"; name="lockup_with_congs_patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="lockup_with_congs_patch"

[  238.507670] GACT probability on
[  264.573942] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [mod=
probe:4867]
[  264.582875] Modules linked in: act_gact act_mirred openvswitch nf_conn=
track_ipv6 nf_nat_ipv6 nf_defrag_ipv6 vfio_pci vfio_virqfd vfio_iommu_typ=
e1 vfio cls_flower mlx5_ib mlx5_core devlink sch_ingress nfsv3 nfs fscach=
e xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptabl=
e_nat nf_nat_ipv4 nf_nat libcrc32c nf_conntrack_ipv4 nf_defrag_ipv4 xt_co=
nntrack nf_conntrack tun ebtable_filter ebtables ip6table_filter ip6_tabl=
es netconsole bridge stp llc rpcrdma ib_isert iscsi_target_mod ib_iser li=
biscsi scsi_transport_iscsi ib_srpt ib_srp scsi_transport_srp ib_ipoib rd=
ma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm intel_rapl sb_edac ed=
ac_core x86_pkg_temp_thermal coretemp kvm_intel kvm ib_core irqbypass crc=
t10dif_pclmul crc32_pclmul igb ptp iTCO_wdt pps_core crc32c_intel joydev =
i2c_algo_bit ghash_clmulni_intel iTCO_vendor_support pcspkr i2c_i801 mei_=
me ipmi_ssif ioatdma shpchp tpm_tis i2c_smbus tpm_tis_core dca tpm mei lp=
c_ich ipmi_si ipmi_msghandler wmi nfsd target_core_mod auth_rpcgss nfs_ac=
l lockd grace sunrpc isci libsas serio_raw scsi_transport_sas [last unloa=
ded: devlink]
[  264.703539] CPU: 0 PID: 4867 Comm: modprobe Not tainted 4.9.0+ #27
[  264.710766] Hardware name: Supermicro X9DRW/X9DRW, BIOS 3.0a 08/08/201=
3
[  264.718475] task: ffff89916ad09d80 task.stack: ffffa36f44510000
[  264.725414] RIP: 0010:fl_classify+0x1f1/0x2b0 [cls_flower]
[  264.731863] RSP: 0018:ffff89916fa03ad8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff10
[  264.740971] RAX: 00000000ffffffff RBX: ffff89913f522100 RCX: 000000000=
0000000
[  264.749265] RDX: ffff89916fa03c98 RSI: ffff89915bd743c0 RDI: ffff89913=
f522100
[  264.757558] RBP: ffff89916fa03c28 R08: 000000000000270f R09: 000000000=
0000000
[  264.765852] R10: 0000000000000000 R11: 0000000000000004 R12: ffff89916=
fa03c98
[  264.774144] R13: ffff89913ecc7c00 R14: ffff89915bd743c0 R15: 000000000=
0000001
[  264.782440] FS:  00007f74f2f5e700(0000) GS:ffff89916fa00000(0000) knlG=
S:0000000000000000
[  264.792066] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  264.798809] CR2: 00007f74f2491480 CR3: 000000043f3f8000 CR4: 000000000=
00426f0
[  264.807102] Call Trace:
[  264.810151]  <IRQ>
[  264.812717]  ? handle_edge_irq+0x87/0x130
[  264.817504]  ? handle_irq+0xab/0x130
[  264.821808]  ? irq_exit+0x77/0xe0
[  264.825828]  ? irq_exit+0x77/0xe0
[  264.829849]  ? do_IRQ+0x51/0xd0
[  264.833664]  ? common_interrupt+0x93/0x93
[  264.838462]  tc_classify+0x78/0x120
[  264.842679]  __netif_receive_skb_core+0x623/0xa00
[  264.848264]  ? udp4_gro_receive+0x10b/0x2d0
[  264.853253]  __netif_receive_skb+0x18/0x60
[  264.858150]  netif_receive_skb_internal+0x40/0xb0
[  264.863723]  napi_gro_receive+0xcd/0x120
[  264.868437]  mlx5e_handle_rx_cqe_rep+0x61b/0x890 [mlx5_core]
[  264.875105]  ? kvm_irq_delivery_to_apic+0x2c0/0x2c0 [kvm]
[  264.881462]  mlx5e_poll_rx_cq+0x83/0x840 [mlx5_core]
[  264.887333]  mlx5e_napi_poll+0x89/0x480 [mlx5_core]
[  264.893102]  net_rx_action+0x260/0x3c0
[  264.897610]  __do_softirq+0xc9/0x28c
[  264.901922]  irq_exit+0xd7/0xe0
[  264.905748]  do_IRQ+0x51/0xd0
[  264.909380]  common_interrupt+0x93/0x93
[  264.913984] RIP: 0010:mpihelp_submul_1+0x91/0xe0
[  264.919460] RSP: 0018:ffffa36f44513940 EFLAGS: 00000206 ORIG_RAX: ffff=
ffffffffffa2
[  264.928565] RAX: 5414d8fd4127cc59 RBX: 0000000100000000 RCX: fffffffff=
fffff50
[  264.936860] RDX: 00000000ffffffea RSI: 0000000019ba7e4d RDI: 000000006=
8ef6b86
[  264.945146] RBP: ffffa36f44513960 R08: 352cbbd4573982a8 R09: 645890191=
28fea22
[  264.953440] R10: 128fea2200000000 R11: 352cbbd5573982a8 R12: ffff89955=
c585c00
[  264.961732] R13: ffff899134dbfbd0 R14: 66a4c31fb80cf128 R15: d7554d389=
539f6c8
[  264.970028]  </IRQ>
[  264.972688]  mpihelp_divrem+0x23b/0x740
[  264.977291]  mpi_powm+0x471/0xa10
[  264.981312]  rsa_verify+0xa5/0x130
[  264.985421]  pkcs1pad_verify+0xb9/0xf0
[  264.989925]  public_key_verify_signature+0x1f7/0x280
[  264.995790]  public_key_verify_signature_2+0x15/0x20
[  265.001656]  verify_signature+0x3c/0x50
[  265.006259]  pkcs7_validate_trust+0xa1/0x200
[  265.011352]  verify_pkcs7_signature+0x9a/0x140
[  265.016636]  mod_verify_sig+0x92/0xe0
[  265.021046]  load_module+0x171/0x2810
[  265.025456]  ? vfs_read+0x113/0x130
[  265.029668]  ? kernel_read_file+0x158/0x190
[  265.034659]  ? kernel_read_file_from_fd+0x49/0x80
[  265.040248]  SYSC_finit_module+0xa6/0xf0
[  265.044947]  SyS_finit_module+0xe/0x10
[  265.049452]  entry_SYSCALL_64_fastpath+0x1a/0xa9
[  265.054931] RIP: 0033:0x7f74f2439239
[  265.059241] RSP: 002b:00007ffeb8b23218 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000139
[  265.068373] RAX: ffffffffffffffda RBX: 00007ffeb8b21f10 RCX: 00007f74f=
2439239
[  265.076665] RDX: 0000000000000000 RSI: 00005578b61d02a6 RDI: 000000000=
0000000
[  265.084958] RBP: 00007ffeb8b21f00 R08: 0000000000000000 R09: 000000000=
0000000
[  265.098996] R10: 0000000000000000 R11: 0000000000000246 R12: 00005578b=
61d1be7
[  265.107289] R13: 00007ffeb8b22088 R14: 0000000000000000 R15: 00005578b=
61d1bf3
[  265.115582] Code: 02 75 e2 48 8b 81 98 00 00 00 48 8b 91 a0 00 00 00 4=
8 8b 7c 24 18 48 89 07 48 89 57 08 8b 81 84 00 00 00 85 c0 0f 85 86 00 00=
 00 <48> 8b 9c 24 20 01 00 00 65 48 33 1c 25 28 00 00 00 0f 85 a1 00=20
[  265.143394] Kernel panic - not syncing: softlockup: hung tasks
[  265.150231] CPU: 0 PID: 4867 Comm: modprobe Tainted: G             L  =
4.9.0+ #27
[  265.159057] Hardware name: Supermicro X9DRW/X9DRW, BIOS 3.0a 08/08/201=
3
[  265.166766] Call Trace:
[  265.169811]  <IRQ>
[  265.172374]  dump_stack+0x63/0x8c
[  265.176393]  panic+0xeb/0x239
[  265.180047]  watchdog_timer_fn+0x1e5/0x1f0
[  265.184941]  ? watchdog+0x40/0x40
[  265.188960]  __hrtimer_run_queues+0xee/0x270
[  265.194050]  hrtimer_interrupt+0xa8/0x190
[  265.198849]  local_apic_timer_interrupt+0x35/0x60
[  265.204422]  smp_apic_timer_interrupt+0x38/0x50
[  265.209802]  apic_timer_interrupt+0x93/0xa0
[  265.214794] RIP: 0010:fl_classify+0x1f1/0x2b0 [cls_flower]
[  265.221242] RSP: 0018:ffff89916fa03ad8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff10
[  265.230339] RAX: 00000000ffffffff RBX: ffff89913f522100 RCX: 000000000=
0000000
[  265.238635] RDX: ffff89916fa03c98 RSI: ffff89915bd743c0 RDI: ffff89913=
f522100
[  265.246929] RBP: ffff89916fa03c28 R08: 000000000000270f R09: 000000000=
0000000
[  265.255223] R10: 0000000000000000 R11: 0000000000000004 R12: ffff89916=
fa03c98
[  265.263516] R13: ffff89913ecc7c00 R14: ffff89915bd743c0 R15: 000000000=
0000001
[  265.271812]  ? handle_edge_irq+0x87/0x130
[  265.276599]  ? handle_irq+0xab/0x130
[  265.280902]  ? irq_exit+0x77/0xe0
[  265.284911]  ? irq_exit+0x77/0xe0
[  265.288927]  ? do_IRQ+0x51/0xd0
[  265.292752]  ? common_interrupt+0x93/0x93
[  265.297549]  tc_classify+0x78/0x120
[  265.301762]  __netif_receive_skb_core+0x623/0xa00
[  265.307336]  ? udp4_gro_receive+0x10b/0x2d0
[  265.312328]  __netif_receive_skb+0x18/0x60
[  265.317221]  netif_receive_skb_internal+0x40/0xb0
[  265.322795]  napi_gro_receive+0xcd/0x120
[  265.327502]  mlx5e_handle_rx_cqe_rep+0x61b/0x890 [mlx5_core]
[  265.334153]  ? kvm_irq_delivery_to_apic+0x2c0/0x2c0 [kvm]
[  265.340510]  mlx5e_poll_rx_cq+0x83/0x840 [mlx5_core]
[  265.346379]  mlx5e_napi_poll+0x89/0x480 [mlx5_core]
[  265.352170]  net_rx_action+0x260/0x3c0
[  265.356675]  __do_softirq+0xc9/0x28c
[  265.360987]  irq_exit+0xd7/0xe0
[  265.364814]  do_IRQ+0x51/0xd0
[  265.368440]  common_interrupt+0x93/0x93
[  265.373041] RIP: 0010:mpihelp_submul_1+0x91/0xe0
[  265.378516] RSP: 0018:ffffa36f44513940 EFLAGS: 00000206 ORIG_RAX: ffff=
ffffffffffa2
[  265.387614] RAX: 5414d8fd4127cc59 RBX: 0000000100000000 RCX: fffffffff=
fffff50
[  265.395921] RDX: 00000000ffffffea RSI: 0000000019ba7e4d RDI: 000000006=
8ef6b86
[  265.404235] RBP: ffffa36f44513960 R08: 352cbbd4573982a8 R09: 645890191=
28fea22
[  265.412526] R10: 128fea2200000000 R11: 352cbbd5573982a8 R12: ffff89955=
c585c00
[  265.420819] R13: ffff899134dbfbd0 R14: 66a4c31fb80cf128 R15: d7554d389=
539f6c8
[  265.429113]  </IRQ>
[  265.431769]  mpihelp_divrem+0x23b/0x740
[  265.436373]  mpi_powm+0x471/0xa10
[  265.440394]  rsa_verify+0xa5/0x130
[  265.444508]  pkcs1pad_verify+0xb9/0xf0
[  265.449014]  public_key_verify_signature+0x1f7/0x280
[  265.454878]  public_key_verify_signature_2+0x15/0x20
[  265.460741]  verify_signature+0x3c/0x50
[  265.465343]  pkcs7_validate_trust+0xa1/0x200
[  265.470430]  verify_pkcs7_signature+0x9a/0x140
[  265.475715]  mod_verify_sig+0x92/0xe0
[  265.480147]  load_module+0x171/0x2810
[  265.484555]  ? vfs_read+0x113/0x130
[  265.488758]  ? kernel_read_file+0x158/0x190
[  265.493751]  ? kernel_read_file_from_fd+0x49/0x80
[  265.499328]  SYSC_finit_module+0xa6/0xf0
[  265.504051]  SyS_finit_module+0xe/0x10
[  265.508555]  entry_SYSCALL_64_fastpath+0x1a/0xa9
[  265.514030] RIP: 0033:0x7f74f2439239
[  265.518340] RSP: 002b:00007ffeb8b23218 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000139
[  265.527446] RAX: ffffffffffffffda RBX: 00007ffeb8b21f10 RCX: 00007f74f=
2439239
[  265.535740] RDX: 0000000000000000 RSI: 00005578b61d02a6 RDI: 000000000=
0000000
[  265.544056] RBP: 00007ffeb8b21f00 R08: 0000000000000000 R09: 000000000=
0000000
[  265.552354] R10: 0000000000000000 R11: 0000000000000246 R12: 00005578b=
61d1be7
[  265.560648] R13: 00007ffeb8b22088 R14: 0000000000000000 R15: 00005578b=
61d1bf3
[  265.568994] Kernel Offset: 0x3b000000 from 0xffffffff81000000 (relocat=
ion range: 0xffffffff80000000-0xffffffffbfffffff)
[  266.845267] ---[ end Kernel panic - not syncing: softlockup: hung task=
s
[  266.853000] ------------[ cut here ]------------
[  266.858490] WARNING: CPU: 0 PID: 4867 at arch/x86/kernel/smp.c:127 nat=
ive_smp_send_reschedule+0x3f/0x50
[  266.869551] Modules linked in: act_gact act_mirred openvswitch nf_conn=
track_ipv6 nf_nat_ipv6 nf_defrag_ipv6 vfio_pci vfio_virqfd vfio_iommu_typ=
e1 vfio cls_flower mlx5_ib mlx5_core devlink sch_ingress nfsv3 nfs fscach=
e xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptabl=
e_nat nf_nat_ipv4 nf_nat libcrc32c nf_conntrack_ipv4 nf_defrag_ipv4 xt_co=
nntrack nf_conntrack tun ebtable_filter ebtables ip6table_filter ip6_tabl=
es netconsole bridge stp llc rpcrdma ib_isert iscsi_target_mod ib_iser li=
biscsi scsi_transport_iscsi ib_srpt ib_srp scsi_transport_srp ib_ipoib rd=
ma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm intel_rapl sb_edac ed=
ac_core x86_pkg_temp_thermal coretemp kvm_intel kvm ib_core irqbypass crc=
t10dif_pclmul crc32_pclmul igb ptp iTCO_wdt pps_core crc32c_intel joydev =
i2c_algo_bit ghash_clmulni_intel iTCO_vendor_support pcspkr i2c_i801 mei_=
me ipmi_ssif ioatdma shpchp tpm_tis i2c_smbus tpm_tis_core dca tpm mei lp=
c_ich ipmi_si ipmi_msghandler wmi nfsd target_core_mod auth_rpcgss nfs_ac=
l lockd grace sunrpc isci libsas serio_raw scsi_transport_sas [last unloa=
ded: devlink]
[  266.990566] CPU: 0 PID: 4867 Comm: modprobe Tainted: G             L  =
4.9.0+ #27
[  266.999401] Hardware name: Supermicro X9DRW/X9DRW, BIOS 3.0a 08/08/201=
3
[  267.007118] Call Trace:
[  267.010179]  <IRQ>
[  267.012748]  dump_stack+0x63/0x8c
[  267.016783]  __warn+0xd1/0xf0
[  267.020420]  warn_slowpath_null+0x1d/0x20
[  267.025314]  native_smp_send_reschedule+0x3f/0x50
[  267.030895]  try_to_wake_up+0x312/0x390
[  267.035501]  wake_up_process+0x15/0x20
[  267.040009]  swake_up_locked+0x24/0x50
[  267.044519]  swake_up+0x2c/0x40
[  267.048364]  kvm_vcpu_kick+0x32/0x80 [kvm]
[  267.053276]  __apic_accept_irq+0x1b6/0x330 [kvm]
[  267.058774]  kvm_apic_set_irq+0x2a/0x30 [kvm]
[  267.063978]  kvm_irq_delivery_to_apic_fast+0xf5/0x3c0 [kvm]
[  267.070544]  kvm_arch_set_irq_inatomic+0x99/0xb0 [kvm]
[  267.076621]  irqfd_wakeup+0x111/0x160 [kvm]
[  267.081628]  ? kvm_irq_delivery_to_apic+0x2c0/0x2c0 [kvm]
[  267.087984]  __wake_up_common+0x55/0x90
[  267.092583]  __wake_up_locked_key+0x18/0x20
[  267.097580]  eventfd_signal+0x5c/0x80
[  267.102001]  vfio_msihandler+0x16/0x20 [vfio_pci]
[  267.107578]  __handle_irq_event_percpu+0x3c/0x1a0
[  267.113164]  handle_irq_event_percpu+0x32/0x80
[  267.118453]  handle_irq_event+0x2c/0x50
[  267.123068]  handle_edge_irq+0x87/0x130
[  267.127677]  handle_irq+0xab/0x130
[  267.131801]  do_IRQ+0x48/0xd0
[  267.135435]  common_interrupt+0x93/0x93
[  267.140042] RIP: 0010:panic+0x1f5/0x239
[  267.144647] RSP: 0018:ffff89916fa03898 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff73
[  267.153760] RAX: 000000000000003b RBX: 0000000000000000 RCX: 000000000=
0000006
[  267.162062] RDX: 0000000000000000 RSI: 0000000000000046 RDI: ffff89916=
fa0e060
[  267.170362] RBP: ffff89916fa03908 R08: 0000000000000691 R09: ffff898d0=
00bc4c0
[  267.178659] R10: 000000000000010a R11: 0000000000000198 R12: ffffffffb=
cc4a459
[  267.186964] R13: 0000000000000000 R14: 0000000000000000 R15: ffff89916=
fa03a28
[  267.195266]  ? panic+0x1f1/0x239
[  267.199201]  watchdog_timer_fn+0x1e5/0x1f0
[  267.204104]  ? watchdog+0x40/0x40
[  267.208130]  __hrtimer_run_queues+0xee/0x270
[  267.213224]  hrtimer_interrupt+0xa8/0x190
[  267.218036]  local_apic_timer_interrupt+0x35/0x60
[  267.223612]  smp_apic_timer_interrupt+0x38/0x50
[  267.228999]  apic_timer_interrupt+0x93/0xa0
[  267.233987] RIP: 0010:fl_classify+0x1f1/0x2b0 [cls_flower]
[  267.240440] RSP: 0018:ffff89916fa03ad8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff10
[  267.249539] RAX: 00000000ffffffff RBX: ffff89913f522100 RCX: 000000000=
0000000
[  267.257829] RDX: ffff89916fa03c98 RSI: ffff89915bd743c0 RDI: ffff89913=
f522100
[  267.266128] RBP: ffff89916fa03c28 R08: 000000000000270f R09: 000000000=
0000000
[  267.274425] R10: 0000000000000000 R11: 0000000000000004 R12: ffff89916=
fa03c98
[  267.282721] R13: ffff89913ecc7c00 R14: ffff89915bd743c0 R15: 000000000=
0000001
[  267.291019]  ? handle_edge_irq+0x87/0x130
[  267.295818]  ? handle_irq+0xab/0x130
[  267.300133]  ? irq_exit+0x77/0xe0
[  267.304160]  ? irq_exit+0x77/0xe0
[  267.308184]  ? do_IRQ+0x51/0xd0
[  267.312015]  ? common_interrupt+0x93/0x93
[  267.316818]  tc_classify+0x78/0x120
[  267.321038]  __netif_receive_skb_core+0x623/0xa00
[  267.326618]  ? udp4_gro_receive+0x10b/0x2d0
[  267.331616]  __netif_receive_skb+0x18/0x60
[  267.336514]  netif_receive_skb_internal+0x40/0xb0
[  267.342091]  napi_gro_receive+0xcd/0x120
[  267.346809]  mlx5e_handle_rx_cqe_rep+0x61b/0x890 [mlx5_core]
[  267.353467]  ? kvm_irq_delivery_to_apic+0x2c0/0x2c0 [kvm]
[  267.359837]  mlx5e_poll_rx_cq+0x83/0x840 [mlx5_core]
[  267.365716]  mlx5e_napi_poll+0x89/0x480 [mlx5_core]
[  267.371500]  net_rx_action+0x260/0x3c0
[  267.376008]  __do_softirq+0xc9/0x28c
[  267.380330]  irq_exit+0xd7/0xe0
[  267.384168]  do_IRQ+0x51/0xd0
[  267.387810]  common_interrupt+0x93/0x93
[  267.392426] RIP: 0010:mpihelp_submul_1+0x91/0xe0
[  267.403605] RSP: 0018:ffffa36f44513940 EFLAGS: 00000206 ORIG_RAX: ffff=
ffffffffffa2
[  267.412818] RAX: 5414d8fd4127cc59 RBX: 0000000100000000 RCX: fffffffff=
fffff50
[  267.421114] RDX: 00000000ffffffea RSI: 0000000019ba7e4d RDI: 000000006=
8ef6b86
[  267.429418] RBP: ffffa36f44513960 R08: 352cbbd4573982a8 R09: 645890191=
28fea22
[  267.437713] R10: 128fea2200000000 R11: 352cbbd5573982a8 R12: ffff89955=
c585c00
[  267.446014] R13: ffff899134dbfbd0 R14: 66a4c31fb80cf128 R15: d7554d389=
539f6c8
[  267.454311]  </IRQ>
[  267.456981]  mpihelp_divrem+0x23b/0x740
[  267.461598]  mpi_powm+0x471/0xa10
[  267.465630]  rsa_verify+0xa5/0x130
[  267.469759]  pkcs1pad_verify+0xb9/0xf0
[  267.474277]  public_key_verify_signature+0x1f7/0x280
[  267.480148]  public_key_verify_signature_2+0x15/0x20
[  267.486011]  verify_signature+0x3c/0x50
[  267.490619]  pkcs7_validate_trust+0xa1/0x200
[  267.495710]  verify_pkcs7_signature+0x9a/0x140
[  267.501000]  mod_verify_sig+0x92/0xe0
[  267.505404]  load_module+0x171/0x2810
[  267.509822]  ? vfs_read+0x113/0x130
[  267.514047]  ? kernel_read_file+0x158/0x190
[  267.519041]  ? kernel_read_file_from_fd+0x49/0x80
[  267.524620]  SYSC_finit_module+0xa6/0xf0
[  267.529325]  SyS_finit_module+0xe/0x10
[  267.533844]  entry_SYSCALL_64_fastpath+0x1a/0xa9
[  267.539325] RIP: 0033:0x7f74f2439239
[  267.543639] RSP: 002b:00007ffeb8b23218 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000139
[  267.552740] RAX: ffffffffffffffda RBX: 00007ffeb8b21f10 RCX: 00007f74f=
2439239
[  267.561042] RDX: 0000000000000000 RSI: 00005578b61d02a6 RDI: 000000000=
0000000
[  267.569341] RBP: 00007ffeb8b21f00 R08: 0000000000000000 R09: 000000000=
0000000
[  267.577638] R10: 0000000000000000 R11: 0000000000000246 R12: 00005578b=
61d1be7
[  267.585935] R13: 00007ffeb8b22088 R14: 0000000000000000 R15: 00005578b=
61d1bf3
[  267.594231] ---[ end trace 2eb46a584b6ba420 ]---


--------------4A80CCDCA830F630058E70A5--
