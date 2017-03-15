From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/10] netfilter: Force fake conntrack entry to be at least 8 bytes aligned
Date: Wed, 15 Mar 2017 18:01:09 +0100
Message-ID: <1489597272-30347-8-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37606 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751803AbdCORBo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 13:01:44 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 8277A1324DC
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:26 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 721A1DA87A
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:26 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 904D5DA86C
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:22 +0100 (CET)
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steven Rostedt (VMware)" <rostedt@goodmis.org>

Since the nfct and nfctinfo have been combined, the nf_conn structure
must be at least 8 bytes aligned, as the 3 LSB bits are used for the
nfctinfo. But there's a fake nf_conn structure to denote untracked
connections, which is created by a PER_CPU construct. This does not
guarantee that it will be 8 bytes aligned and can break the logic in
determining the correct nfctinfo.

I triggered this on a 32bit machine with the following error:

BUG: unable to handle kernel NULL pointer dereference at 00000af4
IP: nf_ct_deliver_cached_events+0x1b/0xfb
*pdpt = 0000000031962001 *pde = 0000000000000000

Oops: 0000 [#1] SMP
[Modules linked in: ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipv6 crc_ccitt ppdev r8169 parport_pc parport
  OK  ]
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.10.0-test+ #75
Hardware name: MSI MS-7823/CSM-H87M-G43 (MS-7823), BIOS V1.6 02/22/2014
task: c126ec00 task.stack: c1258000
EIP: nf_ct_deliver_cached_events+0x1b/0xfb
EFLAGS: 00010202 CPU: 0
EAX: 0021cd01 EBX: 00000000 ECX: 27b0c767 EDX: 32bcb17a
ESI: f34135c0 EDI: f34135c0 EBP: f2debd60 ESP: f2debd3c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 80050033 CR2: 00000af4 CR3: 309a0440 CR4: 001406f0
Call Trace:
 <SOFTIRQ>
 ? ipv6_skip_exthdr+0xac/0xcb
 ipv6_confirm+0x10c/0x119 [nf_conntrack_ipv6]
 nf_hook_slow+0x22/0xc7
 nf_hook+0x9a/0xad [ipv6]
 ? ip6t_do_table+0x356/0x379 [ip6_tables]
 ? ip6_fragment+0x9e9/0x9e9 [ipv6]
 ip6_output+0xee/0x107 [ipv6]
 ? ip6_fragment+0x9e9/0x9e9 [ipv6]
 dst_output+0x36/0x4d [ipv6]
 NF_HOOK.constprop.37+0xb2/0xba [ipv6]
 ? icmp6_dst_alloc+0x2c/0xfd [ipv6]
 ? local_bh_enable+0x14/0x14 [ipv6]
 mld_sendpack+0x1c5/0x281 [ipv6]
 ? mark_held_locks+0x40/0x5c
 mld_ifc_timer_expire+0x1f6/0x21e [ipv6]
 call_timer_fn+0x135/0x283
 ? detach_if_pending+0x55/0x55
 ? mld_dad_timer_expire+0x3e/0x3e [ipv6]
 __run_timers+0x111/0x14b
 ? mld_dad_timer_expire+0x3e/0x3e [ipv6]
 run_timer_softirq+0x1c/0x36
 __do_softirq+0x185/0x37c
 ? test_ti_thread_flag.constprop.19+0xd/0xd
 do_softirq_own_stack+0x22/0x28
 </SOFTIRQ>
 irq_exit+0x5a/0xa4
 smp_apic_timer_interrupt+0x2a/0x34
 apic_timer_interrupt+0x37/0x3c

By using DEFINE/DECLARE_PER_CPU_ALIGNED we can enforce at least 8 byte
alignment as all cache line sizes are at least 8 bytes or more.

Fixes: a9e419dc7be6 ("netfilter: merge ctinfo into nfct pointer storage area")
Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h | 2 +-
 net/netfilter/nf_conntrack_core.c    | 6 +++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index f540f9ad2af4..19605878da47 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -244,7 +244,7 @@ extern s32 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			       u32 seq);
 
 /* Fake conntrack entry for untracked connections */
-DECLARE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
+DECLARE_PER_CPU_ALIGNED(struct nf_conn, nf_conntrack_untracked);
 static inline struct nf_conn *nf_ct_untracked_get(void)
 {
 	return raw_cpu_ptr(&nf_conntrack_untracked);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 071b97fcbefb..ffb78e5f7b70 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -181,7 +181,11 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 unsigned int nf_conntrack_max __read_mostly;
 seqcount_t nf_conntrack_generation __read_mostly;
 
-DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
+/* nf_conn must be 8 bytes aligned, as the 3 LSB bits are used
+ * for the nfctinfo. We cheat by (ab)using the PER CPU cache line
+ * alignment to enforce this.
+ */
+DEFINE_PER_CPU_ALIGNED(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
 static unsigned int nf_conntrack_hash_rnd __read_mostly;
-- 
2.1.4
