From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH] drivers/net: Remove IRQF_SAMPLE_RANDOM flag from network drivers
Date: Tue, 29 Mar 2011 04:27:31 +0200
Message-ID: <1301365651-9106-1-git-send-email-martinez.javier@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Florian Fainelli <ffainelli@freebox.fr>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IRQF_SAMPLE_RANDOM flag is marked as deprecated and will be removed.

Every input point to the kernel's entropy pool have to better document the
type of entropy source it is.

drivers/char/random.c now implements a set of interfaces that can be used for
devices to collect enviromental noise. IRQF_SAMPLE_RANDOM will be replaced
with these add_*_randomness exported functions.

Network drivers are not a good source of entropy. They use as a source of
entropy essentially a remote host. Which means that the source of entropy can
be potentially controlled by an attacker. Also, with heavy workloads the
entropy decreases due to less hardware interrupts happening thanks to irq
mitigation and NAPI.

If a system relies in its network interface as a entropy source it has a false
sense of security. Systems that don't have devices whose drivers are good
sources of entropy, should either use a hardware random number generator or
feed the kernel's entropy pool from userspace using other sources of entropy
such as EGD, video_entropyd, timer_entropyd and audio-entropyd.

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/atlx/atl1.c              |    2 +-
 drivers/net/bcm63xx_enet.c           |    4 ++--
 drivers/net/cris/eth_v10.c           |    4 ++--
 drivers/net/ibmlana.c                |    3 ++-
 drivers/net/macb.c                   |    3 +--
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 drivers/net/niu.c                    |    3 +--
 drivers/net/qla3xxx.c                |    2 +-
 drivers/net/tg3.c                    |    4 ++--
 drivers/net/xen-netfront.c           |    3 +--
 10 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 67f40b9..e973d05 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2572,7 +2572,7 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
-	int irq_flags = IRQF_SAMPLE_RANDOM;
+	int irq_flags = 0;
 
 	/* hardware has been reset, we need to reload some things */
 	atlx_set_multi(netdev);
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index e94a966a..2af413f 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -839,8 +839,8 @@ static int bcm_enet_open(struct net_device *dev)
 	if (ret)
 		goto out_phy_disconnect;
 
-	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma,
-			  IRQF_SAMPLE_RANDOM | IRQF_DISABLED, dev->name, dev);
+	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
+			  dev->name, dev);
 	if (ret)
 		goto out_freeirq;
 
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 80c2fee..e759d74 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -491,8 +491,8 @@ e100_open(struct net_device *dev)
 
 	/* allocate the irq corresponding to the receiving DMA */
 
-	if (request_irq(NETWORK_DMA_RX_IRQ_NBR, e100rxtx_interrupt,
-			IRQF_SAMPLE_RANDOM, cardname, (void *)dev)) {
+	if (request_irq(NETWORK_DMA_RX_IRQ_NBR, e100rxtx_interrupt, 0, cardname,
+			(void *)dev)) {
 		goto grace_exit0;
 	}
 
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 94d9969..f872f96 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -782,7 +782,8 @@ static int ibmlana_open(struct net_device *dev)
 
 	/* register resources - only necessary for IRQ */
 
-	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED,
+			     dev->name, dev);
 	if (result != 0) {
 		printk(KERN_ERR "%s: failed to register irq %d\n", dev->name, dev->irq);
 		return result;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 79ccb54..2cb4e792 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1171,8 +1171,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	}
 
 	dev->irq = platform_get_irq(pdev, 0);
-	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+	err = request_irq(dev->irq, macb_interrupt, 0, dev->name, dev);
 	if (err) {
 		printk(KERN_ERR
 		       "%s: Unable to request IRQ %d (error %d)\n",
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 83348dc..9336715 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -905,7 +905,7 @@ netxen_nic_request_irq(struct netxen_adapter *adapter)
 	struct nx_host_sds_ring *sds_ring;
 	int err, ring;
 
-	unsigned long flags = IRQF_SAMPLE_RANDOM;
+	unsigned long flags = 0;
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 32678b6..681a42c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6071,8 +6071,7 @@ static int niu_request_irq(struct niu *np)
 	for (i = 0; i < np->num_ldg; i++) {
 		struct niu_ldg *lp = &np->ldg[i];
 
-		err = request_irq(lp->irq, niu_interrupt,
-				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
+		err = request_irq(lp->irq, niu_interrupt, IRQF_SHARED,
 				  np->irq_name[i], lp);
 		if (err)
 			goto out_free_irqs;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 348b4f136..f3f737b 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3468,7 +3468,7 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 {
 	struct net_device *ndev = qdev->ndev;
 	int err;
-	unsigned long irq_flags = IRQF_SAMPLE_RANDOM | IRQF_SHARED;
+	unsigned long irq_flags = IRQF_SHARED;
 	unsigned long hw_flags;
 
 	if (ql_alloc_mem_resources(qdev)) {
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ebec888..89b76f0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8839,12 +8839,12 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
 		fn = tg3_msi;
 		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 			fn = tg3_msi_1shot;
-		flags = IRQF_SAMPLE_RANDOM;
+		flags = 0;
 	} else {
 		fn = tg3_interrupt;
 		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
 			fn = tg3_interrupt_tagged;
-		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
+		flags = IRQF_SHARED;
 	}
 
 	return request_irq(tnapi->irq_vec, fn, flags, name, tnapi);
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 5c8d9c3..c06f5a0 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1416,8 +1416,7 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 		goto fail;
 
 	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
-					IRQF_SAMPLE_RANDOM, netdev->name,
-					netdev);
+					0, netdev->name, netdev);
 	if (err < 0)
 		goto fail;
 	netdev->irq = err;
-- 
1.7.2.5
