From: Juergen Gross <jgross@suse.com>
Subject: [PATCH v2] i40e/i40evf: use cpumask_copy() for assigning cpumask
Date: Wed, 16 Aug 2017 19:52:57 +0200
Message-ID: <20170816175257.9647-1-jgross@suse.com>
Cc: jeffrey.t.kirsher@intel.com, Juergen Gross <jgross@suse.com>,
        stable@vger.kernel.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using direct assignment for a cpumask is wrong, cpumask_copy() should
be used instead.

Otherwise crashes like the following might happen:

[62792.326374] BUG: unable to handle kernel paging request at ffff8800049ff000
[62792.340118] IP: [<ffffffffa2043341>] i40e_irq_affinity_notify+0x11/0x20 [i40e]
...
[62792.810770] Call Trace:
[62792.815722]  [<ffffffff810d77a5>] irq_affinity_notify+0xb5/0xf0
[62792.827593]  [<ffffffff8109593e>] process_one_work+0x14e/0x410
[62792.839282]  [<ffffffff81096196>] worker_thread+0x116/0x490
[62792.850459]  [<ffffffff8109b667>] kthread+0xc7/0xe0
[62792.860255]  [<ffffffff816094bf>] ret_from_fork+0x3f/0x70
[62792.871996] DWARF2 unwinder stuck at ret_from_fork+0x3f/0x70

Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug")
Cc: <stable@vger.kernel.org> # 4.10+
Signed-off-by: Juergen Gross <jgross@suse.com>
---
V2: enhance commit message, merge patches
---
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
2.12.3
