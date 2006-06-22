From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/5] GSO: Generic Segmentation Offload
Date: Thu, 22 Jun 2006 18:15:43 +1000
Message-ID: <20060622081543.GF22671@gondor.apana.org.au>
References: <20060622081211.GA22505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22532 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161009AbWFVIPp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:15:45 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060622081211.GA22505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

If anyone is interested here is the incremental patch against the previous
series.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/dev.c b/net/core/dev.c
index 9c68ab8..d293e0f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1415,7 +1415,7 @@ gso:
 	/* Disable soft irqs for various locks below. Also 
 	 * stops preemption for RCU. 
 	 */
-	local_bh_disable(); 
+	rcu_read_lock_bh(); 
 
 	/* Updates of qdisc are serialized by queue_lock. 
 	 * The struct Qdisc which is pointed to by qdisc is now a 
@@ -1486,13 +1486,13 @@ #endif
 	}
 
 	rc = -ENETDOWN;
-	local_bh_enable();
+	rcu_read_unlock_bh();
 
 out_kfree_skb:
 	kfree_skb(skb);
 	return rc;
 out:
-	local_bh_enable();
+	rcu_read_unlock_bh();
 	return rc;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 472cb5a..4cdd6ca 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -185,9 +185,13 @@ requeue:
 
 void __qdisc_run(struct net_device *dev)
 {
+	if (unlikely(dev->qdisc == &noop_qdisc))
+		goto out;
+
 	while (qdisc_restart(dev) < 0 && !netif_queue_stopped(dev))
 		/* NOTHING */;
 
+out:
 	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
 }
 
@@ -581,20 +585,24 @@ void dev_deactivate(struct net_device *d
 	spin_lock_bh(&dev->queue_lock);
 	qdisc = dev->qdisc;
 	dev->qdisc = &noop_qdisc;
-	skb = dev->gso_skb;
-	dev->gso_skb = NULL;
 
 	qdisc_reset(qdisc);
 
 	spin_unlock_bh(&dev->queue_lock);
 
-	kfree_skb(skb);
 	dev_watchdog_down(dev);
 
-	while (test_bit(__LINK_STATE_SCHED, &dev->state))
+	/* Wait for outstanding dev_queue_xmit calls. */
+	synchronize_rcu();
+
+	/* Wait for outstanding qdisc_run calls. */
+	while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
 		yield();
 
-	spin_unlock_wait(&dev->_xmit_lock);
+	if (dev->gso_skb) {
+		kfree_skb(dev->gso_skb);
+		dev->gso_skb = NULL;
+	}
 }
 
 void dev_init_scheduler(struct net_device *dev)
