From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 24/46] [SCSI] fcoe: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Mon, 18 Feb 2013 18:11:33 +0530
Message-ID: <20130218124133.26245.87187.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: Robert Love <robert.w.love@intel.com>
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: devel@open-fcoe.org
Cc: linux-scsi@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 drivers/scsi/fcoe/fcoe.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 666b7ac..c971a17 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1475,6 +1475,7 @@ static int fcoe_rcv(struct sk_buff *skb, struct net_device *netdev,
 	 * was originated, otherwise select cpu using rx exchange id
 	 * or fcoe_select_cpu().
 	 */
+	get_online_cpus_atomic();
 	if (ntoh24(fh->fh_f_ctl) & FC_FC_EX_CTX)
 		cpu = ntohs(fh->fh_ox_id) & fc_cpu_mask;
 	else {
@@ -1484,8 +1485,10 @@ static int fcoe_rcv(struct sk_buff *skb, struct net_device *netdev,
 			cpu = ntohs(fh->fh_rx_id) & fc_cpu_mask;
 	}
 
-	if (cpu >= nr_cpu_ids)
+	if (cpu >= nr_cpu_ids) {
+		put_online_cpus_atomic();
 		goto err;
+	}
 
 	fps = &per_cpu(fcoe_percpu, cpu);
 	spin_lock(&fps->fcoe_rx_list.lock);
@@ -1505,6 +1508,7 @@ static int fcoe_rcv(struct sk_buff *skb, struct net_device *netdev,
 		spin_lock(&fps->fcoe_rx_list.lock);
 		if (!fps->thread) {
 			spin_unlock(&fps->fcoe_rx_list.lock);
+			put_online_cpus_atomic();
 			goto err;
 		}
 	}
@@ -1526,6 +1530,7 @@ static int fcoe_rcv(struct sk_buff *skb, struct net_device *netdev,
 	if (fps->thread->state == TASK_INTERRUPTIBLE)
 		wake_up_process(fps->thread);
 	spin_unlock(&fps->fcoe_rx_list.lock);
+	put_online_cpus_atomic();
 
 	return 0;
 err:
