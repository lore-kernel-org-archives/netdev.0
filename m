From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] nfnetlink_log: unset nf_loggers for net namespace when unload nfnetlink_log
Date: Mon, 16 Dec 2013 14:59:22 +0800
Message-ID: <1387177162-2725-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <20131214101042.5626c785@gandalf.local.home>
Cc: pablo@netfilter.org, netdev@vger.kernel.org, lclaudio@uudg.org,
	williams@redhat.com, Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:13800 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752526Ab3LPG6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 01:58:36 -0500
In-Reply-To: <20131214101042.5626c785@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steven Rostedt and Arnaldo Carvalho de Melo reported a panic
when access the files /proc/sys/net/netfilter/nf_log/*.

This problem will occur when we do
echo nfnetlink_log > /proc/sys/net/netfilter/nf_log/any_file
,rmmod nfnetlink_log, and then access the files.

Since the nf_loggers of netns hasn't been unset, it will point
to the memory that has been freed.

This bug is introduced by commit 9368a53c471b42a1bd99117d590ce2ccdc8dc3c2
"netfilter: nfnetlink_log: add net namespace support for nfnetlink_log"

[17261.822047] BUG: unable to handle kernel paging request at ffffffffa0d49090
[17261.822056] IP: [<ffffffff8157aba0>] nf_log_proc_dostring+0xf0/0x1d0
[17261.822065] PGD 1c0f067 PUD 1c10063 PMD 2a8615067 PTE 0
[17261.822071] Oops: 0000 [#1] SMP
[17261.822076] Modules linked in: nfnetlink netlink_diag af_packet_diag udp_diag tcp_diag inet_diag unix_diag vhost_net vhost macvtap macvlan ipheth fuse xt_CHECKSUM tun bnep bluetooth rfkill nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6t_REJECT xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw nvidia(POF) coretemp kvm_intel kvm crc32c_intel drm iTCO_wdt iTCO_vendor_support e1000e snd_hda_codec_hdmi lpc_ich ptp pps_core mfd_core mei_me mei shpchp snd_hda_codec_realtek snd_hda_intel snd_hda_cod
 ec snd_hwdep
[17261.822140]  snd_seq snd_seq_device snd_pcm serio_raw microcode i7core_edac i2c_i801 edac_core i2c_core snd_page_alloc snd_timer snd soundcore tpm_tis tpm tpm_bios acpi_cpufreq mperf uinput binfmt_misc wmi [last unloaded: nfnetlink_log]
[17261.822164] CPU: 0 PID: 28872 Comm: cat Tainted: PF          O 3.11.6-200.fc19.x86_64 #1
[17261.822167] Hardware name: LENOVO ThinkCentre M8200T/  , BIOS 5JKT51AUS 11/02/2010
[17261.822171] task: ffff880223de2620 ti: ffff880274d3e000 task.ti: ffff880274d3e000
[17261.822173] RIP: 0010:[<ffffffff8157aba0>]  [<ffffffff8157aba0>] nf_log_proc_dostring+0xf0/0x1d0
[17261.822179] RSP: 0018:ffff880274d3fe28  EFLAGS: 00010282
[17261.822182] RAX: ffffffffa0d49080 RBX: ffffffff81fd7d60 RCX: ffff880274d3fec0
[17261.822185] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff81cc1f00
[17261.822187] RBP: ffff880274d3fea0 R08: ffff880274d3ff50 R09: 0000000000000000
[17261.822190] R10: 0000000000000002 R11: 0000000000000246 R12: 0000000000000004
[17261.822192] R13: ffffffff81cbdfc0 R14: 0000000002009000 R15: ffff8802b0ed8000
[17261.822196] FS:  00007f8a9cd53740(0000) GS:ffff8802bfc00000(0000) knlGS:0000000000000000
[17261.822199] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[17261.822202] CR2: ffffffffa0d49090 CR3: 00000001dae7a000 CR4: 00000000000027e0
[17261.822205] DR0: 00000000000000a0 DR1: 0000000000000000 DR2: 0000000000000003
[17261.822208] DR3: 00000000000000b0 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[17261.822209] Stack:
[17261.822211]  ffff880274d3ff50 ffff880274d3fec0 0000000074d3fe50 ffff880274d3fe50
[17261.822217]  ffffffff81297b98 ffff880274d3fe68 ffffffff8106fa09 ffffffff81fd7d60
[17261.822222]  ffff880274d3fe80 ffffffff8163d25f 0000000027c6e5aa 0000000000000000
[17261.822226] Call Trace:
[17261.822235]  [<ffffffff81297b98>] ? security_capable+0x18/0x20
[17261.822240]  [<ffffffff8106fa09>] ? ns_capable+0x29/0x50
[17261.822247]  [<ffffffff8163d25f>] ? net_ctl_permissions+0x1f/0x90
[17261.822254]  [<ffffffff81216613>] proc_sys_call_handler+0xb3/0xc0
[17261.822258]  [<ffffffff81216651>] proc_sys_read+0x11/0x20
[17261.822265]  [<ffffffff811a80de>] vfs_read+0x9e/0x170
[17261.822270]  [<ffffffff811a8c09>] SyS_read+0x49/0xa0
[17261.822276]  [<ffffffff810e6496>] ? __audit_syscall_exit+0x1f6/0x2a0
[17261.822283]  [<ffffffff81656e99>] system_call_fastpath+0x16/0x1b
[17261.822285] Code: cc 81 4d 63 e4 4c 89 45 88 48 89 4d 90 e8 19 03 0d 00 4b 8b 84 e5 28 08 00 00 48 8b 4d 90 4c 8b 45 88 48 85 c0 0f 84 a8 00 00 00 <48> 8b 40 10 48 89 43 08 48 89 df 4c 89 f2 31 f6 e8 4b 35 af ff
[17261.822329] RIP  [<ffffffff8157aba0>] nf_log_proc_dostring+0xf0/0x1d0
[17261.822334]  RSP <ffff880274d3fe28>
[17261.822336] CR2: ffffffffa0d49090
[17261.822340] ---[ end trace a14ce54c0897a90d ]---

Reported-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nfnetlink_log.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3c4b69e..a155d19 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1053,6 +1053,7 @@ static void __net_exit nfnl_log_net_exit(struct net *net)
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("nfnetlink_log", net->nf.proc_netfilter);
 #endif
+	nf_log_unset(net, &nfulnl_logger);
 }
 
 static struct pernet_operations nfnl_log_net_ops = {
-- 
1.8.3.1
