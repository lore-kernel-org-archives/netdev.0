From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 21/45] net: Use get/put_online_cpus_atomic() to prevent CPU
 offline
Date: Fri, 28 Jun 2013 01:26:28 +0530
Message-ID: <20130627195627.29830.19367.stgit@srivatsabhat.in.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 net/core/dev.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index faebb39..1530633 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3175,7 +3175,7 @@ int netif_rx(struct sk_buff *skb)
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
 		int cpu;
 
-		preempt_disable();
+		get_online_cpus_atomic();
 		rcu_read_lock();
 
 		cpu = get_rps_cpu(skb->dev, skb, &rflow);
@@ -3185,7 +3185,7 @@ int netif_rx(struct sk_buff *skb)
 		ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
 
 		rcu_read_unlock();
-		preempt_enable();
+		put_online_cpus_atomic();
 	} else
 #endif
 	{
@@ -3604,6 +3604,7 @@ int netif_receive_skb(struct sk_buff *skb)
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
 		int cpu, ret;
 
+		get_online_cpus_atomic();
 		rcu_read_lock();
 
 		cpu = get_rps_cpu(skb->dev, skb, &rflow);
@@ -3611,9 +3612,11 @@ int netif_receive_skb(struct sk_buff *skb)
 		if (cpu >= 0) {
 			ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
 			rcu_read_unlock();
+			put_online_cpus_atomic();
 			return ret;
 		}
 		rcu_read_unlock();
+		put_online_cpus_atomic();
 	}
 #endif
 	return __netif_receive_skb(skb);
@@ -3991,6 +3994,7 @@ static void net_rps_action_and_irq_enable(struct softnet_data *sd)
 		local_irq_enable();
 
 		/* Send pending IPI's to kick RPS processing on remote cpus. */
+		get_online_cpus_atomic();
 		while (remsd) {
 			struct softnet_data *next = remsd->rps_ipi_next;
 
@@ -3999,6 +4003,7 @@ static void net_rps_action_and_irq_enable(struct softnet_data *sd)
 							   &remsd->csd, 0);
 			remsd = next;
 		}
+		put_online_cpus_atomic();
 	} else
 #endif
 		local_irq_enable();
