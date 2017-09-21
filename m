From: Roman Gushchin <guro@fb.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of
 net/ipv4/tcp_input.c
Date: Wed, 20 Sep 2017 18:46:20 -0700
Message-ID: <20170921014620.GA20906@castle>
Reply-To: <10035198.1vE6NFrMDO@natalenko.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexey Kuznetsov <kuznet@parallels.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hello.
>
> Since, IIRC, v4.11, there is some regression in TCP stack resulting in the 
> warning shown below. Most of the time it is harmless, but rarely it just 
> causes either freeze or (I believe, this is related too) panic in 
> tcp_sacktag_walk() (because sk_buff passed to this function is NULL). 
> Unfortunately, I still do not have proper stacktrace from panic, but will try 
> to capture it if possible.
> 
> Also, I have custom settings regarding TCP stack, shown below as well. ifb is 
> used to shape traffic with tc.
> 
> Please note this regression was already reported as BZ [1] and as a letter to 
> ML [2], but got neither attention nor resolution. It is reproducible for (not 
> only) me on my home router since v4.11 till v4.13.1 incl.
> 
> Please advise on how to deal with it. I'll provide any additional info if 
> necessary, also ready to test patches if any.
> 
> Thanks.
> 
> [1] https://bugzilla.kernel.org/show_bug.cgi?id=195835
> [2] https://www.spinics.net/lists/netdev/msg436158.html

We're experiencing the same problems on some machines in our fleet.
Exactly the same symptoms: tcp_fastretrans_alert() warnings and
sometimes panics in tcp_sacktag_walk().

Here is an example of a backtrace with the panic log:

