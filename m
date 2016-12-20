From: Shahar Klein <shahark@mellanox.com>
Subject: Re: Soft lockup in tc_classify
Date: Tue, 20 Dec 2016 08:22:41 +0200
Message-ID: <5a985705-11e5-1575-a049-723accb97608@mellanox.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com>
 <584EA60B.80803@iogearbox.net>
 <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com>
 <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com>
 <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com>
 <CAM_iQpXUQYvvXonEXe0czd4osL5YxZ+G5B-PUddautcHnGOtQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="------------3E5050739EB3752AACC4DC6D"
Cc: <shahark@mellanox.com>, Or Gerlitz <gerlitz.or@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "Hadar Hen Zion" <hadarh@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0051.outbound.protection.outlook.com ([104.47.2.51]:57175
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756872AbcLTS5g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Dec 2016 13:57:36 -0500
In-Reply-To: <CAM_iQpXUQYvvXonEXe0czd4osL5YxZ+G5B-PUddautcHnGOtQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------3E5050739EB3752AACC4DC6D
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit



On 12/19/2016 7:58 PM, Cong Wang wrote:
> Hello,
>
> On Mon, Dec 19, 2016 at 8:39 AM, Shahar Klein <shahark@mellanox.com> wrote:
>>
>>
>> On 12/13/2016 12:51 AM, Cong Wang wrote:
>>>
>>> On Mon, Dec 12, 2016 at 1:18 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>>
>>>> On Mon, Dec 12, 2016 at 3:28 PM, Daniel Borkmann <daniel@iogearbox.net>
>>>> wrote:
>>>>
>>>>> Note that there's still the RCU fix missing for the deletion race that
>>>>> Cong will still send out, but you say that the only thing you do is to
>>>>> add a single rule, but no other operation in involved during that test?
>>>>
>>>>
>>>> What's missing to have the deletion race fixed? making a patch or
>>>> testing to a patch which was sent?
>>>
>>>
>>> If you think it would help for this problem, here is my patch rebased
>>> on the latest net-next.
>>>
>>> Again, I don't see how it could help this case yet, especially I don't
>>> see how we could have a loop in this singly linked list.
>>>
>>
>> I've applied cong's patch and hit a different lockup(full log attached):
>
>
> Are you sure this is really different? For me, it is still inside the loop
> in tc_classify(), with only a slightly different offset.
>
>
>>
>> Daniel suggested I'll add a print:
>>                 case RTM_DELTFILTER:
>> -                   err = tp->ops->delete(tp, fh);
>> +                 printk(KERN_ERR "DEBUGG:SK %s:%d\n", __func__, __LINE__);
>> +                 err = tp->ops->delete(tp, fh, &last);
>>                         if (err == 0) {
>>
>> and I couldn't see this print in the output.....
>
> Hmm, that is odd, if this never prints, then my patch should not make any
> difference.
>
> There are still two other cases where we could change tp->next, so do you
> mind to add two more printk's for debugging?
>
> Attached is the delta patch.
>
> Thanks!
>

I've added a slightly different debug print:
@@ -368,11 +375,12 @@ static int tc_ctl_tfilter(struct sk_buff *skb, 
struct nlmsghdr *n)
                 if (tp_created) {
                         RCU_INIT_POINTER(tp->next, 
rtnl_dereference(*back));
                         rcu_assign_pointer(*back, tp);
+                 printk(KERN_ERR "DEBUGG:SK add/change filter by: %pf 
tp=%p tp->next=%p\n", tp->ops->get, tp, tp->next);
                 }
                 tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);

full output attached:

[  283.290271] Mirror/redirect action on
[  283.305031] DEBUGG:SK add/change filter by: fl_get [cls_flower] 
tp=ffff9432d704df60 tp->next=          (null)
[  283.322563] DEBUGG:SK add/change filter by: fl_get [cls_flower] 
tp=ffff9436e718d240 tp->next=          (null)
[  283.359997] GACT probability on
[  283.365923] DEBUGG:SK add/change filter by: fl_get [cls_flower] 
tp=ffff9436e718d3c0 tp->next=ffff9436e718d240
[  283.378725] DEBUGG:SK add/change filter by: fl_get [cls_flower] 
tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
[  283.391310] DEBUGG:SK add/change filter by: fl_get [cls_flower] 
tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
[  283.403923] DEBUGG:SK add/change filter by: fl_get [cls_flower] 
tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
[  283.416542] DEBUGG:SK add/change filter by: fl_get [cls_flower] 
tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
[  308.538571] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! 
[swapper/0:0]


Thanks
Shahar




--------------3E5050739EB3752AACC4DC6D
Content-Type: text/plain; charset="UTF-8"; name="tp_p_debug.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="tp_p_debug.log"

[  283.290271] Mirror/redirect action on
[  283.305031] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=3Df=
fff9432d704df60 tp->next=3D          (null)
[  283.322563] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=3Df=
fff9436e718d240 tp->next=3D          (null)
[  283.359997] GACT probability on
[  283.365923] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=3Df=
fff9436e718d3c0 tp->next=3Dffff9436e718d240
[  283.378725] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=3Df=
fff9436e718d3c0 tp->next=3Dffff9436e718d3c0
[  283.391310] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=3Df=
fff9436e718d3c0 tp->next=3Dffff9436e718d3c0
[  283.403923] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=3Df=
fff9436e718d3c0 tp->next=3Dffff9436e718d3c0
[  283.416542] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=3Df=
fff9436e718d3c0 tp->next=3Dffff9436e718d3c0
[  308.538571] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [swa=
pper/0:0]
[  308.547322] Modules linked in: act_gact act_mirred openvswitch nf_conn=
track_ipv6 nf_nat_ipv6 nf_defrag_ipv6 vfio_pci vfio_virqfd vfio_iommu_typ=
e1 vfio cls_flower mlx5_ib mlx5_core devlink sch_ingress nfsv3 nfs fscach=
e xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptabl=
e_nat nf_nat_ipv4 nf_nat libcrc32c nf_conntrack_ipv4 nf_defrag_ipv4 xt_co=
nntrack nf_conntrack tun ebtable_filter ebtables ip6table_filter ip6_tabl=
es netconsole rpcrdma bridge ib_isert stp iscsi_target_mod llc ib_iser li=
biscsi scsi_transport_iscsi ib_srpt ib_srp scsi_transport_srp ib_ipoib rd=
ma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_core intel_rapl sb=
_edac edac_core x86_pkg_temp_thermal coretemp kvm_intel kvm igb irqbypass=
 joydev ipmi_ssif crct10dif_pclmul crc32_pclmul iTCO_wdt crc32c_intel ptp=
 ipmi_si iTCO_vendor_support pcspkr ghash_clmulni_intel wmi pps_core i2c_=
algo_bit ipmi_msghandler mei_me i2c_i801 ioatdma tpm_tis mei shpchp i2c_s=
mbus dca tpm_tis_core lpc_ich tpm nfsd target_core_mod auth_rpcgss nfs_ac=
l lockd grace sunrpc isci libsas serio_raw scsi_transport_sas [last unloa=
ded: devlink]
[  308.668291] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.9.0+ #31
[  308.675337] Hardware name: Supermicro X9DRW/X9DRW, BIOS 3.0a 08/08/201=
3
[  308.683060] task: ffffffff94e0e500 task.stack: ffffffff94e00000
[  308.690012] RIP: 0010:fl_classify+0xb/0x2b0 [cls_flower]
[  308.696275] RSP: 0018:ffff9432efa03c20 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff10
[  308.705396] RAX: 0000000000000008 RBX: ffff9432b59c4100 RCX: 000000000=
0000000
[  308.713704] RDX: ffff9432efa03c98 RSI: ffff9436e718d3c0 RDI: ffff9432b=
59c4100
[  308.722099] RBP: ffff9432efa03c28 R08: 000000000000270f R09: 000000000=
0000000
[  308.730409] R10: 0000000000000000 R11: 0000000000000004 R12: ffff9432e=
fa03c98
[  308.738713] R13: 0000000000000008 R14: ffff9436e718d3c0 R15: 000000000=
0000001
[  308.747013] FS:  0000000000000000(0000) GS:ffff9432efa00000(0000) knlG=
S:0000000000000000
[  308.756625] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  308.763378] CR2: 00007f5415f67914 CR3: 00000005fde07000 CR4: 000000000=
00426f0
[  308.771684] Call Trace:
[  308.774739]  <IRQ>
[  308.777311]  tc_classify+0x78/0x120
[  308.781549]  __netif_receive_skb_core+0x623/0xa00
[  308.787141]  ? udp4_gro_receive+0x10b/0x2d0
[  308.792143]  __netif_receive_skb+0x18/0x60
[  308.797048]  netif_receive_skb_internal+0x40/0xb0
[  308.802637]  napi_gro_receive+0xcd/0x120
[  308.807462]  mlx5e_handle_rx_cqe_rep+0x61b/0x890 [mlx5_core]
[  308.814123]  mlx5e_poll_rx_cq+0x83/0x840 [mlx5_core]
[  308.820015]  mlx5e_napi_poll+0x89/0x480 [mlx5_core]
[  308.825818]  net_rx_action+0x260/0x3c0
[  308.830334]  __do_softirq+0xc9/0x28c
[  308.834658]  irq_exit+0xd7/0xe0
[  308.838492]  do_IRQ+0x51/0xd0
[  308.842132]  common_interrupt+0x93/0x93
[  308.846747] RIP: 0010:cpuidle_enter_state+0xe1/0x260
[  308.852624] RSP: 0018:ffffffff94e03dc8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffffa2
[  308.861766] RAX: ffff9432efa19600 RBX: ffff9432efa23600 RCX: 000000000=
000001f
[  308.870077] RDX: 0000000000000000 RSI: ffff9432efa16cd8 RDI: 000000000=
0000000
[  308.878379] RBP: ffffffff94e03e00 R08: 0000000000000001 R09: ccccccccc=
ccccccd
[  308.886690] R10: 0000000000000000 R11: 0000000000000008 R12: 000000000=
0000001
[  308.895000] R13: 0000000000000000 R14: ffffffff94ec79a0 R15: 00000041f=
ab01c8d
[  308.903306]  </IRQ>
[  308.905978]  ? cpuidle_enter_state+0xc0/0x260
[  308.911173]  cpuidle_enter+0x17/0x20
[  308.915498]  call_cpuidle+0x23/0x40
[  308.919721]  do_idle+0x172/0x200
[  308.923656]  cpu_startup_entry+0x71/0x80
[  308.928370]  rest_init+0x77/0x80
[  308.932304]  start_kernel+0x4a6/0x4c7
[  308.936723]  ? set_init_arg+0x55/0x55
[  308.941141]  ? early_idt_handler_array+0x120/0x120
[  308.946823]  x86_64_start_reservations+0x24/0x26
[  308.952314]  x86_64_start_kernel+0x14c/0x16f
[  308.957418]  start_cpu+0x5/0x14
[  308.961242] Code: a8 4c 89 fe 48 8b 4d c8 48 8d 14 07 4c 89 e7 e8 2c f=
e ff ff e9 14 ff ff ff 0f 1f 80 00 00 00 00 66 66 66 66 90 55 48 89 e5 41=
 57 <41> 56 41 55 41 54 53 48 81 ec 28 01 00 00 65 48 8b 04 25 28 00=20
[  308.989075] Kernel panic - not syncing: softlockup: hung tasks
[  308.995924] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G             L  4.=
9.0+ #31
[  309.010442] Hardware name: Supermicro X9DRW/X9DRW, BIOS 3.0a 08/08/201=
3
[  309.018160] Call Trace:
[  309.021211]  <IRQ>
[  309.023776]  dump_stack+0x63/0x8c
[  309.027807]  panic+0xeb/0x239
[  309.031449]  watchdog_timer_fn+0x1e5/0x1f0
[  309.036354]  ? watchdog+0x40/0x40
[  309.040386]  __hrtimer_run_queues+0xee/0x270
[  309.045486]  hrtimer_interrupt+0xa8/0x190
[  309.050293]  local_apic_timer_interrupt+0x35/0x60
[  309.055880]  smp_apic_timer_interrupt+0x38/0x50
[  309.061272]  apic_timer_interrupt+0x93/0xa0
[  309.066272] RIP: 0010:fl_classify+0xb/0x2b0 [cls_flower]
[  309.072538] RSP: 0018:ffff9432efa03c20 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff10
[  309.081686] RAX: 0000000000000008 RBX: ffff9432b59c4100 RCX: 000000000=
0000000
[  309.089994] RDX: ffff9432efa03c98 RSI: ffff9436e718d3c0 RDI: ffff9432b=
59c4100
[  309.098297] RBP: ffff9432efa03c28 R08: 000000000000270f R09: 000000000=
0000000
[  309.106603] R10: 0000000000000000 R11: 0000000000000004 R12: ffff9432e=
fa03c98
[  309.114914] R13: 0000000000000008 R14: ffff9436e718d3c0 R15: 000000000=
0000001
[  309.123229]  tc_classify+0x78/0x120
[  309.127452]  __netif_receive_skb_core+0x623/0xa00
[  309.133031]  ? udp4_gro_receive+0x10b/0x2d0
[  309.138033]  __netif_receive_skb+0x18/0x60
[  309.142949]  netif_receive_skb_internal+0x40/0xb0
[  309.148534]  napi_gro_receive+0xcd/0x120
[  309.153259]  mlx5e_handle_rx_cqe_rep+0x61b/0x890 [mlx5_core]
[  309.159918]  mlx5e_poll_rx_cq+0x83/0x840 [mlx5_core]
[  309.165823]  mlx5e_napi_poll+0x89/0x480 [mlx5_core]
[  309.171608]  net_rx_action+0x260/0x3c0
[  309.176238]  __do_softirq+0xc9/0x28c
[  309.180563]  irq_exit+0xd7/0xe0
[  309.184395]  do_IRQ+0x51/0xd0
[  309.188035]  common_interrupt+0x93/0x93
[  309.192651] RIP: 0010:cpuidle_enter_state+0xe1/0x260
[  309.198527] RSP: 0018:ffffffff94e03dc8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffffa2
[  309.207651] RAX: ffff9432efa19600 RBX: ffff9432efa23600 RCX: 000000000=
000001f
[  309.215959] RDX: 0000000000000000 RSI: ffff9432efa16cd8 RDI: 000000000=
0000000
[  309.224268] RBP: ffffffff94e03e00 R08: 0000000000000001 R09: ccccccccc=
ccccccd
[  309.232573] R10: 0000000000000000 R11: 0000000000000008 R12: 000000000=
0000001
[  309.240881] R13: 0000000000000000 R14: ffffffff94ec79a0 R15: 00000041f=
ab01c8d
[  309.249187]  </IRQ>
[  309.251858]  ? cpuidle_enter_state+0xc0/0x260
[  309.257057]  cpuidle_enter+0x17/0x20
[  309.261382]  call_cpuidle+0x23/0x40
[  309.265635]  do_idle+0x172/0x200
[  309.269604]  cpu_startup_entry+0x71/0x80
[  309.274314]  rest_init+0x77/0x80
[  309.278247]  start_kernel+0x4a6/0x4c7
[  309.282668]  ? set_init_arg+0x55/0x55
[  309.287089]  ? early_idt_handler_array+0x120/0x120
[  309.292771]  x86_64_start_reservations+0x24/0x26
[  309.298262]  x86_64_start_kernel+0x14c/0x16f
[  309.303361]  start_cpu+0x5/0x14
[  309.307245] Kernel Offset: 0x13000000 from 0xffffffff81000000 (relocat=
ion range: 0xffffffff80000000-0xffffffffbfffffff)
[  310.573997] ---[ end Kernel panic - not syncing: softlockup: hung task=
s
[  310.581734] ------------[ cut here ]------------
[  310.587236] unchecked MSR access error: WRMSR to 0x83f (tried to write=
 0x00000000000000f6) at rIP: 0xffffffff94065c14 (native_write_msr+0x4/0x3=
0)
[  310.602404] Call Trace:
[  310.605472]  <IRQ>
[  310.608066]  ? native_apic_msr_write+0x30/0x40
[  310.613371]  x2apic_send_IPI_self+0x1d/0x20
[  310.618390]  arch_irq_work_raise+0x28/0x40
[  310.623309]  irq_work_queue+0x6e/0x80
[  310.627724]  wake_up_klogd+0x34/0x40
[  310.632045]  console_unlock+0x4dc/0x540
[  310.636659]  vprintk_emit+0x2eb/0x4b0
[  310.641091]  ? native_smp_send_reschedule+0x3f/0x50
[  310.646871]  vprintk_default+0x29/0x40
[  310.651393]  printk+0x5d/0x74
[  310.655034]  ? native_smp_send_reschedule+0x3f/0x50
[  310.660807]  __warn+0x3b/0xf0
[  310.664450]  warn_slowpath_null+0x1d/0x20
[  310.669262]  native_smp_send_reschedule+0x3f/0x50
[  310.674849]  try_to_wake_up+0x312/0x390
[  310.679456]  default_wake_function+0x12/0x20
[  310.684560]  __wake_up_common+0x55/0x90
[  310.689170]  __wake_up_locked+0x13/0x20
[  310.693788]  ep_poll_callback+0xbb/0x240
[  310.698493]  __wake_up_common+0x55/0x90
[  310.703101]  __wake_up+0x39/0x50
[  310.707028]  wake_up_klogd_work_func+0x40/0x60
[  310.712316]  irq_work_run_list+0x4d/0x70
[  310.717022]  irq_work_run+0x2c/0x40
[  310.721243]  smp_irq_work_interrupt+0x2e/0x40
[  310.726443]  irq_work_interrupt+0x93/0xa0
[  310.731253] RIP: 0010:panic+0x1f5/0x239
[  310.735876] RSP: 0018:ffff9432efa039e8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff09
[  310.744995] RAX: 000000000000003b RBX: 0000000000000000 RCX: 000000000=
0000006
[  310.753294] RDX: 0000000000000000 RSI: 0000000000000046 RDI: ffff9432e=
fa0e060
[  310.761594] RBP: ffff9432efa03a58 R08: 0000000000000674 R09: ffff942e8=
00bb3e0
[  310.769900] R10: 00000000000000ef R11: 0000000000000198 R12: ffffffff9=
4c4a4a9
[  310.778199] R13: 0000000000000000 R14: 0000000000000000 R15: ffff9432e=
fa03b78
[  310.786505]  ? panic+0x1f1/0x239
[  310.790444]  watchdog_timer_fn+0x1e5/0x1f0
[  310.795353]  ? watchdog+0x40/0x40
[  310.799401]  __hrtimer_run_queues+0xee/0x270
[  310.804501]  hrtimer_interrupt+0xa8/0x190
[  310.809318]  local_apic_timer_interrupt+0x35/0x60
[  310.814895]  smp_apic_timer_interrupt+0x38/0x50
[  310.820282]  apic_timer_interrupt+0x93/0xa0
[  310.825287] RIP: 0010:fl_classify+0xb/0x2b0 [cls_flower]
[  310.831554] RSP: 0018:ffff9432efa03c20 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff10
[  310.840693] RAX: 0000000000000008 RBX: ffff9432b59c4100 RCX: 000000000=
0000000
[  310.849007] RDX: ffff9432efa03c98 RSI: ffff9436e718d3c0 RDI: ffff9432b=
59c4100
[  310.857402] RBP: ffff9432efa03c28 R08: 000000000000270f R09: 000000000=
0000000
[  310.865712] R10: 0000000000000000 R11: 0000000000000004 R12: ffff9432e=
fa03c98
[  310.874020] R13: 0000000000000008 R14: ffff9436e718d3c0 R15: 000000000=
0000001
[  310.882337]  tc_classify+0x78/0x120
[  310.886568]  __netif_receive_skb_core+0x623/0xa00
[  310.892157]  ? udp4_gro_receive+0x10b/0x2d0
[  310.897151]  __netif_receive_skb+0x18/0x60
[  310.902057]  netif_receive_skb_internal+0x40/0xb0
[  310.907643]  napi_gro_receive+0xcd/0x120
[  310.912370]  mlx5e_handle_rx_cqe_rep+0x61b/0x890 [mlx5_core]
[  310.919031]  mlx5e_poll_rx_cq+0x83/0x840 [mlx5_core]
[  310.924924]  mlx5e_napi_poll+0x89/0x480 [mlx5_core]
[  310.930808]  net_rx_action+0x260/0x3c0
[  310.935319]  __do_softirq+0xc9/0x28c
[  310.939658]  irq_exit+0xd7/0xe0
[  310.943485]  do_IRQ+0x51/0xd0
[  310.947124]  common_interrupt+0x93/0x93
[  310.951748] RIP: 0010:cpuidle_enter_state+0xe1/0x260
[  310.957616] RSP: 0018:ffffffff94e03dc8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffffa2
[  310.966743] RAX: ffff9432efa19600 RBX: ffff9432efa23600 RCX: 000000000=
000001f
[  310.975044] RDX: 0000000000000000 RSI: ffff9432efa16cd8 RDI: 000000000=
0000000
[  310.983349] RBP: ffffffff94e03e00 R08: 0000000000000001 R09: ccccccccc=
ccccccd
[  310.991654] R10: 0000000000000000 R11: 0000000000000008 R12: 000000000=
0000001
[  310.999952] R13: 0000000000000000 R14: ffffffff94ec79a0 R15: 00000041f=
ab01c8d
[  311.008254]  </IRQ>
[  311.010926]  ? cpuidle_enter_state+0xc0/0x260
[  311.016122]  cpuidle_enter+0x17/0x20
[  311.020430]  call_cpuidle+0x23/0x40
[  311.024658]  do_idle+0x172/0x200
[  311.028583]  cpu_startup_entry+0x71/0x80
[  311.033295]  rest_init+0x77/0x80
[  311.037233]  start_kernel+0x4a6/0x4c7
[  311.041646]  ? set_init_arg+0x55/0x55
[  311.046068]  ? early_idt_handler_array+0x120/0x120
[  311.051752]  x86_64_start_reservations+0x24/0x26
[  311.057238]  x86_64_start_kernel+0x14c/0x16f
[  311.062339]  start_cpu+0x5/0x14
[  311.066180] WARNING: CPU: 0 PID: 0 at arch/x86/kernel/smp.c:127 native=
_smp_send_reschedule+0x3f/0x50
[  311.076956] Modules linked in: act_gact act_mirred openvswitch nf_conn=
track_ipv6 nf_nat_ipv6 nf_defrag_ipv6 vfio_pci vfio_virqfd vfio_iommu_typ=
e1 vfio cls_flower mlx5_ib mlx5_core devlink sch_ingress nfsv3 nfs fscach=
e xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptabl=
e_nat nf_nat_ipv4 nf_nat libcrc32c nf_conntrack_ipv4 nf_defrag_ipv4 xt_co=
nntrack nf_conntrack tun ebtable_filter ebtables ip6table_filter ip6_tabl=
es netconsole rpcrdma bridge ib_isert stp iscsi_target_mod llc ib_iser li=
biscsi scsi_transport_iscsi ib_srpt ib_srp scsi_transport_srp ib_ipoib rd=
ma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_core intel_rapl sb=
_edac edac_core x86_pkg_temp_thermal coretemp kvm_intel kvm igb irqbypass=
 joydev ipmi_ssif crct10dif_pclmul crc32_pclmul iTCO_wdt crc32c_intel ptp=
 ipmi_si iTCO_vendor_support pcspkr ghash_clmulni_intel wmi pps_core i2c_=
algo_bit ipmi_msghandler mei_me i2c_i801 ioatdma tpm_tis mei shpchp i2c_s=
mbus dca tpm_tis_core lpc_ich tpm nfsd target_core_mod auth_rpcgss nfs_ac=
l lockd grace sunrpc isci libsas serio_raw scsi_transport_sas [last unloa=
ded: devlink]
[  311.198587] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G             L  4.=
9.0+ #31
[  311.207253] Hardware name: Supermicro X9DRW/X9DRW, BIOS 3.0a 08/08/201=
3
[  311.214983] Call Trace:
[  311.218051]  <IRQ>
[  311.220626]  dump_stack+0x63/0x8c
[  311.224657]  __warn+0xd1/0xf0
[  311.228298]  warn_slowpath_null+0x1d/0x20
[  311.233116]  native_smp_send_reschedule+0x3f/0x50
[  311.238702]  try_to_wake_up+0x312/0x390
[  311.243318]  default_wake_function+0x12/0x20
[  311.248418]  __wake_up_common+0x55/0x90
[  311.253034]  __wake_up_locked+0x13/0x20
[  311.257641]  ep_poll_callback+0xbb/0x240
[  311.262346]  __wake_up_common+0x55/0x90
[  311.272771]  __wake_up+0x39/0x50
[  311.276697]  wake_up_klogd_work_func+0x40/0x60
[  311.281986]  irq_work_run_list+0x4d/0x70
[  311.286681]  irq_work_run+0x2c/0x40
[  311.290899]  smp_irq_work_interrupt+0x2e/0x40
[  311.296090]  irq_work_interrupt+0x93/0xa0
[  311.300900] RIP: 0010:panic+0x1f5/0x239
[  311.305508] RSP: 0018:ffff9432efa039e8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff09
[  311.314630] RAX: 000000000000003b RBX: 0000000000000000 RCX: 000000000=
0000006
[  311.322936] RDX: 0000000000000000 RSI: 0000000000000046 RDI: ffff9432e=
fa0e060
[  311.331245] RBP: ffff9432efa03a58 R08: 0000000000000674 R09: ffff942e8=
00bb3e0
[  311.339543] R10: 00000000000000ef R11: 0000000000000198 R12: ffffffff9=
4c4a4a9
[  311.347855] R13: 0000000000000000 R14: 0000000000000000 R15: ffff9432e=
fa03b78
[  311.356167]  ? panic+0x1f1/0x239
[  311.360106]  watchdog_timer_fn+0x1e5/0x1f0
[  311.365004]  ? watchdog+0x40/0x40
[  311.369035]  __hrtimer_run_queues+0xee/0x270
[  311.374132]  hrtimer_interrupt+0xa8/0x190
[  311.378935]  local_apic_timer_interrupt+0x35/0x60
[  311.384511]  smp_apic_timer_interrupt+0x38/0x50
[  311.389897]  apic_timer_interrupt+0x93/0xa0
[  311.394892] RIP: 0010:fl_classify+0xb/0x2b0 [cls_flower]
[  311.401151] RSP: 0018:ffff9432efa03c20 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffff10
[  311.410270] RAX: 0000000000000008 RBX: ffff9432b59c4100 RCX: 000000000=
0000000
[  311.418580] RDX: ffff9432efa03c98 RSI: ffff9436e718d3c0 RDI: ffff9432b=
59c4100
[  311.426967] RBP: ffff9432efa03c28 R08: 000000000000270f R09: 000000000=
0000000
[  311.435278] R10: 0000000000000000 R11: 0000000000000004 R12: ffff9432e=
fa03c98
[  311.443584] R13: 0000000000000008 R14: ffff9436e718d3c0 R15: 000000000=
0000001
[  311.451889]  tc_classify+0x78/0x120
[  311.456105]  __netif_receive_skb_core+0x623/0xa00
[  311.461683]  ? udp4_gro_receive+0x10b/0x2d0
[  311.466687]  __netif_receive_skb+0x18/0x60
[  311.471593]  netif_receive_skb_internal+0x40/0xb0
[  311.477186]  napi_gro_receive+0xcd/0x120
[  311.481900]  mlx5e_handle_rx_cqe_rep+0x61b/0x890 [mlx5_core]
[  311.488555]  mlx5e_poll_rx_cq+0x83/0x840 [mlx5_core]
[  311.494451]  mlx5e_napi_poll+0x89/0x480 [mlx5_core]
[  311.500233]  net_rx_action+0x260/0x3c0
[  311.504751]  __do_softirq+0xc9/0x28c
[  311.509075]  irq_exit+0xd7/0xe0
[  311.512901]  do_IRQ+0x51/0xd0
[  311.516529]  common_interrupt+0x93/0x93
[  311.521143] RIP: 0010:cpuidle_enter_state+0xe1/0x260
[  311.527011] RSP: 0018:ffffffff94e03dc8 EFLAGS: 00000246 ORIG_RAX: ffff=
ffffffffffa2
[  311.536123] RAX: ffff9432efa19600 RBX: ffff9432efa23600 RCX: 000000000=
000001f
[  311.544430] RDX: 0000000000000000 RSI: ffff9432efa16cd8 RDI: 000000000=
0000000
[  311.552760] RBP: ffffffff94e03e00 R08: 0000000000000001 R09: ccccccccc=
ccccccd
[  311.561087] R10: 0000000000000000 R11: 0000000000000008 R12: 000000000=
0000001
[  311.569396] R13: 0000000000000000 R14: ffffffff94ec79a0 R15: 00000041f=
ab01c8d
[  311.577714]  </IRQ>
[  311.580393]  ? cpuidle_enter_state+0xc0/0x260
[  311.585591]  cpuidle_enter+0x17/0x20
[  311.589913]  call_cpuidle+0x23/0x40
[  311.594136]  do_idle+0x172/0x200
[  311.598069]  cpu_startup_entry+0x71/0x80
[  311.602782]  rest_init+0x77/0x80
[  311.606713]  start_kernel+0x4a6/0x4c7
[  311.611134]  ? set_init_arg+0x55/0x55
[  311.615547]  ? early_idt_handler_array+0x120/0x120
[  311.621231]  x86_64_start_reservations+0x24/0x26
[  311.626717]  x86_64_start_kernel+0x14c/0x16f
[  311.631810]  start_cpu+0x5/0x14
[  311.635648] ---[ end trace c2fd08dd3d93dab3 ]---



--------------3E5050739EB3752AACC4DC6D--
