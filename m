From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/mlx4_en: reception NAPI/IRQ race breaker
Date: Sat, 25 Feb 2017 06:22:57 -0800
Message-ID: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35842 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdBYQHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2017 11:07:41 -0500
Received: by mail-pf0-f193.google.com with SMTP id m88so668393pfi.3
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2017 08:07:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While playing with hardware timestamping of RX packets, I found
that some packets were received by TCP stack with a ~200 ms delay...

Since the timestamp was provided by the NIC, and my probe was added
in tcp_v4_rcv() while in BH handler, I was confident it was not
a sender issue, or a drop in the network.

This would happen with a very low probability, but hurting RPC
workloads.

I could track this down to the cx-3 (mlx4 driver) card that was
apparently sending an IRQ before we would arm it.

A NAPI driver normally arms the IRQ after the napi_complete_done(),
after NAPI_STATE_SCHED is cleared, so that the hard irq handler can grab
it.

This patch adds a new rx_irq_miss field that is incremented every time
the hard IRQ handler could not grab NAPI_STATE_SCHED.

Then, mlx4_en_poll_rx_cq() is able to detect that rx_irq was incremented
and attempts to read more packets, if it can re-acquire NAPI_STATE_SCHED

Note that this work around would probably not work if the IRQ is spread
over many cpus, since it assume the hard irq and softirq are handled by
the same cpu. This kind of setup is buggy anyway because of reordering
issues.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |   32 +++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    1 
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 867292880c07a15124a0cf099d1fcda09926548e..7c262dc6a9971ca99a890bc3cff49289f0ef43fc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1132,10 +1132,14 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_cq *cq = container_of(mcq, struct mlx4_en_cq, mcq);
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
-	if (likely(priv->port_up))
-		napi_schedule_irqoff(&cq->napi);
-	else
+	if (likely(priv->port_up)) {
+		if (napi_schedule_prep(&cq->napi))
+			__napi_schedule_irqoff(&cq->napi);
+		else
+			cq->rx_irq_missed++;
+	} else {
 		mlx4_en_arm_cq(priv, cq);
+	}
 }
 
 /* Rx CQ polling - called by NAPI */
@@ -1144,9 +1148,12 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	struct mlx4_en_cq *cq = container_of(napi, struct mlx4_en_cq, napi);
 	struct net_device *dev = cq->dev;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int done;
+	int done = 0;
+	u32 rx_irq_missed;
 
-	done = mlx4_en_process_rx_cq(dev, cq, budget);
+again:
+	rx_irq_missed = READ_ONCE(cq->rx_irq_missed);
+	done += mlx4_en_process_rx_cq(dev, cq, budget - done);
 
 	/* If we used up all the quota - we're probably not done yet... */
 	if (done == budget) {
@@ -1171,10 +1178,21 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 		 */
 		if (done)
 			done--;
+		if (napi_complete_done(napi, done))
+			mlx4_en_arm_cq(priv, cq);
+		return done;
 	}
-	/* Done for now */
-	if (napi_complete_done(napi, done))
+	if (unlikely(READ_ONCE(cq->rx_irq_missed) != rx_irq_missed))
+		goto again;
+
+	if (napi_complete_done(napi, done)) {
 		mlx4_en_arm_cq(priv, cq);
+
+		/* We might have received an interrupt too soon */
+		if (unlikely(READ_ONCE(cq->rx_irq_missed) != rx_irq_missed) &&
+		    napi_reschedule(napi))
+			goto again;
+	}
 	return done;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 4941b692e9479bc7800e92f9bfb13baf3ff7d0d4..030f305fcca7fa4b3b9a15be3fe11e572d665003 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -369,6 +369,7 @@ struct mlx4_en_cq {
 	int                     ring;
 	struct net_device      *dev;
 	struct napi_struct	napi;
+	u32			rx_irq_missed;
 	int size;
 	int buf_size;
 	int vector;
