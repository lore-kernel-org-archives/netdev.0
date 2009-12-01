From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: soft lockup in inet_csk_get_port
Date: Tue, 01 Dec 2009 07:10:39 +0100
Message-ID: <4B14B35F.5000403@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org
To: kapil dakhane <kdakhane@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kapil dakhane a =E9crit :
> Hello,
>=20
> I am trying to analyze the capacity of linux network stack on x6270
> which has 16 Hyper threads on two 8-core Intel(r) Xeon(r) CPU. I see
> that at around 150000 simultaneous connections, after around 1.6 gbps=
,
> a cpu get stuck in an infinite loop in inet_csk_bind_conflict, then
> other cpus get locked up doing spin_lock. Before the lockup cpu usage
> was around 25%. It appears to be a bug, unless I am hitting some kind
> of resource limit. It would be good if someone familiar with network
> code would confirm this, or point me in the right direction.
>=20
> Important details are:
>=20
> I am using kernel version 2.6.31.4 recompiled with TPROXY related
> options: NF_CONNTRACK, NETFILTER_TPROXY, NETFILTER_XT_MATCH_SOCKET,
> NETFILTER_XT_TARGET_TPROXY.
>=20
>=20
> I have enabled transparent capture and transparent forward using
> iptables and ip rules.  I have 10 instances of a single threaded user
> space bits-forwarding-proxy (fast), each bound to different
> hyper-threads (CPUs). Rest 6 CPUs are dedicated to interrupt
> processing, each handling interrupts from six different network cards=
=2E
> TCP flow from a 4-tuple always get handled by the same proxy process,
> interrupt thread, and network card. In this way, network traffic is
> segregated as much as possible to achieve high degree of parallelism.
>=20
> First /var/log/message entry shows CPU#7 is stuck in inet_csk_bind_co=
nflict
>=20
> Nov 17 23:02:04 cap-x6270-01 kernel: BUG: soft lockup - CPU#7 stuck
> for 61s! [fast:20701]
> Nov 17 23:02:04 cap-x6270-01 kernel: Modules linked in: xt_TPROXY
> xt_MARK xt_socket nf_defrag_ipv4 nf_tproxy_core iptable_mangle ipv6
> autofs4 hidp rfcomm l2cap bluetooth rfkill sunrpc 8021q xt_state
> nf_conntrack xt_tcpudp iptable_filter ip_tables x_tables
> cpufreq_ondemand acpi_cpufreq freq_table dm_multipath scsi_dh video
> output sbs sbshc battery acpi_memhotplug ac parport_pc lp parport
> joydev sg rtc_cmos serio_raw rtc_core button igb rtc_lib niu i2c_i801
> i2c_core pcspkr dm_snapshot dm_zero dm_mirror dm_region_hash dm_log
> dm_mod usb_storage ahci libata shpchp aacraid sd_mod scsi_mod ext3 jb=
d
> uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
> Nov 17 23:02:04 cap-x6270-01 kernel: CPU 7:
> Nov 17 23:02:04 cap-x6270-01 kernel: Modules linked in: ...
> Nov 17 23:02:04 cap-x6270-01 kernel: Pid: 20701, comm: fast Not
> tainted 2.6.31.4 #1 SUN BLADE X6270 SERVER MODULE
> Nov 17 23:02:04 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c53>]
> [<ffffffff81285c53>] inet_csk_bind_conflict+0x99/0xa6
> Nov 17 23:02:04 cap-x6270-01 kernel: RSP: 0018:ffff88095ac7fe30
> EFLAGS: 00000202
> Nov 17 23:02:04 cap-x6270-01 kernel: RAX: 000000003c0ba8c0 RBX:
> ffff88097b14bae0 RCX: ffff8804b3d57820
> Nov 17 23:02:04 cap-x6270-01 kernel: RDX: ffff8804b3d57800 RSI:
> 0000000000000000 RDI: ffff880940421840
> Nov 17 23:02:04 cap-x6270-01 kernel: RBP: ffffffff8100c42e R08:
> 000000002d01960c R09: ffff880909832ea0
> Nov 17 23:02:04 cap-x6270-01 kernel: R10: 00007fffc5d92700 R11:
> ffff880940421840 R12: 0000000000000001
> Nov 17 23:02:04 cap-x6270-01 kernel: R13: ffff88097c5e9400 R14:
> ffffffff810b7a92 R15: 0000000000000001
> Nov 17 23:02:04 cap-x6270-01 kernel: FS:  00007f20a08416e0(0000)
> GS:ffffc90000e00000(0000) knlGS:0000000000000000
> Nov 17 23:02:04 cap-x6270-01 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
> 0000000080050033
> Nov 17 23:02:04 cap-x6270-01 kernel: CR2: 00000000081df408 CR3:
> 000000049ac01000 CR4: 00000000000006e0
> Nov 17 23:02:04 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Nov 17 23:02:04 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Nov 17 23:02:04 cap-x6270-01 kernel: Call Trace:
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff812859e4>] ?
> inet_csk_get_port+0x1b2/0x29e
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff812a1596>] ?
> inet_bind+0x10c/0x1b7
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff8124ef53>] ? sys_bind=
+0x6e/0x9e
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff8106de14>] ?
> audit_syscall_entry+0x1a4/0x1cf
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff8100b92b>] ?
> system_call_fastpath+0x16/0x1b
>=20
> While other CPUs get stuck doing _spin_lock:
>=20
>=20
> Nov 17 23:02:04 cap-x6270-01 kernel: BUG: soft lockup - CPU#15 stuck
> for 61s! [fast:20702]
> Nov 17 23:02:04 cap-x6270-01 kernel: Modules linked in: ...
> Nov 17 23:02:04 cap-x6270-01 kernel: CPU 15:
> Nov 17 23:02:04 cap-x6270-01 kernel: Modules linked in: ...
> Nov 17 23:02:04 cap-x6270-01 kernel: Pid: 20702, comm: fast Not
> tainted 2.6.31.4 #1 SUN BLADE X6270 SERVER MODULE
> Nov 17 23:02:04 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dedff>]
> [<ffffffff812dedff>] _spin_lock+0x10/0x15
> Nov 17 23:02:04 cap-x6270-01 kernel: RSP: 0018:ffff88090ecabe30
> EFLAGS: 00000297
> Nov 17 23:02:04 cap-x6270-01 kernel: RAX: 0000000000000504 RBX:
> 00000000ffffffea RCX: 0000000000000000
> Nov 17 23:02:04 cap-x6270-01 kernel: RDX: 00000000000000a2 RSI:
> 0000000000000fa2 RDI: ffffc90019f82a20
> Nov 17 23:02:04 cap-x6270-01 kernel: RBP: ffffffff8100c42e R08:
> ffff880905d89840 R09: 0000000000000000
> Nov 17 23:02:04 cap-x6270-01 kernel: R10: 00007fffd8db4574 R11:
> ffff880905d89840 R12: ffffffff812509d4
> Nov 17 23:02:04 cap-x6270-01 kernel: R13: ffff88094c0bd280 R14:
> 0000000000000246 R15: 0000000000000001
> Nov 17 23:02:04 cap-x6270-01 kernel: FS:  00007f0deff696e0(0000)
> GS:ffffc90001e00000(0000) knlGS:0000000000000000
> Nov 17 23:02:04 cap-x6270-01 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
> 0000000080050033
> Nov 17 23:02:04 cap-x6270-01 kernel: CR2: 0000000007ec2258 CR3:
> 00000009494b1000 CR4: 00000000000006e0
> Nov 17 23:02:04 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Nov 17 23:02:04 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Nov 17 23:02:04 cap-x6270-01 kernel: Call Trace:
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff81285989>] ?
> inet_csk_get_port+0x157/0x29e
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff812a1596>] ?
> inet_bind+0x10c/0x1b7
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff8124ef53>] ? sys_bind=
+0x6e/0x9e
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff8106de14>] ?
> audit_syscall_entry+0x1a4/0x1cf
> Nov 17 23:02:04 cap-x6270-01 kernel:  [<ffffffff8100b92b>] ?
> system_call_fastpath+0x16/0x1b
> --

Hmm, I did an one hour audit and could not yet find the bug.

Is it a reproductible error, and any chance I can have a snapshot of
"netstat -atn" before the lockup ? (maybe privately, since it might be
too big for netdev)

What is the 'fast' program, is it freely available somewhere ?

Thanks