978.210080]  fuse
[973978.214099]  sg
[973978.217789]  loop
[973978.221829]  efivarfs
[973978.226544]  autofs4
[973978.231109] CPU: 12 PID: 3806320 Comm: ld:srv:W20 Tainted: G        W       4.11.3-7_fbk1_1174_ga56eebf #7
[973978.250563] Hardware name: Wiwynn Leopard-Orv2/Leopard-DDR BW, BIOS LBM06   10/28/2016
[973978.266558] Call Trace:
[973978.271615]  <IRQ>
[973978.275817]  dump_stack+0x4d/0x70
[973978.282626]  __warn+0xd3/0xf0
[973978.288727]  warn_slowpath_null+0x1e/0x20
[973978.296910]  tcp_fastretrans_alert+0xacf/0xbd0
[973978.305974]  tcp_ack+0xbce/0x1390
[973978.312770]  tcp_rcv_established+0x1ce/0x740
[973978.321488]  tcp_v6_do_rcv+0x195/0x440
[973978.329166]  tcp_v6_rcv+0x94c/0x9f0
[973978.336323]  ip6_input_finish+0xea/0x430
[973978.344330]  ip6_input+0x32/0xa0
[973978.350968]  ? ip6_rcv_finish+0xa0/0xa0
[973978.358799]  ip6_rcv_finish+0x4b/0xa0
[973978.366289]  ipv6_rcv+0x2ec/0x4f0
[973978.373082]  ? ip6_make_skb+0x1c0/0x1c0
[973978.380919]  __netif_receive_skb_core+0x2d5/0x9a0
[973978.390505]  __netif_receive_skb+0x16/0x70
[973978.398875]  netif_receive_skb_internal+0x23/0x80
[973978.408462]  napi_gro_receive+0x113/0x1d0
[973978.416657]  mlx5e_handle_rx_cqe_mpwrq+0x5b6/0x8d0
[973978.426398]  mlx5e_poll_rx_cq+0x7c/0x7f0
[973978.434405]  mlx5e_napi_poll+0x8c/0x380
[973978.442238]  ? mlx5_cq_completion+0x54/0xb0
[973978.450770]  net_rx_action+0x22e/0x380
[973978.458447]  __do_softirq+0x106/0x2e8
[973978.465950]  irq_exit+0xb0/0xc0
[973978.472396]  do_IRQ+0x4f/0xd0
[973978.478495]  common_interrupt+0x86/0x86
[973978.486329] RIP: 0033:0x7f8dee58d8ae
[973978.493642] RSP: 002b:00007f8cb925f078 EFLAGS: 00000206
[973978.504251]  ORIG_RAX: ffffffffffffff5f
[973978.512085] RAX: 00007f8cb925f1a8 RBX: 0000000048000000 RCX: 00007f8764bd6a80
[973978.526508] RDX: 00000000000001ba RSI: 00007f7cb4ca3410 RDI: 00007f7cb4ca3410
[973978.540927] RBP: 000000000000000d R08: 00007f8764bd6b00 R09: 00007f8764bd6b80
[973978.555347] R10: 0000000000002400 R11: 00007f8dee58e240 R12: d3273c84146e8c29
[973978.569766] R13: 9dac83ddf04c235c R14: 00007f7cb4ca33b0 R15: 00007f7cb4ca4f50
[973978.584189]  </IRQ>
[973978.588650] ---[ end trace 5d1c83e12a57d039 ]---
[973995.178183] BUG: unable to handle kernel 
[973995.186385] NULL pointer dereference
[973995.193692]  at 0000000000000028
[973995.200323] IP: tcp_sacktag_walk+0x2b7/0x460
[973995.209032] PGD 102d856067 
[973995.214789] PUD fded0d067 
[973995.220385] PMD 0 
[973995.224577] 
[973995.227732] ------------[ cut here ]------------
[973995.237128] Oops: 0000 [#1] SMP
[973995.243575] Modules linked in:
[973995.249868]  mptctl
[973995.254251]  mptbase
[973995.258792]  xt_DSCP
[973995.263331]  xt_set
[973995.267698]  ip_set_hash_ip
[973995.273452]  cls_u32
[973995.277993]  sch_sfq
[973995.282535]  cls_fw
[973995.286904]  sch_htb
[973995.291444]  mpt3sas
[973995.295982]  raid_class
[973995.301044]  ip6table_mangle
[973995.306973]  iptable_mangle
[973995.312726]  cls_bpf
[973995.317268]  tcp_diag
[973995.321983]  udp_diag
[973995.326697]  inet_diag
[973995.331585]  ip6table_filter
[973995.337513]  xt_NFLOG
[973995.342226]  nfnetlink_log
[973995.347807]  xt_comment
[973995.352866]  xt_statistic
[973995.358276]  iptable_filter
[973995.364029]  xt_mark
[973995.368572]  sb_edac
[973995.373113]  edac_core
[973995.378001]  x86_pkg_temp_thermal
[973995.384795]  intel_powerclamp
[973995.390897]  coretemp
[973995.395608]  kvm_intel
[973995.400498]  kvm
[973995.404345]  irqbypass
[973995.409235]  ses
[973995.413078]  iTCO_wdt
[973995.417794]  iTCO_vendor_support
[973995.424415]  enclosure
[973995.429301]  lpc_ich
[973995.433843]  scsi_transport_sas
[973995.440292]  mfd_core
[973995.445007]  efivars
[973995.449548]  ipmi_si
[973995.454087]  ipmi_devintf
[973995.459496]  i2c_i801
[973995.464209]  ipmi_msghandler
[973995.470138]  acpi_cpufreq
[973995.475545]  button
[973995.479914]  sch_fq_codel
[973995.485319]  nfsd
[973995.489341]  auth_rpcgss
[973995.494573]  nfs_acl
[973995.499114]  oid_registry
[973995.504524]  lockd
[973995.508717]  grace
[973995.512912]  sunrpc
[973995.517280]  megaraid_sas
[973995.522689]  fuse
[973995.526709]  sg
[973995.530382]  loop
[973995.534405]  efivarfs
[973995.539118]  autofs4
[973995.543660] CPU: 19 PID: 3806297 Comm: ld:srv:W0 Tainted: G        W       4.11.3-7_fbk1_1174_ga56eebf #7
[973995.562936] Hardware name: Wiwynn Leopard-Orv2/Leopard-DDR BW, BIOS LBM06   10/28/2016
[973995.578914] task: ffff880129e5c380 task.stack: ffffc900210cc000
[973995.590914] RIP: 0010:tcp_sacktag_walk+0x2b7/0x460
[973995.600648] RSP: 0000:ffff88203ef438e8 EFLAGS: 00010207
[973995.611254] RAX: 0000000000000001 RBX: 0000000000000000 RCX: 000000004e4ec474
[973995.625677] RDX: 000000004e4ec2ad RSI: ffff8810361faa00 RDI: ffff881ffecf8840
[973995.640102] RBP: ffff88203ef43940 R08: 0000000045729921 R09: 0000000000000000
[973995.654519] R10: 00000000000085d6 R11: ffff881ffecf8998 R12: ffff881ffecf8840
[973995.668938] R13: ffff88203ef43a48 R14: 0000000000000000 R15: ffff881ffecf8998
[973995.683362] FS:  00007f8cc8cf7700(0000) GS:ffff88203ef40000(0000) knlGS:0000000000000000
[973995.699686] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[973995.711331] CR2: 0000000000000028 CR3: 0000000104c1b000 CR4: 00000000003406e0
[973995.725755] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[973995.740175] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[973995.754595] Call Trace:
[973995.759652]  <IRQ>
[973995.763855]  ? kprobe_perf_func+0x28/0x210
[973995.772210]  tcp_sacktag_write_queue+0x5ff/0x9e0
[973995.781615]  tcp_ack+0x677/0x1390
[973995.788408]  tcp_rcv_established+0x1ce/0x740
[973995.797112]  tcp_v6_do_rcv+0x195/0x440
[973995.804767]  tcp_v6_rcv+0x94c/0x9f0
[973995.811911]  ip6_input_finish+0xea/0x430
[973995.819917]  ip6_input+0x32/0xa0
[973995.826538]  ? ip6_rcv_finish+0xa0/0xa0
[973995.834373]  ip6_rcv_finish+0x4b/0xa0
[973995.841859]  ipv6_rcv+0x2ec/0x4f0
[973995.848653]  ? ip6_fragment+0x9f0/0x9f0
[973995.856489]  ? ip6_make_skb+0x1c0/0x1c0
[973995.864323]  __netif_receive_skb_core+0x2d5/0x9a0
[973995.873891]  __netif_receive_skb+0x16/0x70
[973995.882244]  netif_receive_skb_internal+0x23/0x80
[973995.891812]  napi_gro_receive+0x113/0x1d0
[973995.899993]  mlx5e_handle_rx_cqe_mpwrq+0x5b6/0x8d0
[973995.909735]  mlx5e_poll_rx_cq+0x7c/0x7f0
[973995.917740]  mlx5e_napi_poll+0x8c/0x380
[973995.925576]  ? mlx5_cq_completion+0x54/0xb0
[973995.934101]  net_rx_action+0x22e/0x380
[973995.941764]  __do_softirq+0x106/0x2e8
[973995.949255]  irq_exit+0xb0/0xc0
[973995.955696]  do_IRQ+0x4f/0xd0
[973995.961798]  common_interrupt+0x86/0x86
[973995.969634] RIP: 0033:0x7f8dec97a557
[973995.976945] RSP: 002b:00007f8cc8cf2f48 EFLAGS: 00000206
[973995.987552]  ORIG_RAX: ffffffffffffff20
[973995.995386] RAX: 00007f7fa9e15230 RBX: 00007f8c2153a160 RCX: 00007f7fa9e15230
[973996.009810] RDX: 0000000000000000 RSI: 00007f8cc8cf3040 RDI: 00007f8c204f90c0
[973996.024230] RBP: 00007f8cc8cf2f80 R08: 0000000000000001 R09: 000131aa4c002c01
[973996.038652] R10: 0000000000000000 R11: 0000000000000001 R12: 00007f8c2153a170
[973996.053073] R13: 00007f8cc8cf3040 R14: 00007f8c204f90c0 R15: 00007f8c2153a120
[973996.067494]  </IRQ>
[973996.071858] Code: 
[973996.076051] b9 
[973996.079723] 01 
[973996.083383] 00 
[973996.087056] 00 
[973996.090730] 00 
[973996.094388] 85 
[973996.098062] c0 
[973996.101738] 0f 
[973996.105410] 8e 
[973996.109087] da 
[973996.112759] fd 
[973996.116433] ff 
[973996.120109] ff 
[973996.123783] 85 
[973996.127457] c0 
[973996.131132] 75 
[973996.134806] 28 
[973996.138481] 0f 
[973996.142156] b7 
[973996.145831] 43 
[973996.149504] 30 
[973996.153180] 41 
[973996.156835] 01 
[973996.160511] 45 
[973996.164168] 04 
[973996.167843] 48 
[973996.171517] 8b 
[973996.175190] 1b 
[973996.178848] 4c 
[973996.182521] 39 
[973996.186198] fb 
[973996.189872] 74 
[973996.193529] 8c 
[973996.197202] 49 
[973996.200877] 3b 
[973996.204534] 9c 
[973996.208209] 24 
[973996.211883] 50 
[973996.215559] 01 
[973996.219215] 00 
[973996.222889] 00 
[973996.226562] 74 
[973996.230221] c1 
[973996.233894] <8b> 
[973996.237916] 43 
[973996.241590] 28 
[973996.245264] 3b 
[973996.248921] 45 
[973996.252596] d4 
[973996.256271] 0f 
[973996.259929] 88 
[973996.263601] 9f 
[973996.267276] fd 
[973996.270935] ff 
[973996.274592] ff 
[973996.278267] eb 
[973996.281938] b3 
[973996.285614] 48 
[973996.289289] 8d 
[973996.292964] 43 
[973996.296638] 10 
[973996.300296] 8b 
[973996.303969] 4b 
[973996.307642] 28 
[973996.311325] RIP: tcp_sacktag_walk+0x2b7/0x460 RSP: ffff88203ef438e8
[973996.324007] ------------[ cut here ]------------
[973996.333399] CR2: 0000000000000028
[973996.340218] ---[ end trace 5d1c83e12a57d03a ]---
[973996.349605] Kernel panic - not syncing: Fatal exception in interrupt
[973996.362521] Kernel Offset: disabled
TBOOT: wait until all APs ready for txt shutdown
TBOOT: IA32_FEATURE_CONTROL_MSR: 0000ff07
TBOOT: CPU is SMX-capable
TBOOT: CPU is VMX-capable
TBOOT: SMX is enabled
TBOOT: TXT chipset and all needed capabilities present
TBOOT: TPM: Pcr 17 extend, return value = 0000003D
TBOOT: TPM: Pcr 18 extend, return value = 0000003D
TBOOT: TPM: Pcr 19 extend, return value = 0000003D
TBOOT: cap'ed dynamic PCRs
TBOOT: waiting for APs (0) to exit guests...
TBOOT: .
TBOOT: 
TBOOT: all APs exited guests
TBOOT: calling txt_shutdown on AP


Thanks!
