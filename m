From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 5/5] ixgbe: add support for threadable rx irq
Date: Wed, 15 Jun 2016 15:42:06 +0200
Message-ID: <48e47152b803d691f197c3c5fb8f1ab7584d81e8.1465996447.git.pabeni@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1465996447.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Plug-in the threadable irq infrastructure to allow run-time
configuration of rx irqs, when msix irqs are used.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 088c47c..d9a591c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2890,6 +2890,14 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	return 0;
 }
 
+static void ixgbe_irq_mode_notifier(int irq, void *data,
+				    struct task_struct *irq_thread)
+{
+	struct ixgbe_q_vector *q_vector = (struct ixgbe_q_vector *)data;
+
+	q_vector->napi.thread = irq_thread;
+}
+
 /**
  * ixgbe_request_msix_irqs - Initialize MSI-X interrupts
  * @adapter: board private structure
@@ -2921,8 +2929,12 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 			/* skip this unused q_vector */
 			continue;
 		}
-		err = request_irq(entry->vector, &ixgbe_msix_clean_rings, 0,
+		err = request_irq(entry->vector, &ixgbe_msix_clean_rings,
+				  IRQF_TH_NO_AFFINITY | IRQF_TH_SCHED_NORMAL,
 				  q_vector->name, q_vector);
+		if (!err)
+			err = irq_set_mode_notifier(entry->vector, q_vector,
+						    ixgbe_irq_mode_notifier);
 		if (err) {
 			e_err(probe, "request_irq failed for MSIX interrupt "
 			      "Error: %d\n", err);
-- 
1.8.3.1
