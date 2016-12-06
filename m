From: Tom Herbert <tom@herbertland.com>
Subject: Soft lockup in inet_put_port on 4.6
Date: Tue, 6 Dec 2016 15:06:21 -0800
Message-ID: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:32886 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbcLFXHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 18:07:30 -0500
Received: by mail-qt0-f172.google.com with SMTP id p16so361021039qta.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 15:06:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We are seeing a fair number of machines getting into softlockup in 4.6
kernel. As near as I can tell this is happening on the spinlock in
bind hash bucket. When inet_csk_get_port exits and does spinunlock_bh
the TCP timer runs and we hit lockup in inet_put_port (presumably on
same lock). It seems like the locked isn't properly be unlocked
somewhere but I don't readily see it.

Any ideas?

Thanks,
Tom

NMI watchdog: BUG: soft lockup - CPU#22 stuck for 22s! [proxygend:4152094]
Modules linked in: fuse nf_log_ipv6 ip6t_REJECT nf_reject_ipv6
nf_log_ipv4 nf_log_common xt_LOG ipt_REJECT nf_reject_ipv4 xt_limit
xt_multiport ipip ip_tunnel tunnel4 ip6_tunnel tunnel6 coretemp mptctl
mptbase cls_bpf ipmi_watchdog tcp_diag inet_diag ip6table_filter
xt_NFLOG nfnetlink_log xt_comment xt_statistic iptable_filter xt_mark
tpm_crb i2c_piix4 dm_crypt loop ipmi_devintf acpi_cpufreq iTCO_wdt
iTCO_vendor_support ipmi_si ipmi_msghandler efivars i2c_i801 sg
lpc_ich mfd_core hpilo xhci_pci xhci_hcd button nvme nvme_core
CPU: 22 PID: 4152094 Comm: proxygend Tainted: G W L
4.6.7-13_fbk3_1119_g367d67b #13
Hardware name: HP ProLiant DL380 Gen9/ProLiant DL380 Gen9, BIOS P89 12/27/2015
task: ffff88168c52d100 ti: ffff881c12fb0000 task.ti: ffff881c12fb0000
RIP: 0010:[<ffffffff810b87b8>] [<ffffffff810b87b8>]
queued_spin_lock_slowpath+0xf8/0x170
RSP: 0018:ffff883fff303da0 EFLAGS: 00000246
RAX: 0000000000000000 RBX: ffff881257163e00 RCX: 0000000000000001
RDX: ffff883fff375e40 RSI: 00000000005c0000 RDI: ffffc90018d6bae0
RBP: ffff883fff303da0 R08: ffff883fff315e40 R09: 0000000000000000
R10: 0000000000000020 R11: 00000000000001c0 R12: ffffc90018d6bae0
R13: ffffffff820f8a80 R14: ffff881257163f30 R15: 0000000000000000
FS: 00007fa7bb7ff700(0000) GS:ffff883fff300000(0000) knlGS:0000000000000000
CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ff4be114d90 CR3: 000000243f99c000 CR4: 00000000003406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack: ffff883fff303db0 ffffffff817e5910 ffff883fff303dd8 ffffffff8172f6b4
ffff881257163e00 0000000000000007 0000000000000004 ffff883fff303e00
ffffffff81733237 ffff881257163e00 0000000000000000 ffffffff81ce7cc0
Call Trace:
<IRQ>
[<ffffffff817e5910>] _raw_spin_lock+0x20/0x30
[<ffffffff8172f6b4>] inet_put_port+0x54/0xb0
[<ffffffff81733237>] tcp_set_state+0x67/0xc0
[<ffffffff81733a33>] tcp_done+0x33/0x90
[<ffffffff81746431>] tcp_write_err+0x31/0x50
[<ffffffff81746bc9>] tcp_retransmit_timer+0x119/0x7d0
[<ffffffff81747460>] ? tcp_write_timer_handler+0x1e0/0x1e0
[<ffffffff8174730e>] tcp_write_timer_handler+0x8e/0x1e0
[<ffffffff817474c7>] tcp_write_timer+0x67/0x70
[<ffffffff810ccc35>] call_timer_fn+0x35/0x120
[<ffffffff81747460>] ? tcp_write_timer_handler+0x1e0/0x1e0
[<ffffffff810cd01c>] run_timer_softirq+0x1fc/0x2b0
[<ffffffff817e811c>] __do_softirq+0xcc/0x26c
[<ffffffff817e753c>] do_softirq_own_stack+0x1c/0x30 <EOI>
[<ffffffff8107b481>] do_softirq+0x31/0x40
[<ffffffff8107b508>] __local_bh_enable_ip+0x78/0x80
[<ffffffff817e572a>] _raw_spin_unlock_bh +0x1a/0x20
[<ffffffff81730a61>] inet_csk_get_port+0x1c1/0x5a0
[<ffffffff816c7637>] ? sock_poll+0x47/0xb0
[<ffffffff817313f5>] inet_csk_listen_start+0x65/0xc0
[<ffffffff8175ea8c>] inet_listen+0x9c/0xe0
[<ffffffff816c8560>] SyS_listen+0x80/0x90
[<ffffffff817e5adb>] entry_SYSCALL_64_fastpath+0x13/0x8f
Code: c1 ea 0c 83 e8 01 83 e2 30 48 98 48 81 c2 40 5e 01 00 48 03 14
c5 c0 d4 d1 81 4c 89 02 41 8b 40 08 85 c0 75 0a f3 90 41 8b 40 08 <85>
c0 74 f6 4d 8b 08 4d 85 c9 74 08 41 0f 0d 09 eb 02 f3 90 8b
