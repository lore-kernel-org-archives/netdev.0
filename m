From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 17/41] net: Replace __this_cpu_inc in route.c with raw_cpu_inc
Date: Fri, 17 Jan 2014 09:18:29 -0600
Message-ID: <20140117151836.140608046@linux.com>
References: <20140117151812.770437629@linux.com>
Content-Type: text/plain; charset=UTF-8
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=preempt_rt_cache_stat
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Patch depends on another patch in this series that introduces raw_cpu_ops]

The RT_CACHE_STAT_INC macro triggers the new preemption checks
for __this_cpu ops.

I do not see any other synchronization that would allow the use
of a __this_cpu operation here however in commit
dbd2915ce87e811165da0717f8e159276ebb803e Andrew justifies
the use of raw_smp_processor_id() here because "we do not care"
about races. In the past we agreed that the price of disabling
interrupts here to get consistent counters would be too high.
These counters may be inaccurate due to race conditions.

The use of __this_cpu op improves the situation already from what commit
dbd2915ce87e811165da0717f8e159276ebb803e did since the single instruction
emitted on x86 does not allow the race to occur anymore. However,
non x86 platforms could still experience a race here.

Trace:

[ 1277.189084] __this_cpu_add operation in preemptible [00000000] code: avahi-daemon/1193
[ 1277.189085] caller is __this_cpu_preempt_check+0x38/0x60
[ 1277.189086] CPU: 1 PID: 1193 Comm: avahi-daemon Tainted: GF            3.12.0-rc4+ #187
[ 1277.189087] Hardware name: FUJITSU CELSIUS W530 Power/D3227-A1, BIOS V4.6.5.4 R1.10.0 for D3227-A1x 09/16/2013
[ 1277.189088]  0000000000000001 ffff8807ef78fa00 ffffffff816d5a57 ffff8807ef78ffd8
[ 1277.189089]  ffff8807ef78fa30 ffffffff8137359c ffff8807ef78fba0 ffff88079f822b40
[ 1277.189091]  0000000020000000 ffff8807ee32c800 ffff8807ef78fa70 ffffffff813735f8
[ 1277.189093] Call Trace:
[ 1277.189094]  [<ffffffff816d5a57>] dump_stack+0x4e/0x82
[ 1277.189096]  [<ffffffff8137359c>] check_preemption_disabled+0xec/0x110
[ 1277.189097]  [<ffffffff813735f8>] __this_cpu_preempt_check+0x38/0x60
[ 1277.189098]  [<ffffffff81610d65>] __ip_route_output_key+0x575/0x8c0
[ 1277.189100]  [<ffffffff816110d7>] ip_route_output_flow+0x27/0x70
[ 1277.189101]  [<ffffffff81616c80>] ? ip_copy_metadata+0x1a0/0x1a0
[ 1277.189102]  [<ffffffff81640b15>] udp_sendmsg+0x825/0xa20
[ 1277.189104]  [<ffffffff811b4aa9>] ? do_sys_poll+0x449/0x5d0
[ 1277.189105]  [<ffffffff8164c695>] inet_sendmsg+0x85/0xc0
[ 1277.189106]  [<ffffffff815c6e3c>] sock_sendmsg+0x9c/0xd0
[ 1277.189108]  [<ffffffff813735f8>] ? __this_cpu_preempt_check+0x38/0x60
[ 1277.189109]  [<ffffffff815c7550>] ? move_addr_to_kernel+0x40/0xa0
[ 1277.189111]  [<ffffffff815c71ec>] ___sys_sendmsg+0x37c/0x390
[ 1277.189112]  [<ffffffff8136613a>] ? string.isra.3+0x3a/0xd0
[ 1277.189113]  [<ffffffff8136613a>] ? string.isra.3+0x3a/0xd0
[ 1277.189115]  [<ffffffff81367b54>] ? vsnprintf+0x364/0x650
[ 1277.189116]  [<ffffffff81367ee9>] ? snprintf+0x39/0x40
[ 1277.189118]  [<ffffffff813735f8>] ? __this_cpu_preempt_check+0x38/0x60
[ 1277.189119]  [<ffffffff815c7ff9>] __sys_sendmsg+0x49/0x90
[ 1277.189121]  [<ffffffff815c8052>] SyS_sendmsg+0x12/0x20
[ 1277.189122]  [<ffffffff816e4fd3>] tracesys+0xe1/0xe6

Cc: netdev@vger.kernel.org
Cc: davem@davemloft.net
Cc: edumazet@google.com
Acked-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/net/ipv4/route.c
===================================================================
--- linux.orig/net/ipv4/route.c	2013-12-02 16:07:51.964573250 -0600
+++ linux/net/ipv4/route.c	2013-12-02 16:07:51.954573526 -0600
@@ -197,7 +197,7 @@ const __u8 ip_tos2prio[16] = {
 EXPORT_SYMBOL(ip_tos2prio);
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
-#define RT_CACHE_STAT_INC(field) __this_cpu_inc(rt_cache_stat.field)
+#define RT_CACHE_STAT_INC(field) raw_cpu_inc(rt_cache_stat.field)
 
 #ifdef CONFIG_PROC_FS
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
