From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] fix unsafe set_memory_rw from softirq
Date: Wed,  2 Oct 2013 20:50:31 -0700
Message-ID: <1380772231-3566-1-git-send-email-ast@plumgrid.com>
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Xi Wang <xi.wang@gmail.com>, x86@kernel.org,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:55919 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab3JCDuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 23:50:37 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so1844292pbc.12
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 20:50:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

on x86 system with net.core.bpf_jit_enable = 1

sudo tcpdump -i eth1 'tcp port 22'

causes the warning:
[   56.766097]  Possible unsafe locking scenario:
[   56.766097]
[   56.780146]        CPU0
[   56.786807]        ----
[   56.793188]   lock(&(&vb->lock)->rlock);
[   56.799593]   <Interrupt>
[   56.805889]     lock(&(&vb->lock)->rlock);
[   56.812266]
[   56.812266]  *** DEADLOCK ***
[   56.812266]
[   56.830670] 1 lock held by ksoftirqd/1/13:
[   56.836838]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8118f44c>] vm_unmap_aliases+0x8c/0x380
[   56.849757]
[   56.849757] stack backtrace:
[   56.862194] CPU: 1 PID: 13 Comm: ksoftirqd/1 Not tainted 3.12.0-rc3+ #45
[   56.868721] Hardware name: System manufacturer System Product Name/P8Z77 WS, BIOS 3007 07/26/2012
[   56.882004]  ffffffff821944c0 ffff88080bbdb8c8 ffffffff8175a145 0000000000000007
[   56.895630]  ffff88080bbd5f40 ffff88080bbdb928 ffffffff81755b14 0000000000000001
[   56.909313]  ffff880800000001 ffff880800000000 ffffffff8101178f 0000000000000001
[   56.923006] Call Trace:
[   56.929532]  [<ffffffff8175a145>] dump_stack+0x55/0x76
[   56.936067]  [<ffffffff81755b14>] print_usage_bug+0x1f7/0x208
[   56.942445]  [<ffffffff8101178f>] ? save_stack_trace+0x2f/0x50
[   56.948932]  [<ffffffff810cc0a0>] ? check_usage_backwards+0x150/0x150
[   56.955470]  [<ffffffff810ccb52>] mark_lock+0x282/0x2c0
[   56.961945]  [<ffffffff810ccfed>] __lock_acquire+0x45d/0x1d50
[   56.968474]  [<ffffffff810cce6e>] ? __lock_acquire+0x2de/0x1d50
[   56.975140]  [<ffffffff81393bf5>] ? cpumask_next_and+0x55/0x90
[   56.981942]  [<ffffffff810cef72>] lock_acquire+0x92/0x1d0
[   56.988745]  [<ffffffff8118f52a>] ? vm_unmap_aliases+0x16a/0x380
[   56.995619]  [<ffffffff817628f1>] _raw_spin_lock+0x41/0x50
[   57.002493]  [<ffffffff8118f52a>] ? vm_unmap_aliases+0x16a/0x380
[   57.009447]  [<ffffffff8118f52a>] vm_unmap_aliases+0x16a/0x380
[   57.016477]  [<ffffffff8118f44c>] ? vm_unmap_aliases+0x8c/0x380
[   57.023607]  [<ffffffff810436b0>] change_page_attr_set_clr+0xc0/0x460
[   57.030818]  [<ffffffff810cfb8d>] ? trace_hardirqs_on+0xd/0x10
[   57.037896]  [<ffffffff811a8330>] ? kmem_cache_free+0xb0/0x2b0
[   57.044789]  [<ffffffff811b59c3>] ? free_object_rcu+0x93/0xa0
[   57.051720]  [<ffffffff81043d9f>] set_memory_rw+0x2f/0x40
[   57.058727]  [<ffffffff8104e17c>] bpf_jit_free+0x2c/0x40
[   57.065577]  [<ffffffff81642cba>] sk_filter_release_rcu+0x1a/0x30
[   57.072338]  [<ffffffff811108e2>] rcu_process_callbacks+0x202/0x7c0
[   57.078962]  [<ffffffff81057f17>] __do_softirq+0xf7/0x3f0
[   57.085373]  [<ffffffff81058245>] run_ksoftirqd+0x35/0x70

cannot reuse filter memory, since it's readonly, so have to
extend sk_filter with work_struct

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/net/bpf_jit_comp.c |   17 ++++++++++++-----
 include/linux/filter.h      |    1 +
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 79c216a..89a43df 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -772,13 +772,20 @@ out:
 	return;
 }
 
+static void bpf_jit_free_deferred(struct work_struct *work)
+{
+	struct sk_filter *fp = container_of(work, struct sk_filter, work);
+	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
+	struct bpf_binary_header *header = (void *)addr;
+
+	set_memory_rw(addr, header->pages);
+	module_free(NULL, header);
+}
+
 void bpf_jit_free(struct sk_filter *fp)
 {
 	if (fp->bpf_func != sk_run_filter) {
-		unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
-		struct bpf_binary_header *header = (void *)addr;
-
-		set_memory_rw(addr, header->pages);
-		module_free(NULL, header);
+		INIT_WORK(&fp->work, bpf_jit_free_deferred);
+		schedule_work(&fp->work);
 	}
 }
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a6ac848..378fa03 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -27,6 +27,7 @@ struct sk_filter
 	unsigned int         	len;	/* Number of filter blocks */
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct sock_filter *filter);
+	struct work_struct	work;
 	struct rcu_head		rcu;
 	struct sock_filter     	insns[0];
 };
-- 
1.7.9.5
