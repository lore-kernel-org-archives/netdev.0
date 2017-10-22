From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Subject: [PATCH v2 37/37] net/mvpp2: Replace tasklet with softirq hrtimer
Date: Sun, 22 Oct 2017 23:40:15 +0200
Message-ID: <20171022214054.007080900@linutronix.de>
References: <20171022213938.940451689@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>, keescook@chromium.org,
        Christoph Hellwig <hch@lst.de>,
        John Stultz <john.stultz@linaro.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline;
 filename=netmvpp2_Replace_tasklet_with_softirq_hrtimer.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

The tx_done_tasklet tasklet is used in invoke the hrtimer
(mvpp2_hr_timer_cb) in softirq context. This can be also achieved without
the tasklet but with HRTIMER_MODE_SOFT as hrtimer mode.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/marvell/mvpp2.c |   62 ++++++++++++++---------------------
 1 file changed, 25 insertions(+), 37 deletions(-)

--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -830,9 +830,8 @@ struct mvpp2_pcpu_stats {
 /* Per-CPU port control */
 struct mvpp2_port_pcpu {
 	struct hrtimer tx_done_timer;
+	struct net_device *dev;
 	bool timer_scheduled;
-	/* Tasklet for egress finalization */
-	struct tasklet_struct tx_done_tasklet;
 };
 
 struct mvpp2_queue_vector {
@@ -5973,46 +5972,34 @@ static void mvpp2_link_event(struct net_
 	}
 }
 
-static void mvpp2_timer_set(struct mvpp2_port_pcpu *port_pcpu)
-{
-	ktime_t interval;
-
-	if (!port_pcpu->timer_scheduled) {
-		port_pcpu->timer_scheduled = true;
-		interval = MVPP2_TXDONE_HRTIMER_PERIOD_NS;
-		hrtimer_start(&port_pcpu->tx_done_timer, interval,
-			      HRTIMER_MODE_REL_PINNED);
-	}
-}
-
-static void mvpp2_tx_proc_cb(unsigned long data)
+static enum hrtimer_restart mvpp2_hr_timer_cb(struct hrtimer *timer)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct mvpp2_port *port = netdev_priv(dev);
-	struct mvpp2_port_pcpu *port_pcpu = this_cpu_ptr(port->pcpu);
+	struct net_device *dev;
+	struct mvpp2_port *port;
+	struct mvpp2_port_pcpu *port_pcpu;
 	unsigned int tx_todo, cause;
 
+	port_pcpu = container_of(timer, struct mvpp2_port_pcpu, tx_done_timer);
+	dev = port_pcpu->dev;
+
 	if (!netif_running(dev))
-		return;
+		return HRTIMER_NORESTART;
+
 	port_pcpu->timer_scheduled = false;
+	port = netdev_priv(dev);
 
 	/* Process all the Tx queues */
 	cause = (1 << port->ntxqs) - 1;
 	tx_todo = mvpp2_tx_done(port, cause, smp_processor_id());
 
 	/* Set the timer in case not all the packets were processed */
-	if (tx_todo)
-		mvpp2_timer_set(port_pcpu);
-}
-
-static enum hrtimer_restart mvpp2_hr_timer_cb(struct hrtimer *timer)
-{
-	struct mvpp2_port_pcpu *port_pcpu = container_of(timer,
-							 struct mvpp2_port_pcpu,
-							 tx_done_timer);
-
-	tasklet_schedule(&port_pcpu->tx_done_tasklet);
+	if (tx_todo && !port_pcpu->timer_scheduled) {
+		port_pcpu->timer_scheduled = true;
+		hrtimer_forward_now(&port_pcpu->tx_done_timer,
+				    MVPP2_TXDONE_HRTIMER_PERIOD_NS);
 
+		return HRTIMER_RESTART;
+	}
 	return HRTIMER_NORESTART;
 }
 
@@ -6498,7 +6485,12 @@ static int mvpp2_tx(struct sk_buff *skb,
 	    txq_pcpu->count > 0) {
 		struct mvpp2_port_pcpu *port_pcpu = this_cpu_ptr(port->pcpu);
 
-		mvpp2_timer_set(port_pcpu);
+		if (!port_pcpu->timer_scheduled) {
+			port_pcpu->timer_scheduled = true;
+			hrtimer_start(&port_pcpu->tx_done_timer,
+				      MVPP2_TXDONE_HRTIMER_PERIOD_NS,
+				      HRTIMER_MODE_REL_PINNED_SOFT);
+		}
 	}
 
 	return NETDEV_TX_OK;
@@ -6883,7 +6875,6 @@ static int mvpp2_stop(struct net_device
 
 			hrtimer_cancel(&port_pcpu->tx_done_timer);
 			port_pcpu->timer_scheduled = false;
-			tasklet_kill(&port_pcpu->tx_done_tasklet);
 		}
 	}
 	mvpp2_cleanup_rxqs(port);
@@ -7651,13 +7642,10 @@ static int mvpp2_port_probe(struct platf
 			port_pcpu = per_cpu_ptr(port->pcpu, cpu);
 
 			hrtimer_init(&port_pcpu->tx_done_timer, CLOCK_MONOTONIC,
-				     HRTIMER_MODE_REL_PINNED);
+				     HRTIMER_MODE_REL_PINNED_SOFT);
 			port_pcpu->tx_done_timer.function = mvpp2_hr_timer_cb;
 			port_pcpu->timer_scheduled = false;
-
-			tasklet_init(&port_pcpu->tx_done_tasklet,
-				     mvpp2_tx_proc_cb,
-				     (unsigned long)dev);
+			port_pcpu->dev = dev;
 		}
 	}
 
