From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH] i40e{,vf}: Fix out-of-bound cpumask read in IRQ affinity handler
Date: Tue, 15 Aug 2017 12:30:14 +0200
Message-ID: <ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Alan Brady <alan.brady@intel.com>,
        Stefan Assmann <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33140 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753423AbdHOKa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 06:30:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cpumask used in i40e{,vf}_irq_affinity_notify() is allocated
by irq_affinity_notify() with alloc_cpumask_var(), which doesn't
allocate NR_CPUS bits, but only nr_cpumask_bits bits. If we just
dereference it, we'll read way more than what is allocated, e.g.
1024 bytes vs. 8 bytes allocated on x86_64 machine with 24 CPUs.

Use cpumask_copy() instead. A comprehensive explanation is given
in the comments about cpumask_var_t, in include/linux/cpumask.h.

KASAN reports:
[   25.242312] BUG: KASAN: slab-out-of-bounds in i40e_irq_affinity_notify+0x30/0x50 [i40e] at addr ffff880462eea960
[   25.242315] Read of size 1024 by task kworker/2:1/170
[   25.242322] CPU: 2 PID: 170 Comm: kworker/2:1 Not tainted 4.11.0-22.el7a.x86_64 #1
[   25.242325] Hardware name: HP ProLiant DL380 Gen9, BIOS P89 05/06/2015
[   25.242336] Workqueue: events irq_affinity_notify
[   25.242340] Call Trace:
[   25.242350]  dump_stack+0x63/0x8d
[   25.242358]  kasan_object_err+0x21/0x70
[   25.242364]  kasan_report+0x288/0x540
[   25.242397]  ? i40e_irq_affinity_notify+0x30/0x50 [i40e]
[   25.242403]  check_memory_region+0x13c/0x1a0
[   25.242408]  __asan_loadN+0xf/0x20
[   25.242440]  i40e_irq_affinity_notify+0x30/0x50 [i40e]
[   25.242446]  irq_affinity_notify+0x1b4/0x230
[   25.242452]  ? irq_set_affinity_notifier+0x130/0x130
[   25.242457]  ? kasan_slab_free+0x89/0xc0
[   25.242466]  process_one_work+0x32f/0x6f0
[   25.242472]  worker_thread+0x89/0x770
[   25.242481]  ? pci_mmcfg_check_reserved+0xc0/0xc0
[   25.242488]  kthread+0x18c/0x1e0
[   25.242493]  ? process_one_work+0x6f0/0x6f0
[   25.242499]  ? kthread_create_on_node+0xc0/0xc0
[   25.242506]  ret_from_fork+0x2c/0x40
[   25.242511] Object at ffff880462eea960, in cache kmalloc-8 size: 8
[   25.242513] Allocated:
[   25.242514] PID = 170
[   25.242522]  save_stack_trace+0x1b/0x20
[   25.242529]  save_stack+0x46/0xd0
[   25.242533]  kasan_kmalloc+0xad/0xe0
[   25.242537]  __kmalloc_node+0x12c/0x2b0
[   25.242542]  alloc_cpumask_var_node+0x3c/0x60
[   25.242546]  alloc_cpumask_var+0xe/0x10
[   25.242550]  irq_affinity_notify+0x94/0x230
[   25.242555]  process_one_work+0x32f/0x6f0
[   25.242559]  worker_thread+0x89/0x770
[   25.242564]  kthread+0x18c/0x1e0
[   25.242568]  ret_from_fork+0x2c/0x40
[   25.242569] Freed:
[   25.242570] PID = 0
[   25.242572] (stack is not available)
[   25.242573] Memory state around the buggy address:
[   25.242578]  ffff880462eea800: fc fc 00 fc fc 00 fc fc 00 fc fc 00 fc fc fb fc
[   25.242582]  ffff880462eea880: fc fb fc fc fb fc fc 00 fc fc 00 fc fc 00 fc fc
[   25.242586] >ffff880462eea900: 00 fc fc 00 fc fc 00 fc fc fb fc fc 00 fc fc fc
[   25.242588]                                                           ^
[   25.242592]  ffff880462eea980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[   25.242596]  ffff880462eeaa00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[   25.242597] ==================================================================

Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
This should be considered for -stable, back to 4.10.

 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2db93d3f6d23..c0e42d162c7c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3495,7 +3495,7 @@ static void i40e_irq_affinity_notify(struct irq_affinity_notify *notify,
 	struct i40e_q_vector *q_vector =
 		container_of(notify, struct i40e_q_vector, affinity_notify);
 
-	q_vector->affinity_mask = *mask;
+	cpumask_copy(&q_vector->affinity_mask, mask);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 7c213a347909..a4b60367ecce 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -520,7 +520,7 @@ static void i40evf_irq_affinity_notify(struct irq_affinity_notify *notify,
 	struct i40e_q_vector *q_vector =
 		container_of(notify, struct i40e_q_vector, affinity_notify);
 
-	q_vector->affinity_mask = *mask;
+	cpumask_copy(&q_vector->affinity_mask, mask);
 }
 
 /**
-- 
2.9.4
